/*
 Copyright 2015 Notificare B.V.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
	public void onResume() {
		Log.d(TAG, "activity started");
		super.onResume();
		Notificare.shared().setForeground(true);
		Notificare.shared().getEventLogger().logStartSession();		
	}

	@Override
	public void onPause() {
		Log.d(TAG, "activity stopped");
		super.onPause();
		Notificare.shared().setForeground(false);
		Notificare.shared().getEventLogger().logEndSession();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Notificare.shared().handleServiceErrorResolution(requestCode, resultCode, data);
	}
	
	

}
