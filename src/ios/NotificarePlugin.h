#import <Cordova/CDV.h>
#import "NotificarePushLib.h"

@interface NSDictionary (NotificareJSON)
- (NSString *)escapedJSONString;
@end

@interface NSArray (NotificareJSON)
- (NSString *)escapedJSONString;
@end

@interface NSString (NotificareJSON)
- (NSString *)escapedString;
@end

@interface NotificarePlugin : CDVPlugin <UIApplicationDelegate, NotificarePushLibDelegate>

- (void)enableNotifications:(CDVInvokedUrlCommand *)command;
- (void)enableLocationUpdates:(CDVInvokedUrlCommand *)command;
- (void)disableNotifications:(CDVInvokedUrlCommand *)command;
- (void)disableLocationUpdates:(CDVInvokedUrlCommand *)command;
- (void)registerDevice:(CDVInvokedUrlCommand *)command;
- (void)getDeviceId:(CDVInvokedUrlCommand *)command;
- (void)addDeviceTags:(CDVInvokedUrlCommand *)command;
- (void)removeDeviceTag:(CDVInvokedUrlCommand *)command;
- (void)clearDeviceTags:(CDVInvokedUrlCommand *)command;
- (void)fetchDeviceTags:(CDVInvokedUrlCommand *)command;
- (void)createAccount:(CDVInvokedUrlCommand *)command;
- (void)validateUser:(CDVInvokedUrlCommand *)command;
- (void)sendPassword:(CDVInvokedUrlCommand *)command;
- (void)resetPassword:(CDVInvokedUrlCommand *)command;
- (void)changePassword:(CDVInvokedUrlCommand *)command;
- (void)userLogin:(CDVInvokedUrlCommand *)command;
- (void)userLogout:(CDVInvokedUrlCommand *)command;
- (void)generateAccessToken:(CDVInvokedUrlCommand *)command;
- (void)fetchUserDetails:(CDVInvokedUrlCommand *)command;
- (void)openNotification:(CDVInvokedUrlCommand *)command;

@end
