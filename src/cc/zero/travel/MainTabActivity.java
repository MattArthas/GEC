package cc.zero.travel;

import android.app.Activity;
import android.app.TabActivity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;
import android.widget.TextView;

public class MainTabActivity extends TabActivity {

	private TabHost mTabHost;
	private LayoutInflater inflater;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.main_tab);
        
        inflater = LayoutInflater.from(this);
        mTabHost = getTabHost();
        mTabHost.addTab(getTab());
        mTabHost.addTab(getTab1());
        mTabHost.addTab(getTab2());
        mTabHost.addTab(getTab3());
       }

   private TabSpec getTab(){
	   TabSpec spec = mTabHost.newTabSpec("1");
	   Intent intent = new Intent(this,TravelInfoActivity.class);
	   spec.setContent(intent);
	   spec.setIndicator(getIndicatorView("套餐", R.drawable.spot));
	   return spec;
   }
   
   private TabSpec getTab1(){
	   TabSpec spec = mTabHost.newTabSpec("2");
	   Intent intent = new Intent(this,TopicActivity.class);
	   spec.setContent(intent);
	   spec.setIndicator(getIndicatorView("单点", R.drawable.news));
	   return spec;
   }
   
   private TabSpec getTab2(){
	   TabSpec spec = mTabHost.newTabSpec("3");
	   Intent intent = new Intent(this,MessageBoardActivity.class);
	   spec.setContent(intent);
	   spec.setIndicator(getIndicatorView("留言板", R.drawable.mb));
	   return spec;
   }
   

   private TabSpec getTab3(){
	   TabSpec spec = mTabHost.newTabSpec("4");
	   Intent intent = new Intent(this,MyActivity.class);
	   spec.setContent(intent);
	   spec.setIndicator(getIndicatorView("个人中心", R.drawable.setting));
	   return spec;
   }
   
   private View getIndicatorView(String name, int iconid){
	   View view = inflater.inflate(R.layout.tab_main_nav, null);
	    ImageView ivicon =	(ImageView) view.findViewById(R.id.ivIcon);
	    TextView tvtitle =	(TextView) view.findViewById(R.id.tvTitle);
	    ivicon.setImageResource(iconid);
	    tvtitle.setText(name);
	    return view;
   }

@Override
public boolean onCreateOptionsMenu(Menu menu) {
	MenuInflater inflater = new MenuInflater(this);
	inflater.inflate(R.menu.man_tab_menu, menu);
	
	return super.onCreateOptionsMenu(menu);
	
}



@Override
public boolean onOptionsItemSelected(MenuItem item) {
	switch(item.getItemId()){
	case R.id.logout:
		SharedPreferences sp =getSharedPreferences("config", Context.MODE_PRIVATE);
		Editor editor = sp.edit();
		editor.putString("username", "");
		editor.putString("password", "");
		editor.commit();
		break;
	}
	return super.onOptionsItemSelected(item);
}
   
   
   

}

