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

package com.socialengineaddons.mobileapp.classes.modules.multipleListingType;

import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.AppBarLayout;
import android.support.design.widget.CollapsingToolbarLayout;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.TabLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v4.widget.NestedScrollView;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.LinearInterpolator;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.PhotoUploadingActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.WebViewActivity;
import com.socialengineaddons.mobileapp.classes.common.adapters.ImageAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.SliderAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.ViewPageFragmentAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.fragments.FragmentUtils;
import com.socialengineaddons.mobileapp.classes.common.fragments.MapViewFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.PhotoFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnOptionItemClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUserReviewDeleteListener;
import com.socialengineaddons.mobileapp.classes.common.ui.BezelImageView;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.SplitToolbar;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageViewList;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.modules.likeNComment.Comment;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoLightBoxActivity;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MLTView extends AppCompatActivity implements ViewPager.OnPageChangeListener,
        View.OnClickListener, AppBarLayout.OnOffsetChangedListener,
        OnOptionItemClickResponseListener, OnUserReviewDeleteListener,
        OnUploadResponseListener, View.OnLongClickListener {

    String TAG = "MLTView";
    private Context mContext;
    private Bundle bundle;
    private AppConstant mAppConst;
    private GutterMenuUtils mGutterMenuUtils;
    private View messageBlock;
    private LinearLayout.LayoutParams llParamLike, llParamCount;
    private ViewPager coverImagePager, viewPager;
    private TabLayout mSlidingTabs;
    private CollapsingToolbarLayout collapsingToolbar;
    private CoordinatorLayout mMainContent;
    private ViewPageFragmentAdapter mViewPageFragmentAdapter;
    private SplitToolbar mBottomToolBar;
    private FrameLayout mCoverLayout;
    private View mCarouselView, mOverviewSeperaterView;
    private ImageView mCoverImage, leftArrow, rightArrow, mProfileImage;
    private TextView mCoverTitle, mPhotoCountIcon;
    private TextView mLikeCountTextView, mCommentCountTextView, mLikeUnlikeText;
    private RelativeLayout mCarouselLayout;
    private LinearLayout mLikeCommentContent;
    private String mMLTViewUrl, mContentUrl, mMakePaymentUrl, mPhotoMenuTitle;
    private String ownerTitle, successMessage, title, coverImage;
    private int ownerId;
    private int mMLTViewType, mListingTypeId, mContentId, isListingClosed = 0, canEdit = 0,
            isListingSubscribed = 0, mListingId, totalItemCount, likeCount, commentCount, mProfileTabSize;
    private float initialY;
    private boolean isLoadingFromCreate = false, isLiked = false, likeUnlikeAction = true, isAdapterSet = false;
    private JSONObject mBody;
    private JSONArray mGutterMenus, imageArray, mProfileTabs;
    private Typeface fontIcon;
    private List<ImageViewList> mPhotoUrls;
    private SliderAdapter sliderAdapter;
    private BrowseListItems mBrowseList;
    public static AppBarLayout appBar;
    private boolean isContentEdited = false;
    private Toolbar mToolbar;
    private TextView mToolBarTitle;
    private JSONObject mReactionsObject, myReaction, mAllReactionObject, mContentReactions;
    private int mReactionsEnabled;
    private ImageView mReactionIcon;
    private List<ImageViewList> reactionsImages;
    private String mLikeUnlikeUrl;
    private int siteVideoPluginEnabled, mAdvVideosCount;
    private TextView mProfileImageMenus, mCoverImageMenus, mContentTitle;
    private JSONArray coverPhotoMenuArray, profilePhotoMenuArray;
    private ArrayList<PhotoListDetails> mPhotoDetails, mProfilePhotoDetail;
    private ProgressBar mProgressBar;
    private int defaultCover, cover_photo = 0, profile_photo = 0;
    private String profileImageUrl, coverImageUrl;
    private boolean isCoverRequest;
    private JSONObject mResponseObject;
    private AlertDialogWithAction mAlertDialogWithAction;
    boolean isCoverPhotoEnable = false;
    private ArrayList<JSONObject> mReactionsArray;
    private ImageLoader mImageLoader;
    private LinearLayout mOwnerView;
    private TextView mOwnerTitle, mCategoryText;
    private BezelImageView mOwnerImage;
    private String ownerImage, overview, category, body;
    private WebView mViewDescription, mViewBody;
    private NestedScrollView mScrollView;
    private int mUserId;
    private String sendLikeNotificationUrl;
    private int currentSelectedTab;
    private boolean isCoverProfilePictureRequest = false;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile_pages);
        mContext = MLTView.this;
        mAppConst = new AppConstant(mContext);
        mGutterMenuUtils = new GutterMenuUtils(mContext);
        mGutterMenuUtils.setOnOptionItemClickResponseListener(this);
        fontIcon = GlobalFunctions.getFontIconTypeFace(mContext);
        mPhotoUrls = new ArrayList<>();
        mProfileTabs = new JSONArray();
        FragmentUtils.setOnUserReviewDeleteListener(this);
        mPhotoDetails = new ArrayList<>();
        mProfilePhotoDetail = new ArrayList<>();
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        mImageLoader = new ImageLoader(getApplicationContext());

        /* Create Back Button On Action Bar **/
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mToolBarTitle = (TextView) findViewById(R.id.toolbar_title);
        mToolBarTitle.setSelected(true);
        setSupportActionBar(mToolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(getResources().getString(R.string.blank_string));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }


        /** Getting Intent Key's. **/
        mContentId = getIntent().getIntExtra(ConstantVariables.VIEW_PAGE_ID, 0);

        // View Page Url
        mListingTypeId = getIntent().getIntExtra(ConstantVariables.LISTING_TYPE_ID, 0);
        mMLTViewUrl = getIntent().getStringExtra(ConstantVariables.VIEW_PAGE_URL) + "&listingtype_id=" + mListingTypeId;

        PreferencesUtils.setCurrentSelectedListingId(mContext, mListingTypeId);

        // MLT view type
        // Getting current Listing variables from preferences
        mMLTViewType = PreferencesUtils.getMLTViewType(mContext, mListingTypeId);
        if (mMLTViewType == 0)
            mMLTViewType = 3;

        // Initializing respective views according to view types.
        initializeView(mMLTViewType);

        // If response coming from create page.
        mBody = GlobalFunctions.getCreateResponse(getIntent().getStringExtra(ConstantVariables.EXTRA_CREATE_RESPONSE));

        mReactionsEnabled = PreferencesUtils.getReactionsEnabled(mContext);

        /*
            Check if Reactions and nested comment plugin is enabled on the site
            send request to get the reactions on a particular content
            send this request only if the reactions Enabled is not saved yet in Preferences
             or if it is set to 1
         */
        if(mReactionsEnabled == 1 || mReactionsEnabled == -1){
            String getContentReactionsUrl = UrlUtil.CONTENT_REACTIONS_URL + "&subject_type=sitereview_listing" +
                    "&subject_id=" + mContentId;
            mAppConst.getJsonResponseFromUrl(getContentReactionsUrl, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mReactionsObject = jsonObject;
                    JSONObject reactionsData = mReactionsObject.optJSONObject("reactions");
                    mContentReactions = mReactionsObject.optJSONObject("feed_reactions");
                    if(reactionsData != null){
                        mReactionsEnabled = reactionsData.optInt("reactionsEnabled");
                        PreferencesUtils.updateReactionsEnabledPref(mContext, mReactionsEnabled);
                        mAllReactionObject = reactionsData.optJSONObject("reactions");
                        if(mAllReactionObject != null){
                            mReactionsArray = GlobalFunctions.sortReactionsObjectWithOrder(mAllReactionObject);
                        }
                    }

                    // Load Data Directly if Coming from Create Page.
                    if (mBody != null && mBody.length() != 0) {
                        isLoadingFromCreate = true;
                        isContentEdited = true;
                        checkSiteVideoPluginEnabled();
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    // Load Data Directly if Coming from Create Page.
                    if (mBody != null && mBody.length() != 0) {
                        isLoadingFromCreate = true;
                        isContentEdited = true;
                        checkSiteVideoPluginEnabled();
                    }
                }
            });
        } else {
            // Load Data Directly if Coming from Create Page.
            if (mBody != null && mBody.length() != 0) {
                isLoadingFromCreate = true;
                isContentEdited = true;
                checkSiteVideoPluginEnabled();
            }
        }
    }

    /**
     * Method to initialize view according to view type.
     * @param mMLTViewType type contains the view page type in which view page needs to be shown.
     */
    public void initializeView(int mMLTViewType) {

        /**
         * Common views in all view types
         */
        //Header view
        mCoverLayout = (FrameLayout) findViewById(R.id.cover_layout);
        mMainContent = (CoordinatorLayout) findViewById(R.id.main_content);
        appBar = (AppBarLayout) findViewById(R.id.appbar);
        appBar.addOnOffsetChangedListener(this);

        // Setup the Tabs
        viewPager = (ViewPager) findViewById(R.id.pager);
        mSlidingTabs = (TabLayout) findViewById(R.id.slidingTabs);

        collapsingToolbar = (CollapsingToolbarLayout) findViewById(R.id.collapsing_toolbar);

        switch (mMLTViewType) {
            case ConstantVariables.BLOG_VIEW:
                mCoverLayout.setVisibility(View.GONE);
                viewPager.setVisibility(View.GONE);
                mSlidingTabs.setVisibility(View.GONE);

                mScrollView = (NestedScrollView) findViewById(R.id.scroll_view);
                mOwnerView = (LinearLayout) findViewById(R.id.owner_detail_layout);
                mOwnerImage = (BezelImageView) findViewById(R.id.owner_image);
                mOwnerTitle = (TextView) findViewById(R.id.owner_title);
                mCategoryText = (TextView) findViewById(R.id.category);
                mOverviewSeperaterView = findViewById(R.id.mOverviewSeperaterView);
                mViewBody = (WebView) findViewById(R.id.view_blog_body);
                mViewDescription = (WebView) findViewById(R.id.view_blog_overview);
                GlobalFunctions.setWebSettings(mViewBody, false);
                GlobalFunctions.setWebSettings(mViewDescription, false);
                break;

            case ConstantVariables.CLASSIFIED_VIEW_WITH_CAROUSEL:
                mCarouselView = LayoutInflater.from(this).inflate(R.layout.layout_carousel_image, null);

                mCarouselLayout = (RelativeLayout) mCarouselView.findViewById(R.id.carouselLayout);
                coverImagePager = (ViewPager) mCarouselView.findViewById(R.id.backdrop);
                mCoverTitle = (TextView) mCarouselView.findViewById(R.id.content_title);
                leftArrow = (ImageView) mCarouselView.findViewById(R.id.left_arrow);
                rightArrow = (ImageView) mCarouselView.findViewById(R.id.right_arrow);
                mPhotoCountIcon = (TextView) mCarouselView.findViewById(R.id.image_count);
                mPhotoCountIcon.setTypeface(fontIcon);

                sliderAdapter = new SliderAdapter(this, mPhotoUrls, new OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {
                        // launch full screen activity
                        Bundle bundle = new Bundle();
                        bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mPhotoDetails);
                        Intent i = new Intent(mContext, PhotoLightBoxActivity.class);
                        i.putExtra("position", position);
                        i.putExtra("canEdit",canEdit);
                        i.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.MLT_MENU_TITLE);
                        i.putExtra(ConstantVariables.LISTING_TYPE_ID, mListingTypeId);
                        i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, totalItemCount);
                        i.putExtras(bundle);
                        startActivityForResult(i, ConstantVariables.VIEW_LIGHT_BOX);
                    }
                });
                coverImagePager.setAdapter(sliderAdapter);
                coverImagePager.addOnPageChangeListener(this);

                leftArrow.setOnClickListener(this);
                rightArrow.setOnClickListener(this);

                break;
        }

        mProgressBar = (ProgressBar) findViewById(R.id.progressBar);
        mCoverImage = (ImageView) findViewById(R.id.coverImage);
        mContentTitle = (TextView) findViewById(R.id.content_title);
        mProfileImage = (ImageView) findViewById(R.id.profile_image);
        mCoverImageMenus = (TextView) findViewById(R.id.cover_image_menus);
        mProfileImageMenus = (TextView) findViewById(R.id.profile_image_menus);
        mCoverImageMenus.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        mProfileImageMenus.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));

        //Footer view.
        /*
            Like and Unlike Fields...
        */
        mLikeCountTextView = (TextView) findViewById(R.id.likeCount);
        mCommentCountTextView = (TextView) findViewById(R.id.commentCount);
        mReactionIcon = (ImageView) findViewById(R.id.reactionIcon);
        mLikeUnlikeText = (TextView) findViewById(R.id.likeUnlikeText);

        View likeBlock = findViewById(R.id.likeBlock);
        View likeCommentCountBlock = findViewById(R.id.likeCommentBlock);
        messageBlock = findViewById(R.id.messageBlock);
        messageBlock.setVisibility(View.VISIBLE);
        findViewById(R.id.message_divider).setVisibility(View.VISIBLE);
        findViewById(R.id.commentBlock).setVisibility(View.GONE);
        findViewById(R.id.comment_divider).setVisibility(View.GONE);
        ImageView ivMessageIcon = findViewById(R.id.messageIcon);
        TextView tvMessage = findViewById(R.id.messageText);
        Drawable icon;
        if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
            ivMessageIcon.setVisibility(View.GONE);
            icon = ContextCompat.getDrawable(mContext, R.drawable.ic_prime_messenger);
            tvMessage.setCompoundDrawablesWithIntrinsicBounds(icon, null, null, null);
        } else {
            ivMessageIcon.setVisibility(View.VISIBLE);
            icon = ContextCompat.getDrawable(mContext, R.drawable.ic_message);
        }
        icon.mutate();
        ivMessageIcon.setImageDrawable(icon);
        ivMessageIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.grey_dark),
                PorterDuff.Mode.SRC_ATOP);

        llParamLike = (LinearLayout.LayoutParams) likeBlock.getLayoutParams();
        llParamCount = (LinearLayout.LayoutParams) likeCommentCountBlock.getLayoutParams();
        messageBlock.setOnClickListener(this);
        likeBlock.setOnClickListener(this);
        likeBlock.setOnLongClickListener(this);
        likeCommentCountBlock.setOnClickListener(this);

        mLikeCommentContent = (LinearLayout) findViewById(R.id.likeCommentContent);
        mBottomToolBar = (SplitToolbar) findViewById(R.id.toolbarBottom);
        mBottomToolBar.setVisibility(View.GONE);
    }

    /**
     * Method to get response of mlt view page.
     */
    public void makeRequest(){

        // Do not send request if coming from create page
        if(!isLoadingFromCreate){
            mAppConst.getJsonResponseFromUrl(mMLTViewUrl, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) {
                    mBody = jsonObject;
                    checkSiteVideoPluginEnabled();
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mProgressBar.setVisibility(View.GONE);
                    SnackbarUtils.displaySnackbarLongWithListener(mMainContent, message,
                            new SnackbarUtils.OnSnackbarDismissListener() {
                                @Override
                                public void onSnackbarDismissed() {
                                    finish();
                                }
                            });
                }
            });
        }
    }

    /**
     *  This calling will return sitevideoPluginEnabled to 1 if
     *  1. Adv Video plugin is integrated with Directory/Pages plugin
     *  2. And if there is any video uploaded in this page using Avd video
     *  else it will return sitevideoPluginEnabled to 0
     */
    public void checkSiteVideoPluginEnabled(){

        String url = UrlUtil.IS_SITEVIDEO_ENABLED + "?subject_id=" + mContentId + "&subject_type=sitereview_listing";
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mProgressBar.setVisibility(View.GONE);
                siteVideoPluginEnabled = jsonObject.optInt("sitevideoPluginEnabled");
                mAdvVideosCount = jsonObject.optInt("totalItemCount");
                loadViewPageData(mBody);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mProgressBar.setVisibility(View.GONE);
                loadViewPageData(mBody);
            }
        });

    }

    /**
     * Method to get view page data.
     * @param bodyJsonObject jsonObject, which contains view page data.
     */
    private void loadViewPageData(JSONObject bodyJsonObject) {
        mProgressBar.setVisibility(View.GONE);

        mResponseObject = bodyJsonObject;

        if(mPhotoDetails != null && mPhotoUrls != null) {
            mPhotoUrls.clear();
            mPhotoDetails.clear();
        }

        if (bodyJsonObject != null && bodyJsonObject.length() != 0) {
            try {
                mGutterMenus = bodyJsonObject.optJSONArray("gutterMenu");
                mListingId = bodyJsonObject.optInt("listing_id");
                ownerTitle = bodyJsonObject.optString("owner_title");
                ownerId = bodyJsonObject.optInt("owner_id");
                category = bodyJsonObject.optString("categoryName");
                mUserId = bodyJsonObject.optInt("owner_id");
                isLiked = bodyJsonObject.optBoolean("is_like");
                likeCount = bodyJsonObject.optInt("like_count");
                commentCount = bodyJsonObject.optInt("comment_count");
                title = bodyJsonObject.optString("title");
                coverImage = bodyJsonObject.optString("image");
                imageArray = bodyJsonObject.optJSONArray("images");
                mContentUrl = bodyJsonObject.optString("content_url");
                isListingClosed = bodyJsonObject.optInt("closed");
                isListingSubscribed = bodyJsonObject.optInt("isSubscribed");
                int isApplyJob = bodyJsonObject.optInt("isApplyJob");

                mBrowseList = new BrowseListItems(mListingId, title, coverImage, mContentUrl, isListingClosed,
                        isListingSubscribed, isApplyJob);

                profileImageUrl = bodyJsonObject.getString("image");
                coverImageUrl = bodyJsonObject.optString("cover_image");
                ownerImage = bodyJsonObject.optString("owner_image_icon");
                overview = bodyJsonObject.optString("overview");
                body = bodyJsonObject.optString("body");

                String messageOwnerUrl = null, messageOwnerTitle = null;
                if (mGutterMenus != null) {
                    for (int i = 0; i < mGutterMenus.length(); i++) {
                        JSONObject jsonObject = mGutterMenus.optJSONObject(i);
                        if (jsonObject.optString("name").toLowerCase().equals("messageowner")) {
                            messageOwnerUrl = AppConstant.DEFAULT_URL + jsonObject.optString("url");
                            messageOwnerTitle = jsonObject.optString("label");
                            break;
                        }
                    }
                    invalidateOptionsMenu();
                }

                // Used for message.
                mBrowseList.setUserId(bodyJsonObject.optInt("owner_id"));
                mBrowseList.setUserDisplayName(bodyJsonObject.optString("owner_title"));
                mBrowseList.setUserProfileImageUrl(bodyJsonObject.optString("owner_image_normal"));
                mBrowseList.setMessageOwnerUrl(messageOwnerUrl);
                mBrowseList.setMessageOwnerTitle(messageOwnerTitle);

                checkForMessageOption();

                // Don't show profile tabs for blog view type

                if (mMLTViewType != ConstantVariables.BLOG_VIEW) {
                    mProfileTabs = bodyJsonObject.optJSONArray("profile_tabs");
                    bundle = new Bundle();
                    bundle.putString(ConstantVariables.RESPONSE_OBJECT, bodyJsonObject.toString());
                    bundle.putInt(ConstantVariables.CAN_UPLOAD, bodyJsonObject.optInt("can_upload_photo"));
                    bundle.putString(ConstantVariables.SUBJECT_TYPE, "sitereview_listing");
                    bundle.putInt(ConstantVariables.SUBJECT_ID, mListingId);
                    bundle.putInt(ConstantVariables.CONTENT_ID, mContentId);
                    bundle.putInt(ConstantVariables.LISTING_ID, mListingId);
                    bundle.putInt(ConstantVariables.MLT_VIEW_TYPE, mMLTViewType);
                    bundle.putInt(ConstantVariables.LISTING_TYPE_ID, mListingTypeId);
                    bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.MLT_MENU_TITLE);
                    bundle.putInt(ConstantVariables.ADV_VIDEO_INTEGRATED, siteVideoPluginEnabled);
                    bundle.putInt(ConstantVariables.ADV_VIDEOS_COUNT, mAdvVideosCount);

                    if (!isAdapterSet) {

                        mProfileTabSize = mProfileTabs.length();
                        // Setup the viewPager
                        mViewPageFragmentAdapter = new ViewPageFragmentAdapter(mContext,
                                getSupportFragmentManager(), mProfileTabs, bundle);
                        viewPager.setAdapter(mViewPageFragmentAdapter);

                        viewPager.setOffscreenPageLimit(mViewPageFragmentAdapter.getCount() + 1);
                        // This method ensures that tab selection events update the ViewPager and page changes update the selected tab.
                        mSlidingTabs.setupWithViewPager(viewPager);

                        // Showing the alert dialog once when listing is closed.
                        if (isListingClosed == 1) {

                            mAlertDialogWithAction.showDialogForClosedContent(title,
                                    mContext.getResources().getString(R.string.this_text) + " " +
                                            PreferencesUtils.getCurrentSelectedListingSingularLabel(mContext,
                                                    mListingTypeId).toLowerCase() +
                                            " " + mContext.getResources().getString(R.string.closed_listing_msg));
                        }

                        // Checking for the make payment option.
                        if (mGutterMenus != null) {
                            for (int i = 0; i < mGutterMenus.length(); i++) {
                                JSONObject menuJsonObject = mGutterMenus.optJSONObject(i);
                                if (menuJsonObject.optString("name").equals("makePayment")) {
                                    mMakePaymentUrl = menuJsonObject.optString("url");
                                }
                            }
                        }

                        // When payment url is not null then showing the snackbar with payment message,
                        // and action button for making the payment.
                        if (mMakePaymentUrl != null && !mMakePaymentUrl.isEmpty()) {
                            SnackbarUtils.displayMultiLineSnackbarWithAction(mContext, mMainContent,
                                    mContext.getResources().getString(R.string.make_payment_message),
                                    mContext.getResources().getString(R.string.pay_now_text),
                                    new SnackbarUtils.OnSnackbarActionClickListener() {
                                        @Override
                                        public void onSnackbarActionClick() {
                                            Intent webViewIntent = new Intent(mContext, WebViewActivity.class);
                                            webViewIntent.putExtra("isPackagePayment", true);
                                            webViewIntent.putExtra("url", mMakePaymentUrl);
                                            startActivityForResult(webViewIntent, ConstantVariables.PACKAGE_WEBVIEW_CODE);
                                            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                                        }
                                    });
                        }
                        isAdapterSet = true;
                    } else {
                        mViewPageFragmentAdapter.updateData(bundle, mProfileTabs,
                                (mProfileTabSize == mProfileTabs.length()), false);
                        // If any tab is added/removed then again set the adapter.
                        if (mProfileTabSize != mProfileTabs.length()) {
                            mProfileTabSize = mProfileTabs.length();
                            viewPager.setAdapter(mViewPageFragmentAdapter);
                        }
                    }


                    if (viewPager != null) {
                        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
                            @Override
                            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
                            }

                            @Override
                            public void onPageSelected(int position) {
                                if ((mProfileTabSize -1) != position ) {
                                    currentSelectedTab = position;
                                }
                                if (mBottomToolBar != null && mAppConst != null) {
                                    if (position == 1 && !mAppConst.isLoggedOutUser()) {
                                        mBottomToolBar.setVisibility(View.VISIBLE);
                                    } else {
                                        mBottomToolBar.setVisibility(View.GONE);
                                    }
                                }
                            }

                            @Override
                            public void onPageScrollStateChanged(int state) {
                            }
                        });
                    }
                }

                //Setting data in respective views
                setDataInViews();

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void checkForMessageOption() {
        if (mBrowseList.getMessageOwnerUrl() != null
                && !mBrowseList.getMessageOwnerUrl().isEmpty()) {
            messageBlock.setVisibility(View.VISIBLE);
            llParamLike.weight = (float) 0.3;
            llParamCount.weight = (float) 0.33;
        } else {
            messageBlock.setVisibility(View.GONE);
            llParamLike.weight = (float) 0.5;
            llParamCount.weight = (float) 0.5;
        }
    }

    /**
     * Method for setting the data in respective views according to view types.
     */
    public void setDataInViews() {
        try {

            collapsingToolbar.setTitle(title);
            mToolBarTitle.setText(title);
            mContentTitle.setText(title);
            CustomViews.setCollapsingToolBarTitle(collapsingToolbar);

            if (mResponseObject.has("default_cover")) {
                isCoverPhotoEnable = true;
            }

            switch (mMLTViewType) {

                case ConstantVariables.BLOG_VIEW:
                    if (getSupportActionBar() != null) {
                        if (isCoverPhotoEnable) {
                            mCoverLayout.setVisibility(View.VISIBLE);
                            showCoverImageView();
                        } else {
                            String listingName = PreferencesUtils.getCurrentSelectedListingSingularLabel(mContext, mListingTypeId);
                            mToolBarTitle.setText(listingName);
                            collapsingToolbar.setTitleEnabled(false);
                        }

                    }

                    mScrollView.setVisibility(View.VISIBLE);

                    mOwnerTitle.setText(ownerTitle);
                    //Showing profile image.
                    if (ownerImage != null && !ownerImage.isEmpty()) {
                        mOwnerImage.setVisibility(View.VISIBLE);
                        mImageLoader.setImageForUserProfile(ownerImage, mOwnerImage);
                    }
                    mCategoryText.setText(category);
                    mCategoryText.setVisibility(View.VISIBLE);

                    mOwnerImage.setOnClickListener(this);
                    mOwnerTitle.setOnClickListener(this);

                    //Showing body block if there is any text in body.
                    if (body != null && !body.isEmpty()) {
                        mViewBody.setVisibility(View.VISIBLE);

                         /*Setting Body in TextView */
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                            mViewBody.getSettings().setLayoutAlgorithm(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING);
                        } else {
                            mViewBody.getSettings().setLayoutAlgorithm(WebSettings.LayoutAlgorithm.NORMAL);
                        }

                        mViewBody.loadDataWithBaseURL("file:///android_asset/",
                                GlobalFunctions.getHtmlData(mContext, body, true), "text/html", "utf-8", null);
                    }else {
                        mViewBody.setVisibility(View.GONE);
                    }

                    //Showing description block if there is any text in body.
                    if (overview != null && !overview.isEmpty()) {
                        mOverviewSeperaterView.setVisibility(View.VISIBLE);
                        mViewDescription.setVisibility(View.VISIBLE);

                        /* Setting Body in TextView */
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                            mViewDescription.getSettings().setLayoutAlgorithm(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING);
                        } else {
                            mViewDescription.getSettings().setLayoutAlgorithm(WebSettings.LayoutAlgorithm.NORMAL);
                        }
                        mViewDescription.loadDataWithBaseURL("file:///android_asset/",
                                GlobalFunctions.getHtmlData(mContext, overview, true), "text/html", "utf-8", null);
                    } else {
                        mOverviewSeperaterView.setVisibility(View.GONE);
                    }

                    break;

                case ConstantVariables.CLASSIFIED_VIEW_WITH_CAROUSEL:
                    mCarouselLayout.setVisibility(View.VISIBLE);

                    if (isCoverPhotoEnable) {
                        showCoverImageView();

                    } else if (imageArray != null && imageArray.length() > 0){
                        mCoverTitle.setText(title);
                        mCoverLayout.removeAllViews();
                        mCoverLayout.addView(mCarouselView);
                        for (int i = 0; i < imageArray.length(); i++) {

                            JSONObject imageUrlsObj = imageArray.optJSONObject(i);

                            String normalImgUrl = imageUrlsObj.optString("image");
                            String image_title = imageUrlsObj.optString("title");
                            String image_desc = imageUrlsObj.optString("description");
                            int photo_id = imageUrlsObj.optInt("photo_id");
                            int photoLikeCount = imageUrlsObj.optInt("like_count");
                            boolean isLiked = imageUrlsObj.optBoolean("is_like");
                            String menuArray = imageUrlsObj.optString("menu");

                            totalItemCount = imageArray.length();
                            mPhotoDetails.add(new PhotoListDetails(title, ownerTitle,
                                    image_title, image_desc, photo_id, normalImgUrl, photoLikeCount,
                                    isLiked, menuArray));

                            mPhotoUrls.add(new ImageViewList(normalImgUrl));
                            sliderAdapter.notifyDataSetChanged();
                            if (mPhotoUrls.size() > 1 && coverImagePager != null &&
                                    coverImagePager.getCurrentItem() == 0) {
                                rightArrow.setVisibility(View.VISIBLE);
                            }
                            mPhotoCountIcon.setText(String.format("\uF030 %d", mPhotoUrls.size()));
                        }
                    }

                    break;

                case ConstantVariables.CLASSIFIED_VIEW_WITHOUT_CAROUSEL:
                    if (isCoverPhotoEnable) {
                        showCoverImageView();
                    } else {
                        mImageLoader.setImageUrl(profileImageUrl, mCoverImage);
                        mPhotoDetails.clear();
                        mPhotoDetails.add(new PhotoListDetails(profileImageUrl));
                    }

                    break;
            }
            setLikeAndCommentCount();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /*
     * Show cover image view if content cover image plugin is enabled
     */
    private void showCoverImageView() {
        mProfileImage.setVisibility(View.VISIBLE);
        defaultCover = mResponseObject.optInt("default_cover");

        //Showing profile image.
        if (profileImageUrl != null && !profileImageUrl.isEmpty()) {
            mProfileImage.setVisibility(View.VISIBLE);
            mImageLoader.setCoverImageUrl(profileImageUrl, mProfileImage);
        }

        //Showing Cover image.
        if (coverImageUrl != null && !coverImageUrl.isEmpty()) {
            cover_photo = defaultCover == 1 ? 0 : 1;
            mImageLoader.setCoverImageUrl(coverImageUrl, mCoverImage);
        }
        profile_photo = mResponseObject.has("photo_id") ? 1 : 0;
        getCoverMenuRequest();

        mProfilePhotoDetail.clear();
        mPhotoDetails.clear();

        mProfilePhotoDetail.add(new PhotoListDetails(profileImageUrl));
        mPhotoDetails.add(new PhotoListDetails(coverImageUrl));
        CustomViews.setCollapsingToolBarTitle(collapsingToolbar);

        mCoverImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (PreferencesUtils.getSiteContentCoverPhotoEnabled(mContext) == 1 &&
                        coverPhotoMenuArray != null && coverPhotoMenuArray.length() > 0) {
                    isCoverRequest = true;
                    mPhotoMenuTitle = getResources().getString(R.string.choose_cover_photo);
                    mGutterMenuUtils.showPopup(mCoverImageMenus, coverPhotoMenuArray,
                            mBrowseList, ConstantVariables.MLT_MENU_TITLE);
                } else {
                    openLightBox(true);
                }

            }
        });

        mProfileImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (profileImageUrl != null && !profileImageUrl.isEmpty() &&
                        profilePhotoMenuArray != null && profilePhotoMenuArray.length() > 0) {
                    isCoverRequest = false;
                    mPhotoMenuTitle = getResources().getString(R.string.choose_profile_photo);
                    mGutterMenuUtils.showPopup(mProfileImageMenus, profilePhotoMenuArray,
                            mBrowseList, ConstantVariables.MLT_MENU_TITLE);
                } else {
                    openLightBox(false);
                }
            }
        });
    }

    private void getCoverMenuRequest() {
        String menuUrl = UrlUtil.GET_COVER_MENU_URL +"subject_id=" + mListingId +
                "&subject_type=sitereview_listing&special=both&cover_photo=" + cover_photo + "&profile_photo=" + profile_photo;

        mAppConst.getJsonResponseFromUrl(menuUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                JSONObject mResponseObject = jsonObject.optJSONObject("response");

                setCoverMenu(mResponseObject);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

            }
        });

    }

    private void setCoverMenu(JSONObject mResponseObject) {

        if (mResponseObject != null) {

            coverPhotoMenuArray = mResponseObject.optJSONArray("coverPhotoMenu");
            profilePhotoMenuArray = mResponseObject.optJSONArray("profilePhotoMenu");

            if (coverPhotoMenuArray != null && coverPhotoMenuArray.length() > 0) {
                mCoverImageMenus.setVisibility(View.VISIBLE);
                mCoverImageMenus.setText("\uf030");
            } else {
                mCoverImageMenus.setVisibility(View.GONE);
            }

            if (profilePhotoMenuArray != null && profilePhotoMenuArray.length() > 0) {
                mProfileImageMenus.setVisibility(View.VISIBLE);
                mProfileImageMenus.setText("\uf030");
            } else {
                mProfileImageMenus.setVisibility(View.GONE);
            }
        }

    }

    /**
     * Method to open photolightbox when user click on view image
     * @param isCoverRequest parameter to decide whether it is user profile or user cover.
     */
    public void openLightBox(boolean isCoverRequest) {

        Bundle bundle = new Bundle();
        if (isCoverRequest) {
            bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mPhotoDetails);
        } else {
            bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mProfilePhotoDetail);
        }
        Intent i = new Intent(mContext, PhotoLightBoxActivity.class);
        i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, 1);
        i.putExtra(ConstantVariables.SHOW_OPTIONS, false);
        i.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.MLT_MENU_TITLE);
        i.putExtras(bundle);
        startActivityForResult(i, ConstantVariables.VIEW_LIGHT_BOX);

    }

    private void startImageUploading() {
        isCoverProfilePictureRequest = false;
        Intent intent = new Intent(mContext, PhotoUploadingActivity.class);
        intent.putExtra("selection_mode", true);
        intent.putExtra(ConstantVariables.IS_PHOTO_UPLOADED, true);
        startActivityForResult(intent, ConstantVariables.PHOTO_UPLOAD_CODE);
    }

    /**
     * Method to set like and comment count in bottom bar.
     */
    public void setLikeAndCommentCount(){

        if(mAppConst.isLoggedOutUser() || (viewPager != null && viewPager.getCurrentItem() != 0)){
            mBottomToolBar.setVisibility(View.GONE);
        }else{
            mBottomToolBar.setVisibility(View.VISIBLE);
            // setting up the values in views
            mLikeCommentContent.setVisibility(View.VISIBLE);

            mLikeUnlikeText.setActivated(isLiked);
            if(!isLiked){
                mLikeUnlikeText.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark));
            }else{
                mLikeUnlikeText.setTextColor(ContextCompat.getColor(mContext, R.color.themeButtonColor));
            }

            /*
            Set Like and Comment Count
             */
            // Check if Reactions is enabled, show that content reaction and it's icon here.
            if(mReactionsEnabled == 1 && mReactionsObject != null && mReactionsObject.length() != 0){


                myReaction = mReactionsObject.optJSONObject("my_feed_reaction");

                if(myReaction != null && myReaction.length() != 0){
                    mLikeUnlikeText.setText(myReaction.optString("caption"));
                    String reactionImage = myReaction.optString("reaction_image_icon");
                    mImageLoader.setImageUrl(reactionImage, mReactionIcon);
                    mReactionIcon.setVisibility(View.VISIBLE);
                    mLikeUnlikeText.setCompoundDrawablesWithIntrinsicBounds(
                           null, null, null, null);
                } else {
                    mLikeUnlikeText.setCompoundDrawablesWithIntrinsicBounds(
                            ContextCompat.getDrawable(this, R.drawable.ic_thumb_up_white_18dp),
                            null, null, null);
                    mReactionIcon.setVisibility(View.GONE);
                    mLikeUnlikeText.setText(getString(R.string.like_text));
                }

            } else{
                mLikeUnlikeText.setCompoundDrawablesWithIntrinsicBounds(
                        ContextCompat.getDrawable(this, R.drawable.ic_thumb_up_white_18dp),
                        null, null, null);
                mLikeUnlikeText.setText(getString(R.string.like_text));
            }

            mLikeCountTextView.setText(String.valueOf(likeCount));
            mCommentCountTextView.setText(String.valueOf(commentCount));
        }
    }

    private void toolbarAnimateShow() {
        mBottomToolBar.animate()
                .translationY(0)
                .setInterpolator(new LinearInterpolator())
                .setDuration(180)
                .setListener(new AnimatorListenerAdapter() {
                    @Override
                    public void onAnimationStart(Animator animation) {
                    }
                });
    }

    private void toolbarAnimateHide() {
        mBottomToolBar.animate()
                .translationY(mBottomToolBar.getHeight())
                .setInterpolator(new LinearInterpolator())
                .setDuration(180)
                .setListener(new AnimatorListenerAdapter() {
                    @Override
                    public void onAnimationEnd(Animator animation) {
                    }
                });
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        int action = event.getActionMasked();
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                initialY = event.getY();
                break;

            case MotionEvent.ACTION_UP:
                float finalY = event.getY();
                // When both position equal then don't take any action.
                if (initialY != finalY) {
                    if (initialY < finalY) {
                        toolbarAnimateShow();
                    } else if ((initialY - finalY) > 80){
                        // Hide only when user scroll.
                        toolbarAnimateHide();
                    }
                }
                break;
        }

        return super.dispatchTouchEvent(event);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.default_menu_item, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        int id = item.getItemId();
        if (id == android.R.id.home) {
            onBackPressed();
            // Playing backSound effect when user tapped on back button from tool bar.
            if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
                SoundUtil.playSoundEffectOnBackPressed(mContext);
            }
        } else {
            if (mGutterMenus != null) {
                mGutterMenuUtils.onMenuOptionItemSelected(mMainContent, findViewById(item.getItemId()),
                        id, mGutterMenus, mListingTypeId);

            }
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        menu.clear();
        if(mGutterMenus != null){
            mGutterMenuUtils.showOptionMenus(menu, mGutterMenus, ConstantVariables.MLT_MENU_TITLE,
                    mBrowseList, ownerId);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public void onBackPressed() {

        if (!isFinishing()) {
            if (isContentEdited || isLoadingFromCreate) {
                Intent intent = new Intent();
                setResult(ConstantVariables.VIEW_PAGE_CODE, intent);
            }
            super.onBackPressed();
            mAppConst.hideKeyboard();
            overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        makeRequest();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        super.onActivityResult(requestCode, resultCode, data);
        isLoadingFromCreate = false;

        switch (resultCode){
            case ConstantVariables.VIEW_PAGE_EDIT_CODE:
                isContentEdited = true;
                makeRequest();
                break;

            case ConstantVariables.VIEW_COMMENT_PAGE_CODE:
                if (data != null) {
                    commentCount = data.getIntExtra(ConstantVariables.PHOTO_COMMENT_COUNT, commentCount);
                    mCommentCountTextView.setText(String.valueOf(commentCount));
                }
                break;

            case ConstantVariables.CREATE_REQUEST_CODE:
            case ConstantVariables.PAGE_EDIT_CODE:
                if (mViewPageFragmentAdapter != null) {
                    mViewPageFragmentAdapter.updateData(bundle, mProfileTabs, false, true);
                }
                if (requestCode == ConstantVariables.PHOTO_UPLOAD_CODE
                        && resultCode == ConstantVariables.PAGE_EDIT_CODE && data != null) {
                    ArrayList<String> resultList = data.getStringArrayListExtra(ConstantVariables.PHOTO_LIST);
                    String postUrl = UrlUtil.UPLOAD_COVER_PHOTO_URL + "subject_type=sitereview_listing&subject_id=" + mListingId;
                    if (isCoverRequest) {
                        successMessage = mContext.getResources().getString(R.string.cover_photo_updated);
                    } else {
                        postUrl = postUrl + "&special=profile";
                        successMessage = mContext.getResources().getString(R.string.profile_photo_updated);
                    }
                    new UploadFileToServerUtils(MLTView.this, postUrl, resultList, this).execute();

                }
                break;

            case ConstantVariables.FEED_REQUEST_CODE:
                /* Reset the view pager adapter if any status is posted using AAF */
                if(viewPager != null) {
                    viewPager.setAdapter(mViewPageFragmentAdapter);
                }
                break;

            case ConstantVariables.VIEW_PAGE_CODE:
                if (requestCode == ConstantVariables.ADD_VIDEO_CODE) {
                    isAdapterSet = false;
                    makeRequest();
                }
                break;
                case ConstantVariables.ON_BACK_PRESSED_CODE:
                    mSlidingTabs.setScrollPosition(currentSelectedTab, 0f,true);
                    viewPager.setCurrentItem(currentSelectedTab,true);
                break;

        }
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        Intent intent;
        switch (id) {
            case R.id.left_arrow:
                coverImagePager.setCurrentItem(coverImagePager.getCurrentItem() - 1, true);
                break;

            case R.id.right_arrow:
                coverImagePager.setCurrentItem(coverImagePager.getCurrentItem() + 1, true);
                break;

            case R.id.likeBlock:
                int reactionId = 0;
                String reactionIcon = null, caption = null;

                if(mReactionsEnabled ==  1 && mAllReactionObject != null ){
                    reactionId = mAllReactionObject.optJSONObject("like").optInt("reactionicon_id");
                    reactionIcon = mAllReactionObject.optJSONObject("like").optJSONObject("icon").
                            optString("reaction_image_icon");
                    caption = mContext.getResources().getString(R.string.like_text);
                }
                doLikeUnlike(null, false, reactionId, reactionIcon, caption);
                break;

            case R.id.likeCommentBlock:
                String mLikeCommentsUrl = AppConstant.DEFAULT_URL + "likes-comments?subject_type=sitereview_listing" +
                        "&subject_id=" + mListingId + "&viewAllComments=1&page=1&limit=20";
                intent = new Intent(mContext, Comment.class);
                intent.putExtra(ConstantVariables.LIKE_COMMENT_URL, mLikeCommentsUrl);
                intent.putExtra(ConstantVariables.SUBJECT_TYPE, ConstantVariables.MLT_MENU_TITLE);
                intent.putExtra(ConstantVariables.SUBJECT_ID, mListingId);
                intent.putExtra("commentCount", commentCount);
                intent.putExtra("reactionsEnabled", mReactionsEnabled);
                if(mContentReactions != null){
                    intent.putExtra("popularReactions", mContentReactions.toString());
                }
                startActivityForResult(intent, ConstantVariables.VIEW_COMMENT_PAGE_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.coverImage:
                Bundle bundle = new Bundle();
                bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mPhotoDetails);
                Intent i = new Intent(mContext, PhotoLightBoxActivity.class);
                i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, 1);
                i.putExtra(ConstantVariables.SHOW_OPTIONS, false);
                i.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.MLT_MENU_TITLE);
                i.putExtras(bundle);
                startActivityForResult(i, ConstantVariables.VIEW_LIGHT_BOX);

            case R.id.owner_title:
            case R.id.owner_image:
                if (mUserId != 0) {
                    intent = new Intent(mContext, userProfile.class);
                    intent.putExtra(ConstantVariables.USER_ID, mUserId);
                    startActivity(intent);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                }
                break;

            case R.id.messageBlock:
                GlobalFunctions.messageOwner(mContext, ConstantVariables.MLT_MENU_TITLE, mBrowseList);
                break;
        }
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
        if(position == (mPhotoUrls.size() - 1)){
            rightArrow.setVisibility(View.INVISIBLE);
        }else {
            rightArrow.setVisibility(View.VISIBLE);
        }
        if(position == 0){
            leftArrow.setVisibility(View.INVISIBLE);
        }else {
            leftArrow.setVisibility(View.VISIBLE);
        }

    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }

    @Override
    public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
        CustomViews.showMarqueeTitle(verticalOffset, collapsingToolbar, mToolbar, mToolBarTitle, title);
    }

    @Override
    public boolean onLongClick(View v) {
        int[] location = new int[2];
        mBottomToolBar.getLocationOnScreen(location);

        RecyclerView reactionsRecyclerView = CustomViews.getReactionPopupRecyclerView(mContext);
        LinearLayout tipLayout = CustomViews.getReactionPopupTipLinearLayout(mContext);

        LinearLayout linearLayout = new LinearLayout(mContext);
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        linearLayout.addView(reactionsRecyclerView);
        linearLayout.addView(tipLayout);

        final PopupWindow popUp = new PopupWindow(linearLayout, LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
        popUp.setTouchable(true);
        popUp.setFocusable(true);
        popUp.setOutsideTouchable(true);
        popUp.setAnimationStyle(R.style.customDialogAnimation);

        // Playing popup effect when user long presses on like button of a feed.
        if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
            SoundUtil.playSoundEffectOnReactionsPopup(mContext);
        }
        popUp.showAtLocation(linearLayout, Gravity.TOP, location[0], location[1] - (int) mContext.getResources().getDimension(R.dimen.reaction_popup_pos_y));

        if(mAllReactionObject != null && mReactionsArray != null) {

            reactionsImages = new ArrayList<>();
            for(int i = 0; i< mReactionsArray.size(); i++){
                JSONObject reactionObject = mReactionsArray.get(i);
                String reaction_image_url = reactionObject.optJSONObject("icon").
                        optString("reaction_image_icon");
                String caption = reactionObject.optString("caption");
                String reaction = reactionObject.optString("reaction");
                int reactionId = reactionObject.optInt("reactionicon_id");
                String reactionIconUrl = reactionObject.optJSONObject("icon").
                        optString("reaction_image_icon");
                reactionsImages.add(new ImageViewList(reaction_image_url, caption,
                        reaction, reactionId, reactionIconUrl));
            }

            ImageAdapter reactionsAdapter = new ImageAdapter((Activity) mContext, reactionsImages, true,
                    new OnItemClickListener() {
                        @Override
                        public void onItemClick(View view, int position) {


                            ImageViewList imageViewList = reactionsImages.get(position);
                            String reaction = imageViewList.getmReaction();
                            String caption = imageViewList.getmCaption();
                            String reactionIcon = imageViewList.getmReactionIcon();
                            int reactionId = imageViewList.getmReactionId();
                            popUp.dismiss();

                            /**
                             * If the user Presses the same reaction again then don't do anything
                             */
                            if(myReaction != null){
                                if(myReaction.optInt("reactionicon_id") != reactionId){
                                    doLikeUnlike(reaction, true, reactionId, reactionIcon, caption);
                                }
                            } else{
                                doLikeUnlike(reaction, false, reactionId, reactionIcon, caption);
                            }
                        }
                    });

            reactionsRecyclerView.setAdapter(reactionsAdapter);
        }
        return true;
    }

    private void doLikeUnlike(String reaction, final boolean isReactionChanged, final int reactionId,
                              final String reactionIcon, final String caption){

        mLikeUnlikeText.setTypeface(fontIcon);
        mLikeUnlikeText.setText("\uf110");
        mLikeUnlikeText.setCompoundDrawablesWithIntrinsicBounds(
                null, null, null, null);

        if (PreferencesUtils.isNestedCommentEnabled(mContext)) {
            sendLikeNotificationUrl = AppConstant.DEFAULT_URL + "advancedcomments/send-like-notitfication";
        } else {
            sendLikeNotificationUrl = AppConstant.DEFAULT_URL + "send-notification";
        }

        mReactionIcon.setVisibility(View.GONE);
        final Map<String, String> likeParams = new HashMap<>();
        likeParams.put(ConstantVariables.SUBJECT_TYPE, "sitereview_listing");
        likeParams.put(ConstantVariables.SUBJECT_ID, String.valueOf(mContentId));

        if(reaction != null){
            likeParams.put("reaction", reaction);
        }

        if(!isLiked || isReactionChanged){
            if(mReactionsEnabled ==  1 && PreferencesUtils.isNestedCommentEnabled(mContext)){
                mLikeUnlikeUrl = AppConstant.DEFAULT_URL + "advancedcomments/like?sendNotification=0";
            } else{
                mLikeUnlikeUrl = AppConstant.DEFAULT_URL + "like";
            }
        } else{
            mLikeUnlikeUrl = AppConstant.DEFAULT_URL + "unlike";
        }

        mAppConst.postJsonResponseForUrl(mLikeUnlikeUrl, likeParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                mLikeUnlikeText.setTypeface(null);
                // Set My FeedReaction Changed
                if( mReactionsEnabled == 1){
                    /* If a Reaction is posted or a reaction is changed on content
                       put the updated reactions in my feed reactions array
                     */
                    updateContentReactions(reactionId, reactionIcon, caption, isLiked, isReactionChanged);

                    /* Calling to send notifications after like action */
                    if (!isLiked) {
                        mAppConst.postJsonResponseForUrl(sendLikeNotificationUrl, likeParams, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                            }
                        });
                    }
                }

                /*
                 Increase Like Count if content is liked else
                 decrease like count if the content is unliked
                 Do not need to increase/decrease the like count when it is already liked and only reaction is changed.
                  */
                if(!isLiked){
                    likeCount += 1;
                } else if( !isReactionChanged){
                    likeCount -= 1;
                }

                // Toggle isLike Variable if reaction is not changed
                if( !isReactionChanged)
                    isLiked = !isLiked;

                setLikeAndCommentCount();
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mLikeUnlikeText.setTypeface(null);
                setLikeAndCommentCount();
                SnackbarUtils.displaySnackbar(findViewById(R.id.main_content), message);
            }
        });
    }

    private void updateContentReactions(int reactionId, String reactionIcon, String caption,
                                        boolean isLiked, boolean isReactionChanged) {

        try {

            // Update the count of previous reaction in reactions object and remove the my_feed_reactions
            if(isLiked && mReactionsObject != null){
                if (myReaction != null && mContentReactions != null) {
                    int myReactionId = myReaction.optInt("reactionicon_id");
                    if (mContentReactions.optJSONObject(String.valueOf(myReactionId)) != null) {
                        int myReactionCount = mContentReactions.optJSONObject(String.valueOf(myReactionId)).
                                optInt("reaction_count");
                        if ((myReactionCount - 1) <= 0) {
                            mContentReactions.remove(String.valueOf(myReactionId));
                        } else {
                            mContentReactions.optJSONObject(String.valueOf(myReactionId)).put("reaction_count",
                                    myReactionCount - 1);
                        }
                        mReactionsObject.put("feed_reactions", mContentReactions);
                    }
                }
                mReactionsObject.put("my_feed_reaction", null);
            }

            // Update the count of current reaction in reactions object and set new my_feed_reactions object.
            if ((!isLiked || isReactionChanged) && mReactionsObject != null) {
                // Set the updated my Reactions

                JSONObject jsonObject = new JSONObject();
                jsonObject.putOpt("reactionicon_id", reactionId);
                jsonObject.putOpt("reaction_image_icon", reactionIcon);
                jsonObject.putOpt("caption", caption);
                mReactionsObject.put("my_feed_reaction", jsonObject);

                if (mContentReactions != null) {
                    if (mContentReactions.optJSONObject(String.valueOf(reactionId)) != null) {
                        int reactionCount = mContentReactions.optJSONObject(String.valueOf(reactionId)).optInt("reaction_count");
                        mContentReactions.optJSONObject(String.valueOf(reactionId)).putOpt("reaction_count", reactionCount + 1);
                    } else {
                        jsonObject.put("reaction_count", 1);
                        mContentReactions.put(String.valueOf(reactionId), jsonObject);
                    }
                } else {
                    mContentReactions = new JSONObject();
                    jsonObject.put("reaction_count", 1);
                    mContentReactions.put(String.valueOf(reactionId), jsonObject);
                }
                mReactionsObject.put("feed_reactions", mContentReactions);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void onItemDelete(String successMessage) {

        // Show Message
        SnackbarUtils.displaySnackbarShortWithListener(mMainContent, successMessage,
                new SnackbarUtils.OnSnackbarDismissListener() {
                    @Override
                    public void onSnackbarDismissed() {
                        Intent intent = new Intent();
                        setResult(ConstantVariables.VIEW_PAGE_CODE, intent);
                        finish();
                    }
                });
    }

    @Override
    public void onOptionItemActionSuccess(Object itemList, String menuName) {
        mBrowseList = (BrowseListItems) itemList;

        switch (menuName) {
            case "view_profile_photo":
            case "view_cover_photo":
                openLightBox(isCoverRequest);
                break;

            case "upload_cover_photo":
            case "upload_photo":
                isCoverProfilePictureRequest = true;
                if(!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)){
                    mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            ConstantVariables.WRITE_EXTERNAL_STORAGE);
                }else{
                    startImageUploading();
                }
                break;

            case "remove_cover_photo":
            case "remove_photo":
                mProgressBar.setVisibility(View.VISIBLE);
                mProgressBar.bringToFront();
                makeRequest();
                break;

            case "choose_from_album":
                Bundle bundle = new Bundle();
                bundle.putString(ConstantVariables.FRAGMENT_NAME, "photos");
                bundle.putString(ConstantVariables.CONTENT_TITLE, mPhotoMenuTitle);
                bundle.putBoolean(ConstantVariables.IS_WAITING, false);
                bundle.putBoolean("isCoverRequest", isCoverRequest);
                bundle.putBoolean("isCoverChange", true);
                bundle.putString(ConstantVariables.URL_STRING, AppConstant.DEFAULT_URL + "listings/photo/" + mListingId);
                bundle.putString(ConstantVariables.SUBJECT_TYPE, ConstantVariables.MLT_MENU_TITLE);
                bundle.putInt(ConstantVariables.SUBJECT_ID, mListingId);
                bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.MLT_MENU_TITLE);
                bundle.putInt(ConstantVariables.LISTING_TYPE_ID, mListingTypeId);
                Intent newIntent = new Intent(mContext, FragmentLoadActivity.class);
                newIntent.putExtras(bundle);
                startActivityForResult(newIntent, ConstantVariables.PHOTO_UPLOAD_CODE);
                ((Activity)mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;
        }

    }

    @Override
    public void onUserReviewDelete() {
        makeRequest();
    }

    @Override
    public void onUploadResponse(JSONObject jsonObject, boolean isRequestSuccessful) {
        if (isRequestSuccessful) {
            SnackbarUtils.displaySnackbarLongTime(mMainContent, successMessage);
            mProgressBar.setVisibility(View.VISIBLE);
            mProgressBar.bringToFront();
            makeRequest();

        } else {
            SnackbarUtils.displaySnackbarLongTime(mMainContent, jsonObject.optString("message"));
        }
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {

        switch (requestCode) {
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, proceed to the normal flow.
                    if (isCoverProfilePictureRequest) {
                        startImageUploading();
                    } else {
                        PhotoFragment fragment = (PhotoFragment) mViewPageFragmentAdapter.getFragment(mViewPageFragmentAdapter.mPhotoTabPosition);
                        fragment.onRequestPermissionsResult(requestCode, permissions, grantResults);
                    }
                } else {
                    // If user deny the permission popup
                    if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                        // Show an explanation to the user, After the user
                        // sees the explanation, try again to request the permission.
                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);
                    }else{
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.
                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, mMainContent,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);
                    }
                }
                break;

            case ConstantVariables.ACCESS_FINE_LOCATION:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    MapViewFragment fragment = (MapViewFragment) mViewPageFragmentAdapter.getFragment(mViewPageFragmentAdapter.mMapTabPosition);
                    if (fragment != null) {
                        fragment.onRequestPermissionsResult(requestCode, permissions, grantResults);
                    }
                } else {
                    // If user press deny in the permission popup
                    if (shouldShowRequestPermissionRationale(Manifest.permission.ACCESS_FINE_LOCATION)) {

                        // Show an expanation to the user After the user
                        // sees the explanation, try again to request the permission.

                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.ACCESS_FINE_LOCATION,
                                ConstantVariables.ACCESS_FINE_LOCATION);

                    } else {
                        // If user pressed never ask again on permission popup
                        // Show Snackbar with setting activity button to open App Info
                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, mMainContent,
                                ConstantVariables.ACCESS_FINE_LOCATION);

                    }
                }
                break;

        }
    }
}
