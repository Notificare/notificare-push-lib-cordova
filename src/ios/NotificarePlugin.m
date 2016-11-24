/*
 Copyright 2015 Notificare B.V.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "NotificarePlugin.h"
#import "NotificareAppDelegateSurrogate.h"
#import "NotificarePushLib.h"
#import "NotificareInboxManager.h"

@interface NotificareInboxManager (/* Private Methods */)
- (void)handleNotification:(NSString *)notificationID isOpened:(BOOL)opened;
@end

@interface NotificarePlugin() {
    BOOL _handleNotification;
    BOOL _handleBadge;
}
@property (copy, nonatomic) NSString *mainCallbackId;
@property (strong, nonatomic) NSMutableArray *resultQueue;
@property (strong, nonatomic) NSMutableSet *receiveQueue;
@end


@implementation NotificarePlugin

#define kPluginVersion @"1.9.0"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

- (void)pluginInitialize {
	NSLog(@"Initializing Notificare Plugin version %@", kPluginVersion);
	[self setResultQueue:[[NSMutableArray alloc] init]];
	[self setReceiveQueue:[[NSMutableSet alloc] init]];
    [[NotificareAppDelegateSurrogate shared] setSurrogateDelegate:self];
    [[NotificarePushLib shared] launch];
    [[NotificarePushLib shared] setDelegate:self];
}

- (void)start:(CDVInvokedUrlCommand*) command {
    NSLog(@"NotificarePlugin: start");
    [self setMainCallbackId:[command callbackId]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    NSDictionary *options = [[NotificareAppDelegateSurrogate shared] launchOptions];
    BOOL handled = NO;
    if (_handleNotification) {
        if ([options objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] && [[options objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"id"]) {
            // Send it to JS
            NSLog(@"NotificarePlugin: app launched with remote notification, fetching and sending to JS");
            [self logReceivedNotification:[[options objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"id"]];
            [self logInfluencedOpenNotification:[[options objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"id"]];
            [[NotificarePushLib shared] getNotification:[[options objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"id"] completionHandler:^(NSDictionary *info) {
                // Info is the full notification object in key "notification"
                NSDictionary *notification = [info objectForKey:@"notification"];
                [self sendSuccessResultWithType:@"notification" andDictionary:notification];
            } errorHandler:^(NSError *error) {
                NSLog(@"NotificarePlugin: error fetching notification: %@", error);
            }];
            handled = YES;
        } else if ([options objectForKey:@"UIApplicationLaunchOptionsLocalNotificationKey"]) {
            UILocalNotification *notification = [options objectForKey:@"UIApplicationLaunchOptionsLocalNotificationKey"];
            [self logReceivedNotification:[[notification userInfo] objectForKey:@"id"]];
            [self logInfluencedOpenNotification:[[notification userInfo] objectForKey:@"id"]];
            if ([notification userInfo] && [[notification userInfo] objectForKey:@"id"]) {
                NSLog(@"NotificarePlugin: app launched with local notification, fetching and sending to JS");
                // Send it to JS
                [[NotificarePushLib shared] getNotification:[[options objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"id"] completionHandler:^(NSDictionary *info) {
                    // Info is the full notification object in key "notification"
                    NSDictionary *notification = [info objectForKey:@"notification"];
                    [self sendSuccessResultWithType:@"notification" andDictionary:notification];
                } errorHandler:^(NSError *error) {
                    NSLog(@"NotificarePlugin: error fetching notification: %@", error);
                }];
                handled = YES;
            }
        }
    }
    if (handled) {
        [self refreshBadge];
    } else {
        [[NotificarePushLib shared] handleOptions:options];
    }
    [[NotificareAppDelegateSurrogate shared] clearLaunchOptions];

}

- (void)setHandleNotification:(CDVInvokedUrlCommand*)command {
    _handleNotification = [[command argumentAtIndex:0] boolValue];
}

- (void)setHandleBadge:(CDVInvokedUrlCommand*)command {
    _handleBadge = [[command argumentAtIndex:0] boolValue];
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
    [[NotificarePushLib shared] unregisterForNotifications];
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
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[[NotificarePushLib shared] myDevice] deviceID]];
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
    NSString *email = [command argumentAtIndex:0];
    NSString *password = [command argumentAtIndex:1];
    NSString *userName = [command argumentAtIndex:2];
    [[NotificarePushLib shared] createAccount:email withName:userName andPassword:password completionHandler:^(NSDictionary *info) {
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
    NSString *email = [command argumentAtIndex:0];
    [[NotificarePushLib shared] sendPassword:email completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)resetPassword:(CDVInvokedUrlCommand*)command {
    NSString *password = [command argumentAtIndex:0];
    NSString *token = [command argumentAtIndex:1];
    [[NotificarePushLib shared] resetPassword:password withToken:token completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)changePassword:(CDVInvokedUrlCommand*)command {
    NSString *password = [command argumentAtIndex:0];
    [[NotificarePushLib shared] changePassword:password completionHandler:^(NSDictionary *info) {
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
    // NotificarePushLib needs the original payload from APNS or a wrapped notification
    NSDictionary *notification = [command argumentAtIndex:0];
    NSLog(@"NotificarePlugin: opening notification");
    // Add aps.alert to make sure NotificarePushLib doesn't see this as a system push
    [[NotificarePushLib shared] openNotification:@{@"aps":@{@"alert":[notification objectForKey:@"message"]}, @"notification": notification}];
    [self refreshBadge];
}

- (void)logOpenNotification:(CDVInvokedUrlCommand*)command {
    // NotificarePushLib needs the original payload from APNS or a wrapped notification
    [[NotificarePushLib shared] logOpenNotification:@{@"notification":[command argumentAtIndex:0]}];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    [self refreshBadge];
}

- (void)fetchInbox:(CDVInvokedUrlCommand*)command {
    NSNumber *skip = [command argumentAtIndex:0];
    NSNumber *limit = [command argumentAtIndex:1];
    [[NotificarePushLib shared] fetchInbox:nil skip:skip limit:limit completionHandler:^(NSDictionary *info) {
        NSMutableArray *inboxResult = [[NSMutableArray alloc] init];
        if ([info objectForKey:@"inbox"]) {
            for (NotificareDeviceInbox *inboxItem in [info objectForKey:@"inbox"]) {
                NSDictionary *inboxItemResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [inboxItem inboxId], @"itemId",
                                                 [inboxItem notification], @"notification",
                                                 [inboxItem message], @"message",
                                                 [NSNumber numberWithBool:[inboxItem opened]], @"status",
                                                 [inboxItem time], @"timestamp",
                                                 nil];
                [inboxResult addObject:inboxItemResult];
            }
        }
        NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                                inboxResult, @"inbox",
                                [info objectForKey:@"total"], @"total",
                                [info objectForKey:@"unread"], @"unread",
                                nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)markInboxItem:(CDVInvokedUrlCommand*)command {
    NSDictionary *inboxJSON = [command argumentAtIndex:0];
    NotificareDeviceInbox *inboxItemStub = [[NotificareDeviceInbox alloc] init];
    [inboxItemStub setInboxId:[inboxJSON objectForKey:@"itemId"]];
    [inboxItemStub setNotification:[inboxJSON objectForKey:@"notification"]];
    [[NotificarePushLib shared] markAsRead:inboxItemStub completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        [self refreshBadge];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)deleteInboxItem:(CDVInvokedUrlCommand*)command {
    NSDictionary *inboxJSON = [command argumentAtIndex:0];
    NotificareDeviceInbox *inboxItemStub = [[NotificareDeviceInbox alloc] init];
    [inboxItemStub setInboxId:[inboxJSON objectForKey:@"itemId"]];
    [inboxItemStub setNotification:[inboxJSON objectForKey:@"notification"]];
    [[NotificarePushLib shared] removeFromInbox:inboxItemStub completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        [self refreshBadge];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)clearInbox:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] clearInbox:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
        [self refreshBadge];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

- (void)setApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command {
    NSNumber *options = [command argumentAtIndex:0];
    int badge = [options intValue] ?: 0;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}

- (void)getApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command {
    NSInteger badge = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)badge];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}

- (void)logCustomEvent:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] logCustomEvent:[command argumentAtIndex:0] withData:[command argumentAtIndex:1] completionHandler:^(NSDictionary *info) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    } errorHandler:^(NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
    }];
}

#pragma logging of notification events

- (void)logInfluencedOpenNotification:(NSString *)notificationID {
    NSLog(@"NotificarePlugin: Log Influenced Open");
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    //what to save
    NSMutableDictionary* log = [NSMutableDictionary dictionary];
    [log setValue:[settings objectForKey:@"notificareSessionID"] forKey:@"sessionID"];
    [log setValue:@"re.notifica.event.notification.Influenced" forKey:@"type"];
    [log setValue:notificationID forKey:@"notification"];
    [log setValue:[settings objectForKey:@"notificareUserID"] forKey:@"userID"];
    [log setValue:[settings objectForKey:@"notificareDeviceToken"] forKey:@"deviceID"];

    //make the call
    [[NotificarePushLib shared] doPushHostOperation:@"POST" path:@"event" URLParams:nil bodyJSON:log successHandler:^(NSDictionary *info) {
        NSLog(@"NotificarePlugin: Received Notification Log for %@", notificationID);
    } errorHandler:^(NotificareNetworkOperation *operation, NSError *error) {
       switch ([error code]) {
           case kNotificareErrorCodeGatewayTimeout:
           case kNotificareErrorCodeBadGateway:
           case kNotificareErrorCodeServiceUnavailable:
               [self logInfluencedOpenNotification:notificationID];
               break;
           default:
               if([error code] < 0){
                   [self logInfluencedOpenNotification:notificationID];
               }
               break;
       }
    }];
}

- (void)logReceivedNotification:(NSString *)notificationID {
    NSLog(@"NotificarePlugin: Log Notification Received");
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    //what to save
    NSMutableDictionary* log = [NSMutableDictionary dictionary];
    [log setValue:[settings objectForKey:@"notificareSessionID"] forKey:@"sessionID"];
    [log setValue:@"re.notifica.event.notification.Receive" forKey:@"type"];
    [log setValue:notificationID forKey:@"notification"];
    [log setValue:[settings objectForKey:@"notificareUserID"] forKey:@"userID"];
    [log setValue:[settings objectForKey:@"notificareDeviceToken"] forKey:@"deviceID"];

    //make the call
    [[NotificarePushLib shared] doPushHostOperation:@"POST" path:@"event" URLParams:nil bodyJSON:log successHandler:^(NSDictionary *info) {
        NSLog(@"NotificarePlugin: Received Notification Log for %@", notificationID);
    } errorHandler:^(NotificareNetworkOperation *operation, NSError *error) {
       switch ([error code]) {
           case kNotificareErrorCodeGatewayTimeout:
           case kNotificareErrorCodeBadGateway:
           case kNotificareErrorCodeServiceUnavailable:
               [self logReceivedNotification:notificationID];
               break;
           default:
               if([error code] < 0){
                   [self logReceivedNotification:notificationID];
               }
               break;
       }
    }];
}

/**
 * Helper method to refresh the badge
 */
-(void)refreshBadge {
    NSLog(@"NotificarePlugin: Refresh badge");
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings objectForKey:@"notificareDeviceToken"] && _handleBadge) {
        [[NotificarePushLib shared] fetchInbox:[NSDate date] skip:0 limit:0 completionHandler:^(NSDictionary *info) {
            if ([info objectForKey:@"unread"]) {
                [settings setObject:[NSNumber numberWithInt:[[info objectForKey:@"unread"] intValue]] forKey:@"NotificareInboxBadge"];
                
                if (_handleBadge) {
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[info objectForKey:@"unread"] intValue]];
                    [self sendSuccessResultWithType:@"badge" andNumber:[info objectForKey:@"unread"]];
                }
            }
        } errorHandler:^(NSError *error) {
            if (_handleBadge) {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[settings objectForKey:@"NotificareInboxBadge"] intValue]];
                [self sendSuccessResultWithType:@"badge" andNumber:[settings objectForKey:@"NotificareInboxBadge"]];
            }
        }];
    }
}

#pragma callback methods

- (void)sendResultQueue {
    NSLog(@"NotificarePlugin: sending queued results");
    for (CDVPluginResult *pluginResult in _resultQueue) {
        [[self commandDelegate] sendPluginResult:pluginResult callbackId:_mainCallbackId];
    }
    [_resultQueue removeAllObjects];
}

- (void)sendErrorResultWithType:(NSString *)type andMessage:(NSString *)message {
    if (message != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        if (_mainCallbackId != nil) {
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:_mainCallbackId];
        } else {
            [_resultQueue addObject:pluginResult];
        }
    }
}

- (void)sendSuccessResult:(NSDictionary *)payload {
    if (payload != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        if (_mainCallbackId != nil) {
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:_mainCallbackId];
        } else {
            [_resultQueue addObject:pluginResult];
        }
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

- (void)sendSuccessResultWithType:(NSString *)type andNumber:(NSNumber *)data {
    if (type != nil && data != nil) {
        NSDictionary *payload = @{@"type": type, @"data": data};
        [self sendSuccessResult:payload];
    }
}


#pragma NotificarePushLibDelegate

- (void)notificarePushLib:(NotificarePushLib *)library onReady:(NSDictionary *)info {
    NSLog(@"NotificarePlugin: Notificare ready");
    [self sendSuccessResultWithType:@"ready" andDictionary:info];
    [self sendResultQueue];
}

-(void)notificarePushLib:(NotificarePushLib *)library willHandleNotification:(UNNotification *)notification {

    //Check if there's an id
    if([[[[[notification request] content] userInfo] allKeys] containsObject:@"id"]){

        //Save only non-nil aps.alert notifications
        if([[[[notification request] content] userInfo] objectForKey:@"aps"] && [[[[[notification request] content] userInfo] objectForKey:@"aps"] objectForKey:@"alert"]){


            //Check if inbox is activated
            if ([[[[[[NotificarePushLib shared] applicationInfo] objectForKey:@"services"] objectForKey:@"inboxConfig"] objectForKey:@"useInbox"] boolValue]) {

                // No use calling the shared inbox manager if inbox isn't enabled
                if ([[NotificareInboxManager sharedManager] enabled]) {
                    [[NotificareInboxManager sharedManager] handleNotification:[[[[notification request] content] userInfo] objectForKey:@"id"] isOpened:NO];
                }

            }


            [[NotificarePushLib shared] getNotification:[[[[notification request] content] userInfo] objectForKey:@"id"] completionHandler:^(NSDictionary *info) {
                // Info is the full notification object in key "notification"
                NSMutableDictionary *notificationDictionary = [NSMutableDictionary dictionaryWithDictionary:[[[[notification request] content] userInfo] objectForKey:@"notification"]];
                [notificationDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"foreground"];
                [self sendSuccessResultWithType:@"notification" andDictionary:notificationDictionary];
            } errorHandler:^(NSError *error) {
                NSLog(@"NotificarePlugin: error fetching notification: %@", error);
            }];
        }

        [self refreshBadge];

    } else {
        //Could not find any id so let's just log and fail
        NSLog(@"NotificarePlugin: notification object is not valid");
    }


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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (_handleNotification) {
        if ([userInfo objectForKey:@"id"]) {
            if ([userInfo objectForKey:@"aps"] && [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]) {

                [self refreshBadge];

                //Check if inbox is activated
                if ([[[[[[NotificarePushLib shared] applicationInfo] objectForKey:@"services"] objectForKey:@"inboxConfig"] objectForKey:@"useInbox"] boolValue]) {

                    // No use calling the shared inbox manager if inbox isn't enabled
                    if ([[NotificareInboxManager sharedManager] enabled]) {
                        [[NotificareInboxManager sharedManager] handleNotification:[userInfo objectForKey:@"id"] isOpened:NO];
                    }

                }

                // Check if notification has to go to JS or not
                if ([application applicationState] == UIApplicationStateBackground) {
                    NSLog(@"NotificarePlugin: received notification in background, logging receive");
                    [self logReceivedNotification:[userInfo objectForKey:@"id"]];
                    // Put in a receive queue so the receive event doesn't get logged twice
                    [_receiveQueue addObject:[userInfo objectForKey:@"id"]];
                    completionHandler(UIBackgroundFetchResultNewData);
                } else {
                    NSLog(@"NotificarePlugin: received notification, fetching and sending to JS");
                    if ([_receiveQueue containsObject:[userInfo objectForKey:@"id"]]) {
                        [_receiveQueue removeObject:[userInfo objectForKey:@"id"]];
                    } else {
                        // only log received event the first time
                        [self logReceivedNotification:[userInfo objectForKey:@"id"]];
                    }
                    [[NotificarePushLib shared] getNotification:[userInfo objectForKey:@"id"] completionHandler:^(NSDictionary *info) {
                        // Info is the full notification object in key "notification"
                        NSMutableDictionary *notification = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:@"notification"]];
                        if ([application applicationState] == UIApplicationStateActive) {
                            // Received while app was running
                            [notification setObject:[NSNumber numberWithBool:YES] forKey:@"foreground"];
                            [self sendSuccessResultWithType:@"notification" andDictionary:notification];
                            completionHandler(UIBackgroundFetchResultNewData);
                        } else {
                            // Clicked in notification center
                            if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
                                [notification setObject:[NSNumber numberWithBool:NO] forKey:@"foreground"];
                                [self sendSuccessResultWithType:@"notification" andDictionary:notification];
                            }
                            completionHandler(UIBackgroundFetchResultNewData);
                        }
                    } errorHandler:^(NSError *error) {
                        NSLog(@"NotificarePlugin: error fetching notification: %@", error);
                        completionHandler(UIBackgroundFetchResultFailed);
                    }];
                }
            } else {
                // System push, use normal handling
                [[NotificarePushLib shared] handleNotification:userInfo forApplication:application completionHandler:^(NSDictionary *info) {
                    completionHandler(UIBackgroundFetchResultNewData);
                } errorHandler:^(NSError *error) {
                    NSLog(@"NotificarePlugin: failed to handle notification: %@", error);
                    completionHandler(UIBackgroundFetchResultNoData);
                }];
            }
        } else {
            //Could not find any id so let's just log and fail
            NSLog(@"NotificarePlugin: notification object is not valid");
            completionHandler(UIBackgroundFetchResultFailed);
        }
    } else {
        // Standard SDK behaviour
        [[NotificarePushLib shared] handleNotification:userInfo forApplication:application completionHandler:^(NSDictionary *info) {
            completionHandler(UIBackgroundFetchResultNewData);
        } errorHandler:^(NSError *error) {
            NSLog(@"NotificarePlugin: failed to handle notification: %@", error);
            completionHandler(UIBackgroundFetchResultNoData);
        }];
    }
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completion {
    [[NotificarePushLib shared] handleAction:identifier forNotification:userInfo withData:nil completionHandler:^(NSDictionary *info) {
        completion();
    } errorHandler:^(NSError *error) {
        completion();
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    [[NotificarePushLib shared] handleOpenURL:url];
    return YES;
}


@end
