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
