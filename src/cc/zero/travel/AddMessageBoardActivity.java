package cc.zero.travel;

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
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Toast;

public class AddMessageBoardActivity extends Activity implements OnClickListener{

	protected static final int ADDMESSAGE_SUCCESS=11;
	protected static final int ADDMESSAGE_FAIL=12;
	
	private EditText et_message;
	private String username;
	private ImageButton ib_back;
	private Button bt_submit;
	private Button bt_exit;
	ProgressDialog pd ;

	private Handler handler = new Handler(){
		@Override
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			pd.dismiss();
			switch (msg.what) {
			case ADDMESSAGE_SUCCESS:
				Toast.makeText(getApplicationContext(), "添加成功", 200).show();
				finish();
				Intent i = new Intent(AddMessageBoardActivity.this,MainTabActivity.class);
				startActivity(i);
				break;	
			case ADDMESSAGE_FAIL:
				Toast.makeText(getApplicationContext(), "添加失败", 200).show();
				break;		
			}
			
		}
	};	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.add_mb);
		setup();
		setListener();
	}

	public void setup(){
		et_message = (EditText) this.findViewById(R.id.message);
		ib_back = (ImageButton) this.findViewById(R.id.back_button);
		bt_exit = (Button) this.findViewById(R.id.exit);
		bt_submit = (Button) this.findViewById(R.id.submit);
		username = getIntent().getStringExtra("username");
		pd = new ProgressDialog(this);
	}

	public void setListener() {
		ib_back.setOnClickListener(this);
		bt_exit.setOnClickListener(this);
		bt_submit.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.back_button:
			finish();
			break;
		case R.id.exit:
			finish();
			break;
		case R.id.submit:
			final String message = et_message.getText().toString();
			if("".equals(message)||message.length()>200){
				Toast.makeText(this, "留言不能为空", 1).show();
				return;
			}else{
				addMb(message,username);
			}
			
			break;

		default:
			break;
		}
		
	}

	private void addMb(final String message, final String username) {
		pd.setMessage("正在提交");
		pd.show();
		new Thread(){
			@Override
			public void run() {
				  try {
				    boolean flag = LoginIn(getApplicationContext());
				    System.out.println(flag);
					if(flag){
						Message msg = new Message();
						msg.what=ADDMESSAGE_SUCCESS;
						handler.sendMessage(msg);
					}
				} catch (Exception e) {
					e.printStackTrace();
					Message msg = new Message();
					msg.what=ADDMESSAGE_FAIL;
					handler.sendMessage(msg);
				}
			}

			private boolean LoginIn(Context applicationContext) {
				String url = "http://192.168.23.1:8080/Travel/messageBoard4App_add.action";
				Map<String,String> data = new HashMap<String, String>();
				data.put("content", message);
				data.put("username", username);
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
						System.out.println("11");
						if (response.getStatusLine().getStatusCode() == HttpURLConnection.HTTP_OK) {
							entity=response.getEntity();
					        if(entity!=null){
					        String jsonstr = EntityUtils.toString(entity);
					        System.out.println(jsonstr);
					        if(jsonstr.equals("ok")){
					        	return true;
					        }else{
					        	return false;
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
	
}
