package re.notifica.cordova;

import java.lang.reflect.Constructor;
import java.util.List;

import com.google.android.gms.location.Geofence;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareAction;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificarePendingResult;
import re.notifica.push.gcm.DefaultIntentReceiver;
import re.notifica.ui.NotificationAction;
import re.notifica.ui.NotificationActivity;
import android.app.Activity;
import android.content.Intent;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.TaskStackBuilder;
import android.util.Log;

public class IntentReceiver extends DefaultIntentReceiver {

	private static final String TAG = IntentReceiver.class.getSimpleName();

	
	@Override
	public void onActionReceived(Uri target) {
		super.onActionReceived(target);
	}

	@Override
	public void onLocationUpdateReceived(Location location) {
		super.onLocationUpdateReceived(location);
	}

	@Override
	public void onNotificationOpened(String alert, String notificationId, Bundle extras) {
		
        Notificare.shared().getEventLogger().logOpenNotification(notificationId);
        Notificare.shared().getEventLogger().logOpenNotificationInfluenced(notificationId);

		NotificareAction action = extras.getParcelable(Notificare.INTENT_EXTRA_ACTION);
		NotificareNotification notification = extras.getParcelable(Notificare.INTENT_EXTRA_NOTIFICATION);
		if (action != null && notification != null) {
			// TODO: check if action needs UI, in which case we should probably pass on the action to the Notification activity
			try {
				Class<?> actionClass = Class.forName(action.getType());
				Constructor<?> ctor = actionClass.getConstructor(Activity.class, NotificareNotification.class, NotificareAction.class);
				NotificationAction actionHandler = (NotificationAction) ctor.newInstance(null, notification, action);
				actionHandler.handleAction(new NotificareCallback<NotificarePendingResult>() {
					@Override
					public void onSuccess(NotificarePendingResult result) {
						Log.d(TAG, "action handle successfully");
					}
					
					@Override
					public void onError(NotificareError error) {
						Log.e(TAG, "error handling action", error);
					}
				});
			} catch (Exception e) {
				Log.e(TAG, "error instantiating Action Handler", e);
			}
		} else {
			// Close the notification drawer
			Notificare.shared().getApplicationContext().sendBroadcast(new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS));
			Intent notificationIntent = new Intent()
			.setAction(Notificare.INTENT_ACTION_NOTIFICATION_OPENED)
			.putExtras(extras)
			.putExtra(Notificare.INTENT_EXTRA_DISPLAY_MESSAGE, Notificare.shared().getDisplayMessage())
			.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP)
			.setPackage(Notificare.shared().getApplicationContext().getPackageName());
			
			// Workaround for pre-1.1.1 SDK
			if (notificationIntent.resolveActivity(Notificare.shared().getApplicationContext().getPackageManager()) != null) {
				Notificare.shared().getApplicationContext().startActivity(notificationIntent);
			} else {
				notificationIntent.setClass(Notificare.shared().getApplicationContext(), NotificationActivity.class);
				TaskStackBuilder stackBuilder = TaskStackBuilder.create(Notificare.shared().getApplicationContext());
				buildTaskStack(stackBuilder, notificationIntent, notification);
				stackBuilder.startActivities();				
			}
		}
		
		if (Notificare.shared().getAutoCancel()) {
			Notificare.shared().cancelNotification(notificationId);
		}
	}
	
	
	@Override
	public void onNotificationReceived(String alert, String notificationId,
			Bundle extras) {
		super.onNotificationReceived(alert, notificationId, extras);
	}

	@Override
	public void onRegionEnter(List<Geofence> geofences) {
		super.onRegionEnter(geofences);
	}

	@Override
	public void onRegionExit(List<Geofence> geofences) {
		super.onRegionExit(geofences);
	}

	@Override
	public void onNotificationDeleted(String notificationId) {
		super.onNotificationDeleted(notificationId);
	}

	@Override
	public void onReady() {
		super.onReady();
		Log.d(TAG, "Notificare ready");
	}

	@Override
	public void onRegistrationFinished(final String deviceId) {
		Log.d(TAG, "Device registered to GCM");
		NotificarePlugin.shared().sendRegistration(deviceId);
	}

	@Override
	public void onUnregistrationFinished() {
		Log.d(TAG, "Device unregistered from GCM");
		Notificare.shared().unregisterDevice(new NotificareCallback<Boolean>() {
			
			@Override
			public void onSuccess(Boolean success) {
				Log.d(TAG, "Device unregistered from Notificare");
			}
			
			@Override
			public void onError(NotificareError error) {
				Log.e(TAG, "Error unregistering from Notificare", error);
			}
		});
	}

	@Override
	public void onRegistrationError(String errorId) {
		Log.d(TAG, "Device failed registration to GCM");
		NotificarePlugin.shared().sendRegistrationError(errorId);
	}
	
	
}
