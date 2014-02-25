//var exec = require("cordova/exec");

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
 */
function Notificare() {
	EventEmitter.apply(this, arguments);
}

Notificare.prototype = inherit(EventEmitter.prototype);

Notificare.prototype.registerDevice = function(deviceId, userId, userName, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'registerDevice', [deviceId, userId, userName]);
};

Notificare.prototype.enableNotifications = function(success, fail) {
	alert("enable!");
	cordova.exec(success, fail, 'Notificare', 'enableNotifications', []);
};

Notificare.prototype.enableLocationUpdates = function(success, fail) {
	cordova.exec(success, fail, 'Notificare', 'enableLocationUpdates', []);
};

Notificare.prototype.fetchNotification = function(notificationId, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'fetchNotification', [notificationId]);
};

Notificare.prototype.addDeviceTags = function(tags, success, fail) {
	cordova.exec(success, fail, 'Notificare', 'addDeviceTags', [tags]);
};

Notificare.prototype.pushNotificationReceivedCallback = function(message, notificationId, extras) {
	this.emit('notification-received', message, notificationId, extras);
};

Notificare.prototype.pushNotificationOpenedCallback = function(message, notificationId, extras) {
	this.emit('notification-opened', message, notificationId, extras);
};

Notificare.prototype.registrationCallback = function(deviceId) {
	this.emit('registration', deviceId);
};

cordova.addConstructor(function() {
	if(!window.plugins) window.plugins = {};
	window.plugins.notificare = new Notificare();
	console.log('Notificare plugin loaded');
});

module.exports = new Notificare();