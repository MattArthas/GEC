package cc.zero.travel;

import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

public abstract class BaseActivity extends Activity {

	public TextView title;
	public  RelativeLayout loading;
	public ImageButton back;
	  
    List<Map<String, String>> moreList;  
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setupView();
		setListener();
		fillData(); 
    }  
  
	public abstract void setupView();
	public abstract void setListener();
	public abstract void fillData();
	public void showLoading(){
		loading.setVisibility(View.VISIBLE);
		AlphaAnimation aa = new AlphaAnimation(0.0f, 1.0f);
		aa.setDuration(1000);
		ScaleAnimation sa = new ScaleAnimation(0.0f, 1.0f, 0.0f, 1.0f);
		sa.setDuration(1000);
		AnimationSet set = new AnimationSet(false);
		set.addAnimation(sa);
		set.addAnimation(aa);
		loading.setAnimation(set);
		loading.startAnimation(set);
	}
	public void hideLoading(){
		AlphaAnimation aa = new AlphaAnimation(1.0f, 0.0f);
		aa.setDuration(1000);
		ScaleAnimation sa = new ScaleAnimation(1.0f, 0.0f, 1.0f,0.0f);
		sa.setDuration(1000);
		AnimationSet set = new AnimationSet(false);
		set.addAnimation(sa);
		set.addAnimation(aa);
		loading.setAnimation(set);
		loading.startAnimation(set);
		loading.setVisibility(View.INVISIBLE);
	}
	public void showToast(String text){
		Toast.makeText(this, text, 0).show();
	}
	
}
