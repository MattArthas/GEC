package cc.zero.travel;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

public class MyActivity extends Activity implements OnItemClickListener{

	private ListView mListView;
	private LinearLayout ll_login;
	private static final String[] arr={"我的信息","我的订单","我的支付","信息与反馈"};
	private TextView username;
	private ImageView touxiang;
	private SharedPreferences sp;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.myactivity);
        sp = getSharedPreferences("config", Context.MODE_PRIVATE);
        mListView = (ListView) findViewById(R.id.selflistview);
        if(isUserLogin()){
        	username = (TextView) this.findViewById(R.id.username);
        	username.setText(sp.getString("username", null));
        	touxiang = (ImageView) this.findViewById(R.id.touxiang);
        	touxiang.setImageResource(R.drawable.headxiang);
        }
		mListView.setAdapter(new ArrayAdapter<String>(this, R.layout.me_item,R.id.fav_title,arr));
		mListView.setOnItemClickListener(this);
		ll_login = (LinearLayout) this.findViewById(R.id.ll_login);
		ll_login.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent  loginIntent = new Intent(MyActivity.this,LoginActivity.class);
				startActivity(loginIntent);				
			}
		});
       
       }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		if(isUserLogin()){
			//进入到对应的界面 
			switch (position) {
			case 0:
				Intent  myInfoIntent = new Intent(MyActivity.this,MyInfoActivity.class);
				startActivity(myInfoIntent);
				break;
			case 1:
				Intent  myOrderIntent = new Intent(MyActivity.this,MyOrderActivity.class);
				startActivity(myOrderIntent);
				break;
			case 2:
				Toast.makeText(this, "本功能暂未开通，尽情期待", 1000);
				break;
			case 3:
				Intent  feedbackIntent = new Intent(MyActivity.this,FeedBackActivity.class);
				startActivity(feedbackIntent);
				break;
			}
		}else{
			//定向到登陆界面 
			Intent intent = new Intent(this,LoginActivity.class);
			startActivity(intent);
		}
		
	}
	
	private boolean isUserLogin(){
		String username = sp.getString("username", null);
		String password = sp.getString("password", null);
		if(username==null||password==null||"".equals(username)||"".equals(password)){
			return false;
		}else{
			return true;
		}
		
	}
	

}

