#import <Cordova/CDV.h>
#import "NotificarePushLib.h"
#import "NotificarePushLibCordovaUtils.h"
#import "UIImage+FromBundle.h"
#import "NotificareNone.h"
#import "NotificareURLScheme.h"

@interface NotificarePushLibCordova : CDVPlugin <NotificarePushLibDelegate> {
  // Member variables go here.
}

@property (copy, nonatomic) NSString *mainCallbackId;
@property (strong, nonatomic) NSMutableArray *eventQueue;

- (void)launch:(CDVInvokedUrlCommand*)command;

@end

@implementation NotificarePushLibCordova

- (void)pluginInitialize {
    [self setEventQueue:[NSMutableArray new]];
    [[NotificarePushLib shared] initializeWithKey:nil andSecret:nil];
    [[NotificarePushLib shared] setDelegate:self];
}

#pragma Plugin Methods
- (void)launch:(CDVInvokedUrlCommand*)command {
    [self setMainCallbackId:[command callbackId]];
    [[NotificarePushLib shared] launch];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

- (void)unlaunch:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] unlaunch];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)setAuthorizationOptions:(CDVInvokedUrlCommand*)command {

    NSArray *options = [command argumentAtIndex:0];

    if (@available(iOS 10.0, *)) {
        UNAuthorizationOptions authorizationOptions = UNAuthorizationOptionNone;

        for (NSString * option in options) {
            if ([option isEqualToString:@"alert"]) {
                authorizationOptions = authorizationOptions + UNAuthorizationOptionAlert;
            }
            if ([option isEqualToString:@"badge"]) {
                authorizationOptions = authorizationOptions + UNAuthorizationOptionBadge;
            }
            if ([option isEqualToString:@"sound"]) {
                authorizationOptions = authorizationOptions + UNAuthorizationOptionSound;
            }
            if ([option isEqualToString:@"carPlay"]) {
                authorizationOptions = authorizationOptions + UNAuthorizationOptionCarPlay;
            }
            if (@available(iOS 12.0, *)) {
                if ([option isEqualToString:@"providesAppNotificationSettings"]) {
                    authorizationOptions = authorizationOptions + UNAuthorizationOptionProvidesAppNotificationSettings;
                }
                if ([option isEqualToString:@"provisional"]) {
                    authorizationOptions = authorizationOptions + UNAuthorizationOptionProvisional;
                }
                if ([option isEqualToString:@"criticalAlert"]) {
                    authorizationOptions = authorizationOptions + UNAuthorizationOptionCriticalAlert;
                }
            }
            if (@available(iOS 13.0, *)) {
                if ([option isEqualToString:@"announcement"]) {
                    authorizationOptions = authorizationOptions + UNAuthorizationOptionAnnouncement;
                }
            }
        }

        if (authorizationOptions) {
            [[NotificarePushLib shared] setAuthorizationOptions:authorizationOptions];
        }
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)setPresentationOptions:(CDVInvokedUrlCommand*)command {

    NSArray *options = [command argumentAtIndex:0];

    if (@available(iOS 10.0, *)) {
        UNNotificationPresentationOptions presentationOptions = UNNotificationPresentationOptionNone;

        for (NSString * option in options) {
            if ([option isEqualToString:@"alert"]) {
                presentationOptions = presentationOptions + UNNotificationPresentationOptionAlert;
            }
            if ([option isEqualToString:@"badge"]) {
                presentationOptions = presentationOptions + UNNotificationPresentationOptionBadge;
            }
            if ([option isEqualToString:@"sound"]) {
                presentationOptions = presentationOptions + UNNotificationPresentationOptionSound;
            }
        }

        if (presentationOptions) {
            [[NotificarePushLib shared] setPresentationOptions:presentationOptions];
        }
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}


-(void)setCategoryOptions:(CDVInvokedUrlCommand*)command {

    NSArray *options = [command argumentAtIndex:0];

    if (@available(iOS 10.0, *)) {
        UNNotificationCategoryOptions categoryOptions = UNNotificationCategoryOptionNone;

        for (NSString * option in options) {
            if ([option isEqualToString:@"customDismissAction"]) {
                categoryOptions = categoryOptions + UNNotificationCategoryOptionCustomDismissAction;
            }
            if ([option isEqualToString:@"allowInCarPlay"]) {
                categoryOptions = categoryOptions + UNNotificationCategoryOptionAllowInCarPlay;
            }
            if (@available(iOS 11.0, *)) {
                if ([option isEqualToString:@"hiddenPreviewsShowTitle"]) {
                    categoryOptions = categoryOptions + UNNotificationCategoryOptionHiddenPreviewsShowTitle;
                }
                if ([option isEqualToString:@"hiddenPreviewsShowSubtitle"]) {
                    categoryOptions = categoryOptions + UNNotificationCategoryOptionHiddenPreviewsShowSubtitle;
                }
            }
            if (@available(iOS 13.0, *)) {
                if ([option isEqualToString:@"allowAnnouncement"]) {
                    categoryOptions = categoryOptions + UNNotificationCategoryOptionAllowAnnouncement;
                }
            }
        }

        if (categoryOptions) {
            [[NotificarePushLib shared] setCategoryOptions:categoryOptions];
        }
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

- (void)registerForNotifications:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] registerForNotifications];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

- (void)unregisterForNotifications:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] unregisterForNotifications];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)isRemoteNotificationsEnabled:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[[NotificarePushLib shared] remoteNotificationsEnabled]];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)isAllowedUIEnabled:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[[NotificarePushLib shared] allowedUIEnabled]];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)isNotificationFromNotificare:(CDVInvokedUrlCommand*)command {
    NSDictionary *notification = [command argumentAtIndex:0];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[[NotificarePushLib shared] isNotificationFromNotificare:notification]];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)fetchNotificationSettings:(CDVInvokedUrlCommand*)command {
    if (@available(iOS 10.0, *)) {
         [[[NotificarePushLib shared] userNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromNotificationSettings:settings]];
             [self handleCallback:pluginResult withCommand:command];
         }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self handleCallback:pluginResult withCommand:command];
    }
}

-(void)startLocationUpdates:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] startLocationUpdates];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)stopLocationUpdates:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] stopLocationUpdates];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)clearLocation:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] clearDeviceLocation:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)isLocationServicesEnabled:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[[NotificarePushLib shared] locationServicesEnabled]];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)enableBeacons:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)disableBeacons:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)registerDevice:(CDVInvokedUrlCommand*)command {
    NSString *userID = ([command argumentAtIndex:0]) ? [command argumentAtIndex:0] : nil;
    NSString *userName = ([command argumentAtIndex:1]) ?  [command argumentAtIndex:1] : nil;

    [[NotificarePushLib shared] registerDevice:userID withUsername:userName completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromDevice:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchDevice:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromDevice:[[NotificarePushLib shared] myDevice]]];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)fetchPreferredLanguage:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NotificarePushLib shared] preferredLanguage]];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)updatePreferredLanguage:(CDVInvokedUrlCommand*)command {
    NSString *preferredLanguage = ([command argumentAtIndex:0]) ? [command argumentAtIndex:0] : nil;
    [[NotificarePushLib shared] updatePreferredLanguage:preferredLanguage completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchTags:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] fetchTags:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:response];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)addTag:(CDVInvokedUrlCommand*)command {
    NSString *tag = [command argumentAtIndex:0];
     [[NotificarePushLib shared] addTag:tag completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
         if (!error) {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
             [self handleCallback:pluginResult withCommand:command];
         } else {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
             [self handleCallback:pluginResult withCommand:command];
         }
     }];
}


-(void)addTags:(CDVInvokedUrlCommand*)command {
    NSArray *tags = [command argumentAtIndex:0];
     [[NotificarePushLib shared] addTags:tags completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
         if (!error) {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
             [self handleCallback:pluginResult withCommand:command];
         } else {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
             [self handleCallback:pluginResult withCommand:command];
         }
     }];
}

-(void)removeTag:(CDVInvokedUrlCommand*)command {
    NSString *tag = [command argumentAtIndex:0];
     [[NotificarePushLib shared] removeTag:tag completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
         if (!error) {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
             [self handleCallback:pluginResult withCommand:command];
         } else {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
             [self handleCallback:pluginResult withCommand:command];
         }
     }];
}

-(void)removeTags:(CDVInvokedUrlCommand*)command {
    NSArray *tags = [command argumentAtIndex:0];
     [[NotificarePushLib shared] removeTags:tags completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
         if (!error) {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
             [self handleCallback:pluginResult withCommand:command];
         } else {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
             [self handleCallback:pluginResult withCommand:command];
         }
     }];
}

-(void)clearTags:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] clearTags:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchUserData:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] fetchUserData:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareUserData * userData in response) {
                [payload addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromUserData:userData]];
            }
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:payload];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)updateUserData:(CDVInvokedUrlCommand*)command {
    NSArray *userData = [command argumentAtIndex:0];
    NSMutableArray * data = [NSMutableArray array];
    for (NSDictionary * field in userData) {
        [data addObject:[[NotificarePushLibCordovaUtils shared] userDataFromDictionary:field]];
    }
    [[NotificarePushLib shared] updateUserData:data completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareUserData * userData in response) {
                [payload addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromUserData:userData]];
            }
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:payload];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchDoNotDisturb:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] fetchDoNotDisturb:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromDeviceDnD:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)updateDoNotDisturb:(CDVInvokedUrlCommand*)command {
    NSDictionary *deviceDnD = [command argumentAtIndex:0];
    [[NotificarePushLib shared] updateDoNotDisturb:[[NotificarePushLibCordovaUtils shared] deviceDnDFromDictionary:deviceDnD] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromDeviceDnD:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)clearDoNotDisturb:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] clearDoNotDisturb:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchNotification:(CDVInvokedUrlCommand*)command {
    NSDictionary *notification = [command argumentAtIndex:0];
    [[NotificarePushLib shared] fetchNotification:notification completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchNotificationForInboxItem:(CDVInvokedUrlCommand*)command {
    NSDictionary *inboxItem = [command argumentAtIndex:0];
    [[NotificarePushLib shared] fetchNotification:[inboxItem objectForKey:@"inboxId"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)presentNotification:(CDVInvokedUrlCommand*)command {
    NSDictionary *notification = [command argumentAtIndex:0];
    NotificareNotification * item = [[NotificarePushLibCordovaUtils shared] notificationFromDictionary:notification];
    id controller = [[NotificarePushLib shared] controllerForNotification:item];
    if ([self isViewController:controller]) {
        UINavigationController *navController = [self navigationControllerForViewControllers:controller];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navController animated:NO completion:^{
            [[NotificarePushLib shared] presentNotification:item inNavigationController:navController withController:controller];
        }];
    } else {
        [[NotificarePushLib shared] presentNotification:item inNavigationController:[self navigationControllerForRootViewController] withController:controller];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)fetchInbox:(CDVInvokedUrlCommand*)command {
    [[[NotificarePushLib shared] inboxManager] fetchInbox:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareDeviceInbox * inboxItem in response) {
                [payload addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromDeviceInbox:inboxItem]];
            }
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:payload];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)presentInboxItem:(CDVInvokedUrlCommand*)command {
    NSDictionary *inboxItem = [command argumentAtIndex:0];
     NotificareDeviceInbox * item = [[NotificarePushLibCordovaUtils shared] deviceInboxFromDictionary:inboxItem];
     [[[NotificarePushLib shared] inboxManager] openInboxItem:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
         if (!error) {
             if ([self isViewController:response]) {
                 UINavigationController *navController = [self navigationControllerForViewControllers:response];
                 [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navController animated:NO completion:^{
                     [[NotificarePushLib shared] presentInboxItem:item inNavigationController:navController withController:response];
                 }];
             } else {
                 [[NotificarePushLib shared] presentInboxItem:item inNavigationController:[self navigationControllerForRootViewController] withController:response];
             }
         }
     }];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)removeFromInbox:(CDVInvokedUrlCommand*)command {
    NSDictionary *inboxItem = [command argumentAtIndex:0];
    [[[NotificarePushLib shared] inboxManager] removeFromInbox:[[NotificarePushLibCordovaUtils shared] deviceInboxFromDictionary:inboxItem] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromDeviceInbox:response]];
          [self handleCallback:pluginResult withCommand:command];
        } else {
          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
          [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)markAsRead:(CDVInvokedUrlCommand*)command {
    NSDictionary *inboxItem = [command argumentAtIndex:0];
    [[[NotificarePushLib shared] inboxManager] markAsRead:[[NotificarePushLibCordovaUtils shared] deviceInboxFromDictionary:inboxItem] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromDeviceInbox:response]];
          [self handleCallback:pluginResult withCommand:command];
        } else {
          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
          [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)markAllAsRead:(CDVInvokedUrlCommand*)command {
    [[[NotificarePushLib shared] inboxManager] markAllAsRead:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
          [self handleCallback:pluginResult withCommand:command];
        } else {
          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
          [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)clearInbox:(CDVInvokedUrlCommand*)command {
    [[[NotificarePushLib shared] inboxManager] clearInbox:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
          [self handleCallback:pluginResult withCommand:command];
        } else {
          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
          [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchAssets:(CDVInvokedUrlCommand*)command {
    NSString *group = [command argumentAtIndex:0];
    [[NotificarePushLib shared] fetchAssets:group completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareAsset * asset in response) {
                [payload addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromAsset:asset]];
            }
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:payload];
            [self handleCallback:pluginResult withCommand:command];
        } else {
          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
          [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchPassWithSerial:(CDVInvokedUrlCommand*)command {
    NSString *serial = [command argumentAtIndex:0];
    [[NotificarePushLib shared] fetchPassWithSerial:serial completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromPass:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchPassWithBarcode:(CDVInvokedUrlCommand*)command {
    NSString *barcode = [command argumentAtIndex:0];
    [[NotificarePushLib shared] fetchPassWithBarcode:barcode completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromPass:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchProducts:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] fetchProducts:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareProduct * product in response) {
                [payload addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:product]];
            }
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:payload];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchPurchasedProducts:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] fetchPurchasedProducts:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareProduct * product in response) {
                [payload addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:product]];
            }
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:payload];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchProduct:(CDVInvokedUrlCommand*)command {
    NSDictionary *product = [command argumentAtIndex:0];
    [[NotificarePushLib shared] fetchProduct:[product objectForKey:@"productIdentifier"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)buyProduct:(CDVInvokedUrlCommand*)command {
    NSDictionary *product = [command argumentAtIndex:0];
    [[NotificarePushLib shared] fetchProduct:[product objectForKey:@"productIdentifier"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [[NotificarePushLib shared] buyProduct:response];
        }
    }];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)enableBilling:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)disableBilling:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)logCustomEvent:(CDVInvokedUrlCommand*)command {
    NSString *name = [command argumentAtIndex:0];
    NSDictionary *data = ([command argumentAtIndex:0]) ? [command argumentAtIndex:0] : nil;
    [[NotificarePushLib shared] logCustomEvent:name withData:data completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)logOpenNotification:(CDVInvokedUrlCommand*)command {
    NSDictionary *notification = [command argumentAtIndex:0];
    NSMutableDictionary * eventData = [NSMutableDictionary dictionary];
    [eventData setObject:[notification objectForKey:@"id"] forKey:@"notification"];
    [[NotificarePushLib shared] logEvent:kNotificareEventNotificationOpen withData:eventData completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)logInfluencedNotification:(CDVInvokedUrlCommand*)command {
    NSDictionary *notification = [command argumentAtIndex:0];
    NSMutableDictionary * eventData = [NSMutableDictionary dictionary];
    [eventData setObject:[notification objectForKey:@"id"] forKey:@"notification"];
    [[NotificarePushLib shared] logEvent:kNotificareEventNotificationInfluenced withData:eventData completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)logReceiveNotification:(CDVInvokedUrlCommand*)command {
    NSDictionary *notification = [command argumentAtIndex:0];
    NSMutableDictionary * eventData = [NSMutableDictionary dictionary];
    [eventData setObject:[notification objectForKey:@"id"] forKey:@"notification"];
    [[NotificarePushLib shared] logEvent:kNotificareEventNotificationReceive withData:eventData completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)doCloudHostOperation:(CDVInvokedUrlCommand*)command {
    NSString *verb = [command argumentAtIndex:0];
    NSString *path = [command argumentAtIndex:1];
    NSDictionary *headers = ([command argumentAtIndex:2]) ? [command argumentAtIndex:2] : nil;
    NSDictionary *params = ([command argumentAtIndex:3]) ? [command argumentAtIndex:3] : nil;
    NSDictionary *body = ([command argumentAtIndex:4]) ? [command argumentAtIndex:4] : nil;
    [[NotificarePushLib shared] doCloudHostOperation:verb path:path URLParams:params customHeaders:headers bodyJSON:body completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)createAccount:(CDVInvokedUrlCommand*)command {
    NSString *email = [command argumentAtIndex:0];
    NSString *name = [command argumentAtIndex:1];
    NSString *password = [command argumentAtIndex:2];
    [[[NotificarePushLib shared] authManager] createAccount:email withName:name andPassword:password completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)validateAccount:(CDVInvokedUrlCommand*)command {
    NSString *token = [command argumentAtIndex:0];
    [[[NotificarePushLib shared] authManager] validateAccount:token completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)resetPassword:(CDVInvokedUrlCommand*)command {
    NSString *password = [command argumentAtIndex:0];
    NSString *token = [command argumentAtIndex:1];
    [[[NotificarePushLib shared] authManager] resetPassword:password withToken:token completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)sendPassword:(CDVInvokedUrlCommand*)command {
    NSString *email = [command argumentAtIndex:0];
    [[[NotificarePushLib shared] authManager] sendPassword:email completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)login:(CDVInvokedUrlCommand*)command {
    NSString *email = [command argumentAtIndex:0];
    NSString *password = [command argumentAtIndex:1];
    [[[NotificarePushLib shared] authManager] loginWithUsername:email andPassword:password completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)logout:(CDVInvokedUrlCommand*)command {
    [[[NotificarePushLib shared] authManager] logoutAccount:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)isLoggedIn:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[[[NotificarePushLib shared] authManager] isLoggedIn]];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)generateAccessToken:(CDVInvokedUrlCommand*)command {
    [[[NotificarePushLib shared] authManager] generateAccessToken:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromUser:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)changePassword:(CDVInvokedUrlCommand*)command {
    NSString *password = [command argumentAtIndex:0];
    [[[NotificarePushLib shared] authManager] changePassword:password completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromUser:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchAccountDetails:(CDVInvokedUrlCommand*)command {
    [[[NotificarePushLib shared] authManager] fetchAccountDetails:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[[NotificarePushLibCordovaUtils shared] dictionaryFromUser:response]];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)fetchUserPreferences:(CDVInvokedUrlCommand*)command {
    [[[NotificarePushLib shared] authManager] fetchUserPreferences:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray * payload = [NSMutableArray array];
            for (NotificareUserPreference * preference in response) {
                [payload addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromUserPreference:preference]];
            }
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:payload];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)addSegmentToUserPreference:(CDVInvokedUrlCommand*)command {
    NSDictionary *segment = [command argumentAtIndex:0];
    NSDictionary *userPreference = [command argumentAtIndex:1];
    [[[NotificarePushLib shared] authManager] addSegment:[[NotificarePushLibCordovaUtils shared] segmentFromDictionary:segment] toPreference:[[NotificarePushLibCordovaUtils shared] userPreferenceFromDictionary:userPreference] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)removeSegmentFromUserPreference:(CDVInvokedUrlCommand*)command {
    NSDictionary *segment = [command argumentAtIndex:0];
    NSDictionary *userPreference = [command argumentAtIndex:1];
    [[[NotificarePushLib shared] authManager] removeSegment:[[NotificarePushLibCordovaUtils shared] segmentFromDictionary:segment] fromPreference:[[NotificarePushLibCordovaUtils shared] userPreferenceFromDictionary:userPreference] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self handleCallback:pluginResult withCommand:command];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self handleCallback:pluginResult withCommand:command];
        }
    }];
}

-(void)startScannableSession:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] startScannableSessionWithQRCode:[self navigationControllerForRootViewController] asModal:YES];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)presentScannable:(CDVInvokedUrlCommand*)command {
    NSDictionary *scannable = [command argumentAtIndex:0];
    NotificareScannable * item = [[NotificarePushLibCordovaUtils shared] scannableFromDictionary:scannable];
    [[NotificarePushLib shared] openScannable:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if ([self isViewController:response]) {
                UINavigationController *navController = [self navigationControllerForViewControllers:response];
                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navController animated:NO completion:^{
                    [[NotificarePushLib shared] presentScannable:item inNavigationController:navController withController:response];
                }];
            } else {
                [[NotificarePushLib shared] presentScannable:item inNavigationController:[self navigationControllerForRootViewController] withController:response];
            }
        }
    }];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)requestAlwaysAuthorizationForLocationUpdates:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] requestAlwaysAuthorizationForLocationUpdates];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

-(void)requestTemporaryFullAccuracyAuthorization:(CDVInvokedUrlCommand*)command {
    if (@available(iOS 14.0, *)) {
        NSString *purposeKey = [command argumentAtIndex:0];
        [[NotificarePushLib shared] requestTemporaryFullAccuracyAuthorizationWithPurposeKey:purposeKey];
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self handleCallback:pluginResult withCommand:command];
}

#pragma Notificare Delegates
-(void)notificarePushLib:(NotificarePushLib *)library onReady:(NotificareApplication *)application{
    [self handleEvents:@{@"type": @"ready", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromApplication:application]}];
    [self handleQueue];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRegisterDevice:(nonnull NotificareDevice *)device{
    [self handleEvents:@{@"type": @"deviceRegistered", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromDevice:device]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didChangeNotificationSettings:(BOOL)granted{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[NSNumber numberWithBool:granted] forKey:@"granted"];
    [self handleEvents:@{@"type": @"notificationSettingsChanged", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLaunchURL:(NSURL *)launchURL{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[launchURL absoluteString] forKey:@"url"];
    [self handleEvents:@{@"type": @"launchUrlReceived", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveRemoteNotificationInBackground:(NotificareNotification *)notification withController:(id _Nullable)controller{
    [self handleEvents:@{@"type": @"remoteNotificationReceivedInBackground", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:notification]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveRemoteNotificationInForeground:(NotificareNotification *)notification withController:(id _Nullable)controller{
    [self handleEvents:@{@"type": @"remoteNotificationReceivedInForeground", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:notification]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemNotificationInBackground:(NotificareSystemNotification *)notification{
    [self handleEvents:@{@"type": @"systemNotificationReceivedInBackground", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromSystemNotification:notification]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemNotificationInForeground:(NotificareSystemNotification *)notification{
    [self handleEvents:@{@"type": @"systemNotificationReceivedInForeground", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromSystemNotification:notification]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownNotification:(NSDictionary *)notification{
    [self handleEvents:@{@"type": @"unknownNotificationReceived", @"data": notification}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownNotificationInBackground:(NSDictionary *)notification {
    [self handleEvents:@{@"type": @"unknownNotificationReceivedInBackground", @"data": notification}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownNotificationInForeground:(NSDictionary *)notification {
    [self handleEvents:@{@"type": @"unknownNotificationReceivedInForeground", @"data": notification}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveUnknownAction:(NSDictionary *)action forNotification:(NSDictionary *)notification{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:action forKey:@"action"];
    [payload setObject:notification forKey:@"notification"];
    [self handleEvents:@{@"type": @"unknownActionForNotificationReceived", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library willOpenNotification:(NotificareNotification *)notification{
    [self handleEvents:@{@"type": @"notificationWillOpen", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:notification]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didOpenNotification:(NotificareNotification *)notification{
    [self handleEvents:@{@"type": @"notificationOpened", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:notification]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCloseNotification:(NotificareNotification *)notification{
    [self handleEvents:@{@"type": @"notificationClosed", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:notification]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToOpenNotification:(NotificareNotification *)notification{
    [self handleEvents:@{@"type": @"notificationFailedToOpen", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:notification]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didClickURL:(NSURL *)url inNotification:(NotificareNotification *)notification{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:notification] forKey:@"notification"];
    [self handleEvents:@{@"type": @"urlClickedInNotification", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library willExecuteAction:(NotificareAction *)action{
    [self handleEvents:@{@"type": @"actionWillExecute", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromAction:action]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didExecuteAction:(NotificareAction *)action{
    [self handleEvents:@{@"type": @"actionExecuted", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromAction:action]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelectorWithURL:(NSURL *)url inAction:(NotificareAction *)action{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromAction:action] forKey:@"action"];
    [self handleEvents:@{@"type": @"shouldPerformSelectorWithUrl", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didNotExecuteAction:(NotificareAction *)action{
     [self handleEvents:@{@"type": @"actionNotExecuted", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromAction:action]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToExecuteAction:(NotificareAction *)action withError:(NSError *)error{
     [self handleEvents:@{@"type": @"actionFailedToExecute", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromAction:action]}];
}

/*
 * Uncomment this code to implement native PKPasses
 * Additionally you must import PassKit framework in the NotificareReactNativeIOS.h and implement PKAddPassesViewControllerDelegate in the PushHandler interface
 *
- (void)notificarePushLib:(NotificarePushLib *)library didReceivePass:(NSURL *)pass inNotification:(NotificareNotification*)notification{

     dispatch_async(dispatch_get_main_queue(), ^{
         NSData *data = [[NSData alloc] initWithContentsOfURL:pass];
         NSError *error;

         //init a pass object with the data
         PKPass * pkPass = [[PKPass alloc] initWithData:data error:&error];

         if(!error){
             //present view controller to add the pass to the library
             PKAddPassesViewController * vc = [[PKAddPassesViewController alloc] initWithPass:pkPass];
             [vc setDelegate:self];

             [[NotificarePushLib shared] presentWalletPass:notification inNavigationController:[self navigationControllerForRootViewController] withController:vc];
         }
     });

}
*/

- (void)notificarePushLib:(NotificarePushLib *)library shouldOpenSettings:(NotificareNotification* _Nullable)notification{
    [self handleEvents:@{@"type": @"shouldOpenSettings", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromNotification:notification]}];
}


- (void)notificarePushLib:(NotificarePushLib *)library didLoadInbox:(NSArray<NotificareDeviceInbox*>*)items{
    NSMutableArray * inboxItems = [NSMutableArray array];
    for (NotificareDeviceInbox * inboxItem in items) {
        [inboxItems addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromDeviceInbox:inboxItem]];
    }
    [self handleEvents:@{@"type": @"inboxLoaded", @"data": inboxItems}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{
    [self handleEvents:@{@"type": @"badgeUpdated", @"data":[NSNumber numberWithInt:badge]}];
}


- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [self handleEvents:@{@"type": @"locationServiceFailedToStart", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAuthorizationStatus:(NotificareGeoAuthorizationStatus)status{

    NSMutableDictionary * payload = [NSMutableDictionary new];

    if (status == NotificareGeoAuthorizationStatusDenied) {
        [payload setObject:@"denied" forKey:@"status"];
    } else if (status == NotificareGeoAuthorizationStatusRestricted) {
        [payload setObject:@"restricted" forKey:@"status"];
    } else if (status == NotificareGeoAuthorizationStatusNotDetermined) {
        [payload setObject:@"notDetermined" forKey:@"status"];
    } else if (status == NotificareGeoAuthorizationStatusAuthorizedAlways) {
        [payload setObject:@"always" forKey:@"status"];
    } else if (status == NotificareGeoAuthorizationStatusAuthorizedWhenInUse) {
        [payload setObject:@"whenInUse" forKey:@"status"];
    }

    [self handleEvents:@{@"type": @"locationServiceAuthorizationStatusReceived", @"data": payload}];

}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAccuracyAuthorization:(NotificareGeoAccuracyAuthorization)accuracy {
    NSMutableDictionary * payload = [NSMutableDictionary new];

    if (accuracy == NotificareGeoAccuracyAuthorizationFull) {
        [payload setObject:@"full" forKey:@"accuracy"];
    } else if (accuracy == NotificareGeoGeoAccuracyAuthorizationReduced) {
        [payload setObject:@"reduced" forKey:@"accuracy"];
    }

    [self handleEvents:@{@"type": @"locationServiceAccuracyAuthorizationReceived", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray<NotificareLocation*> *)locations{
    NSMutableArray * payload = [NSMutableArray new];
    for (NotificareLocation * location in locations) {
        [payload addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromLocation:location]];
    }
    [self handleEvents:@{@"type": @"locationsUpdated", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library monitoringDidFailForRegion:(id)region withError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [self handleEvents:@{@"type": @"monitoringForRegionFailed", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didStartMonitoringForRegion:(id)region{

    if([region isKindOfClass:[NotificareRegion class]]){
        [self handleEvents:@{@"type": @"monitoringForRegionStarted", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromRegion:region]}];
    }

    if([region isKindOfClass:[NotificareBeacon class]]){
        [self handleEvents:@{@"type": @"monitoringForRegionStarted", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromBeacon:region]}];
    }
}

- (void)notificarePushLib:(NotificarePushLib *)library didDetermineState:(NotificareRegionState)state forRegion:(id)region{

    NSMutableDictionary * payload = [NSMutableDictionary new];

    if (state == NotificareRegionStateInside) {
        [payload setObject:@"inside" forKey:@"state"];
    } else if (state == NotificareRegionStateOutside) {
        [payload setObject:@"outside" forKey:@"state"];
    } else if (state == NotificareRegionStateUnknown) {
        [payload setObject:@"unknown" forKey:@"state"];
    }

    if([region isKindOfClass:[NotificareRegion class]]){
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromRegion:region] forKey:@"region"];
    }

    if([region isKindOfClass:[NotificareBeacon class]]){
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromBeacon:region] forKey:@"region"];
    }

    [self handleEvents:@{@"type": @"stateForRegionChanged", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didEnterRegion:(id)region{

    if([region isKindOfClass:[NotificareRegion class]]){
        [self handleEvents:@{@"type": @"regionEntered", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromRegion:region]}];
    }

    if([region isKindOfClass:[NotificareBeacon class]]){
        [self handleEvents:@{@"type": @"regionEntered", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromBeacon:region]}];
    }
}

- (void)notificarePushLib:(NotificarePushLib *)library didExitRegion:(id)region{

    if([region isKindOfClass:[NotificareRegion class]]){
        [self handleEvents:@{@"type": @"regionExited", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromRegion:region]}];
    }

    if([region isKindOfClass:[NotificareBeacon class]]){
        [self handleEvents:@{@"type": @"regionExited", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromBeacon:region]}];
    }

}

- (void)notificarePushLib:(NotificarePushLib *)library rangingBeaconsDidFailForRegion:(NotificareBeacon *)region withError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromBeacon:region] forKey:@"region"];
    [self handleEvents:@{@"type": @"rangingBeaconsFailed", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray<NotificareBeacon *> *)beacons inRegion:(NotificareBeacon *)region{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    NSMutableArray * beaconsList = [NSMutableArray new];
    for (NotificareBeacon * beacon in beacons) {
        [beaconsList addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromBeacon:beacon]];
    }
    [payload setObject:beaconsList forKey:@"beacons"];
    [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromBeacon:region] forKey:@"region"];
    [self handleEvents:@{@"type": @"beaconsInRangeForRegion", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateHeading:(NotificareHeading*)heading{
    [self handleEvents:@{@"type": @"headingUpdated", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromHeading:heading]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didVisit:(NotificareVisit*)visit{
    [self handleEvents:@{@"type": @"visitReceived", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromVisit:visit]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveActivationToken:(NSString *)token{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:token forKey:@"token"];
    [self handleEvents:@{@"type": @"activationTokenReceived", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveResetPasswordToken:(NSString *)token{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:token forKey:@"token"];
    [self handleEvents:@{@"type": @"resetPasswordTokenReceived", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didLoadStore:(NSArray<NotificareProduct *> *)products{
    NSMutableArray * payload = [NSMutableArray array];
    for (NotificareProduct * product in products) {
        [payload addObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:product]];
    }
    [self handleEvents:@{@"type": @"storeLoaded", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToLoadStore:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [self handleEvents:@{@"type": @"storeFailedToLoad", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCompleteProductTransaction:(SKPaymentTransaction *)transaction{
    [[NotificarePushLib shared] fetchProduct:[[transaction payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        [self handleEvents:@{@"type": @"productTransactionCompleted", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response]}];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRestoreProductTransaction:(SKPaymentTransaction *)transaction{
    [[NotificarePushLib shared] fetchProduct:[[transaction payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        [self handleEvents:@{@"type": @"productTransactionRestored", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response]}];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailProductTransaction:(SKPaymentTransaction *)transaction withError:(NSError *)error{
    [[NotificarePushLib shared] fetchProduct:[[transaction payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[error localizedDescription] forKey:@"error"];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self handleEvents:@{@"type": @"productTransactionFailed", @"data": payload}];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didStartDownloadContent:(SKPaymentTransaction *)transaction{
    [[NotificarePushLib shared] fetchProduct:[[transaction payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        [self handleEvents:@{@"type": @"productContentDownloadStarted", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response]}];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didPauseDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromSKDownload:download] forKey:@"download"];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self handleEvents:@{@"type": @"productContentDownloadPaused", @"data": payload}];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCancelDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromSKDownload:download] forKey:@"download"];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self handleEvents:@{@"type": @"productContentDownloadCancelled", @"data": payload}];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveProgressDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromSKDownload:download] forKey:@"download"];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self handleEvents:@{@"type": @"productContentDownloadProgress", @"data": payload}];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromSKDownload:download] forKey:@"download"];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self handleEvents:@{@"type": @"productContentDownloadFailed", @"data": payload}];
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFinishDownloadContent:(SKDownload *)download{
    [[NotificarePushLib shared] fetchProduct:[[[download transaction] payment] productIdentifier] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * payload = [NSMutableDictionary new];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromSKDownload:download]forKey:@"download"];
        [payload setObject:[[NotificarePushLibCordovaUtils shared] dictionaryFromProduct:response] forKey:@"product"];
        [self handleEvents:@{@"type": @"productContentDownloadFinished", @"data": payload}];
    }];
}


- (void)notificarePushLib:(NotificarePushLib *)library didStartQRCodeScanner:(UIViewController*)scanner{
    [self handleEvents:@{@"type": @"qrCodeScannerStarted", @"data": [NSNull null]}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didInvalidateScannableSessionWithError:(NSError *)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [self handleEvents:@{@"type": @"scannableSessionInvalidatedWithError", @"data": payload}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didDetectScannable:(NotificareScannable *)scannable{
    [self handleEvents:@{@"type": @"scannableDetected", @"data": [[NotificarePushLibCordovaUtils shared] dictionaryFromScannable:scannable]}];
}

#pragma Helper Methods
-(void)handleEvents:(NSDictionary *)payload{

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
     [pluginResult setKeepCallbackAsBool:YES];

     if ([self mainCallbackId] != nil) {
         [[self commandDelegate] sendPluginResult:pluginResult callbackId:[self mainCallbackId]];
     } else {
         [[self eventQueue] addObject:pluginResult];
     }
}


-(void)handleQueue{
    if ([self eventQueue] && [[self eventQueue] count] > 0) {
        for (CDVPluginResult *pluginResult in [self eventQueue]) {
            [[self commandDelegate] sendPluginResult:pluginResult callbackId:[self mainCallbackId]];
        }
        [[self eventQueue] removeAllObjects];
    }
}

-(void)close{
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:^{

    }];
}

-(UINavigationController*)navigationControllerForViewControllers:(id)object{
    UINavigationController *navController = [UINavigationController new];
    [[(UIViewController *)object navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageFromBundle:@"closeIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(close)]];
    return navController;
}

-(UINavigationController*)navigationControllerForRootViewController{
    UINavigationController * navController = (UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    return navController;
}

-(BOOL)isViewController:(id)controller{
    BOOL result = YES;
    if ([[controller class] isEqual:[UIAlertController class]] ||
        [[controller class] isEqual:[SKStoreProductViewController class]] ||
        [[controller class] isEqual:[NotificareNone class]] ||
        [[controller class] isEqual:[NotificareURLScheme class]] ||
        controller == nil) {
        result = NO;
    }
    return result;
}

-(void)handleCallback:(CDVPluginResult*)result withCommand:(CDVInvokedUrlCommand*)command{
    [result setKeepCallbackAsBool:YES];
    [[self commandDelegate] sendPluginResult:result callbackId:command.callbackId];
}

@end
