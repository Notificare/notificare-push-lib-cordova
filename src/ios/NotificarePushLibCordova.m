#import <Cordova/CDV.h>
#import "NotificarePushLib.h"
#import "NotificarePushLibCordovaUtils.h"
#import "UIImage+FromBundle.h"

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
    [self handleSendPluginResultSuccess:command];
}

- (void)registerForNotifications:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] registerForNotifications];
    [self handleSendPluginResultSuccess:command];
}

- (void)unregisterForNotifications:(CDVInvokedUrlCommand*)command {
    [[NotificarePushLib shared] unregisterForNotifications];
    [self handleSendPluginResultSuccess:command];
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

- (void)notificarePushLib:(NotificarePushLib *)library didChangeAccountState:(NSDictionary *)info{
    [self handleEvents:@{@"type": @"accountStateChanged", @"data": info}];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToRenewAccountSessionWithError:(NSError * _Nullable)error{
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    [self handleEvents:@{@"type": @"accountSessionFailedToRenewWithError", @"data": payload}];
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
        [[controller class] isEqual:[NSObject class]] ||
        controller == nil) {
        result = NO;
    }
    return result;
}

-(void)handleSendPluginResultSuccess:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:YES];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)handleSendPluginResultError:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [pluginResult setKeepCallbackAsBool:YES];
    [[self commandDelegate] sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end
