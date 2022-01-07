/*
 *   Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 *    You may not use this file except in compliance with the
 *    SocialEngineAddOns License Agreement.
 *    You may obtain a copy of the License at:
 *    https://www.socialengineaddons.com/android-app-license
 *    The full copyright and license information is also mentioned
 *    in the LICENSE file that was distributed with this
 *    source code.
 */

package com.socialengineaddons.mobileapp.classes.modules.packages;

import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ListView;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.adapters.PackageViewAdapter;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.CurrencyUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class PackageView extends AppCompatActivity {

    private Toolbar mToolbar;
    private JSONObject mPackageInfoObject;
    private TextView mPackageTitle, mDescriptionValue;
    private String mSelectedPackageTitle;
    private int mPackageId, mListingTypeId;
    private String currentSelectedOption, mUpgradePackageUrl;
    private ArrayList<BrowseListItems> mPackageDetails;
    private ListView mPackageInfoListView;
    private boolean isPackageUpgrade = false;
    private AppConstant mAppConst;
    private Map<String, String> mPostParams;
    private String mContentString = "";
    private Bundle mBundle;
    boolean isSimpleInfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_package_view);

        mToolbar = (Toolbar)findViewById(R.id.toolbar);
        mPackageInfoListView = (ListView) findViewById(R.id.packageInfo);
        mPackageDetails = new ArrayList<>();
        mAppConst = new AppConstant(this);
        mPostParams = new HashMap<>();
        mBundle = getIntent().getExtras();
        //Fetch Current Selected Module
        currentSelectedOption = PreferencesUtils.getCurrentSelectedModule(this);
        mPackageTitle = (TextView) findViewById(R.id.package_title);

        if(getIntent() != null){
            mSelectedPackageTitle = getIntent().getStringExtra("packageTitle");
            mListingTypeId = getIntent().getIntExtra(ConstantVariables.LISTING_TYPE_ID, 0);
            if(getIntent().getStringExtra(ConstantVariables.SHIPPING_METHOD) != null){
                isSimpleInfo = true;
            }
            try {
                mPackageInfoObject = new JSONObject(getIntent().getStringExtra("packageObject"));
                mPackageId = mPackageInfoObject.optInt("package_id");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            if (getIntent().hasExtra("isPackageUpgrade")) {
                isPackageUpgrade = getIntent().getBooleanExtra("isPackageUpgrade", false);
                mUpgradePackageUrl = getIntent().getStringExtra("upgrade_url");

                try {

                    switch (currentSelectedOption) {
                        case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
                            mContentString = "event_id";
                            break;
                        case ConstantVariables.SITE_PAGE_MENU_TITLE:
                            mContentString = "page_id";
                            break;
                        case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                            mContentString = "group_id";
                            break;
                        case ConstantVariables.MLT_MENU_TITLE:
                            mContentString = "listing_id";
                            break;
                        case ConstantVariables.STORE_MENU_TITLE:
                            mContentString = "store_id";
                            break;
                    }

                    JSONObject urlParams = new JSONObject(getIntent().getStringExtra("urlParams"));
                    String mContentId = urlParams.optString(mContentString);
                    String packageId = urlParams.optString("package_id");

                    if (mContentString.equals("listing_id")) {
                        mPostParams.put(ConstantVariables.LISTING_TYPE_ID, urlParams.optString(ConstantVariables.LISTING_TYPE_ID));
                    }

                    mPostParams.put(mContentString, mContentId);
                    mPostParams.put("package_id", packageId);

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }

        setSupportActionBar(mToolbar);
        if(getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        CustomViews.createMarqueeTitle(this, mToolbar);

        /**
         * Show Package Title and Description
         */
        mPackageTitle.setText(mSelectedPackageTitle);
        mDescriptionValue = (TextView) findViewById(R.id.descriptionValue);
        if(isSimpleInfo) {
            setTitle(getResources().getString(R.string.shipping_details));
        } else {
            JSONObject descriptionObject = mPackageInfoObject.optJSONObject("description");
            if (descriptionObject != null) {
                mDescriptionValue.setText(descriptionObject.optString("value"));
            }
        }

        /**
         * Add Package Detail in List and pass in adapter
         * to show in listview
         */
        JSONArray packageParamKeys = mPackageInfoObject.names();
        for(int i = 0; i < mPackageInfoObject.length(); i++){

            String packageParamKey = packageParamKeys.optString(i);
            if(!packageParamKey.equals("package_id") && !packageParamKey.equals(mContentString) && !packageParamKey.equals("title")
                    && !packageParamKey.equals("description")){
                JSONObject paramDetails = mPackageInfoObject.optJSONObject(packageParamKey);
                if (paramDetails == null) continue;
                String value = paramDetails.optString("value");

                /* handling_type key is used in store shipping method info
                 * rest of the app price key is used */
                if((packageParamKey.equals("price") || packageParamKey.equals("handling_type")) && paramDetails.optString("currency", null) != null){
                    value = CurrencyUtils.getCurrencyConvertedValue(this, paramDetails.optString("currency"),
                                    paramDetails.optDouble("value"));
                }
                mPackageDetails.add(new BrowseListItems(packageParamKey, paramDetails.optString("label"), value));
            }
        }

        PackageViewAdapter packageViewAdapter = new PackageViewAdapter(this, mPackageDetails);
        mPackageInfoListView.setAdapter(packageViewAdapter);

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        if(!isSimpleInfo) {
            getMenuInflater().inflate(R.menu.menu_with_action_icon, menu);
            menu.findItem(R.id.submit).setTitle(getResources().getString(R.string.create));
        }
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        switch (id) {
            case R.id.submit:
                if (isPackageUpgrade) {
                    mAppConst.showProgressDialog();
                    upgradePackage();
                } else {
                    openCreateEntry();
                }
                break;
            case android.R.id.home:
                onBackPressed();
                // Playing backSound effect when user tapped on back button from tool bar.
                if (PreferencesUtils.isSoundEffectEnabled(PackageView.this)) {
                    SoundUtil.playSoundEffectOnBackPressed(PackageView.this);
                }
                return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void upgradePackage() {
        mAppConst.postJsonResponseForUrl(mUpgradePackageUrl, mPostParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mAppConst.hideProgressDialog();
                SnackbarUtils.displaySnackbarLongWithListener(mPackageInfoListView, getResources().getString(R.string.upgrade_package_success_message),
                        new SnackbarUtils.OnSnackbarDismissListener() {
                            @Override
                            public void onSnackbarDismissed() {
                                try {
                                    Intent intent = new Intent();
                                    setResult(ConstantVariables.VIEW_PAGE_CODE, intent);
                                    onBackPressed();
                                } catch (IllegalStateException e) {
                                    e.printStackTrace();
                                }
                            }
                        });
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mAppConst.hideProgressDialog();
                SnackbarUtils.displaySnackbar(mPackageInfoListView, message);
            }
        });

    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }

    private void openCreateEntry(){
        String redirectUrl = AppConstant.DEFAULT_URL;
        if(currentSelectedOption != null){
            switch (currentSelectedOption){
                case "sitereview_listing":
                    redirectUrl += "listings/create/package_id/" + mPackageId + "?listingtype_id=" + mListingTypeId;
                    break;
                case "core_main_siteevent":
                    redirectUrl += "advancedevents/create/package_id/" + mPackageId;
                    break;
                case "core_main_sitepage":
                case "sitepage":
                    redirectUrl += "sitepages/create/package_id/" + mPackageId;
                    break;
                case "core_main_sitegroup":
                    redirectUrl += "advancedgroups/create/package_id/" + mPackageId;
                    break;
                case ConstantVariables.STORE_MENU_TITLE:
                    redirectUrl += "sitestore/create/package_id/" + mPackageId;
                    break;
                    default:
                        redirectUrl = mBundle.getString(ConstantVariables.URL_STRING) + "/package_id/" + mPackageId;

            }
        }
        Intent createIntent = new Intent(this, CreateNewEntry.class);
        mBundle.putString(ConstantVariables.CREATE_URL, redirectUrl);
        createIntent.putExtras(mBundle);
        createIntent.putExtra(ConstantVariables.LISTING_TYPE_ID, mListingTypeId);
        createIntent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, currentSelectedOption);
        startActivityForResult(createIntent, ConstantVariables.CREATE_REQUEST_CODE);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == ConstantVariables.CREATE_REQUEST_CODE) {
            Intent intent = new Intent();
            setResult(ConstantVariables.VIEW_PAGE_CODE, intent);
            finish();
        }
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        MenuItem submit = menu.findItem(R.id.submit);
        if (submit != null) {
            Drawable drawable = submit.getIcon();
            drawable.setColorFilter(ContextCompat.getColor(this, R.color.textColorPrimary), PorterDuff.Mode.SRC_ATOP);
        }
        return super.onPrepareOptionsMenu(menu);
    }
}
