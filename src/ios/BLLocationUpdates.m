/********* BLLocationUpdates.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "BLLocationService.h"

@interface BLLocationUpdates : CDVPlugin {
  // Member variables go here.
}

- (void)start:(CDVInvokedUrlCommand*)command;
@end

@implementation BLLocationUpdates


- (void) configure: (CDVInvokedUrlCommand *) command {
    BLLocationService* service = [BLLocationService locationService];
    
    service.url = [command.arguments objectAtIndex:0];
    service.maximumAge = [[command.arguments objectAtIndex:1] integerValue];
    service.parameters = [command.arguments objectAtIndex:2];
    service.headers = [command.arguments objectAtIndex:3];
    
    [service persist];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}

- (void) start:(CDVInvokedUrlCommand*)command
{

    NSError* error = nil;
    [[BLLocationService locationService] startWithError:&error];
    
    CDVPluginResult* result;
    if(error) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
 
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) stop:(CDVInvokedUrlCommand *)command
{
    [[BLLocationService locationService] stop];
    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
