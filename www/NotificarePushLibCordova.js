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

Notificare.prototype.registerForNotifications = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'registerForNotifications', []);
};

Notificare.prototype.unregisterForNotifications = function(success, fail) {
    exec(success, fail, 'NotificarePushLibCordova', 'unregisterForNotifications', []);
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