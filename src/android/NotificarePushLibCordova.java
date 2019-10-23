package re.notifica.cordova;

import android.app.Activity;
import android.content.Intent;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.common.api.CommonStatusCodes;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.SortedSet;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.beacon.BeaconRangingListener;
import re.notifica.billing.BillingManager;
import re.notifica.billing.BillingResult;
import re.notifica.billing.Purchase;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareAsset;
import re.notifica.model.NotificareBeacon;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificarePass;
import re.notifica.model.NotificareProduct;
import re.notifica.model.NotificareScannable;
import re.notifica.model.NotificareTimeOfDay;
import re.notifica.model.NotificareTimeOfDayRange;
import re.notifica.model.NotificareUser;
import re.notifica.model.NotificareUserData;
import re.notifica.model.NotificareUserDataField;
import re.notifica.model.NotificareUserPreference;
import re.notifica.model.NotificareUserSegment;

/**
 * This class echoes a string called from JavaScript.
 */
public class NotificarePushLibCordova extends CordovaPlugin implements Observer<SortedSet<NotificareInboxItem>>, Notificare.OnNotificareReadyListener, Notificare.OnServiceErrorListener, Notificare.OnNotificareNotificationListener, BeaconRangingListener, Notificare.OnBillingReadyListener, BillingManager.OnRefreshFinishedListener, BillingManager.OnPurchaseFinishedListener {

    private static final String TAG = NotificarePushLibCordova.class.getSimpleName();

    private static final int SCANNABLE_REQUEST_CODE = 9004;

    private LiveData<SortedSet<NotificareInboxItem>> mInboxItems;
    private boolean mIsBillingReady = false;

    private CallbackContext mainCallback;
    private List<PluginResult> eventQueue;

    public NotificarePushLibCordova() {
        eventQueue = new ArrayList<PluginResult>();
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("launch")) {
            this.launch(args, callbackContext);
            return true;
        } else if (action.equals("setAuthorizationOptions")) {
            callbackContext.success();
            return true;
        } else if (action.equals("setPresentationOptions")) {
            callbackContext.success();
            return true;
        } else if (action.equals("setCategoryOptions")) {
            callbackContext.success();
            return true;
        } else if (action.equals("didChangeAppLifecycleState")) {
            this.didChangeAppLifecycleState(args, callbackContext);
            return true;
        } else if (action.equals("registerForNotifications")) {
            this.registerForNotifications(args, callbackContext);
            return true;
        } else if (action.equals("unregisterForNotifications")) {
            this.unregisterForNotifications(args, callbackContext);
            return true;
        } else if (action.equals("isRemoteNotificationsEnabled")) {
            this.isRemoteNotificationsEnabled(args, callbackContext);
            return true;
        } else if (action.equals("isAllowedUIEnabled")) {
            this.isAllowedUIEnabled(args, callbackContext);
            return true;
        } else if (action.equals("isNotificationFromNotificare")) {
            callbackContext.success();
            return true;
        } else if (action.equals("fetchNotificationSettings")) {
            callbackContext.success();
            return true;
        } else if (action.equals("startLocationUpdates")) {
            this.startLocationUpdates(args, callbackContext);
            return true;
        } else if (action.equals("stopLocationUpdates")) {
            this.stopLocationUpdates(args, callbackContext);
            return true;
        } else if (action.equals("clearLocation")) {
            this.clearLocation(args, callbackContext);
            return true;
        } else if (action.equals("isLocationServicesEnabled")) {
            this.isLocationServicesEnabled(args, callbackContext);
            return true;
        } else if (action.equals("enableBeacons")) {
            this.enableBeacons(args, callbackContext);
            return true;
        } else if (action.equals("disableBeacons")) {
            this.disableBeacons(args, callbackContext);
            return true;
        } else if (action.equals("enableBilling")) {
            this.enableBilling(args, callbackContext);
            return true;
        } else if (action.equals("disableBilling")) {
            this.disableBilling(args, callbackContext);
            return true;
        } else if (action.equals("registerDevice")) {
            this.registerDevice(args, callbackContext);
            return true;
        } else if (action.equals("fetchDevice")) {
            this.fetchDevice(args, callbackContext);
            return true;
        } else if (action.equals("fetchPreferredLanguage")) {
            this.fetchPreferredLanguage(args, callbackContext);
            return true;
        } else if (action.equals("updatePreferredLanguage")) {
            this.updatePreferredLanguage(args, callbackContext);
            return true;
        } else if (action.equals("fetchTags")) {
            this.fetchTags(args, callbackContext);
            return true;
        }

        return false;
    }

    /**
     * Notificare Cordova Plugin Methods
     */

    private void launch(JSONArray args, CallbackContext callbackContext) {
        mainCallback = callbackContext;
        callbackContext.success();
        Notificare.shared().addNotificareReadyListener(this);
    }

    private void didChangeAppLifecycleState(JSONArray args, CallbackContext callbackContext) {
        try {
            String lifeCycleState = args.getString(0);
            if (lifeCycleState != null) {
                if (lifeCycleState.equals("AppLifecycleState.paused")) {
                    Notificare.shared().setForeground(false);
                    Notificare.shared().getEventLogger().logEndSession();
                } else if (lifeCycleState.equals("AppLifecycleState.resumed")) {
                    Notificare.shared().setForeground(true);
                    Notificare.shared().getEventLogger().logStartSession();
                }
            }
        } catch (JSONException e) {
            // ignore
        }

        callbackContext.success();
    }

    private void registerForNotifications(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().enableNotifications();
        callbackContext.success();
    }

    private void unregisterForNotifications(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().disableNotifications();
        callbackContext.success();
    }

    private void isRemoteNotificationsEnabled(JSONArray args, CallbackContext callbackContext) {
        callbackContext.success((Notificare.shared().isNotificationsEnabled()) ? 1 : 0);
    }

    private void isAllowedUIEnabled(JSONArray args, CallbackContext callbackContext) {
        callbackContext.success((Notificare.shared().checkAllowedUI()) ? 1 : 0);
    }

    private void startLocationUpdates(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().enableLocationUpdates();
        callbackContext.success();
    }

    private void stopLocationUpdates(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().disableLocationUpdates();
        callbackContext.success();
    }

    private void clearLocation(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().clearLocation(new NotificareCallback<Boolean>() {

            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }

            @Override
            public void onSuccess(Boolean aBoolean) {
                callbackContext.success();
            }
        });
    }

    private void isLocationServicesEnabled(JSONArray args, CallbackContext callbackContext) {
        callbackContext.success((Notificare.shared().isLocationUpdatesEnabled()) ? 1 : 0);
    }

    private void enableBeacons(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().enableBeacons();
        callbackContext.success();
    }

    private void disableBeacons(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().disableBeacons();
        callbackContext.success();
    }

    private void enableBilling(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().enableBilling();
        callbackContext.success();
    }

    private void disableBilling(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().disableBilling();
        callbackContext.success();
    }

    private void registerDevice(JSONArray args, CallbackContext callbackContext) {
        try {
            if (args.getString(0) != null) {
                Notificare.shared().setUserId(args.getString(0));
            }
            if (args.getString(0) != null && args.getString(1) != null) {
                Notificare.shared().setUserName(args.getString(1));
            }
            Notificare.shared().registerDevice(new NotificareCallback<String>() {
                @Override
                public void onSuccess(String s) {
                    try {
                        callbackContext.success(NotificarePushLibCordovaUtils.mapDevice(Notificare.shared().getRegisteredDevice()));
                    } catch (JSONException e) {
                        callbackContext.error(e.getLocalizedMessage());
                    }
                }

                @Override
                public void onError(NotificareError notificareError) {
                    callbackContext.error(notificareError.getLocalizedMessage());
                }
            });
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void fetchDevice(JSONArray args, CallbackContext callbackContext) {
        try {
            callbackContext.success(NotificarePushLibCordovaUtils.mapDevice(Notificare.shared().getRegisteredDevice()));
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void fetchPreferredLanguage(JSONArray args, CallbackContext callbackContext) {
        callbackContext.success(Notificare.shared().getPreferredLanguage());
    }

    private void updatePreferredLanguage(JSONArray args, CallbackContext callbackContext) {
        try {
            if (args.getString(0) != null  && args.getString(0) instanceof String) {
                Notificare.shared().updatePreferredLanguage(args.getString(0), new NotificareCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean aBoolean) {
                        callbackContext.success();
                    }

                    @Override
                    public void onError(NotificareError notificareError) {
                        callbackContext.error(notificareError.getLocalizedMessage());
                    }
                });
            } else {
                NotificareError notificareError = new NotificareError("invalid parameters");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void fetchTags(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().fetchDeviceTags(new NotificareCallback<List<String>>() {
            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }

            @Override
            public void onSuccess(List<String> tags) {
                callbackContext.success(new JSONArray(tags));
            }
        });
    }

    /**
     * Notificare Events
     */

    @Override
    public void onNotificareReady(NotificareApplicationInfo notificareApplicationInfo) {
        try {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, NotificarePushLibCordovaUtils.mapApplicationInfo(notificareApplicationInfo));
            handleEvent("ready", pluginResult);
            handleQueue();
        } catch (JSONException e) {
            // ignore
        }
    }

    /**
     * Helper Method to send or queue events
     * @param type
     * @param pluginResult
     */
    public void handleEvent(String type,PluginResult pluginResult) {
        pluginResult.setKeepCallback(true);
        if (mainCallback != null) {
            mainCallback.sendPluginResult(pluginResult);
        } else {
            eventQueue.add(pluginResult);
        }
    }

    /**
     * Helper Method to handle queued events
     */
    public void handleQueue() {
        for (PluginResult pluginResult : eventQueue) {
            mainCallback.sendPluginResult(pluginResult);
        }
        eventQueue.clear();
    }

    public void handleCallback(PluginResult result, CallbackContext callbackContext){
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }

    /**
     * Send a validate user token received event
     * @param token
     */
    private void sendValidateUserToken(String token) {
        if (token != null && !token.isEmpty()) {
            JSONObject tokenMap = new JSONObject();
            try {
                tokenMap.put("token", token);
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, tokenMap);
                handleEvent("activationTokenReceived", pluginResult);
            } catch (JSONException e) {
                // ignore
            }
        }
    }

    /**
     * Send a password reset token received event
     * @param token
     */
    private void sendResetPasswordToken(String token) {
        if (token != null && !token.isEmpty()) {
            JSONObject tokenMap = new JSONObject();
            try {
                tokenMap.put("token", token);
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, tokenMap);
                handleEvent("resetPasswordTokenReceived", pluginResult);
            } catch (JSONException e) {
                // ignore
            }
        }
    }

    private JSONObject parseNotificationIntent(Intent intent) {
        NotificareNotification notification = intent.getParcelableExtra(Notificare.INTENT_EXTRA_NOTIFICATION);
        if (notification != null) {
            try {
                JSONObject notificationMap = NotificarePushLibCordovaUtils.mapNotification(notification);
                // Add inbox item id if present
                if (intent.hasExtra(Notificare.INTENT_EXTRA_INBOX_ITEM_ID)) {
                    notificationMap.put("inboxItemId", intent.getStringExtra(Notificare.INTENT_EXTRA_INBOX_ITEM_ID));
                }
                return notificationMap;
            } catch (JSONException e) {
                return null;
            }
        }
        return null;
    }

    /**
     * Notificare implemented interfaces
     */

    @Override
    public void onChanged(@Nullable SortedSet<NotificareInboxItem> notificareInboxItems) {
        JSONArray inbox = new JSONArray();
        if (notificareInboxItems != null) {
            try {
                for (NotificareInboxItem item : notificareInboxItems) {
                    inbox.put(NotificarePushLibCordovaUtils.mapInboxItem(item));
                }
            } catch (JSONException e) {
                // ignore, send list as is
            }
            PluginResult inboxResult = new PluginResult(PluginResult.Status.OK, inbox);
            handleEvent("inboxLoaded", inboxResult);
            PluginResult badgeResult = new PluginResult(PluginResult.Status.OK, Notificare.shared().getInboxManager().getUnreadCount());
            handleEvent("badgeUpdated", badgeResult);
        }
    }

    @Override
    public void onBillingReady() {
        if (!mIsBillingReady) {
            Notificare.shared().getBillingManager().refresh(this);
        }
    }

    @Override
    public void onNotificareNotification(NotificareNotification notification, NotificareInboxItem inboxItem, Boolean shouldPresent) {
        if (notification != null) {
            try {
                JSONObject notificationMap = NotificarePushLibCordovaUtils.mapNotification(notification);
                // Add inbox item id if present
                if (inboxItem != null) {
                    notificationMap.put("inboxItemId", inboxItem.getItemId());
                }
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, notificationMap);
                handleEvent("remoteNotificationReceivedInForeground", pluginResult);
            } catch (JSONException e) {
                // ignore
            }
        }
    }

    @Override
    public void onServiceError(int errorCode, int requestCode) {
        if (Notificare.isUserRecoverableError(errorCode) && cordova != null && cordova.getActivity() != null) {
            final Activity activity = cordova.getActivity();
            activity.runOnUiThread(() -> Notificare.getErrorDialog(errorCode, activity, requestCode).show());
        }
    }

    @Override
    public void onRangingBeacons(List<NotificareBeacon> beacons) {
        try {
            JSONObject payload = new JSONObject();
            JSONArray beaconsArray = new JSONArray();
            for (NotificareBeacon beacon : beacons) {
                beaconsArray.put(NotificarePushLibCordovaUtils.mapBeacon(beacon));
            }
            payload.put("beacons", beaconsArray);
            if (beacons.size() > 0) {
                if (beacons.get(0).getRegion() != null) {
                    payload.put("region", NotificarePushLibCordovaUtils.mapRegionForBeacon(beacons.get(0)));
                }
            }
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, payload);
            handleEvent("beaconsInRangeForRegion", pluginResult);
        } catch (JSONException e) {
            // ignore
        }
    }

    @Override
    public void onPurchaseFinished(BillingResult billingResult, Purchase purchase) {
        mIsBillingReady = false;
        JSONObject payload = new JSONObject();
        NotificareProduct product = Notificare.shared().getBillingManager().getProduct(purchase.getProductId());
        try {
            if (product != null) {
                payload.put("product", NotificarePushLibCordovaUtils.mapProduct(product));
            }
            if (billingResult.isFailure()) {
                payload.put("error", billingResult.getMessage());
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, payload);
                handleEvent("productTransactionFailed", pluginResult);
            } else if (billingResult.isSuccess()) {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, payload);
                handleEvent("productTransactionCompleted", pluginResult);
            }
        } catch (JSONException e) {
            //ignore
        }
    }

    @Override
    public void onRefreshFinished() {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, NotificarePushLibCordovaUtils.mapProducts(Notificare.shared().getBillingManager().getProducts()));
        handleEvent("storeLoaded", pluginResult);
    }

    @Override
    public void onRefreshFailed(NotificareError notificareError) {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR);
        handleEvent("storeFailedToLoad", pluginResult);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (!Notificare.shared().handleServiceErrorResolution(requestCode, resultCode, data)) {
            if (requestCode == SCANNABLE_REQUEST_CODE) {
                if (resultCode == CommonStatusCodes.SUCCESS) {
                    if (data != null) {
                        NotificareScannable scannable = Notificare.shared().extractScannableFromActivityResult(data);
                        if (scannable != null) {
                            try {
                                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, NotificarePushLibCordovaUtils.mapScannable(scannable));
                                handleEvent("scannableDetected", pluginResult);
                            } catch (JSONException e) {
                                // ignore
                            }
                        } else {
                            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "scannable not found");
                            handleEvent("scannableSessionInvalidatedWithError", pluginResult);
                        }
                    } else {
                        PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "scan did not return any results");
                        handleEvent("scannableSessionInvalidatedWithError", pluginResult);
                    }
                } else if (resultCode == CommonStatusCodes.CANCELED) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "scan was canceled");
                    handleEvent("scannableSessionInvalidatedWithError", pluginResult);
                } else {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "unknown error");
                    handleEvent("scannableSessionInvalidatedWithError", pluginResult);
                }
            } else if (Notificare.shared().getBillingManager() != null && Notificare.shared().getBillingManager().handleActivityResult(requestCode, resultCode, data)) {
                // Billingmanager handled the result
                mIsBillingReady = true; // wait for purchase to finish before doing other calls
            }
        }
    }


    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        JSONObject notificationMap = parseNotificationIntent(intent);
        if (notificationMap != null) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, notificationMap);
            handleEvent("remoteNotificationReceivedInBackground", pluginResult);
        }
    }

}
