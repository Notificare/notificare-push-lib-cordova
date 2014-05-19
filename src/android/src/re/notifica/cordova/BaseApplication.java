package re.notifica.cordova;

import re.notifica.Notificare;
import android.app.Application;
import android.util.Log;

public class BaseApplication extends Application {

	private static final String TAG = BaseApplication.class.getSimpleName();

	@Override
	public void onCreate() {
		Log.d(TAG, "Application created");
		super.onCreate();
		// Launch Notificare system
	    Notificare.shared().launch(this);
	    Notificare.shared().setIntentReceiver(IntentReceiver.class);
	}
	
}
