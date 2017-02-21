package cc.zero.travel;

import java.net.URI;
import java.util.ArrayList;
import java.util.Date;
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
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import cc.zero.travel.model.Order;
import cc.zero.travel.model.Dishes;
import cc.zero.travel.model.SetMeal;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class MyOrderActivity extends BaseListActivity {

	private ListView orders;
	private SharedPreferences sp;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		setContentView(R.layout.order);
		super.onCreate(savedInstanceState);
	}

	@Override
	public void setupView() {
		orders = (ListView) this.findViewById(android.R.id.list);
		back = (ImageButton) this.findViewById(R.id.back_button);
		loading = (RelativeLayout) this.findViewById(R.id.loading);
		sp = getSharedPreferences("config", Context.MODE_PRIVATE);
	}

	@Override
	public void setListener() {
		back.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				finish();
			}
		});
	}

	@Override
	public void fillData() {
		
		new AsyncTask<Void, Void, List<Order>>() {

			@Override
			protected void onPreExecute() {
				showLoading();
				super.onPreExecute();
			}

			@Override
			protected void onPostExecute(List<Order> result) {
				hideLoading();
				super.onPostExecute(result);
				if (result != null) {
					// 设置到数据适配器里面
					MyOrderAdapter adapter = new MyOrderAdapter(result);
					orders.setAdapter(adapter);
				} else {
					System.out.println("下载数据发生异常");
				}
			}


			@Override
			protected List<Order> doInBackground(Void... params) {
				List<Order> os = new ArrayList<Order>();
					String url = "http://192.168.173.1:8888/cook/app/listOrdersByClient";
					try {
						HttpClient client=new DefaultHttpClient();
				        HttpPost request;
				        request = new HttpPost(new URI(url));
				        List<NameValuePair> parameters = new ArrayList<NameValuePair>();
				        String id = sp.getString("id", null);
				        NameValuePair nameValuePairs = new BasicNameValuePair("id", id);
				        parameters.add(nameValuePairs);
						HttpEntity entity = new UrlEncodedFormEntity(parameters, "UTF-8");
						request.setEntity(entity);
				        HttpResponse response=client.execute(request);
				        //判断请求是否成功
				        if(response.getStatusLine().getStatusCode()==200){
				        entity=response.getEntity();
				        if(entity!=null){
				        String jsonstr = EntityUtils.toString(entity);
						os = getOrderDetail("data" , jsonstr);
						return os;
				       }
				     }
					
				} catch (Exception e) {
					e.printStackTrace();
				}
					return null;
					
			}

			@SuppressWarnings("null")
			private List<Order> getOrderDetail(String key , String jsonstr) {
				try {
					List<Order> messages = new ArrayList<Order>();
					JSONObject jsonObject = new JSONObject(jsonstr);
					JSONArray jsona = (JSONArray) jsonObject.getJSONArray(key);
					
					for (int i = 0; i < jsona.length(); i++) {
						JSONObject o1 = jsona.getJSONObject(i);
						Order o =new Order();
						o.setId(o1.getInt("orderId"));
						o.setOrderTotalPrice(o1.getInt("orderTotalPrice"));
						int orderCreateTime = o1.getInt("orderCreateTime");
						Date d = new Date(orderCreateTime);
						o.setOrderCreateTime("2015-"+d.getMonth()+"-"+d.getDate());
						o.setOrderDiscount(o1.getString("orderDiscount"));
						o.setOrderStatus(o1.getString("orderStatus"));
						o.setTable(o1.getJSONObject("table").getInt("tableId"));
						o.setOrderComment(o1.getString("orderComment"));
						messages.add(o);
					}
					
					return messages;
				} catch (JSONException e) {
					e.printStackTrace();
				}
				return null;
			}
		}.execute();
		
	}
	
	
	private class MyOrderAdapter extends BaseAdapter {
		private List<Order> ms;

		public MyOrderAdapter(List<Order> ms) {
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
				view = View.inflate(getApplicationContext(), R.layout.order_item, null);
			
			TextView tv_name = (TextView) view.findViewById(R.id.order_id);
			TextView tv_place = (TextView) view.findViewById(R.id.order_volume);
			TextView tv_discription = (TextView) view.findViewById(R.id.order_volume);
			tv_name.setText("订单号： "+ms.get(position).getId());
			tv_place.setText("价格： "+ms.get(position).getOrderTotalPrice()+"");
			tv_discription.setText("日期： "+ms.get(position).getOrderCreateTime());
			return view;
		}
	}
	
}
