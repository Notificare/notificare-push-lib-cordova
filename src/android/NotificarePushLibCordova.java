package re.notifica.cordova;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

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
import java.util.Map;
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
        } else if (action.equals("addTag")) {
            this.addTag(args, callbackContext);
            return true;
        } else if (action.equals("addTags")) {
            this.addTags(args, callbackContext);
            return true;
        } else if (action.equals("removeTag")) {
            this.removeTag(args, callbackContext);
            return true;
        } else if (action.equals("removeTags")) {
            this.removeTags(args, callbackContext);
            return true;
        } else if (action.equals("clearTags")) {
            this.clearTags(args, callbackContext);
            return true;
        } else if (action.equals("fetchUserData")) {
            this.fetchUserData(args, callbackContext);
            return true;
        } else if (action.equals("updateUserData")) {
            this.updateUserData(args, callbackContext);
            return true;
        } else if (action.equals("fetchDoNotDisturb")) {
            this.fetchDoNotDisturb(args, callbackContext);
            return true;
        } else if (action.equals("updateDoNotDisturb")) {
            this.updateDoNotDisturb(args, callbackContext);
            return true;
        } else if (action.equals("clearDoNotDisturb")) {
            this.clearDoNotDisturb(args, callbackContext);
            return true;
        } else if (action.equals("fetchNotificationForInboxItem")) {
            this.fetchNotificationForInboxItem(args, callbackContext);
            return true;
        }  else if (action.equals("presentNotification")) {
            this.presentNotification(args, callbackContext);
            return true;
        }  else if (action.equals("fetchInbox")) {
            this.fetchInbox(args, callbackContext);
            return true;
        } else if (action.equals("presentInboxItem")) {
            this.presentInboxItem(args, callbackContext);
            return true;
        } else if (action.equals("removeFromInbox")) {
            this.removeFromInbox(args, callbackContext);
            return true;
        } else if (action.equals("markAsRead")) {
            this.markAsRead(args, callbackContext);
            return true;
        } else if (action.equals("clearInbox")) {
            this.clearInbox(args, callbackContext);
            return true;
        } else if (action.equals("fetchAssets")) {
            this.fetchAssets(args, callbackContext);
            return true;
        } else if (action.equals("fetchPassWithSerial")) {
            this.fetchPassWithSerial(args, callbackContext);
            return true;
        } else if (action.equals("fetchPassWithBarcode")) {
            this.fetchPassWithBarcode(args, callbackContext);
            return true;
        } else if (action.equals("fetchProducts")) {
            this.fetchProducts(args, callbackContext);
            return true;
        } else if (action.equals("fetchPurchasedProducts")) {
            this.fetchPurchasedProducts(args, callbackContext);
            return true;
        } else if (action.equals("fetchProduct")) {
            this.fetchProduct(args, callbackContext);
            return true;
        } else if (action.equals("buyProduct")) {
            this.buyProduct(args, callbackContext);
            return true;
        } else if (action.equals("logCustomEvent")) {
            this.logCustomEvent(args, callbackContext);
            return true;
        } else if (action.equals("logOpenNotification")) {
            this.logOpenNotification(args, callbackContext);
            return true;
        } else if (action.equals("logInfluencedNotification")) {
            this.logInfluencedNotification(args, callbackContext);
            return true;
        } else if (action.equals("doCloudHostOperation")) {
            this.doCloudHostOperation(args, callbackContext);
            return true;
        } else if (action.equals("createAccount")) {
            this.createAccount(args, callbackContext);
            return true;
        } else if (action.equals("validateAccount")) {
            this.validateAccount(args, callbackContext);
            return true;
        } else if (action.equals("resetPassword")) {
            this.resetPassword(args, callbackContext);
            return true;
        } else if (action.equals("sendPassword")) {
            this.sendPassword(args, callbackContext);
            return true;
        } else if (action.equals("login")) {
            this.login(args, callbackContext);
            return true;
        } else if (action.equals("logout")) {
            this.logout(args, callbackContext);
            return true;
        } else if (action.equals("isLoggedIn")) {
            this.isLoggedIn(args, callbackContext);
            return true;
        } else if (action.equals("generateAccessToken")) {
            this.generateAccessToken(args, callbackContext);
            return true;
        } else if (action.equals("changePassword")) {
            this.changePassword(args, callbackContext);
            return true;
        } else if (action.equals("fetchAccountDetails")) {
            this.fetchAccountDetails(args, callbackContext);
            return true;
        } else if (action.equals("fetchUserPreferences")) {
            this.fetchUserPreferences(args, callbackContext);
            return true;
        } else if (action.equals("addSegmentToUserPreference")) {
            this.addSegmentToUserPreference(args, callbackContext);
            return true;
        } else if (action.equals("removeSegmentFromUserPreference")) {
            this.removeSegmentFromUserPreference(args, callbackContext);
            return true;
        } else if (action.equals("startScannableSession")) {
            this.startScannableSession(args, callbackContext);
            return true;
        } else if (action.equals("presentScannable")) {
            this.presentScannable(args, callbackContext);
            return true;
        }

        return false;
    }

    /************************************************************************************************************************************************************
     * Notificare Cordova Plugin Methods
     ************************************************************************************************************************************************************/


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

    private void addTag(JSONArray args, CallbackContext callbackContext) {
        try {
            if (args.getString(0) != null  && args.getString(0) instanceof String) {
                Notificare.shared().addDeviceTag(args.getString(0), new NotificareCallback<Boolean>() {
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

    private void addTags(JSONArray args, CallbackContext callbackContext) {
        try {
            if (args.getJSONArray(0) != null) {
                List<String> tagsList = new ArrayList<>();
                for (int i = 0; i < args.getJSONArray(0).length(); i++) {
                    tagsList.add(args.getJSONArray(0).optString(i));
                }
                Notificare.shared().addDeviceTags(tagsList, new NotificareCallback<Boolean>() {
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

    private void removeTag(JSONArray args, CallbackContext callbackContext) {
        try {
            if (args.getString(0) != null  && args.getString(0) instanceof String) {
                Notificare.shared().removeDeviceTag(args.getString(0), new NotificareCallback<Boolean>() {
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

    private void removeTags(JSONArray args, CallbackContext callbackContext) {
        try {
            if (args.getJSONArray(0) != null) {
                List<String> tagsList = new ArrayList<>();
                for (int i = 0; i < args.getJSONArray(0).length(); i++) {
                    tagsList.add(args.getJSONArray(0).optString(i));
                }
                Notificare.shared().removeDeviceTags(tagsList, new NotificareCallback<Boolean>() {
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

    private void clearTags(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().clearDeviceTags(new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callbackContext.success();
            }

            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        });
    }

    private void fetchUserData(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().fetchUserData(new NotificareCallback<NotificareUserData>() {
            @Override
            public void onSuccess(NotificareUserData notificareUserData) {
                JSONArray userDataFields = new JSONArray();
                try {
                    for (HashMap.Entry<String, NotificareUserDataField> field : Notificare.shared().getApplicationInfo().getUserDataFields().entrySet()) {
                        JSONObject userDataMap = new JSONObject();
                        userDataMap.put("key", field.getValue().getKey());
                        userDataMap.put("label", field.getValue().getLabel());
                        userDataMap.put("value", notificareUserData.getValue(field.getKey()));
                        userDataFields.put(userDataMap);
                    }
                } catch (JSONException e) {
                    // ignore, send list as is
                }
                callbackContext.success(userDataFields);
            }

            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        });
    }

    private void updateUserData(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject fields = args.getJSONObject(0);
            if (fields != null) {
                NotificareUserData data = new NotificareUserData();
                while (fields.keys().hasNext()) {
                    String key = fields.keys().next();
                    if (fields.optString(key, null) != null) {
                        data.setValue(key, fields.optString(key));
                    }
                }
                Notificare.shared().updateUserData(data, new NotificareCallback<Boolean>() {
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
                NotificareError notificareError = new NotificareError("invalid user data");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }

    }

    private void fetchDoNotDisturb(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().fetchDoNotDisturb(new NotificareCallback<NotificareTimeOfDayRange>() {
            @Override
            public void onSuccess(NotificareTimeOfDayRange dnd) {
                try {
                    callbackContext.success(NotificarePushLibCordovaUtils.mapTimeOfDayRange(dnd));
                } catch (JSONException e) {
                    callbackContext.error(e.getLocalizedMessage());
                }
            }

            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        });
    }

    private void updateDoNotDisturb(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject deviceDnd = args.getJSONObject(0);
            if (deviceDnd != null && deviceDnd.optString("start", null) != null && deviceDnd.optString("end", null) != null) {
                String[] s = deviceDnd.optString("start").split(":");
                String[] e = deviceDnd.optString("end").split(":");
                final NotificareTimeOfDayRange range = new NotificareTimeOfDayRange(
                        new NotificareTimeOfDay(Integer.parseInt(s[0]),Integer.parseInt(s[1])),
                        new NotificareTimeOfDay(Integer.parseInt(e[0]),Integer.parseInt(e[1])));

                Notificare.shared().updateDoNotDisturb(range, new NotificareCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean aBoolean) {
                        try {
                            callbackContext.success(NotificarePushLibCordovaUtils.mapTimeOfDayRange(range));
                        } catch (JSONException e) {
                            callbackContext.error(e.getLocalizedMessage());
                        }
                    }

                    @Override
                    public void onError(NotificareError notificareError) {
                        callbackContext.error(notificareError.getLocalizedMessage());
                    }
                });
            } else {
                NotificareError notificareError = new NotificareError("invalid device dnd");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void clearDoNotDisturb(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().clearDoNotDisturb(new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callbackContext.success();
            }

            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        });
    }

    private void fetchNotificationForInboxItem(JSONArray args, CallbackContext callbackContext) {
        try {
            if (Notificare.shared().getInboxManager() != null) {
                JSONObject inboxItem = args.getJSONObject(0);
                if (inboxItem != null && inboxItem.optString("inboxId", null) != null && Notificare.shared().getInboxManager() != null) {
                    NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.optString("inboxId"));
                    if (notificareInboxItem != null) {
                        try {
                            callbackContext.success(NotificarePushLibCordovaUtils.mapNotification(notificareInboxItem.getNotification()));
                        } catch (JSONException e) {
                            NotificareError notificareError = new NotificareError("invalid inbox item");
                            callbackContext.error(notificareError.getLocalizedMessage());
                        }
                    } else {
                        NotificareError notificareError = new NotificareError("inbox item not found");
                        callbackContext.error(notificareError.getLocalizedMessage());
                    }
                } else {
                    NotificareError notificareError = new NotificareError("inbox item not found");
                    callbackContext.error(notificareError.getLocalizedMessage());
                }
            } else {
                NotificareError notificareError = new NotificareError("inbox not enabled");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void presentNotification(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject notification = args.getJSONObject(0);
            handlePresentNotification(notification);
            callbackContext.success();
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void fetchInbox(JSONArray args, CallbackContext callbackContext) {
        if (Notificare.shared().getInboxManager() != null) {
            JSONArray inbox = new JSONArray();
            try {
                for (NotificareInboxItem item : Notificare.shared().getInboxManager().getItems()) {
                    inbox.put(NotificarePushLibCordovaUtils.mapInboxItem(item));
                }
            } catch (JSONException e) {
                // ignore exceptions, just return the list as is
            }
            callbackContext.success(inbox);
        } else {
            NotificareError notificareError = new NotificareError("inbox not enabled");
            callbackContext.error(notificareError.getLocalizedMessage());
        }
    }

    private void presentInboxItem(JSONArray args, CallbackContext callbackContext) {
        try {
            if (Notificare.shared().getInboxManager() != null) {
                JSONObject inboxItem = args.getJSONObject(0);
                if (inboxItem != null && inboxItem.optString("inboxId", null) != null) {
                    NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.optString("inboxId"));
                    if (notificareInboxItem != null) {
                        Notificare.shared().openInboxItem(cordova.getActivity(), notificareInboxItem);
                        callbackContext.success();
                    }
                }
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void removeFromInbox(JSONArray args, CallbackContext callbackContext) {
        try {
            if (Notificare.shared().getInboxManager() != null) {
                JSONObject inboxItem = args.getJSONObject(0);
                if (inboxItem != null && inboxItem.optString("inboxId", null) != null) {
                    NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.optString("inboxId"));
                    if (notificareInboxItem != null) {
                        Notificare.shared().getInboxManager().removeItem(notificareInboxItem, new NotificareCallback<Boolean>() {
                            @Override
                            public void onSuccess(Boolean aBoolean) {
                                try {
                                    callbackContext.success(NotificarePushLibCordovaUtils.mapInboxItem(notificareInboxItem));
                                } catch (JSONException e) {
                                    NotificareError notificareError = new NotificareError("invalid response");
                                    callbackContext.error(notificareError.getLocalizedMessage());
                                }
                            }

                            @Override
                            public void onError(NotificareError error) {
                                callbackContext.error(error.getLocalizedMessage());
                            }
                        });
                    } else {
                        NotificareError notificareError = new NotificareError("inbox item not found");
                        callbackContext.error(notificareError.getLocalizedMessage());
                    }
                } else {
                    NotificareError notificareError = new NotificareError("inbox item not found");
                    callbackContext.error(notificareError.getLocalizedMessage());
                }
            } else {
                NotificareError notificareError = new NotificareError("inbox not enabled");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void markAsRead(JSONArray args, CallbackContext callbackContext) {
        try {
            if (Notificare.shared().getInboxManager() != null) {
                JSONObject inboxItem = args.getJSONObject(0);
                if (inboxItem != null && inboxItem.optString("inboxId", null) != null) {
                    NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(inboxItem.optString("inboxId"));
                    if (notificareInboxItem != null) {
                        Notificare.shared().getInboxManager().markItem(notificareInboxItem, new NotificareCallback<Boolean>() {
                            @Override
                            public void onSuccess(Boolean aBoolean) {
                                try {
                                    callbackContext.success(NotificarePushLibCordovaUtils.mapInboxItem(notificareInboxItem));
                                } catch (JSONException e) {
                                    NotificareError notificareError = new NotificareError("invalid response");
                                    callbackContext.error(notificareError.getLocalizedMessage());
                                }
                            }

                            @Override
                            public void onError(NotificareError error) {
                                callbackContext.error(error.getLocalizedMessage());
                            }
                        });
                    } else {
                        NotificareError notificareError = new NotificareError("inbox item not found");
                        callbackContext.error(notificareError.getLocalizedMessage());
                    }
                } else {
                    NotificareError notificareError = new NotificareError("inbox item not found");
                    callbackContext.error(notificareError.getLocalizedMessage());
                }
            } else {
                NotificareError notificareError = new NotificareError("inbox not enabled");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void clearInbox(JSONArray args, CallbackContext callbackContext) {
        if (Notificare.shared().getInboxManager() != null) {
            Notificare.shared().getInboxManager().clearInbox(new NotificareCallback<Integer>() {
                @Override
                public void onSuccess(Integer count) {
                    callbackContext.success();
                }

                @Override
                public void onError(NotificareError notificareError) {
                    callbackContext.error(notificareError.getLocalizedMessage());
                }
            });
        } else {
            NotificareError notificareError = new NotificareError("inbox not enabled");
            callbackContext.error(notificareError.getLocalizedMessage());
        }
    }

    private void fetchAssets(JSONArray args, CallbackContext callbackContext) {
        try {
            if (args.getString(0) != null  && args.getString(0) instanceof String) {
                Notificare.shared().fetchAssets(args.getString(0), new NotificareCallback<List<NotificareAsset>>() {
                    @Override
                    public void onSuccess(List<NotificareAsset> notificareAssets) {
                        JSONArray assetsArray = new JSONArray();
                        try {
                            for (NotificareAsset asset : notificareAssets) {
                                assetsArray.put(NotificarePushLibCordovaUtils.mapAsset(asset));
                            }
                        } catch (JSONException e) {
                            // ignore, send list of assets as is
                        }
                        callbackContext.success(assetsArray);
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

    private void fetchPassWithSerial(JSONArray args, CallbackContext callbackContext) {
        try {
            if (args.getString(0) != null  && args.getString(0) instanceof String) {
                Notificare.shared().fetchPass(args.getString(0), new NotificareCallback<NotificarePass>() {
                    @Override
                    public void onSuccess(NotificarePass notificarePass) {
                        try {
                            callbackContext.success(NotificarePushLibCordovaUtils.mapPass(notificarePass));
                        } catch (JSONException e) {
                            NotificareError notificareError = new NotificareError("invalid response");
                            callbackContext.error(notificareError.getLocalizedMessage());
                        }
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

    private void fetchPassWithBarcode(JSONArray args, CallbackContext callbackContext) {
        try {
            if (args.getString(0) != null  && args.getString(0) instanceof String) {
                Notificare.shared().fetchPass(args.getString(0), new NotificareCallback<NotificarePass>() {
                    @Override
                    public void onSuccess(NotificarePass notificarePass) {
                        try {
                            callbackContext.success(NotificarePushLibCordovaUtils.mapPass(notificarePass));
                        } catch (JSONException e) {
                            NotificareError notificareError = new NotificareError("invalid response");
                            callbackContext.error(notificareError.getLocalizedMessage());
                        }
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

    private void fetchProducts(JSONArray args, CallbackContext callbackContext) {
        if (Notificare.shared().getBillingManager() != null) {
            callbackContext.success(NotificarePushLibCordovaUtils.mapProducts(Notificare.shared().getBillingManager().getProducts()));
        } else {
            NotificareError notificareError = new NotificareError("billing not enabled");
            callbackContext.error(notificareError.getLocalizedMessage());
        }
    }

    private void fetchPurchasedProducts(JSONArray args, CallbackContext callbackContext) {
        if (Notificare.shared().getBillingManager() != null) {
            List<Purchase> purchases = Notificare.shared().getBillingManager().getPurchases();
            List<NotificareProduct> products = new ArrayList<>();
            for (Purchase purchase : purchases) {
                NotificareProduct product = Notificare.shared().getBillingManager().getProduct(purchase.getProductId());
                if (product != null) {
                    products.add(product);
                }
            }
            callbackContext.success(NotificarePushLibCordovaUtils.mapProducts(products));
        } else {
            NotificareError notificareError = new NotificareError("billing not enabled");
            callbackContext.error(notificareError.getLocalizedMessage());
        }
    }

    private void fetchProduct(JSONArray args, CallbackContext callbackContext) {
        try {
            if (Notificare.shared().getBillingManager() != null) {
                JSONObject product = args.getJSONObject(0);
                if (product != null && product.optString("productIdentifier", null) != null) {
                    NotificareProduct theProduct = Notificare.shared().getBillingManager().getProduct(product.optString("productIdentifier"));
                    if (theProduct != null) {
                        try {
                            callbackContext.success(NotificarePushLibCordovaUtils.mapProduct(theProduct));
                        } catch (JSONException e) {
                            NotificareError notificareError = new NotificareError("invalid response");
                            callbackContext.error(notificareError.getLocalizedMessage());
                        }
                    } else {
                        NotificareError notificareError = new NotificareError("product not found");
                        callbackContext.error(notificareError.getLocalizedMessage());
                    }
                } else {
                    NotificareError notificareError = new NotificareError("product not found");
                    callbackContext.error(notificareError.getLocalizedMessage());
                }
            } else {
                NotificareError notificareError = new NotificareError("billing not enabled");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void buyProduct(JSONArray args, CallbackContext callbackContext) {
        try {
            if (Notificare.shared().getBillingManager() != null && cordova.getActivity() != null) {
                JSONObject product = args.getJSONObject(0);
                if (product != null && product.optString("productIdentifier", null) != null) {
                    NotificareProduct notificareProduct = Notificare.shared().getBillingManager().getProduct(product.optString("identifier"));
                    final Activity activity = cordova.getActivity();
                    activity.runOnUiThread(() -> Notificare.shared().getBillingManager().launchPurchaseFlow(activity, notificareProduct, this));
                }
            }
            callbackContext.success();
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void logCustomEvent(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject data = args.getJSONObject(1);
            if (args.getString(0) != null  && args.getString(0) instanceof String) {
                Notificare.shared().getEventLogger().logCustomEvent(args.getString(0), data, new NotificareCallback<Boolean>() {
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

    private void logOpenNotification(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject notification = args.getJSONObject(0);
            if (notification != null && notification.optString("id", null) != null) {
                Notificare.shared().getEventLogger().logOpenNotification(notification.optString("id"), new NotificareCallback<Boolean>() {
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
                NotificareError notificareError = new NotificareError("invalid notification");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void logInfluencedNotification(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject notification = args.getJSONObject(0);
            if (notification != null && notification.optString("id", null) != null) {
                Notificare.shared().getEventLogger().logOpenNotificationInfluenced(notification.optString("id"), new NotificareCallback<Boolean>() {
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
                NotificareError notificareError = new NotificareError("invalid notification");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void doCloudHostOperation(JSONArray args, CallbackContext callbackContext) {
        try {

            if ((args.getString(0) != null  && args.getString(0) instanceof String) && (args.getString(1) != null  && args.getString(1) instanceof String)) {
                JSONObject body = args.getJSONObject(2);
                JSONObject params = args.getJSONObject(3);
                JSONObject headers = args.getJSONObject(4);

                Map<String, String> paramsMap = new HashMap<>();
                if (params != null) {
                    while (params.keys().hasNext()) {
                        String key = params.keys().next();
                        paramsMap.put(key, params.optString(key, null));
                    }
                }
                Map<String, String> headersMap = new HashMap<>();
                if (headers != null) {
                    while (headers.keys().hasNext()) {
                        String key = headers.keys().next();
                        headersMap.put(key, headers.optString(key, null));
                    }
                }
                Notificare.shared().doCloudRequest(args.getString(0), args.getString(1), paramsMap, body, headersMap, new NotificareCallback<JSONObject>() {
                    @Override
                    public void onSuccess(JSONObject jsonObject) {
                        callbackContext.success(jsonObject);
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

    private void createAccount(JSONArray args, CallbackContext callbackContext) {
        try {

            if ((args.getString(0) != null  && args.getString(0) instanceof String) &&
                    (args.getString(1) != null  && args.getString(1) instanceof String) &&
                    (args.getString(2) != null  && args.getString(2) instanceof String)) {

                String email = args.getString(0);
                String name = args.getString(1);
                String password = args.getString(2);

                Notificare.shared().createAccount(email, password, name, new NotificareCallback<Boolean>() {
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

    private void validateAccount(JSONArray args, CallbackContext callbackContext) {
        try {

            if (args.getString(0) != null  && args.getString(0) instanceof String) {

                Notificare.shared().validateUser(args.getString(0), new NotificareCallback<Boolean>() {
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

    private void resetPassword(JSONArray args, CallbackContext callbackContext) {
        try {

            if ((args.getString(0) != null  && args.getString(0) instanceof String) &&
                    (args.getString(1) != null  && args.getString(1) instanceof String)) {

                Notificare.shared().resetPassword(args.getString(0), args.getString(1), new NotificareCallback<Boolean>() {
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

    private void sendPassword(JSONArray args, CallbackContext callbackContext) {
        try {

            if (args.getString(0) != null  && args.getString(0) instanceof String) {

                Notificare.shared().sendPassword(args.getString(0), new NotificareCallback<Boolean>() {
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

    private void login(JSONArray args, CallbackContext callbackContext) {
        try {

            if ((args.getString(0) != null  && args.getString(0) instanceof String) &&
                    (args.getString(1) != null  && args.getString(1) instanceof String)) {

                Notificare.shared().userLogin(args.getString(0), args.getString(1), new NotificareCallback<Boolean>() {
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

    private void logout(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().userLogout(new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callbackContext.success();
            }

            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        });
    }

    private void isLoggedIn(JSONArray args, CallbackContext callbackContext) {
        callbackContext.success((Notificare.shared().isLoggedIn()) ? 1 : 0);
    }

    private void generateAccessToken(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().generateAccessToken(new NotificareCallback<NotificareUser>() {
            @Override
            public void onSuccess(NotificareUser notificareUser) {
                try {
                    callbackContext.success(NotificarePushLibCordovaUtils.mapUser(notificareUser));
                } catch (JSONException e) {
                    NotificareError notificareError = new NotificareError("invalid response");
                    callbackContext.error(notificareError.getLocalizedMessage());
                }
            }

            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        });
    }

    private void changePassword(JSONArray args, CallbackContext callbackContext) {
        try {

            if (args.getString(0) != null  && args.getString(0) instanceof String) {

                Notificare.shared().changePassword(args.getString(0), new NotificareCallback<Boolean>() {
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

    private void fetchAccountDetails(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().fetchUserDetails(new NotificareCallback<NotificareUser>() {
            @Override
            public void onSuccess(NotificareUser notificareUser) {
                try {
                    callbackContext.success(NotificarePushLibCordovaUtils.mapUser(notificareUser));
                } catch (JSONException e) {
                    NotificareError notificareError = new NotificareError("invalid response");
                    callbackContext.error(notificareError.getLocalizedMessage());
                }
            }

            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        });
    }

    private void fetchUserPreferences(JSONArray args, CallbackContext callbackContext) {
        Notificare.shared().fetchUserPreferences(new NotificareCallback<List<NotificareUserPreference>>() {
            @Override
            public void onSuccess(List<NotificareUserPreference> notificareUserPreferences) {
                JSONArray preferencesArray = new JSONArray();
                try {
                    for (NotificareUserPreference preference : notificareUserPreferences) {
                        preferencesArray.put(NotificarePushLibCordovaUtils.mapUserPreference(preference));
                    }
                } catch (JSONException e) {
                    // ignore, send list as is
                }
                callbackContext.success(preferencesArray);
            }

            @Override
            public void onError(NotificareError notificareError) {
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        });
    }

    private void addSegmentToUserPreference(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject segment = args.getJSONObject(0);
            JSONObject preference = args.getJSONObject(1);
            if (segment != null && preference != null) {
                NotificareUserSegment userSegment = NotificarePushLibCordovaUtils.createUserSegment(segment);
                NotificareUserPreference userPreference = NotificarePushLibCordovaUtils.createUserPreference(preference);
                if (userSegment != null && userPreference != null) {
                    Notificare.shared().userSegmentAddToUserPreference(userSegment, userPreference, new NotificareCallback<Boolean>() {
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
            } else {
                NotificareError notificareError = new NotificareError("invalid parameters");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void removeSegmentFromUserPreference(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject segment = args.getJSONObject(0);
            JSONObject preference = args.getJSONObject(1);
            if (segment != null && preference != null) {
                NotificareUserSegment userSegment = NotificarePushLibCordovaUtils.createUserSegment(segment);
                NotificareUserPreference userPreference = NotificarePushLibCordovaUtils.createUserPreference(preference);
                if (userSegment != null && userPreference != null) {
                    Notificare.shared().userSegmentRemoveFromUserPreference(userSegment, userPreference, new NotificareCallback<Boolean>() {
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
            } else {
                NotificareError notificareError = new NotificareError("invalid parameters");
                callbackContext.error(notificareError.getLocalizedMessage());
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    private void startScannableSession(JSONArray args, CallbackContext callbackContext) {
        if (cordova.getActivity() != null) {
            Notificare.shared().startScannableActivity(cordova.getActivity(), SCANNABLE_REQUEST_CODE);
        }
        callbackContext.success();
    }

    private void presentScannable(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject scannable = args.getJSONObject(0);
            if (scannable != null && scannable.optJSONObject("notification") != null) {
                handlePresentNotification(scannable.optJSONObject("notification"));
            }
        } catch (JSONException e) {
            callbackContext.error(e.getLocalizedMessage());
        }
    }

    /************************************************************************************************************************************************************
     * Notificare Events
     ************************************************************************************************************************************************************/

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

    /************************************************************************************************************************************************************
     * Notificare Helper Methods
     ************************************************************************************************************************************************************/

    /**
     * Present Notification helper
     * @param notification
     */
    private void handlePresentNotification(JSONObject notification) {
        if (notification != null && notification.has("id")) {
            String notificationId = notification.optString("id");
            if (notification.has("inboxItemId") && notification.optString("inboxItemId", null) != null && Notificare.shared().getInboxManager() != null) {
                // This is an item opened with inboxItemId, so coming from NotificationManager open
                NotificareInboxItem notificareInboxItem = Notificare.shared().getInboxManager().getItem(notification.optString("inboxItemId"));
                if (notificareInboxItem != null) {
                    Notificare.shared().openInboxItem(cordova.getActivity(), notificareInboxItem);
                }
            } else if (notificationId != null && !notificationId.isEmpty()) {
                // We have a notificationId, let's see if we can create a notification from the payload, otherwise fetch from API
                NotificareNotification notificareNotification = NotificarePushLibCordovaUtils.createNotification(notification);
                if (notificareNotification != null) {
                    Notificare.shared().openNotification(cordova.getActivity(), notificareNotification);
                } else {
                    Notificare.shared().fetchNotification(notificationId, new NotificareCallback<NotificareNotification>() {
                        @Override
                        public void onSuccess(NotificareNotification notificareNotification) {
                            Notificare.shared().openNotification(cordova.getActivity(), notificareNotification);
                        }

                        @Override
                        public void onError(NotificareError notificareError) {
                            Log.e(TAG, "error fetching notification: " + notificareError.getMessage());
                        }
                    });
                }
            }
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

    /************************************************************************************************************************************************************
     * Notificare Interfaces
     ************************************************************************************************************************************************************/

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
