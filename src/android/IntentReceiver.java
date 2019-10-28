package re.notifica.cordova;

import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import java.util.List;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.app.DefaultIntentReceiver;
import re.notifica.model.NotificareDevice;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificareRemoteMessage;
import re.notifica.model.NotificareSystemNotification;


public class IntentReceiver extends DefaultIntentReceiver {

    private static final String TAG = IntentReceiver.class.getSimpleName();

    @Override
    public void onNotificationReceived(NotificareRemoteMessage message) {
        super.onNotificationReceived(message);
    }

    @Override
    public void onUrlClicked(Uri urlClicked, Bundle extras) {
        Log.i(TAG, "URL was clicked: " + urlClicked);
    }

    @Override
    public void onReady() {
        // Check if notifications are enabled, by default they are not.
        // Make sure to call enableNotifications() after on-boarding (or from your app settings view)
        if (Notificare.shared().isNotificationsEnabled()) {
            Notificare.shared().enableNotifications();
        }
        // Check if location updates are enabled, by default they are not.
        // Make sure to call enableLocationUpdates() after on-boarding (or from your app settings view)
        if (Notificare.shared().isLocationUpdatesEnabled()) {
            Notificare.shared().enableLocationUpdates();
        }
    }

    @Override
    public void onActionReceived(Uri target) {
        Log.d(TAG, "Custom action was received: " + target.toString());
        // By default, pass the target as data URI to your main activity in a launch intent
        super.onActionReceived(target);
    }

    @Override
    public void onSystemNotificationReceived(NotificareSystemNotification notification) {
        Log.i(TAG, "system notification received with type " + notification.getType());
    }
}
