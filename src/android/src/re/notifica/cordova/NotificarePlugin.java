package re.notifica.cordova;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareNotification;
import android.os.Bundle;
import android.util.Log;

/**
 * Cordova plugin for Notificare 
 * @author Joris Verbogt <joris@notifica.re>
 */
public class NotificarePlugin extends CordovaPlugin {

    final static String TAG = NotificarePlugin.class.getSimpleName();

    public static final String ENABLE = "enableNotifications";
    public static final String REGISTER = "registerDevice";
	public static final String UNREGISTER = "unregisterDevice";
	public static final String FETCH = "fetchNotification";
	public static final String ADDTAGS = "addDeviceTags";

	protected HashMap<String, CallbackContext> pendingCallbacks = new HashMap<String, CallbackContext>();
		
	/**
	 * Shared instance
	 */
	static NotificarePlugin instance = new NotificarePlugin();
	
	/**
	 * Constructor
	 */
	public NotificarePlugin() {
		instance = this;
	}
	
	/**
	 * Singleton method
	 * @return the shared instance of the plugin
	 */
	public static NotificarePlugin shared() {
		return instance;
	}
	
	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if (ENABLE.equals(action)) {
			enableNotifications(callbackContext);
			return true;
		} else if (REGISTER.equals(action)) {
			registerDevice(args, callbackContext);
			return true;
		} else if (FETCH.equals(action)) {
			fetchNotification(args, callbackContext);
			return true;
		} else if (ADDTAGS.equals(action)) {
			addDeviceTags(args, callbackContext);
			return true;
		}
        Log.d(TAG, "Invalid action: " + action);
		return false;
	}

	/**
	 * Enable push notifications
	 * @param callbackContext
	 */
	protected void enableNotifications(CallbackContext callbackContext) {
		Log.d(TAG, "ENABLE");
		Notificare.shared().enableNotifications();
		callbackContext.success();
	}
	
	/**
	 * Register a device and (optionally) its user to Notificare 
	 * @param args
	 * @param callbackContext
	 * @throws JSONException
	 */
	protected void registerDevice(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "REGISTER");
        String deviceId = args.getString(0);
        String userId = null;
        String userName = null;
        if (args.length() == 2) {
        	userId = args.getString(1);
        }
        if (args.length() == 3) {
        	userName = args.getString(2);
        }
		Notificare.shared().registerDevice(deviceId, userId, userName, new NotificareCallback<String>() {

			@Override
			public void onSuccess(String result) {
				Notificare.shared().setDeviceId(result);
				if (callbackContext == null) {
					return;
				}
				callbackContext.success();
			}

			@Override
			public void onError(NotificareError error) {
				if (callbackContext == null) {
					return;
				}
				callbackContext.error(error.getLocalizedMessage());		
			}
			
		});
	}

	/**
	 * Fetch the full notification object
	 * @param args
	 * @param callbackContext
	 */
	protected void fetchNotification(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "FETCH");
		// Add to notification queue
		String notificationId = null;
		try {
			notificationId = args.getString(0);
		} catch (JSONException e) {
			callbackContext.error(e.getLocalizedMessage());
		}
		if (notificationId != null) {
			Notificare.shared().fetchNotification(notificationId, new NotificareCallback<NotificareNotification>() {

				@Override
				public void onSuccess(NotificareNotification notification) {
					if (callbackContext == null) {
						return;
					}
					try {
						callbackContext.success(notification.toJSONObject());
					} catch (JSONException e) {
						callbackContext.error(e.getLocalizedMessage());
					}					
				}

				@Override
				public void onError(NotificareError error) {
					if (callbackContext == null) {
						return;
					}
					callbackContext.error(error.getLocalizedMessage());
				}
			});
		}
	}
	
	
	/**
	 * Fetch the full notification object
	 * @param args
	 * @param callbackContext
	 */
	protected void addDeviceTags(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "ADDTAGS");
		ArrayList<String> tagList = new ArrayList<String>();
		try {
			JSONArray tags = args.getJSONArray(0);
			if (tags != null) {
				for (int i = 0; i < tags.length(); i++) {
					tagList.add(tags.getString(i));
				}
			}
			Notificare.shared().addDeviceTags(Notificare.shared().getDeviceId(), tagList, new NotificareCallback<Boolean>() {

				@Override
				public void onSuccess(Boolean result) {
					if (callbackContext == null) {
						return;
					}
					callbackContext.success();
				}

				@Override
				public void onError(NotificareError error) {
					if (callbackContext == null) {
						return;
					}
					callbackContext.error(error.getLocalizedMessage());
				}
			});
		} catch (JSONException e) {
			callbackContext.error("JSON parse error");
		}
	}
	
	/**
	 * Send the registered deviceId (APID) to the webview
	 * @param deviceId
	 */
	public void sendRegistration(String deviceId) {
        String js = String.format(
                "window.plugins.notificare.registrationCallback('%s');",
                deviceId);
        Log.i(TAG, "Calling JS: " + js);

        try {
            this.webView.sendJavascript(js);
        } catch (NullPointerException npe) {
            Log.i(TAG, "unable to send javascript in sendRegistration");
        } catch (Exception e) {
            Log.e(TAG, "unexpected exception in sendRegistration", e);
        }
	}

	/**
	 * Get extras from a Bundle and convert to JSON object
	 * @param extras
	 * @return the extras as JSON object
	 */
	protected JSONObject getNotificationExtras(Bundle extras) {
		JSONObject data = new JSONObject();
		try {
			for (Iterator<String> iterator = extras.keySet().iterator(); iterator.hasNext();) {
				String key = (String) iterator.next();
					data.put(key, extras.getString(key));
			}
		} catch (JSONException e) {
			Log.e(TAG, "error in sendPushNotificationOpened", e);
		}
		return data;
	}

	/**
	 * Send the opened notification to the webview
	 * @param alert
	 * @param notificationId
	 * @param extras
	 */
	public void sendPushNotificationOpened(String alert, String notificationId, Bundle extras) {
        String js = String.format(
                "window.plugins.notificare.pushNotificationOpenedCallback('%s', '%s', %s);",
                alert, notificationId, getNotificationExtras(extras).toString());
        Log.i(TAG, "Calling JS: " + js);

        try {
            this.webView.sendJavascript(js);
        } catch (NullPointerException npe) {
            Log.i(TAG, "unable to send javascript in sendPushNotificationOpened");
        } catch (Exception e) {
            Log.e(TAG, "unexpected exception in sendPushNotificationOpened", e);
        }
	}

	/**
	 * Send the received notification to the webview
	 * @param alert
	 * @param notificationId
	 * @param extras
	 */
	public void sendPushNotificationReceived(String alert, String notificationId, Bundle extras) {
        String js = String.format(
                "window.plugins.notificare.pushNotificationReceivedCallback('%s', '%s', %s);",
                alert, notificationId, getNotificationExtras(extras).toString());
        Log.i(TAG, "Calling JS: " + js);

        try {
            this.webView.sendJavascript(js);
        } catch (NullPointerException npe) {
            Log.i(TAG, "unable to send javascript in sendPushNotificationReceived");
        } catch (Exception e) {
            Log.e(TAG, "unexpected exception in sendPushNotificationReceived", e);
        }
	}

}
