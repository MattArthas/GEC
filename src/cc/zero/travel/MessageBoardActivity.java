package cc.zero.travel;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;



import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cc.zero.travel.model.MessageBoard;
import cc.zero.travel.util.MsgListView;
import cc.zero.travel.util.MsgListView.OnRefreshListener;

public class MessageBoardActivity extends BaseListActivity implements OnClickListener{
	private MsgListView messages;
	private Button add;
	SharedPreferences sp;
	private boolean isloading=false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		setContentView(R.layout.messageboard);
		super.onCreate(savedInstanceState);
	}

	@Override
	public void setupView() {
		loading = (RelativeLayout) this.findViewById(R.id.loading);
		messages = (MsgListView) this.findViewById(android.R.id.list);
		add = (Button) this.findViewById(R.id.addMessage);
		sp =getSharedPreferences("config", Context.MODE_PRIVATE);
		
		messages.setonRefreshListener(new OnRefreshListener() {  
            public void onRefresh() {  
                new AsyncTask<Void, Void, Void>() {  
                    protected Void doInBackground(Void... params) {  
                        try {  
                            Thread.sleep(1000);  
                        } catch (Exception e) {  
                            e.printStackTrace();  
                        }  
                        return null;  
                    }  
  
                    @Override  
                    protected void onPostExecute(Void result) {  
                        /*adapter.notifyDataSetChanged();  */
                        fillData();//刷新监听中，真正执行刷新动作  
                        messages.onRefreshComplete();  
                    }  
                }.execute();  
            }  
        });  
		messages.setItemsCanFocus(false);              
		messages.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
		
		
	}

	@Override
	public void fillData() {
		if(isloading){
			showToast("正在下载数据中");
			return;
		}
		
		new AsyncTask<Void, Void, List<MessageBoard>>() {

			@Override
			protected void onPreExecute() {
				showLoading();
				isloading = true;
				super.onPreExecute();
			}

			@Override
			protected void onPostExecute(List<MessageBoard> result) {
				hideLoading();
				super.onPostExecute(result);
				if (result != null) {
					// 设置到数据适配器里面
					MyMessageBoardAdapter adapter = new MyMessageBoardAdapter(result);
					messages.setAdapter(adapter);
				} else {
					showToast("下载数据发生异常");
				}
				isloading =false;
			}

			@Override
			protected List<MessageBoard> doInBackground(Void... params) {
					List<MessageBoard> mess = new ArrayList<MessageBoard>();
					/*String url = "http://10.203.170.83:8080/Travel/messageBoard4App_list.action";*/
					String url = "http://192.168.23.1:8080/Travel/messageBoard4App_list.action";
					try {
						HttpClient client=new DefaultHttpClient();
				        HttpPost request;
				        request = new HttpPost(new URI(url));
				        HttpResponse response=client.execute(request);
				        //判断请求是否成功
				        if(response.getStatusLine().getStatusCode()==200){
				        HttpEntity entity=response.getEntity();
				        if(entity!=null){
				        String jsonstr = EntityUtils.toString(entity);
				        System.out.println(jsonstr);
						mess = getMessageBoards("messages" , jsonstr);
						return mess;
				       }
				     }
					
				} catch (Exception e) {
					e.printStackTrace();
					return null;
				}
					return mess;
			}
		}.execute();
	}

	
	public static List<MessageBoard> getMessageBoards(String key , String jsonString) throws Exception{
		List<MessageBoard> mes = new ArrayList<MessageBoard>();
		//jsonObject={"persons":[{"address":"香港","id":1001,"name":"刘德华"},{"address":"韩国","id":1002,"name":"宋慧乔"}]} 
		JSONObject jsonObject = new JSONObject(jsonString);
		//jsonArray =[{"address":"香港","id":1001,"name":"刘德华"},{"address":"韩国","id":1002,"name":"宋慧乔"}]
		JSONArray jsonArray = jsonObject.getJSONArray(key);   //此处key = persons,取得
		for (int i = 0; i < jsonArray.length(); i++) {
			JSONObject messageObject = jsonArray.getJSONObject(i);
			MessageBoard mb = new MessageBoard();
			mb.setContent("留言： "+messageObject.getString("content"));
			mb.setUsername("用户名: "+messageObject.getString("username"));  
			mes.add(mb);			
		}
		return mes;
	}
	
	private class MyMessageBoardAdapter extends BaseAdapter {
		private List<MessageBoard> ms;

		public MyMessageBoardAdapter(List<MessageBoard> ms) {
			this.ms = ms;
		}

		public int getCount() {
			// TODO Auto-generated method stub
			return ms.size();
		}

		public Object getItem(int position) {
			// TODO Auto-generated method stub
			return ms.get(position);
		}

		public long getItemId(int position) {
			// TODO Auto-generated method stub
			return position;
		}

		public View getView(int position, View convertView, ViewGroup parent) {
			View view = null;
			if (convertView == null) {

				view = View.inflate(getApplicationContext(), R.layout.mb_item, null);
			}else{
				view = convertView;
			}
			TextView tv_message = (TextView) view.findViewById(R.id.message);
			TextView tv_username = (TextView) view.findViewById(R.id.mb_name);
			tv_message.setText(ms.get(position).getContent());
			tv_username.setText(ms.get(position).getUsername());
			return view;
		}
	}

	@Override
	public void setListener() {
		add.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		if(isUserLogin()){
		switch (v.getId()) {
		case R.id.addMessage:
			Intent  myMessageIntent = new Intent(MessageBoardActivity.this,AddMessageBoardActivity.class);
			String username = sp.getString("username", null);
			myMessageIntent.putExtra("username", username);
			startActivity(myMessageIntent);
			break;
		}
	}else{
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
