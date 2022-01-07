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

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.support.multidex.MultiDex;
import android.support.multidex.MultiDexApplication;
import android.text.TextUtils;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.HttpStack;
import com.android.volley.toolbox.HurlStack;
import com.android.volley.toolbox.Volley;
import com.crashlytics.android.Crashlytics;
import com.facebook.ads.AudienceNetworkAds;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.security.ProviderInstaller;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.TLSSocketFactory;
import com.socialengineaddons.mobileapp.classes.modules.messagingMiddleware.MessageCoreUtils;
import com.twitter.sdk.android.core.Twitter;
import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterConfig;

import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import javax.net.ssl.SSLContext;

import io.fabric.sdk.android.Fabric;


public class AppController extends MultiDexApplication {

    public static final String TAG = AppController.class.getSimpleName();

    private RequestQueue mRequestQueue;

    private FirebaseAnalytics mFirebaseAnalytics;

    private static AppController mInstance;
    private static Context context;


    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

    @Override
    public void onCreate() {
        super.onCreate();

        // Initialize the Facebook Audience Network SDK
        if (ConstantVariables.ENABLE_ADMOB == 0 && !getResources().getString(R.string.facebook_placement_id).isEmpty()) {

            if (AudienceNetworkAds.isInAdsProcess(this)) {
                return;
            }

            AudienceNetworkAds.initialize(this);
        }

        FontChanger.setDefaultFont(this, "MONOSPACE", getResources().getString(R.string.default_font_name));
        FontChanger.setDefaultFont(this, "DEFAULT", getResources().getString(R.string.default_font_name));
        FontChanger.setDefaultFont(this, "SERIF", getResources().getString(R.string.default_font_name));
        FontChanger.setDefaultFont(this, "SANS_SERIF", getResources().getString(R.string.default_font_name));
        mInstance = this;
        VolleyLog.DEBUG = false;

        context = getApplicationContext();
        MessageCoreUtils.initializeChannelize();

        registerActivityLifecycleCallbacks(new AppLifecycleTracker());

        TwitterConfig config = new TwitterConfig.Builder(this)
                .twitterAuthConfig(new TwitterAuthConfig(getResources().getString(R.string.twitter_key),
                        getResources().getString(R.string.twitter_secret)))
                .debug(false)
                .build();
        Twitter.initialize(config);

        Fabric.with(this, new Crashlytics());

        mFirebaseAnalytics = FirebaseAnalytics.getInstance(this);

        // Updating current app version in preferences.
        try {
            PreferencesUtils.updateCurrentAppVersionPref(this, this.getPackageManager().
                    getPackageInfo(this.getPackageName(), 0).versionName);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        registerActivityLifecycleCallbacks(new AppLifecycleTracker());

        // Setting initial values in preferences.
        PreferencesUtils.setForceAppUpgrade(this, null);
        PreferencesUtils.setAppUpgradeInfo(this, null, null);
    }

    public static synchronized AppController getInstance() {
        return mInstance;
    }

    public RequestQueue getRequestQueue() {
        if (mRequestQueue == null) {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                mRequestQueue = Volley.newRequestQueue(getApplicationContext());
            } else {
                HttpStack stack = null;
                try {
                    stack = new HurlStack(null, new TLSSocketFactory());
                } catch (KeyManagementException e) {
                    e.printStackTrace();
                    stack = new HurlStack();
                } catch (NoSuchAlgorithmException e) {
                    e.printStackTrace();
                    stack = new HurlStack();
                }
                mRequestQueue = Volley.newRequestQueue(getApplicationContext(), stack);
            }

            if (!GlobalFunctions.isSslEnabled()) {
                try {
                    ProviderInstaller.installIfNeeded(getApplicationContext());
                    SSLContext sslContext;
                    sslContext = SSLContext.getInstance("TLSv1.2");
                    sslContext.init(null, null, null);
                    sslContext.createSSLEngine();
                } catch (GooglePlayServicesRepairableException | GooglePlayServicesNotAvailableException
                        | NoSuchAlgorithmException | KeyManagementException e) {
                    e.printStackTrace();
                }
            }
        }

        return mRequestQueue;
    }

    public <T> void addToRequestQueue(Request<T> req, String tag) {
        req.setShouldCache(false);
        req.setTag(TextUtils.isEmpty(tag) ? TAG : tag);
        getRequestQueue().add(req);
    }

    public <T> void addToRequestQueue(Request<T> req) {
        req.setTag(TAG);
        getRequestQueue().add(req);
    }


    /***
     * Tracking event
     *
     * @param category event category
     * @param action   action of the event
     * @param label    label
     */
    public void trackEvent(String category, String action, String label) {

        Bundle bundle = new Bundle();
        bundle.putString(FirebaseAnalytics.Param.ITEM_CATEGORY, category);
        bundle.putString(FirebaseAnalytics.Param.ITEM_NAME, label);
        bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, action);
        mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.SELECT_CONTENT, bundle);

    }

    /***
     * Tracking event
     *
     * @param name event name
     * @param params   event params
     */
    public void trackEventCustom(String name, Bundle params) {
        mFirebaseAnalytics.logEvent(name, params);
    }

    class AppLifecycleTracker implements ActivityLifecycleCallbacks {

        private int numStarted = 0;

        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {

        }

        @Override
        public void onActivityStarted(Activity activity) {
            if (numStarted == 0) {
                // app went to foreground
            }
            numStarted++;
        }

        @Override
        public void onActivityResumed(Activity activity) {

        }

        @Override
        public void onActivityPaused(Activity activity) {

        }

        @Override
        public void onActivityStopped(Activity activity) {
            numStarted--;
            if (numStarted == 0) {
                // app went to background
//                messengerDatabaseUtils.setUserOffline(context);
            }
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            if (numStarted == 0) {
//                messengerDatabaseUtils.appClosed(context);
                GlobalFunctions.invokeMethod(getPackageName() + ".classes.modules.liveStreaming.LiveCoreUtils",
                        "onAppClosed", new Bundle());
            }
        }
    }
}
