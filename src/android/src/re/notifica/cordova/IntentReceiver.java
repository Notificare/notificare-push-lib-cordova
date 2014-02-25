package re.notifica.cordova;

import android.util.Log;
import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.push.gcm.DefaultIntentReceiver;

public class IntentReceiver extends DefaultIntentReceiver {

	private static final String TAG = IntentReceiver.class.getSimpleName();

	@Override
	public void onRegistrationFinished(final String deviceId) {
		Log.d(TAG, "Device registered to GCM");
        Notificare.shared().registerDevice(deviceId, new NotificareCallback<String>() {

			@Override
			public void onSuccess(String result) {
				Log.d(TAG, "Successfully registered");
				NotificarePlugin.shared().sendRegistration(deviceId);
			}

			@Override
			public void onError(NotificareError error) {
				Log.e(TAG, "Error registering device", error);
			}
        	
        });
	}

	@Override
	public void onUnregistrationFinished() {
		Log.d(TAG, "Device unregistered from GCM");
        Notificare.shared().unregisterDevice(new NotificareCallback<Boolean>() {

			@Override
			public void onSuccess(Boolean result) {
				Log.d(TAG, "Successfully unregistered");
			}

			@Override
			public void onError(NotificareError error) {
				Log.e(TAG, "Error unregistering device", error);
			}
        	
        });
	}
}
