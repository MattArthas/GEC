package cc.zero.travel;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class testActivity1 extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		TextView tv = new TextView(this);
		tv.setText("d点点滴滴等等a");
		setContentView(tv);
	}
}
