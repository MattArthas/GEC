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
import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Toast;

public class LoginActivity extends Activity implements OnClickListener{

	protected static final int LOGIN_SUCCESS=11;
	protected static final int LOGIN_FAIL=12;
	protected static final int PWD_FAIL=13;
	protected static final int CAPTCHA_FAIL=14;
	protected static final int USERNAME_FAIL=15;
	
	private EditText username;
	private EditText password;
	private Button btnLogin, btnExit,btnRegister;
	private ImageButton back;
	private Bitmap bitmap;
	ProgressDialog pd ;
	
	private Handler handler = new Handler(){
		@Override
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			pd.dismiss();
			switch (msg.what) {
			
			case LOGIN_SUCCESS:
				Intent  myInfoIntent = new Intent(LoginActivity.this,MyActivity.class);
				startActivity(myInfoIntent);
				break;	
			case PWD_FAIL:
				Toast.makeText(getApplicationContext(), "密码错误", 200).show();
				break;		
			case USERNAME_FAIL:
					Toast.makeText(getApplicationContext(), "用户不存在", 200).show();
					break;
			}
			
		}
	};
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);
		setupView();
		setLinstener();
	}

	private void setupView() {
		username = (EditText) this.findViewById(R.id.EditTextEmail);
		password = (EditText) this.findViewById(R.id.EditTextPassword);
		btnExit = (Button) this.findViewById(R.id.btnExit);
		btnLogin = (Button) this.findViewById(R.id.btnLogin);
		btnRegister = (Button) this.findViewById(R.id.btnRegister);
		back = (ImageButton) this.findViewById(R.id.back_button);
		pd = new ProgressDialog(this);
//		getCaptcha();
		
	}
	
	//获取验证码
	/*private void getCaptcha() {
		new Thread() {
			@Override
			public void run() {
				try {
						String imagepath = "http://10.203.170.83:8080/Travel/image.jsp?timestamp="+new Date().getTime();
						bitmap = getImage(imagepath);
						imageViewCaptcha.setImageBitmap(bitmap);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}.start();
		
	}
	
	public static Bitmap getImage(String path) throws Exception{
		URL url = new URL(path);
		HttpURLConnection conn =  (HttpURLConnection) url.openConnection();
		InputStream is = conn.getInputStream();
		return  BitmapFactory.decodeStream(is);
	}*/
	
	private void setLinstener() {
		btnExit.setOnClickListener(this);
		btnLogin.setOnClickListener(this);
		btnRegister.setOnClickListener(this);
		back.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		switch(v.getId()){
		case R.id.btnExit:
			finish();
			break;
		case R.id.btnLogin:
			final String name = username.getText().toString();
			final String pwd = password.getText().toString();
			if("".equals(name)||"".equals(pwd)){
				Toast.makeText(this, "用户名或密码不能为空", 1).show();
				return;
			}else{
					login(name, pwd);
			}
			break;
		case R.id.btnRegister:
			Intent i = new Intent(LoginActivity.this,RegisterActivity.class);
			startActivity(i);
			break;
			
		case R.id.back_button:
			finish();
			break;	
			
		}
	}

	private void login(final String name, final String pwd) {
		pd.setMessage("正在登陆");
		pd.show();
		new Thread(){

			@Override
			public void run() {
				  try {
				    boolean flag = LoginIn(name, pwd,getApplicationContext());
					if(flag){
						Message msg = new Message();
						msg.what=LOGIN_SUCCESS;
						handler.sendMessage(msg);
					}
				} catch (Exception e) {
					e.printStackTrace();
					Message msg = new Message();
					msg.what=LOGIN_FAIL;
					handler.sendMessage(msg);
				}
			}

			private boolean LoginIn(String name, String pwd, Context applicationContext) {
				System.out.println("5");
				String url = "http://192.168.173.1:8888/cook/app/loginAjax";
				Map<String,String> data = new HashMap<String, String>();
				data.put("username", name);
				data.put("pwd", pwd);
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
					        if(jsonstr.equals("用户名不存在")){
					        	Message msg = new Message();
								msg.what=LOGIN_SUCCESS;
								handler.sendMessage(msg);
					        }else if(jsonstr.equals("密码错误")){
					        	Message msg = new Message();
								msg.what=LOGIN_SUCCESS;
								handler.sendMessage(msg);
					        }else{
					        JSONObject jsonObject = new JSONObject(jsonstr);
					        SharedPreferences sp = getSharedPreferences("config", Context.MODE_PRIVATE);
							Editor editor = sp.edit();
							editor.putString("id", jsonObject.getString("clientId"));
							editor.putString("username", jsonObject.getString("clientName"));
							editor.putString("password", "123456");
							editor.putString("sex", jsonObject.getString("clientSex"));
							editor.putString("address", jsonObject.getString("clientAddress"));
							editor.putString("email", jsonObject.getString("clientEmail"));
							editor.putString("rank", jsonObject.getString("clientRank"));
							editor.putString("phone", jsonObject.getString("clientTel"));
							editor.commit();
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
