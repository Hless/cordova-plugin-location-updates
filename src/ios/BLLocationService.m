//
//  BLLocationService.m
//  CDVPluginTest
//
//  Created by Boy van der laak on 05/02/15.
//
//
#import "BLLocationService.h"
#import <CoreLocation/CoreLocation.h>



@interface BLLocationService () <CLLocationManagerDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) CLLocation* lastLocation;
@property (strong, nonatomic) NSURLConnection* activeConnection;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (assign, nonatomic) int currentRetries;

@end

NSString *const BLLocationServiceErrorDomain = @"BLLocationService";
static int kPOSTMaxRetries = 3;

@implementation BLLocationService

+ (void) load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
}

+ (void)didFinishLaunching:(NSNotification*)notification {
    NSDictionary* launchOptions = notification.userInfo;
    
    
    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        // Applicaiton has been launched because of significant location update.
        // We should ask for location updates
        [[BLLocationService locationService] startWithError:nil];
    }
}


+ (instancetype) locationService {
    static BLLocationService *gLocationService = nil;
    @synchronized(self) {
        if (gLocationService == nil)
            gLocationService = [[self alloc] init];
    }
    return gLocationService;
}

- (id) init {
    if(self = [super init]){
        _locationManager = [CLLocationManager new];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.activityType = CLActivityTypeOther;
        _locationManager.delegate = self;
        
        
        [self _recover];
        
    }
    
    return self;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.lastLocation = [locations lastObject];
    self.currentRetries = 0;
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:
                           ^{
                               [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                           }];
    
    [self _save];
    
}

- (void) startWithError:(NSError **)error {
    
    if(!self.url) {
        // No URL, we can't start monitoring
        NSLog(@"[BLLocationService] No URL supplied for posting user location.");
        *error = [NSError errorWithDomain:BLLocationServiceErrorDomain code:BLLocationServiceNoURLError userInfo:nil];
        return;
    }
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        // Ask for background persmission
        [self.locationManager performSelector:@selector(requestAlwaysAuthorization)];
    }
    
    if(![CLLocationManager locationServicesEnabled]) {
        *error = [NSError errorWithDomain:BLLocationServiceErrorDomain code:BLLocationServiceDisabledError userInfo:nil];
        NSLog(@"[BLLocationService] Location services are disabled");
        return;
    }
    
    if(![CLLocationManager significantLocationChangeMonitoringAvailable]) {
        *error = [NSError errorWithDomain:BLLocationServiceErrorDomain code:BLLocationServiceDeviceNotCapableError userInfo:nil];
        NSLog(@"[BLLocationService] Significant location changes are not available on this device.");
        return;
    }
    
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void) stop {
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void) persist {
    // Persist values
    
    NSDictionary* values = @{@"url": self.url,
                             @"maximumAge": [NSNumber numberWithInteger:self.maximumAge],
                             @"headers": self.headers,
                             @"parameters": self.parameters};
    
    [[NSUserDefaults standardUserDefaults] setObject:values forKey:@"BLLocationService.persistedObject"];
    //...
    
}

- (void) _recover {
    
    // Recover persisted values
    NSDictionary * values = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"BLLocationService.persistedObject"];
    self.url = values[@"url"];
    self.maximumAge = [values[@"maximumAge"] integerValue];
    self.headers = values[@"headers"];
    self.parameters = values[@"parameters"];
    
}

- (void) _save  {
    
    if(!self.lastLocation) {
        NSLog(@"[BLLocationService] There is no location to save");
        return;
    }
    
    if(self.activeConnection) {
        [self.activeConnection cancel];
        self.activeConnection = nil;
    }
    
    if(self.maximumAge && [self.lastLocation.timestamp timeIntervalSince1970] > ([[NSDate date] timeIntervalSince1970] - self.maximumAge)) {
        NSLog(@"[BLLocationService] Location is too old" );
        return;
    }
    
    
    self.currentRetries++;
    
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObject:[self _dictionaryFromLocation:self.lastLocation] forKey:@"location"];
    
    [postDict addEntriesFromDictionary:self.parameters];
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:&error];
    
    // Cancel previous requests
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:5];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if(self.headers)
        [self.headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    
    self.activeConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [self.activeConnection start];
    
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    
    self.activeConnection = nil;
    
    if(self.currentRetries == kPOSTMaxRetries) {
        [self _finishBackgroundTask];
        return;
    }
    [self performSelector:@selector(_save) withObject:nil afterDelay:5];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self _finishBackgroundTask];
}


- (void) _finishBackgroundTask {
    if(self.activeConnection) {
        [self.activeConnection cancel];
        self.activeConnection = nil;
    }
    if(self.backgroundTask && self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (NSDictionary *) _dictionaryFromLocation:(CLLocation *)location {
    NSMutableDictionary* locationDict = [NSMutableDictionary dictionary];
    
    [locationDict setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [locationDict setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    
    [locationDict setObject:[NSNumber numberWithDouble:location.altitude] forKey:@"altitude"];
    
    [locationDict setObject:[NSNumber numberWithDouble:location.horizontalAccuracy] forKey:@"horizontalAccuracy"];
    [locationDict setObject:[NSNumber numberWithDouble:location.verticalAccuracy] forKey:@"verticalAccuracy"];
    
    return [locationDict copy];
}

@end
