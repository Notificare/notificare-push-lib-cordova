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

Setup
-----

* `Android`
	* 

* `iOS`


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
