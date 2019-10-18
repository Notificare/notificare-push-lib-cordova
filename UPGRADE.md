# Upgrade

## Upgrade from a pre-1.5.2 version

From version 1.5.2 and up, the Notificare plugin is available from the new Cordova Plugin NPM repository. This means we also changed the name to adhere to NPM naming conventions.

To upgrade, do the following:

- Save (the contents of) your *notifcareconfig.properties* and *Notificare.plist*
- Update to the latest platforms

```sh
$ cordova platform update ios
$ cordova platform update android
```

- Replace the plugin

```sh
$ cordova plugin remove re.notifica.cordova
$ cordova plugin add cordova-plugin-notificare-push
```

- Restore the contents of your *notifcareconfig.properties* and *Notificare.plist*
- If necessary, update your AndroidManifest to use the correct application class


## Upgrade to 1.2

Apps now need to call Notificare.start() and listen for the `ready` event before any calls can be made to any of the services. 
Previously, this was only needed for extra services. This means that where previously one could use:

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
    }
    
```

now this has to move into a `ready` event listener, and be acted by calling start(), like so:

```javascript

	onDeviceReady: function() {
		Notificare.on('ready', function(applicationInfo) {
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
    }

```



