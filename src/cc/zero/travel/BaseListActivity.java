package cc.zero.travel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.ListActivity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;

public abstract class BaseListActivity extends ListActivity {

	public TextView title;
	public  RelativeLayout loading;
	public ImageButton back;
	public ImageButton ibOperationMore;  
	  
    List<Map<String, String>> moreList;  
    public PopupWindow pwMyPopWindow;// popupwindow  
    private ListView lvPopupList;// popupwindow中的ListView  
    private int NUM_OF_VISIBLE_LIST_ROWS = 3;// 指定popupwindow中Item的数量  
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setupView();
		iniData();  
        iniPopupWindow();
		setListener();
		fillData(); 
        
    }  
  
    private void iniData() {  
  
        moreList = new ArrayList<Map<String, String>>();  
        Map<String, String> map;  
        map = new HashMap<String, String>();  
        map.put("share_key", "我的");  
        moreList.add(map);  
        map = new HashMap<String, String>();  
        map.put("share_key", "注销");  
        moreList.add(map);  
        map = new HashMap<String, String>();  
        map.put("share_key", "退出");  
        moreList.add(map);  
    }  
  
    private void iniPopupWindow() {  
  
        LayoutInflater inflater = (LayoutInflater) this  
                .getSystemService(LAYOUT_INFLATER_SERVICE);  
        View layout = inflater.inflate(R.layout.task_detail_popupwindow, null);  
        lvPopupList = (ListView) layout.findViewById(R.id.lv_popup_list);  
        pwMyPopWindow = new PopupWindow(layout);  
        pwMyPopWindow.setFocusable(true);// 加上这个popupwindow中的ListView才可以接收点击事件  
  
        lvPopupList.setAdapter(new SimpleAdapter(this, moreList,  
                R.layout.list_item_popupwindow, new String[] { "share_key" },  
                new int[] { R.id.tv_list_item }));  
        lvPopupList.setOnItemClickListener(new OnItemClickListener() {  
  
            @Override  
            public void onItemClick(AdapterView<?> parent, View view,  
                    int position, long id) {  
  
              switch (position) {
			case 0:
				
				break;
			case 1:
				SharedPreferences sp =getSharedPreferences("config", Context.MODE_PRIVATE);
				Editor editor = sp.edit();
				editor.putString("username", "");
				editor.putString("password", "");
				editor.commit();
				break;
			case 2:
				android.os.Process.killProcess(android.os.Process.myPid());
				break;

			default:
				break;
			}
            	
            }  
        });  
  
        // 控制popupwindow的宽度和高度自适应  
        lvPopupList.measure(View.MeasureSpec.UNSPECIFIED,  
                View.MeasureSpec.UNSPECIFIED);  
        pwMyPopWindow.setWidth(lvPopupList.getMeasuredWidth());  
        pwMyPopWindow.setHeight((lvPopupList.getMeasuredHeight() + 20)  
                * NUM_OF_VISIBLE_LIST_ROWS);  
  
        // 控制popupwindow点击屏幕其他地方消失  
        pwMyPopWindow.setBackgroundDrawable(this.getResources().getDrawable(  
                R.drawable.bg_popupwindow));// 设置背景图片，不能在布局中设置，要通过代码来设置  
        pwMyPopWindow.setOutsideTouchable(true);// 触摸popupwindow外部，popupwindow消失。这个要求你的popupwindow要有背景图片才可以成功，如上  
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
