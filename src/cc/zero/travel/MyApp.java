package cc.zero.travel;

import android.app.Application;
import android.content.Intent;

public class MyApp extends Application {

	@Override
	public void onLowMemory() {
		super.onLowMemory();
		
		// ����һЩ�㲥 �رյ�һЩactivity service 
		Intent intent = new Intent();
		intent.setAction("kill_activity_action");
		sendBroadcast(intent);
		
		
	}
}
