#import "NotificarePlugin.h"
#import "NotificareAppDelegateSurrogate.h"
#import "NotificarePushLib.h"

@interface NotificarePlugin() {
    BOOL _handleNotification;
}
@property (copy, nonatomic) NSString *mainCallbackId;
@end


@implementation NotificarePlugin

#define kPluginVersion @"1.2.3"

- (void)pluginInitialize {
	NSLog(@"Initializing Notificare Plugin version %@", kPluginVersion);
    [[NotificareAppDelegateSurrogate shared] setSurrogateDelegate:self];
    [[NotificarePushLib shared] launch];
    [[NotificarePushLib shared] setDelegate:self];
    [[NotificarePushLib shared] handleOptions:[[NotificareAppDelegateSurrogate shared] launchOptions]];
}

- (void)start:(CDVInvokedUrlCommand*) command {
    [self setMainCallbackId:[command callbackId]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}

- (void)setHandleNotification:(CDVInvokedUrlCommand*)command {
    _handleNotification = [[command argumentAtIndex:0] boolValue];
}

- (void)enableNotifications:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] registerForNotifications];
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
        [[NotificarePushLib shared] registerDevice:[NSData dataFromHexadecimalString:deviceID] withUserID:userID withUsername:username completionHandler:^(NSDictionary *info) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        } errorHandler:^(NSError *error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        }];
    } else if (userID) {
        [[NotificarePushLib shared] registerDevice:[NSData dataFromHexadecimalString:deviceID] withUserID:userID completionHandler:^(NSDictionary *info) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        } errorHandler:^(NSError *error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        }];
    } else {
        [[NotificarePushLib shared] registerDevice:[NSData dataFromHexadecimalString:deviceID] completionHandler:^(NSDictionary *info) {
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

- (void)createAccount:(CDVInvokedUrlCommand*)command {
    NSDictionary *params = @{@"email": [command argumentAtIndex:0], @"password": [command argumentAtIndex:1], @"userName": [command argumentAtIndex:2]};
    [[NotificarePushLib shared] createAccount:params completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)validateUser:(CDVInvokedUrlCommand*)command {
    NSString *token = [command argumentAtIndex:0];
    [[NotificarePushLib shared] validateAccount:token completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)sendPassword:(CDVInvokedUrlCommand*)command {
    NSDictionary *params = @{@"email": [command argumentAtIndex:0]};
    [[NotificarePushLib shared] sendPassword:params completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)resetPassword:(CDVInvokedUrlCommand*)command {
    NSDictionary *params = @{@"password": [command argumentAtIndex:0]};
    NSString *token = [command argumentAtIndex:1];
    [[NotificarePushLib shared] resetPassword:params withToken:token completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)changePassword:(CDVInvokedUrlCommand*)command {
    NSDictionary *params = @{@"password": [command argumentAtIndex:0]};
    [[NotificarePushLib shared] changePassword:params completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)userLogin:(CDVInvokedUrlCommand*)command {
    NSString *username = [command argumentAtIndex:0];
    NSString *password = [command argumentAtIndex:1];
    if (username && password) {
        [[NotificarePushLib shared] loginWithUsername:username andPassword:password completionHandler:^(NSDictionary *info) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        } errorHandler:^(NSError *error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        }];
    }
}

- (void)userLogout:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] logoutAccount];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}

- (void)generateAccessToken:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] generateAccessToken:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[info objectForKey:@"user"]];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)fetchUserDetails:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] fetchAccountDetails:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[info objectForKey:@"user"]];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)openNotification:(CDVInvokedUrlCommand*)command {
    // NotificarePushLib needs the original payload from APNS
    [[NotificarePushLib shared] openNotification:@{@"notification": [command argumentAtIndex:0]}];
}

#pragma callback methods

- (void)sendErrorResultWithType:(NSString *)type andMessage:(NSString *)message {
    if (_mainCallbackId != nil && message != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:_mainCallbackId];
    }
}

- (void)sendSuccessResult:(NSDictionary *)payload {
    if (_mainCallbackId != nil && payload != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:_mainCallbackId];
    }
}

- (void)sendSuccessResultWithType:(NSString *)type andDictionary:(NSDictionary *)data {
    if (type != nil && data != nil) {
        NSDictionary *payload = @{@"type": type, @"data": data};
        [self sendSuccessResult:payload];
    }
}

- (void)sendSuccessResultWithType:(NSString *)type andString:(NSString *)data {
    if (type != nil && data != nil) {
        NSDictionary *payload = @{@"type": type, @"data": data};
        [self sendSuccessResult:payload];
    }
}



#pragma NotificarePushLibDelegate

- (void)notificarePushLib:(NotificarePushLib *)library onReady:(NSDictionary *)info {
    NSLog(@"Notificare ready");
    [self sendSuccessResultWithType:@"ready" andDictionary:info];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveActivationToken:(NSString *)token {
    [self sendSuccessResultWithType:@"validateUserToken" andString:token];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveResetPasswordToken:(NSString *)token {
    [self sendSuccessResultWithType:@"resetPasswordToken" andString:token];
}

#pragma UIApplicationDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self sendSuccessResultWithType:@"registration" andString:[deviceToken hexadecimalString]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [self sendErrorResultWithType:@"registration" andMessage:[error localizedDescription]];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (_handleNotification && [userInfo objectForKey:@"id"]) {
        [[NotificarePushLib shared]getNotification:[userInfo objectForKey:@"id"] completionHandler:^(NSDictionary *info) {
            // Info is the full notification object in key "notification"
            NSDictionary *notification = [info objectForKey:@"notification"];
            [self sendSuccessResultWithType:@"notification" andDictionary:notification];
        } errorHandler:^(NSError *error) {
            NSLog(@"Error fetching notification: %@", error);
        }];
    } else {
        [[NotificarePushLib shared] openNotification:userInfo];
    }
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    NSLog(@"didReceiveRemoteNotification:fetchCompletionHandler: %@", [userInfo description]);
//    if (_handleNotification && [userInfo objectForKey:@"id"]) {
//        [[NotificarePushLib shared]getNotification:[userInfo objectForKey:@"id"] completionHandler:^(NSDictionary *info) {
//            // Info is the full notification object in key "notification"
//            NSDictionary *notification = [info objectForKey:@"notification"];
//            [self sendSuccessResultWithType:@"notification" andDictionary:notification];
//            completionHandler(UIBackgroundFetchResultNewData);
//        } errorHandler:^(NSError *error) {
//            NSLog(@"Error fetching notification: %@", error);
//            completionHandler(UIBackgroundFetchResultFailed);
//        }];
//    } else {
//        [[NotificarePushLib shared] openNotification:userInfo];
//        completionHandler(UIBackgroundFetchResultNewData);
//    }
//}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completion {
    [[NotificarePushLib shared] handleAction:identifier forNotification:userInfo withData:nil completionHandler:^(NSDictionary *info) {
        completion();
    } errorHandler:^(NSError *error) {
        completion();
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    [[NotificarePushLib shared]  handleOpenURL:url];
    return YES;
}


@end
