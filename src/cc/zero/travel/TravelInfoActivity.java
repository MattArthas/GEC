package cc.zero.travel;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import cc.zero.travel.model.SetMeal;
import cc.zero.travel.util.ClickUtil;
import cc.zero.travel.util.MsgListView;
import cc.zero.travel.util.MsgListView.OnRefreshListener;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

public class TravelInfoActivity extends BaseListActivity implements OnItemClickListener{

	private MsgListView setMeals;
	private boolean isloading=false;
	private EditText et_search;
	private Button bt_search;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		setContentView(R.layout.travelactivity);
		super.onCreate(savedInstanceState);
		fillData("");
	}
	
	@Override
	public void setupView() {
		loading = (RelativeLayout) this.findViewById(R.id.loading);
		setMeals = (MsgListView) this.findViewById(android.R.id.list);
		bt_search = (Button) this.findViewById(R.id.btSearch);
		et_search = (EditText) this.findViewById(R.id.txtSearch);
		ibOperationMore = (ImageButton) this.findViewById(R.id.more);
		
	}
	@Override
	public void setListener() {
		setMeals.setOnItemClickListener(this);
		setMeals.setonRefreshListener(new OnRefreshListener() {  
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
                        fillData("");//刷新监听中，真正执行刷新动作  
                        setMeals.onRefreshComplete();  
                    }  
                }.execute();  
            }  
        });  
		setMeals.setItemsCanFocus(false);              
		setMeals.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
		
		bt_search.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				String key = et_search.getText().toString();
				if (ClickUtil.isFastDoubleClick()) {  
			        return;  
			    } 
				
				if("".equals(key)){
					showToast("关键字不能为空");
					return;
				}else{
					fillData(key);
				}
				
			}
		});
		
		ibOperationMore.setOnClickListener(new OnClickListener() {  
			  
            @Override  
            public void onClick(View v) {  
  
                if (pwMyPopWindow.isShowing()) {  
  
                    pwMyPopWindow.dismiss();// 关闭  
                } else {  
  
                    pwMyPopWindow.showAsDropDown(ibOperationMore);// 显示  
                }  
  
            }  
        });  
		
	}
	
	
	
	public void fillData(final String key) {
		if(isloading){
			showToast("正在下载数据中");
			return;
		}
		
		new AsyncTask<Void, Void, List<SetMeal>>() {

			@Override
			protected void onPreExecute() {
				showLoading();
				isloading = true;
				super.onPreExecute();
			}

			@Override
			protected void onPostExecute(List<SetMeal> result) {
				hideLoading();
				super.onPostExecute(result);
				if (result != null) {
					// 设置到数据适配器里面
					MyTravLineAdapter adapter = new MyTravLineAdapter(result);
					setMeals.setAdapter(adapter);
				} else {
					showToast("下载数据发生异常");
				}
				isloading =false;
			}

			@Override
			protected List<SetMeal> doInBackground(Void... params) {
					List<SetMeal> mess = new ArrayList<SetMeal>();
					String url = "http://192.168.173.1:8888/cook/app/listSetMeal";
					try {
						HttpClient client=new DefaultHttpClient();
				        HttpPost request;
				        request = new HttpPost(new URI(url));
				        if(!("".equals(key))){
				        List<NameValuePair> parameters = new ArrayList<NameValuePair>();
				        NameValuePair nameValuePairs = new BasicNameValuePair("key", key);
				        parameters.add(nameValuePairs);
						HttpEntity entity = new UrlEncodedFormEntity(parameters, "UTF-8");
						request.setEntity(entity);
				        }
				        HttpResponse response=client.execute(request);
				        //判断请求是否成功
				        if(response.getStatusLine().getStatusCode()==200){
				        HttpEntity entity=response.getEntity();
				        if(entity!=null){
				        String jsonstr = EntityUtils.toString(entity);
						mess = getSetMeal("data" , jsonstr);
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
	
	public static List<SetMeal> getSetMeal(String key , String jsonString) throws Exception{
		List<SetMeal> mes = new ArrayList<SetMeal>();
		//jsonObject={"persons":[{"address":"香港","id":1001,"name":"刘德华"},{"address":"韩国","id":1002,"name":"宋慧乔"}]} 
		JSONObject jsonObject = new JSONObject(jsonString);
		//jsonArray =[{"address":"香港","id":1001,"name":"刘德华"},{"address":"韩国","id":1002,"name":"宋慧乔"}]
		JSONArray jsonArray = jsonObject.getJSONArray(key);   //此处key = persons,取得
		for (int i = 0; i < jsonArray.length(); i++) {
			JSONObject messageObject = jsonArray.getJSONObject(i);
			SetMeal sm = new SetMeal();
			sm.setSetMealId(messageObject.getInt("setMealId"));
			sm.setSetMealName(messageObject.getString("setMealName"));
			sm.setSetMealPrice(messageObject.getInt("setMealPrice"));  
			sm.setSetMealSaleVolume(messageObject.getInt("setMealSaleVolume")); 
			sm.setSetMealIntroduce(messageObject.getString("setMealIntroduce")); 
			sm.setSetMealComment(messageObject.getString("setMealComment")); 
			mes.add(sm);	
		}
		return mes;
	}
	
	private class MyTravLineAdapter extends BaseAdapter {
		private List<SetMeal> ms;

		public MyTravLineAdapter(List<SetMeal> ms) {
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

				view = View.inflate(getApplicationContext(), R.layout.travel_item, null);
			}else{
				view = convertView;
			}
			TextView tv_name = (TextView) view.findViewById(R.id.tra_name);
			TextView tv_price = (TextView) view.findViewById(R.id.tra_price);
			TextView tv_type = (TextView) view.findViewById(R.id.tra_type);
			
			tv_name.setText("套餐名： "+ms.get(position).getSetMealName());
			tv_price.setText("价格： "+ms.get(position).getSetMealPrice()+"");
			tv_type.setText("销量： "+ms.get(position).getSetMealSaleVolume()+"");
			return view;
		}
	}
	
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
				if (ClickUtil.isFastDoubleClick()) {  
						return;  
					} 
				Intent travIntent = new Intent(TravelInfoActivity.this,TravelDetailInfoActivity.class);
				SetMeal tl =(SetMeal) setMeals.getItemAtPosition(position);
				travIntent.putExtra("id", tl.getSetMealId());
				startActivity(travIntent);
			
	}

	@Override
	public void fillData() {
		
	}

}
