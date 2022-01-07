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


import android.Manifest;
import android.app.Activity;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.NotificationManager;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentSender;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.bottomnavigation.LabelVisibilityMode;
import android.support.design.internal.BottomNavigationItemView;
import android.support.design.internal.BottomNavigationMenuView;
import android.support.design.widget.AppBarLayout;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.BottomSheetBehavior;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.TabLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.GravityCompat;
import android.support.v4.view.ViewPager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.widget.CardView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.login.LoginManager;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResult;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.iid.FirebaseInstanceId;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.activities.SearchActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.VideoLightBox;
import com.socialengineaddons.mobileapp.classes.common.activities.WebViewActivity;
import com.socialengineaddons.mobileapp.classes.common.adapters.CurrencyAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.FragmentAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.SelectAlbumListAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.dialogs.CheckInLocationDialog;
import com.socialengineaddons.mobileapp.classes.common.formgenerator.FormActivity;
import com.socialengineaddons.mobileapp.classes.common.fragments.BlankFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.ModulesHomeFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCheckInLocationResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.BadgeView;
import com.socialengineaddons.mobileapp.classes.common.ui.BottomNavigation.BottomNavigationBehavior;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.fab.CustomFloatingActionButton;
import com.socialengineaddons.mobileapp.classes.common.ui.fab.FloatingActionMenu;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.CustomTabUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.DataStorage;
import com.socialengineaddons.mobileapp.classes.common.utils.DeepLinksHandler;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SlideShowListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SocialShareUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.FeedsFragment;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.SingleFeedPage;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.Status;
import com.socialengineaddons.mobileapp.classes.modules.advancedVideos.AdvVideoView;
import com.socialengineaddons.mobileapp.classes.modules.album.AlbumView;
import com.socialengineaddons.mobileapp.classes.modules.friendrequests.FeedFriendRequests;
import com.socialengineaddons.mobileapp.classes.modules.messages.CreateNewMessage;
import com.socialengineaddons.mobileapp.classes.modules.messages.NewMessagesFragment;
import com.socialengineaddons.mobileapp.classes.modules.messagingMiddleware.MessageCoreUtils;
import com.socialengineaddons.mobileapp.classes.modules.multipleListingType.BrowseMLTFragment;
import com.socialengineaddons.mobileapp.classes.modules.notifications.NotificationFragment;
import com.socialengineaddons.mobileapp.classes.modules.packages.SelectPackage;
import com.socialengineaddons.mobileapp.classes.modules.peopleSuggestion.FindFriends;
import com.socialengineaddons.mobileapp.classes.modules.pushnotification.MyFcmListenerService;
import com.socialengineaddons.mobileapp.classes.modules.qrscanner.QRScannerFragment;
import com.socialengineaddons.mobileapp.classes.modules.store.CartView;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.EditProfileActivity;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;
import com.socialengineaddons.mobileapp.classes.modules.user.settings.MemberSettingsActivity;
import com.socialengineaddons.mobileapp.classes.modules.user.settings.SettingsListActivity;
import com.twitter.sdk.android.core.TwitterCore;
import com.twitter.sdk.android.tweetcomposer.TweetComposer;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import bolts.AppLinks;
import ru.dimorinny.showcasecard.position.BottomRightCustom;
import ru.dimorinny.showcasecard.position.TopLeftToolbar;
import ru.dimorinny.showcasecard.position.ViewPosition;
import ru.dimorinny.showcasecard.step.ShowCaseStep;
import ru.dimorinny.showcasecard.step.ShowCaseStepDisplayer;

import static android.support.design.widget.AppBarLayout.LayoutParams.SCROLL_FLAG_ENTER_ALWAYS;
import static android.support.design.widget.AppBarLayout.LayoutParams.SCROLL_FLAG_SCROLL;
import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.SERVER_SETTINGS;
import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.STATUS_POST_OPTIONS;

public class MainActivity extends FormActivity implements FragmentDrawer.FragmentDrawerListener,
        View.OnClickListener, OnCheckInLocationResponseListener, OnUploadResponseListener, GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener, LocationListener, ShowCaseStepDisplayer.DismissListener, DeepLinksHandler {

    private final int TYPE_HOME = 1, TYPE_MODULE = 2, TYPE_OTHER = 3;
    private boolean isHomePage = false, mIsCanView = true, isGuestUserHomePage = false,
            isSetLocation = false, isCurrentLocationSet = false, bCanCreate, isAlreadyLoggedIn;
    private String mAppTitle;
    private String mUploadPhotoUrl, mIcon, mSingularLabel;
    private ArrayList<String> mSelectPath;
    private BadgeView mCartCountBadge;
    private Menu optionMenu = null;
    private ProgressDialog progressDialog;
    private AppConstant mAppConst;
    private String currentSelectedOption;
    private FragmentDrawer drawerFragment;
    private SelectAlbumListAdapter listAdapter;
    private ArrayAdapter<String> locationAdapter;
    private Map<String, String> mSelectedLocationInfo;
    private Context mContext;
    private IntentFilter intentFilter;
    private SocialShareUtil socialShareUtil;
    Toolbar toolbar;
    CustomFloatingActionButton fabAlbumCreate, fabAlbumUpload;
    private FloatingActionButton mFabCreate;
    private FloatingActionMenu mFabMenu;
    private LinearLayout mFooterTabs;
    private CardView mEventFilters;
    private TabLayout mTabHost;
    private AppBarLayout.LayoutParams mToolbarParams;
    private AlertDialogWithAction mAlertDialogWithAction;
    private int mListingTypeId, mBrowseType, mViewType, mSecondaryViewType;
    private int mPackagesEnabled, mStoreWishListEnabled, mMLTWishListEnabled;
    private BottomSheetBehavior<View> behavior;
    public static FirebaseAnalytics mFirebaseAnalytics;
    private GoogleApiClient mGoogleApiClient;
    private CheckInLocationDialog checkInLocationDialog;
    private LocationRequest mLocationRequest;
    private MenuItem cartItem, searchItem, locationItem;
    private ShowCaseStepDisplayer.Builder showCaseStepDisplayer;
    private boolean isShowCaseView = false, isRequested;
    private int menuCallingTime = 0;
    private JSONObject menuOtherInfo;
    private AppBarLayout appBarLayout;
    private FragmentAdapter adapter;
    private ViewPager viewPager;
    private BottomNavigationView mBottomNavigationTabs;
    private Fragment loadFragment;
    private static int recentTabSelected = 0;
    private static boolean isPrimeMessangerOpened = false;
    private AlertDialog dialog;

    /* Broadcast receiver for receiving broadcasting intent action for
    viewing message and notification module (view all)    */

    private BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent != null) {
                switch (intent.getAction()) {
                    case ConstantVariables.ACTION_VIEW_ALL_MESSAGES:
                        selectItem("core_mini_messages",
                                getResources().getString(R.string.message_tab_name), null, null, 1);
                        break;
                    case ConstantVariables.ACTION_VIEW_ALL_NOTIFICATIONS:
                        if (optionMenu != null) {
                            optionMenu.findItem(R.id.action_search).setVisible(false);
                        }
                        selectItem("core_mini_notification",
                                getResources().getString(R.string.notification_drawer), null, null, 1);
                        break;
                }
            }
        }
    };


    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
//        Thread.setDefaultUncaughtExceptionHandler(new UncaughtHandler(this));
        intentFilter = new IntentFilter();
        intentFilter.addAction(ConstantVariables.ACTION_VIEW_ALL_MESSAGES);
        intentFilter.addAction(ConstantVariables.ACTION_VIEW_ALL_NOTIFICATIONS);

        mAppConst = new AppConstant(this);
        socialShareUtil = new SocialShareUtil(mContext);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);

        if (!mAppConst.checkManifestPermission(Manifest.permission.WAKE_LOCK)) {
            mAppConst.requestForManifestPermission(Manifest.permission.WAKE_LOCK,
                    ConstantVariables.PERMISSION_WAKE_LOCK);
        } else {
            mFirebaseAnalytics = FirebaseAnalytics.getInstance(this);
        }

        /* Facebook app linking */
        Uri targetUrl = AppLinks.getTargetUrlFromInboundIntent(this, getIntent());
        if (targetUrl != null) {
            LogUtils.LOGD("MainActivity: ", "App Link Target URL: " + targetUrl.toString());
        }

        setContentView(R.layout.activity_main);

        // Load the App in the previous saved Language
        mAppConst.changeAppLocale(PreferencesUtils.getCurrentLanguage(this), false);

        View bottomSheet = findViewById(R.id.bottom_sheet);
        mBottomNavigationTabs = findViewById(R.id.navigation);
        viewPager = findViewById(R.id.non_viewpager);

        behavior = BottomSheetBehavior.from(bottomSheet);
        behavior.setHideable(true);
        behavior.setState(BottomSheetBehavior.STATE_HIDDEN);

        mAppTitle = getApplicationContext().getResources().getString(R.string.app_name);
        mFooterTabs = (LinearLayout) findViewById(R.id.quick_return_footer_ll);
        mEventFilters = (CardView) findViewById(R.id.eventFilterBlock);
        mTabHost = (TabLayout) findViewById(R.id.materialTabHost);
        mFabMenu = (FloatingActionMenu) findViewById(R.id.fab_menu);
        mFabCreate = (FloatingActionButton) findViewById(R.id.create_fab);
        mFabCreate.hide();
        mFooterTabs.setVisibility(View.GONE);
        fabAlbumCreate = (CustomFloatingActionButton) findViewById(R.id.create_new_album);
        fabAlbumUpload = (CustomFloatingActionButton) findViewById(R.id.edit_album);
        mFabCreate.setOnClickListener(this);
        fabAlbumUpload.setOnClickListener(this);
        fabAlbumCreate.setOnClickListener(this);

        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
        mToolbarParams = (AppBarLayout.LayoutParams) toolbar.getLayoutParams();
        appBarLayout = findViewById(R.id.appbar);

        // Header search bar's text view.
        TextView tvSearch = (TextView) findViewById(R.id.tv_search);
        Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_action_search).mutate();
        drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                PorterDuff.Mode.SRC_ATOP));
        tvSearch.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);

        //drawer layout settings
        drawerFragment = (FragmentDrawer) getSupportFragmentManager()
                .findFragmentById(R.id.fragment_navigation_drawer);
        DrawerLayout drawerLayout = findViewById(R.id.drawer_layout);
        drawerFragment.setUp(R.id.fragment_navigation_drawer,
                drawerLayout, toolbar);
        drawerFragment.setDrawerListener(MainActivity.this);

        MessageCoreUtils.checkForOutDatedCache();
        isSetLocation = getIntent().hasExtra("isSetLocation");
        isAlreadyLoggedIn = getIntent().hasExtra("isAlreadyLoggedIn");
        //OCTOBER 2018 QR CODE CUSTOMIZATION
        checkForRequiredFields();

        /* Used for play pause auto play videos */
        drawerLayout.addDrawerListener(new DrawerLayout.DrawerListener() {
            @Override
            public void onDrawerSlide(@NonNull View view, float v) {

            }

            @Override
            public void onDrawerOpened(@NonNull View view) {
                pauseVideoAutoPlay();
            }

            @Override
            public void onDrawerClosed(@NonNull View view) {
                resumeVideoPlay();
            }

            @Override
            public void onDrawerStateChanged(int i) {

            }
        });

        // Updating dashboard data.
        mAppConst.getJsonResponseFromUrl(UrlUtil.DASHBOARD_URL + "?browse_as_guest=1",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                        new Thread(() -> {
                            updateServerSettings();
                            updateHostPathPrefixes();

                            // Update Paid Membership Status
                            PreferencesUtils.updatePaidMemberStatus(mContext, jsonObject.optInt("isPaidMember"));

                            // Update PrimeMessenger Enabled setting in Pref.
                            PreferencesUtils.updatePrimeMessengerEnabled(mContext,
                                    jsonObject.optInt("isPrimeMessengerActive"));

                            // If session get Logged-out then Relogin the firebase account
                            if (jsonObject.optInt("isPrimeMessengerActive") == 1 &&
                                    PreferencesUtils.getUserDetail(mContext) != null) {
                                try {
                                    JSONObject userDetail = new JSONObject(PreferencesUtils.getUserDetail(mContext));
                                    //TODO, recheck.
                                    MessageCoreUtils.login(userDetail.optString("user_id"),
                                            PreferencesUtils.getChannelizeAccessToken(mContext));
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }

                            // Updating location & guest user info.
                            PreferencesUtils.updateLocationEnabledSetting(mContext,
                                    jsonObject.optInt("location"));
                            PreferencesUtils.updateGuestUserSettings(mContext,
                                    jsonObject.optString("browse_as_guest"));
                            PreferencesUtils.setVideoQualityPref(mContext,
                                    jsonObject.optInt("video_quality"));
                            PreferencesUtils.setFilterEnabled(mContext, jsonObject.optInt("showFilterType"));
                            PreferencesUtils.setOtpEnabledOption(mContext, jsonObject.optString("loginoption"));
                            PreferencesUtils.setOtpPluginEnabled(mContext, jsonObject.optInt("isOTPEnable"));

                            JSONArray enabledModules = jsonObject.optJSONArray("enable_modules");
                            if (enabledModules != null) {
                                String modules = enabledModules.toString().replace("[\"", "");
                                modules = modules.replace("\"]", "");
                                PreferencesUtils.updateNestedCommentEnabled(mContext,
                                        enabledModules.toString().contains("nestedcomment") ? 1 : 0);
                                PreferencesUtils.updateSiteContentCoverPhotoEnabled(mContext,
                                        enabledModules.toString().contains("sitecontentcoverphoto") ? 1 : 0);
                                PreferencesUtils.setEnabledModuleList(mContext, modules);
                            }

                            // Saving dashboard response into preferences.
                            mAppConst.saveDashboardValues(jsonObject);

                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    // Updating drawer.
                                    drawerFragment.drawerUpdate();
                                }
                            });

                        }).start();

                        invalidateOptionsMenu();

                        if (getIntent().hasExtra("isFromWelcomeScreen")) {
                            checkLocationPermission();
                        }
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        // Updating drawer.
                        drawerFragment.drawerUpdate();

                        if (getIntent().hasExtra("isFromWelcomeScreen")) {
                            checkLocationPermission();
                        }
                    }
                });

        // calling for status post options.
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/feeds/feed-decoration",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) {
                        STATUS_POST_OPTIONS.put(ConstantVariables.FEED_DECORATION,
                                jsonObject.optJSONObject("feed_docoration_setting"));
                        STATUS_POST_OPTIONS.put(ConstantVariables.WORD_STYLING,
                                jsonObject.optJSONArray("word_styling"));
                        STATUS_POST_OPTIONS.put(ConstantVariables.ON_THIS_DAY,
                                jsonObject.optJSONObject("on_thisDay"));
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });

        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/feelings/banner",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) {
                        STATUS_POST_OPTIONS.put(ConstantVariables.BANNER_DECORATION,
                                jsonObject.optJSONArray("response"));
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });

        // Checking the force upgrade only once at app lifecycle.
        if (PreferencesUtils.getForceAppUpgrade(mContext) == null
                || PreferencesUtils.getForceAppUpgrade(mContext).isEmpty()) {
            // Making server call to get response of the upgrade params.
            mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "get-new-version?type=android",
                    new OnResponseListener() {
                        @Override
                        public void onTaskCompleted(JSONObject jsonObject) {
                            try {
                                boolean isPopUpEnabled = jsonObject.optInt("isPopUpEnabled") == 1;
                                String latestVersion = jsonObject.optString("latestVersion");
                                String description = jsonObject.optString("description");
                                boolean isForceUpgrade = jsonObject.optBoolean("isForceUpgrade");
                                PackageInfo pInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
                                String currentVersion = pInfo.versionName;
                                int hoursDifference = 0;
                                if (isPopUpEnabled && isForceUpgrade && latestVersion != null && !latestVersion.isEmpty() && currentVersion != null
                                        && GlobalFunctions.versionCompare(latestVersion, currentVersion) > 0) {
                                    try {
                                        PreferencesUtils.setForceAppUpgrade(mContext, ConstantVariables.FORCE_APP_UPGRADE);
                                        PreferencesUtils.setAppUpgradeInfo(mContext, latestVersion, description);
                                        showUpgradeDialogIfNeeded(true, latestVersion, description);
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                } else {
                                    if (dialog != null) {
                                        dialog.dismiss();
                                    }

                                    // Performing action on intent values, if its being hold for the app upgrade response.
                                    performOnBundleValues();

                                    PreferencesUtils.setForceAppUpgrade(mContext, ConstantVariables.NORMAL_APP_UPGRADE);
                                    if (PreferencesUtils.getAppUpgradeRemindTime(mContext) != null) {
                                        hoursDifference = GlobalFunctions.hoursDifferenceFromCurrentDate(PreferencesUtils.
                                                getAppUpgradeRemindTime(mContext));
                                    }
                                    // Checking for the conditions in which upgrade app dialog needs to be shown.
                                    if (isPopUpEnabled && !PreferencesUtils.isAppUpgradeDialogIgnored(mContext)
                                            && latestVersion != null && !latestVersion.isEmpty() && currentVersion != null
                                            && GlobalFunctions.versionCompare(latestVersion, currentVersion) > 0
                                            && (hoursDifference > 24 || PreferencesUtils.getAppUpgradeRemindTime(mContext) == null)) {
                                        try {
                                            showUpgradeDialogIfNeeded(false, latestVersion, description);
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                        }
                                    } else if (dialog != null) {
                                        dialog.dismiss();
                                    }
                                }
                            } catch (PackageManager.NameNotFoundException | NullPointerException e) {
                                e.printStackTrace();
                            }
                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                        }
                    });

        } else {
            // Putting condition for force upgrade.
            // Do not redirect to any other page other than home page if its force upgrade.

            // If there is no force upgrade then perform action on intent values.
            if (PreferencesUtils.getForceAppUpgrade(mContext).equals(ConstantVariables.NORMAL_APP_UPGRADE)) {
                performOnBundleValues();
            } else if (PreferencesUtils.getForceAppUpgrade(mContext).equals(ConstantVariables.FORCE_APP_UPGRADE)
                    && PreferencesUtils.getAppUpgradeVersion(mContext) != null
                    && PreferencesUtils.getAppUpgradeDescription(mContext) != null) {
                // If there is force upgrade then showing dialog for force upgrade.
                try {
                    showUpgradeDialogIfNeeded(true, PreferencesUtils.getAppUpgradeVersion(mContext),
                            PreferencesUtils.getAppUpgradeDescription(mContext));
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        handleAppLinks();

        displayCartCount();

        if (ConstantVariables.ENABLE_RATE_US_POPUP == 1 && !PreferencesUtils.isAppRated(this, PreferencesUtils.APP_RATED)) {
            showRateAppDialogIfNeeded();
        }
    }

    private void pauseVideoAutoPlay() {
        if (adapter != null) {
            FeedsFragment fragment = (FeedsFragment) adapter.getItem(0);
            fragment.pauseVideos(true);
        }
    }

    private void resumeVideoPlay() {
        if (adapter != null && !isShowCaseView) {
            FeedsFragment fragment = (FeedsFragment) adapter.getItem(0);
            if (isHomePage) {
                fragment.resumeVideos(true);
            }
        }
    }

    /**
     * Method to redirect to respective activity.
     */
    private void performOnBundleValues() {
        Bundle extras = getIntent().getExtras();

        // Check is there any push notification intent coming from MyFcmListenerService Class
        if (extras != null) {

            LogUtils.LOGD(MainActivity.class.getSimpleName(), "extras: " + extras);
            if (extras.containsKey("isMessenger")) {
                selectItem("home", mAppTitle, null, null, 0);
                MyFcmListenerService.clearMessengerPushNotification();
                GlobalFunctions.openMessengerApp(extras, mContext, ConstantVariables.OPEN_MESSENGER_REQUEST);
            } else {
                int id = extras.getInt("id");
                int isSingleNotification = extras.getInt("is_single_notification");
                String type = extras.getString("type");
                String notificationViewUrl = extras.getString("notification_view_url");
                String headerTitle = extras.getString("headerTitle");
                String message = extras.getString("message");

                JSONObject paramsObject = null;
                if (extras.getString("objectParams") != null &&
                        !extras.getString("objectParams").isEmpty()) {
                    try {
                        paramsObject = new JSONObject(extras.getString("objectParams"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                if (type != null && notificationViewUrl != null) {
                    MyFcmListenerService.clearPushNotification();
                    if (isSingleNotification == 1) {
                        int listingTypeId = extras.getInt(ConstantVariables.LISTING_TYPE_ID, 0);
                        int albumId = extras.getInt(ConstantVariables.ALBUM_ID, 0);
                        if (!type.isEmpty()) {

                            if (type.equals("core_comment")) {
                                selectItem("core_mini_notification", getResources().
                                        getString(R.string.notification_drawer), null, null, 0);
                            } else if (type.equals("album_photo") && albumId != 0) {
                                startNewActivity(type, albumId, listingTypeId, notificationViewUrl, headerTitle, paramsObject);
                                handleAppLinks();
                            } else if (type.equals(ConstantVariables.LIVE_STREAM_TYPE)) {
                                String channelName = extras.getString(ConstantVariables.CHANNEL_NAME);
                                String videoType = extras.getString(ConstantVariables.SUBJECT_TYPE);
                                int videoId = extras.getInt(ConstantVariables.SUBJECT_ID);
                                GlobalFunctions.updateBadgeCount(mContext, false);
                                GlobalFunctions.openLiveStreamActivity(mContext, channelName, videoType, videoId);
                                selectItem("home", mAppTitle, null, null, 0);

                            } else {
                                startNewActivity(type, id, listingTypeId, notificationViewUrl, headerTitle, paramsObject);
                                handleAppLinks();
                            }
                        } else {
                            mAlertDialogWithAction.showPushNotificationAlertDialog(headerTitle, message);
                            handleAppLinks();
                        }
                    } else {
                        selectItem("core_mini_notification", getResources().
                                getString(R.string.notification_drawer), null, null, 0);
                    }
                } else {
                    //first page selection when the app loaded first time
                    handleAppLinks();
                }
            }

            Intent intent = getIntent();
            if (intent.getAction() != null && intent.getType() != null) {
                Intent newIntent = new Intent(mContext, Status.class);
                newIntent.putExtras(extras);
                newIntent.setAction(intent.getAction());
                newIntent.setType(intent.getType());
                startActivity(newIntent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            }
        }
    }

    private void getAlertNotifications() {
        // getting the notification updates
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "notifications/new-updates",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                        if (jsonObject != null) {

                            PreferencesUtils.updateNotificationPreferences(mContext,
                                    jsonObject.optString("messages")
                                    , jsonObject.optString("notifications"),
                                    jsonObject.optString("friend_requests"),
                                    jsonObject.optString("cartProductsCount"));

                            updateNotificationCounts();

                        }
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });
    }

    public void updateNotificationCounts() {
        String notificationCount = PreferencesUtils.getNotificationsCounts(mContext, PreferencesUtils.NOTIFICATION_COUNT);
        String messageCount = PreferencesUtils.getNotificationsCounts(mContext, PreferencesUtils.MESSAGE_COUNT);
        String requestCount = PreferencesUtils.getNotificationsCounts(mContext, PreferencesUtils.FRIEND_REQ_COUNT);
        int missedCallCount = 0;

        /* Get unread message count from pm if enabled */
        if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
            missedCallCount = MessageCoreUtils.getMissedCallCount();
            messageCount = String.valueOf(PreferencesUtils.getUnReadMessageCount(mContext) + missedCallCount);
        }

        if (notificationCount != null && !notificationCount.equals("0")) {
            setBadgeOnTabs(4, notificationCount, false);
            // Show app notification count on app icon in supported launcher
            GlobalFunctions.updateBadgeCount(mContext, false);
        } else {
            removeBadge(4);
        }

        if (messageCount != null && !messageCount.equals("0")) {
            setBadgeOnTabs(2, messageCount, false);
        } else if (!PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
            removeBadge(3);
        }

        if (requestCount != null && !requestCount.equals("0")) {
            setBadgeOnTabs(1, requestCount, false);
        } else {
            removeBadge(1);
        }

    }

    // Set viewpager adapter and add home screen fragments
    private void setViewPagerForTabs() {
        if (viewPager != null) {
            adapter = new FragmentAdapter(getSupportFragmentManager());
            adapter.addFragment(FeedsFragment.newInstance(null),
                    mContext.getResources().getString(R.string.feed_tab_name));
            adapter.addFragment(FeedFriendRequests.newInstance(null),
                    mContext.getResources().getString(R.string.requests_tab_name));
            adapter.addFragment(QRScannerFragment.newInstance(null),
                    mContext.getResources().getString(R.string.scanner));
            adapter.addFragment(NewMessagesFragment.newInstance(null),
                    mContext.getResources().getString(R.string.message_tab_name));
            adapter.addFragment(NotificationFragment.newInstance(null),
                    mContext.getResources().getString(R.string.notification_tab_name));

            viewPager.setAdapter(adapter);
            viewPager.setOffscreenPageLimit(adapter.getCount() + 1);

            setMessageTabIcon(false);
        }
    }

    // Initialize and set property of bottom navigation tabs
    private void setBottomNavigationView() {

        setViewPagerForTabs();

        mBottomNavigationTabs.setLabelVisibilityMode(LabelVisibilityMode.LABEL_VISIBILITY_SELECTED);
        mBottomNavigationTabs.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

        // attaching bottom sheet behaviour - hide / show on scroll
        CoordinatorLayout.LayoutParams layoutParams = (CoordinatorLayout.LayoutParams) mBottomNavigationTabs.getLayoutParams();
        layoutParams.setBehavior(new BottomNavigationBehavior());

        // Add view badge view for display update count
        setBadgeOnTabs(1, "", true);
        setBadgeOnTabs(3, "", true);
        setBadgeOnTabs(4, "", true);

        if (!mAppConst.isLoggedOutUser()) {
            getAlertNotifications();
            if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                getMessageAndMissedCallCount();
            }
            // Kick off the first runnable task right away
            handler.postDelayed(runnableCode, ConstantVariables.FIRST_COUNT_REQUEST_DELAY);
        }

        if (loadFragment != null) {
            replaceFragment(new BlankFragment());
        }

        mBottomNavigationTabs.getMenu().findItem(R.id.navigation_home).setChecked(true);
        selectHomeScreenTab();

    }

    private void setMessageTabIcon(boolean isFilled) {

        Drawable icon;
        if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
            icon = ContextCompat.getDrawable(mContext, R.drawable.ic_prime_messenger);
        } else if (isFilled) {
            mAppConst.markAllMessageRead(null);
            PreferencesUtils.clearNotificationsCount(mContext, PreferencesUtils.MESSAGE_COUNT);
            icon = ContextCompat.getDrawable(mContext, R.drawable.ic_core_message_filled);
        } else {
            icon = ContextCompat.getDrawable(mContext, R.drawable.ic_core_message_outline);
        }
        if (icon != null) {
            mBottomNavigationTabs.getMenu().getItem(3).setIcon(icon);
        }
    }

    // Create the Handler object (on the main thread by default)
    Handler handler = new Handler();
    // Define the task to be run here
    private Runnable runnableCode = new Runnable() {
        @Override
        public void run() {
            if (!mAppConst.isLoggedOutUser()) {
                // getting the notification updates
                getAlertNotifications();

                // Repeat this runnable code again every 60 seconds
                handler.postDelayed(runnableCode, ConstantVariables.REFRESH_NOTIFICATION_TIME);
            }
        }
    };


    // Set and display update count on tabs icon
    public void setBadgeOnTabs(int position, String count, boolean addView) {
        BottomNavigationMenuView bottomNavigationMenuView =
                (BottomNavigationMenuView) mBottomNavigationTabs.getChildAt(0);

        BottomNavigationItemView itemView = (BottomNavigationItemView) bottomNavigationMenuView.getChildAt(position);

        if (addView) {
            View badge = LayoutInflater.from(this)
                    .inflate(R.layout.badge_view, bottomNavigationMenuView, false);
            TextView badgeView = badge.findViewById(R.id.notificationsBadgeTextView);
            badgeView.setText(count);
            itemView.addView(badge);
            badgeView.setVisibility(View.GONE);
        } else {
            TextView textView = itemView.findViewById(R.id.notificationsBadgeTextView);
            if (textView != null) {
                textView.setText(count);
                textView.setVisibility(View.VISIBLE);
            }
        }
    }

    // Hide badge view on tab selection
    public void removeBadge(int index) {
        BottomNavigationMenuView bottomNavigationMenuView =
                (BottomNavigationMenuView) mBottomNavigationTabs.getChildAt(0);
        BottomNavigationItemView itemView = (BottomNavigationItemView) bottomNavigationMenuView.getChildAt(index);

        TextView textView = itemView.findViewById(R.id.notificationsBadgeTextView);
        if (textView != null)
            textView.setVisibility(View.GONE);

    }

    /* Set tab selected listener for add fragment and switching in between tabs */
    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = item -> {
        switch (item.getItemId()) {
            case R.id.navigation_home:
                selectHomeScreenTab();
                onReselectTab(0);
                return true;

            case R.id.navigation_friend_request:
                mBottomNavigationTabs.getMenu().getItem(0).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_home_outline));
                mBottomNavigationTabs.getMenu().getItem(1).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_friend_request_filled));
                setMessageTabIcon(false);
                mBottomNavigationTabs.getMenu().getItem(4).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_notification_outline));
                mFabCreate.hide();
                onReselectTab(1);
                PreferencesUtils.clearNotificationsCount(mContext, PreferencesUtils.FRIEND_REQ_COUNT);
                mAppConst.markAllFriendRequestsRead();
                return true;

            case R.id.scanner:
                mBottomNavigationTabs.getMenu().getItem(0).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_home_outline));
                mBottomNavigationTabs.getMenu().getItem(1).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_friend_request_outline));
                setMessageTabIcon(false);
                mBottomNavigationTabs.getMenu().getItem(4).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_notification_outline));
                mFabCreate.hide();
                if (PreferencesUtils.isPaidMember(mContext)) {
                    onReselectTab(2);
                } else {
                    SnackbarUtils.displaySnackbarShortWithListener(findViewById(R.id.main_content),
                            mContext.getResources().getString(R.string.subscription_fail_error_message), () -> {
                                Intent settingsIntent = new Intent(mContext, MemberSettingsActivity.class);
                                String url = AppConstant.DEFAULT_URL + "/members/settings/subscriptions";
                                settingsIntent.putExtra("selected_option", "settings_subscription");
                                settingsIntent.putExtra("title", getResources().getString(R.string.subscription_settings));
                                settingsIntent.putExtra("url", url);
//                                        settingsIntent.putExtras(mBundle);
                                startActivity(settingsIntent);
                                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                            });

                }
                return true;

            case R.id.navigation_message:
                if (PreferencesUtils.getMessagingType(mContext).equals("none")) {
                    SnackbarUtils.displaySnackbar(findViewById(R.id.main_content),
                            mContext.getResources().getString(R.string.message_send_permission_message));
                    return false;
                }
                mBottomNavigationTabs.getMenu().getItem(0).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_home_outline));
                mBottomNavigationTabs.getMenu().getItem(1).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_friend_request_outline));
                mBottomNavigationTabs.getMenu().getItem(4).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_notification_outline));
                setMessageTabIcon(true);
                if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                    isPrimeMessangerOpened = true;
                    GlobalFunctions.openMessengerApp(null, mContext, ConstantVariables.OPEN_MESSENGER_REQUEST);
                } else {
                    onReselectTab(2);
                    setVisibilityOfFabCreate();
                    mFabCreate.setTag("core_main_message");

                    CoordinatorLayout.LayoutParams layoutParams = (CoordinatorLayout.LayoutParams) mFabCreate.getLayoutParams();
                    layoutParams.setMargins(0, 0, 0, (int) mContext.getResources().getDimension(R.dimen.margin_60dp));
                    mFabCreate.setLayoutParams(layoutParams);
                }
                return true;

            case R.id.navigation_notifications:
                mBottomNavigationTabs.getMenu().getItem(0).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_home_outline));
                mBottomNavigationTabs.getMenu().getItem(1).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_friend_request_outline));
                setMessageTabIcon(false);
                mBottomNavigationTabs.getMenu().getItem(4).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_notification_filled));
                onReselectTab(4);
                PreferencesUtils.clearNotificationsCount(mContext, PreferencesUtils.NOTIFICATION_COUNT);
                GlobalFunctions.updateBadgeCount(mContext, false);
                mAppConst.markAllNotificationsRead();

                mFabCreate.hide();
                Drawable drawable = ContextCompat.getDrawable(
                        mContext, R.drawable.ic_settings_white_24dp);
                drawable.mutate();
                drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.white),
                        PorterDuff.Mode.SRC_ATOP));
                mFabCreate.setImageDrawable(drawable);

                mFabCreate.setTag("core_main_notification");
                mFabCreate.show();
                CoordinatorLayout.LayoutParams layoutParams1 = (CoordinatorLayout.LayoutParams) mFabCreate.getLayoutParams();
                layoutParams1.setMargins(0, 0, 0, (int) mContext.getResources().getDimension(R.dimen.margin_60dp));
                mFabCreate.setLayoutParams(layoutParams1);
                return true;
        }
        return false;
    };

    private int getSelectedTabsId() {
        int id;
        switch (recentTabSelected) {
            case 1:
                id = R.id.navigation_friend_request;
                break;
            case 2:
                id = R.id.scanner;
                break;
            case 3:
                id = R.id.navigation_message;
                break;
            case 4:
                id = R.id.navigation_notifications;
                break;
            default:
                id = R.id.navigation_home;
                break;
        }
        return id;
    }

    private void selectHomeScreenTab() {
        mBottomNavigationTabs.getMenu().getItem(0).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_home_filled));
        mBottomNavigationTabs.getMenu().getItem(1).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_friend_request_outline));
        setMessageTabIcon(false);
        mBottomNavigationTabs.getMenu().getItem(4).setIcon(ContextCompat.getDrawable(mContext, R.drawable.ic_notification_outline));
        mFabCreate.hide();
    }


    /* Reset Tabs position and badge count on tabs selections.
     * Scroll fragments to top position on Re-Selections
     */
    private void onReselectTab(int position) {
        if (viewPager.getCurrentItem() == position && adapter != null && adapter.getCount() > 0 && position < adapter.getCount()
                && adapter.getItem(position) != null) {
            Fragment fragment = adapter.getItem(position);
            fragment.onAttach(mContext);
        }
        recentTabSelected = position;
        viewPager.setCurrentItem(position);

        if (position != 2) {
            removeBadge(position);
        }
    }

    private void updateServerSettings() {
        mAppConst.getJsonResponseFromUrl(UrlUtil.SERVER_SETTINGS_URL,
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject response) {
                        SERVER_SETTINGS.put(ConstantVariables.SERVER_SETTINGS_KEY,
                                response);
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });
    }

    private void updateHostPathPrefixes() {
        mAppConst.getJsonResponseFromUrl(UrlUtil.HOST_PATH_PREFIXES_URL,
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject response) {
                        PreferencesUtils.setHostPathPrefix(mContext, response.toString());
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });
    }

    private void autoUpdateCurrentLocation() {
        if (AppConstant.isDeviceLocationEnable == 1 && AppConstant.mLocationType.equals("notspecific")) {
            if (ContextCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION)
                    == PackageManager.PERMISSION_GRANTED) {
                buildGoogleApiClient();
            }
        }
    }

    /*
     * Add show case view step and display them (app quick tour guide)
     * */

    private void displayShowCaseView() {

        Context mContext = getApplicationContext();

        View searchBar = findViewById(R.id.search_bar);

        if (isHomePage && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.NAVIGATION_ICON_CASE_VIEW)) {
            isShowCaseView = true;
            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.NAVIGATION_ICON_CASE_VIEW);
            showCaseStepDisplayer.addStep(new ShowCaseStep(new TopLeftToolbar(), mContext.getResources().getString(R.string.navigation_show_case_text)));
        }

        if (searchBar != null && isHomePage &&
                searchBar.getVisibility() == View.VISIBLE && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.SEARCH_BAR_CASE_VIEW)) {
            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.SEARCH_BAR_CASE_VIEW);
            isShowCaseView = true;
            showCaseStepDisplayer.addStep(new ShowCaseStep(new ViewPosition(searchBar.findViewById(R.id.tv_search)),
                    mContext.getResources().getString(R.string.search_show_case_text), mContext.getResources().getDimension(R.dimen.radius_18)));
        }

        if (cartItem != null && isHomePage && cartItem.isVisible() && isHomePage
                && cartItem.getActionView() != null && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.CART_ICON_CASE_VIEW)) {
            isShowCaseView = true;
            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.CART_ICON_CASE_VIEW);
            showCaseStepDisplayer.addStep(new ShowCaseStep(cartItem.getActionView(),
                    mContext.getResources().getString(R.string.cart_show_case_text), mContext.getResources().getDimension(R.dimen.radius_18)));
        }

        if (locationItem != null && locationItem.isVisible() && isHomePage && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.LOCATION_ICON_CASE_VIEW)) {
            isShowCaseView = true;
            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.LOCATION_ICON_CASE_VIEW);
            showCaseStepDisplayer.addStep(new ShowCaseStep(locationItem.getActionView(),
                    mContext.getResources().getString(R.string.location_show_case_text), mContext.getResources().getDimension(R.dimen.radius_18)));
        }

        if (searchItem != null && searchItem.isVisible()
                && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.SEARCH_ICON_CASE_VIEW)) {
            isShowCaseView = true;
            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.SEARCH_ICON_CASE_VIEW);
            showCaseStepDisplayer.addStep(new ShowCaseStep(searchItem.getActionView(),
                    mContext.getResources().getString(R.string.search_show_case_text), mContext.getResources().getDimension(R.dimen.radius_18)));
        }

        View postView = findViewById(R.id.status_update_text);
        if (postView != null && postView.getVisibility() == View.VISIBLE && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.STATUS_POST_CASE_VIEW)
                && !drawerFragment.mDrawerLayout.isDrawerOpen(GravityCompat.START) && isHomePage && viewPager.getCurrentItem() == 0) {
            isShowCaseView = true;
            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.STATUS_POST_CASE_VIEW);
            showCaseStepDisplayer.addStep(new ShowCaseStep(postView,
                    mContext.getResources().getString(R.string.feed_post_show_case_text), mContext.getResources().getDimension(R.dimen.radius_20)));
        }

        if (!isHomePage && mFabCreate != null && mFabCreate.getVisibility() == View.VISIBLE
                && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.FAB_CREATE_CASE_VIEW)
                && !currentSelectedOption.equals(ConstantVariables.ALBUM_MENU_TITLE)) {
            isShowCaseView = true;
            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.FAB_CREATE_CASE_VIEW);
            showCaseStepDisplayer.addStep(new ShowCaseStep(new ViewPosition(mFabCreate), mContext.getResources().getString(R.string.create_content_show_case_text)));
        }

        if (!isHomePage && mFabMenu != null && mFabMenu.getVisibility() == View.VISIBLE
                && currentSelectedOption.equals(ConstantVariables.ALBUM_MENU_TITLE)
                && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.FAB_MENU_CASE_VIEW)) {
            isShowCaseView = true;
            int padding70 = (int) getResources().getDimensionPixelOffset(R.dimen.padding_70dp);
            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.FAB_MENU_CASE_VIEW);
            showCaseStepDisplayer.addStep(new ShowCaseStep(new BottomRightCustom(padding70), mContext.getResources().getString(R.string.create_album_show_case_text),
                    mContext.getResources().getDimension(R.dimen.radius_25)));
        }

        if (isShowCaseView) {
            pauseVideoAutoPlay();
            showCaseStepDisplayer.build().start();
        } else {
            checkLocationPermission();
        }

    }

    // Display product count over the cart menu icon in toolbar
    public void displayCartCount() {
        if (mCartCountBadge != null) {
            if (!PreferencesUtils.getNotificationsCounts(this, PreferencesUtils.CART_COUNT).equals("0") &&
                    !PreferencesUtils.getNotificationsCounts(this, PreferencesUtils.CART_COUNT).equals("")
                    && !PreferencesUtils.getNotificationsCounts(this, PreferencesUtils.CART_COUNT).equals("null")) {
                mCartCountBadge.setVisibility(View.VISIBLE);
                mCartCountBadge.setText(PreferencesUtils.getNotificationsCounts(this, PreferencesUtils.CART_COUNT));
            } else {
                mCartCountBadge.setVisibility(View.GONE);
            }
        }
    }

    /**
     * Method to show app upgrade dialog if needed.
     *
     * @param isForceUpgrade True, if popup is showing for force upgrade.
     * @param latestVersion  Latest version of the app which is available on play store.
     * @param description    Description of the new upgradable version.
     */
    private void showUpgradeDialogIfNeeded(boolean isForceUpgrade, String latestVersion, String description) {
        View view = getLayoutInflater().inflate(R.layout.layout_upgrade_dialog, null);
        TextView tvTitle = view.findViewById(R.id.tv_title);
        TextView tvDescription = view.findViewById(R.id.tv_description);
        TextView tvDownload = view.findViewById(R.id.tv_download);
        TextView tvRemindMeLater = view.findViewById(R.id.tv_reming_me_later);
        TextView tvIgnore = view.findViewById(R.id.tv_ignore);
        tvTitle.setText(getResources().getString(R.string.new_version_available) + " (" + latestVersion + ")");
        tvDescription.setText(description);
        GradientDrawable drawable = (GradientDrawable) view.getBackground();
        drawable.setCornerRadius(30f);
        view.setBackground(drawable);
        View downloadSeparator = view.findViewById(R.id.download_separator);
        View remindLaterSeparator = view.findViewById(R.id.remind_later_separator);
        if (isForceUpgrade) {
            tvDownload.setText(mContext.getResources().getString(R.string.app_upgrade_button_label));
            tvRemindMeLater.setVisibility(View.GONE);
            tvIgnore.setVisibility(View.GONE);
            downloadSeparator.setVisibility(View.INVISIBLE);
            remindLaterSeparator.setVisibility(View.GONE);
            MyFcmListenerService.clearPushNotification();
            GlobalFunctions.updateBadgeCount(mContext, false);
        } else {
            tvDownload.setText(mContext.getResources().getString(R.string.download_button_label));
            tvRemindMeLater.setVisibility(View.VISIBLE);
            tvIgnore.setVisibility(View.VISIBLE);
            downloadSeparator.setVisibility(View.VISIBLE);
            remindLaterSeparator.setVisibility(View.VISIBLE);
        }

        AlertDialog.Builder alertBuilder = new AlertDialog.Builder(this, R.style.Theme_LocationDialog);
        alertBuilder.setView(view);
        dialog = alertBuilder.create();
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(false);
        dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        dialog.show();

        WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams();
        layoutParams.copyFrom(dialog.getWindow().getAttributes());
        layoutParams.width = AppConstant.getDisplayMetricsWidth(mContext) - 100;
        layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        layoutParams.gravity = Gravity.CENTER;
        dialog.getWindow().setAttributes(layoutParams);

        // Adding click listener on all 3 buttons, and setting up the value accordingly.
        tvDownload.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isForceUpgrade) {
                    dialog.dismiss();
                }
                openAppInPlayStore();
            }
        });
        tvRemindMeLater.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
                PreferencesUtils.setUpgradeRemindMeLaterTime(mContext,
                        new SimpleDateFormat("yyyy/MM/dd HH:mm:ss", Locale.ENGLISH).format(new Date()));
            }
        });
        tvIgnore.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
                PreferencesUtils.setAppUpgradeDialogIgnored(mContext);
            }
        });
    }

    private void showRateAppDialogIfNeeded() {
        PreferencesUtils.updateLaunchCount(this, PreferencesUtils.getLaunchCount(this) + 1);
        int count = PreferencesUtils.isAppRated(this, PreferencesUtils.NOT_RATED) ? 180 : 20;
        if (PreferencesUtils.getLaunchCount(this) % count == 0) {
            createAppRatingDialog(getString(R.string.rate_app_title) + " " + getString(R.string.app_name),
                    getString(R.string.rate_app_message)).show();
        }
    }

    private AlertDialog createAppRatingDialog(String rateAppTitle, String rateAppMessage) {
        return new AlertDialog.Builder(this, R.style.Theme_LocationDialog).setPositiveButton(getString(R.string.dialog_app_rate), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface paramAnonymousDialogInterface, int paramAnonymousInt) {
                PreferencesUtils.updateRatePref(mContext, PreferencesUtils.APP_RATED);
                openAppInPlayStore();
            }
        }).setNegativeButton(getString(R.string.dialog_app_never), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface paramAnonymousDialogInterface, int paramAnonymousInt) {
                PreferencesUtils.updateRatePref(mContext, PreferencesUtils.NOT_RATED);
                PreferencesUtils.updateLaunchCount(mContext, 0);
                paramAnonymousDialogInterface.dismiss();
            }
        }).setMessage(rateAppMessage).setTitle(rateAppTitle).create();
    }

    public void openAppInPlayStore() {
        try {
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + getPackageName())));
        } catch (android.content.ActivityNotFoundException anfe) {
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + getPackageName())));
        }
    }

    /**
     * Swaps fragments in the main content view
     */

    public void selectItem(String name, String label, String headerLabel, String itemUrl, int canCreate) {
        if (name != null && !name.equals(ConstantVariables.APP_TOUR_MENU_TITLE)
                && !name.equals(ConstantVariables.SITE_MULTI_CURRENCY)) {
            loadFragment = null;
        }
        isGuestUserHomePage = false;
        BrowseMLTFragment.selectedViewType = 0;

        // update the main content by replacing fragments
        if (name != null) {

            AppController.getInstance().trackEvent(name, "Dashboard Selection", label);
            switch (name) {
                case "signout":
                    if (GlobalFunctions.isNetworkAvailable(mContext)) {
                        PreferencesUtils.clearSharedPreferences(mContext);
                        DataStorage.clearApplicationData(mContext);
                        CookieSyncManager.createInstance(mContext);
                        CookieManager cookieManager = CookieManager.getInstance();
                        cookieManager.removeSessionCookie();
                        TwitterCore.getInstance().getSessionManager().clearActiveSession();
                        task.execute((Void[]) null);
                    } else {
                        SnackbarUtils.displaySnackbar(findViewById(R.id.main_content),
                                mContext.getResources().getString(R.string.network_connectivity_error));
                    }
                    break;

                case ConstantVariables.USER_SETTINGS_MENU_TITLE:
                    Intent settingsActivity = new Intent(MainActivity.this, SettingsListActivity.class);
                    startActivity(settingsActivity);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    break;

                case ConstantVariables.PRODUCT_CART_MENU_TITLE:
                    Intent cartIntent = new Intent(MainActivity.this, CartView.class);
                    startActivity(cartIntent);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    break;

                case ConstantVariables.GLOBAL_SEARCH_MENU_TITLE:
                    Intent searchActivity = new Intent(MainActivity.this, SearchActivity.class);
                    searchActivity.putExtra(ConstantVariables.IS_SEARCHED_FROM_DASHBOARD, true);
                    startActivity(searchActivity);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    break;

                case ConstantVariables.MESSAGE_MENU_TITLE:
                    if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                        GlobalFunctions.openMessengerApp(null, mContext, 0);
                    } else {
                        mFooterTabs.setVisibility(View.GONE);
                        currentSelectedOption = name;
                        PreferencesUtils.updateCurrentModule(mContext, name);
                        loadFragment = new ModulesHomeFragment();
                        mFabCreate.setImageDrawable(ContextCompat.getDrawable(
                                this, R.drawable.ic_action_new));
                        if (canCreate == 1) {
                            mFabCreate.show();
                        } else {
                            mFabCreate.hide();
                        }
                        mFabMenu.hideMenu(false);
                        setTabVisibility(TYPE_MODULE);
                    }
                    break;

                case ConstantVariables.MULTI_LANGUAGES_MENU_TITLE:
                    mAppConst.changeLanguage(mContext, currentSelectedOption);
                    break;

                /* We are using return here instead of break
                 * as we don't need code after this block
                 * ie setting toolbar text, fragment replacments etc*/
                case ConstantVariables.SITE_MULTI_CURRENCY:
                    changeCurrency(mContext, currentSelectedOption);
                    return;

                case ConstantVariables.APP_TOUR_MENU_TITLE:
                    isShowCaseView = true;
                    PreferencesUtils.setShowCaseViewPref(mContext, false, false, false,
                            false, false, false, false, false, false, false);

                    PreferencesUtils.setProfileShowCaseViewPref(mContext, false, false,
                            false, false, false, false, false);

                    if (currentSelectedOption.equals(ConstantVariables.HOME_MENU_TITLE) || loadFragment == null) {
                        menuCallingTime = 1;
                    } else {
                        menuCallingTime = 0;
                    }
                    appBarLayout.setExpanded(true);
                    resetToolbarAndBottomTabs();

                    if (drawerFragment != null)
                        drawerFragment.scrolledToTop();

                    loadFragment = null;

                    if (adapter != null) {
                        FeedsFragment fragment = (FeedsFragment) adapter.getItem(0);
                        fragment.scrollToTop(0);
                    }
                    break;

                case ConstantVariables.LOCATION_MENU_TITLE:
                    changeLocation();
                    break;

                case ConstantVariables.SPREAD_THE_WORD_MENU_TITLE:

                    String description = getResources().getString(R.string.spread_the_word_description);

                    if (!description.contains("siteapi/index/app-page")) {
                        description += " " + AppConstant.DEFAULT_URL.replace("api/rest/", "") + "siteapi/index/app-page";
                    }

                    socialShareUtil.shareContent(getResources().getString(R.string.spread_the_word_title) + " " +
                            getResources().getString(R.string.app_name), description);
                    break;

                case ConstantVariables.RATE_US_MENU_TITLE:
                    createAppRatingDialog(getString(R.string.rate_app_title) + " " + getString(R.string.app_name),
                            getString(R.string.rate_app_message)).show();
                    break;

                case "sodrujestrvo_taxi":
                    /**
                     * Redirect to Taxi app if it is installed in phone
                     * else redirect to Google playstore to download install it.
                     */
                    if (isCometchatAppInstalled("com.sodrujestvo.taxi")) {
                        Intent launchIntent = getApplicationContext().getPackageManager().
                                getLaunchIntentForPackage("com.sodrujestvo.taxi");
                        startActivityForResult(launchIntent, 1);
                    } else {
                        startActivity(new Intent(Intent.ACTION_VIEW,
                                Uri.parse("https://play.google.com/store/apps/details?id=com.sodrujestvo.taxi")));
                    }
                    break;

                case ConstantVariables.FRIENDS_MENU_TITLE:
                    Intent intent = new Intent(mContext, FindFriends.class);
                    intent.putExtra("isFriendsTab", true);
                    startActivity(intent);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    break;

                case ConstantVariables.COMET_CHAT_MENU_TITLE:
                    /**
                     * Redirect to Cometchat app if it is installed in phone
                     * else redirect to Google playstore to download install it.
                     */
                    if (isCometchatAppInstalled(ConstantVariables.COMETCHAT_PACKAGE_NAME)) {
                        String userEmail = PreferencesUtils.getLoginInfo(mContext, PreferencesUtils.LOGIN_EMAIL);
                        String password = PreferencesUtils.getLoginInfo(mContext, PreferencesUtils.LOGIN_PASSWORD);
                        int userId = PreferencesUtils.getLoginUserId(mContext);
                        Intent launchIntent = getApplicationContext().getPackageManager().
                                getLaunchIntentForPackage(ConstantVariables.COMETCHAT_PACKAGE_NAME);
                        launchIntent.putExtra("username", userEmail);
                        launchIntent.putExtra("password", password);
                        launchIntent.putExtra("user_id", userId);
                        startActivityForResult(launchIntent, 1);
                    } else {
                        startActivity(new Intent(Intent.ACTION_VIEW,
                                Uri.parse("https://play.google.com/store/apps/details?id=" + ConstantVariables.COMETCHAT_PACKAGE_NAME)));
                    }
                    break;

                default:
                    mFooterTabs.setVisibility(View.GONE);
                    currentSelectedOption = name;
                    PreferencesUtils.updateCurrentModule(mContext, name);
                    if (mAppConst.isLoggedOutUser()) {
                        if (name.equals("sitereview_listing")) {
                            PreferencesUtils.updateCurrentListingType(mContext, mListingTypeId, label,
                                    mSingularLabel, mListingTypeId, mBrowseType, mViewType, mIcon,
                                    canCreate, mPackagesEnabled, mIsCanView, mSecondaryViewType);
                        } else if (name.equals("home")) {
                            label = headerLabel = mAppTitle;
                            isHomePage = true;
                            isGuestUserHomePage = true;
                        }

                        if (mIsCanView) {
                            loadFragment = GlobalFunctions.getGuestUserFragment(name);
                        }

                        // Checking tab visibility for the logged out user.
                        // Making tool bar SCROLL_FLAG_SCROLL only for the selected modules.
                        switch (name) {
                            case ConstantVariables.MLT_MENU_TITLE:
                            case ConstantVariables.EVENT_MENU_TITLE:
                            case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
                            case ConstantVariables.SITE_PAGE_TITLE_MENU:
                            case ConstantVariables.SITE_PAGE_MENU_TITLE:
                            case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                            case ConstantVariables.ADV_VIDEO_MENU_TITLE:
                            case ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE:
                            case ConstantVariables.PRODUCT_MENU_TITLE:
                                setTabVisibility(TYPE_MODULE);
                                break;

                            default:
                                setTabVisibility(TYPE_OTHER);
                                break;
                        }
                        mTabHost.setVisibility(View.GONE);
                    } else {
                        switch (name) {
                            case ConstantVariables.HOME_MENU_TITLE:
                                setTabVisibility(TYPE_HOME);
                                label = headerLabel = mAppTitle;
                                isHomePage = true;
                                break;

                            case ConstantVariables.SITE_PRODUCT_WISHLIST_MENU_TITLE:
                            case ConstantVariables.STORE_OFFER_MENU_TITLE:
                            case ConstantVariables.FORUM_MENU_TITLE:
                            case ConstantVariables.FRIEND_REQUEST_MENU_TITLE:
                            case ConstantVariables.USER_MENU_TITLE:
                            case ConstantVariables.CONTACT_US_MENU_TITLE:
                            case ConstantVariables.PRIVACY_POLICY_MENU_TITLE:
                            case ConstantVariables.TERMS_OF_SERVICE_MENU_TITLE:
                                mFabCreate.hide();
                                setTabVisibility(TYPE_OTHER);
                                break;

                            case ConstantVariables.ALBUM_MENU_TITLE:
                                mFabCreate.hide();
                                if (canCreate == 1) {
                                    mFabMenu.showMenu(false);
                                }
                                mFabMenu.setClosedOnTouchOutside(true);
                                setTabVisibility(TYPE_MODULE);
                                break;

                            case ConstantVariables.NOTIFICATION_MENU_TITLE:
                                mFabCreate.hide();
                                setTabVisibility(TYPE_MODULE);
                                break;

                            case ConstantVariables.DIARY_MENU_TITLE:
                            case ConstantVariables.MLT_WISHLIST_MENU_TITLE:
                                if (canCreate == 1) {
                                    mFabCreate.show();
                                } else {
                                    mFabCreate.hide();
                                }
                                setTabVisibility(TYPE_OTHER);
                                break;

                            case ConstantVariables.WISHLIST_MENU_TITLE:

                                mFabCreate.hide();
                                if (mStoreWishListEnabled == 1 && mMLTWishListEnabled == 1) {
                                    setTabVisibility(TYPE_MODULE);
                                } else {
                                    setTabVisibility(TYPE_OTHER);
                                }
                                break;

                            case ConstantVariables.MLT_MENU_TITLE:
                                PreferencesUtils.updateCurrentListingType(mContext, mListingTypeId, label,
                                        mSingularLabel, mListingTypeId, mBrowseType, mViewType, mIcon,
                                        canCreate, mPackagesEnabled, mIsCanView, mSecondaryViewType);

                            case ConstantVariables.STORE_MENU_TITLE:
                                if (canCreate == 1) {
                                    setVisibilityOfFabCreate();
                                } else {
                                    mFabCreate.hide();
                                }
                                setTabVisibility(TYPE_MODULE);
                                break;
                            default:
                                if (canCreate == 1) {
                                    setVisibilityOfFabCreate();
                                } else {
                                    mFabCreate.hide();
                                }
                                setTabVisibility(TYPE_MODULE);
                                break;
                        }

                        if (!name.equals("home"))
                            loadFragment = GlobalFunctions.getAuthenticateUserFragment(name, mStoreWishListEnabled, mMLTWishListEnabled);
                        else {
                            setBottomNavigationView();
                        }
                    }
            }

            /* Enable pip video play when user select video and advanced video related modules
             * form dashboard otherwise disable it */
            if (name.contains("video")) {
                PreferencesUtils.updatePlayVideoInPip(mContext, true);
            } else {
                PreferencesUtils.updatePlayVideoInPip(mContext, false);
            }

        } else if (label != null && !label.isEmpty() && itemUrl != null && !itemUrl.isEmpty()) {

            AppController.getInstance().trackEvent(headerLabel, "Dashboard Selection", "Webview Loaded");
            if (ConstantVariables.WEBVIEW_ENABLE == 1) {
                Intent webViewActivity = new Intent(MainActivity.this, WebViewActivity.class);
                webViewActivity.putExtra("headerText", headerLabel);
                webViewActivity.putExtra("url", itemUrl);
                startActivity(webViewActivity);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

            } else {
                LogUtils.LOGD("MessengerActivity", "GlobalFunctions.getWebViewUrl(itemUrl, this) " +
                        GlobalFunctions.getWebViewUrl(itemUrl, this));
                CustomTabUtil.launchCustomTab(this, GlobalFunctions.getWebViewUrl(itemUrl, this));
            }
        }

        if (loadFragment != null) {
            Bundle args = new Bundle();
            args.putBoolean(ConstantVariables.CAN_CREATE, (canCreate == 1));
            args.putBoolean(ConstantVariables.IS_PACKAGE_ENABLED, (mPackagesEnabled == 1));
            loadFragment.setArguments(args);
            replaceFragment(loadFragment);
            // Show Header label as Toolbar title if set
            if (headerLabel != null && !headerLabel.isEmpty()) {
                setTitle(headerLabel);
            } else {
                setTitle(label);
            }
        } else if (!mIsCanView && mAppConst.isLoggedOutUser()) {
            Intent mainIntent;
            if (ConstantVariables.INTRO_SLIDE_SHOW_ENABLED == 1) {
                mainIntent = new Intent(mContext, NewLoginActivity.class);
            } else {
                mainIntent = new Intent(mContext, LoginActivity.class);
            }
            startActivity(mainIntent);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }

        setToolbarView();
    }

    @Override
    public void setTitle(CharSequence title) {
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(title);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        getMenuInflater().inflate(R.menu.menu_main, menu);
        this.optionMenu = menu;

        if (AppConstant.isLocationEnable && isHomePage &&
                PreferencesUtils.isLocationSettingEnabled(mContext)) {
            menu.findItem(R.id.action_location).setVisible(true);
        } else {
            menu.findItem(R.id.action_location).setVisible(false);
        }

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {


        // Handle action bar actions click
        switch (item.getItemId()) {

            case R.id.action_search:
                if (currentSelectedOption != null && currentSelectedOption.equals(ConstantVariables.PRODUCT_MENU_TITLE)) {
                    return super.onOptionsItemSelected(item);
                } else {
                    //calling the search activity
                    Intent searchActivity = new Intent(MainActivity.this, SearchActivity.class);
                    searchActivity.putExtra(ConstantVariables.IS_SEARCHED_FROM_DASHBOARD, false);
                    searchActivity.putExtra(ConstantVariables.CATEGORY_FORUM_TOPIC,
                            getResources().getString(R.string.query_search_forum_topics));
                    if (menuOtherInfo != null) {
                        searchActivity.putExtra(ConstantVariables.URL_STRING, menuOtherInfo.optString("url"));
                        searchActivity.putExtra(ConstantVariables.SEARCH_TITLE, menuOtherInfo.optString("label"));
                    }
                    searchActivity.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, currentSelectedOption);
                    startActivity(searchActivity);
                    return true;
                }

            case R.id.action_location:
                changeLocation();
                return true;

//            case R.id.action_messenger:
//                GlobalFunctions.openMessengerApp(null, mContext, 0);
//                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        MenuItem toggleItem = menu.findItem(R.id.viewToggle);
        toggleItem.setVisible(false);

        menuCallingTime++;

        searchItem = menu.findItem(R.id.action_search);
        //TODO API_DISCUSSION REGARDING ACTION MENU
        locationItem = menu.findItem(R.id.action_location);
        cartItem = menu.findItem(R.id.action_cart);
        View searchBar = findViewById(R.id.search_bar);
        if (searchItem != null && searchItem.getActionView() != null) {
            setColorFilter((ImageView) searchItem.getActionView().findViewById(R.id.search_icon));
        }
        if (locationItem != null && locationItem.getActionView() != null) {
            setColorFilter((ImageView) locationItem.getActionView().findViewById(R.id.location_icon));
        }
        if (cartItem != null && cartItem.getActionView() != null) {
            setColorFilter((ImageView) cartItem.getActionView().findViewById(R.id.cart_icon));
        }

//        MenuItem messengerItem = menu.findItem(R.id.action_messenger);

        if (behavior.getState() == BottomSheetBehavior.STATE_EXPANDED) {
            behavior.setState(BottomSheetBehavior.STATE_HIDDEN);
        }

        // Show Messenger Icon only when PrimeMessenger is integrated on website, else hide it.
//        if(!mAppConst.isLoggedOutUser() && PreferencesUtils.isPrimeMessengerEnabled(mContext)){
//            messengerItem.setVisible(true);
//        } else {
//            messengerItem.setVisible(false);
//        }

        // Getting enabled module array to check store cart icon is need to show or not.
        List<String> enabledModuleList = null;
        if (PreferencesUtils.getEnabledModuleList(mContext) != null) {
            enabledModuleList = new ArrayList<>(Arrays.asList(PreferencesUtils.getEnabledModuleList(mContext).split("\",\"")));
        }

        if (enabledModuleList != null && enabledModuleList.contains("sitestore") && ConstantVariables.SHOW_CART_ICON) {
            cartItem.setVisible(true);
            cartItem.getActionView().setOnClickListener(this);
            mCartCountBadge = (BadgeView) cartItem.getActionView().findViewById(R.id.cart_item_count);
            displayCartCount();
        } else {
            cartItem.setVisible(false);
        }

        if (locationItem != null && locationItem.isVisible()) {
            locationItem.getActionView().setOnClickListener(this);
        }

        if (searchItem != null && searchItem.isVisible()) {
            searchItem.getActionView().setOnClickListener(this);
        }

        /**
         * Changing search bar margin when the other menu items are visible or not.
         */
        Toolbar.LayoutParams layoutParams = (Toolbar.LayoutParams) searchBar.getLayoutParams();
        if (!cartItem.isVisible() && !locationItem.isVisible()) {
            layoutParams.setMargins(0, mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_20dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp));
        } else {
            layoutParams.setMargins(0, mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp));
        }

        if (currentSelectedOption != null) {

            switch (currentSelectedOption) {
                case ConstantVariables.NOTIFICATION_MENU_TITLE:
                case ConstantVariables.USER_SETTINGS_MENU_TITLE:
                case ConstantVariables.CONTACT_US_MENU_TITLE:
                case ConstantVariables.PRIVACY_POLICY_MENU_TITLE:
                case ConstantVariables.TERMS_OF_SERVICE_MENU_TITLE:
                case ConstantVariables.MESSAGE_MENU_TITLE:
                case ConstantVariables.FRIEND_REQUEST_MENU_TITLE:
                case ConstantVariables.STORE_OFFER_MENU_TITLE:
                    searchItem.setVisible(false);
                    break;

                case ConstantVariables.BLOG_MENU_TITLE:
                case ConstantVariables.CLASSIFIED_MENU_TITLE:
                case ConstantVariables.POLL_MENU_TITLE:
                case ConstantVariables.GROUP_MENU_TITLE:
                case ConstantVariables.VIDEO_MENU_TITLE:
                case ConstantVariables.EVENT_MENU_TITLE:
                case ConstantVariables.MUSIC_MENU_TITLE:
                case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
                case ConstantVariables.ALBUM_MENU_TITLE:
                case ConstantVariables.MLT_MENU_TITLE:
                case ConstantVariables.MLT_WISHLIST_MENU_TITLE:
                case ConstantVariables.FORUM_MENU_TITLE:
                case ConstantVariables.USER_MENU_TITLE:
                case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                case ConstantVariables.SITE_PAGE_TITLE_MENU:
                case ConstantVariables.PRODUCT_MENU_TITLE:
                    break;
                default:
                    break;

            }

            if ((isHomePage || isGuestUserHomePage) && ConstantVariables.SHOW_APP_TITLE_IN_HEADER == 0) {
                searchItem.setVisible(false);
            }

        }

        /* Execute show case view code after initializing
         * all methods and views */
        if (menuCallingTime > 2 && !mAppConst.isLoggedOutUser()
                && PreferencesUtils.getAppTourEnabled(mContext) == 1) {
            /* Initialize show case view step builder */
            showCaseStepDisplayer = new ShowCaseStepDisplayer.Builder(this, R.color.colorAccent);
            displayShowCaseView();
        }
        return super.onPrepareOptionsMenu(menu);
    }

    private void setColorFilter(ImageView imageView) {
        if (imageView != null) {
            imageView.setColorFilter(ContextCompat.getColor(mContext, R.color.textColorPrimary));
        }
    }

    @Override
    public void onDrawerItemSelected(View view, String name, String label, String headerLabel,
                                     String singularLabel, String itemUrl, int listingId, int browseType,
                                     int viewType, String icon, int canCreate, int packagesEnabled,
                                     int siteStoreEnabled, int listingEnabled, boolean canView, int secondaryViewType, JSONObject otherInfo) {
        mListingTypeId = listingId;
        mBrowseType = browseType;
        mViewType = viewType;
        mIcon = icon;
        mSingularLabel = singularLabel;
        mStoreWishListEnabled = siteStoreEnabled;
        mMLTWishListEnabled = listingEnabled;
        mIsCanView = canView;
        mSecondaryViewType = secondaryViewType;
        menuOtherInfo = otherInfo;
        bCanCreate = (canCreate == 1);

        if (name != null && !name.isEmpty()
                && !name.equals(ConstantVariables.SPREAD_THE_WORD_MENU_TITLE)
                && !name.equals(ConstantVariables.LOCATION_MENU_TITLE)
                && !name.equals(ConstantVariables.RATE_US_MENU_TITLE)) {
            mPackagesEnabled = packagesEnabled;
        }
        selectItem(name, label, headerLabel, itemUrl, canCreate);
    }


    //Showing list of albums for uploading photos in a particular album
    public void showListOfAlbums() {

        final Dialog albumListDialog = new Dialog(this, R.style.Theme_CustomDialog);
        final ListView listViewAlbumTitle = new ListView(this);
        final List<BrowseListItems> mBrowseItemList = new ArrayList<>();
        listAdapter =
                new SelectAlbumListAdapter(this, R.layout.simple_text_view, mBrowseItemList);
        listViewAlbumTitle.setAdapter(listAdapter);
        ProgressBar progressBar = new ProgressBar(this);
        albumListDialog.setContentView(progressBar);
        albumListDialog.setTitle(getApplicationContext().getResources()
                .getString(R.string.select_album_dialog_title));
        albumListDialog.setCancelable(true);
        albumListDialog.show();
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "albums/upload",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                        if (jsonObject != null) {
                            albumListDialog.setContentView(listViewAlbumTitle);
                            JSONArray body = jsonObject.optJSONArray("response");
                            if (body != null && body.length() > 2) {
                                JSONObject albumList = body.optJSONObject(0);
                                if (albumList.optString("name").equals("album")) {
                                    try {
                                        if (albumList.optJSONObject("multiOptions") != null) {
                                            Iterator<String> iter = albumList.optJSONObject("multiOptions").keys();
                                            while (iter.hasNext()) {
                                                String key = iter.next();
                                                String value = albumList.optJSONObject("multiOptions").getString(key);
                                                if (!key.equals("0"))
                                                    mBrowseItemList.add(new BrowseListItems(key, value));
                                                listAdapter.notifyDataSetChanged();
                                            }
                                        } else {
                                            mBrowseItemList.add(new BrowseListItems("", getResources().
                                                    getString(R.string.no_album_error_message)));
                                            listAdapter.notifyDataSetChanged();
                                            listViewAlbumTitle.setOnItemClickListener(null);
                                        }
                                    } catch (NullPointerException e) {
                                        e.printStackTrace();
                                    }
                                }
                            }


                        }
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        albumListDialog.dismiss();
                    }
                });


        listViewAlbumTitle.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                mFabMenu.close(true);
                String url = AppConstant.DEFAULT_URL + "albums/upload?album_id="
                        + mBrowseItemList.get(i).getAlbumId();
                albumListDialog.cancel();
                Intent uploadPhoto = new Intent(MainActivity.this, MultiMediaSelectorActivity.class);
                // Selection type photo to display items in grid
                uploadPhoto.putExtra(MultiMediaSelectorActivity.EXTRA_SELECTION_TYPE, MultiMediaSelectorActivity.SELECTION_PHOTO);
                // Whether photo shoot
                uploadPhoto.putExtra(MultiMediaSelectorActivity.EXTRA_SHOW_CAMERA, true);
                // The maximum number of selectable image
                uploadPhoto.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_COUNT,
                        ConstantVariables.FILE_UPLOAD_LIMIT);
                // Select mode
                uploadPhoto.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_MODE,
                        MultiMediaSelectorActivity.MODE_MULTI);
                uploadPhoto.putExtra(MultiMediaSelectorActivity.EXTRA_URL, url);

                startActivityForResult(uploadPhoto, ConstantVariables.REQUEST_IMAGE);
            }
        });

    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        try {
            if (checkInLocationDialog != null && checkInLocationDialog.isShowing()) {
                checkInLocationDialog.onActivityResult(requestCode, resultCode, data);
                return;
            }

            if (requestCode == ConstantVariables.TWITTER_REQUEST_CODE) {
                Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.fragment_navigation_drawer);
                if (fragment != null) {
                    fragment.onActivityResult(requestCode, resultCode, data);
                }
            }

            if (requestCode == ConstantVariables.QR_SCANNER_REQUEST_CODE) {
                List<Fragment> allFragments = getSupportFragmentManager().getFragments();
                boolean isQRScanner = false;
                for (int i = 0; i < allFragments.size(); i++) {
                    Fragment fragment = allFragments.get(i);
                    if (!isQRScanner && fragment != null && fragment instanceof QRScannerFragment) {
                        fragment.onActivityResult(requestCode, resultCode, data);
                    }
                }
            }
            if (resultCode == ConstantVariables.CANCELED_QR_SCAN && isHomePage) {
                selectItem("home", mAppTitle, null, null, 0);
                return;
            }

            if (currentSelectedOption != null && currentSelectedOption.equals(ConstantVariables.CROWD_FUNDING_MAIN_TITLE) && loadFragment != null) {
                loadFragment.onActivityResult(requestCode, resultCode, data);
            }
            Bundle bundle = null;
            if (data != null) {
                bundle = data.getExtras();
            }
            if (requestCode == ConstantVariables.PERMISSION_GPS_SETTINGS) {
                switch (resultCode) {
                    case Activity.RESULT_OK:
                        // All required changes were successfully made
                        if (isHomePage) {
                            autoUpdateCurrentLocation();
                        } else {
                            loadFragmentOnGPSEnabled();
                        }
                        break;

                    case Activity.RESULT_CANCELED:
                        // The user was asked to change settings, but chose not to
                        Toast.makeText(mContext, mContext.getResources().getString(R.string.for_better_results_enable_gps), Toast.LENGTH_LONG).show();
                        break;

                    default:
                        break;
                }
            } else if (resultCode != 0) {
                switch (resultCode) {

                    case ConstantVariables.CREATE_REQUEST_CODE:
                        loadFragment = GlobalFunctions.getAuthenticateUserFragment(currentSelectedOption, mStoreWishListEnabled, mMLTWishListEnabled);
                        if (loadFragment != null) {
                            loadFragment.setArguments(bundle);
                            replaceFragment(loadFragment);
                        }
                        break;

                    // Refreshing the fragment when creating any content.
                    case ConstantVariables.VIEW_PAGE_CODE:
                        loadFragment = GlobalFunctions.getAuthenticateUserFragment(currentSelectedOption, mStoreWishListEnabled, mMLTWishListEnabled);
                        if ((requestCode == ConstantVariables.CREATE_REQUEST_CODE || (bundle != null && bundle.getBoolean(ConstantVariables.KEY_CAN_REFRESH, false)))
                                && loadFragment != null) {
                            PreferencesUtils.updateCurrentModule(mContext, currentSelectedOption);
                            bundle.putBoolean(ConstantVariables.CAN_CREATE, bCanCreate);
                            loadFragment.setArguments(bundle);
                            replaceFragment(loadFragment);
                        }
                        break;

                    case ConstantVariables.REQUEST_IMAGE:
                        mSelectPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);
                        mUploadPhotoUrl = data.getStringExtra(MultiMediaSelectorActivity.EXTRA_URL);
                        StringBuilder sb = new StringBuilder();
                        for (String p : mSelectPath) {
                            sb.append(p);
                            sb.append("\n");
                        }
                        // uploading the photos to server
                        new UploadFileToServerUtils(mContext, findViewById(R.id.main_content),
                                mUploadPhotoUrl, mSelectPath, this).execute();
                        break;

                    case ConstantVariables.FEED_REQUEST_CODE:

                        if (bundle != null) {
                            if (bundle.getBoolean("isPosted", false)) {
                                if (bundle.getBoolean("isExternalShare", false)) {
                                    Toast.makeText(mContext, getResources().getString(R.string.post_sharing_success_message),
                                            Toast.LENGTH_LONG).show();
                                } else {
                                    if (viewPager != null) {
                                        viewPager.setAdapter(adapter);
                                    }
                                }
                            }

                            if (bundle.getBoolean("isTwitterPost", false)) {
                                TweetComposer.Builder builder = new TweetComposer.Builder(this);
                                builder.text(bundle.getString("mStatusBodyText", ""));
                                if (bundle.containsKey("imagePath")) {
                                    String imagePath = bundle.getString("imagePath");
                                    File myImageFile = new File(imagePath);

                                    builder.image(GlobalFunctions.getFileUri(mContext, myImageFile));
                                } else if (bundle.containsKey(ConstantVariables.VIDEO_URL)) {
                                    URL url = new URL(bundle.getString(ConstantVariables.VIDEO_URL));
                                    builder.url(url);
                                }
                                builder.show();
                            }

                        }

                        break;

                    case ConstantVariables.CANCEL_FILL_REQUIRED_FIELD:
                        showRequiredFieldAlert();
                        break;
                }
            } else {
                switch (requestCode) {
                    case ConstantVariables.REQUEST_IMAGE:

                        if (data != null) {
                            mSelectPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);
                            mUploadPhotoUrl = data.getStringExtra(MultiMediaSelectorActivity.EXTRA_URL);
                            StringBuilder sb = new StringBuilder();
                            for (String p : mSelectPath) {
                                sb.append(p);
                                sb.append("\n");
                            }

                            // uploading the photos to server
                            new UploadFileToServerUtils(mContext, findViewById(R.id.main_content),
                                    mUploadPhotoUrl, mSelectPath, this).execute();
                        }

                        break;

                    case ConstantVariables.WEB_VIEW_ACTIVITY_CODE:
                        if (isHomePage) {
                            handleAppLinks();
                        }
                        break;

                    case ConstantVariables.OPEN_MESSENGER_REQUEST:
                        getMessageAndMissedCallCount();
                        break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private void replaceFragment(Fragment loadFragment) {
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction ft = fragmentManager.beginTransaction();
        ft.replace(R.id.main_content, loadFragment);
        ft.commitAllowingStateLoss();
    }

    @Override
    protected void onResume() {
        super.onResume();
        displayCartCount();
        if (isPrimeMessangerOpened || recentTabSelected == 2) {
            isPrimeMessangerOpened = false;

            if (recentTabSelected == 2) {
                recentTabSelected = 0;
            }
            MenuItem menuItem = mBottomNavigationTabs.getMenu().findItem(getSelectedTabsId());
            if (menuItem != null)
                menuItem.setChecked(true);
        }
        if (!mAppConst.isLoggedOutUser()) {
            handler.postDelayed(runnableCode, ConstantVariables.FIRST_COUNT_REQUEST_DELAY);
        }
        registerReceiver(broadcastReceiver, intentFilter);
        if (currentSelectedOption != null && currentSelectedOption.equals("home")) {
            if (mTabHost.getVisibility() == View.VISIBLE) {
                mTabHost.setVisibility(View.GONE);
            }
            if (mFooterTabs.getVisibility() == View.VISIBLE) {
                mFooterTabs.setVisibility(View.GONE);
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(broadcastReceiver);
    }

    @Override
    public void onBackPressed() {

        // If show case view is displayed close/hide it
        if (isShowCaseView) {
            showCaseStepDisplayer.dismissShowCaseView();
        }
        // if drawer is open, close it.
        if (drawerFragment.mDrawerLayout != null
                && drawerFragment.mDrawerLayout.isDrawerOpen(GravityCompat.START)) {

            drawerFragment.mDrawerLayout.closeDrawers();

        } else if (behavior.getState() == BottomSheetBehavior.STATE_EXPANDED) {
            behavior.setState(BottomSheetBehavior.STATE_HIDDEN);
        } else if (isHomePage) {
            //Going to home screen
            moveTaskToBack(true);
            checkActivityStack();
        } else {
            if (findViewById(R.id.quick_return_footer_ll) != null) {
                findViewById(R.id.quick_return_footer_ll).setVisibility(View.GONE);
            }

            PreferencesUtils.updatePlayVideoInPip(mContext, false);

            if (!mAppConst.isLoggedOutUser()) {
                resetToolbarAndBottomTabs();
                BottomNavigationBehavior.updateBehaviour(true);

                /* check and resume video if it's on screen when user came back from any module page */
                resumeVideoPlay();
            } else {
                //Going back to home screen
                handleAppLinks();
                if (isGuestUserHomePage) {
                    super.onBackPressed();
                } else {
                    //Going back to home screen
                    selectItem("home", mAppTitle, null, null, 0);
                }
            }
        }
    }

    /* Check current activity stack close VideoLightBox and AdvVideoView
     * if they are running in pip mode*/
    private void checkActivityStack() {

        ActivityManager mngr = (ActivityManager) getSystemService(ACTIVITY_SERVICE);

        List<ActivityManager.RunningTaskInfo> taskList = mngr.getRunningTasks(5);

        if (taskList != null && taskList.size() > 0) {
            if (VideoLightBox.mActivityRef != null && VideoLightBox.mActivityRef.get() != null) {
                VideoLightBox.mActivityRef.get().finish();
            }

            if (AdvVideoView.mActivityRef != null && AdvVideoView.mActivityRef.get() != null) {
                AdvVideoView.mActivityRef.get().finish();
            }
        }
    }

    // Reset toolbar and bottom navigation tabs view
    private void resetToolbarAndBottomTabs() {
        mBottomNavigationTabs.getMenu().findItem(R.id.navigation_home).setChecked(true);
        selectHomeScreenTab();
        setTabVisibility(TYPE_HOME);
        isHomePage = true;
        currentSelectedOption = ConstantVariables.HOME_MENU_TITLE;
        PreferencesUtils.updateCurrentModule(mContext, currentSelectedOption);

        setToolbarView();
        invalidateOptionsMenu();

        if (viewPager != null) {
            viewPager.setCurrentItem(0);
        }

        MenuItem menuItem = mBottomNavigationTabs.getMenu().findItem(getSelectedTabsId());
        if (menuItem != null)
            menuItem.setChecked(true);

        if (loadFragment != null) {
            replaceFragment(new BlankFragment());
        }
    }

    // Reset the toolbar view and icons on module selection and come back on home screen
    private void setToolbarView() {
        if ((isHomePage || isGuestUserHomePage) && ConstantVariables.SHOW_APP_TITLE_IN_HEADER == 0) {
            findViewById(R.id.search_bar).setVisibility(View.VISIBLE);
            findViewById(R.id.search_bar).setOnClickListener(this);
            invalidateOptionsMenu();
        } else {
            findViewById(R.id.search_bar).setVisibility(View.GONE);
        }

        CustomViews.createMarqueeTitle(mContext, toolbar);
    }


    @Override
    public void onClick(View view) {
        LogUtils.LOGD("MainActivity", String.valueOf(view.getId()));

        switch (view.getId()) {

            case R.id.create_fab:
                //create page url settings
                Intent createEntry;
                String url = null;

                if (currentSelectedOption != null) {
                    createEntry = new Intent(MainActivity.this, CreateNewEntry.class);

                    switch (currentSelectedOption) {
                        case ConstantVariables.HOME_MENU_TITLE:
                            if (view.getTag() != null && view.getTag().equals("core_main_message")) {
                                createEntry = new Intent(MainActivity.this, CreateNewMessage.class);
                            } else {
                                createEntry = new Intent(this, SettingsListActivity.class);
                            }
                            break;

                        case ConstantVariables.MESSAGE_MENU_TITLE:
                            createEntry = new Intent(MainActivity.this, CreateNewMessage.class);
                            break;

                        case ConstantVariables.BLOG_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "/blogs/create";
                            break;

                        case ConstantVariables.CLASSIFIED_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "/classifieds/create";
                            break;

                        case ConstantVariables.GROUP_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "groups/create";
                            break;

                        case ConstantVariables.VIDEO_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "videos/create";
                            break;

                        case ConstantVariables.EVENT_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "events/create";
                            break;

                        case ConstantVariables.MUSIC_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "music/create";
                            break;

                        case ConstantVariables.POLL_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "/polls/create";
                            break;

                        case ConstantVariables.MLT_MENU_TITLE:
                            if (mPackagesEnabled == 1) {
                                createEntry = new Intent(this, SelectPackage.class);
                                url = UrlUtil.MLT_PACKAGE_LIST_URL + "&listingtype_id=" +
                                        PreferencesUtils.getCurrentSelectedListingId(mContext);
                            } else {
                                url = AppConstant.DEFAULT_URL + "listings/create?listingtype_id=" +
                                        PreferencesUtils.getCurrentSelectedListingId(mContext);
                            }
                            createEntry.putExtra(ConstantVariables.LISTING_TYPE_ID,
                                    PreferencesUtils.getCurrentSelectedListingId(mContext));
                            break;

                        case ConstantVariables.MLT_WISHLIST_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "listings/wishlist/create";
                            break;

                        case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
                            if (mPackagesEnabled == 1) {
                                createEntry = new Intent(this, SelectPackage.class);
                                url = UrlUtil.ADV_EVENTS_PACKAGE_LIST_URL;
                            } else {
                                url = AppConstant.DEFAULT_URL + "advancedevents/create";
                            }
                            break;

                        case ConstantVariables.DIARY_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "advancedevents/diaries/create";
                            createEntry.putExtra(ConstantVariables.FORM_TYPE, "create_new_diary");
                            break;

                        case ConstantVariables.SITE_PAGE_MENU_TITLE:
                        case ConstantVariables.SITE_PAGE_TITLE_MENU:
                            if (mPackagesEnabled == 1) {
                                createEntry = new Intent(this, SelectPackage.class);
                                url = UrlUtil.SITE_PAGE_PACKAGE_LIST_URL;
                            } else
                                url = AppConstant.DEFAULT_URL + "sitepages/create";
                            break;

                        case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                            if (mPackagesEnabled == 1) {
                                createEntry = new Intent(this, SelectPackage.class);
                                url = UrlUtil.ADV_GROUP_PACKAGE_LIST_URL;
                            } else
                                url = AppConstant.DEFAULT_URL + "advancedgroups/create";
                            break;

                        case ConstantVariables.ADV_VIDEO_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "advancedvideos/create";
                            break;

                        case ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "advancedvideos/channel/create";
                            break;

                        case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                            url = AppConstant.DEFAULT_URL + "advancedvideos/playlist/create";
                            break;
                        case ConstantVariables.STORE_MENU_TITLE:
                            if (mPackagesEnabled == 1) {
                                createEntry = new Intent(this, SelectPackage.class);
                                url = UrlUtil.STORE_PACKAGE_LIST_URL;
                            } else {
                                createEntry = new Intent(this, CreateNewEntry.class);
                                url = AppConstant.DEFAULT_URL + "sitestore/create/";
                            }
                            createEntry.putExtra(ConstantVariables.FORM_TYPE, "store_create");
                            PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.STORE_MENU_TITLE);
                            break;
                        case ConstantVariables.CROWD_FUNDING_MAIN_TITLE:
                            if (mPackagesEnabled == 1) {
                                createEntry = new Intent(mContext, SelectPackage.class);
                                url = UrlUtil.CROWD_FUNDING_PACKAGE_URL;
                            } else {
                                createEntry = new Intent(mContext, CreateNewEntry.class);
                                url = UrlUtil.CROWD_FUNDING_PROJECT_CREATE_URL;
                            }
                            createEntry.putExtra(ConstantVariables.URL_STRING, UrlUtil.CROWD_FUNDING_PROJECT_CREATE_URL);
                            createEntry.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
                            createEntry.putExtra(ConstantVariables.KEY_TOOLBAR_TITLE, getResources().getString(R.string.create_project));
                            createEntry.putExtra(ConstantVariables.KEY_SUCCESS_MESSAGE, getResources().getString(R.string.project_created_successfully));
                            createEntry.putExtra(ConstantVariables.KEY_PACKAGE_NAME, "com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.utils.CoreUtil");
                            createEntry.putExtra(ConstantVariables.KEY_METHOD_NAME, "getCreatedPageIntent");
                            PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
                            break;
                        default:
                            currentSelectedOption = PreferencesUtils.getCurrentSelectedModule(mContext);
                            break;

                    }

                    createEntry.putExtra(ConstantVariables.CREATE_URL, url);
                    startActivityForResult(createEntry, ConstantVariables.CREATE_REQUEST_CODE);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                }
                break;

            case R.id.create_new_album:
                mFabMenu.close(true);
                url = AppConstant.DEFAULT_URL + "albums/upload?create_new_album=1";
                createEntry = new Intent(MainActivity.this, CreateNewEntry.class);
                createEntry.putExtra(ConstantVariables.CREATE_URL, url);
                createEntry.putExtra(ConstantVariables.KEY_TOOLBAR_TITLE, mContext.getResources().getString(R.string.title_activity_create_new_album));
                startActivityForResult(createEntry, ConstantVariables.CREATE_REQUEST_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.edit_album:
                if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            ConstantVariables.WRITE_EXTERNAL_STORAGE);
                } else {
                    showListOfAlbums();
                }
                break;

            case R.id.search_bar:
                PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.HOME_MENU_TITLE);
                //calling the search activity
                Intent searchActivity = new Intent(MainActivity.this, SearchActivity.class);
                searchActivity.putExtra(ConstantVariables.IS_SEARCHED_FROM_DASHBOARD, false);
                startActivity(searchActivity);
                break;


            case R.id.search_icon_view:
            case R.id.search_icon:
                //calling the search activity
                Intent searchIntent = new Intent(MainActivity.this, SearchActivity.class);
                searchIntent.putExtra(ConstantVariables.IS_SEARCHED_FROM_DASHBOARD, false);
                searchIntent.putExtra(ConstantVariables.CATEGORY_FORUM_TOPIC,
                        getResources().getString(R.string.query_search_forum_topics));
                if (menuOtherInfo != null) {
                    searchIntent.putExtra(ConstantVariables.URL_STRING, menuOtherInfo.optString("url"));
                    searchIntent.putExtra(ConstantVariables.SEARCH_TITLE, menuOtherInfo.optString("label"));
                    searchIntent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, menuOtherInfo.optString("module"));
                    searchIntent.putExtra(ConstantVariables.KEY_PACKAGE_NAME, GlobalFunctions.getAbsClassPath(mContext, menuOtherInfo.optString("module")));
                }
                startActivity(searchIntent);
                break;

            case R.id.action_location:
            case R.id.location_icon:
            case R.id.location_icon_view:
                if (!mAppConst.checkManifestPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
                    mAppConst.requestForManifestPermission(Manifest.permission.ACCESS_FINE_LOCATION,
                            ConstantVariables.ACCESS_FINE_LOCATION);
                } else {
                    changeLocation();
                }
                break;

            default:
                Intent intent = new Intent(this, CartView.class);
                startActivity(intent);


        }

    }

    public void setTabVisibility(int viewType) {
        switch (viewType) {
            case TYPE_HOME:
                BottomNavigationBehavior.updateBehaviour(true);
                mToolbarParams.setScrollFlags(SCROLL_FLAG_SCROLL | SCROLL_FLAG_ENTER_ALWAYS);
                mBottomNavigationTabs.setVisibility(View.VISIBLE);
                mEventFilters.setVisibility(View.GONE);
                mTabHost.setVisibility(View.GONE);
                mFabCreate.setVisibility(View.GONE);
                mFabMenu.hideMenu(false);
                if (viewPager != null)
                    viewPager.setVisibility(View.VISIBLE);
                findViewById(R.id.main_content).setVisibility(View.GONE);
                setTitle(mAppTitle);
                break;

            case TYPE_MODULE:
                BottomNavigationBehavior.updateBehaviour(false);
                mToolbarParams.setScrollFlags(SCROLL_FLAG_SCROLL | SCROLL_FLAG_ENTER_ALWAYS);
                isHomePage = false;
                mBottomNavigationTabs.setVisibility(View.GONE);
                if (viewPager != null)
                    viewPager.setVisibility(View.GONE);
                findViewById(R.id.main_content).setVisibility(View.VISIBLE);
                mEventFilters.setVisibility(View.GONE);
                if (!currentSelectedOption.equals(ConstantVariables.ALBUM_MENU_TITLE)) {
                    mFabMenu.hideMenu(false);
                }
                break;

            case TYPE_OTHER:
                BottomNavigationBehavior.updateBehaviour(false);
                mToolbarParams.setScrollFlags(0);
                isHomePage = false;
                mBottomNavigationTabs.setVisibility(View.GONE);
                if (viewPager != null)
                    viewPager.setVisibility(View.GONE);
                findViewById(R.id.main_content).setVisibility(View.VISIBLE);
                mEventFilters.setVisibility(View.GONE);
                mTabHost.setVisibility(View.GONE);
                mFabMenu.hideMenu(false);
                break;
        }
    }

    @Override
    public void onCheckInLocationChanged(final Bundle data) {
        loadFragmentOnDefaultLocationChanged(data.getBoolean("isNewLocation", true));
        if (data.getBoolean("isNewLocation", true)) {
            setCurrentLocationOnServer(data.getString("locationObject", ""), data.getInt("user_id"));
        }
    }

    private void loadFragmentOnDefaultLocationChanged(final boolean isNewLocation) {
        if (!currentSelectedOption.equals(ConstantVariables.HOME_MENU_TITLE)) {
            final Fragment loadFragment = GlobalFunctions.getAuthenticateUserFragment(currentSelectedOption,
                    mStoreWishListEnabled, mMLTWishListEnabled);

            Toast.makeText(mContext, getResources().getString(R.string.change_location_success_message),
                    Toast.LENGTH_LONG).show();

            if (loadFragment != null && isNewLocation) {
                replaceFragment(loadFragment);
            }
        }
    }


    private void loadFragmentOnGPSEnabled() {
        if (!currentSelectedOption.equals(ConstantVariables.HOME_MENU_TITLE)) {
            final Fragment loadFragment = GlobalFunctions.getAuthenticateUserFragment(currentSelectedOption,
                    mStoreWishListEnabled, mMLTWishListEnabled);
            replaceFragment(loadFragment);
        }
    }


    @Override
    public void onUploadResponse(JSONObject jsonObject, boolean isRequestSuccessful) {
        String message;
        if (isRequestSuccessful) {
            message = getResources().
                    getQuantityString(R.plurals.photo_upload_msg,
                            mSelectPath.size(),
                            mSelectPath.size());
        } else {
            message = jsonObject.optString("message");
        }
        SnackbarUtils.displaySnackbar(findViewById(R.id.main_content), message);

    }

    /**
     * Method to start new activity according to push notification type.
     *
     * @param type                type of push notification.
     * @param id                  id of content page.
     * @param listingTypeId       listingtypeId in case of sitereview.
     * @param notificationViewUrl web view url.
     * @param headerTitle         title of push notification.
     */
    public void startNewActivity(String type, int id, int listingTypeId, String notificationViewUrl,
                                 String headerTitle, JSONObject paramsObject) {
        Intent viewIntent;
        MyFcmListenerService.clearPushNotification();
        GlobalFunctions.updateBadgeCount(mContext, false);

        switch (type) {

            case "user":
            case "siteverify_verify":
            case "siteverify_new":
            case "siteverify_user_request":
            case "siteverify_admin_approve":
                viewIntent = new Intent(getApplicationContext(), userProfile.class);
                viewIntent.putExtra("user_id", id);
                startActivityForResult(viewIntent, ConstantVariables.USER_PROFILE_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

                break;
            case "activity_action":
            case "activity_comment":
                viewIntent = new Intent(mContext, SingleFeedPage.class);
                if (type.equals("activity_action") && paramsObject != null &&
                        paramsObject.optInt("attachment_count") > 1) {
                    viewIntent.putExtra("isFromNotifications", true);
                }

                viewIntent.putExtra(ConstantVariables.ACTION_ID, id);
                startActivity(viewIntent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;
            case "messages_conversation":
                if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                    MessageCoreUtils.openTwoUsersConversation(mContext, String.valueOf(id),
                            headerTitle, null);
                } else {
                    viewIntent = GlobalFunctions.getIntentForModule(getApplicationContext(), id, type, null);
                    viewIntent.putExtra("UserName", headerTitle);
                    startActivity(viewIntent);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                }

                break;
            default:
                viewIntent = GlobalFunctions.getIntentForModule(getApplicationContext(), id, type, null);
                if (viewIntent != null
                        && !Arrays.asList(ConstantVariables.DELETED_MODULES).contains(type)) {

                    if (type.equals("sitereview_listing") || type.equals("sitereview_review")) {
                        viewIntent.putExtra(ConstantVariables.LISTING_TYPE_ID, listingTypeId);
                    }

                    startActivityForResult(viewIntent, ConstantVariables.VIEW_PAGE_CODE);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                } else if (notificationViewUrl != null && !notificationViewUrl.isEmpty()) {
                    if (ConstantVariables.WEBVIEW_ENABLE == 0) {
                        CustomTabUtil.launchCustomTab(this, GlobalFunctions.
                                getWebViewUrl(notificationViewUrl, mContext));
                    } else {
                        Intent webViewActivity = new Intent(MainActivity.this, WebViewActivity.class);
                        webViewActivity.putExtra("headerText", headerTitle);
                        webViewActivity.putExtra("url", notificationViewUrl);
                        startActivityForResult(webViewActivity, ConstantVariables.WEB_VIEW_ACTIVITY_CODE);
                        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                }
                break;
        }
    }

    private void setVisibilityOfFabCreate() {
        mFabCreate.hide();
        Drawable icon = ContextCompat.getDrawable(
                this, R.drawable.ic_action_new);
        icon.mutate();
        icon.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.white),
                PorterDuff.Mode.SRC_ATOP));
        mFabCreate.setImageDrawable(icon);
        mFabCreate.show();
        mFabCreate.setVisibility(View.VISIBLE);
        CoordinatorLayout.LayoutParams layoutParams = (CoordinatorLayout.LayoutParams) mFabCreate.getLayoutParams();
        layoutParams.setMargins(0, 0, 0, (int) mContext.getResources().getDimension(R.dimen.margin_20dp));
        mFabCreate.setLayoutParams(layoutParams);
    }


    public void changeLocation() {

        if (AppConstant.mLocationType != null && AppConstant.mLocationType.equals("specific")) {

            try {
                mSelectedLocationInfo = new HashMap<>();
                AlertDialog.Builder alertBuilder = new AlertDialog.Builder(this);
                alertBuilder.setTitle(getResources().getString(R.string.location_popup_title));
                JSONObject multiLocations = null;
                int selectedPosition = 0;
                locationAdapter = new ArrayAdapter<>(this, android.R.layout.select_dialog_singlechoice);
                String locations = PreferencesUtils.getLocations(mContext);

                // Put Location key and label in adapter and hashmap
                if (locations != null && !locations.isEmpty()) {
                    multiLocations = new JSONObject(locations);
                    JSONArray localeNames = multiLocations.names();

                    for (int i = 0; i < multiLocations.length(); i++) {
                        String locationKey = localeNames.getString(i);
                        locationAdapter.add(multiLocations.getString(locationKey));
                        mSelectedLocationInfo.put(multiLocations.getString(locationKey), locationKey);
                    }
                }

                // Show the previously selected location selected in AlertBox
                if (multiLocations != null && multiLocations.has(PreferencesUtils.getDefaultLocation(mContext))) {
                    String defaultLang = multiLocations.optString(PreferencesUtils.getDefaultLocation(mContext));
                    selectedPosition = locationAdapter.getPosition(defaultLang);

                }

                alertBuilder.setSingleChoiceItems(locationAdapter, selectedPosition,
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.cancel();
                                String location = mSelectedLocationInfo.get(locationAdapter.getItem(which));
                                if (location != null && !location.isEmpty() && !PreferencesUtils.getDefaultLocation(mContext).equals(location)) {
                                    PreferencesUtils.updateDashBoardData(mContext,
                                            PreferencesUtils.DASHBOARD_DEFAULT_LOCATION, location);
                                    loadFragmentOnDefaultLocationChanged(true);
                                }
                            }
                        });

                alertBuilder.create().show();
            } catch (JSONException | NullPointerException e) {
                e.printStackTrace();
            }

        } else {
            if (AppConstant.isDeviceLocationChange == 1) {
                Bundle bundle = new Bundle();
                bundle.putBoolean(ConstantVariables.CHANGE_DEFAULT_LOCATION, true);
                checkInLocationDialog = new CheckInLocationDialog(MainActivity.this, bundle);
                checkInLocationDialog.show();
            } else {
                SnackbarUtils.displaySnackbar(findViewById(R.id.main_content), getResources().getString(R.string.change_location_permission_message));
            }
        }
    }

    /* Executing background task for sending post request for sing out */
    AsyncTask<Void, Void, Void> task = new AsyncTask<Void, Void, Void>() {
        @Override
        protected void onPreExecute() {

            progressDialog = ProgressDialog.show(MainActivity.this, "",
                    getResources().getString(R.string.progress_dialog_message) + "....",
                    true, false);
        }

        @Override
        protected Void doInBackground(Void... arg0) {
            Map<String, String> params = new HashMap<>();
            params.put("device_uuid", mAppConst.getDeviceUUID());

            mAppConst.postJsonRequest(AppConstant.DEFAULT_URL + "logout", params);
            MessageCoreUtils.logout();
            MyFcmListenerService.clearPushNotification();
            MyFcmListenerService.clearMessengerPushNotification();
            NotificationManager notificationManager = (NotificationManager) getApplicationContext().getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.cancelAll();
            GlobalFunctions.updateBadgeCount(mContext, true);
            try {
                // Delete existing FirebaseInstanceId and generate a new one for the new user.
                FirebaseInstanceId.getInstance().deleteInstanceId();
                FirebaseInstanceId.getInstance().getToken();
            } catch (IOException e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void result) {
            if (progressDialog != null) {
                progressDialog.dismiss();

                if (!mContext.getResources().getString(R.string.facebook_app_id).isEmpty())
                    LoginManager.getInstance().logOut();

                Intent homeScreen;
                if (ConstantVariables.INTRO_SLIDE_SHOW_ENABLED == 1) {
                    homeScreen = new Intent(MainActivity.this, NewLoginActivity.class);
                } else {
                    homeScreen = new Intent(MainActivity.this, LoginActivity.class);
                }
                homeScreen.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(homeScreen);
                finish();
                overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
            }
        }
    };

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (!isSetLocation && checkInLocationDialog != null && checkInLocationDialog.isShowing()) {
            checkInLocationDialog.onRequestPermissionsResult(requestCode, permissions, grantResults);
            return;
        }
        switch (requestCode) {
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, proceed to the normal flow.
                    showListOfAlbums();
                } else {
                    // If user deny the permission popup
                    if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE)) {

                        // Show an explanation to the user, After the user
                        // sees the explanation, try again to request the permission.

                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    } else {
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.

                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext,
                                findViewById(R.id.main_content), ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    }
                }
                break;

            case ConstantVariables.PERMISSION_WAKE_LOCK:

                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, proceed to the normal flow.
                    mFirebaseAnalytics = FirebaseAnalytics.getInstance(this);
                } else {
                    // If user deny the permission popup
                    if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                            Manifest.permission.WAKE_LOCK)) {

                        // Show an explanation to the user, After the user
                        // sees the explanation, try again to request the permission.

                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.WAKE_LOCK,
                                ConstantVariables.PERMISSION_WAKE_LOCK);

                    } else {
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.

                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext,
                                findViewById(R.id.main_content), ConstantVariables.PERMISSION_WAKE_LOCK);

                    }
                }
                break;

            case ConstantVariables.ACCESS_FINE_LOCATION:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    requestForDeviceLocation();
                } else {
                    // If user press deny in the permission popup
                    if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                            Manifest.permission.ACCESS_FINE_LOCATION)) {

                        // Show an expanation to the user After the user
                        // sees the explanation, try again to request the permission.

                        AlertDialogWithAction mAlertDialogWithAction = new AlertDialogWithAction(this);
                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.ACCESS_FINE_LOCATION,
                                ConstantVariables.ACCESS_FINE_LOCATION);

                    } else {
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.

                        SnackbarUtils.displaySnackbarOnPermissionResult(this, findViewById(R.id.app_bar_content),
                                ConstantVariables.ACCESS_FINE_LOCATION);
                    }
                }
                break;

        }
    }

    public boolean isCometchatAppInstalled(String packageName) {
        try {
            getPackageManager().getApplicationInfo(packageName, 0);
            return true;
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
    }

    public synchronized void buildGoogleApiClient() {
        if (mGoogleApiClient == null) {
            mGoogleApiClient = new GoogleApiClient.Builder(mContext)
                    .addConnectionCallbacks(this)
                    .addOnConnectionFailedListener(this)
                    .addApi(LocationServices.API)
                    .build();
        }

        if (mGoogleApiClient.isConnected()) {
            mGoogleApiClient.disconnect();
        }

        mGoogleApiClient.connect();

        if (mLocationRequest == null) {
            mLocationRequest = new LocationRequest();
        }

        mLocationRequest.setInterval(1000);
        mLocationRequest.setFastestInterval(1000);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);
    }

    @Override
    public void onConnected(@Nullable Bundle bundle) {
        if (ContextCompat.checkSelfPermission(mContext,
                Manifest.permission.ACCESS_FINE_LOCATION)
                == PackageManager.PERMISSION_GRANTED && mGoogleApiClient.isConnected()) {

            LocationServices.FusedLocationApi.requestLocationUpdates(
                    mGoogleApiClient, mLocationRequest, this);

        }
    }

    @Override
    public void onConnectionSuspended(int i) {
    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
    }

    @Override
    public void onLocationChanged(Location location) {
        Geocoder geocoder = new Geocoder(this, Locale.getDefault());

        try {
            List<Address> addresses = geocoder.getFromLocation(location.getLatitude(),
                    location.getLongitude(), 1);


            if (addresses != null) {
                Address address = addresses.get(0);
                ArrayList<String> addressFragments = new ArrayList<>();
                // Fetch the address lines using getAddressLine and join them.
                for (int i = 0; i <= address.getMaxAddressLineIndex(); i++) {
                    addressFragments.add(address.getAddressLine(i));
                }
                if (!isCurrentLocationSet) {
                    isCurrentLocationSet = true;
                    String locationLabel = address.getFeatureName() + " " + address.getLocality();
                    String mNewLocation = TextUtils.join(System.getProperty("line.separator"), addressFragments);

                    Toast.makeText(mContext, getResources().getString(R.string.current_location_text) + " " + locationLabel,
                            Toast.LENGTH_LONG).show();

                    PreferencesUtils.updateDashBoardData(mContext,
                            PreferencesUtils.DASHBOARD_DEFAULT_LOCATION, mNewLocation);

                    JSONObject userDetail = (!mAppConst.isLoggedOutUser() && PreferencesUtils.getUserDetail(mContext) != null) ? new JSONObject(PreferencesUtils.getUserDetail(mContext)) : null;
                    int user_id = 0;
                    if (userDetail != null) {
                        userDetail.put(PreferencesUtils.USER_LOCATION_LATITUDE, location.getLatitude());
                        userDetail.put(PreferencesUtils.USER_LOCATION_LONGITUDE, location.getLongitude());
                        PreferencesUtils.updateUserDetails(mContext, userDetail.toString());
                        userDetail.optInt("user_id");
                    }

                    JSONObject locationObject = new JSONObject();
                    locationObject.put("country", address.getCountryName());
                    locationObject.put("state", address.getAdminArea());
                    locationObject.put("zipcode", address.getPostalCode());
                    locationObject.put("city", address.getSubAdminArea());
                    locationObject.put("countryCode", address.getCountryCode());
                    locationObject.put("address", address.getFeatureName());
                    locationObject.put("formatted_address", mNewLocation);
                    locationObject.put("location", mNewLocation);
                    locationObject.put("latitude", address.getLatitude());
                    locationObject.put("longitude", address.getLongitude());

                    setCurrentLocationOnServer(locationObject.toString(), user_id);

                }
            }
        } catch (IOException | IndexOutOfBoundsException | JSONException e) {
            e.printStackTrace();
        }

        try {
            //stop location updates
            if (mGoogleApiClient != null) {
                LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this);
            }
        } catch (IllegalStateException e) {
            e.printStackTrace();
        }

    }

    private void setCurrentLocationOnServer(String object, int user_id) {
        String url = AppConstant.DEFAULT_URL + "memberlocation/edit-address?resource_type=user&user_id=" + user_id;
        HashMap<String, String> params = new HashMap<>();
        params.put("location", object);

        mAppConst.postJsonResponseForUrl(url, params, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

            }
        });

    }

    public void requestForDeviceLocation() {

        mGoogleApiClient = new GoogleApiClient.Builder(mContext)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();
        mGoogleApiClient.connect();
        mLocationRequest = new LocationRequest();
        mLocationRequest.setPriority(LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);

        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder().addLocationRequest(mLocationRequest);
        builder.setAlwaysShow(true);
        PendingResult<LocationSettingsResult> result = LocationServices.SettingsApi.checkLocationSettings(mGoogleApiClient, builder.build());
        result.setResultCallback(new ResultCallback<LocationSettingsResult>() {
            @Override
            public void onResult(LocationSettingsResult result) {
                final com.google.android.gms.common.api.Status status = result.getStatus();
                switch (status.getStatusCode()) {
                    case LocationSettingsStatusCodes.SUCCESS:
                        if (isHomePage) {
                            autoUpdateCurrentLocation();
                        } else {
                            loadFragmentOnGPSEnabled();
                        }
                        break;
                    case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                        try {
                            status.startResolutionForResult((Activity) mContext, ConstantVariables.PERMISSION_GPS_SETTINGS);
                        } catch (IntentSender.SendIntentException e) {
                            e.printStackTrace();
                        }
                        break;
                    case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                        break;
                }
            }
        });
    }

    /*
     * Show case view dismiss listener override method
     * */
    @Override
    public void onDismiss() {
        if (isRequested)
            isShowCaseView = false;

        isHomePage = true;
        resumeVideoPlay();
        checkLocationPermission();
    }

    /* Check and request for device location to access all the location based features */
    private void checkLocationPermission() {
        isCurrentLocationSet = false;
        if (isSetLocation && AppConstant.mLocationType != null && AppConstant.mLocationType.equals("notspecific")
                && AppConstant.isDeviceLocationEnable == 1) {
            isSetLocation = false;
            if (!mAppConst.checkManifestPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
                mAppConst.requestForManifestPermission(Manifest.permission.ACCESS_FINE_LOCATION,
                        ConstantVariables.ACCESS_FINE_LOCATION);
            } else {
                requestForDeviceLocation();
            }
        }
    }

    //OCTOBER 2018 QR CODE CUSTOMIZATION
    private void checkForRequiredFields() {
        if (mAppConst.isLoggedOutUser()) {
            return;
        }
        try {
            JSONObject userDetail = new JSONObject(PreferencesUtils.getUserDetail(mContext));
            if (userDetail == null) {
                return;
            }
            mAppConst.getJsonResponseFromUrl(UrlUtil.CHECK_REQUIRED_FIELD + userDetail.optString("user_id", "0"),
                    new OnResponseListener() {
                        @Override
                        public void onTaskCompleted(JSONObject response) {
                            if (response != null && response.optInt("isEmptyRequiredField") == 1) {
                                showRequiredFieldAlert();
                            }
                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                        }
                    });
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void showRequiredFieldAlert() {
        android.support.v7.app.AlertDialog.Builder mDialogBuilder = new android.support.v7.app.AlertDialog.Builder(mContext);
        String message = mContext.getResources().getString(R.string.required_field_alert_message);
        mDialogBuilder.setMessage(message);
        mDialogBuilder.setCancelable(false);
        mDialogBuilder.setPositiveButton(mContext.getResources().getString(R.string.date_time_dialogue_ok_button),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        Intent intent = new Intent(mContext, EditProfileActivity.class);
                        intent.putExtra("url", UrlUtil.EDIT_MEMBER_PROFILE);
                        intent.putExtra("is_photo_tab", false);
                        intent.putExtra(ConstantVariables.FILL_REQUIRED_FIELD, true);
                        ((Activity) mContext).startActivityForResult(intent, ConstantVariables.EDIT_ENTRY_RETURN_CODE);
                        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                });
        if (isAlreadyLoggedIn) {
            mDialogBuilder.setNegativeButton(mContext.getResources().getString(R.string.date_time_dialogue_cancel_button), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                    finish();
                }
            });
        }
        mDialogBuilder.create().show();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(runnableCode);
        if (dialog != null) {
            dialog.dismiss();
        }
        checkActivityStack();
    }

    /* Change app's currency and display price in selected currency accross the app */
    public void changeCurrency(final Context mContext, final String currentSelectedOption) {
        try {
            CurrencyAdapter currencyAdapter;
            List<SlideShowListItems> mBrowseItemList = new ArrayList<>();
            int selectedPosition = 0;
            boolean isCurrencySet = false;
            final android.support.v7.app.AlertDialog.Builder alertBuilder = new android.support.v7.app.AlertDialog.Builder(mContext);
            alertBuilder.setTitle(mContext.getResources().getString(R.string.currency_popup_title));

            String currencyString = PreferencesUtils.getMultiCurrencyResponse(mContext);
            JSONObject currencyObject = new JSONObject(currencyString);
            JSONArray currencyList = currencyObject.optJSONArray("response");

            for (int i = 0; i < currencyList.length(); i++) {
                JSONObject jsonObject = currencyList.optJSONObject(i);
                if (!isCurrencySet && PreferencesUtils.getDefaultCurrencyString(mContext) != null
                        && PreferencesUtils.getDefaultCurrencyString(mContext).equals(jsonObject.optString("code"))) {
                    selectedPosition = i;
                    isCurrencySet = true;
                }
                mBrowseItemList.add(new SlideShowListItems(jsonObject));
            }

            currencyAdapter = new CurrencyAdapter(mContext, android.R.layout.select_dialog_singlechoice,
                    mBrowseItemList, selectedPosition);
            alertBuilder.setAdapter(currencyAdapter, (dialog, which) -> {
                SlideShowListItems item = currencyAdapter.getItem(which);
                if (item != null && item.getmObject() != null && item.getmObject().length() > 0) {

                    String currencyName;
                    if (PreferencesUtils.getCurrencyFormat(mContext).equals("countryFlag")) {
                        currencyName = item.getmObject().optString("currency_name");
                    } else {
                        currencyName = item.getmObject().optString("code");
                    }

                    if (currencyName != null &&
                            !currencyName.equals(PreferencesUtils.getSelectedCurrency(mContext))) {

                        PreferencesUtils.setSelectedCurrency(mContext, currencyName, item.getmObject().toString());

                        Toast.makeText(mContext, getResources().getString(R.string.change_currency_success_message),
                                Toast.LENGTH_LONG).show();

                        Bundle bundle = new Bundle();
                        bundle.putBoolean(ConstantVariables.IS_CURRENCY_UPDATED, true);

                        if (loadFragment != null && (!currentSelectedOption.equals(ConstantVariables.HOME_MENU_TITLE) ||
                                mAppConst.isLoggedOutUser())) {
                            loadFragment.onSaveInstanceState(bundle);
                        } else {
                            FeedsFragment fragment = (FeedsFragment) adapter.getItem(0);
                            fragment.onSaveInstanceState(bundle);
                        }
                        // Updating drawer.
                        drawerFragment.drawerUpdate();
                    }
                    dialog.dismiss();
                }
            });
            alertBuilder.create().show();
        } catch (JSONException | NullPointerException e) {
            e.printStackTrace();

        }
    }


    @Override
    protected void onStop() {
        super.onStop();
        handler.removeCallbacks(runnableCode);
    }

    private void getMessageAndMissedCallCount() {
        updateNotificationCounts();
        GlobalFunctions.updateBadgeCount(mContext, false);

        MessageCoreUtils.findUnReadMessageCount(newMessageCount -> {
            PreferencesUtils.updateUnReadMessageCount(mContext, newMessageCount);
            runOnUiThread(() -> {
                updateNotificationCounts();
                GlobalFunctions.updateBadgeCount(mContext, false);
                if (newMessageCount == 0) {
                    MyFcmListenerService.clearMessengerPushNotification();
                }
            });
        });

        MessageCoreUtils.findMissedCallCount(count ->
                runOnUiThread(() -> {
                    updateNotificationCounts();
                    GlobalFunctions.updateBadgeCount(mContext, false);
                }));
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        isRequested = false;
        handleAppLinks();
    }

    @Override
    public void handleAppLinks() {
        if (isRequested) {
            return;
        }
        isRequested = true;
        Intent intent = getIntent();
        Uri data = intent.getData();
        try {
            JSONObject joPrefixes = PreferencesUtils.getHostPathPrefix(mContext);
            if (data != null && data.getPath() != null && (joPrefixes != null && joPrefixes.length() > 0)) {
                String mainPrefix, prefixPath = data.getPath();
                prefixPath = prefixPath.replace(mContext.getResources().getString(R.string.app_host_sub_domain), "");
                prefixPath = prefixPath.substring(1);
                mainPrefix = prefixPath;
                if (specificPathLinking(mainPrefix)) {
                    selectItem("home", mAppTitle, null, null, 0);
                    return;
                }
                if (prefixPath.contains("profile") && prefixPath.contains("action_id") && prefixPath.contains("show_comments")) {
                    prefixPath = prefixPath.substring(prefixPath.indexOf("action_id/"));
                    prefixPath = prefixPath.replace("action_id/", "");
                    prefixPath = prefixPath.substring(0, prefixPath.indexOf("/"));
                    Intent singleFeed = new Intent(mContext, SingleFeedPage.class);
                    singleFeed.putExtra(ConstantVariables.ACTION_ID, Integer.parseInt(prefixPath));
                    startActivity(singleFeed);
                    selectItem("home", mAppTitle, null, null, 0);
                    return;
                }
                String preFix = getPreFix(prefixPath);
                Object oPrefix = joPrefixes.opt(preFix);
                if (oPrefix instanceof JSONObject) {
                    String tempPrefix = preFix;
                    preFix = getPreFix(prefixPath.replace(preFix + "/", ""));
                    JSONObject joPrefix = (JSONObject) oPrefix;
                    preFix = joPrefix.optString(preFix, null);
                    if (joPrefix.optString(preFix, null) == null
                            && joPrefix.optString(preFix + "_view", null) != null) {
                        preFix = joPrefix.optString(preFix + "_view");
                        renderActivity(mainPrefix, preFix);
                    } else {
                        preFix = preFix == null ? joPrefix.optString(tempPrefix) : preFix;
                        renderFragment(data, preFix);
                    }
                } else if (oPrefix instanceof String) {
                    renderFragment(data, oPrefix.toString());
                } else if ((prefixPath = joPrefixes.optString(preFix + "_view")) != null) {
                    renderActivity(mainPrefix, prefixPath);
                    selectItem("home", mAppTitle, null, null, 0);
                }
            } else {
                selectItem("home", mAppTitle, null, null, 0);
            }
        } catch (Exception e) {
            e.printStackTrace();
            selectItem("home", mAppTitle, null, null, 0);
        }

    }

    /**
     * Method to render the activity specified by path prefixes
     *
     * @param mainPrefix exact data path
     * @param prefixPath String
     */
    private void renderActivity(String mainPrefix, String prefixPath) {
        String preFix;
        String index = prefixPath.substring(prefixPath.lastIndexOf("_") + 1);
        preFix = prefixPath.substring(0, prefixPath.lastIndexOf("_"));
        preFix = preFix.contains(ConstantVariables.MLT_MENU_TITLE) ? preFix.substring(0, preFix.lastIndexOf("_")) : preFix;
        prefixPath = prefixPath.replace("_" + index, "");
        prefixPath = prefixPath.replace(preFix, "");
        prefixPath = prefixPath.contains("_") ? prefixPath.replace("_", "") : "0";
        List<String> ids = Arrays.asList(mainPrefix.trim().split("/"));
        Intent intentUrl;
        String contentId = ids.get(Integer.parseInt(index) + 1);
        if (isNumeric(contentId)) {
            intentUrl = GlobalFunctions.getIntentForModule(mContext, Integer.parseInt(contentId), preFix, null);
        } else {
            intentUrl = GlobalFunctions.getIntentForModule(mContext, 0, preFix, contentId);
        }
        if (intentUrl != null) {
            intentUrl.putExtra(ConstantVariables.LISTING_TYPE_ID, Integer.parseInt(prefixPath));
            startActivity(intentUrl);
        }
    }

    /**
     * Method to fetch prefix of the data path
     *
     * @param prefixPath link prefix
     * @return String
     */
    private String getPreFix(String prefixPath) {
        String preFix = prefixPath.contains("/") ? prefixPath.substring(0, prefixPath.indexOf("/")) : prefixPath;
        preFix = !preFix.isEmpty() ? preFix : prefixPath;
        return preFix;
    }

    /**
     * Method to render module home fragment as per the given module name
     *
     * @param data       Uri data path
     * @param moduleName module name
     */
    private void renderFragment(Uri data, String moduleName) {
        String id = "";
        if (moduleName.contains(ConstantVariables.MLT_MENU_TITLE)) {
            id = moduleName.substring(moduleName.lastIndexOf("_") + 1);
            moduleName = moduleName.substring(0, moduleName.lastIndexOf("_"));
        }
        JSONObject menuObject = PreferencesUtils.getMenuByName(mContext, moduleName, "listingtype_id", id);
        String strQueries = data.getPath().replaceAll("[^0-9]+", " ");
        List<String> ids = Arrays.asList(strQueries.trim().split(" "));
        if ((ids.size() > 0 && !ids.get(0).isEmpty()) && (moduleName.contains(ConstantVariables.ALBUM_MENU_TITLE) || moduleName.contains(ConstantVariables.VIDEO_MENU_TITLE) || moduleName.contains(ConstantVariables.ADV_VIDEO_MENU_TITLE))) {
            Intent intentUrl = moduleName.contains(ConstantVariables.ALBUM_MENU_TITLE) ? new Intent(mContext, AlbumView.class)
                    : new Intent(mContext, AdvVideoView.class);
            intentUrl.setData(data);
            startActivity(intentUrl);
            selectItem("home", mAppTitle, null, null, 0);

        }
        if (menuObject != null) {
            JSONObject canCreate = menuObject.optJSONObject("canCreate");
            selectItem(menuObject.optString("name", "home"), menuObject.optString("label", mAppTitle), null, null, (canCreate != null) ? canCreate.optInt("default", 0) : 0);
            isHomePage = true;
        } else {
            selectItem("home", mAppTitle, null, null, 0);
        }
    }

    /**
     * Method to check the numeric string
     *
     * @param value String
     * @return true if numeric else false
     */
    private boolean isNumeric(String value) {
        try {
            Integer.parseInt(value);
        } catch (NumberFormatException nfe) {
            return false;
        }
        return true;
    }

    /**
     * Method to directly redirect to the specific activity.
     *
     * @param path data path
     * @return
     */
    private boolean specificPathLinking(String path) {
        Intent intentUrl;
        if (path.contains("login") && mAppConst.isLoggedOutUser()) {
            if (ConstantVariables.INTRO_SLIDE_SHOW_ENABLED == 1) {
                intentUrl = new Intent(mContext, NewLoginActivity.class);
            } else {
                intentUrl = new Intent(mContext, LoginActivity.class);
            }
            startActivity(intentUrl);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            return true;
        }
        //TODO, ADD Other Cases For Specific Linking Like User Settings etc.
        return false;
    }
}
