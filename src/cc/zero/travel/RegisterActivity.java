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
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RadioButton;
import android.widget.Toast;

public class RegisterActivity extends Activity implements OnClickListener{
	
	protected static final int REGISTER_SUCCESS=11;
	protected static final int REGISTER_FAIL=12;
	
	private EditText et_username;
	private EditText et_password;
	private EditText et_email;
	private EditText et_phone;
	private EditText et_address;
	private EditText et_realname;
	private ImageButton ib_back;
	private Button bt_register;
	private Button bt_exit;
	private RadioButton rt_sex;
	ProgressDialog pd ;
	
	private Handler handler = new Handler(){
		@Override
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			pd.dismiss();
			switch (msg.what) {
			case REGISTER_SUCCESS:
				Toast.makeText(getApplicationContext(), "注册成功", 200).show();
				finish();
				break;	
			case REGISTER_FAIL:
				Toast.makeText(getApplicationContext(), "用户名已存在", 200).show();
				break;		
			}
			
		}
	};
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		setContentView(R.layout.register);
		setup();
		setListener();
	}

	public void setup(){
		et_address = (EditText) this.findViewById(R.id.address);
		et_username = (EditText) this.findViewById(R.id.username);
		et_phone = (EditText) this.findViewById(R.id.phone);
		et_password = (EditText) this.findViewById(R.id.password);
		et_email = (EditText) this.findViewById(R.id.email);
		et_realname = (EditText) this.findViewById(R.id.realname);
		rt_sex = (RadioButton) this.findViewById(R.id.radioMale);
		ib_back = (ImageButton) this.findViewById(R.id.back_button);
		bt_exit = (Button) this.findViewById(R.id.exit);
		bt_register = (Button) this.findViewById(R.id.register);
		pd = new ProgressDialog(this);
	}

	public void setListener() {
		ib_back.setOnClickListener(this);
		bt_exit.setOnClickListener(this);
		bt_register.setOnClickListener(this);
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
		case R.id.register:
			final String address = et_address.getText().toString();
			final String email = et_email.getText().toString();
			final String username = et_username.getText().toString();
			final String phone = et_phone.getText().toString();
			final String realname = et_realname.getText().toString();
			final String password = et_password.getText().toString();
			final String sex;
			if(rt_sex.isSelected()){
				sex = "男";
			}else
				sex = "女";
			
			if("".equals(username)||"".equals(password)){
				Toast.makeText(this, "用户名或密码不能为空", 1).show();
				return;
			}else{
				register(username,password,sex,address,email,phone,realname);
			}
			
			break;

		default:
			break;
		}
		
	}

	private void register(final String username, final String password, 
			final String sex, final String address, final String email, 
			final String phone, final String realname) {
		pd.setMessage("正在注册");
		pd.show();
		new Thread(){
			@Override
			public void run() {
				  try {
				    boolean flag = LoginIn(getApplicationContext());
				    System.out.println(flag);
					if(flag){
						Message msg = new Message();
						msg.what=REGISTER_SUCCESS;
						handler.sendMessage(msg);
					}
				} catch (Exception e) {
					e.printStackTrace();
					Message msg = new Message();
					msg.what=REGISTER_FAIL;
					handler.sendMessage(msg);
				}
			}

			private boolean LoginIn(Context applicationContext) {
				String url = "http://192.168.23.1:8080/Travel/loginFApp_register.action";
				Map<String,String> data = new HashMap<String, String>();
				data.put("username", username);
				data.put("password", password);
				data.put("address", address);
				data.put("phone", phone);
				data.put("email", email);
				data.put("realname", realname);
				data.put("sex", sex);
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
					        if(jsonstr.equals("用户名已存在")){
					        	Message msg = new Message();
								msg.what=REGISTER_FAIL;
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
	
	
	
}
