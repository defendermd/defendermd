package com.socialengineaddons.mobileapp.classes.modules.store;

import android.content.Context;
import android.support.v4.content.ContextCompat;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.RelativeLayout;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.formgenerator.FormActivity;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

public class FilterPage extends FormActivity {
    private AppConstant mAppConst;
    private HashMap<String, String> postParams;
    private Toolbar mToolbar;
    private Context mContext;
    private RelativeLayout filterView;
    private String currentSelectedOption;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_filter_page);
        /* Create Back Button On Action Bar **/
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mToolbar.setNavigationIcon(ContextCompat.getDrawable(this,R.drawable.ic_clear_white_24dp));
        setSupportActionBar(mToolbar);
        if(getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
        mAppConst = new AppConstant(this);
        mContext = this;
//Fetch Current Selected Module
        currentSelectedOption = PreferencesUtils.getCurrentSelectedModule(mContext);
        filterView = (RelativeLayout)findViewById(R.id.filter_view);

        mAppConst.getJsonResponseFromUrl(UrlUtil.PRODUCT_FILTER_URL, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                findViewById(R.id.progressBar).setVisibility(View.GONE);
                filterView.addView(generateForm(jsonObject, true, currentSelectedOption));
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                findViewById(R.id.progressBar).setVisibility(View.GONE);
                SnackbarUtils.displaySnackbarLongWithListener(filterView, message,
                        new SnackbarUtils.OnSnackbarDismissListener() {
                            @Override
                            public void onSnackbarDismissed() {
                                finish();
                            }
                        });
            }
        });
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        switch (id) {
            case android.R.id.home:
                onBackPressed();
                // Playing backSound effect when user tapped on back button from tool bar.
                if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
                    SoundUtil.playSoundEffectOnBackPressed(mContext);
                }
                overridePendingTransition(R.anim.push_down_in,R.anim.push_down_out);
                return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
