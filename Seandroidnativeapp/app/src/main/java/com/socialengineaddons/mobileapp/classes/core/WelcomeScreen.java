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

package com.socialengineaddons.mobileapp.classes.core;


import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.TypedValue;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.load.resource.gif.GifDrawable;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.Target;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.DataStorage;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.startscreens.HomeScreen;
import com.socialengineaddons.mobileapp.classes.core.startscreens.NewHomeScreen;

import org.json.JSONException;
import org.json.JSONObject;


public class WelcomeScreen extends AppCompatActivity {

    private AppConstant mAppConst;
    private Context mContext;
    private Bundle mBundle;
    private boolean isServerDataUpdated = false, isRedirectionTimeComplete = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_welcome_screen);
        mContext = this;

        //ToDo enable it for testing
//        PreferencesUtils.setShowCaseViewPref(mContext, false, false, false, false,
//                false, false, false, false, false, false);

        mAppConst = new AppConstant(mContext);
        getAppSettings();

        getMultiCurrency();

        //TODO
//        GlobalFunctions.updateAndroidSecurityProvider(this);

        TextView mLoadingText = (TextView) findViewById(R.id.loading_text);
        mLoadingText.setText(mContext.getResources().getString(R.string.loading_text) + "…");

        ImageView ivScreen = (ImageView) findViewById(R.id.iv_screen);
        TypedValue value = new TypedValue();
        getResources().getValue(R.mipmap.screen, value, true);
        boolean isScreenGif = value.string != null && value.string.toString().contains(".gif");
        if (!isScreenGif) {
            ivScreen.setScaleType(ImageView.ScaleType.CENTER_CROP);
        }

        RequestOptions requestOptions = new RequestOptions();
        requestOptions.placeholder(R.mipmap.screen);
        requestOptions.error(R.mipmap.screen);
        Glide.with(mContext)
                .setDefaultRequestOptions(requestOptions)
                .load(R.mipmap.screen)
                .listener(new RequestListener<Drawable>() {
                    @Override
                    public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                        return false;
                    }

                    @Override
                    public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                        if (resource instanceof GifDrawable) {
                            GifDrawable gifDrawable = (GifDrawable) resource;
                            gifDrawable.setLoopCount(1);
                        }
                        return false;
                    }
                })
                .into(ivScreen);

        LogUtils.LOGD(WelcomeScreen.class.getSimpleName(), " Oncreate called.." );

        if (getIntent().getExtras() != null) {


            mBundle = getIntent().getExtras();

            if(getIntent().hasExtra("previousSelected")){
                mBundle = getIntent().getExtras();

                // clearing the dashboard and cache data for loading the new language data.
                DataStorage.clearApplicationData(mContext);
                PreferencesUtils.updateDashBoardData(mContext,
                        PreferencesUtils.DASHBOARD_MENUS,
                        null);
                mLoadingText.setText(mContext.getResources().getString(R.string.language_update) + "...");
                mLoadingText.setVisibility(View.VISIBLE);
            }

            if(getIntent().hasExtra("isMessenger")){
                mBundle = getIntent().getExtras();
            }
        }


        /* Logged-in user */

        if ((PreferencesUtils.getAuthToken(WelcomeScreen.this) != null &&
                !PreferencesUtils.getAuthToken(WelcomeScreen.this).isEmpty()) || mBundle != null) {

            mAppConst.refreshUserData();

            new Handler().postDelayed(new Runnable() {
                public void run() {
                    if (isServerDataUpdated) {
                        redirectUserToMainScreens();
                    } else {
                        isRedirectionTimeComplete = true;
                    }
                }
            }, isScreenGif ? ConstantVariables.GIF_ANIMATION_TIME*1000 : 500);

        } else {
            new Handler().postDelayed(new Runnable() {

                public void run() {
                    requestDashboardData(true);
                }
            }, isScreenGif ? ConstantVariables.GIF_ANIMATION_TIME*1000 : 2000);
        }

        new Thread(() -> mAppConst.updateModulesSettings()).start();
    }

    private void redirectUserToMainScreens() {
        Intent intent;
        if (!mAppConst.isLoggedOutUser()) {
            intent = new Intent(WelcomeScreen.this, MainActivity.class);
            intent.putExtra("isSetLocation", true);
            intent.putExtra("isFromWelcomeScreen", true);
        } else if (ConstantVariables.INTRO_SLIDE_SHOW_ENABLED == 1) {
            intent = new Intent(WelcomeScreen.this, NewHomeScreen.class);
            requestDashboardData(false);
        } else {
            intent = new Intent(WelcomeScreen.this, HomeScreen.class);
            requestDashboardData(false);
        }

        if (mBundle != null) {
            intent.putExtras(mBundle);
        }
        startActivity(intent);
        finish();
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }


    /* Method for get enabled currency list data form server */
    private void getMultiCurrency() {
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "currencies/currency", new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                if (jsonObject != null && jsonObject.length() > 0) {
                    JSONObject defaultCurrency = jsonObject.optJSONObject("defaultCurrencyDetail");
                    String currencyFormat = jsonObject.optString("isSymbol");

                    /* Clear currency data from preferences if currency format is
                     * updated from admin */
                    if (!PreferencesUtils.getCurrencyFormat(mContext).isEmpty()
                            && !currencyFormat.equals(PreferencesUtils.getCurrencyFormat(mContext))) {
                        PreferencesUtils.clearMultiCurrencyData(mContext);
                    }

                    /* Set currency data in preferences */
                    PreferencesUtils.setCurrencyFormat(mContext, currencyFormat);
                    PreferencesUtils.updateDefaultCurrency(mContext, defaultCurrency.toString());
                    PreferencesUtils.setMultiCurrencyResponse(mContext, jsonObject.toString());
                } else {
                    PreferencesUtils.clearMultiCurrencyData(mContext);
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

            }
        });
    }

    private void getAppSettings() {
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "get-settings", new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                isServerDataUpdated = true;
                if (jsonObject != null && jsonObject.optJSONObject("livestreamingvideo") != null) {
                    PreferencesUtils.setLiveStreamingInfo(mContext, jsonObject.optJSONObject("livestreamingvideo"));
                } else {
                    PreferencesUtils.disableLiveStreaming(mContext);
                }

                if (isRedirectionTimeComplete) {
                    redirectUserToMainScreens();
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                isServerDataUpdated = true;
                if (isRedirectionTimeComplete) {
                    redirectUserToMainScreens();
                }
            }
        });
    }

    public void requestDashboardData(final boolean isLogging) {

        mAppConst.getJsonResponseFromUrl(UrlUtil.DASHBOARD_URL + "?browse_as_guest=1",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                        if (jsonObject != null) {
                            // Update PrimeMessenger Enabled setting in Pref.
                            PreferencesUtils.updatePrimeMessengerEnabled(mContext, jsonObject.optInt("isPrimeMessengerActive"));
                            PreferencesUtils.updateGuestUserSettings(mContext, jsonObject.optString("browse_as_guest"));
                            PreferencesUtils.updateLocationEnabledSetting(mContext, jsonObject.optInt("location"));
                            PreferencesUtils.setFilterEnabled(mContext, jsonObject.optInt("showFilterType"));
                            PreferencesUtils.setOtpEnabledOption(mContext, jsonObject.optString("loginoption"));
                            PreferencesUtils.setOtpPluginEnabled(mContext, jsonObject.optInt("isOTPEnable"));
                            JSONObject mLanguageObject = jsonObject.optJSONObject("languages");
                            if (mLanguageObject != null && mLanguageObject.length() != 0) {
                                String mDefaultLanguageCode = mLanguageObject.optString("default");
                                mAppConst.changeAppLocale(mDefaultLanguageCode, false);
                            }

                            mAppConst.saveDashboardValues(jsonObject);
                            if (isLogging) {
                                redirectToHomeScreen();
                            }
                        }

                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        if (isLogging) {
                            redirectToHomeScreen();
                        }
                    }
                });
    }

    private void redirectToHomeScreen() {
        Intent mainIntent;
        if (ConstantVariables.INTRO_SLIDE_SHOW_ENABLED == 1) {
            mainIntent = new Intent(WelcomeScreen.this, NewHomeScreen.class);
        } else {
            mainIntent = new Intent(WelcomeScreen.this, HomeScreen.class);
        }
        startActivity(mainIntent);
        finish();
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

}
