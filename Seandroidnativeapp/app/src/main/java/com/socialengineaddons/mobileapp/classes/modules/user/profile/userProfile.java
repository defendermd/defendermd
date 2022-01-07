package com.socialengineaddons.mobileapp.classes.modules.user.profile;
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

import android.Manifest;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.design.widget.AppBarLayout;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.TabLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.text.TextUtils;
import android.transition.Transition;
import android.transition.TransitionInflater;
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.PhotoUploadingActivity;
import com.socialengineaddons.mobileapp.classes.common.adapters.GridItemAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.SelectAlbumListAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.ViewPageFragmentAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnOptionItemClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.models.GridItemModel;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ObservableScrollView;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ObservableScrollViewCallbacks;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ScrollState;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ScrollUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.CustomTabUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GridSpacingItemDecorationUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.Status;
import com.socialengineaddons.mobileapp.classes.modules.peopleSuggestion.FindFriends;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoLightBoxActivity;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;
import com.socialengineaddons.mobileapp.classes.modules.user.settings.MemberSettingsActivity;
import com.socialengineaddons.mobileapp.classes.modules.user.settings.SettingsListActivity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import ru.dimorinny.showcasecard.position.TopRightToolbar;
import ru.dimorinny.showcasecard.position.ViewPosition;
import ru.dimorinny.showcasecard.step.ShowCaseStep;
import ru.dimorinny.showcasecard.step.ShowCaseStepDisplayer;


public class userProfile extends AppCompatActivity implements AppBarLayout.OnOffsetChangedListener,
        OnUploadResponseListener, OnOptionItemClickResponseListener, View.OnClickListener, ShowCaseStepDisplayer.DismissListener
        , ObservableScrollViewCallbacks, OnItemClickListener {

    static int mUserId, index = 0;
    private static Activity activity;
    private String userProfileUrl, displayName, mPreviousSelectedModule, mCoverImageUrl;
    private int mPreviousSelectedModuleListingTypeId;
    private int ONE_WAY = 1;
    private int TWO_WAY = 2;
    private AppConstant mAppConst;
    private GutterMenuUtils mGutterMenuUtils;
    private BrowseListItems mBrowseList;
    private Toolbar mToolBar;
    private ProgressBar mProgressBar, pbrLoadingPhotos, pbrLoadingFriends;
    private JSONObject mBody, mResponseObject;
    private JSONArray mGutterMenus, mOptionArray, mProfileTabs, mUserProfileTabs, coverPhotoMenuArray,
            profilePhotoMenuArray;
    private ImageView mCoverImage, mProfileImage;
    private TextView mProfileImageMenus, mCoverImageMenus, mContentTitle, tvUserStatus;
    private ViewPager mViewPager;
    private TabLayout mTabLayout;
    private Context mContext;
    private ViewPageFragmentAdapter mViewPageFragmentAdapter;
    private String successMessage;
    private CoordinatorLayout mMainContent;
    private ArrayList<PhotoListDetails> mPhotoDetails, mProfilePhotoDetail, alRecentPhotosDetail;
    private Boolean isOrganizerProfile = false, isCoverRequest = false, isShowFriends = false;
    private TextView tvAddFriend, tvMessage, tvMore, tvFollow, tvStatusPost;
    private AlertDialogWithAction mAlertDialogWithAction;
    private boolean sendMessage = false;
    private ImageLoader mImageLoader;
    private int mFriendshipType = ONE_WAY;
    private boolean isFriendsOption = false;
    private JSONObject menuObject;
    private ShowCaseStepDisplayer.Builder showCaseStepDisplayer;
    private boolean isShowCaseView, isUploadPhotosRequest, isAlbumsRequest;
    private int callingTime = 0, mParallaxImageHeight, infoTabPosition = -1, iStatusBarHeight;
    private ObservableScrollView mScrollView;
    private LinearLayout llProfileInfoWrapper;
    private View vOptionInfoDivider;
    private RecyclerView rvRecentPhotos, rvFriendList;
    private GridItemAdapter mGridItemAdapterPhotos, mGridItemAdapterFriends;
    private List<GridItemModel> mPhotosList, mFriendsList;
    private TextView tvAddFriends, tvAddPhoto, tvPhotosIcon, tvFriendsIcon;
    private SelectAlbumListAdapter listAdapter;
    private View cvRecentPhotos, cvFriends;
    private HashMap<View, String> hmShowcases = new HashMap<>();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_profile);
        mAppConst = new AppConstant(this);
        mContext = this;

        setupWindowAnimations();

        /* Initialize show case view step builder */
        showCaseStepDisplayer = new ShowCaseStepDisplayer.Builder(this, R.color.colorAccent);
        mParallaxImageHeight = getResources().getDimensionPixelSize(R.dimen.dimen_750dp);
        // Todo enable it for testing
        if (!PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.USER_PROFILE_EDIT_PHOTO_SHOW_CASE_VIEW)) {
            PreferencesUtils.setProfileShowCaseViewPref(mContext, false, false,
                    false, false, false, false, false);
        }

        iStatusBarHeight = (int) Math.ceil(25 * mContext.getResources().getDisplayMetrics().density);
        int resourceId = getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            iStatusBarHeight = getResources().getDimensionPixelSize(resourceId);
        }

        mGutterMenuUtils = new GutterMenuUtils(this, true);
        mGutterMenuUtils.setOnOptionItemClickResponseListener(this);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        mImageLoader = new ImageLoader(getApplicationContext());
        mProfileTabs = mUserProfileTabs = new JSONArray();
        if (getIntent().getExtras() != null) {
            mUserId = getIntent().getExtras().getInt(ConstantVariables.USER_ID);
            isShowFriends = getIntent().getBooleanExtra("isShowFriends", false);
            String profileType = getIntent().getExtras().getString(ConstantVariables.PROFILE_TYPE);
            if (profileType != null && !profileType.isEmpty() && profileType.equals("organizer_profile")) {
                isOrganizerProfile = true;
            }
        }
        PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.USER_MENU_TITLE);
        mPreviousSelectedModule = PreferencesUtils.getCurrentSelectedModule(mContext);
        if (mPreviousSelectedModule != null && mPreviousSelectedModule.equals("sitereview_listing")) {
            mPreviousSelectedModuleListingTypeId = PreferencesUtils.getCurrentSelectedListingId(mContext);
        }

        mToolBar = findViewById(R.id.toolbar);
        mToolBar.setBackgroundColor(ScrollUtils.getColorWithAlpha(0, ContextCompat.getColor(this, R.color.colorPrimary)));
        setSupportActionBar(mToolBar);

        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(getResources().getString(R.string.blank_string));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        mPhotoDetails = new ArrayList<>();
        mProfilePhotoDetail = new ArrayList<>();
        alRecentPhotosDetail = new ArrayList<>();

        mProgressBar = findViewById(R.id.progressBar);
        mContentTitle = findViewById(R.id.content_title);
        mCoverImage = findViewById(R.id.coverImage);
        mProfileImage = findViewById(R.id.profile_image);
        mCoverImageMenus = findViewById(R.id.cover_image_menus);
        mCoverImageMenus.setOnClickListener(this::onClick);
        mProfileImageMenus = findViewById(R.id.profile_image_menus);
        mProfileImageMenus.setOnClickListener(this::onClick);
        mCoverImageMenus.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        mProfileImageMenus.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));

        mViewPager = findViewById(R.id.pager);
        mTabLayout = findViewById(R.id.slidingTabs);
        mMainContent = findViewById(R.id.main_content);
        tvAddFriend = findViewById(R.id.add_friend);
        tvMessage = findViewById(R.id.message);
        tvMore = findViewById(R.id.more);
        tvFollow = findViewById(R.id.follow);
        tvStatusPost = findViewById(R.id.tvStatusPost);

        mScrollView = findViewById(R.id.scroll);
        mScrollView.setScrollViewCallbacks(this);

        tvAddFriends = findViewById(R.id.tvAddFriend);
        tvAddFriends.setOnClickListener(this);
        tvAddPhoto = findViewById(R.id.tvAddPhoto);
        tvAddPhoto.setOnClickListener(this);
        tvPhotosIcon = findViewById(R.id.tvPhotosIcon);
        tvPhotosIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        tvPhotosIcon.setText("\uf03e");
        tvFriendsIcon = findViewById(R.id.tvFriendsIcon);
        tvFriendsIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        tvFriendsIcon.setText("\uf0c0");


        pbrLoadingPhotos = findViewById(R.id.pbrLoadingPhotos);
        pbrLoadingFriends = findViewById(R.id.pbrLoadingFriends);

        tvUserStatus = findViewById(R.id.tvUserStatus);
        llProfileInfoWrapper = findViewById(R.id.llProfileInfoWrapper);
        vOptionInfoDivider = findViewById(R.id.vOptionInfoDivider);
        rvRecentPhotos = findViewById(R.id.rvRecentPhotos);
        GridLayoutManager mLayoutManager = new GridLayoutManager(this, 3);
        rvRecentPhotos.addItemDecoration(new GridSpacingItemDecorationUtil(
                mContext.getResources().getDimensionPixelOffset(R.dimen.dimen_3dp), 0,
                0, mContext.getResources().getDimensionPixelOffset(R.dimen.dimen_5dp), 3
        ));

        rvRecentPhotos.setLayoutManager(mLayoutManager);
        rvRecentPhotos.setNestedScrollingEnabled(false);
        mPhotosList = new ArrayList<>();
        mGridItemAdapterPhotos = new GridItemAdapter(mPhotosList, mContext);
        mGridItemAdapterPhotos.setAdapterTagName("RecentPhotos");
        setPlaceholder(mPhotosList, 6);
        rvRecentPhotos.setAdapter(mGridItemAdapterPhotos);

        rvFriendList = findViewById(R.id.rvFriends);
        GridLayoutManager mLayoutManagerFriends = new GridLayoutManager(this, 3);
        rvFriendList.setLayoutManager(mLayoutManagerFriends);
        rvFriendList.addItemDecoration(new GridSpacingItemDecorationUtil(
                mContext.getResources().getDimensionPixelOffset(R.dimen.dimen_3dp), 0,
                0, mContext.getResources().getDimensionPixelOffset(R.dimen.dimen_10dp), 3
        ));
        rvFriendList.setNestedScrollingEnabled(false);
        mFriendsList = new ArrayList<>();
        mGridItemAdapterFriends = new GridItemAdapter(mFriendsList, mContext);
        mGridItemAdapterFriends.setAdapterTagName("Friends");
        setPlaceholder(mFriendsList, 6);
        rvFriendList.setAdapter(mGridItemAdapterFriends);

        tvAddFriend.setOnClickListener(this);
        tvMessage.setOnClickListener(this);
        tvMore.setOnClickListener(this);
        tvFollow.setOnClickListener(this);

        cvRecentPhotos = findViewById(R.id.cvRecentPhotos);
        cvFriends = findViewById(R.id.cvFriends);

        if (isOrganizerProfile) {
            userProfileUrl = AppConstant.DEFAULT_URL + "advancedevents/organizer/" + mUserId;
        } else {
            userProfileUrl = AppConstant.DEFAULT_URL + "user/profile/" + mUserId;
        }

        // IF profile photo is uploaded via album view page.
        if (getIntent().getBooleanExtra(ConstantVariables.IS_PHOTO_UPLOADED, false)) {
            mAppConst.refreshUserData();
        }
        try {
            String profileImage = getIntent().getStringExtra(ConstantVariables.PROFILE_IMAGE_URL);
            if (getIntent().hasExtra(ConstantVariables.PROFILE_QUICK_INFO) && getIntent().getStringExtra(ConstantVariables.PROFILE_QUICK_INFO) != null) {
                JSONObject userDetails = new JSONObject(getIntent().getStringExtra(ConstantVariables.PROFILE_QUICK_INFO));
                mBody = userDetails;
                profileImage = mBody.optString("image");
            }
            if (profileImage != null && !profileImage.isEmpty()) {
                mImageLoader.setImageForUserProfile(profileImage, mProfileImage);
            }

            if (!mAppConst.isLoggedOutUser()) {
                JSONObject userDetails = new JSONObject(PreferencesUtils.getUserDetail(mContext));
                if (mUserId == userDetails.optInt("user_id", 0)) {
                    mBody = userDetails;
                    tvAddPhoto.setVisibility(View.VISIBLE);
                    tvAddFriends.setVisibility(View.VISIBLE);
                }
            }
            if (mBody != null) {
                setUserProfileDetails(mBody, true);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }


        new Handler().post(() -> {
            makeRequest();
            getRecentPhotos(true);
        });
        final ViewGroup.LayoutParams layoutParams = mViewPager.getLayoutParams();
        mToolBar.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                mToolBar.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                final int toolbarHeight = mToolBar.getHeight(); //height is ready
                mTabLayout.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
                    @Override
                    public void onGlobalLayout() {
                        mTabLayout.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                        int tabHeight = mTabLayout.getHeight();
                        int screenElementsHeight = toolbarHeight + tabHeight;
                        if (iStatusBarHeight < 100) {
                            screenElementsHeight += iStatusBarHeight;
                        }
                        layoutParams.height = (mAppConst.getScreenHeight() - screenElementsHeight);
                    }
                });
            }
        });
    }

    private void setupWindowAnimations() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Transition fade = TransitionInflater.from(this).inflateTransition(R.transition.activity_fade);
            getWindow().setEnterTransition(fade);
        }
    }

    private void setPlaceholder(List<GridItemModel> lPlaceholderList, int itemCount) {
        for (int i = 0; i < itemCount; ++i) {
            lPlaceholderList.add(new GridItemModel());
        }
    }

    public void makeRequest() {

        try {
            mAppConst.getJsonResponseFromUrl(userProfileUrl, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) {
                    mBody = jsonObject;
                    mProgressBar.setVisibility(View.GONE);

                    if (mBody != null) {
                        setUserProfileDetails(jsonObject, false);
                        // Adding verification gutter menu.
                        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "memberverify/allow-verify?user_id=" + mUserId,
                                new OnResponseListener() {
                                    @Override
                                    public void onTaskCompleted(JSONObject jsonObject) {
                                        mBrowseList.setIsAdminApprovalRequired(jsonObject.optInt("is_admin_approval_required") == 1);
                                        mBrowseList.setIsAdminApproved(jsonObject.optInt("admin_approve") == 1);

                                        JSONArray menuArray = jsonObject.optJSONArray("menu");
                                        if (menuArray != null && menuArray.length() > 0) {
                                            if (mOptionArray == null) {
                                                mOptionArray = menuArray;
                                            } else {
                                                for (int i = 0; i < menuArray.length(); i++) {
                                                    mOptionArray.put(menuArray.optJSONObject(i));
                                                }
                                            }

                                            if (mOptionArray.length() > 0) {
                                                tvMore.setVisibility(View.VISIBLE);
                                                setEditProfileOptions(tvMore, mContext.getResources().getString(R.string.more),
                                                        -1, R.drawable.ic_more);
                                            }
                                            isShowCaseView = true;
                                            invalidateOptionsMenu();
                                        }
                                    }

                                    @Override
                                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                                    }
                                });


                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    // Show Privacy Message to user if not authorized to view this
                    mProgressBar.setVisibility(View.GONE);
                    SnackbarUtils.displaySnackbarWithAction(mContext, mMainContent, message,
                            () -> makeRequest());
                }
            });
        } catch (IllegalStateException | NullPointerException e) {
            e.printStackTrace();
        }
    }

    private void setUserProfileDetails(JSONObject jsonObject, boolean isCache) {
        mGutterMenus = mBody.optJSONArray("gutterMenu");
        mUserProfileTabs = mBody.optJSONArray("profile_tabs");
        if (mUserProfileTabs == null) {
            mUserProfileTabs = mBody.optJSONArray("profileTabs");
        }
        mResponseObject = mBody.optJSONObject("response");
        if (mResponseObject == null) {
            mResponseObject = mBody;

        }
        if (mResponseObject.optJSONArray("profile_fields") != null) {
            setUserInfo(mResponseObject.optJSONArray("profile_fields"));
        }
        if (mResponseObject != null) {
            String userImageProfile = null;
            if (isOrganizerProfile) {
                displayName = jsonObject.optString("title");
                userImageProfile = jsonObject.optString("owner_image");
                if (userImageProfile == null || userImageProfile.isEmpty())
                    userImageProfile = jsonObject.optString("image");

                mImageLoader.setImageUrl(userImageProfile, mCoverImage);

            } else {
                displayName = mResponseObject.optString("displayname");
                userImageProfile = mResponseObject.optString("image");
                // When the user name or profile image is changed then Updating the user data.
                if (!mAppConst.isLoggedOutUser()
                        && PreferencesUtils.getUserDetail(mContext) != null) {
                    try {
                        JSONObject userDetail = new JSONObject(PreferencesUtils.getUserDetail(mContext));
                        String userName = userDetail.optString("displayname");
                        String coverImageUrl = userDetail.optString("image");
                        if (userDetail.optInt("user_id") == mUserId && (!displayName.equals(userName) ||
                                !userImageProfile.equals(coverImageUrl))) {
                            userDetail.put("displayname", displayName);
                            userDetail.put("image", userImageProfile);
                            userDetail.put("image_profile", mResponseObject.optString("image_profile"));
                            PreferencesUtils.updateUserPreferences(mContext, userDetail.toString(),
                                    PreferencesUtils.getUserPreferences(mContext).getString("oauth_secret", null),
                                    PreferencesUtils.getUserPreferences(mContext).getString("oauth_token", null));
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

            // Used for prime messenger.
            mBrowseList = new BrowseListItems("", mUserId, displayName);

            // Used for message.
            mBrowseList.setUserId(mUserId);
            mBrowseList.setUserDisplayName(displayName);
            mBrowseList.setUserProfileImageUrl(mResponseObject.optString("image_normal"));

            mPhotoDetails.clear();
            mCoverImageUrl = mResponseObject.optString("cover");

            //Showing content title
            mContentTitle.setText(displayName);
            mToolBar.setTitle(displayName);

            if (mResponseObject.optInt("showVerifyIcon") == 1) {
                mContentTitle.setMaxLines(1);
                mContentTitle.setSingleLine(true);
                mContentTitle.setEllipsize(TextUtils.TruncateAt.END);//
                Drawable verifyDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_security);
                verifyDrawable.setColorFilter(ContextCompat.getColor(mContext, R.color.colorPrimary), PorterDuff.Mode.SRC_ATOP);
                verifyDrawable.setBounds(0, 0, mContext.getResources().getDimensionPixelSize(R.dimen.margin_15dp),
                        mContext.getResources().getDimensionPixelSize(R.dimen.margin_15dp));
                mContentTitle.setCompoundDrawables(null, null, verifyDrawable, null);
            }

            // If not null then showing user cover image plugin views.
            if (mCoverImageUrl != null && !mCoverImageUrl.isEmpty()) {
                coverPhotoMenuArray = mResponseObject.optJSONArray("coverPhotoMenu");
                profilePhotoMenuArray = mResponseObject.optJSONArray("mainPhotoMenu");
                if (coverPhotoMenuArray != null && coverPhotoMenuArray.length() > 0) {
                    mCoverImageMenus.setVisibility(View.VISIBLE);
                    mCoverImageMenus.setText("\uf030");
                }
                if (profilePhotoMenuArray != null && profilePhotoMenuArray.length() > 0) {
                    mProfileImageMenus.setVisibility(View.VISIBLE);
                    mProfileImageMenus.setText("\uf030");
                }

                //Showing profile image.
                mImageLoader.setImageForUserProfile(userImageProfile, mProfileImage);

                //Showing Cover image.
                mImageLoader.setImageUrl(mCoverImageUrl, mCoverImage);

                mProfilePhotoDetail.clear();
                mProfilePhotoDetail.add(new PhotoListDetails(userImageProfile));
                mPhotoDetails.add(new PhotoListDetails(mCoverImageUrl));

            } else {
                mImageLoader.setImageUrl(userImageProfile, mProfileImage);
                mPhotoDetails.add(new PhotoListDetails(userImageProfile));
            }

            mCoverImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    openLightBox(mPhotoDetails, 0);
                }
            });

            mProfileImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    openLightBox(mProfilePhotoDetail, 0);
                }
            });

            if (mUserProfileTabs != null && !isCache) {
                if (mProfileTabs != null && mProfileTabs.length() != 0) {
                    mProfileTabs = new JSONArray();
                }
                for (int i = 0; i < mUserProfileTabs.length(); i++) {
                    JSONObject singleJsonObject = mUserProfileTabs.optJSONObject(i);
                    String tabName = singleJsonObject.optString("name");
                    int totalItemCount = singleJsonObject.optInt("totalItemCount");

                    if (!((!(tabName.equals("update") || tabName.equals("info") ||
                            tabName.equals("organizer_info") || tabName.equals("organizer_events")) &&
                            (totalItemCount == 0)) || (tabName.equals("forum_topics")))) {
                        mProfileTabs.put(singleJsonObject);
                        if (tabName.equals("info")) {
                            infoTabPosition = mProfileTabs.length() - 1;
                            tvUserStatus.setOnClickListener(this::onClick);
                        }
                    }
                }

                Bundle bundle = new Bundle();
                bundle.putString(ConstantVariables.SUBJECT_TYPE, "user");
                bundle.putInt(ConstantVariables.SUBJECT_ID, mUserId);
                bundle.putString(ConstantVariables.MODULE_NAME, "userProfile");
                bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, "userProfile");
                bundle.putInt(ConstantVariables.USER_ID, mUserId);
                bundle.putString(ConstantVariables.RESPONSE_OBJECT, mResponseObject.toString());
                bundle.putBoolean(ConstantVariables.SET_NESTED_SCROLLING_ENABLED, false);
                // Setup the viewPager
                mViewPageFragmentAdapter = new ViewPageFragmentAdapter(mContext,
                        getSupportFragmentManager(), mProfileTabs, bundle);
                mViewPager.setAdapter(mViewPageFragmentAdapter);
                mViewPager.setOffscreenPageLimit(mViewPageFragmentAdapter.getCount() + 1);
                // This method ensures that tab selection events update the ViewPager and page changes update the selected tab.
                mTabLayout.setupWithViewPager(mViewPager);
                mViewPager.setVisibility(View.VISIBLE);
                if (Boolean.TRUE.equals(isShowFriends)) {
                    mViewPageFragmentAdapter.loadFriendTab();
                    isShowFriends = false;
                }

                mTabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
                    @Override
                    public void onTabSelected(TabLayout.Tab tab) {
                        try {
                            JSONObject jsonObject = mProfileTabs.getJSONObject(tab.getPosition());
                            PreferencesUtils.setCurrentSelectedListingId(mContext, jsonObject.optInt(ConstantVariables.LISTING_TYPE_ID));

                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                    @Override
                    public void onTabUnselected(TabLayout.Tab tab) {

                    }

                    @Override
                    public void onTabReselected(TabLayout.Tab tab) {

                    }
                });
            }
        }
        // Method to check profile options.
        if (!isCache) {
            mScrollView.smoothScrollTo(0, 0);
            checkForOptions();
        }
    }

    private void checkForOptions() {
        if (!mAppConst.isLoggedOutUser()) {
            tvStatusPost.setOnClickListener(this::onClick);
        } else {
            disableOptions(tvStatusPost);
        }

        findViewById(R.id.profile_options).setVisibility(View.VISIBLE);
        if (mGutterMenus != null && mGutterMenus.length() > 0) {
            Drawable dPostIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_icons_post).mutate();
            dPostIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.body_text_1), PorterDuff.Mode.SRC_ATOP);
            dPostIcon.setBounds(0, 0, mContext.getResources().getDimensionPixelSize(R.dimen.margin_15dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_15dp));
            tvStatusPost.setCompoundDrawablesWithIntrinsicBounds(null, dPostIcon, null, null);
            tvStatusPost.setText(mContext.getResources().getString(R.string.post_status_button_text));

            mOptionArray = new JSONArray();
            JSONObject profileObject = null;
            disableOptions(tvMessage);
            for (int i = 0; i < mGutterMenus.length(); i++) {
                JSONObject jsonObject = mGutterMenus.optJSONObject(i);
                String menuName = jsonObject.optString("name");

                switch (menuName) {
                    case "add_friend":
                    case "member_follow":
                    case "accept_request":
                        setAddFriendOption(i, jsonObject, R.drawable.ic_icons_add_user, R.color.body_text_1);
                        break;

                    case "remove_friend":
                    case "member_unfollow":
                        setAddFriendOption(i, jsonObject, R.drawable.ic_user_remove, R.color.body_text_1);
                        break;

                    case "cancel_request":
                    case "cancel_follow":
                        setAddFriendOption(i, jsonObject, R.drawable.ic_user_cancel, R.color.body_text_1);
                        break;

                    case "follow":
                        setFollowMemberOption(i, jsonObject, R.drawable.ic_icons_follow_user, R.color.body_text_1);
                        break;

                    case "following":
                        setFollowMemberOption(i, jsonObject, R.drawable.ic_icons_follow_user, R.color.body_text_1);
                        break;

                    case "user_profile_send_message":
                        tvMessage.setEnabled(true);
                        tvMessage.setClickable(true);
                        tvMessage.setAlpha(1);
                        sendMessage = true;

                        if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                            setEditProfileOptions(tvMessage,
                                    mContext.getResources().getString(R.string.contact_us_message),
                                    i, R.drawable.ic_prime_messenger);
                        } else {
                            setEditProfileOptions(tvMessage,
                                    mContext.getResources().getString(R.string.contact_us_message),
                                    i, R.drawable.ic_message);
                        }

                        if (!PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.USER_PROFILE_MESSAGE_SHOW_CASE_VIEW)) {
                            isShowCaseView = true;
                            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.USER_PROFILE_MESSAGE_SHOW_CASE_VIEW);
                            showCaseStepDisplayer.addStep(new ShowCaseStep(new ViewPosition(tvMessage),
                                    mContext.getResources().getString(R.string.user_profile_send_message_show_case_text),
                                    mContext.getResources().getDimension(R.dimen.radius_20)));
                        }

                        if (mViewPageFragmentAdapter != null) {
                            mViewPageFragmentAdapter.checkForMessageOption(mBrowseList);
                        }
                        break;

                    case "user_home_edit":
                        try {
                            profileObject = new JSONObject(jsonObject.toString());
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        setEditProfileOptions(tvAddFriend, mContext.getResources().getString(R.string.edit_profile),
                                i, R.drawable.ic_icons_edit_profile);
                        isFriendsOption = true;
                        break;

                    default:
                        mOptionArray.put(jsonObject);
                        break;
                }
            }

            if (mOptionArray.length() > 0) {
                tvMore.setVisibility(View.VISIBLE);
                setEditProfileOptions(tvMore, mContext.getResources().getString(R.string.more),
                        -1, R.drawable.ic_more);
            } else {
                tvMore.setVisibility(View.GONE);
            }

            if (profileObject != null && profileObject.length() > 0) {
                try {
                    tvMessage.setEnabled(true);
                    tvMessage.setClickable(true);
                    tvMessage.setAlpha(1);
                    setEditProfileOptions(tvMessage, mContext.getResources().getString(R.string.notification_settings_text),
                            mGutterMenus.length(), R.drawable.ic_notification_outline);
                    profileObject.put("is_photo_tab", true);
                    tvMessage.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            Intent settingsIntent = new Intent(mContext, MemberSettingsActivity.class);
                            settingsIntent.putExtra("selected_option", "settings_notifications");
                            settingsIntent.putExtra("title", getResources().getString(R.string.notification_settings));
                            settingsIntent.putExtra("url", AppConstant.DEFAULT_URL + "members/settings/notifications");
                            startActivity(settingsIntent);
                            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                        }
                    });

                    // Add edit profile photo showcase view
                    if (!PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.USER_PROFILE_EDIT_PHOTO_SHOW_CASE_VIEW)) {
                        isShowCaseView = true;
                        PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.USER_PROFILE_EDIT_PHOTO_SHOW_CASE_VIEW);
                        hmShowcases.put(mProfileImageMenus, mContext.getResources().getString(R.string.user_profile_edit_photo_show_case_text));
                    }

                    mGutterMenus.put(mGutterMenus.length(), profileObject);

                    setEditProfileOptions(tvFollow, mContext.getResources().getString(R.string.action_settings),
                            mGutterMenus.length() + 1, R.drawable.ic_icons_lock);
                    tvFollow.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            Intent settingsActivity = new Intent(userProfile.this, SettingsListActivity.class);
                            startActivity(settingsActivity);
                            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                        }
                    });
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                    setEditProfileOptions(tvMessage,
                            mContext.getResources().getString(R.string.contact_us_message),
                            -1, R.drawable.ic_prime_messenger);
                } else {
                    setEditProfileOptions(tvMessage,
                            mContext.getResources().getString(R.string.contact_us_message),
                            -1, R.drawable.ic_message);
                }
            }

        } else {

            setEditProfileOptions(tvAddFriend,
                    mContext.getResources().getString(R.string.add_friend_title),
                    -1, R.drawable.ic_icons_add_user);

            if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                setEditProfileOptions(tvMessage,
                        mContext.getResources().getString(R.string.contact_us_message),
                        -1, R.drawable.ic_prime_messenger);
            } else {
                setEditProfileOptions(tvMessage,
                        mContext.getResources().getString(R.string.contact_us_message),
                        -1, R.drawable.ic_message);
            }

            setEditProfileOptions(tvMore,
                    mContext.getResources().getString(R.string.more),
                    -1, R.drawable.ic_more);

            setEditProfileOptions(tvFollow,
                    mContext.getResources().getString(R.string.follow),
                    -1, R.drawable.ic_icons_follow_user);

            disableOptions(tvAddFriend);
            disableOptions(tvMessage);
            disableOptions(tvMore);
            disableOptions(tvFollow);
        }
        invalidateOptionsMenu();

        Set<View> keySet = hmShowcases.keySet();
        for (View key : keySet) {
            String value = hmShowcases.get(key);
            showCaseStepDisplayer.addStep(new ShowCaseStep(key,
                    value,
                    mContext.getResources().getDimension(R.dimen.radius_20)));

        }
//         TODO, Enable Showcase
//        if (isShowCaseView && PreferencesUtils.getAppTourEnabled(mContext) == 1) {
//            showCaseStepDisplayer.build().start();
//            isShowCaseView = false;
//        }

    }

    private void disableOptions(TextView tvOption) {
        tvOption.setClickable(false);
        tvOption.setEnabled(false);
        tvOption.setAlpha(0.2f);
    }

    private void setAddFriendOption(int position, JSONObject jsonObject, int drawableResId, int colorResId) {
        tvAddFriend.setVisibility(View.VISIBLE);
        tvAddFriend.setText(jsonObject.optString("label"));
        tvAddFriend.setTag(position);
        Drawable drawable = ContextCompat.getDrawable(mContext, drawableResId);
        tvAddFriend.setTextColor(ContextCompat.getColor(mContext, colorResId));
        drawable.setColorFilter(ContextCompat.getColor(mContext, colorResId), PorterDuff.Mode.SRC_ATOP);
        tvAddFriend.setCompoundDrawablesWithIntrinsicBounds(null, drawable, null, null);
    }

    private void setFollowMemberOption(int position, JSONObject jsonObject, int drawableResId, int colorResId) {
        mFriendshipType = TWO_WAY;
        tvFollow.setVisibility(View.VISIBLE);
        tvFollow.setText(jsonObject.optString("label"));
        tvFollow.setTag(position);
        Drawable drawable = ContextCompat.getDrawable(mContext, drawableResId);
        tvFollow.setTextColor(ContextCompat.getColor(mContext, colorResId));
        drawable.setColorFilter(ContextCompat.getColor(mContext, colorResId), PorterDuff.Mode.SRC_ATOP);
        tvFollow.setCompoundDrawablesWithIntrinsicBounds(null, drawable, null, null);
    }

    private void setEditProfileOptions(TextView tvOption, String label, int tag, int resId) {
        tvOption.setText(label);
        tvOption.setVisibility(View.VISIBLE);
        Drawable drawable = ContextCompat.getDrawable(mContext, resId);
        drawable.setColorFilter(ContextCompat.getColor(mContext, R.color.body_text_1),
                PorterDuff.Mode.SRC_ATOP);
        tvOption.setCompoundDrawablesWithIntrinsicBounds(null, drawable, null, null);
        if (tag >= 0) {
            tvOption.setTag(tag);
        }
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        if (mFriendshipType == TWO_WAY && mGutterMenus != null) {
            menu.clear();
            mGutterMenuUtils.showOptionMenus(menu, mOptionArray, ConstantVariables.USER_MENU_TITLE, mBrowseList);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.default_menu_item, menu);
        addShowcases(menu);
        return true;
    }

    private void addShowcases(Menu menu) {
        ShowCaseStep showCaseStep = null;
        if (mFriendshipType == ONE_WAY) {
            menu.findItem(R.id.action_settings).setVisible(false);
            if (mOptionArray != null && mOptionArray.length() > 0) {
                tvMore.setVisibility(View.VISIBLE);
                // Add more option showcase view
                showCaseStep = new ShowCaseStep(new ViewPosition(tvMore),
                        mContext.getResources().getString(R.string.user_profile_more_icon_show_case_text),
                        mContext.getResources().getDimension(R.dimen.radius_25));
            }
            if (isFriendsOption) {
                tvFollow.setVisibility(View.VISIBLE);
            } else {
                tvFollow.setVisibility(View.GONE);
            }
        } else {
            menu.findItem(R.id.action_settings).setVisible(true);
            tvMore.setVisibility(View.GONE);
            tvFollow.setVisibility(View.VISIBLE);

            showCaseStep = new ShowCaseStep(new TopRightToolbar(),
                    mContext.getResources().getString(R.string.user_profile_more_icon_show_case_text),
                    mContext.getResources().getDimension(R.dimen.radius_20));
        }

        // Add more option showcase view
        if (showCaseStep != null && !PreferencesUtils.getShowCaseView(mContext, PreferencesUtils.USER_PROFILE_MORE_SHOW_CASE_VIEW)) {
            isShowCaseView = true;
            PreferencesUtils.updateShowCaseView(mContext, PreferencesUtils.USER_PROFILE_MORE_SHOW_CASE_VIEW);
            showCaseStepDisplayer.addStep(showCaseStep);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if (id == android.R.id.home) {
            onBackPressed();
            // Playing backSound effect when user tapped on back button from tool bar.
            if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
                SoundUtil.playSoundEffectOnBackPressed(mContext);
            }
        } else {
            if (mOptionArray != null) {
                mGutterMenuUtils.onMenuOptionItemSelected(mMainContent, findViewById(item.getItemId()), id, mOptionArray);
            }
        }
        return super.onOptionsItemSelected(item);
    }

    /**
     * Method to open photoLightBox when user click on view image
     *
     * @param photoDetails
     */
    public void openLightBox(ArrayList<PhotoListDetails> photoDetails, int position) {
        if (photoDetails != null && photoDetails.size() > 0) {
            Bundle bundle = new Bundle();
            bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, photoDetails);
            Intent i = new Intent(mContext, PhotoLightBoxActivity.class);
            i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, photoDetails.size());
            i.putExtra(ConstantVariables.ITEM_POSITION, position);
            i.putExtra(ConstantVariables.SHOW_OPTIONS, false);
            i.putExtras(bundle);
            startActivityForResult(i, ConstantVariables.VIEW_LIGHT_BOX);
        }
    }

    private void startImageUploading() {
        Intent intent = new Intent(mContext, PhotoUploadingActivity.class);
        intent.putExtra("selection_mode", true);
        intent.putExtra(ConstantVariables.IS_PHOTO_UPLOADED, true);
        startActivityForResult(intent, ConstantVariables.PAGE_EDIT_CODE);
    }

    @Override
    public void onClick(View view) {
          switch (view.getId()) {
            case R.id.follow:
                int position = (int) view.getTag();
                if (position == mGutterMenus.length() + 1 && mViewPageFragmentAdapter != null) {
                    mViewPageFragmentAdapter.loadFriendTab();
                } else {
                    mGutterMenuUtils.onMenuItemSelected(view, position, mGutterMenus,
                            ConstantVariables.USER_MENU_TITLE, mBrowseList);
                }
                break;

            case R.id.more:
                if (view.getTag() != null) {
                    if (mViewPageFragmentAdapter != null) {
                        mViewPageFragmentAdapter.loadFriendTab();
                    }
                } else if (mOptionArray != null) {
                    mGutterMenuUtils.showPopup(view, mOptionArray, mBrowseList, ConstantVariables.USER_MENU_TITLE);
                }
                break;
            case R.id.tvAddFriend:
                Intent intent = new Intent(mContext, FindFriends.class);
                startActivity(intent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;
            case R.id.tvAddPhoto:
                if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    isAlbumsRequest = true;
                    mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            ConstantVariables.WRITE_EXTERNAL_STORAGE);
                } else {
                    showListOfAlbums();
                }

                break;
            case R.id.tvStatusPost:
                Bundle feedPostMenus = new Bundle();
                feedPostMenus.putBoolean("showPhotoBlock", false);
                feedPostMenus.putBoolean("openCheckIn", false);
                feedPostMenus.putBoolean("openVideo", false);
                feedPostMenus.putBoolean("isExternalPost", true);
                try {
                    JSONObject mFeedPostMenus = new JSONObject(PreferencesUtils.getStatusPostPrivacyOptions(mContext));
                    feedPostMenus.putString("feedPostMenus", mFeedPostMenus.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                Intent statusIntent = new Intent(mContext, Status.class);
                statusIntent.putExtra(ConstantVariables.SUBJECT_TYPE, ConstantVariables.USER_TITLE);
                statusIntent.putExtra(ConstantVariables.SUBJECT_ID, mUserId);
                statusIntent.putExtras(feedPostMenus);
                startActivityForResult(statusIntent, ConstantVariables.FEED_REQUEST_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;
            case R.id.cover_image_menus:
                if (mCoverImageUrl != null && !mCoverImageUrl.isEmpty() &&
                        coverPhotoMenuArray != null && coverPhotoMenuArray.length() > 0) {
                    isCoverRequest = true;
                    mGutterMenuUtils.showPopup(mCoverImageMenus, coverPhotoMenuArray,
                            mBrowseList, ConstantVariables.USER_MENU_TITLE);
                }
                break;
            case R.id.profile_image_menus:
                if (profilePhotoMenuArray != null && profilePhotoMenuArray.length() > 0) {
                    isCoverRequest = false;
                    mGutterMenuUtils.showPopup(mProfileImageMenus, profilePhotoMenuArray,
                            mBrowseList, ConstantVariables.USER_MENU_TITLE);

                }
                break;
            case R.id.tvUserStatus:
                if (infoTabPosition > -1) {
                    mViewPager.setCurrentItem(infoTabPosition);
                    scrollToTabs();
                }
                break;
            default:
                if (view.getTag() != null) {
                    int pos = (int) view.getTag();
                    mGutterMenuUtils.onMenuItemSelected(view, pos, mGutterMenus,
                            ConstantVariables.USER_MENU_TITLE, mBrowseList);
                }
                break;

        }
    }

    private void scrollToTabs() {
        int movY = mTabLayout.getHeight() + (int) mTabLayout.getY() + iStatusBarHeight;
        mScrollView.smoothScrollTo(0, movY);
    }

    @Override
    public void onOffsetChanged(AppBarLayout appBarLayout, int i) {
        index = i;
    }

    @Override
    public void onUploadResponse(JSONObject jsonObject, boolean isRequestSuccessful) {
        if (isUploadPhotosRequest) {
            getRecentPhotos(false);
        } else if (isRequestSuccessful) {
            SnackbarUtils.displaySnackbarLongTime(mMainContent, successMessage);
            mProgressBar.setVisibility(View.VISIBLE);
            mProgressBar.bringToFront();
            mAppConst.refreshUserData();
            makeRequest();
        } else {
            SnackbarUtils.displaySnackbarLongTime(mMainContent, jsonObject.optString("message"));
        }

    }

    @Override
    public void onItemDelete(String successMessage) {

    }

    @Override
    public void onOptionItemActionSuccess(Object itemList, String menuName) {
        mBrowseList = (BrowseListItems) itemList;

        switch (menuName) {
            case "view_profile_photo":
            case "view_cover_photo":
                openLightBox(isCoverRequest ? mPhotoDetails : mProfilePhotoDetail, 0);
                break;

            case "upload_cover_photo":
            case "upload_photo":
                if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    isAlbumsRequest = false;
                    mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            ConstantVariables.WRITE_EXTERNAL_STORAGE);
                } else {
                    startImageUploading();
                }
                break;

            case "choose_from_album":
                Bundle bundle = new Bundle();
                bundle.putString(ConstantVariables.FRAGMENT_NAME, "album");
                bundle.putString(ConstantVariables.CONTENT_TITLE, mBrowseList.getmBrowseListTitle());
                bundle.putBoolean(ConstantVariables.IS_WAITING, false);
                bundle.putInt("user_id", mUserId);
                bundle.putBoolean("isMemberAlbums", true);
                bundle.putBoolean("isCoverRequest", isCoverRequest);
                if (isOrganizerProfile) {
                    bundle.putString(ConstantVariables.PROFILE_TYPE, "organizer_profile");
                }

                Intent newIntent = new Intent(mContext, FragmentLoadActivity.class);
                newIntent.putExtras(bundle);
                startActivityForResult(newIntent, ConstantVariables.PAGE_EDIT_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            default:
                finish();
                startActivity(getIntent());
                break;
        }
    }

    @Override
    public void onStart() {
        super.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();

        if (mPreviousSelectedModule != null) {
            PreferencesUtils.updateCurrentModule(mContext, mPreviousSelectedModule);
            if (mPreviousSelectedModule.equals("sitereview_listing") && mPreviousSelectedModuleListingTypeId != 0) {
                PreferencesUtils.setCurrentSelectedListingId(mContext, mPreviousSelectedModuleListingTypeId);
            } else if (mPreviousSelectedModule.equals(ConstantVariables.USER_MENU_TITLE)) {
                setResult(RESULT_OK);
                finish();
            }
        }
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {

            case ConstantVariables.VIEW_PAGE_CODE:
                makeRequest();
                break;

            case ConstantVariables.PAGE_EDIT_CODE:
                if (resultCode == ConstantVariables.PAGE_EDIT_CODE && data != null) {
                    ArrayList<String> resultList = data.getStringArrayListExtra(ConstantVariables.PHOTO_LIST);
                    String postUrl;
                    if (isCoverRequest) {
                        postUrl = AppConstant.DEFAULT_URL + "user/profilepage/upload-cover-photo/user_id/" +
                                mUserId + "/special/cover";
                        successMessage = mContext.getResources().getString(R.string.cover_photo_updated);
                    } else {
                        postUrl = AppConstant.DEFAULT_URL + "user/profilepage/upload-cover-photo/user_id/" +
                                mUserId + "/special/profile";
                        successMessage = mContext.getResources().getString(R.string.profile_photo_updated);
                    }
                    new UploadFileToServerUtils(userProfile.this, postUrl, resultList, this).execute();
                }
                break;

            case ConstantVariables.USER_PROFILE_CODE:
                if (resultCode == ConstantVariables.USER_PROFILE_CODE) {
                    mProgressBar.setVisibility(View.VISIBLE);
                    mProgressBar.bringToFront();
                    mAppConst.refreshUserData();
                    makeRequest();
                }
                break;

            case ConstantVariables.FEED_REQUEST_CODE:
                /* Reset the view pager adapter if any status is posted using AAF */
                if (resultCode == ConstantVariables.FEED_REQUEST_CODE && mViewPager != null) {
                    mViewPager.setAdapter(mViewPageFragmentAdapter);
                    scrollToTabs();
                }
                break;
            case ConstantVariables.REQUEST_IMAGE:

                if (data != null) {
                    ArrayList<String> mSelectPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);
                    if (mSelectPath != null) {
                        String mUploadPhotoUrl = data.getStringExtra(MultiMediaSelectorActivity.EXTRA_URL);
                        // uploading the photos to server
                        new UploadFileToServerUtils(mContext, findViewById(android.R.id.content),
                                mUploadPhotoUrl, mSelectPath, this).execute();
                    }
                }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {

        switch (requestCode) {
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, proceed to the normal flow.
                    if (isAlbumsRequest) {
                        isAlbumsRequest = false;
                        showListOfAlbums();
                    } else {
                        startImageUploading();
                    }
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

                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, mMainContent,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    }
                }
                break;

        }
    }

    @Override
    public void onDismiss() {

    }

    @Override
    public void onScrollChanged(int scrollY, boolean firstScroll, boolean dragging) {


        if (mViewPageFragmentAdapter == null) {
            return;
        }
        int baseColor = ContextCompat.getColor(this, R.color.colorPrimary);
        float alpha = Math.min(1, (float) scrollY / mParallaxImageHeight);

        int[] location = new int[2];
        mTabLayout.getLocationOnScreen(location);
        int position = mToolBar.getHeight() + (int) mTabLayout.getHeight() + iStatusBarHeight;

        BaseFragment baseFragment = mViewPageFragmentAdapter.getFragment(mViewPager.getCurrentItem());

        if (baseFragment != null) {
            if (position >= location[1]) {
                baseFragment.setNestedScrollingEnabled(true);
                alpha = 1.0f;
            } else {
                baseFragment.setNestedScrollingEnabled(false);
            }
        }
        mToolBar.setBackgroundColor(ScrollUtils.getColorWithAlpha(alpha, baseColor));
    }

    @Override
    public void onDownMotionEvent() {

    }

    @Override
    public void onUpOrCancelMotionEvent(ScrollState scrollState) {

    }

    /**
     * @param jsonArray
     * @setUserInfo is used to render status & profile fields.
     */
    private void setUserInfo(JSONArray jsonArray) {
        if (jsonArray == null || jsonArray.length() < 1) {
            return;
        }
        llProfileInfoWrapper.setVisibility(View.VISIBLE);
        llProfileInfoWrapper.removeAllViews();
        boolean hasFields = false;
        int fieldsCount = 0;
        String ignoreTypes = "first_name last_name";
        for (int i = 0; i < jsonArray.length(); i++) {

            JSONObject info = jsonArray.optJSONObject(i);
            String type = info.optString("type");
            String value = info.optString("value");
            String link = info.optString("link");
            if (ignoreTypes.contains(type)) continue;

            if (type.equals("about_me")) {
                tvUserStatus.setText(Html.fromHtml(value));
                tvUserStatus.setVisibility(View.VISIBLE);
            } else {
                TextView tvInfo = new TextView(mContext);
                tvInfo.setText(Html.fromHtml(value));
                tvInfo.setTextColor(mContext.getResources().getColor(R.color.body_text_1));
                tvInfo.setLayoutParams(CustomViews.getWrapLayoutParams());
                tvInfo.setGravity(Gravity.VERTICAL_GRAVITY_MASK);
                tvInfo.setTextAlignment(View.TEXT_ALIGNMENT_GRAVITY);
                tvInfo.setPadding(0, mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp),
                        mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp),
                        mContext.getResources().getDimensionPixelSize(R.dimen.dimen_2dp));
                if (link != null && link.contains("http://") || link.contains("https://")) {
                    tvInfo.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            CustomTabUtil.launchCustomTab((Activity) mContext, link);
                        }
                    });
                }

                Drawable drawable = GlobalFunctions.getDrawableByName(mContext, type);
                drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.body_text_1),
                        PorterDuff.Mode.SRC_ATOP));
                tvInfo.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
                tvInfo.setCompoundDrawablePadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp));
                llProfileInfoWrapper.addView(tvInfo);
                hasFields = true;
                fieldsCount++;
            }
            if (fieldsCount >= 5) {
                break;
            }
        }

        if (hasFields) {
            vOptionInfoDivider.setVisibility(View.VISIBLE);
        }
    }

    private void getRecentPhotos(boolean isLoadFriends) {
        String url = AppConstant.DEFAULT_URL + "albums/photo/list?item_type=user&user_id=" + mUserId + "&order=DESC&limit=6";
        pbrLoadingPhotos.setVisibility(View.GONE);
        rvRecentPhotos.setVisibility(View.VISIBLE);
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                if (isLoadFriends) {
                    getFriends();
                }
                new Handler().post(new Runnable() {
                    @Override
                    public void run() {
                        pbrLoadingPhotos.setVisibility(View.GONE);
                        rvRecentPhotos.setVisibility(View.VISIBLE);
                        JSONArray mDataResponseArray = jsonObject.optJSONArray("photos");
                        int itemCount = jsonObject.optInt("totalPhotoCount");
                        if (mDataResponseArray != null) {
                            mPhotosList.clear();
                            alRecentPhotosDetail.clear();
                            for (int i = 0; i < mDataResponseArray.length(); i++) {
                                JSONObject imageUrlsObj = mDataResponseArray.optJSONObject(i);
                                String image = imageUrlsObj.optString("image");
                                mPhotosList.add(new GridItemModel(image));
                                alRecentPhotosDetail.add(new PhotoListDetails(image));
                            }
                        } else {
                            cvRecentPhotos.setVisibility(View.GONE);
                        }
                        mGridItemAdapterPhotos.setTotalItemCount(itemCount);
                        mGridItemAdapterPhotos.notifyDataSetChanged();
                    }
                });

            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                pbrLoadingPhotos.setVisibility(View.GONE);
                cvRecentPhotos.setVisibility(View.GONE);
                if (isLoadFriends) {
                    getFriends();
                }
            }
        });
    }

    private void getFriends() {
        String url = AppConstant.DEFAULT_URL + "user/get-friend-list?user_id=" + mUserId + "&limit=6";
        pbrLoadingFriends.setVisibility(View.GONE);
        rvFriendList.setVisibility(View.VISIBLE);
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                new Handler().post(new Runnable() {
                    @Override
                    public void run() {
                        pbrLoadingFriends.setVisibility(View.GONE);
                        rvFriendList.setVisibility(View.VISIBLE);
                        mFriendsList.clear();
                        JSONArray mDataResponseArray = jsonObject.optJSONArray("friends");
                        int itemCount = jsonObject.optInt("totalItemCount");
                        if (mDataResponseArray != null) {
                            for (int i = 0; i < mDataResponseArray.length(); i++) {
                                JSONObject friendsObject = mDataResponseArray.optJSONObject(i);
                                String displayName = friendsObject.optString("displayname");
                                String imageUrl = friendsObject.optString("image_profile");
                                int id = friendsObject.optInt("user_id");
                                int mutualFriendCount = friendsObject.optInt("mutualFriendCount");
                                String mutualFriends = (mutualFriendCount > 0) ? mContext.getResources().
                                        getQuantityString(R.plurals.mutual_friend_text, mutualFriendCount, mutualFriendCount) : null;
                                mFriendsList.add(new GridItemModel(imageUrl, displayName, mutualFriends, id));
                            }
                        } else {
                            cvFriends.setVisibility(View.GONE);
                        }
                        mGridItemAdapterFriends.setTotalItemCount(itemCount);
                        mGridItemAdapterFriends.notifyDataSetChanged();
                    }
                });

            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                pbrLoadingFriends.setVisibility(View.GONE);
                cvFriends.setVisibility(View.GONE);
            }
        });
    }

    //Showing list of albums for uploading photos in a particular album
    public void showListOfAlbums() {

        final Dialog albumListDialog = new Dialog(this, R.style.Theme_ListAlbums);
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
                isUploadPhotosRequest = true;
                String url = AppConstant.DEFAULT_URL + "albums/upload?album_id="
                        + mBrowseItemList.get(i).getAlbumId();
                albumListDialog.cancel();
                Intent uploadPhoto = new Intent(userProfile.this, MultiMediaSelectorActivity.class);
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


    @Override
    public void onItemClick(View view, int position) {
        String tag = (view.getTag() != null) ? view.getTag().toString() : null;
        if (tag == null) {
            return;
        }
        switch (tag) {
            case "RecentPhotos":
                openLightBox(alRecentPhotosDetail, position);
                break;
            case "Friends":
                GridItemModel userModel = mFriendsList.get(position);
                goToProfile(userModel.getItemIdentity());
                break;
            case "SeeMore_RecentPhotos":
                Intent newIntent = new Intent(mContext, FragmentLoadActivity.class);
                newIntent.putExtra(ConstantVariables.CONTENT_TITLE, mContext.getResources().getString(R.string.photos_tab));
                newIntent.putExtra(ConstantVariables.FRAGMENT_NAME, "album_photos");
                newIntent.putExtra(ConstantVariables.SUBJECT_TYPE, "album_photo");
                newIntent.putExtra(ConstantVariables.SUBJECT_ID, mUserId);
                newIntent.putExtra(ConstantVariables.URL_STRING, AppConstant.DEFAULT_URL + "albums/photo/list?item_type=user&user_id=" + mUserId + "&order=DESC&limit=" + AppConstant.LIMIT);
                startActivity(newIntent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;
            case "SeeMore_Friends":
                if (mViewPageFragmentAdapter != null) {
                    mViewPageFragmentAdapter.loadFriendTab();
                }
                break;
        }
    }

    public void goToProfile(int userId) {
        Intent userIntent = new Intent(mContext, userProfile.class);
        userIntent.putExtra("user_id", userId);
        ((Activity) mContext).startActivityForResult(userIntent, ConstantVariables.USER_PROFILE_CODE);
        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }
}
