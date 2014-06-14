package re.notifica.cordova;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareUser;
import android.util.Log;

/**
 * Cordova plugin for Notificare 
 * @author Joris Verbogt <joris@notifica.re>
 */
public class NotificarePlugin extends CordovaPlugin {

    final static String TAG = NotificarePlugin.class.getSimpleName();

    public static final String ENABLE = "enableNotifications";
    public static final String ENABLELOCATIONS = "enableLocationUpdates";
    public static final String DISABLE = "disableNotifications";
    public static final String DISABLELOCATIONS = "disableLocationUpdates";
    public static final String REGISTER = "registerDevice";
	public static final String ADDTAGS = "addDeviceTags";
	public static final String REMOVETAG = "removeDeviceTag";
	public static final String CLEARTAGS = "clearDeviceTags";
	public static final String FETCHTAGS = "fetchDeviceTags";
	public static final String CREATEACCOUNT = "createAccount";
	public static final String SENDPASSWORD = "sendPassword";
	public static final String RESETPASSWORD = "resetPassword";
	public static final String CHANGEPASSWORD = "changePassword";
	public static final String USERLOGIN = "userLogin";
	public static final String FETCHUSERDETAILS = "fetchUserDetails";	

	protected HashMap<String, CallbackContext> pendingCallbacks = new HashMap<String, CallbackContext>();
		
	/**
	 * Shared instance
	 */
	static NotificarePlugin instance = new NotificarePlugin();
	
	/**
	 * Constructor
	 */
	public NotificarePlugin() {
		Log.d(TAG, "NotificarePlugin instantiated");
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
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);
		Notificare.shared().launch(cordova.getActivity());
		Notificare.shared().setIntentReceiver(IntentReceiver.class);
	}

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if (ENABLE.equals(action)) {
			enableNotifications(callbackContext);
			return true;
		} else if (ENABLELOCATIONS.equals(action)) {
			enableLocationUpdates(callbackContext);
			return true;
		} else if (DISABLE.equals(action)) {
			disableNotifications(callbackContext);
			return true;
		} else if (DISABLELOCATIONS.equals(action)) {
			disableLocationUpdates(callbackContext);
			return true;
		} else if (REGISTER.equals(action)) {
			registerDevice(args, callbackContext);
			return true;
		} else if (ADDTAGS.equals(action)) {
			addDeviceTags(args, callbackContext);
			return true;
		} else if (REMOVETAG.equals(action)) {
			removeDeviceTag(args, callbackContext);
			return true;
		} else if (CLEARTAGS.equals(action)) {
			clearDeviceTags(args, callbackContext);
			return true;
		} else if (FETCHTAGS.equals(action)) {
			fetchDeviceTags(args, callbackContext);
			return true;
		} else if (CREATEACCOUNT.equals(action)) {
			createAccount(args, callbackContext);
			return true;
		} else if (SENDPASSWORD.equals(action)) {
			sendPassword(args, callbackContext);
			return true;
		} else if (RESETPASSWORD.equals(action)) {
			resetPassword(args, callbackContext);
			return true;
		} else if (CHANGEPASSWORD.equals(action)) {
			changePassword(args, callbackContext);
			return true;
		} else if (USERLOGIN.equals(action)) {
			userLogin(args, callbackContext);
			return true;
		} else if (FETCHUSERDETAILS.equals(action)) {
			fetchUserDetails(args, callbackContext);
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
	 * Enable location updates
	 * @param callbackContext
	 */
	protected void enableLocationUpdates(CallbackContext callbackContext) {
		Log.d(TAG, "ENABLELOCATIONS");
		Notificare.shared().enableLocationUpdates();
		callbackContext.success();
	}

	/**
	 * Disable push notifications
	 * @param callbackContext
	 */
	protected void disableNotifications(CallbackContext callbackContext) {
		Log.d(TAG, "DISABLE");
		Notificare.shared().disableNotifications();
		callbackContext.success();
	}

	/**
	 * Disable location updates
	 * @param callbackContext
	 */
	protected void disableLocationUpdates(CallbackContext callbackContext) {
		Log.d(TAG, "DISABLELOCATIONS");
		Notificare.shared().disableLocationUpdates();
		callbackContext.success();
	}

	/**
	 * Register a device and (optionally) its user to Notificare 
	 * @param args
	 * @param callbackContext
	 * @throws JSONException
	 */
	protected void registerDevice(JSONArray args, final CallbackContext callbackContext) {
        Log.d(TAG, "REGISTER");
        try {
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
        } catch (JSONException e) {
			callbackContext.error("JSON parse error");
		}
	}

	/**
	 * Add tags to a device
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
			Notificare.shared().addDeviceTags(tagList, new NotificareCallback<Boolean>() {

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
	 * Remove tag from a device
	 * @param args
	 * @param callbackContext
	 */
	protected void removeDeviceTag(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "REMOVETAG");
		try {
			String tag = args.getString(0);
			if (tag != null) {
				Notificare.shared().removeDeviceTag(tag, new NotificareCallback<Boolean>() {

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
			}
		} catch (JSONException e) {
			callbackContext.error("JSON parse error");
		}
	}
	
	/**
	 * Clear tags, i.e., remove all tags from a device
	 * @param args
	 * @param callbackContext
	 */
	protected void clearDeviceTags(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "CLEARTAGS");
		Notificare.shared().clearDeviceTags(new NotificareCallback<Boolean>() {

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
	}
	
	/**
	 * Fetch the device tags
	 * @param args
	 * @param callbackContext
	 */
	protected void fetchDeviceTags(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "FETCHTAGS");
		Notificare.shared().fetchDeviceTags(new NotificareCallback<List<String>>() {

			@Override
			public void onSuccess(List<String>tags) {
				if (callbackContext == null) {
					return;
				}
				callbackContext.success(new JSONArray(tags));
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
	 * Create a new user account
	 * @param args
	 * @param callbackContext
	 */
	protected void createAccount(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "CREATEACCOUNT");
		try {
			String email = args.getString(0);
			String password = args.getString(1);
			String userName = args.optString(2);
			if (userName.isEmpty()) {
				userName = null;
			}
			Notificare.shared().createAccount(email, password, userName, new NotificareCallback<Boolean>() {

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
	 * Send a password reset email
	 * @param args
	 * @param callbackContext
	 */
	protected void sendPassword(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "SENDPASSWORD");
		try {
			String email = args.getString(0);
			Notificare.shared().sendPassword(email, new NotificareCallback<Boolean>() {

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
	 * Reset password
	 * @param args
	 * @param callbackContext
	 */
	protected void resetPassword(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "RESETPASSWORD");
		try {
			String password = args.getString(0);
			String token = args.getString(1);
			Notificare.shared().resetPassword(password, token, new NotificareCallback<Boolean>() {

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
	 * Change password
	 * @param args
	 * @param callbackContext
	 */
	protected void changePassword(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "CHANGEPASSWORD");
		try {
			String password = args.getString(0);
			Notificare.shared().changePassword(password, new NotificareCallback<Boolean>() {

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
	 * Log in user
	 * @param args
	 * @param callbackContext
	 */
	protected void userLogin(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "USERLOGIN");
		try {
			String username = args.getString(0);
			String password = args.getString(1);
			Notificare.shared().userLogin(username, password, new NotificareCallback<Boolean>() {

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
	 * Fetch user details
	 * @param args
	 * @param callbackContext
	 */
	protected void fetchUserDetails(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "FETCHUSERDETAILS");
		Notificare.shared().fetchUserDetails(new NotificareCallback<NotificareUser>() {

			@Override
			public void onSuccess(NotificareUser result) {
				if (callbackContext == null) {
					return;
				}
				try {
					callbackContext.success(result.toJSONObject());
				} catch (JSONException error) {
					callbackContext.error(error.getLocalizedMessage());
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

	/**
	 * Send the registered deviceId (APID) to the webview
	 * @param deviceId
	 */
	public void sendRegistration(String deviceId) {
        String js = String.format("Notificare.registrationCallback(null, '%s');", deviceId);
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
	 * Send the registered deviceId (APID) to the webview
	 * @param deviceId
	 */
	public void sendRegistrationError(String errorId) {
        String js = String.format("Notificare.registrationCallback(new Error(%s));", errorId);
        Log.i(TAG, "Calling JS: " + js);
        try {
            this.webView.sendJavascript(js);
        } catch (NullPointerException npe) {
            Log.i(TAG, "unable to send javascript in sendRegistration");
        } catch (Exception e) {
            Log.e(TAG, "unexpected exception in sendRegistration", e);
        }
	}

}
