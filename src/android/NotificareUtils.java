package re.notifica.cordova;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;

import re.notifica.Notificare;
import re.notifica.model.NotificareAction;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareAsset;
import re.notifica.model.NotificareAttachment;
import re.notifica.model.NotificareBeacon;
import re.notifica.model.NotificareContent;
import re.notifica.model.NotificareDevice;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificarePass;
import re.notifica.model.NotificarePassRedemption;
import re.notifica.model.NotificareProduct;
import re.notifica.model.NotificareRegion;
import re.notifica.model.NotificareScannable;
import re.notifica.model.NotificareTimeOfDayRange;
import re.notifica.model.NotificareUser;
import re.notifica.model.NotificareUserPreference;
import re.notifica.model.NotificareUserPreferenceOption;
import re.notifica.model.NotificareUserSegment;
import re.notifica.util.ISODateFormatter;

public class NotificareUtils {

    /**
     * Map application info
     * @param applicationInfo
     * @return
     */
    public static JSONObject mapApplicationInfo(NotificareApplicationInfo applicationInfo) throws JSONException {
        JSONObject infoMap = new JSONObject();
        infoMap.put("id", applicationInfo.getId());
        infoMap.put("name", applicationInfo.getName());
        JSONObject servicesMap = new JSONObject();
        for (String key : applicationInfo.getServices().keySet()) {
            servicesMap.put(key, applicationInfo.getServices().get(key));
        }
        infoMap.put("services", servicesMap);

        if (applicationInfo.getInboxConfig() != null) {
            JSONObject inboxConfigMap = new JSONObject();
            inboxConfigMap.put("autoBadge", applicationInfo.getInboxConfig().getAutoBadge());
            inboxConfigMap.put("useInbox", applicationInfo.getInboxConfig().getUseInbox());
            infoMap.put("inboxConfig", inboxConfigMap);
        }

        if (applicationInfo.getRegionConfig() != null) {
            JSONObject regionConfigMap = new JSONObject();
            regionConfigMap.put("proximityUUID", applicationInfo.getRegionConfig().getProximityUUID());
            infoMap.put("regionConfig", regionConfigMap);
        }


        JSONArray userDataFieldsArray = new JSONArray();
        for (String key : applicationInfo.getUserDataFields().keySet()){
            JSONObject userDataFieldMap = new JSONObject();
            userDataFieldMap.put("key", key);
            userDataFieldMap.put("label", applicationInfo.getUserDataFields().get(key).getLabel());
            userDataFieldsArray.put(userDataFieldMap);
        }
        infoMap.put("userDataFields", userDataFieldsArray);

        return infoMap;
    }

    /**
     * Map a device
     * @param device
     * @return
     */
    public static JSONObject mapDevice(NotificareDevice device) throws JSONException {
        JSONObject deviceMap = new JSONObject();
        deviceMap.put("deviceID", device.getDeviceId());
        deviceMap.put("userID", device.getUserId());
        deviceMap.put("userName", device.getUserName());
        deviceMap.put("timezone", device.getTimeZoneOffset());
        deviceMap.put("osVersion", device.getOsVersion());
        deviceMap.put("sdkVersion", device.getSdkVersion());
        deviceMap.put("appVersion", device.getAppVersion());
        deviceMap.put("countryCode", device.getCountry());
        deviceMap.put("language", device.getLanguage());
        deviceMap.put("region", device.getRegion());
        deviceMap.put("transport", device.getTransport());
        if (!Double.isNaN(device.getLatitude())) {
            deviceMap.put("latitude", device.getLatitude());
        }
        if (!Double.isNaN(device.getLongitude())) {
            deviceMap.put("longitude", device.getLongitude());
        }
        if (!Double.isNaN(device.getAltitude())) {
            deviceMap.put("altitude", device.getAltitude());
        }
        if (!Double.isNaN(device.getSpeed())) {
            deviceMap.put("speed", device.getSpeed());
        }
        if (!Double.isNaN(device.getCourse())) {
            deviceMap.put("course", device.getCourse());
        }
        if (device.getLastActive() != null) {
            deviceMap.put("lastRegistered", ISODateFormatter.format(device.getLastActive()));
        }
        deviceMap.put("locationServicesAuthStatus", device.getLocationServicesAuthStatus());
        deviceMap.put("registeredForNotifications", Notificare.shared().isNotificationsEnabled());
        deviceMap.put("allowedLocationServices", Notificare.shared().isLocationUpdatesEnabled());
        deviceMap.put("allowedUI", device.getAllowedUI());
        deviceMap.put("backgroundAppRefresh", true);
        deviceMap.put("bluetoothON", device.getBluetoothEnabled());
        return deviceMap;
    }

    /**
     * Map a notification
     * @param notification
     * @return
     */
    public static JSONObject mapNotification(NotificareNotification notification) throws JSONException {
        JSONObject notificationMap = new JSONObject();
        notificationMap.put("id", notification.getNotificationId());
        notificationMap.put("message", notification.getMessage());
        notificationMap.put("title", notification.getTitle());
        notificationMap.put("subtitle", notification.getSubtitle());
        notificationMap.put("type", notification.getType());
        notificationMap.put("time", ISODateFormatter.format(notification.getTime()));
        if (notification.getExtra() != null) {
            JSONObject extraMap = new JSONObject();
            for (HashMap.Entry<String, String> prop : notification.getExtra().entrySet()) {
                extraMap.put(prop.getKey(), prop.getValue());
            }
            notificationMap.put("extra", extraMap);
        }
        if (notification.getContent().size() > 0) {
            JSONArray contentArray = new JSONArray();
            for (NotificareContent c : notification.getContent()) {
                JSONObject contentMap = new JSONObject();
                contentMap.put("type", c.getType());
                contentMap.put("data", c.getData().toString());
                contentArray.put(contentMap);
            }
            notificationMap.put("content", contentArray);
        }
        if (notification.getAttachments().size() > 0) {
            JSONArray attachmentsArray = new JSONArray();
            for (NotificareAttachment a : notification.getAttachments()) {
                JSONObject attachmentsMap = new JSONObject();
                attachmentsMap.put("mimeType", a.getMimeType());
                attachmentsMap.put("uri", a.getUri());
                attachmentsArray.put(attachmentsMap);
            }
            notificationMap.put("attachments", attachmentsArray);
        }
        if (notification.getActions().size() > 0) {
            JSONArray actionsArray = new JSONArray();
            for (NotificareAction a : notification.getActions()) {
                JSONObject actionMap = new JSONObject();
                actionMap.put("label", a.getLabel());
                actionMap.put("type", a.getType());
                actionMap.put("target", a.getTarget());
                actionMap.put("camera", a.getCamera());
                actionMap.put("keyboard", a.getKeyboard());
                actionsArray.put(actionMap);
            }
            notificationMap.put("actions", actionsArray);
        }
        notificationMap.put("partial", notification.isPartial());
        return notificationMap;
    }

    /**
     * Create a notification instance from a map
     * @param notificationMap
     * @return
     */
    public static NotificareNotification createNotification(JSONObject notificationMap) {
        if (notificationMap.optBoolean("partial", false)) {
            return null;
        } else {
            try {
                JSONObject json = new JSONObject(notificationMap.toString());
                if (notificationMap.has("id")) {
                    json.put("_id", notificationMap.getString("id"));
                }
                return new NotificareNotification(json);
            } catch (JSONException e) {
                return null;
            }
        }
    }

    /**
     * Map an asset
     * @param asset
     * @return
     */
    public static JSONObject mapAsset(NotificareAsset asset) throws JSONException {
        JSONObject assetMap = new JSONObject();
        assetMap.put("assetTitle", asset.getTitle());
        assetMap.put("assetDescription", asset.getDescription());
        assetMap.put("assetUrl", asset.getUrl().toString());

        JSONObject metaMap = new JSONObject();
        metaMap.put("originalFileName", asset.getOriginalFileName());
        metaMap.put("key", asset.getKey());
        metaMap.put("contentType", asset.getContentType());
        metaMap.put("contentLength", asset.getContentLength());
        assetMap.put("assetMetaData", metaMap);

        JSONObject buttonMap = new JSONObject();
        buttonMap.put("label", asset.getButtonLabel());
        buttonMap.put("action", asset.getButtonAction());
        assetMap.put("assetButton", buttonMap);
        return assetMap;
    }

    /**
     * Map time of day range
     * @param notificareTimeOfDayRange
     * @return
     */
    public static JSONObject mapTimeOfDayRange(NotificareTimeOfDayRange notificareTimeOfDayRange) throws JSONException {
        JSONObject timeOfDayRangeMap = new JSONObject();
        timeOfDayRangeMap.put("start", notificareTimeOfDayRange.getStart().toString());
        timeOfDayRangeMap.put("end", notificareTimeOfDayRange.getEnd().toString());
        return timeOfDayRangeMap;
    }

    /**
     * Map a region
     * @param region
     * @return
     */
    public static JSONObject mapRegion(NotificareRegion region) throws JSONException {
        JSONObject regionMap = new JSONObject();
        regionMap.put("id", region.getRegionId());
        regionMap.put("regionId", region.getRegionId());
        regionMap.put("regionName", region.getName());
        regionMap.put("regionMajor", region.getMajor());
        if (region.getGeometry() != null) {
            regionMap.put("regionGeometry", region.getGeometry().toJSONObject());
        }
        if (region.getAdvancedGeometry() != null) {
            regionMap.put("regionAdvancedGeometry", region.getAdvancedGeometry().toJSONObject());
        }
        regionMap.put("regionDistance", region.getDistance());
        regionMap.put("regionTimezone", region.getTimezone());
        return regionMap;
    }

    /**
     * Map a beacon
     * @param beacon
     * @return
     */
    public static JSONObject mapBeacon(NotificareBeacon beacon) throws JSONException {
        JSONObject beaconMap = new JSONObject();
        beaconMap.put("beaconId", beacon.getBeaconId());
        beaconMap.put("beaconName", beacon.getName());
        beaconMap.put("beaconRegion", beacon.getRegionId());
        beaconMap.put("beaconUUID", Notificare.shared().getApplicationInfo().getRegionConfig().getProximityUUID());
        beaconMap.put("beaconMajor", beacon.getMajor());
        beaconMap.put("beaconMinor", beacon.getMinor());
        beaconMap.put("beaconTriggers", beacon.getTriggers());
        return beaconMap;
    }

    /**
     * Map a region for ranging beacons
     * @param beacon
     * @return
     * @throws JSONException
     */
    public static JSONObject mapRegionForBeacon(NotificareBeacon beacon) throws JSONException {
        JSONObject beaconMap = new JSONObject();
        beaconMap.put("beaconId", beacon.getRegionId());
        beaconMap.put("beaconName", beacon.getRegion().getName());
        beaconMap.put("beaconRegion", beacon.getRegionId());
        beaconMap.put("beaconUUID", Notificare.shared().getApplicationInfo().getRegionConfig().getProximityUUID());
        beaconMap.put("beaconMajor", beacon.getMajor());
        return beaconMap;
    }

    /**
     * Map a pass
     * @param pass
     * @return
     */
    public static JSONObject mapPass(NotificarePass pass) throws JSONException {
        JSONObject passMap = new JSONObject();
        passMap.put("passbook", pass.getPassbook());
        passMap.put("serial", pass.getSerial());
        if (pass.getRedeem() == NotificarePass.Redeem.ALWAYS) {
            passMap.put("redeem", "always");
        } else if (pass.getRedeem() == NotificarePass.Redeem.LIMIT) {
            passMap.put("redeem", "limit");
        } else if (pass.getRedeem() == NotificarePass.Redeem.ONCE) {
            passMap.put("redeem", "once");
        }
        passMap.put("token", pass.getToken());
        if (pass.getData() != null) {
            passMap.put("data", pass.getData());
        }
        passMap.put("date", ISODateFormatter.format(pass.getDate()));
        passMap.put("limit", pass.getLimit());
        JSONArray redeemHistory = new JSONArray();
        for (NotificarePassRedemption redemption : pass.getRedeemHistory()) {
            JSONObject redemptionMap = new JSONObject();
            redemptionMap.put("comments", redemption.getComments());
            redemptionMap.put("date", ISODateFormatter.format(redemption.getDate()));
            redeemHistory.put(redemptionMap);
        }
        passMap.put("redeemHistory", redeemHistory);
        return passMap;
    }

    /**
     * Map a product
     * @param product
     * @return
     */
    public static JSONObject mapProduct(NotificareProduct product) throws JSONException {
        JSONObject productItemMap = new JSONObject();
        productItemMap.put("productType", product.getType());
        productItemMap.put("productIdentifier", product.getIdentifier());
        productItemMap.put("productName", product.getName());
        productItemMap.put("productDescription", product.getSkuDetails().getDescription());
        productItemMap.put("productPrice", product.getSkuDetails().getPrice());
        productItemMap.put("productCurrency", product.getSkuDetails().getPriceCurrencyCode());
        productItemMap.put("productDate", ISODateFormatter.format(product.getDate()));
        productItemMap.put("productActive", true);
        return productItemMap;
    }

    /**
     * Map products
     * @param products
     * @return
     */
    public static JSONArray mapProducts(List<NotificareProduct> products) {
        JSONArray productList = new JSONArray();
        try {
            for (NotificareProduct product : products) {
                productList.put(mapProduct(product));
            }
        } catch (JSONException e) {
            // ignore, return list as is
        }
        return productList;
    }

    /**
     * Map inbox item
     * @param notificareInboxItem
     * @return
     */
    public static JSONObject mapInboxItem(NotificareInboxItem notificareInboxItem) throws JSONException {
        JSONObject inboxItemMap = new JSONObject();
        inboxItemMap.put("inboxId", notificareInboxItem.getItemId());
        inboxItemMap.put("notification", notificareInboxItem.getNotification().getNotificationId());
        inboxItemMap.put("message", notificareInboxItem.getNotification().getMessage());
        inboxItemMap.put("title", notificareInboxItem.getTitle());
        inboxItemMap.put("subtitle", notificareInboxItem.getSubtitle());
        if (notificareInboxItem.getAttachment() != null) {
            JSONObject attachmentsMap = new JSONObject();
            attachmentsMap.put("mimeType", notificareInboxItem.getAttachment().getMimeType());
            attachmentsMap.put("uri", notificareInboxItem.getAttachment().getUri());
            inboxItemMap.put("attachment", attachmentsMap);
        }
        if (notificareInboxItem.getExtra() != null) {
            JSONObject extraMap = new JSONObject();
            for (HashMap.Entry<String, String> prop : notificareInboxItem.getExtra().entrySet()) {
                extraMap.put(prop.getKey(), prop.getValue());
            }
            inboxItemMap.put("extra", extraMap);
        }
        inboxItemMap.put("time", ISODateFormatter.format(notificareInboxItem.getTimestamp()));
        inboxItemMap.put("opened", notificareInboxItem.getStatus());
        return inboxItemMap;
    }

    /**
     * Map user
     * @param user
     * @return
     */
    public static JSONObject mapUser(NotificareUser user) throws JSONException {
        JSONObject userMap = new JSONObject();
        userMap.put("userID", user.getUserId());
        userMap.put("userName", user.getUserName());
        userMap.put("segments", user.getSegments());
        return userMap;
    }

    /**
     * Map user segment
     * @param userSegment
     * @return
     */
    public static JSONObject mapUserSegment(NotificareUserSegment userSegment) throws JSONException {
        JSONObject userSegmentMap = new JSONObject();
        userSegmentMap.put("segmentId", userSegment.getId());
        userSegmentMap.put("segmentLabel", userSegment.getName());
        return userSegmentMap;
    }

    /**
     * Map user segments
     * @param userSegments
     * @return
     */
    public static JSONArray mapUserSegments(List<NotificareUserSegment> userSegments) {
        JSONArray userSegmentsArray = new JSONArray();
        try {
            for (NotificareUserSegment userSegment : userSegments) {
                userSegmentsArray.put(mapUserSegment(userSegment));
            }
        } catch (JSONException e) {
            // ignore, send list as is
        }
        return userSegmentsArray;
    }

    /**
     * Create user segment from map
     * @param userSegmentMap
     * @return
     */
    public static NotificareUserSegment createUserSegment(JSONObject userSegmentMap) {
        try {
            JSONObject json = new JSONObject();
            json.put("_id", userSegmentMap.get("segmentId"));
            json.put("name", userSegmentMap.get("segmentLabel"));
            return new NotificareUserSegment(json);
        } catch (JSONException e) {
            return null;
        }
    }

    /**
     * Map user preferences
     * @param userPreference
     * @return
     */
    public static JSONObject mapUserPreference(NotificareUserPreference userPreference) throws JSONException {
       JSONObject userPreferenceMap = new JSONObject();
        userPreferenceMap.put("preferenceId", userPreference.getId());
        userPreferenceMap.put("preferenceLabel", userPreference.getLabel());
        userPreferenceMap.put("preferenceType", userPreference.getPreferenceType());
        JSONArray options = new JSONArray();
        for (NotificareUserPreferenceOption option : userPreference.getPreferenceOptions()) {
            JSONObject optionMap = new JSONObject();
            optionMap.put("segmentId", option.getUserSegmentId());
            optionMap.put("segmentLabel", option.getLabel());
            optionMap.put("selected", option.isSelected());
            options.put(optionMap);
        }
        userPreferenceMap.put("preferenceOptions", options);
        return userPreferenceMap;
    }

    /**
     * Create user preference from map
     * @param userPreferenceMap
     * @return
     */
    public static NotificareUserPreference createUserPreference(JSONObject userPreferenceMap) {
        try {
            JSONObject json = new JSONObject();
            json.put("_id", userPreferenceMap.get("preferenceId"));
            json.put("label", userPreferenceMap.get("preferenceLabel"));
            json.put("preferenceType", userPreferenceMap.get("preferenceType"));

            JSONArray originalUserPreferenceOptions = userPreferenceMap.getJSONArray("preferenceOptions");
            JSONArray convertedUserPreferenceOptions = new JSONArray();
            for (int i = 0; i < originalUserPreferenceOptions.length(); i++) {
                JSONObject optionJson = originalUserPreferenceOptions.getJSONObject(i);

                JSONObject destinationJson = new JSONObject();
                destinationJson.put("label", optionJson.getString("segmentLabel"));
                destinationJson.put("userSegment", optionJson.getString("segmentId"));
                destinationJson.put("selected", optionJson.getBoolean("selected"));

                convertedUserPreferenceOptions.put(destinationJson);
            }

            json.put("preferenceOptions", convertedUserPreferenceOptions);
            json.put("indexPosition", -1);
            return new NotificareUserPreference(json);
        } catch (JSONException e) {
            return null;
        }
    }

    /**
     * Map scannable
     * @param scannable
     * @return
     */
    public static JSONObject mapScannable(NotificareScannable scannable) throws JSONException {
        JSONObject result = new JSONObject();
        result.put("scannableId", scannable.getScannableId());
        result.put("name", scannable.getName());
        result.put("type", scannable.getType());
        result.put("tag", scannable.getTag());
        result.put("data", scannable.getData());
        result.put("notification", mapNotification(scannable.getNotification()));
        return result;
    }


}
