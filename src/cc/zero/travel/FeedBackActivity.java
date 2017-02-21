package cc.zero.travel;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;

public class FeedBackActivity extends Activity {

	ImageButton back;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		setContentView(R.layout.feedback);
		super.onCreate(savedInstanceState);
		back = (ImageButton) this.findViewById(R.id.back_button);
		back.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				finish();
				
			}
		});
	}

	
}
