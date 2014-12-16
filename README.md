Notificare Push Notification Plugin for Cordova
====================================

Rich and interactive push notifications for iOS, Android and Web. Enhance your apps with location based messages that really work.

Installation
------------

To install the plugin to your Cordova project use the Cordova CLI Tool:
	
	$ cordova plugin add re.notifica.cordova

Requirements
------------

* `Android`
	* Minimal required Android SDK version is 10 (Gingerbread / 2.3.x)
	* Setup GCM in Notificare (and optionally Google Maps) as described in [Set up GCM](https://notificare.atlassian.net/wiki/display/notificare/1.+Set+up+GCM) and [Create an Android application](https://notificare.atlassian.net/wiki/display/notificare/2.+Create+an+Android+application)
* `iOS`
	* iOS 6+. 
	* Manage certificates and API keys as explained in [Set up APNS](https://notificare.atlassian.net/wiki/display/notificare/1.+Set+up+APNS) and [Create an iOS application](https://notificare.atlassian.net/wiki/display/notificare/2.+Create+an+iOS+Application)

Setup notes for Android
-----------------------

To get Android to link to the Notificare SDK and the Google Play SDK, you will need to edit the project properties.
If you are using Eclipse as an IDE, the easiest way to do this is adding these 2 dependencies as linked projects in Eclipse, as described in "Before we start" in the [Android Developer documentation](https://notificare.atlassian.net/wiki/display/notificare/3.+Implementing+the+Android+library) 

Otherwise, you will need to edit the `project.properties` file yourself. It should eventually look something like this:

```
android.library.reference.1=CordovaLib
# Project target.
target=android-21
android.library.reference.2=../../../../android-sdks/extras/google/google_play_services/libproject/google-play-services_lib
android.library.reference.3=../../../../android-sdks/extras/android/support/v7/appcompat
android.library.reference.4=../../../notificare-push-lib-android/SDK
```

Where path references to Support Library, Google Play SDK and Notificare SDK are of course dependent on your local setup.

Since the Cordova plugin installer doesn't add all necessary changes to the AndroidManifest.xml, you might have to add some settings manually in that file.
In any case, your application needs to be of class re.notifica.cordova.BaseApplication

```
<application 
   android:hardwareAccelerated="true" 
   android:icon="@drawable/icon" 
   android:label="@string/app_name" 
   android:name="re.notifica.cordova.BaseApplication">
```

If you want to keep track of user sessions in your app, have your activities extend re.notifica.cordova.BaseActivity. This is only necessary for
your non-Cordova activities. The Cordova plugin will do the logging for you in the Cordova activity.

```
import re.notifica.cordova.BaseActivity;

public class MyNonCordovaActivity extends BaseActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
}
```

Configure plugin
----------------

### iOS

Edit the Notificare.plist and enter your keys from the Notificare Dashboard

### Android

Edit assets/notificareconfig.properties and enter your keys from the Notificare Dashboard plus the SenderId from your Google API Console


Basic Usage
-----------

### Initialization

An instance of the plugin is accessible in JavaScript as `Notificare`.

To enable push notifications in your Cordova app, you only need to do 2 things in your `deviceReady` listener:

* listen for a `ready` event to be emitted from Notificare, then call `Notificare.enableNotifications()`.
* listen for a `registration` event to be emitted from Notificare. This will give you a deviceId to be registered to the Notificare API with optional userId and userName that are specific for your user. 

#### Example

```javascript
onDeviceReady: function() {

	Notificare.on('ready', function(applicationInfo) {
		console.log(JSON.stringify(applicationInfo));
		Notificare.enableNotifications();
	});
	Notificare.on('registration', function(deviceId) {
		// Register the device on Notificare API
		Notificare.registerDevice(deviceId, 'testuser@notifica.re', 'Test User', function() {
			console.log('registered with Notificare');
		}, function(error) {
			console.log(error);
		});
	});
	Notificare.start();
});
```

### Location updates & geofences

By enabling location updates, the Notificare plugin will automatically take care of updating the device's location and fetching nearby geofences.

Be careful to only enable location updates after the device is registered, this will make sure all updates are registered correctly.

#### Example

```javascript
onDeviceReady: function() {
	Notificare.on('ready', function(applicationInfo) {
		console.log(JSON.stringify(applicationInfo));
		Notificare.enableNotifications();
	});
	Notificare.on('registration', function(deviceId) {
		// Register the device on Notificare API
		Notificare.registerDevice(deviceId, 'testuser@notifica.re', 'Test User', function() {
			console.log('registered with Notificare');
			Notificare.enableLocationUpdates();
		}, function(error) {
			console.log(error);
		});
	});
});
```

### Tags

You can add, remove and clean tags for the device from within your Javascript code. Again, make sure you registered the device first before you call any of these methods.

#### Examples

```javascript
Notificare.addDeviceTags(['tag1','tag2'], function() {
	console.log('added tags');
}, function(error) {
	console.log(error);
});
```

```javascript
Notificare.removeDeviceTag('tag2', function() {
	console.log('removed tag');
}, function(error) {
	console.log(error);
});
```

```javascript
Notificare.clearDeviceTags(function() {
	console.log('cleared all tags');
}, function(error) {
	console.log(error);
});
```

```javascript
Notificare.fetchDeviceTags(function(tags) {
	console.log('tags registered for this device: ' + tags);
}, function(error) {
	console.log(error);
});
```

### Disabling

Both locationUpdates and notifications can be disabled by calling `disableLocationUpdates()` and `disableLocationUpdates()`

Handling Notifications yourself
-----------

### Android

In Android, simply add an intent filter to your (Cordova) Activity in the AndroidManifest.

```xml
   <activity android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale" android:label="@string/app_name" android:launchMode="singleTop" android:name="MyCordovaActivity" android:theme="@android:style/Theme.Black.NoTitleBar">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
        <!--
        	This activity will receive notification opened intents
        -->
        <intent-filter>
            <action android:name="re.notifica.intent.action.NotificationOpened" />
            <category android:name="android.intent.category.DEFAULT" />
        </intent-filter>
    </activity>
```

### iOS

In iOS, you only need to tell the plugin to handle notifications by calling Notificare.setHandleNotification(true) in JS. See below.

### JS

In your device ready logic, tell the plugin to handle incoming notifications, then add an event listener for incoming notifications

```javascript
onDeviceReady: function() {
	Notificare.setHandleNotification(true);
	Notificare.on('ready', function(applicationInfo) {
		Notificare.enableNotifications();
	});
	Notificare.on('registration', function(deviceId) {
	
		// ...

	});

	Notificare.on('notification', function(notification) {
		if (someCondition) {
			// Here you should show notification in your view, or ignore it
			// In iOS, don't use any blocking calls like window.alert()
		}
	});
});
```




Customizations
--------------

For more info on customizing the default behavior and looks of the Notificare UI, take a look at the platforms' respective docs:

[4. iOS - Settings & Customizations](https://notificare.atlassian.net/wiki/pages/viewpage.action?pageId=2228230) 

[4. Android Costumizations](https://notificare.atlassian.net/wiki/display/notificare/4.+Android+Costumizations)

