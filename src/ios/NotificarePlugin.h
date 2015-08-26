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

#import <Cordova/CDV.h>
#import "NotificarePushLib.h"

@interface NotificarePlugin : CDVPlugin <UIApplicationDelegate, NotificarePushLibDelegate>

- (void)start:(CDVInvokedUrlCommand *)command;
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
- (void)logOpenNotification:(CDVInvokedUrlCommand *)command;
- (void)logCustomEvent:(CDVInvokedUrlCommand *)command;

@end
