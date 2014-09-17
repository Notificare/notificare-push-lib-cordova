/**
 * Notificare Cordova Plugin
 * 
 * @author Joris Verbogt <joris@notifica.re>
 */

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
}

Notificare.prototype = inherit(EventEmitter.prototype);

Notificare.prototype.registerDevice = function(deviceId, userId, userName, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'registerDevice', [deviceId, userId, userName]);
};

Notificare.prototype.enableNotifications = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'enableNotifications', []);
};

Notificare.prototype.enableLocationUpdates = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'enableLocationUpdates', []);
};

Notificare.prototype.disableNotifications = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'disableNotifications', []);
};

Notificare.prototype.disableLocationUpdates = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'disableLocationUpdates', []);
};

Notificare.prototype.addDeviceTags = function(tags, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'addDeviceTags', [tags]);
};

Notificare.prototype.removeDeviceTag = function(tag, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'removeDeviceTag', [tag]);
};

Notificare.prototype.clearDeviceTags = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'clearDeviceTags', []);
};

Notificare.prototype.fetchDeviceTags = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'fetchDeviceTags', []);
};

Notificare.prototype.createAccount = function(email, password, userName, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'createAccount', [email, password, userName]);
};

Notificare.prototype.validateUser = function(token, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'validateUser', [token]);
};

Notificare.prototype.sendPassword = function(email, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'sendPassword', [email]);
};

Notificare.prototype.resetPassword = function(password, token, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'resetPassword', [password, token]);
};

Notificare.prototype.changePassword = function(password, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'fetchDeviceTags', [password]);
};

Notificare.prototype.userLogin = function(username, password, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'userLogin', [username, password]);
};

Notificare.prototype.userLogout = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'userLogout', []);
};

Notificare.prototype.generateAccessToken = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'generateAccessToken', []);
};

Notificare.prototype.fetchUserDetails = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'fetchUserDetails', []);
};

Notificare.prototype.openNotification = function(notification, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'openNotification', [notification]);
};

Notificare.prototype.registrationCallback = function(err, deviceId) {
	if (err) {
		this.emit('registrationError', err);
	} else {
		this.emit('registration', deviceId);
	}
};

Notificare.prototype.notificationCallback = function(notification) {
	this.emit('notification', notification);
};

module.exports = new Notificare();