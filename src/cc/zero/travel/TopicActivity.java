package cc.zero.travel;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
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
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cc.zero.travel.model.Dishes;
import cc.zero.travel.util.MsgListView;
import cc.zero.travel.util.MsgListView.OnRefreshListener;

public class TopicActivity extends BaseListActivity implements OnItemClickListener{

	private MsgListView topics;
	private boolean isloading=false;
	private Bitmap bitmap;
	ProgressDialog pd;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		setContentView(R.layout.topic);
		super.onCreate(savedInstanceState);
	}

	@Override
	public void setupView() {
		loading = (RelativeLayout) this.findViewById(R.id.loading);
		topics = (MsgListView) this.findViewById(android.R.id.list);
		pd = new ProgressDialog(this);
	}

	@Override
	public void fillData() {
		if(isloading){
			showToast("正在下载数据中");
			return;
		}
		
		new AsyncTask<Void, Void, List<Dishes>>() {

			@Override
			protected void onPreExecute() {
				showLoading();
				isloading = true;
				super.onPreExecute();
			}

			@Override
			protected void onPostExecute(List<Dishes> result) {
				hideLoading();
				super.onPostExecute(result);
				if (result != null) {
					// 设置到数据适配器里面
					MyMessageBoardAdapter adapter = new MyMessageBoardAdapter(result);
					topics.setAdapter(adapter);
				} else {
					showToast("下载数据发生异常");
				}
				isloading =false;
			}

			@Override
			protected List<Dishes> doInBackground(Void... params) {
					List<Dishes> ts = new ArrayList<Dishes>();
					String url = "http://192.168.173.1:8888/cook/app/listDishes";
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
						ts = getTopics("data" , jsonstr);
						return ts;
				       }
				     }
					
				} catch (Exception e) {
					e.printStackTrace();
					return null;
				}
					return ts;
			}
		}.execute();
	}
	
	public static List<Dishes> getTopics(String key , String jsonString) throws Exception{
		List<Dishes> mes = new ArrayList<Dishes>();
		//jsonObject={"persons":[{"address":"香港","id":1001,"name":"刘德华"},{"address":"韩国","id":1002,"name":"宋慧乔"}]} 
		JSONObject jsonObject = new JSONObject(jsonString);
		//jsonArray =[{"address":"香港","id":1001,"name":"刘德华"},{"address":"韩国","id":1002,"name":"宋慧乔"}]
		JSONArray jsonArray = jsonObject.getJSONArray(key);   //此处key = persons,取得
		for (int i = 0; i < jsonArray.length(); i++) {
			JSONObject topicObject = jsonArray.getJSONObject(i);
			Dishes t = new Dishes();
			t.setDishesId(topicObject.getInt("dishesId"));
			t.setDishesName(topicObject.getString("dishesName"));
			t.setDishesPrice(topicObject.getInt("dishesPrice"));
			t.setDishesSalesVolume(topicObject.getInt("dishesSalesVolume"));
			t.setDishesCategory(topicObject.getJSONObject("dishesCategory").getString("dishesCategoryName"));
			t.setPicName(topicObject.getJSONObject("picture").getString("newName"));
			t.setDishesIntroduce(topicObject.getString("dishesIntroduce"));
			t.setDishesComment(topicObject.getString("dishesComment"));
			mes.add(t);			
		}
		return mes;
	}
	
	private class MyMessageBoardAdapter extends BaseAdapter {
		private List<Dishes> ms;

		public MyMessageBoardAdapter(List<Dishes> ms) {
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

				view = View.inflate(getApplicationContext(), R.layout.spot_item, null);
			}else{
				view = convertView;
			}
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

	@Override
	public void setListener() {
		topics.setOnItemClickListener(this);
		
		topics.setonRefreshListener(new OnRefreshListener() {  
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
                        topics.onRefreshComplete();  
                    }  
                }.execute();  
            }  
        });  
		topics.setItemsCanFocus(false);              
		topics.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
		
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		
		Dishes t =(Dishes) topics.getItemAtPosition(position);
		Intent intent = new Intent(this,TopicDetailActivity.class);
		intent.putExtra("id",t.getDishesId());
		intent.putExtra("dishesName",t.getDishesName());
		intent.putExtra("dishesPrice",t.getDishesPrice());
		intent.putExtra("dishesSalesVolume",t.getDishesSalesVolume());
		intent.putExtra("dishesCategoryName",t.getDishesCategory());
		intent.putExtra("newName",t.getPicName());
		intent.putExtra("dishesIntroduce",t.getDishesIntroduce());
		intent.putExtra("dishesComment",t.getDishesComment());
		startActivity(intent);
	}


}
