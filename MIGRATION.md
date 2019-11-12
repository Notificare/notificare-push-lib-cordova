# Migration

If you are migrating from 1.x.x version of our plugin, there are several breaking changes that you will need to take into consideration. Some crucial steps required in version 1 were removed and replaced with a simplified new API that unifies integration of remote notifications, location services, user authentication, contextual content and analytics for iOS 9 and up and Android 4.4 and up.

Guides for setup and implementation can be found here:

### iOS:
https://docs.notifica.re/sdk/v2/cordova/ios/setup/

### Android:
https://docs.notifica.re/sdk/v2/cordova/android/setup/


## Device Registration

When you are migrating from older versions, you will notice that you no longer need to take action whenever a device token is registered, as device registration in SDK 2.0 is totally managed by Notificare. You can still register/unregister a device to/from a userID and userName and Notificare will always keep that information cached in the device. This will make sure that whenever a device token changes everything is correctly handled without the need for your app to handle it. 

It is also important to mention that the first time an app is launched we will assign a UUID token to the device before you even request to register for notifications. Basically with this new version, all the features of Notificare can still be used even if your app does not implement remote notifications. Obviously if you never request to register for notifications, users will never receive remote notifications, although messages will still be in the inbox (if implemented), tags can be registered, location services can be used and pretty much all features will work as expected.

Once you decide to register for notifications, those automatically assigned device tokens will be replaced by the APNS tokens assign to each device. 

Bottom line, for this version you should remove all the device registration delegates used in previous versions and optionally you can implement the new delegates which are merely informative. You can find more information about device registration here:

### iOS:
https://docs.notifica.re/sdk/v2/cordova/ios/implementation/register/ 

### Android:
https://docs.notifica.re/sdk/v2/cordova/android/implementation/register/

## Events
This new version also introduces breaking changes to almost all the events triggered by our plugin. Please review below all the events supported by our new version:

| Event | iOS | Android |
|-------|:---:|:-------:|
| ready | :white_check_mark: | :white_check_mark: |
| deviceRegistered | :white_check_mark: | :white_check_mark: |
| notificationSettingsChanged | :white_check_mark: | :x: |
| urlOpened | :white_check_mark: | :x: |
| launchUrlReceived | :white_check_mark: | :x: |
| inboxLoaded | :white_check_mark: | :white_check_mark: |
| badgeUpdated | :white_check_mark: | :white_check_mark: |
| remoteNotificationReceivedInBackground | :white_check_mark: | :x: |
| remoteNotificationReceivedInForeground | :white_check_mark: | :white_check_mark: |
| systemNotificationReceivedInBackground | :white_check_mark: | :x: |
| systemNotificationReceivedInForeground | :white_check_mark: | :x: |
| unknownNotificationReceived | :white_check_mark: | :x: |
| unknownActionForNotificationReceived | :white_check_mark: | :x: |
| notificationWillOpen | :white_check_mark: | :x: |
| notificationOpened | :white_check_mark: | :white_check_mark: |
| notificationClosed | :white_check_mark: | :x: |
| notificationFailedToOpen | :white_check_mark: | :x: |
| urlClickedInNotification | :white_check_mark: | :white_check_mark: |
| actionWillExecute | :white_check_mark: | :x: |
| actionExecuted | :white_check_mark: | :x: |
| shouldPerformSelectorWithUrl | :white_check_mark: | :x: |
| actionNotExecuted | :white_check_mark: | :x: |
| actionFailedToExecute | :white_check_mark: | :x: |
| shouldOpenSettings | :white_check_mark: | :x: |
| locationServiceFailedToStart | :white_check_mark: | :x: |
| locationServiceAuthorizationStatusReceived | :white_check_mark: | :x: |
| locationsUpdated | :white_check_mark: | :x: |
| monitoringForRegionFailed | :white_check_mark: | :x: |
| monitoringForRegionStarted | :white_check_mark: | :x: |
| stateForRegionChanged | :white_check_mark: | :x: |
| regionEntered | :white_check_mark: | :x: |
| regionExited | :white_check_mark: | :x: |
| rangingBeaconsFailed | :white_check_mark: | :x: |
| beaconsInRangeForRegion | :white_check_mark: | :white_check_mark: |
| headingUpdated | :white_check_mark: | :x: |
| visitReceived | :white_check_mark: | :x: |
| accountStateChanged | :white_check_mark: | :x: |
| accountSessionFailedToRenewWithError | :white_check_mark: | :x: |
| activationTokenReceived | :white_check_mark: | :x: |
| resetPasswordTokenReceived | :white_check_mark: | :x: |
| storeLoaded | :white_check_mark: | :white_check_mark: |
| storeFailedToLoad | :white_check_mark: | :white_check_mark: |
| productTransactionCompleted | :white_check_mark: | :white_check_mark: |
| productTransactionRestored | :white_check_mark: | :x: |
| productTransactionFailed | :white_check_mark: | :white_check_mark: |
| productContentDownloadStarted | :white_check_mark: | :x: |
| productContentDownloadPaused | :white_check_mark: | :x: |
| productContentDownloadCancelled | :white_check_mark: | :x: |
| productContentDownloadProgress | :white_check_mark: | :x: |
| productContentDownloadFailed | :white_check_mark: | :x: |
| productContentDownloadFinished | :white_check_mark: | :x: |
| qrCodeScannerStarted | :white_check_mark: | :x: |
| scannableSessionInvalidatedWithError | :white_check_mark: | :white_check_mark: |
| scannableDetected | :white_check_mark: | :white_check_mark: |

