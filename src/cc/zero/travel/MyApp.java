package cc.zero.travel;

import android.app.Application;
import android.content.Intent;

public class MyApp extends Application {

	@Override
	public void onLowMemory() {
		super.onLowMemory();
		
		// 发送一些广播 关闭掉一些activity service 
		Intent intent = new Intent();
		intent.setAction("kill_activity_action");
		sendBroadcast(intent);
		
		
	}
}
