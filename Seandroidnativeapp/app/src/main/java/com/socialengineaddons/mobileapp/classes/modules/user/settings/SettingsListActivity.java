/*
 *   Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 *   You may not use this file except in compliance with the
 *   SocialEngineAddOns License Agreement.
 *   You may obtain a copy of the License at:
 *   https://www.socialengineaddons.com/android-app-license
 *   The full copyright and license information is also mentioned
 *   in the LICENSE file that was distributed with this
 *   source code.
 */

package com.socialengineaddons.mobileapp.classes.modules.user.settings;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AppOpsManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.SwitchCompat;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.view.MenuItem;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.ui.BaseButton;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Text;

public class SettingsListActivity extends AppCompatActivity implements View.OnClickListener{

    private TextView mGeneralSettingLabel, mPrivacySettingLabel, mNetworkSettingLabel, mSoundSettingLabel, mMobileInfoSettingLabel;
    private TextView mPasswordLabel, mDeleteLabel,mNotificationSettingLabel, mSubscriptionSettingLabel, mVideoAutoPlayLabel;
    private RelativeLayout mGeneralSettings, mPrivacySettings, mNotificationSettings, mSubscriptionSettings;
    private RelativeLayout mNetworksSettings, mPasswordSettings, mDeleteAccount, mSoundSetting, mMobileInfoSettings,
            mVideoAutoPlaySettings, mPipModeSettings;
    private SwitchCompat mSoundEffectSwitch;
    private View mDeleteAccountBottomLine;
    private Typeface fontIcon;
    private Context mContext;
    private AppConstant mAppConst;
    private View mRootView;
    private BottomSheetDialog bottomSheetDialog;
    private Bundle mBundle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings_list);

        fontIcon = GlobalFunctions.getFontIconTypeFace(this);
        mContext = this;

        mAppConst = new AppConstant(mContext);
        mBundle = new Bundle();

        Toolbar mToolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(mToolBar);

        if(getSupportActionBar() != null){
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        CustomViews.createMarqueeTitle(this, mToolBar);

        getUserSettingsFields();

        makeRequest();

    }

    private void getUserSettingsFields(){

        mRootView = findViewById(R.id.rootView);

        TextView mGeneralNextIcon = findViewById(R.id.general_nextIcon);
        TextView mPrivacyNextIcon = findViewById(R.id.privacy_nextIcon);
        TextView mNetworksNextIcon = findViewById(R.id.networks_nextIcon);
        TextView mNotificationsNextIcon = findViewById(R.id.notifications_nextIcon);
        TextView mPasswordNextIcon = findViewById(R.id.password_nextIcon);
        TextView mDeleteNextIcon = findViewById(R.id.delete_nextIcon);
        TextView mSubscriptionNextIcon = findViewById(R.id.subscription_nextIcon);
        TextView mMobileInfoNextIcon = findViewById(R.id.mobile_info_nextIcon);
        TextView mVideoAutoPlayNextIcon = findViewById(R.id.video_play_nextIcon);
        TextView mPipNextIcon = findViewById(R.id.pip_nextIcon);

        mGeneralSettingLabel = findViewById(R.id.general_setting_label);
        mPrivacySettingLabel = findViewById(R.id.privacy_setting_label);
        mNetworkSettingLabel = findViewById(R.id.network_setting_label);
        mNotificationSettingLabel = findViewById(R.id.notification_setting_label);
        mPasswordLabel = findViewById(R.id.password_setting_label);
        mDeleteLabel = findViewById(R.id.delete_account_label);
        mSoundSettingLabel = findViewById(R.id.sound_setting_label);
        mSubscriptionSettingLabel = findViewById(R.id.subscription_label);
        mMobileInfoSettingLabel = findViewById(R.id.mobile_info_setting_label);
        mVideoAutoPlayLabel = findViewById(R.id.video_play_label);

        mGeneralSettings = findViewById(R.id.settings_general);
        mPrivacySettings =findViewById(R.id.settings_privacy);
        mNotificationSettings = findViewById(R.id.settings_notifications);
        mNetworksSettings = findViewById(R.id.settings_networks);
        mPasswordSettings = findViewById(R.id.settings_password);
        mDeleteAccount = findViewById(R.id.settings_delete_account);
        mSoundSetting = findViewById(R.id.sound_settings);
        mSubscriptionSettings = findViewById(R.id.settings_subscription);
        mSoundEffectSwitch = findViewById(R.id.sound_setting_switch);
        mSoundEffectSwitch.setChecked(PreferencesUtils.isSoundEffectEnabled(mContext));
        mDeleteAccountBottomLine = findViewById(R.id.delete_accound_bottom_line);
        mMobileInfoSettings = findViewById(R.id.settings_mobile_info);
        mVideoAutoPlaySettings = findViewById(R.id.settings_video_play);
        mPipModeSettings = findViewById(R.id.settings_pip_mode);

        mGeneralSettings.setOnClickListener(this);
        mPrivacySettings.setOnClickListener(this);
        mNotificationSettings.setOnClickListener(this);
        mNetworksSettings.setOnClickListener(this);
        mPasswordSettings.setOnClickListener(this);
        mDeleteAccount.setOnClickListener(this);
        mSubscriptionSettings.setOnClickListener(this);
        mMobileInfoSettings.setOnClickListener(this);
        mVideoAutoPlaySettings.setOnClickListener(this);
        mPipModeSettings.setOnClickListener(this);


        mGeneralNextIcon.setTypeface(fontIcon);
        mPrivacyNextIcon.setTypeface(fontIcon);
        mNetworksNextIcon.setTypeface(fontIcon);
        mNotificationsNextIcon.setTypeface(fontIcon);
        mPasswordNextIcon.setTypeface(fontIcon);
        mDeleteNextIcon.setTypeface(fontIcon);
        mSubscriptionNextIcon.setTypeface(fontIcon);
        mMobileInfoNextIcon.setTypeface(fontIcon);
        mVideoAutoPlayNextIcon.setTypeface(fontIcon);
        mPipNextIcon.setTypeface(fontIcon);

        mGeneralNextIcon.setText("\uf054");
        mPrivacyNextIcon.setText("\uf054");
        mNetworksNextIcon.setText("\uf054");
        mNotificationsNextIcon.setText("\uf054");
        mPasswordNextIcon.setText("\uf054");
        mDeleteNextIcon.setText("\uf054");
        mSubscriptionNextIcon.setText("\uf054");
        mMobileInfoNextIcon.setText("\uf054");
        mVideoAutoPlayNextIcon.setText("\uf054");
        mPipNextIcon.setText("\uf054");
    }

    private void makeRequest(){

        mAppConst.getJsonResponseFromUrl(UrlUtil.ACCOUNT_SETTINGS, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                findViewById(R.id.progressBar).setVisibility(View.GONE);

                if(jsonObject != null){
                    JSONArray responseArray = jsonObject.optJSONArray("response");
                    if(responseArray != null && responseArray.length() != 0){
                        for(int i = 0; i < responseArray.length(); i++){
                            JSONObject settingObject = responseArray.optJSONObject(i);
                            String setting_name = settingObject.optString("name");
                            String settingLabel = settingObject.optString("label").trim();
                            switch(setting_name){

                                case "general":
                                    mGeneralSettings.setVisibility(View.VISIBLE);
                                    mGeneralSettingLabel.setText(settingLabel);
                                    break;

                                case "privacy":
                                    mPrivacySettings.setVisibility(View.VISIBLE);
                                    mPrivacySettingLabel.setText(settingLabel);
                                    break;

                                case "network":
                                    mNetworksSettings.setVisibility(View.VISIBLE);
                                    mNetworkSettingLabel.setText(settingLabel);
                                    break;

                                case "notification":
                                    mNotificationSettings.setVisibility(View.VISIBLE);
                                    mNotificationSettingLabel.setText(settingLabel);
                                    break;

                                case "password":
                                    mPasswordSettings.setVisibility(View.VISIBLE);
                                    mPasswordLabel.setText(settingLabel);
                                    break;

                                case "delete":
                                    mDeleteAccount.setVisibility(View.VISIBLE);
                                    mDeleteLabel.setText(settingLabel);
                                    break;

                                case "sound":
                                    mSoundSetting.setVisibility(View.VISIBLE);
                                    findViewById(R.id.mobileInfo_bottom_line).setVisibility(View.VISIBLE);
                                    mSoundSettingLabel.setText(settingLabel);
                                    mSoundEffectSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                                        @Override
                                        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                                            PreferencesUtils.setSoundEffectValue(mContext, isChecked);

                                        }
                                    });
                                    break;

                                case "subscription":
                                    mSubscriptionSettings.setVisibility(View.VISIBLE);
                                    mSubscriptionSettingLabel.setText(settingLabel);
                                    mDeleteAccountBottomLine.setVisibility(View.VISIBLE);
                                    break;

                                case "mobileinfo":
                                    mMobileInfoSettings.setVisibility(View.VISIBLE);
                                    findViewById(R.id.subscription_bottom_line).setVisibility(View.VISIBLE);
                                    mMobileInfoSettingLabel.setText(settingLabel);
                                    mBundle.putInt("otpLength", settingObject.optInt("length"));
                                    mBundle.putInt("keyboardType", settingObject.optInt("type"));
                                    break;

                                default:
                                    break;
                            }
                        }
                    }
                }
                mVideoAutoPlaySettings.setVisibility(View.VISIBLE);

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && ConstantVariables.ENABLE_PIP == 1) {
                    mPipModeSettings.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                findViewById(R.id.progressBar).setVisibility(View.GONE);
                if (isRetryOption) {
                    SnackbarUtils.displaySnackbarWithAction(mContext, mRootView, message,
                            () -> {
                                findViewById(R.id.progressBar).setVisibility(View.VISIBLE);
                                makeRequest();
                            });
                } else {
                    SnackbarUtils.displaySnackbar(mRootView, message);
                }

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
        if (id == android.R.id.home) {
            onBackPressed();
            // Playing backSound effect when user tapped on back button from tool bar.
            if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
                SoundUtil.playSoundEffectOnBackPressed(mContext);
            }
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onClick(View view) {

        int id = view.getId();
        Intent settingsIntent = null;
        String url = null;
        if (id != R.id.settings_mobile_info) {
            settingsIntent = new Intent(mContext, MemberSettingsActivity.class);
        }
        switch (id){

            case R.id.settings_general:
                url = AppConstant.DEFAULT_URL + "members/settings/general?facebookTwitterIntegrate=1";
                settingsIntent.putExtra("selected_option", "settings_general");
                settingsIntent.putExtra("title", getResources().getString(R.string.general_settings));
                break;

            case R.id.settings_privacy:
                url = AppConstant.DEFAULT_URL + "members/settings/privacy?getBlockedUsers=1";
                settingsIntent.putExtra("selected_option", "settings_privacy");
                settingsIntent.putExtra("title", getResources().getString(R.string.privacy_settings));
                break;

            case R.id.settings_notifications:
                url = AppConstant.DEFAULT_URL + "members/settings/notifications";
                settingsIntent.putExtra("selected_option", "settings_notifications");
                settingsIntent.putExtra("title", getResources().getString(R.string.notification_settings));
                break;

            case R.id.settings_networks:
                url = AppConstant.DEFAULT_URL + "members/settings/network";
                settingsIntent.putExtra("selected_option", "settings_networks");
                settingsIntent.putExtra("title", getResources().getString(R.string.network_settings));
                break;

            case R.id.settings_password:
                url = AppConstant.DEFAULT_URL + "members/settings/password";
                settingsIntent.putExtra("selected_option", "settings_password");
                settingsIntent.putExtra("title", getResources().getString(R.string.change_password_settings));
                break;

            case R.id.settings_delete_account:
                url = AppConstant.DEFAULT_URL + "members/settings/delete";
                settingsIntent.putExtra("selected_option", "settings_delete_account");
                settingsIntent.putExtra("title", getResources().getString(R.string.delete_account_settings));
                break;

            case R.id.settings_subscription:
                url = AppConstant.DEFAULT_URL + "/members/settings/subscriptions";
                settingsIntent.putExtra("selected_option", "settings_subscription");
                settingsIntent.putExtra("title", getResources().getString(R.string.subscription_settings));
                break;

            case R.id.settings_mobile_info:
                settingsIntent = new Intent(mContext, MobileInfoSetting.class);
                settingsIntent.putExtra("title",getResources().getString(R.string.mobile_info_settings));
                break;

            case R.id.settings_video_play:
                settingsIntent = null;
                initializeVideoBottomSheet(true);
                break;

            case R.id.settings_pip_mode:
                settingsIntent = null;
                initializeVideoBottomSheet(false);
                break;

            case R.id.pip_settings_button:
                settingsIntent = null;
                Intent intent = new Intent("android.settings.PICTURE_IN_PICTURE_SETTINGS", Uri.parse("package:" + mContext.getPackageName()));
                startActivity(intent);
                break;

        }

        if (settingsIntent != null) {
            settingsIntent.putExtra("url", url);
            settingsIntent.putExtras(mBundle);
            startActivity(settingsIntent);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }

    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (bottomSheetDialog != null && bottomSheetDialog.isShowing()) {
            bottomSheetDialog.dismiss();
        }
    }


    /* Method for display video auto play settings in bottomsheet */
    private void initializeVideoBottomSheet(boolean isAutoPlay) {


        View inflatedView = ((Activity) mContext).getLayoutInflater().inflate(R.layout.video_auto_play_settings_view, null);
        inflatedView.setBackgroundResource(R.color.white);

        bottomSheetDialog = new BottomSheetDialog(mContext);
        bottomSheetDialog.setContentView(inflatedView);
        bottomSheetDialog.show();

        TextView tvDescription = inflatedView.findViewById(R.id.description);
        TextView tvTitle = inflatedView.findViewById(R.id.title);
        TextView tvOptionBoth = inflatedView.findViewById(R.id.option_1);
        TextView tvOnlyWifi = inflatedView.findViewById(R.id.option_2);
        TextView tvNever = inflatedView.findViewById(R.id.option_3);

        String description = "", title = "";

        if (isAutoPlay) {

            TextView tvChooseOptionHeader = inflatedView.findViewById(R.id.choose_option_header);
            tvChooseOptionHeader.setVisibility(View.VISIBLE);
            tvOptionBoth.setVisibility(View.VISIBLE);
            tvOnlyWifi.setVisibility(View.VISIBLE);
            tvNever.setVisibility(View.VISIBLE);

            title = getResources().getString(R.string.video_auto_play_text);
            description = getResources().getString(R.string.video_auto_play_description_1)
                    + "<br><br>" +  getResources().getString(R.string.video_auto_play_description_2 )
                    + "<br><br>" + getResources().getString(R.string.video_auto_play_description_3);

            tvDescription.setText(GlobalFunctions.getHtmlModeText(description));

            Drawable checkIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_check_white_24dp);
            checkIcon.mutate();
            checkIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor), PorterDuff.Mode.SRC_ATOP);


            if (PreferencesUtils.getVideoAutoPlaySetting(mContext).equals("both")) {
                tvOptionBoth.setCompoundDrawablesWithIntrinsicBounds(null, null, checkIcon, null);
            } else if (PreferencesUtils.getVideoAutoPlaySetting(mContext).equals("wifi")) {
                tvOnlyWifi.setCompoundDrawablesWithIntrinsicBounds(null, null, checkIcon, null);
            } else {
                tvNever.setCompoundDrawablesWithIntrinsicBounds(null, null, checkIcon, null);
            }

            tvOptionBoth.setOnClickListener(v -> {
                displayCheckIconOnSelectedView("both", checkIcon, tvOptionBoth, tvOnlyWifi, tvNever);
            });

            tvOnlyWifi.setOnClickListener(v -> {
                displayCheckIconOnSelectedView("only_wifi", checkIcon, tvOnlyWifi, tvOptionBoth, tvNever);
            });

            tvNever.setOnClickListener(v -> {
                displayCheckIconOnSelectedView("never", checkIcon, tvNever, tvOnlyWifi, tvOptionBoth);
            });

        } else {

            tvOptionBoth.setVisibility(View.GONE);
            tvOnlyWifi.setVisibility(View.GONE);
            tvNever.setVisibility(View.GONE);

            title = getResources().getString(R.string.pip_text);
            description = getResources().getString(R.string.pip_settings_description);
            tvDescription.setText(description);

            RelativeLayout headerView = inflatedView.findViewById(R.id.header_view);
            headerView.setBackgroundColor(ContextCompat.getColor(mContext, R.color.white));
            tvTitle.setTextColor(ContextCompat.getColor(mContext, R.color.themeButtonColor));

            SwitchCompat switchCompat = inflatedView.findViewById(R.id.enable_pip);
            switchCompat.setChecked(PreferencesUtils.isPipModeEnabled(mContext));
            switchCompat.setVisibility(View.VISIBLE);

            switchCompat.setOnCheckedChangeListener((buttonView, isChecked) -> {

                if (PreferencesUtils.isPipModeEnabled(mContext) != isChecked) {
                    PreferencesUtils.setPipModeEnable(mContext, isChecked);
                    PreferencesUtils.updatePipUserPopupDisplayed(mContext, false);
                    PreferencesUtils.updatePipPermissionPopupDisplayed(mContext, false);
                }
            });

            if (!canEnterPiPMode()) {
                inflatedView.findViewById(R.id.pip_system_settings).setVisibility(View.VISIBLE);
                BaseButton settingsButton = inflatedView.findViewById(R.id.pip_settings_button);
                settingsButton.setOnClickListener(this);
            }

        }

        tvTitle.setText(title);
    }

    @TargetApi(Build.VERSION_CODES.O)
    public boolean canEnterPiPMode() {
        AppOpsManager appOpsManager = (AppOpsManager) getSystemService(Context.APP_OPS_SERVICE);
        return (AppOpsManager.MODE_ALLOWED== appOpsManager.checkOpNoThrow(AppOpsManager.OPSTR_PICTURE_IN_PICTURE, android.os.Process.myUid(), mContext.getPackageName()));
    }


    /* Method for display check icon on selected menu (video auto play settings) */
    public void displayCheckIconOnSelectedView(String type, Drawable checkIcon, TextView selectedView, TextView nSelectedView1, TextView nSelectedView2){
        PreferencesUtils.setVideoAutoPlaySetting(mContext, type);
        selectedView.setCompoundDrawablesWithIntrinsicBounds(null, null, checkIcon, null);
        nSelectedView1.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
        nSelectedView2.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
    }
}
