package re.notifica.cordova;

import re.notifica.push.gcm.DefaultIntentReceiver;
import android.util.Log;

public class IntentReceiver extends DefaultIntentReceiver {

	private static final String TAG = IntentReceiver.class.getSimpleName();
	
	@Override
	public void onReady() {
		Log.d(TAG, "Notificare ready");
	}

	@Override
	public void onRegistrationFinished(final String deviceId) {
		Log.d(TAG, "Device registered to GCM");
		NotificarePlugin.shared().sendRegistration(deviceId);
	}

	@Override
	public void onRegistrationError(String errorId) {
		Log.d(TAG, "Device failed registration to GCM");
		NotificarePlugin.shared().sendRegistrationError(errorId);
	}
	
	
}
