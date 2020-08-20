var channel = require('cordova/channel'),
    exec = require('cordova/exec');

/**
 * Event emitter class
 * @returns {EventEmitter}
 */
function EventEmitter() {
    this._listeners = {}
    this._mutators = {}
}

EventEmitter.prototype.on = function(event, fn) {
    (this._listeners[event] = this._listeners[event] || []).push(fn);
    return this;
};

EventEmitter.prototype.mutate = function(event, fn) {
    this._mutators[event] = fn;
    return this;
};

EventEmitter.prototype.once = function(event, fn) {
    var self = this;
    return self.on(event, listener);

    function listener() {
        fn.apply(this, [].slice.call(arguments));
        self.remove(event, listener);
    }
};

EventEmitter.prototype.emit = function(event) {
    var list = this._listeners[event] || [],
        args = [].slice.call(arguments, 1),
        mutator = this._mutators[event] || function() {
            return [].slice.call(arguments);
        };

    args = mutator.apply(null, args);

    list.forEach(function(fn) {
        fn.apply(null, args);
    });
};

EventEmitter.prototype.listeners = function(event) {
    return this._listeners[event] || [];
};

EventEmitter.prototype.removeListener = EventEmitter.prototype.remove = function(event, fn) {
    var tmp = this._listeners[event] || [];
    typeof fn === 'function' ? tmp.indexOf(fn) > -1 && tmp.splice(tmp.indexOf(fn), 1) : delete this._listeners[event];
};

function inherit(proto) {
    function F() {}
    F.prototype = proto;
    return new F();
}

/**
 * Notificare Cordova plugin
 * @base {EventEmitter}
 * @type {Notificare}
 *
 * A singleton instance is automatically created by adding the plugin to your project
 * This singleton can be accessed as global var Notificare in JavaScript
 *
 * <code>
 *
 * </code>
 */
function Notificare() {
    EventEmitter.apply(this, arguments);
    console.log('Notificare Plugin created on JS side');
}

Notificare.prototype = inherit(EventEmitter.prototype);

Notificare.prototype.launch = function() {
    exec(this.successCallback.bind(this), this.errorCallback.bind(this), 'NotificarePushLibCordova', 'launch', []);
};

Notificare.prototype.unlaunch = function () {
    exec(this.successCallback.bind(this), this.errorCallback.bind(this), 'NotificarePushLibCordova', 'unlaunch', []);
}

Notificare.prototype.registerForNotifications = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'registerForNotifications', []);
};

Notificare.prototype.unregisterForNotifications = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'unregisterForNotifications', []);
};

Notificare.prototype.setAuthorizationOptions = function(options, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'setAuthorizationOptions', [options]);
};

Notificare.prototype.setPresentationOptions = function(options, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'setPresentationOptions', [options]);
};

Notificare.prototype.setCategoryOptions = function(options, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'setCategoryOptions', [options]);
};

Notificare.prototype.isRemoteNotificationsEnabled = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'isRemoteNotificationsEnabled', []);
};

Notificare.prototype.isAllowedUIEnabled = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'isAllowedUIEnabled', []);
};

Notificare.prototype.isNotificationFromNotificare = function(notification, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'isNotificationFromNotificare', [notification]);
};

Notificare.prototype.fetchNotificationSettings = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchNotificationSettings', []);
};

Notificare.prototype.startLocationUpdates = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'startLocationUpdates', []);
};

Notificare.prototype.stopLocationUpdates = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'stopLocationUpdates', []);
};

Notificare.prototype.clearLocation = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'clearLocation', []);
};

Notificare.prototype.isLocationServicesEnabled = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'isLocationServicesEnabled', []);
};

Notificare.prototype.enableBeacons = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'enableBeacons', []);
};

Notificare.prototype.disableBeacons = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'disableBeacons', []);
};

Notificare.prototype.registerDevice = function(userID, userName, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'registerDevice', [userID, userName]);
};

Notificare.prototype.fetchDevice = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchDevice', []);
};

Notificare.prototype.fetchPreferredLanguage = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchPreferredLanguage', []);
};

Notificare.prototype.updatePreferredLanguage = function(preferredLanguage, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'updatePreferredLanguage', [preferredLanguage]);
};

Notificare.prototype.fetchTags = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchTags', []);
};

Notificare.prototype.addTag = function(tag, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'addTag', [tag]);
};

Notificare.prototype.addTags = function(tags, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'addTags', [tags]);
};

Notificare.prototype.removeTag = function(tag, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'removeTag', [tag]);
};

Notificare.prototype.removeTags = function(tags, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'removeTags', [tags]);
};

Notificare.prototype.clearTags = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'clearTags', []);
};

Notificare.prototype.fetchUserData = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchUserData', []);
};

Notificare.prototype.updateUserData = function(userData, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'updateUserData', [userData]);
};

Notificare.prototype.fetchDoNotDisturb = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchDoNotDisturb', []);
};

Notificare.prototype.updateDoNotDisturb = function(dnd, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'updateDoNotDisturb', [dnd]);
};

Notificare.prototype.clearDoNotDisturb = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'clearDoNotDisturb', []);
};

Notificare.prototype.fetchNotification = function(notification, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchNotification', [notification]);
};

Notificare.prototype.fetchNotificationForInboxItem = function(inboxItem, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchNotificationForInboxItem', [inboxItem]);
};

Notificare.prototype.presentNotification = function(notification, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'presentNotification', [notification]);
};

Notificare.prototype.fetchInbox = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchInbox', []);
};

Notificare.prototype.presentInboxItem = function(inboxItem, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'presentInboxItem', [inboxItem]);
};

Notificare.prototype.removeFromInbox = function(inboxItem, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'removeFromInbox', [inboxItem]);
};

Notificare.prototype.markAsRead = function(inboxItem, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'markAsRead', [inboxItem]);
};

Notificare.prototype.markAllAsRead = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'markAllAsRead', []);
};

Notificare.prototype.clearInbox = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'clearInbox', []);
};

Notificare.prototype.fetchAssets = function(group, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchAssets', [group]);
};

Notificare.prototype.fetchPassWithSerial = function(serial, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchPassWithSerial', [serial]);
};

Notificare.prototype.fetchPassWithBarcode = function(barcode, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchPassWithBarcode', [barcode]);
};

Notificare.prototype.fetchProducts = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchProducts', []);
};

Notificare.prototype.fetchPurchasedProducts = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchPurchasedProducts', []);
};

Notificare.prototype.fetchProduct = function(product, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchProduct', [product]);
};

Notificare.prototype.buyProduct = function(product, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'buyProduct', [product]);
};

Notificare.prototype.enableBilling = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'enableBilling', []);
};

Notificare.prototype.disableBilling = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'disableBilling', []);
};

Notificare.prototype.logCustomEvent = function(event, data, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'logCustomEvent', [event, data]);
};

Notificare.prototype.logOpenNotification = function(notification, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'logOpenNotification', [notification]);
};

Notificare.prototype.logInfluencedNotification = function(notification, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'logInfluencedNotification', [notification]);
};

Notificare.prototype.logReceiveNotification = function(notification, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'logReceiveNotification', [notification]);
};

Notificare.prototype.doCloudHostOperation = function(verb, path, headers, params, body, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'doCloudHostOperation', [verb, path, headers, params, body]);
};

Notificare.prototype.createAccount = function(email, name, password, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'createAccount', [email, name, password]);
};

Notificare.prototype.validateAccount = function(token, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'validateAccount', [token]);
};

Notificare.prototype.resetPassword = function(password, token, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'resetPassword', [password, token]);
};

Notificare.prototype.sendPassword = function(email, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'sendPassword', [email]);
};

Notificare.prototype.login = function(email, password, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'login', [email, password]);
};

Notificare.prototype.logout = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'logout', []);
};

Notificare.prototype.isLoggedIn = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'isLoggedIn', []);
};

Notificare.prototype.generateAccessToken = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'generateAccessToken', []);
};

Notificare.prototype.changePassword = function(password, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'changePassword', [password]);
};

Notificare.prototype.fetchAccountDetails = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchAccountDetails', []);
};

Notificare.prototype.fetchUserPreferences = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'fetchUserPreferences', []);
};

Notificare.prototype.addSegmentToUserPreference = function(segment, preference, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'addSegmentToUserPreference', [segment, preference]);
};

Notificare.prototype.removeSegmentFromUserPreference = function(segment, preference, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'removeSegmentFromUserPreference', [segment, preference]);
};

Notificare.prototype.startScannableSession = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'startScannableSession', []);
};

Notificare.prototype.presentScannable = function(scannable, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'presentScannable', [scannable]);
};

Notificare.prototype.requestAlwaysAuthorizationForLocationUpdates = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'requestAlwaysAuthorizationForLocationUpdates', []);
};

Notificare.prototype.requestTemporaryFullAccuracyAuthorization = function(purposeKey, success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'requestTemporaryFullAccuracyAuthorization', [purposeKey]);
};

Notificare.prototype.successCallback = function(payload) {
    if (payload && payload.type) {
        this.emit(payload.type, payload.data);
    }
};

Notificare.prototype.errorCallback = function(payload) {
    if (payload && payload.type) {
        this.emit(payload.type + 'Error', new Error(payload.message));
    }
};

module.exports = new Notificare();
