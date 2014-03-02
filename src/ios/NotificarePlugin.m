#import "NotificarePlugin.h"
#import "NotificareAppDelegateSurrogate.h"
#import "NotificarePushLib.h"

@interface NotificarePlugin()

@end


@implementation NotificarePlugin

- (void)pluginInitialize {
    [[NotificareAppDelegateSurrogate shared] setSurrogateDelegate:self];
    [[NotificarePushLib shared] launch];
    [[NotificarePushLib shared] setDelegate:self];
    NSDictionary *launchOptions = [[NotificareAppDelegateSurrogate shared] launchOptions];
    if ([launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]) {
    	[[NotificarePushLib shared] handleOptions:[[[NotificareAppDelegateSurrogate shared] launchOptions] objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
    }
}

- (void)enableNotifications:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] registerForRemoteNotificationsTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
   
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}


- (void)enableLocationUpdates:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] startLocationUpdates];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}


- (void)disableNotifications:(CDVInvokedUrlCommand*)command {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [[NotificarePushLib shared] unregisterDevice];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}


- (void)disableLocationUpdates:(CDVInvokedUrlCommand*)command {
    [[[NotificarePushLib shared] locationManager] stopMonitoringSignificantLocationChanges];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}


- (void)registerDevice:(CDVInvokedUrlCommand*)command {
    NSString *deviceID = [command argumentAtIndex:0];
    NSString *userID = [command argumentAtIndex:1];
    NSString *username = [command argumentAtIndex:2];
    if (username) {
        [[NotificarePushLib shared] registerDevice:[NSData dataFromBase64String:deviceID] withUserID:userID withUsername:username completionHandler:^(NSDictionary *info) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        } errorHandler:^(NSError *error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        }];
    } else if (userID) {
        [[NotificarePushLib shared] registerDevice:[NSData dataFromBase64String:deviceID] withUserID:userID completionHandler:^(NSDictionary *info) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        } errorHandler:^(NSError *error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        }];
    } else {
        [[NotificarePushLib shared] registerDevice:[NSData dataFromBase64String:deviceID] completionHandler:^(NSDictionary *info) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        } errorHandler:^(NSError *error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        }];
    }
}


- (void)getDeviceId:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NotificarePushLib shared] deviceToken]];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}


- (void)addDeviceTags:(CDVInvokedUrlCommand*)command {
    NSArray *tags = [command argumentAtIndex:0];
    if (tags) {
        [[NotificarePushLib shared] addTags:tags completionHandler:^(NSDictionary *info) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        } errorHandler:^(NSError *error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        }];
    }
}


- (void)removeDeviceTag:(CDVInvokedUrlCommand*)command {
    NSString *tag = [command argumentAtIndex:0];
    if (tag) {
        [[NotificarePushLib shared] removeTag:tag completionHandler:^(NSDictionary *info) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        } errorHandler:^(NSError *error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        }];
    }
}


- (void)clearDeviceTags:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] clearTags:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}


- (void)fetchDeviceTags:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] getTags:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:[info objectForKey:@"tags"]];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}


#pragma UIApplicationDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *js = [NSString stringWithFormat:@"Notificare.registrationCallback(null, '%@');", [deviceToken base64EncodedString]];
    [[self webView] stringByEvaluatingJavaScriptFromString:js];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"%@",error);
    NSString *js = [NSString stringWithFormat:@"Notificare.registrationCallback(new Error('%@'));", [error localizedDescription]];
    [[self webView] stringByEvaluatingJavaScriptFromString:js];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NotificarePushLib shared] openNotification:userInfo];
}

@end