## 2.5.3
- Prevent crash on mapping inbox items without a notification
- Update native Android dependency
- Update native iOS dependency

## 2.5.2
* Prevent crash on inbox updates after un-launching

## 2.5.1
* Add `extra` to assets
* Allow nullable asset URLs

## 2.5.0
* Update native Android SDK to 2.5.0
* Update native iOS SDK to 2.5.0
* Add beacon scanning foreground service
* Add iOS 14 presentation options

## 2.4.0-beta.2
* Add `targetContentIdentifier` to `NotificareNotification`
* Update native iOS SDK to v2.4.0-beta.7

## 2.4.0-beta.1
* Fix `buyProduct` & `updatePreferredLanguage` invocations
- Update native SDKs to v2.4.0-beta
- Refactor Billing Manager integration
- Add `unknownNotificationReceivedInBackground` and `unknownNotificationReceivedInForeground` events on iOS
- Add `markAllAsRead` method
- Add `accuracy` to `NotificareDevice`
- Add support for Dynamic Links
- Add 'ephemeral' authorization status
- Add `requestAlwaysAuthorizationForLocationUpdates` and `requestTemporaryFullAccuracyAuthorization` methods
- Add `fetchLink` helper method

## 2.3.1
* Add `urlOpened` event to Android

## 2.3.0
* Fix `sendPassword` & `presentScannable` invocations
* Fix user preference parsing
* Add `accessToken` to the account details
* Fix `TimeOfDayRange` parsing
* Fix `updateDoNotDisturb` invocation
* Fix `doCloudHostOperation` nullable params handling
* Update to Android SDK 2.3.0
* Update to iOS SDK 2.3.2
* Allow `carPlay` in authorization options

## 2.2.7
* Updated to Android SDK 2.2.3

## 2.2.6
* Updated to Android SDK 2.2.2

## 2.2.5
* check partially fetched notifications when fetching inbox items 

## 2.2.4
* updated to iOS SDK 2.2.6

## 2.2.3
* optionally include googleServices gradle plugin

## 2.2.2
* fixed issue with fetchNotificationForInboxItem
* added fetchNotification in Android plugin

## 2.2.1
* updated to iOS SDK 2.2.4
* changes in isViewController helper method

## 2.2.0
* updated to Android SDK 2.2.1
* updated to iOS SDK 2.2.3
