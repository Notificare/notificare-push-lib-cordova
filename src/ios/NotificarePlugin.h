#import <Cordova/CDV.h>
#import "NotificarePushLib.h"

@interface NotificarePlugin : CDVPlugin <UIApplicationDelegate, NotificarePushLibDelegate>

- (void)enableNotifications:(CDVInvokedUrlCommand*)command;
- (void)enableLocationUpdates:(CDVInvokedUrlCommand*)command;
- (void)disableNotifications:(CDVInvokedUrlCommand*)command;
- (void)disableLocationUpdates:(CDVInvokedUrlCommand*)command;
- (void)registerDevice:(CDVInvokedUrlCommand *)command;
- (void)getDeviceId:(CDVInvokedUrlCommand *)command;
- (void)addDeviceTags:(CDVInvokedUrlCommand *)command;
- (void)removeDeviceTag:(CDVInvokedUrlCommand *)command;
- (void)clearDeviceTags:(CDVInvokedUrlCommand *)command;
- (void)fetchDeviceTags:(CDVInvokedUrlCommand *)command;

@end
