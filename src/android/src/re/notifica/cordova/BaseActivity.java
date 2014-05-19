package re.notifica.cordova;

import org.apache.cordova.CordovaActivity;

import re.notifica.Notificare;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

/**
 * A base class for Activities in an app that uses Notificare Cordova Plugin
 * @author Joris Verbogt <joris@notifica.re>
 * 
 * <p>This Activity class takes care of:</p>
 * <ul>
 * <li>Logging activity create / destroy as events in API</li>
 * <li>Handle recoverable errors from Notificare, e.g. Google Play Services errors</li>
 * </ul>
 */
public class BaseActivity extends CordovaActivity {

	private static final String TAG = BaseActivity.class.getSimpleName();

	@Override
	public void onCreate(Bundle savedInstanceState) {
		Log.d(TAG, "activity created with intent action " + getIntent().getAction() + " and data " + getIntent().getDataString());
		super.onCreate(savedInstanceState);
		Notificare.shared().setForeground(true);
		Notificare.shared().getEventLogger().logCreateActivity();
		if (Notificare.shared().getStatus() != Notificare.STATUS_OK) {
			if (Notificare.isUserRecoverableError(Notificare.shared().getErrorCode())) {
	            Notificare.getErrorDialog(Notificare.shared().getErrorCode(), this, Notificare.shared().getRequestCode()).show();
	        } else {
	            Log.i(TAG, "This device is not supported.");
	            finish();
	        }
		}
	}

	@Override
	public void onDestroy() {
		Log.d(TAG, "activity destroyed");
		super.onDestroy();
		Notificare.shared().setForeground(false);
		Notificare.shared().getEventLogger().logDestroyActivity();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Notificare.shared().handleServiceErrorResolution(requestCode, resultCode, data);
	}
	
	

}
