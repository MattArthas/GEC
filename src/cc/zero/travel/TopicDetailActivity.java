package cc.zero.travel;


import java.lang.ref.SoftReference;
import java.net.HttpURLConnection;
import java.net.URI;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

public class TopicDetailActivity  extends BaseActivity implements OnClickListener{
	protected static final int BUY_SUCCESS=11;
	protected static final int BUY_FAIL=12;
	private TextView title;
	private TextView content;
	private TextView author;
	private ImageButton back;
	private Button bt_buy;
	private int id;
	private SharedPreferences sp;
	ProgressDialog pd ;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.topic_detail);
		title = (TextView) this.findViewById(R.id.topiv_detail_title);
		content = (TextView) this.findViewById(R.id.topiv_detail_content);
		author = (TextView) this.findViewById(R.id.topiv_detail_username);
		back = (ImageButton) this.findViewById(R.id.back_button);
		bt_buy = (Button) this.findViewById(R.id.dishes_buy);
		sp = getSharedPreferences("config", Context.MODE_PRIVATE);
		pd = new ProgressDialog(this);
		id = getIntent().getIntExtra("id", 0);
		String txt_dishesName = getIntent().getStringExtra("dishesName");
		String txt_dishesPrice = getIntent().getStringExtra("dishesPrice");
		String txt_dishesSalesVolume = getIntent().getStringExtra("dishesSalesVolume");
		String txt_dishesCategoryName = getIntent().getStringExtra("dishesCategoryName");
		String txt_newName = getIntent().getStringExtra("newName");
		String txt_dishesIntroduce = getIntent().getStringExtra("dishesIntroduce");
		String txt_dishesComment = getIntent().getStringExtra("dishesComment");
		title.setText(txt_dishesName);
		content.setText(txt_dishesIntroduce);
		author.setText(txt_dishesPrice);
		back.setOnClickListener(this);
	}
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.back_button:
			finish();
			break;
		case R.id.dishes_buy:
			
			if(isUserLogin()){
				String user_id = sp.getString("id", null);
				buy(id+"",user_id);
				
			}else{
				Intent intent = new Intent(this,LoginActivity.class);
				startActivity(intent);
			}
			break;
		default:
			break;
		}
		
	}
	
	private Handler handler = new Handler(){
		@Override
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			pd.dismiss();
			switch (msg.what) {
			case BUY_SUCCESS:
				showToast("添加成功");
				Intent  myInfoIntent = new Intent(TopicDetailActivity.this,MyActivity.class);
				startActivity(myInfoIntent);
				break;	
			case BUY_FAIL:
				Toast.makeText(getApplicationContext(), "密码错误", 200).show();
				break;		
			}
			
		}
	};
	
	private void buy(final String id, final String user_id) {
		pd.setMessage("正在加入");
		pd.show();
		new Thread(){

			@Override
			public void run() {
				  try {
				    boolean flag = order(getApplicationContext());
					if(flag){
						Message msg = new Message();
						msg.what=BUY_SUCCESS;
						handler.sendMessage(msg);
					}
				} catch (Exception e) {
					e.printStackTrace();
					Message msg = new Message();
					msg.what=BUY_FAIL;
					handler.sendMessage(msg);
				}
			}

			private boolean order(Context applicationContext) {
				String url = "http://192.168.173.1:8888/cook/app/addCart";
				Map<String,String> data = new HashMap<String, String>();
				data.put("id", id);
				data.put("type", "dishes");
				data.put("userId", user_id);
				HttpClient hc = new DefaultHttpClient();
				HttpPost request;
				try {
					request = new HttpPost(new URI(url));
				List<NameValuePair> parameters = new ArrayList<NameValuePair>();
				for (Map.Entry<String, String> entry : data.entrySet()) {
				        NameValuePair nameValuePairs = new BasicNameValuePair(entry.getKey(), entry.getValue());
				        parameters.add(nameValuePairs);
				    }
				
					HttpEntity entity = new UrlEncodedFormEntity(parameters, "UTF-8");
					request.setEntity(entity);
					HttpResponse response;
						response = hc.execute(request);
						if (response.getStatusLine().getStatusCode() == HttpURLConnection.HTTP_OK) {
							entity=response.getEntity();
					        if(entity!=null){
					        String jsonstr = EntityUtils.toString(entity);
					        System.out.println(jsonstr);
					        if(jsonstr.equals("fail")){
					        	Message msg = new Message();
								msg.what=BUY_FAIL;
								handler.sendMessage(msg);
					        }else{
							return true;
					        }
					      }	      
				      }
					} catch (Exception e) {
						e.printStackTrace();
					}
					
				return false;
			}
		}.start();
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
	@Override
	public void setupView() {
		// TODO Auto-generated method stub
		
	}
	@Override
	public void setListener() {
		// TODO Auto-generated method stub
		
	}
	@Override
	public void fillData() {
		// TODO Auto-generated method stub
		
	}
	
}
