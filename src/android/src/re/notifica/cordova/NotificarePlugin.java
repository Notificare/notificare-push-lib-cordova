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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import re.notifica.Notificare;
import re.notifica.Notificare.OnNotificareReadyListener;
import re.notifica.Notificare.OnServiceErrorListener;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareUser;
import re.notifica.ui.NotificationActivity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import re.notifica.util.Log;

/**
 * Cordova plugin for Notificare 
 * @author Joris Verbogt <joris@notifica.re>
 */
public class NotificarePlugin extends CordovaPlugin implements OnServiceErrorListener, OnNotificareReadyListener {

	
    protected static final String TAG = NotificarePlugin.class.getSimpleName();

	private static final String SETTINGS_PREFERENCES = "re.notifica.preferences.Settings";
	private static final String SETTINGS_KEY_LOCATION_PERMISSION_REQUESTED = "locationPermissionRequested";

	public static final int MIN_SDK_VERSION = 10605;
	public static final int PLUGIN_VERSION_CODE = 10605;
	public static final String PLUGIN_VERSION_NAME = "1.6.5";
    
	public static final String START = "start";
	public static final String SETHANDLENOTIFICATION = "setHandleNotification";
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
	public static final String VALIDATEUSER = "validateUser";
	public static final String SENDPASSWORD = "sendPassword";
	public static final String RESETPASSWORD = "resetPassword";
	public static final String CHANGEPASSWORD = "changePassword";
	public static final String USERLOGIN = "userLogin";
	public static final String USERLOGOUT = "userLogout";
	public static final String GENERATEACCESSTOKEN = "generateAccessToken";
	public static final String FETCHUSERDETAILS = "fetchUserDetails";
	public static final String OPENNOTIFICATION = "openNotification";
	public static final String LOGOPENNOTIFICATION = "logOpenNotification";
	public static final String LOGCUSTOMEVENT = "logCustomEvent";

	public static final String CALLBACK_TYPE_READY = "ready";
	public static final String CALLBACK_TYPE_REGISTRATION = "registration";
	public static final String CALLBACK_TYPE_NOTIFICATION = "notification";
	public static final String CALLBACK_TYPE_LOCATION_PERMISSION_RATIONALE = "locationPermissionRationale";
	public static final String CALLBACK_TYPE_RESET_PASSWORD_TOKEN = "resetPasswordToken";
	public static final String CALLBACK_TYPE_VALIDATE_USER_TOKEN = "validateUserToken";

	public static final int LOCATION_PERMISSION_REQUEST_CODE = 0;

	protected HashMap<String, CallbackContext> pendingCallbacks = new HashMap<String, CallbackContext>();
	
	private CallbackContext mainCallback;

	private List<PluginResult> resultQueue;
	
	/**
	 * Shared instance
	 */
	private static NotificarePlugin instance;
    final static Object lock = new Object();
	
	/**
	 * Constructor
	 */
	public NotificarePlugin() {
		Log.d(TAG, "NotificarePlugin instantiated");
		instance = this;
		resultQueue = new ArrayList<PluginResult>();
	}
	
	/**
	 * Singleton method
	 * @return the shared instance of the plugin
	 */
	public static NotificarePlugin shared() {
		synchronized (lock) {
			if (instance == null) {
				instance = new NotificarePlugin();
			}
			return instance;
		}
	}
	
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		Log.d(TAG, "Initializing Notificare Plugin version " + PLUGIN_VERSION_NAME);
		super.initialize(cordova, webView);
		if (Notificare.shared().getSDKVersionCode() < MIN_SDK_VERSION) {
			throw new IllegalStateException("Please install a newer version of the Notificare SDK, minimal compatible version is " + MIN_SDK_VERSION);
		}
		Notificare.shared().addServiceErrorListener(this);
		Notificare.shared().setForeground(true);
		Notificare.shared().getEventLogger().logStartSession();	
		// Check for launch with notification or tokens
		sendNotification(parseNotificationIntent(cordova.getActivity().getIntent()));
		sendValidateUserToken(Notificare.shared().parseValidateUserIntent(cordova.getActivity().getIntent()));
		sendResetPasswordToken(Notificare.shared().parseResetPasswordIntent(cordova.getActivity().getIntent()));
	}

	@Override
	public void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		// Check for launch with notification or tokens
		sendNotification(parseNotificationIntent(intent));
		sendValidateUserToken(Notificare.shared().parseValidateUserIntent(intent));
		sendResetPasswordToken(Notificare.shared().parseResetPasswordIntent(intent));
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		super.onActivityResult(requestCode, resultCode, intent);
		Notificare.shared().handleServiceErrorResolution(requestCode, resultCode, intent);
	}

	@Override
	public void onServiceError(int errorCode, int requestCode) {
		if (Notificare.isUserRecoverableError(errorCode)) {
            Notificare.getErrorDialog(errorCode, cordova.getActivity(), requestCode).show();
        }
	}
	
	@Override
	public void onNotificareReady(NotificareApplicationInfo applicationInfo) {
		Log.d(TAG, "onNotificareReady");
		sendReady(applicationInfo);
		sendResultQueue();
	}
	
	@Override
	public void onPause(boolean multitasking) {
		Log.d(TAG, "activity paused");
		super.onPause(multitasking);
		Notificare.shared().removeServiceErrorListener(this);
		Notificare.shared().setForeground(false);
		Notificare.shared().getEventLogger().logEndSession();	
	}

	@Override
	public void onResume(boolean multitasking) {
		Log.d(TAG, "activity resumed");
		super.onResume(multitasking);
		Notificare.shared().addServiceErrorListener(this);
		Notificare.shared().setForeground(true);
		Notificare.shared().getEventLogger().logStartSession();	
	}

	@Override
	public void onDestroy() {
		Log.d(TAG, "activity destroyed");
		super.onDestroy();
		Notificare.shared().removeServiceErrorListener(this);
		Notificare.shared().removeNotificareReadyListener(this);
		Notificare.shared().setForeground(false);
		Notificare.shared().getEventLogger().logEndSession();	
	}

	@Override
	public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        switch (requestCode) {
            case LOCATION_PERMISSION_REQUEST_CODE: {
                if (Notificare.shared().checkRequestLocationPermissionResult(permissions, grantResults)) {
                    Log.i(TAG, "permission granted");
                    Notificare.shared().enableLocationUpdates();
                    Notificare.shared().enableBeacons();
                }
                return;
            }
        }
	}

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if (START.equals(action)) {
			start(callbackContext);
			return true;
		} else if (SETHANDLENOTIFICATION.equals(action)) {
			setHandleNotification(args, callbackContext);
			return true;
		} else if (ENABLE.equals(action)) {
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
		} else if (VALIDATEUSER.equals(action)) {
			validateUser(args, callbackContext);
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
		} else if (USERLOGOUT.equals(action)) {
			userLogout(args, callbackContext);
			return true;
		} else if (FETCHUSERDETAILS.equals(action)) {
			fetchUserDetails(args, callbackContext);
			return true;
		} else if (GENERATEACCESSTOKEN.equals(action)) {
			generateAccessToken(args, callbackContext);
			return true;
		} else if (OPENNOTIFICATION.equals(action)) {
			openNotification(args, callbackContext);
			return true;
		} else if (LOGOPENNOTIFICATION.equals(action)) {
			logOpenNotification(args, callbackContext);
			return true;
		} else if (LOGCUSTOMEVENT.equals(action)) {
			logCustomEvent(args, callbackContext);
			return true;
		}
        Log.d(TAG, "Invalid action: " + action);
		return false;
	}

	/**
	 * Start the plugin, keep the callbackContext for future events
	 * @param callbackContext
	 */
	protected void start(CallbackContext callbackContext) {
		Log.d(TAG, "START");
		mainCallback = callbackContext;
		PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT, "");
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
        Notificare.shared().addNotificareReadyListener(this);
	}
	
	/**
	 * Handle notifications ourselves: a no-op on Android since this is determined from the AndroidManifest intent-filter
	 * @param callbackContext
	 */
	protected void setHandleNotification(JSONArray args, CallbackContext callbackContext) {
		Log.d(TAG, "SETHANDLENOTIFICATION called on Android, no effect");
		callbackContext.success();
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
    	if (!Notificare.shared().hasLocationPermissionGranted()) {
    		Log.i(TAG, "permission not granted");
			cordova.requestPermissions(this, LOCATION_PERMISSION_REQUEST_CODE, new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION});
    	} else {
    		Notificare.shared().enableLocationUpdates();
    	}
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
	        	userId = args.getString(1);
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
			String userName = null;
			if (args.length() == 3) {
				userName = args.optString(2);
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
	 * Validate user
	 * @param args
	 * @param callbackContext
	 */
	protected void validateUser(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "VALIDATEUSER");
		try {
			String token = args.getString(0);
			Notificare.shared().validateUser(token, new NotificareCallback<Boolean>() {

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
	 * Log out user
	 * @param args
	 * @param callbackContext
	 */
	protected void userLogout(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "USERLOGOUT");
		Notificare.shared().userLogout(new NotificareCallback<Boolean>() {

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
	 * Generate access token
	 * @param args
	 * @param callbackContext
	 */
	protected void generateAccessToken(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "GENERATEACCESSTOKEN");
		Notificare.shared().generateAccessToken(new NotificareCallback<NotificareUser>() {

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
	 * Open the notification in NotificationActivity
	 * @param args
	 * @param callbackContext
	 */
	protected void openNotification(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "OPENNOTIFICATION");
		try {
			JSONObject notificationJSON = args.getJSONObject(0);
			// Workaround for pre-1.1.1 SDK
			notificationJSON.put("_id", notificationJSON.get("notificationId"));
			NotificareNotification notification = new NotificareNotification(notificationJSON);
			
			Intent notificationIntent = new Intent()
			.setClass(Notificare.shared().getApplicationContext(), NotificationActivity.class)
			.setAction(Notificare.INTENT_ACTION_NOTIFICATION_OPENED)
			.putExtra(Notificare.INTENT_EXTRA_NOTIFICATION, notification)
			.putExtra(Notificare.INTENT_EXTRA_DISPLAY_MESSAGE, Notificare.shared().getDisplayMessage())
			.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

			cordova.getActivity().startActivity(notificationIntent);
		} catch (JSONException e) {
			callbackContext.error("JSON parse error");
		}
	}

    /**
     * Log a the notification open
     * @param args
     * @param callbackContext
     */
	protected void logOpenNotification(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "LOGOPENNOTIFICATION");
		try {
			JSONObject notificationJSON = args.getJSONObject(0);
			NotificareNotification notification = new NotificareNotification(notificationJSON);
			Notificare.shared().getEventLogger().logOpenNotification(notification.getNotificationId());
		} catch (JSONException e) {
			callbackContext.error("JSON parse error");
		}
	}

    /**
     * Log a custom event
     * @param args
     * @param callbackContext
     */
	protected void logCustomEvent(JSONArray args, final CallbackContext callbackContext) {
		Log.d(TAG, "LOGCUSTOMEVENT");
		try {
		    String name = args.getString(0);
			JSONObject dataJSON = args.getJSONObject(1);
			Notificare.shared().getEventLogger().logCustomEvent(name, dataJSON);
		} catch (JSONException e) {
			callbackContext.error("JSON parse error");
		}
	}

	/**
	 * Parse notification from launch intent
	 * @param intent
	 * @return
	 */
	protected NotificareNotification parseNotificationIntent(Intent intent) {
		if (intent != null && intent.hasExtra(Notificare.INTENT_EXTRA_NOTIFICATION)) {
			Log.d(TAG, "Launched with Notification");
			return intent.getParcelableExtra(Notificare.INTENT_EXTRA_NOTIFICATION);
		} else {
			return null;
		}
	}

	/**
	 * Send a success result to the webview
	 * @param type
	 * @param data
	 */
	private void sendSuccessResult(String type, Object data) {
		if (data != null && type != null) {
			JSONObject result = new JSONObject();
			try {
				result.put("type", type);
				result.put("data", data);
				PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, result);
				pluginResult.setKeepCallback(true);
				if (mainCallback != null) {
					Log.d(TAG, "Sending success result: " + pluginResult.getMessage());
					mainCallback.sendPluginResult(pluginResult);
				} else {
					Log.d(TAG, "Queueing success result: " + pluginResult.getMessage());
					resultQueue.add(pluginResult);
				}
			} catch (JSONException e) {
				Log.e(TAG, "could not serialize result for callback");
			}
			
		}
	}

	/**
	 * Send an error to the webview
	 * @param type
	 * @param message
	 */
	private void sendErrorResult(String type, String message) {
		if (message != null && type != null) {
			JSONObject result = new JSONObject();
			try {
				result.put("type", type);
				result.put("data", message);
				PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, result);
				pluginResult.setKeepCallback(true);
				if (mainCallback != null) {
	            	mainCallback.sendPluginResult(pluginResult);
	            } else {
	            	resultQueue.add(pluginResult);
	            }
			} catch (JSONException e) {
				Log.e(TAG, "could not serialize result for callback");
			}
			
		}
	}

	/**
	 * Send results that were queued while the plugin was initializing
	 */
	private void sendResultQueue() {
		for (PluginResult pluginResult : resultQueue) {
			mainCallback.sendPluginResult(pluginResult);
		}
		resultQueue.clear();
	}

	/**
	 * Send the ready event to the webview
	 * @param deviceId
	 */
	public void sendReady(NotificareApplicationInfo applicationInfo) {
		Log.d(TAG, "sendReady");
		if (applicationInfo != null) {
	        try {
	        	sendSuccessResult(CALLBACK_TYPE_READY, applicationInfo.toJSONObject());
	        } catch (JSONException e) {
	        	Log.e(TAG, "unable to parse javascript in sendReady", e);
	        }
		}
	}

	/**
	 * Send the registered deviceId (APID) to the webview
	 * @param deviceId
	 */
	public void sendRegistration(String deviceId) {
		Log.d(TAG, "sendRegistration");
		if (deviceId != null) {
			sendSuccessResult(CALLBACK_TYPE_REGISTRATION, deviceId);
		}
	}

	/**
	 * Send the registered deviceId (APID) to the webview
	 * @param deviceId
	 */
	public void sendRegistrationError(String errorId) {
		Log.d(TAG, "sendRegistrationError");
		sendErrorResult(CALLBACK_TYPE_REGISTRATION, errorId);
	}

	/**
	 * Send the notification to the webview
	 * @param deviceId
	 */
	public void sendNotification(NotificareNotification notification) {
		Log.d(TAG, "sendNotification");
		if (notification != null) {
	        try {
	            sendSuccessResult(CALLBACK_TYPE_NOTIFICATION, notification.toJSONObject());
			} catch (JSONException e) {
				Log.e(TAG, "error creating JSON from notification");
	        }			
		}
	}

	/**
	 * Send reset password token to the webview
	 * @param token
	 */
	public void sendResetPasswordToken(String token) {
		if (token != null) {
            sendSuccessResult(CALLBACK_TYPE_RESET_PASSWORD_TOKEN, token);
		}
	}

	/**
	 * Send validate user token to the webview
	 * @param token
	 */
	public void sendValidateUserToken(String token) {
		if (token != null) {
			sendSuccessResult(CALLBACK_TYPE_VALIDATE_USER_TOKEN, token);
		}
	}

}
