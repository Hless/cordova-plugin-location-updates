//
//  BLLocationService.h
//  CDVPluginTest
//
//  Created by Boy van der laak on 05/02/15.
//
//

#import <Foundation/Foundation.h>


extern NSString *const BLLocationServiceErrorDomain;

enum {
    BLLocationServiceDisabledError = 1000,
    BLLocationServiceDeviceNotCapableError,
    BLLocationServiceNoURLError
};

@class CLLocationManager;

@interface BLLocationService : NSObject

@property (strong, nonatomic, readonly) CLLocationManager* locationManager;

@property (strong, nonatomic) NSString* url;
@property (assign, nonatomic) NSInteger maximumAge; // Maximum age of CLLocation object when received
@property (strong, nonatomic) NSDictionary* headers; // Additional headers
@property (strong, nonatomic) NSDictionary* parameters;

+ (instancetype) locationService;

- (void) startWithError:(NSError **)error;
- (void) stop;
- (void) persist;
@end
