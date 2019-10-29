package re.notifica.cordova;

import android.net.Uri;
import android.os.Bundle;

import re.notifica.Notificare;
import re.notifica.app.DefaultIntentReceiver;
import re.notifica.model.NotificareDevice;
import re.notifica.model.NotificareNotification;


public class IntentReceiver extends DefaultIntentReceiver {

    @Override
    public void onUrlClicked(Uri urlClicked, Bundle extras) {
        NotificareNotification notification = extras.getParcelable(Notificare.INTENT_EXTRA_NOTIFICATION);
        NotificarePlugin.shared().sendUrlClicked(urlClicked, notification);
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
    public void onDeviceRegistered(NotificareDevice device) {
        NotificarePlugin.shared().sendRegistration(device);
    }

}
