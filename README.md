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
	* Minimal required Android SDK version to 9
	* Setup GCM in Notificare (and optionally Google Maps) as described in [Set up GCM](https://notificare.atlassian.net/wiki/display/notificare/1.+Set+up+GCM) and [Create an Android application](https://notificare.atlassian.net/wiki/display/notificare/2.+Create+an+Android+application)
* `iOS`
	* iOS 6 or 7. 
	* Manage certificates and API keys as explained in [Set up APNS](https://notificare.atlassian.net/wiki/display/notificare/1.+Set+up+APNS) and [Create an iOS application](https://notificare.atlassian.net/wiki/display/notificare/2.+Create+an+iOS+Application)

Setup notes for Android
-----------------------

To get Android to link to the Notificare SDK and the Google Play SDK, you will need to edit the project properties.
If you are using Eclipse as an IDE, the easiest way to do this is adding these 2 dependencies as linked projects in Eclipse, as described in "Before we start" in the [Android Developer documentation](https://notificare.atlassian.net/wiki/display/notificare/3.+Implementing+the+Android+library) 

Otherwise, you will need to edit the `project.properties` file yourself. It should eventually look something like this:

```
android.library.reference.1=CordovaLib
# Project target.
target=android-19
android.library.reference.2=../../../../android-sdks/extras/google/google_play_services/libproject/google-play-services_lib
android.library.reference.3=../../../notificare-push-lib-android/SDK
```

Where path references to Support Library, Google Play SDK and Notificare SDK are of course dependent on your local setup.

Since the Cordova plugin installer doesn't add all necessary changes to the AndroidManifest.xml, you have to add some settings manually in that file.
First of all, your application needs to be of class re.notifica.cordova.BaseApplication

```
<application 
   android:hardwareAccelerated="true" 
   android:icon="@drawable/icon" 
   android:label="@string/app_name" 
   android:name="re.notifica.cordova.BaseApplication">
```

Second, your application needs some settings for Google Play Services. Add the following somewhere inside the <application> element of your AndroidManifest.xml

```
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

Finally, if you want to keep track of user sessions in your app, have your main activity extend re.notifica.cordova.BaseActivity

```
import re.notifica.cordova.BaseActivity;

public class MyCordovaApp extends BaseActivity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        super.init();
        // Set by <content src="index.html" /> in config.xml
        super.loadUrl(Config.getStartUrl());
        //super.loadUrl("file:///android_asset/www/index.html");
    }
}
```

Basic Usage
-----------

### Initialization

An instance of the plugin is accessible in JavaScript as `Notificare`.

To enable push notifications in your Cordova app, you only need to do 2 things:

* call `Notificare.enableNotifications()` in your `deviceReady` listener
* listen for a `registration` event to be emitted from Notificare. This will give you a deviceId to be registered to the Notificare API with optional userId and userName that are specific for your user. 

#### Example

```javascript
onDeviceReady: function() {
	Notificare.enableNotifications();
	Notificare.on('registration', function(deviceId) {
		// Register the device on Notificare API
		Notificare.registerDevice(deviceId, 'testuser@notifica.re', 'Test User', function() {
			console.log('registered with Notificare');
		}, function(error) {
			console.log(error);
		});
	});
});
```

### Location updates & geofences

By enabling location updates, the Notificare plugin will automatically take care of updating the device's location and fetching nearby geofences.

Be careful to only enable location updates after the device is registered, this will make sure all updates are registered correctly.

#### Example

```javascript
onDeviceReady: function() {
	Notificare.enableNotifications();
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
