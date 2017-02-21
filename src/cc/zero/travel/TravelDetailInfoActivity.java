package cc.zero.travel;

import java.io.InputStream;
import java.lang.ref.SoftReference;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
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
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cc.zero.travel.model.Dishes;
import cc.zero.travel.model.SetMeal;

public class TravelDetailInfoActivity extends BaseActivity implements OnClickListener{

	protected static final int BUY_SUCCESS=11;
	protected static final int BUY_FAIL=12;
	
	private int id;
	private ListView lv_spot;
	private TextView tv_name;
	private TextView tv_startPlace;
	private TextView tv_description;
	private TextView tv_remark;
	private TextView tv_lastDate;
	private TextView tv_startDate;
	private TextView tv_travLineType;
	private TextView tv_crPrice;
	private TextView tv_plan;
	private TextView tv_rtPrice;
	private Button bt_buy;
	private Bitmap bitmap;
	private ImageButton back;
	private SharedPreferences sp;
	Map<String, SoftReference<Bitmap>> iconCache;
	ProgressDialog pd ;
	
	private Handler handler = new Handler(){
		@Override
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			pd.dismiss();
			switch (msg.what) {
			case BUY_SUCCESS:
				showToast("添加成功");
				Intent  myInfoIntent = new Intent(TravelDetailInfoActivity.this,MyActivity.class);
				startActivity(myInfoIntent);
				break;	
			case BUY_FAIL:
				Toast.makeText(getApplicationContext(), "密码错误", 200).show();
				break;		
			}
			
		}
	};
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		setContentView(R.layout.travel_detail);
		super.onCreate(savedInstanceState);
	}

	@Override
	public void setupView() {
		back = (ImageButton) this.findViewById(R.id.back_button);
		loading = (RelativeLayout) this.findViewById(R.id.loading);
		id = getIntent().getIntExtra("id", 0);
		lv_spot = (ListView) this.findViewById(R.id.spotlistview);
		tv_name = (TextView) this.findViewById(R.id.tra_Detai_Name);
		tv_startPlace = (TextView) this.findViewById(R.id.tra_Detai_StartPlace);
		tv_description = (TextView) this.findViewById(R.id.tra_Detai_Discription);
		tv_remark = (TextView) this.findViewById(R.id.tra_Detai_Remark);
		tv_travLineType = (TextView) this.findViewById(R.id.tra_Detai_Type);
		tv_crPrice = (TextView) this.findViewById(R.id.tra_Detai_CRprice);
		bt_buy = (Button) this.findViewById(R.id.buy);
		tv_rtPrice = (TextView) this.findViewById(R.id.tra_Detai_RTprice);
        sp = getSharedPreferences("config", Context.MODE_PRIVATE);
        pd = new ProgressDialog(this);
		iconCache = new HashMap<String, SoftReference<Bitmap>>();
		
	}

	@Override
	public void setListener() {
		back.setOnClickListener(this);
		bt_buy.setOnClickListener(this);
	}

	@Override
	public void fillData() {
		
		new AsyncTask<Void, Void, Map>() {

			@Override
			protected void onPreExecute() {
				showLoading();
				super.onPreExecute();
			}

			@Override
			protected void onPostExecute(Map result) {
				hideLoading();
				super.onPostExecute(result);
				if (result != null) {
					// 设置到数据适配器里面
					setData(result);
					MySpotAdapter adapter = new MySpotAdapter((List<Dishes>) result.get("dishes"));
					lv_spot.setAdapter(adapter);
				} else {
					System.out.println("下载数据发生异常");
				}
			}

			private void setData(Map result) {
				SetMeal t = (SetMeal) result.get("setMeal");
				tv_name.setText("套餐名： "+t.getSetMealName());
				tv_startPlace.setText("价格： "+t.getSetMealPrice()+"");
				tv_description.setText("销量： "+t.getSetMealSaleVolume()+"");
				tv_remark.setText("简介： "+t.getSetMealIntroduce());
				tv_crPrice.setText("评论： "+t.getSetMealComment());
//				tv_startDate.setText("开始日期： ");
//				tv_travLineType.setText("路线类型： ");
//				tv_crPrice.setText("儿童票价： ");
//				tv_plan.setText("计划： ");
//				tv_rtPrice.setText("成人票价： ");
				
			}

			@Override
			protected Map doInBackground(Void... params) {
				Map maps = new HashMap();
					String url = "http://192.168.173.1:8888/cook/app/showSetMealDetail";
					try {
						HttpClient client=new DefaultHttpClient();
				        HttpPost request;
				        request = new HttpPost(new URI(url));
				        List<NameValuePair> parameters = new ArrayList<NameValuePair>();
				        NameValuePair nameValuePairs = new BasicNameValuePair("id", id+"");
				        parameters.add(nameValuePairs);
						HttpEntity entity = new UrlEncodedFormEntity(parameters, "UTF-8");
						request.setEntity(entity);
				        HttpResponse response=client.execute(request);
				        //判断请求是否成功
				        if(response.getStatusLine().getStatusCode()==200){
				        entity=response.getEntity();
				        if(entity!=null){
				        String jsonstr = EntityUtils.toString(entity);
						maps = getCookDetail("data","disheses", jsonstr);
						return maps;
				       }
				     }
					
				} catch (Exception e) {
					e.printStackTrace();
				}
					return null;
					
			}

			@SuppressWarnings("null")
			private Map getCookDetail(String key1, String key2, String jsonstr) {
				try {
					Map map = new HashMap();
					JSONObject jsonObject = new JSONObject(jsonstr);
					JSONObject o1 = (JSONObject) jsonObject.getJSONObject(key1);
					SetMeal sm =new SetMeal();
					sm.setSetMealId(o1.getInt("setMealId"));
					sm.setSetMealName(o1.getString("setMealName"));
					sm.setSetMealPrice(o1.getInt("setMealPrice"));  
					sm.setSetMealSaleVolume(o1.getInt("setMealSaleVolume")); 
					sm.setSetMealIntroduce(o1.getString("setMealIntroduce")); 
					sm.setSetMealComment(o1.getString("setMealComment")); 
					
					JSONArray o3 = o1.getJSONArray(key2);
					List<Dishes> ss = new ArrayList<Dishes>();
					for (int i = 0; i < o3.length(); i++) {
						JSONObject sObject = o3.getJSONObject(i);
						Dishes s = new Dishes();
						s.setDishesName(sObject.getString("dishesName"));
						s.setDishesPrice(sObject.getInt("dishesPrice"));
						s.setDishesSalesVolume(sObject.getInt("dishesSalesVolume"));
						s.setPicName(sObject.getJSONObject("picture").getString("newName"));
						ss.add(s);
					}
					map.put("setMeal", sm);
					map.put("dishes", ss);
					return map;
				} catch (JSONException e) {
					e.printStackTrace();
				}
				return null;
			}
		}.execute();
		
	}
	
	
	private class MySpotAdapter extends BaseAdapter {
		private List<Dishes> ms;

		public MySpotAdapter(List<Dishes> ms) {
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
				view = View.inflate(getApplicationContext(), R.layout.spot_item, null);
			
			ImageView iv = (ImageView) view.findViewById(R.id.image);
			String picname = ms.get(position).getPicName();
			String imagepath = "http://192.168.173.1:8888/cook/resource/image/dishes/"+picname;
			getPic(iv,imagepath);
			
			TextView tv_name = (TextView) view.findViewById(R.id.spot_name);
			TextView tv_place = (TextView) view.findViewById(R.id.spot_place);
			TextView tv_discription = (TextView) view.findViewById(R.id.spot_discription);
			tv_name.setText("菜品名： "+ms.get(position).getDishesName());
			tv_place.setText("价格： "+ms.get(position).getDishesPrice()+"");
			tv_discription.setText("销量： "+ms.get(position).getDishesSalesVolume()+"");
			return view;
		}
		
		
		
		private void getPic(final ImageView iv,final String imagepath) {
			
			new AsyncTask<Void, Void, Bitmap>(){

				
				@Override
				protected void onPostExecute(Bitmap result) {
					iv.setImageBitmap(result);
					super.onPostExecute(result);
				}

				@Override
				protected void onPreExecute() {
					iv.setImageResource(R.drawable.image_default);
					super.onPreExecute();
				}

				@Override
				protected Bitmap doInBackground(Void... params) {
					try {
						URL url = new URL(imagepath);
						HttpURLConnection conn =  (HttpURLConnection) url.openConnection();
						InputStream is = conn.getInputStream();
						bitmap = BitmapFactory.decodeStream(is);
				} catch (Exception e) {
					e.printStackTrace();
				}
					return bitmap;
				}
				
			}.execute();
		
		}
		
	}
	


	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.back_button:
			finish();
			break;

		case R.id.buy:
			
			if(isUserLogin()){
				String user_id = sp.getString("id", null);
				buy(id+"",user_id);
				
			}else{
				Intent intent = new Intent(this,LoginActivity.class);
				startActivity(intent);
			}
			break;
		}
		
	}
	
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
				data.put("type", "setMeal");
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
	
}





