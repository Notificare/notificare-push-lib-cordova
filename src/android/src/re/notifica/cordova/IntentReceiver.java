package re.notifica.cordova;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.push.gcm.DefaultIntentReceiver;
import android.util.Log;

public class IntentReceiver extends DefaultIntentReceiver {

	private static final String TAG = IntentReceiver.class.getSimpleName();

	@Override
	public void onRegistrationFinished(final String deviceId) {
		Log.d(TAG, "Device registered to GCM");
		NotificarePlugin.shared().sendRegistration(deviceId);
	}

	@Override
	public void onUnregistrationFinished() {
		Log.d(TAG, "Device unregistered from GCM");
		Notificare.shared().unregisterDevice(new NotificareCallback<Boolean>() {
			
			@Override
			public void onSuccess(Boolean success) {
				Log.d(TAG, "Device unregistered from Notificare");
			}
			
			@Override
			public void onError(NotificareError error) {
				Log.e(TAG, "Error unregistering from Notificare", error);
			}
		});
	}

	@Override
	public void onRegistrationError(String errorId) {
		Log.d(TAG, "Device failed registration to GCM");
		NotificarePlugin.shared().sendRegistrationError(errorId);
	}
	
	
}
