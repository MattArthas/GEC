package cc.zero.travel.util;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;

/**
 *
 * 第一个参数 就是图片下载路径的url
 * 第二个参数是 下载的进度 
 * 第三个参数就是异步任务执行完毕后的返回值
 * @author Administrator
 *
 */
public class LoadImageAsynTask extends AsyncTask<String, Void, Bitmap> {
	LoadImageAsynTaskCallback loadImageAsynTaskCallback;
	
	
	
	public LoadImageAsynTask(LoadImageAsynTaskCallback loadImageAsynTaskCallback) {
		this.loadImageAsynTaskCallback = loadImageAsynTaskCallback;
	}

	public interface LoadImageAsynTaskCallback{
	   public void	beforeLoadImage();
	   public void afterLoadImage(Bitmap bitmap);
	}

	/**
	 * 当异步任务执行之前调用
	 */
	@Override
	protected void onPreExecute() {
		//初始化的操作具体怎么去实现, LoadImageAsynTask 不知道
		// 需要让调用这个 LoadImageAsynTask 的人 去实现 
		loadImageAsynTaskCallback.beforeLoadImage();
		super.onPreExecute();
	}

	/**
	 * 异步任务执行之后调用
	 */
	@Override
	protected void onPostExecute(Bitmap result) {
		loadImageAsynTaskCallback.afterLoadImage(result);
		super.onPostExecute(result);
	}

	/**
	 * 后台子线程运行的异步任务 
	 * String... params 可变长度的参数 
	 */
	@Override
	protected Bitmap doInBackground(String... params) {
		try {
			String path = params[0];
			URL url = new URL(path);
			HttpURLConnection conn =  (HttpURLConnection) url.openConnection();
			InputStream is = conn.getInputStream();
			return  BitmapFactory.decodeStream(is);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		
	}

}
