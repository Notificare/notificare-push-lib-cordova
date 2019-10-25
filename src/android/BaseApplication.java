package re.notifica.cordova;

import re.notifica.Notificare;
import android.app.Application;
import android.util.Log;

public class BaseApplication extends Application {

	@Override
	public void onCreate() {
		super.onCreate();
	    Notificare.shared().launch(this);
	    Notificare.shared().setIntentReceiver(IntentReceiver.class);
	}

}