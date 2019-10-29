package re.notifica.cordova;

import re.notifica.Notificare;
import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Build;

public class BaseApplication extends Application {

	@Override
	public void onCreate() {
		super.onCreate();
		Notificare.shared().launch(this);
		Notificare.shared().createDefaultChannel();
		Notificare.shared().setIntentReceiver(IntentReceiver.class);
//		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//			NotificationManager notificationManager = (NotificationManager) getApplicationContext().getSystemService(Context.NOTIFICATION_SERVICE);
//			NotificationChannel passbookChannel = new NotificationChannel("passbook", "Passbook Channel", NotificationManager.IMPORTANCE_DEFAULT);
//			passbookChannel.setDescription("This is for passbook notifications");
//			notificationManager.createNotificationChannel(passbookChannel);
//			Notificare.shared().setPassbookChannel(passbookChannel.getId());
//		}
//		Notificare.shared().setSmallIcon(R.drawable.ic_stat_notify_msg);
		Notificare.shared().setAllowOrientationChange(false);
//		Notificare.shared().setPassbookRelevanceOngoing(true);
	}

}