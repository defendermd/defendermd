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
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SocialLoginUtil;
import com.socialengineaddons.mobileapp.classes.core.startscreens.HomeScreen;
import com.socialengineaddons.mobileapp.classes.modules.messagingMiddleware.MessageCoreUtils;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;
import com.facebook.CallbackManager;
import com.facebook.login.widget.LoginButton;
import com.socialengineaddons.mobileapp.classes.modules.user.signup.QuickSignUpActivity;
import com.socialengineaddons.mobileapp.classes.modules.user.signup.SubscriptionActivity;
import com.twitter.sdk.android.core.identity.TwitterLoginButton;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import ru.dimorinny.showcasecard.ShowCaseView;
import ru.dimorinny.showcasecard.position.ShowCasePosition;
import ru.dimorinny.showcasecard.position.ViewPosition;
import ru.dimorinny.showcasecard.radius.Radius;
import ru.dimorinny.showcasecard.radius.ShowCaseRadius;


public class FragmentDrawer extends Fragment implements View.OnClickListener, SocialLoginUtil.OnSocialLoginSuccessListener {

    private RecyclerView recyclerView;
    private ActionBarDrawerToggle mDrawerToggle;
    public DrawerLayout mDrawerLayout;
    private NavigationDrawerAdapter adapter;
    private View containerView;
    private ProgressBar mProgressBar;
    private LinearLayout bottomButton;
    private LinearLayout socialSitesButton;
    private List<Object> dataList;
    private FragmentDrawerListener drawerListener;
    private AppConstant mAppConst;
    private JSONObject mMultiLanguages, mCanCreateObject, mOtherInfo;
    private String mMenuHeaderLabel;
    private JSONArray mEnabledModule, menuObject;
    private Context mContext;
    private IntentFilter intentFilter;
    boolean isLoadedForFirstTime = true, isMLTDataUpdated = false, isMemberBrowseTypeSet = false;
    private String mNotificationCount, mRequestCount, mMessageCount, mCartCount;
    private int mLanguageCount;
    private CallbackManager callbackManager;
    private TwitterLoginButton twitterLoginButton;
    private View mLayoutMain;


    //Receiver for getting new updates count to display it in navigation drawer
    private BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if(intent != null){
                switch (intent.getAction()) {
                    case ConstantVariables.ACTION_FEED_NOTIFICATIONS:
                        isLoadedForFirstTime = false;
                        mNotificationCount = PreferencesUtils.getNotificationsCounts(mContext,PreferencesUtils.NOTIFICATION_COUNT);
                        if(PreferencesUtils.isPrimeMessengerEnabled(mContext)){
                            int missedCallCount = MessageCoreUtils.getMissedCallCount();
                            mMessageCount = String.valueOf(PreferencesUtils.getUnReadMessageCount(mContext) + missedCallCount);
                        } else {
                            mMessageCount = PreferencesUtils.getNotificationsCounts(mContext, PreferencesUtils.MESSAGE_COUNT);
                        }
                        mRequestCount = PreferencesUtils.getNotificationsCounts(mContext,PreferencesUtils.FRIEND_REQ_COUNT);
                        mCartCount = PreferencesUtils.getNotificationsCounts(mContext,PreferencesUtils.CART_COUNT);
                        refreshModuleList();
                        break;

                }
            }
        }
    };

    public void updateBadgeCount() {
        if (PreferencesUtils.getDashboardMenus(mContext) != null) {
            try {
                menuObject = new JSONArray(PreferencesUtils.getDashboardMenus(mContext));
            } catch (JSONException e) {
                e.printStackTrace();
            }
            mNotificationCount = PreferencesUtils.getNotificationsCounts(mContext,
                    PreferencesUtils.NOTIFICATION_COUNT);
            if(PreferencesUtils.isPrimeMessengerEnabled(mContext)){
                int missedCallCount = MessageCoreUtils.getMissedCallCount();
                mMessageCount = String.valueOf(PreferencesUtils.getUnReadMessageCount(mContext) + missedCallCount);
            } else {
                mMessageCount = PreferencesUtils.getNotificationsCounts(mContext, PreferencesUtils.MESSAGE_COUNT);
            }
            mRequestCount = PreferencesUtils.getNotificationsCounts(mContext,
                    PreferencesUtils.FRIEND_REQ_COUNT);
            mCartCount = PreferencesUtils.getNotificationsCounts(mContext,PreferencesUtils.CART_COUNT);
            if (menuObject != null && menuObject.length() != 0 && dataList != null) {
                dataList.clear();
                addDataToDrawerList();
            }
        }
    }

    public FragmentDrawer() {
    }

    public void setDrawerListener(FragmentDrawerListener listener) {
        this.drawerListener = listener;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        mAppConst = new AppConstant(getActivity());
        intentFilter = new IntentFilter();
        intentFilter.addAction(ConstantVariables.ACTION_FEED_NOTIFICATIONS);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        mContext = getContext();

        /* Initialize Facebook SDK, we need to initialize before using it ---- */
        SocialLoginUtil.initializeFacebookSDK(mContext);

        SocialLoginUtil.setSocialLoginListener(this);

        // Inflating view layout
        mLayoutMain = inflater.inflate(R.layout.fragment_navigation_drawer, container, false);
        socialSitesButton = (LinearLayout) mLayoutMain.findViewById(R.id.socialSiteButtons);

        if (PreferencesUtils.getDashboardMenus(mContext) != null) {
            try {
                menuObject = new JSONArray(PreferencesUtils.getDashboardMenus(mContext));
                if (PreferencesUtils.getLanguages(mContext) != null &&
                        !PreferencesUtils.getLanguages(mContext).isEmpty()) {
                    mMultiLanguages = new JSONObject(PreferencesUtils.getLanguages(mContext));
                    mLanguageCount = mMultiLanguages.length();
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        callbackManager = CallbackManager.Factory.create();
        twitterLoginButton= mLayoutMain.findViewById(R.id.twitter_login_button);
        twitterLoginButton.setText(getResources().getString(R.string.twitter));
        twitterLoginButton.setTextSize(15);
        twitterLoginButton.setCompoundDrawablePadding(5);

        LinearLayout.LayoutParams facebookParams;

        // Hide Facebook button when facebook_app_id is null or Empty.
        // When Facebook button is hide, twitter button will cover full width of layout(drawer),
        // so we need to reset layout margins
        if (!getResources().getString(R.string.facebook_app_id).isEmpty()) {
            LoginButton facebookLoginButton = new LoginButton(mContext);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT);
            layoutParams.weight = .5f;
            layoutParams.setMargins(0,0, (int) mContext.getResources().getDimension(R.dimen.margin_5dp),0);
            int padding10 = (int) mContext.getResources().getDimension(R.dimen.padding_10dp);
            facebookLoginButton.setLayoutParams(layoutParams);
            facebookLoginButton.setPadding(padding10, padding10, padding10, (int) mContext.getResources().getDimension(R.dimen.padding_12dp));
            socialSitesButton.addView(facebookLoginButton, 0);

            facebookLoginButton.setReadPermissions(Arrays.asList("public_profile, email"));
            facebookLoginButton.setFragment(this);

        } else {
            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) twitterLoginButton.getLayoutParams();
            layoutParams.setMargins(0,0,0,0);
            twitterLoginButton.setLayoutParams(layoutParams);
            twitterLoginButton.setText(getResources().getString(R.string.twitter_login_text));
        }


        // Hide twitter button when TwitterKey or TwitterSecret is null or Empty.
        // When twitter button is hide, facebook button will cover full width of layout(drawer),
        // so we need to reset layout margins
        if (!getResources().getString(R.string.twitter_key).isEmpty()
                && !getResources().getString(R.string.twitter_secret).isEmpty()) {
            twitterLoginButton.setVisibility(View.VISIBLE);

        } else {
            twitterLoginButton.setVisibility(View.GONE);
        }

        mProgressBar = (ProgressBar) mLayoutMain.findViewById(R.id.progressBar);
        bottomButton = (LinearLayout)mLayoutMain.findViewById(R.id.bottomButtons);
        Button mSignInButton = (Button) mLayoutMain.findViewById(R.id.signin_button);
        Button mSignUpButton = (Button) mLayoutMain.findViewById(R.id.signup_button);
        mSignInButton.setOnClickListener(this);
        mSignUpButton.setOnClickListener(this);
        mSignInButton.setPadding(0, (int) getResources().getDimension(R.dimen.login_button_top_bottom_padding),
                0, (int) getResources().getDimension(R.dimen.login_button_top_bottom_padding));
        mSignUpButton.setPadding(0, (int) getResources().getDimension(R.dimen.login_button_top_bottom_padding),
                0, (int) getResources().getDimension(R.dimen.login_button_top_bottom_padding));

        recyclerView = (RecyclerView) mLayoutMain.findViewById(R.id.drawerList);

        // Initializing
        dataList = new ArrayList<>();
        adapter = new NavigationDrawerAdapter(getActivity(), dataList,
                new NavigationDrawerAdapter.OnDrawerItemClickListener() {
                    @Override
                    public void onDrawerItemClick(View view, int position) {
                        DrawerItem drawerItem = (DrawerItem) dataList.get(position);
                        String name = drawerItem.getItemRegName();
                        String label = drawerItem.getItemName();
                        String headerLabel = drawerItem.getmHeaderLabel();
                        String itemUrl = drawerItem.getmItemUrl();
                        String singularLabel = drawerItem.getmListingSingularLabel();
                        int listingTypeId = drawerItem.getmListingTypeId();
                        int browseType = drawerItem.getmBrowseType();
                        int secondaryViewType = drawerItem.mSecondaryViewType;
                        int viewType = drawerItem.getmViewType();
                        int canCreate = drawerItem.getCanCreate();
                        int packagesEnabled = drawerItem.getmPackagesEnabled();
                        String icon = drawerItem.getmItemIcon();
                        hideBadgeCount(position,name);
                        drawerListener.onDrawerItemSelected(view, name, label, headerLabel, singularLabel,
                                itemUrl, listingTypeId, browseType, viewType, icon,canCreate,
                                packagesEnabled, drawerItem.getSiteStoreEnabled(),
                                drawerItem.getListingEnabled(), drawerItem.isCanView(), secondaryViewType, drawerItem.getOtherInfo());
                        mDrawerLayout.closeDrawer(containerView);
                    }

                    @Override
                    public void onUserLayoutClick(int userId) {
                        Intent intent = new Intent(mContext.getApplicationContext(), userProfile.class);
                        intent.putExtra(ConstantVariables.USER_ID, userId);
                        ((FragmentActivity)mContext).startActivityForResult(intent, ConstantVariables.
                                USER_PROFILE_CODE);
                        ((FragmentActivity) mContext).overridePendingTransition(R.anim.slide_in_right,
                                R.anim.slide_out_left);
                        mDrawerLayout.closeDrawer(containerView);
                    }
                });

        if(menuObject != null && menuObject.length() != 0){
            addDataToDrawerList();
        }

        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));

        //Setting up the user details inside the drawer
        // Adding header view.
        dataList.add(ConstantVariables.HEADER_TYPE);
        adapter.notifyDataSetChanged();
        if (PreferencesUtils.getUserDetail(mContext) == null) {
            bottomButton.setVisibility(View.VISIBLE);
            socialSitesButton.setVisibility(View.VISIBLE);
        }


        //Facebook login authentication process
        if (!getResources().getString(R.string.facebook_app_id).isEmpty()) {
            SocialLoginUtil.registerFacebookLoginCallback(mContext, mLayoutMain, callbackManager, false);
        }

        //Twitter login authentication process
        SocialLoginUtil.registerTwitterLoginCallback(mContext, mLayoutMain, twitterLoginButton, false);

        return mLayoutMain;
    }

    private void hideBadgeCount(int position, String name) {
        if(dataList != null && name != null) {
            DrawerItem drawerItem = (DrawerItem) dataList.get(position);
            if (drawerItem.getBadgeCount() != null && !drawerItem.getBadgeCount().equals("0")) {
                switch (name) {
                    case "core_mini_messages":
                        mAppConst.markAllMessageRead(null);
                        drawerItem.setBadgeCount("0");
                        PreferencesUtils.clearNotificationsCount(mContext, PreferencesUtils.MESSAGE_COUNT);
                        adapter.notifyDataSetChanged();
                        break;
                    case "core_mini_notification":
                        mAppConst.markAllNotificationsRead();
                        drawerItem.setBadgeCount("0");
                        PreferencesUtils.clearNotificationsCount(mContext, PreferencesUtils.NOTIFICATION_COUNT);
                        adapter.notifyDataSetChanged();
                        break;
                    case "core_mini_friend_request":
                        mAppConst.markAllFriendRequestsRead();
                        drawerItem.setBadgeCount("0");
                        PreferencesUtils.clearNotificationsCount(mContext, PreferencesUtils.FRIEND_REQ_COUNT);
                        adapter.notifyDataSetChanged();
                        break;
                }
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data){
        super.onActivityResult(requestCode, resultCode, data);

        if (!getResources().getString(R.string.facebook_app_id).isEmpty()) {
            callbackManager.onActivityResult(requestCode, resultCode, data);
        }
        twitterLoginButton.onActivityResult(requestCode, resultCode, data);
    }

    public void refreshModuleList(){
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "get-enabled-modules",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                        mEnabledModule = jsonObject.optJSONArray("response");
                        dataList.clear();
                        addDataToDrawerList();
                        adapter.notifyDataSetChanged();
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });
    }

    int storeWishListEnabled,mltWishListEnabled;
    public void addDataToDrawerList(){

        try {
            // Adding header view.
            if (!dataList.contains(ConstantVariables.HEADER_TYPE)) {
                dataList.add(ConstantVariables.HEADER_TYPE);
            }

            // preparing navigation drawer items
            if (menuObject != null && menuObject.length() > 0) {
                for (int i = 0; i < menuObject.length(); i++) {
                    JSONObject mMenuJson = menuObject.optJSONObject(i);
                    String mMenuType = mMenuJson.optString("type");
                    String mChildMenuLabel = mMenuJson.getString("label");
                    String mItemIcon = mMenuJson.optString("icon");
                    String mIconColor = mMenuJson.optString("color");
                    mMenuHeaderLabel = mMenuJson.optString("headerLabel");
                    mCanCreateObject = mMenuJson.optJSONObject("canCreate");
                    mOtherInfo = mMenuJson.optJSONObject("otherInfo");
                    String menuName = mMenuJson.optString("name");
                    boolean canView = mMenuJson.optInt("memberView", 1) == 1;
                    int mCanCreate;
                    int mPackagesEnabled;
                    if (mCanCreateObject != null) {
                        mCanCreate = mCanCreateObject.optInt("default");
                        mPackagesEnabled = mCanCreateObject.optInt("packagesEnabled");
                        storeWishListEnabled = mCanCreateObject.optInt("sitestore");
                        mltWishListEnabled = mCanCreateObject.optInt("sitereview");
                    } else {
                        mCanCreate = 0;
                        mPackagesEnabled = 0;
                    }
                    if (menuName != null && menuName.equals(ConstantVariables.CROWD_FUNDING_MAIN_TITLE) && !(ConstantVariables.ENABLE_CROWDFUNDING == 1)) {
                        continue;
                    }
                    if (mMenuType.equals("menu")) {
                        String mChildMenuRegName = mMenuJson.getString("name");

                        if (mChildMenuRegName != null && !mChildMenuRegName.isEmpty() && !mChildMenuRegName.equals("null")) {
                            switch (mChildMenuRegName) {
                                case ConstantVariables.MESSAGE_MENU_TITLE:
                                    dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                            mChildMenuRegName, mMessageCount, mCanCreate, 0, mItemIcon, mIconColor, canView, null));
                                    break;

                                case ConstantVariables.NOTIFICATION_MENU_TITLE:
                                    dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                            mChildMenuRegName, mNotificationCount, 0, 0, mItemIcon,  mIconColor, canView, mOtherInfo));
                                    break;

                                case ConstantVariables.FRIEND_REQUEST_MENU_TITLE:
                                    dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                            mChildMenuRegName, mRequestCount, 0, 0, mItemIcon,  mIconColor, canView, mOtherInfo));
                                    break;

                                case ConstantVariables.PRODUCT_CART_MENU_TITLE:
                                    dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                            mChildMenuRegName, mCartCount, 0, 0, mItemIcon,  mIconColor, canView, mOtherInfo));
                                    break;

                                case ConstantVariables.GLOBAL_SEARCH_MENU_TITLE:
                                case ConstantVariables.HOME_MENU_TITLE:
                                case ConstantVariables.TERMS_OF_SERVICE_MENU_TITLE:
                                case ConstantVariables.PRIVACY_POLICY_MENU_TITLE:
                                case ConstantVariables.CONTACT_US_MENU_TITLE:
                                case ConstantVariables.USER_SETTINGS_MENU_TITLE:
                                case ConstantVariables.SPREAD_THE_WORD_MENU_TITLE:
                                case ConstantVariables.RATE_US_MENU_TITLE:
                                case "signout":
                                // Customization.
                                case "sodrujestrvo_taxi":
                                    dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                            mChildMenuRegName, mItemIcon,  mIconColor));
                                    break;

                                case ConstantVariables.APP_TOUR_MENU_TITLE:
                                    if (!mAppConst.isLoggedOutUser()) {
                                        dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                                mChildMenuRegName, mItemIcon,  mIconColor));
                                    }
                                    break;

                                case ConstantVariables.WISHLIST_MENU_TITLE:
                                    dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                            mChildMenuRegName,null,0,0,mItemIcon,  mIconColor,
                                            storeWishListEnabled,mltWishListEnabled));
                                    break;

                                case ConstantVariables.MLT_MENU_TITLE:
                                    // Storing MLT parameters in Preferences for each listing type.

                                    if (!isMLTDataUpdated) {
                                        PreferencesUtils.updateCurrentListingType(mContext,
                                                mMenuJson.optInt("listingtype_id"),
                                                mChildMenuLabel, mMenuJson.optString("header_label_singular"),
                                                mMenuJson.optInt("listingtype_id"),
                                                mMenuJson.optInt("viewBrowseType"),
                                                mMenuJson.optInt("viewProfileType"),
                                                mItemIcon, mCanCreate, mPackagesEnabled, canView, mMenuJson.optInt("mapViewType"));
                                    }

                                    dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                            mChildMenuRegName,
                                            mMenuJson.optString("header_label_singular"),
                                            mMenuJson.optString("url"),
                                            mItemIcon,  mIconColor, mMenuJson.optInt("listingtype_id"),
                                            mMenuJson.optInt("viewBrowseType"),
                                            mMenuJson.optInt("viewProfileType"),
                                            mCanCreate, mPackagesEnabled, canView, mMenuJson.optInt("mapViewType")));

                                    break;

                                case ConstantVariables.MULTI_LANGUAGES_MENU_TITLE:
                                    if (mLanguageCount > 1) {
                                        mAppConst.changeAppLocale(PreferencesUtils.getCurrentLanguage(mContext), true);
                                        dataList.add(new DrawerItem(null,
                                                mMultiLanguages.optString(PreferencesUtils.getCurrentLanguage(mContext)),
                                                mChildMenuRegName, mItemIcon, mIconColor));
                                    }
                                    break;

                                case ConstantVariables.SITE_MULTI_CURRENCY:
                                    if (!PreferencesUtils.getSelectedCurrency(mContext).isEmpty()) {
                                        mChildMenuLabel = PreferencesUtils.getSelectedCurrency(mContext);
                                    }
                                    dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                            mChildMenuRegName, null, mCanCreate, mPackagesEnabled, mItemIcon,  mIconColor, canView, mOtherInfo));
                                    break;

                                case ConstantVariables.LOCATION_MENU_TITLE:
                                    String defaultLocation = PreferencesUtils.getDefaultLocation(mContext);

                                    if (defaultLocation != null && !defaultLocation.isEmpty()) {
                                        dataList.add(new DrawerItem(null, defaultLocation, "seaocore_location", mItemIcon,  mIconColor));
                                    } else {
                                        dataList.add(new DrawerItem(null, mContext.getResources().
                                                getString(R.string.location_popup_title), "seaocore_location", mItemIcon,  mIconColor));
                                    }
                                    break;

                                case "core_main_cometchat":
                                    if(!mAppConst.isLoggedOutUser() && !ConstantVariables.COMETCHAT_PACKAGE_NAME.isEmpty()){
                                        dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                                mChildMenuRegName, null, mCanCreate, mPackagesEnabled, mItemIcon,  mIconColor, canView, mOtherInfo));
                                    }
                                    break;

                                default:

                                    // Updating ticket enabled value into preferences.
                                    if (mChildMenuRegName.equals(ConstantVariables.ADVANCED_EVENT_MENU_TITLE)
                                            && mCanCreateObject != null) {
                                        PreferencesUtils.updateTicketEnabledPref(mContext,
                                                mCanCreateObject.optInt("myTicketEnabled"));
                                    }

                                    // Getting view type of user member page.
                                    if (mChildMenuRegName.equals(ConstantVariables.USER_MENU_TITLE)
                                            && !isMemberBrowseTypeSet) {
                                        isMemberBrowseTypeSet = true;
                                        PreferencesUtils.updateMemberViewType(mContext, mMenuJson.optInt("memberViewType"));
                                    }

                                    if ((mAppConst.isLoggedOutUser() || isLoadedForFirstTime)
                                            && !Arrays.asList(ConstantVariables.DELETED_MODULES).contains(
                                            getModuleName(mChildMenuRegName))) {
                                        dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                                mChildMenuRegName, null, mCanCreate, mPackagesEnabled, mItemIcon,  mIconColor, canView, mOtherInfo));
                                    } else {
                                        if (mEnabledModule != null && isModuleEnabled(mChildMenuRegName)
                                                && !Arrays.asList(ConstantVariables.DELETED_MODULES).contains(
                                                getModuleName(mChildMenuRegName)))
                                            dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel,
                                                    mChildMenuRegName, null, mCanCreate, mPackagesEnabled, mItemIcon,  mIconColor, canView, mOtherInfo));
                                    }


                            }

                        } else {

                            String headerLabel = mMenuJson.optString("headerLabel");
                            String url = mMenuJson.optString("url");

                            dataList.add(new DrawerItem(mChildMenuLabel, null, headerLabel, url, mItemIcon, mIconColor));
                        }


                    } else if (mMenuType.equals("category")) {
                        dataList.add(new DrawerItem(mMenuHeaderLabel, mChildMenuLabel)); // adding a header to the list
                    }

                    mProgressBar.setVisibility(View.GONE);
                    adapter.notifyDataSetChanged();
                }
            }

            isMLTDataUpdated = true;
            adapter.notifyDataSetChanged();

        }catch (JSONException e) {
            e.printStackTrace();
            SnackbarUtils.displaySnackbar(mLayoutMain,
                    getResources().getString(R.string.no_data_available));
        }

    }

    public boolean isModuleEnabled(String name){
        String mModuleName = getModuleName(name);

        if(mModuleName != null ) {
            for (int i = 0; i < mEnabledModule.length(); i++) {
                String moduleName = mEnabledModule.optString(i);
                if (mModuleName.equals(moduleName)) {
                    return true;
                }
            }
        }
        return false;
    }

    public String getModuleName(String menuName){
        switch (menuName){
            case ConstantVariables.BLOG_MENU_TITLE:
                return "blog";
            case ConstantVariables.MUSIC_MENU_TITLE:
                return "music";
            case ConstantVariables.VIDEO_MENU_TITLE:
                return "video";
            case ConstantVariables.ALBUM_MENU_TITLE:
                return "album";
            case ConstantVariables.CLASSIFIED_MENU_TITLE:
                return "classified";
            case ConstantVariables.EVENT_MENU_TITLE:
                return "event";
            case ConstantVariables.GROUP_MENU_TITLE:
                return "group";
            case ConstantVariables.USER_MENU_TITLE:
                return "user";
            case ConstantVariables.FORUM_MENU_TITLE:
                return "forum";
            case ConstantVariables.POLL_MENU_TITLE:
                return "poll";
            case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
            case ConstantVariables.DIARY_MENU_TITLE:
                return "siteevent";
            case ConstantVariables.SITE_PAGE_MENU_TITLE:
            case ConstantVariables.SITE_PAGE_TITLE_MENU:
                return "sitepage";
            case ConstantVariables.MLT_MENU_TITLE:
            case ConstantVariables.MLT_WISHLIST_MENU_TITLE:
                return "sitereview";
            case ConstantVariables.STORE_MENU_TITLE:
                return "sitestore";
            case ConstantVariables.PRODUCT_MENU_TITLE:
                return "sitestoreproduct";
            case ConstantVariables.PRODUCT_CART_MENU_TITLE:
                return "sitemenu";
            case ConstantVariables.STORE_OFFER_MENU_TITLE:
                return "sitestoreoffer";
            case ConstantVariables.SITE_PRODUCT_WISHLIST_MENU_TITLE:
                return "sitestorelikebox";
            case ConstantVariables.SITE_PRODUCT_ORDER_MENU_TITLE:
                return "sitestoreadmincontact";
            case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                return "sitegroup";
            case ConstantVariables.WISHLIST_MENU_TITLE:
                return "core";
            case ConstantVariables.ADV_VIDEO_MENU_TITLE:
            case ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE:
            case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                return "sitevideo";
            case ConstantVariables.CROWD_FUNDING_MAIN_TITLE:
                return "sitecrowdfunding";
            default: return null;
        }
    }

    public void setUp(int fragmentId, DrawerLayout drawerLayout, final Toolbar toolbar) {
        containerView = getActivity().findViewById(fragmentId);
        mDrawerLayout = drawerLayout;
        mDrawerToggle = new ActionBarDrawerToggle(getActivity(),
                drawerLayout,toolbar, R.string.drawer_open, R.string.drawer_close) {
            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                try {
                    if (!mAppConst.isLoggedOutUser() && PreferencesUtils.getAppTourEnabled(mContext) == 1
                            && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.USER_PROFILE_SHOW_CASE_VIEW)) {
                        displayShowCaseView();
                    }
                } catch (Resources.NotFoundException e) {
                    e.printStackTrace();
                }

                makeOptionMenuInvalidate();
                updateBadgeCount();

            }

            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
                makeOptionMenuInvalidate();
            }

            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {
                super.onDrawerSlide(drawerView, slideOffset);
                toolbar.setAlpha(1 - slideOffset / 2);
            }
        };

        mDrawerLayout.setDrawerListener(mDrawerToggle);
        mDrawerLayout.setFocusableInTouchMode(false);
        mDrawerLayout.post(new Runnable() {
            @Override
            public void run() {
                mDrawerToggle.syncState();
            }
        });

    }

    /* Display show case view on user profile icon in navigation drawer */
    private void displayShowCaseView() {
        if (recyclerView.getChildAt(0) != null)
            showTipWithPosition(new ViewPosition(recyclerView.getChildAt(0)));
    }

    private void showTipWithPosition(ShowCasePosition position) {
        showTip(position, new Radius(mContext.getResources().getDimension(R.dimen.radius_90)));
    }

    private void showTip(ShowCasePosition position, ShowCaseRadius radius) {
        PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.USER_PROFILE_SHOW_CASE_VIEW);
        new ShowCaseView.Builder(mContext)
                .withTypedPosition(position)
                .withTypedRadius(radius)
                .dismissOnTouch(false)
                .withContent(mContext.getString(R.string.profile_page_show_case_text))
                .build()
                .show((Activity) mContext);
    }

    /**
     * Method to update navigation drawer when dashboard response is updated.
     */
    public void drawerUpdate() {

        if (PreferencesUtils.getDashboardMenus(mContext) != null) {
            try {
                menuObject = new JSONArray(PreferencesUtils.getDashboardMenus(mContext));
                if (PreferencesUtils.getLanguages(mContext) != null &&
                        !PreferencesUtils.getLanguages(mContext).isEmpty()) {
                    mMultiLanguages = new JSONObject(PreferencesUtils.getLanguages(mContext));
                    if (mMultiLanguages != null && mMultiLanguages.length() != 0) {
                        mLanguageCount = mMultiLanguages.length();
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
            makeOptionMenuInvalidate();

        } else {
            mProgressBar.setVisibility(View.GONE);
//            recyclerView.setVisibility(View.GONE);

            // When there is not menus then showing the social and sign/signup buttons at center.
            RelativeLayout.LayoutParams socialSitesButtonLayoutParams = (RelativeLayout.LayoutParams)
                    socialSitesButton.getLayoutParams();
            RelativeLayout.LayoutParams bottomButtonLayoutParams = (RelativeLayout.LayoutParams)
                    bottomButton.getLayoutParams();

            // Clearing the already assigned xml rules.
            socialSitesButtonLayoutParams.addRule(RelativeLayout.ABOVE, 0);
            bottomButtonLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, 0);

            // Assigned new rules.
            socialSitesButtonLayoutParams.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
            bottomButtonLayoutParams.addRule(RelativeLayout.BELOW, socialSitesButton.getId());
        }

        makeOptionMenuInvalidate();
        updateBadgeCount();
    }

    /***
     * Method to invalidate option menu when the frament is attached to the activity.
     */
    private void makeOptionMenuInvalidate() {
        if (isAdded() && getActivity() != null) {
            getActivity().invalidateOptionsMenu();
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        switch (id){
            case R.id.signup_button:
                JSONObject quickSignUp = PreferencesUtils.getModuleSettings(mContext, "sitequicksignup");
                Intent signUpIntent;
                if (quickSignUp != null && quickSignUp.optBoolean("isQuickSignUp", false)) {
                    signUpIntent = new Intent(mContext, QuickSignUpActivity.class);
                } else {
                    signUpIntent = new Intent(mContext, SubscriptionActivity.class);
                }
                startActivity(signUpIntent);
                ((AppCompatActivity)mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;
            case R.id.signin_button:
                Intent mainIntent;
                if (ConstantVariables.INTRO_SLIDE_SHOW_ENABLED == 1) {
                    mainIntent = new Intent(mContext, NewLoginActivity.class);
                } else {
                    mainIntent = new Intent(mContext, LoginActivity.class);
                };
                startActivity(mainIntent);
                ((AppCompatActivity)mContext).overridePendingTransition(R.anim.slide_in_right,
                        R.anim.slide_out_left);
                break;
        }
    }

    @Override
    public void onResume() {
        // Register receiver if activity is in front
        getActivity().registerReceiver(broadcastReceiver, intentFilter);
        super.onResume();
    }

    @Override
    public void onPause() {
        // Unregister receiver if activity is not in front
        getActivity().unregisterReceiver(broadcastReceiver);
        super.onPause();
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mContext = context;

    }

    @Override
    public void onSuccess(String loginType) {

    }

    @Override
    public void onError(String loginType, String errorMessage) {
        SocialLoginUtil.clearFbTwitterInstances(mContext, loginType);
        switch (errorMessage) {
            case "email_not_verified":
                SnackbarUtils.displaySnackbar(mLayoutMain, mContext.getResources().getString(R.string.email_not_verified));
                break;
            case "not_approved":
                SnackbarUtils.displaySnackbar(mLayoutMain, mContext.getResources().getString(R.string.signup_admin_approval));
                break;
            default:
                SnackbarUtils.displaySnackbar(mLayoutMain, errorMessage);
                break;
        }
    }

    public interface FragmentDrawerListener {
        void onDrawerItemSelected(View view, String name, String label, String headerLabel, String singularLabel,
                                  String itemUrl, int listingId, int browseType,
                                  int viewType, String icon, int canCreate, int packagesEnabled,
                                  int siteStoreEnabled, int listingEnabled, boolean canView, int secondaryViewType, JSONObject searchForm);

    }


    public void scrolledToTop() {
        recyclerView.smoothScrollToPosition(0);
    }

}
