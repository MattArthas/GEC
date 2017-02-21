package cc.zero.travel;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.view.Window;
import android.view.animation.AlphaAnimation;
import android.widget.LinearLayout;
import android.widget.TextView;

public class SplashActivity extends Activity {
	private LinearLayout mLinearLayout;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		
		setContentView(R.layout.splash);
		mLinearLayout = (LinearLayout) this.findViewById(R.id.LinearLayout01);
		
		// 判断当前网络状态是否可用
		if(isNetWorkConnected()){
			//splash 做一个动画,进入主界面
			AlphaAnimation aa = new AlphaAnimation(0.5f, 1.0f);
			aa.setDuration(2000);
			mLinearLayout.setAnimation(aa);
			mLinearLayout.startAnimation(aa);
			//通过handler 延时2秒 执行r任务 
			new Handler().postDelayed(new LoadMainTabTask(), 2000);
		}else{
			showSetNetworkDialog();
		}
	}
	
	private class LoadMainTabTask implements Runnable{

		public void run() {
			Intent intent = new Intent(SplashActivity.this,MainTabActivity.class);
			startActivity(intent);
			finish();
			
		}
		
	}
	private void showSetNetworkDialog() {
		AlertDialog.Builder builder = new Builder(this);
		builder.setTitle("设置网络");
		builder.setMessage("网络错误请检查网络状态");
		builder.setPositiveButton("设置网络", new OnClickListener() {
			
			public void onClick(DialogInterface dialog, int which) {
				Intent intent = new Intent("android.provider.Settings.ACTION_WIRELESS_SETTINGS");
				//类名一定要包含包名 
				
				startActivity(intent);
				finish();
			}
		});
		builder.setNegativeButton("取消", new OnClickListener() {
			
			public void onClick(DialogInterface dialog, int which) {
				finish();
			}
		});
		builder.create().show();
		
	}


	private String getVersion(){
		try {
			PackageInfo info = getPackageManager().getPackageInfo(getPackageName(), 0);
			return "Version " +info.versionName;
		} catch (NameNotFoundException e) {
			e.printStackTrace();
			return "Version";
		}
	}
	
	/**
	 * 判断网络状态
	 */
	private boolean isNetWorkConnected(){
		ConnectivityManager manager = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
		NetworkInfo info = manager.getActiveNetworkInfo();
		
//		WifiManager  wifimanager =  (WifiManager) getSystemService(WIFI_SERVICE);
//		wifimanager.isWifiEnabled();
//		wifimanager.getWifiState();
	
		return (info!=null&&info.isConnected());
	}

}
