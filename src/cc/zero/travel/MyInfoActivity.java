package cc.zero.travel;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.TextView;

public class MyInfoActivity extends Activity implements OnClickListener{

	private TextView tv_username;
	private TextView tv_sex;
	private TextView tv_address;
	private TextView tv_realname;
	private TextView tv_phone;
	private TextView tv_email;
	private ImageButton back;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		setContentView(R.layout.my_info);
		super.onCreate(savedInstanceState);
		setupView();
		setListener();
		fillData();
	}

	
	public void setupView() {
		tv_address = (TextView) this.findViewById(R.id.txtAddress);
		tv_sex = (TextView) this.findViewById(R.id.txtSex);
		tv_phone = (TextView) this.findViewById(R.id.txtPhone);
		tv_email = (TextView) this.findViewById(R.id.txtEmail);
		tv_username = (TextView) this.findViewById(R.id.txtUserName);
		tv_realname =(TextView) this.findViewById(R.id.txtRealname);
		back = (ImageButton) this.findViewById(R.id.back_button);
	}

	
	public void setListener() {
		back.setOnClickListener(this);
	}

	
	public void fillData() {
		SharedPreferences sp = getSharedPreferences("config", Context.MODE_PRIVATE);
		String address = sp.getString("address", null);
		String sex = sp.getString("sex", null);
		String username = sp.getString("username", null);
		String realname = sp.getString("realname", null);
		String phone = sp.getString("phone", null);
		String email = sp.getString("email", null);
		tv_address.setText("住址： "+address);
		tv_email.setText("邮箱： "+email);
		tv_phone.setText("手机： "+phone);
		tv_realname.setText("真实姓名： "+realname);
		tv_username.setText("用户名： "+username);
		tv_sex.setText("性别： "+sex);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.back_button:
			finish();
			break;

		}
		
	}

}
