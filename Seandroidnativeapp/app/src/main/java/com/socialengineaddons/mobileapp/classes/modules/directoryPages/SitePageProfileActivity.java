package com.socialengineaddons.mobileapp.classes.modules.directoryPages;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.AppBarLayout;
import android.support.design.widget.CollapsingToolbarLayout;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.TabLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.util.Patterns;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.animation.LinearInterpolator;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.RatingBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.PhotoUploadingActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.WebViewActivity;
import com.socialengineaddons.mobileapp.classes.common.adapters.ImageAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.ViewPageFragmentAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.FragmentUtils;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnOptionItemClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUserReviewDeleteListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CircularImageView;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ObservableScrollView;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ObservableScrollViewCallbacks;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ScrollState;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ScrollUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageViewList;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.likeNComment.Comment;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoLightBoxActivity;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SitePageProfileActivity extends AppCompatActivity implements View.OnClickListener,
        AppBarLayout.OnOffsetChangedListener, OnOptionItemClickResponseListener, OnUserReviewDeleteListener,
        OnUploadResponseListener, View.OnLongClickListener, ObservableScrollViewCallbacks {


    Toolbar mToolbar;
    private Context mContext;
    private AppConstant mAppConst;
    private GutterMenuUtils mGutterMenuUtils;
    private BrowseListItems mBrowseList;
    private CollapsingToolbarLayout collapsingToolbar;
    private CoordinatorLayout mMainContent;
    private ViewPager viewPager;
    private TabLayout mSlidingTabs;
    private ImageView mCoverImage;
    private String profilePageUrl, mContentUrl;
    private String successMessage, title, coverImage;
    private int mContentId, isPageClosed = 0, likeCount, commentCount, page_id, mProfileTabSize;
    private boolean isLoadingFromCreate = false, isAdapterSet = false, isLiked = false, likeUnlikeAction = true;
    private JSONObject mBody;
    private JSONArray mGutterMenus, mProfileTabs;
    private TextView mLikeCountTextView, mCommentCountTextView, mLikeUnlikeText;
    private Bundle bundle;
    private LinearLayout mLikeCommentContent;
    private ViewPageFragmentAdapter mViewPageFragmentAdapter;
    private Typeface fontIcon;
    private float initialY;
    private ArrayList<PhotoListDetails> mCoverImageDetails;
    private boolean isContentEdited = false;
    private TextView mToolBarTitle;
    private JSONObject mReactionsObject, myReaction, mAllReactionObject, mContentReactions;
    private int mReactionsEnabled;
    private ImageView mReactionIcon;
    private List<ImageViewList> reactionsImages;
    private String mLikeUnlikeUrl;
    private int siteVideoPluginEnabled, mAdvVideosCount;
    public static int sIsPageFollowed = 0;
    private TextView mProfileImageMenus, mCoverImageMenus, mContentTitle;
    private JSONArray coverPhotoMenuArray, profilePhotoMenuArray;
    private ArrayList<PhotoListDetails> mPhotoDetails, mProfilePhotoDetail;
    private ProgressBar mProgressBar;
    private int defaultCover, cover_photo = 0, profile_photo = 0;
    private String profileImageUrl, coverImageUrl;
    private boolean isCoverRequest;
    private AlertDialogWithAction mAlertDialogWithAction;
    private ArrayList<JSONObject> mReactionsArray;
    private int ownerId;
    private ImageLoader mImageLoader;
    private String sendLikeNotificationUrl;
    private boolean isPhoneNumberAdded = false;


    //new declarations
    private String ownerName, ownerImageUrl, categoryName, location, detailString, profileID, websiteUrl;
    private TextView authorName, ratingCountTextView, priceTextView, onwardsLabelTextView, categoryTextView,
            likeCountTextView, callTextView, reviewTextView, detailsLabelTextView,
            msgTextView, locationTextView, msgCallTextView, visitSiteTextView, detailTextView;

    private RatingBar ratingBar;
    private int rating;
    private int price;
    private String phoneNumber;
    private int mParallaxImageHeight;
    private int iStatusBarHeight;
    private ImageView locationImageicon;
    private LinearLayout mapsLayout, bottomButtonLayout, upperButtonLayout;
    private Button callMsgBtn;
    private CoordinatorLayout rootLayout;
    private RelativeLayout relMainLayout;
    private CollapsingToolbarLayout topCollapsing;
    private boolean isOwner;
    private JSONArray newGutterMenu;
    private ObservableScrollView mScrollView;
    private String newLikeUrl, newFollowUrl;
    int reviewCount;

    private View horizontalView1, horizontalView2;
    private CircularImageView mProfileImage;

    private boolean isReviewEnabled=false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_site_page_profile);
        mContext = this;
        mAppConst = new AppConstant(mContext);
        mImageLoader = new ImageLoader(mContext);
        mGutterMenuUtils = new GutterMenuUtils(this);
        mGutterMenuUtils.setOnOptionItemClickResponseListener(this);
        fontIcon = GlobalFunctions.getFontIconTypeFace(mContext);
        mCoverImageDetails = new ArrayList<>();
        FragmentUtils.setOnUserReviewDeleteListener(this);
        mPhotoDetails = new ArrayList<>();
        mProfilePhotoDetail = new ArrayList<>();
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        initViews();

    }

    private void initViews() {
        mProfileImageMenus = findViewById(R.id.profile_image_menus);
        mCoverImageMenus = findViewById(R.id.cover_image_menus);
        mCoverImageMenus.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        mProfileImageMenus.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        horizontalView1 = findViewById(R.id.horiz_line_view);
        horizontalView2 = findViewById(R.id.horiz_line_view2);
        detailTextView = findViewById(R.id.detail_text_view);
        detailsLabelTextView = findViewById(R.id.details_label_text_view);
        upperButtonLayout = findViewById(R.id.btn_layout);
        visitSiteTextView = findViewById(R.id.visit_txtview_btn);
        relMainLayout = findViewById(R.id.rel_main_layout);
        mScrollView = findViewById(R.id.scroll);
        mScrollView.setScrollViewCallbacks(this);
        topCollapsing = findViewById(R.id.collapsing_toolbar);

        rootLayout = findViewById(R.id.main_content);
        msgCallTextView = findViewById(R.id.msg_txtview_btn);
        bottomButtonLayout = findViewById(R.id.bottom_btn_layout);
        callMsgBtn = findViewById(R.id.call_btn);
        mapsLayout = findViewById(R.id.maps_layout);
        reviewTextView = findViewById(R.id.review_text_view);
        msgTextView = findViewById(R.id.msg_text_view);
        likeCountTextView = findViewById(R.id.like_count_text_view);
        callTextView = findViewById(R.id.call_text_view);
        locationImageicon = findViewById(R.id.map_launch_imageview);
        locationTextView = findViewById(R.id.map_location_text_view);
        mProfileImage = findViewById(R.id.profile_image_view);
        authorName = findViewById(R.id.auth_name_text_view);
        ratingBar = findViewById(R.id.rating_bar);
        ratingCountTextView = findViewById(R.id.rating_count_textview);
        priceTextView = findViewById(R.id.price_text_view);
        onwardsLabelTextView = findViewById(R.id.onwards_label_text_view);
        categoryTextView = findViewById(R.id.category_name_text_view);
        setUpClickListeners();
        setUpTabs();
        setUpToolBar();
        init();
    }

    private void setUpClickListeners() {
        visitSiteTextView.setOnClickListener(this);
        msgCallTextView.setOnClickListener(this);
        callMsgBtn.setOnClickListener(this);
        msgTextView.setOnClickListener(this);
        likeCountTextView.setOnClickListener(this);
        locationImageicon.setOnClickListener(this);
        locationTextView.setOnClickListener(this);
        callTextView.setOnClickListener(this);
        reviewTextView.setOnClickListener(this);
    }


    private void follow() {


        if (sIsPageFollowed > 0) {

            SnackbarUtils.displaySnackbar(relMainLayout, getResources().getString(R.string.already_followed_string));

        } else {

            mAppConst.postJsonRequestWithoutParams(newFollowUrl, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    sIsPageFollowed = 1;
                    mAppConst.hideProgressDialog();
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mAppConst.hideProgressDialog();
                }
            });

        }

    }

    private void init() {

        newGutterMenu = new JSONArray();
        mPostParams = new HashMap<>();
        /** Getting Intent Key's. **/
        mContentId = getIntent().getIntExtra(ConstantVariables.VIEW_PAGE_ID, 0);
        // View Page Url
        profilePageUrl = getIntent().getStringExtra(ConstantVariables.VIEW_PAGE_URL);

        // If response coming from create page.
        mBody = GlobalFunctions.getCreateResponse(getIntent().getStringExtra(ConstantVariables.EXTRA_CREATE_RESPONSE));

        if (mBody != null && mBody.length() > 0) {
            mContentId = mBody.optInt("page_id");
            profilePageUrl = AppConstant.DEFAULT_URL + "sitepage/view/" + mContentId + "?gutter_menu=1";
        }

        mReactionsEnabled = PreferencesUtils.getReactionsEnabled(mContext);
        /*
            Check if Reactions and nested comment plugin is enabled on the site
            send request to get the reactions on a particular content
            send this request only if the reactions Enabled is not saved yet in Preferences
             or if it is set to 1
         */
        if (mReactionsEnabled == 1 || mReactionsEnabled == -1) {
            String getContentReactionsUrl = UrlUtil.CONTENT_REACTIONS_URL + "&subject_type=sitepage_page" +
                    "&subject_id=" + mContentId;
            mAppConst.getJsonResponseFromUrl(getContentReactionsUrl, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mReactionsObject = jsonObject;
                    JSONObject reactionsData = mReactionsObject.optJSONObject("reactions");
                    mContentReactions = mReactionsObject.optJSONObject("feed_reactions");
                    if (reactionsData != null) {
                        mReactionsEnabled = reactionsData.optInt("reactionsEnabled");
                        PreferencesUtils.updateReactionsEnabledPref(mContext, mReactionsEnabled);
                        mAllReactionObject = reactionsData.optJSONObject("reactions");
                        if (mAllReactionObject != null) {
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


        mParallaxImageHeight = getResources().getDimensionPixelSize(R.dimen.dimen_750dp);
        iStatusBarHeight = (int) Math.ceil(25 * mContext.getResources().getDisplayMetrics().density);
        int resourceId = getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            iStatusBarHeight = getResources().getDimensionPixelSize(resourceId);
        }

        final ViewGroup.LayoutParams layoutParams = viewPager.getLayoutParams();
        mToolbar.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                mToolbar.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                final int toolbarHeight = mToolbar.getHeight(); //height is ready
                mSlidingTabs.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
                    @Override
                    public void onGlobalLayout() {
                        mSlidingTabs.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                        int tabHeight = mSlidingTabs.getHeight();
                        int screenElementsHeight = (toolbarHeight + tabHeight);
                        if (iStatusBarHeight < 100) {
                            screenElementsHeight += iStatusBarHeight;
                        }
                        layoutParams.height = (mAppConst.getScreenHeight() - screenElementsHeight);
                    }
                });
            }
        });
    }


    /**
     * Method to get response of profile page.
     */
    public void makeRequest() {


        // Do not send request if coming from create page
        if (!isLoadingFromCreate) {
            mAppConst.getJsonResponseFromUrl(profilePageUrl, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) {
                    mBody = jsonObject;
                    checkSiteVideoPluginEnabled();
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mProgressBar.setVisibility(View.GONE);
                    SnackbarUtils.displaySnackbarLongWithListener(relMainLayout, message,
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


    private void getCoverMenuRequest() {
        String menuUrl = UrlUtil.GET_COVER_MENU_URL + "subject_id=" + page_id +
                "&subject_type=sitepage_page&special=both&cover_photo=" + cover_photo + "&profile_photo=" + profile_photo;

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
            }

            if (profilePhotoMenuArray != null && profilePhotoMenuArray.length() > 0) {
                mProfileImageMenus.setVisibility(View.VISIBLE);
                mProfileImageMenus.setText("\uf030");
            }
        }

    }


    /**
     * This calling will return sitevideoPluginEnabled to 1 if
     * 1. Adv Video plugin is integrated with Directory/Pages plugin
     * 2. And if there is any video uploaded in this page using Avd video
     * else it will return sitevideoPluginEnabled to 0
     */
    public void checkSiteVideoPluginEnabled() {

        String url = UrlUtil.IS_SITEVIDEO_ENABLED + "?subject_id=" + mContentId + "&subject_type=sitepage_page";
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
     *
     * @param bodyJsonObject jsonObject, which contains view page data.
     */
    @SuppressLint("NewApi")
    private void loadViewPageData(JSONObject bodyJsonObject) {

        if (bodyJsonObject != null && bodyJsonObject.length() != 0) {

            try {
                mGutterMenus = bodyJsonObject.optJSONArray("gutterMenu");
                title = bodyJsonObject.optString("title");
                ownerId = bodyJsonObject.optInt("owner_id");
                mContentId = page_id = bodyJsonObject.optInt("page_id");
                coverImage = bodyJsonObject.optString("image");
                mContentUrl = bodyJsonObject.optString("content_url");
                isPageClosed = bodyJsonObject.optInt("closed");
                isLiked = bodyJsonObject.optBoolean("is_like");

                profileImageUrl = bodyJsonObject.getString("image");
                coverImageUrl = bodyJsonObject.optString("cover_image");

                likeCount = bodyJsonObject.optInt("like_count");
                commentCount = bodyJsonObject.optInt("comment_count");

                reviewCount = bodyJsonObject.optInt("review_count");
                sIsPageFollowed = bodyJsonObject.optInt("isPageFollowed");


                //new implementation
                isOwner = bodyJsonObject.optBoolean("isFollowing");
                ownerImageUrl = bodyJsonObject.optString("owner_image");
                ownerName = bodyJsonObject.optString("owner_title");
                rating = bodyJsonObject.optInt("rating");
                price = bodyJsonObject.optInt("price");
                categoryName = bodyJsonObject.optString("category_title");
                phoneNumber = bodyJsonObject.optString("phone");

//                try {
//                    phoneNumber = Integer.parseInt(number.replaceAll(" ",""));
//                }
//                catch (NumberFormatException e){
//                    LogUtils.LOGV("PageResponse","NumberFormatException: ");
//                }
                location = bodyJsonObject.optString("location");
                detailString = bodyJsonObject.optString("body");
                websiteUrl = bodyJsonObject.optString("website");
//                LogUtils.LOGV("PageResponse","Website Url: "+websiteUrl+" phone: "+number);
                mContentTitle.setText(title);
                showSmallTextWithShowLessString(detailString, detailTextView);
                authorName.setText(getString(R.string.by_label_text) + " " + ownerName);
                categoryTextView.setText(categoryName);
                likeCountTextView.setText(String.valueOf(likeCount));
                bottomButtonLayout.setVisibility(View.VISIBLE);
                rootLayout.setVisibility(View.VISIBLE);
                mProgressBar.setVisibility(View.GONE);
                mSlidingTabs.setVisibility(View.VISIBLE);
                viewPager.setVisibility(View.VISIBLE);
                mContentTitle.setVisibility(View.VISIBLE);
                authorName.setVisibility(View.VISIBLE);
                categoryTextView.setVisibility(View.VISIBLE);
                priceTextView.setVisibility(View.VISIBLE);
                ratingBar.setVisibility(View.VISIBLE);
                ratingCountTextView.setVisibility(View.VISIBLE);
                upperButtonLayout.setVisibility(View.VISIBLE);
                detailsLabelTextView.setVisibility(View.VISIBLE);
                mapsLayout.setVisibility(View.VISIBLE);
                detailTextView.setVisibility(View.VISIBLE);
                horizontalView1.setVisibility(View.VISIBLE);
                horizontalView2.setVisibility(View.VISIBLE);

                if (PreferencesUtils.getUserDetail(mContext) == null) {
                    upperButtonLayout.setVisibility(View.GONE);
                    bottomButtonLayout.setVisibility(View.GONE);
                    horizontalView2.setVisibility(View.INVISIBLE);
                    horizontalView1.setVisibility(View.INVISIBLE);
                }

                Drawable likedIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_thumb_up_24dp).mutate();
                int iconColor;
                if (isLiked) {
                    iconColor = ContextCompat.getColor(mContext, R.color.themeButtonColor);
                } else {
                    iconColor = ContextCompat.getColor(mContext, R.color.icon_grey_color);
                }
                likedIcon.setColorFilter(iconColor, PorterDuff.Mode.SRC_ATOP);
                likeCountTextView.setCompoundDrawablesWithIntrinsicBounds(null, likedIcon, null, null);

                if (!location.equals("null") && !location.isEmpty()) {
                    locationTextView.setText(location);

                } else {
                    mapsLayout.setVisibility(View.GONE);
                }

                if (rating > 0) {

                    ratingBar.setRating(rating);
                    ratingCountTextView.setText("(" + String.valueOf(reviewCount) + ")");


                } else {
                    ratingBar.setVisibility(View.INVISIBLE);
                    ratingCountTextView.setVisibility(View.INVISIBLE);
                }

                if (price > 0) {
                    priceTextView.setText(price + "$");
                    priceTextView.setVisibility(View.VISIBLE);
                } else {
                    priceTextView.setVisibility(View.INVISIBLE);
                    onwardsLabelTextView.setVisibility(View.INVISIBLE);
                }

                if (TextUtils.isEmpty(websiteUrl) || !android.util.Patterns.WEB_URL.matcher(websiteUrl).matches()) {

                    visitSiteTextView.setTextColor(getResources().getColor(R.color.extralightgrey));
                    for (Drawable drawable : visitSiteTextView.getCompoundDrawables()) {
                        if (drawable != null) {
                            drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(visitSiteTextView.getContext(),
                                    R.color.extralightgrey), PorterDuff.Mode.SRC_IN));
                        }
                    }
                }


                Drawable callGreyIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_call_dark_black_24dp).mutate();
                int greyIconColor = ContextCompat.getColor(mContext, R.color.extralightgrey);
                Drawable calllWhiteIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_call_dark_black_24dp).mutate();
                Drawable emailWhiteIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_email_white_24dp).mutate();
                Drawable emailGreyIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_email_white_24dp).mutate();
                if (TextUtils.isEmpty(String.valueOf(phoneNumber)) || !Patterns.PHONE.matcher(String.valueOf(phoneNumber)).matches()) {

                    isPhoneNumberAdded = false;
                    callGreyIcon.setColorFilter(greyIconColor, PorterDuff.Mode.SRC_ATOP);
                    callTextView.setTextColor(greyIconColor);
                    callTextView.setCompoundDrawablesWithIntrinsicBounds(null, callGreyIcon, null, null);
                    msgCallTextView.setText(getResources().getString(R.string.call_label));
                    msgCallTextView.setTextColor(greyIconColor);
                    msgCallTextView.setCompoundDrawablesWithIntrinsicBounds(null, callGreyIcon, null, null);
                    emailWhiteIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.white), PorterDuff.Mode.SRC_ATOP);
                    callMsgBtn.setText(getResources().getString(R.string.message_label));
                    callMsgBtn.setCompoundDrawablesWithIntrinsicBounds(emailWhiteIcon, null, null, null);
                    emailGreyIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.icon_grey_color), PorterDuff.Mode.SRC_ATOP);
                    msgTextView.setCompoundDrawablesWithIntrinsicBounds(null, emailGreyIcon, null, null);

                } else {
                    isPhoneNumberAdded = true;
                    callTextView.setTextColor(getResources().getColor(R.color.black));
                    callGreyIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.icon_grey_color), PorterDuff.Mode.SRC_ATOP);
                    callTextView.setCompoundDrawablesWithIntrinsicBounds(null, callGreyIcon, null, null);

                    emailGreyIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.icon_grey_color), PorterDuff.Mode.SRC_ATOP);
                    msgTextView.setCompoundDrawablesWithIntrinsicBounds(null, emailGreyIcon, null, null);

                    calllWhiteIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.white), PorterDuff.Mode.SRC_ATOP);
                    callMsgBtn.setCompoundDrawablesWithIntrinsicBounds(calllWhiteIcon, null, null, null);

                    msgCallTextView.setCompoundDrawablesWithIntrinsicBounds(null, emailGreyIcon, null, null);
                }
                String messageOwnerUrl = null, messageOwnerTitle = null;
                if (mGutterMenus != null) {
                    for (int i = 0; i < mGutterMenus.length(); i++) {
                        JSONObject jsonObject = mGutterMenus.optJSONObject(i);
                        if (jsonObject.optString("name").toLowerCase().equals("messageowner")) {
                            messageOwnerUrl = AppConstant.DEFAULT_URL + jsonObject.optString("url");
                            messageOwnerTitle = jsonObject.optString("label");

                            mGutterMenus.remove(i);
                        } else {
                            if (jsonObject.optString("name").equals("follow") || jsonObject.optString("name").equals("unfollow")) {
                                newFollowUrl = AppConstant.DEFAULT_URL + jsonObject.optString("url");

                            }

                            JSONObject jsonObj = mGutterMenus.optJSONObject(i);
                            if (!jsonObj.optString("name").toLowerCase().equals("messageowner")) {
                                newGutterMenu.put(jsonObj);

                            }
                        }

                        if (jsonObject.optString("name").contains("review")) {
                            isReviewEnabled = true;
                        }
                    }
                    invalidateOptionsMenu();
                }


                mProfileTabs = bodyJsonObject.optJSONArray("profile_tabs");
                mBrowseList = new BrowseListItems(page_id, title, coverImage, mContentUrl, isPageClosed, 0, 0);

                // Used for message.
                mBrowseList.setUserId(bodyJsonObject.optInt("owner_id"));
                mBrowseList.setUserDisplayName(bodyJsonObject.optString("owner_title"));
                mBrowseList.setUserProfileImageUrl(bodyJsonObject.optString("owner_image_normal"));
                if (messageOwnerTitle == null) {
                    msgTextView.setVisibility(View.GONE);
                    msgTextView.setEnabled(false);
                    if (isPhoneNumberAdded) {
                        msgCallTextView.setAlpha(0.2f);
                        msgCallTextView.setEnabled(false);
                    } else {
                        callMsgBtn.setAlpha(0.2f);
                        callMsgBtn.setEnabled(false);
                    }
                }
                mBrowseList.setMessageOwnerUrl(messageOwnerUrl);
                mBrowseList.setMessageOwnerTitle(messageOwnerTitle);

//                isReviewEnabled = PreferencesUtils.getSiteReviewSettings(this);
                if (!isReviewEnabled) {
                    reviewTextView.setVisibility(View.GONE);
                } else {
                    reviewTextView.setVisibility(View.VISIBLE);
                }
                bundle = new Bundle();
                bundle.putString(ConstantVariables.RESPONSE_OBJECT, bodyJsonObject.toString());
                bundle.putInt(ConstantVariables.CONTENT_ID, mContentId);
                bundle.putString(ConstantVariables.SUBJECT_TYPE, "sitepage_page");
                bundle.putInt(ConstantVariables.SUBJECT_ID, page_id);
                bundle.putString(ConstantVariables.CONTENT_TITLE, title);
                bundle.putInt(ConstantVariables.VIEW_PAGE_ID, mContentId);
                bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.SITE_PAGE_MENU_TITLE);
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

                    // Showing the alert dialog once when page is closed.
                    if (isPageClosed == 1) {
                        mAlertDialogWithAction.showDialogForClosedContent(title,
                                mContext.getResources().getString(R.string.page_closed_msg));
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

                        }

                        @Override
                        public void onPageScrollStateChanged(int state) {
                        }
                    });
                }
//                Setting data in views

                if (bodyJsonObject.has("default_cover")) {
                    mProfileImage.setVisibility(View.VISIBLE);
                    defaultCover = bodyJsonObject.optInt("default_cover");

                    //Showing profile image.
                    if (profileImageUrl != null && !profileImageUrl.isEmpty()) {
                        mProfileImage.setVisibility(View.VISIBLE);
                        mImageLoader.setImageForUserProfile(profileImageUrl, mProfileImage);
                    }

                    //Showing Cover image.
                    if (coverImageUrl != null && !coverImageUrl.isEmpty()) {
                        cover_photo = defaultCover == 1 ? 0 : 1;
                        mImageLoader.setCoverImageUrl(coverImageUrl, mCoverImage);
                    }
                    profile_photo = bodyJsonObject.has("photo_id") ? 1 : 0;
                    getCoverMenuRequest();

                    mProfilePhotoDetail.clear();
                    mPhotoDetails.clear();

                    mProfilePhotoDetail.add(new PhotoListDetails(profileImageUrl));
                    mPhotoDetails.add(new PhotoListDetails(coverImageUrl));

                } else {
                    mImageLoader.setImageUrl(profileImageUrl, mCoverImage);
                    mPhotoDetails.add(new PhotoListDetails(profileImageUrl));
                }

                mCoverImage.setOnClickListener(this);
                mProfileImage.setOnClickListener(this);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }


    /**
     * Method to open photolightbox when user click on view image
     *
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
        i.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.SITE_PAGE_MENU_TITLE);
        i.putExtras(bundle);
        startActivityForResult(i, ConstantVariables.VIEW_LIGHT_BOX);

    }

    private void startImageUploading() {
        Intent intent = new Intent(mContext, PhotoUploadingActivity.class);
        intent.putExtra("selection_mode", true);
        intent.putExtra(ConstantVariables.IS_PHOTO_UPLOADED, true);
        startActivityForResult(intent, ConstantVariables.PAGE_EDIT_CODE);
    }

    /**
     * Method to set like and comment count in bottom bar.
     */
    public void setLikeAndCommentCount() {

        if (mAppConst.isLoggedOutUser() || (viewPager != null && viewPager.getCurrentItem() == 1)) {

        } else {

            // setting up the values in views
            mLikeCommentContent.setVisibility(View.VISIBLE);

            mLikeUnlikeText.setActivated(isLiked);
            if (!isLiked) {
                mLikeUnlikeText.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark));
            } else {
                mLikeUnlikeText.setTextColor(ContextCompat.getColor(mContext, R.color.themeButtonColor));
            }

            /*
            Set Like and Comment Count
             */
            // Check if Reactions is enabled, show that content reaction and it's icon here.
            if (mReactionsEnabled == 1 && mReactionsObject != null && mReactionsObject.length() != 0) {


                myReaction = mReactionsObject.optJSONObject("my_feed_reaction");

                if (myReaction != null && myReaction.length() != 0) {
                    mLikeUnlikeText.setText(myReaction.optString("caption"));
                    String reactionImage = myReaction.optString("reaction_image_icon");
                    mImageLoader.setImageUrl(reactionImage, mReactionIcon);
                    mLikeUnlikeText.setCompoundDrawablesWithIntrinsicBounds(
                            null, null, null, null);
                    mReactionIcon.setVisibility(View.VISIBLE);
                } else {
                    mLikeUnlikeText.setCompoundDrawablesWithIntrinsicBounds(
                            ContextCompat.getDrawable(this, R.drawable.ic_thumb_up_white_18dp),
                            null, null, null);
                    mReactionIcon.setVisibility(View.GONE);
                    mLikeUnlikeText.setText(getString(R.string.like_text));
                }

            } else {
                mLikeUnlikeText.setCompoundDrawablesWithIntrinsicBounds(
                        ContextCompat.getDrawable(this, R.drawable.ic_thumb_up_white_18dp),
                        null, null, null);
                mLikeUnlikeText.setText(getString(R.string.like_text));
            }

            mLikeCountTextView.setText(String.valueOf(likeCount));
            mCommentCountTextView.setText(String.valueOf(commentCount));
        }
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
                        bottomButtonLayout.animate()
                                .translationY(bottomButtonLayout.getHeight())
                                .setInterpolator(new LinearInterpolator())
                                .setDuration(180);

                    } else if ((initialY - finalY) > 80) {
                        // Hide only when user scroll.
                        bottomButtonLayout.animate()
                                .translationY(0)
                                .setInterpolator(new LinearInterpolator())
                                .setDuration(180);
                    }
                }
                break;
        }

        return super.dispatchTouchEvent(event);
    }

    @Override
    public void onPointerCaptureChanged(boolean hasCapture) {

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
                        id, mGutterMenus);

            }


        }

        return super.onOptionsItemSelected(item);

    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        menu.clear();
        if (mGutterMenus != null) {
            mGutterMenuUtils.showOptionMenus(menu, mGutterMenus, ConstantVariables.SITE_PAGE_MENU_TITLE,
                    mBrowseList, ownerId);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public void onBackPressed() {
        if (!isFinishing()) {
            if (isContentEdited) {
                Intent intent = new Intent();
                setResult(ConstantVariables.VIEW_PAGE_CODE, intent);
            }
            super.onBackPressed();
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
        switch (resultCode) {
            case ConstantVariables.VIEW_PAGE_EDIT_CODE:
                isContentEdited = true;
                break;

            case ConstantVariables.PAGE_EDIT_CODE:
            case ConstantVariables.CREATE_REQUEST_CODE:
                if (mViewPageFragmentAdapter != null) {
                    mViewPageFragmentAdapter.updateData(bundle, mProfileTabs, false, true);
                }
                if (requestCode == ConstantVariables.PAGE_EDIT_CODE
                        && resultCode == ConstantVariables.PAGE_EDIT_CODE && data != null) {
                    ArrayList<String> resultList = data.getStringArrayListExtra(ConstantVariables.PHOTO_LIST);
                    String postUrl = UrlUtil.UPLOAD_COVER_PHOTO_URL + "subject_type=sitepage_page" +
                            "&subject_id=" + page_id;
                    if (isCoverRequest) {
                        successMessage = mContext.getResources().getString(R.string.cover_photo_updated);
                    } else {
                        postUrl = postUrl + "&special=profile";
                        successMessage = mContext.getResources().getString(R.string.profile_photo_updated);
                    }
                    new UploadFileToServerUtils(SitePageProfileActivity.this, postUrl, resultList, this).execute();
                }
                break;

            case ConstantVariables.FEED_REQUEST_CODE:
                /* Reset the view pager adapter if any status is posted using AAF */
                if (viewPager != null) {
                    viewPager.setAdapter(mViewPageFragmentAdapter);
                }
                break;

            case ConstantVariables.VIEW_COMMENT_PAGE_CODE:
                if (data != null) {
                    commentCount = data.getIntExtra(ConstantVariables.PHOTO_COMMENT_COUNT, commentCount);
                    mCommentCountTextView.setText(String.valueOf(commentCount));
                }
                break;

            case ConstantVariables.VIEW_PAGE_CODE:
                if (requestCode == ConstantVariables.ADD_VIDEO_CODE) {
                    isAdapterSet = false;
                    makeRequest();
                }
                break;
        }
    }


    @Override
    public void onClick(View view) {

        int id = view.getId();
        Intent intent;
        switch (id) {
            case R.id.likeBlock:
                int reactionId = 0;
                String reactionIcon = null, caption = null;

                if (mReactionsEnabled == 1 && mAllReactionObject != null) {
                    reactionId = mAllReactionObject.optJSONObject("like").optInt("reactionicon_id");
                    reactionIcon = mAllReactionObject.optJSONObject("like").optJSONObject("icon").
                            optString("reaction_image_icon");
                    caption = mContext.getResources().getString(R.string.like_text);
                }

                break;

            case R.id.likeCommentBlock:
                String mLikeCommentsUrl = AppConstant.DEFAULT_URL + "likes-comments?subject_type=sitepage_page" +
                        "&subject_id=" + page_id + "&viewAllComments=1&page=1&limit=20";
                intent = new Intent(mContext, Comment.class);
                intent.putExtra(ConstantVariables.LIKE_COMMENT_URL, mLikeCommentsUrl);
                intent.putExtra(ConstantVariables.SUBJECT_TYPE, "sitepage_page");
                intent.putExtra(ConstantVariables.SUBJECT_ID, page_id);
                intent.putExtra("commentCount", commentCount);
                intent.putExtra("reactionsEnabled", mReactionsEnabled);
                if (mContentReactions != null) {
                    intent.putExtra("popularReactions", mContentReactions.toString());
                }
                startActivityForResult(intent, ConstantVariables.VIEW_COMMENT_PAGE_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.messageBlock:
            case R.id.msg_text_view:
                GlobalFunctions.messageOwner(mContext, ConstantVariables.SITE_PAGE_MENU_TITLE, mBrowseList);
                break;


            case R.id.call_btn:

                if (!isPhoneNumberAdded) {

                    GlobalFunctions.messageOwner(mContext, ConstantVariables.SITE_PAGE_MENU_TITLE, mBrowseList);
                } else {

                    if (!TextUtils.isEmpty(phoneNumber) || phoneNumber != null) {
                        String phone = String.valueOf(phoneNumber);
                        Intent callIntent = new Intent(Intent.ACTION_DIAL, Uri.fromParts("tel", phone, null));
                        startActivity(callIntent);

                    }

                }
                break;

            case R.id.msg_txtview_btn:
                if (isPhoneNumberAdded) {
                    GlobalFunctions.messageOwner(mContext, ConstantVariables.SITE_PAGE_MENU_TITLE, mBrowseList);
                }
                break;

            case R.id.call_text_view:
                if (!TextUtils.isEmpty(phoneNumber) || phoneNumber != null) {
                    String phone = String.valueOf(phoneNumber);
                    Intent callIntent = new Intent(Intent.ACTION_DIAL, Uri.fromParts("tel", phone, null));
                    startActivity(callIntent);

                }
                break;

            case R.id.visit_txtview_btn:
                if (!TextUtils.isEmpty(websiteUrl)) {

                    if (android.util.Patterns.WEB_URL.matcher(websiteUrl).matches()) {
                        Intent webViewIntent;
                        if (ConstantVariables.WEBVIEW_ENABLE == 1) {
                            webViewIntent = new Intent(mContext, WebViewActivity.class);
                            webViewIntent.putExtra("url", websiteUrl);
                            webViewIntent.putExtra("isFromDirectoryProfilePage", true);

                        } else {
                            webViewIntent = new Intent(Intent.ACTION_VIEW);
                            webViewIntent.setData(Uri.parse(websiteUrl));
                        }
                        startActivity(webViewIntent);
                    }
                }
                break;


            case R.id.review_text_view:
                onButtonsClicked(reviewTextView, 0, mGutterMenus, false, false, "");
                break;

            case R.id.like_count_text_view:
                mAppConst.showProgressDialog();
                doLike();
                if (!isLiked && sIsPageFollowed == 0) {
                    follow();
                }
                break;

            case R.id.map_launch_imageview:
            case R.id.map_location_text_view:
                if (!location.isEmpty()) {
                    Intent mapIntent = new Intent(android.content.Intent.ACTION_VIEW,
                            Uri.parse("google.navigation:q=" + location));
                    startActivity(mapIntent);

                }
                break;

            case R.id.profile_image_view:
                if (profileImageUrl != null && !profileImageUrl.isEmpty() &&
                        profilePhotoMenuArray != null && profilePhotoMenuArray.length() > 0) {
                    isCoverRequest = false;
                    mGutterMenuUtils.showPopup(mProfileImageMenus, profilePhotoMenuArray,
                            mBrowseList, ConstantVariables.SITE_PAGE_MENU_TITLE);
                } else {
                    openLightBox(false);
                }
                break;

            case R.id.coverImage:
                if (PreferencesUtils.getSiteContentCoverPhotoEnabled(mContext) == 1 &&
                        coverPhotoMenuArray != null && coverPhotoMenuArray.length() > 0) {
                    isCoverRequest = true;
                    mGutterMenuUtils.showPopup(mCoverImageMenus, coverPhotoMenuArray,
                            mBrowseList, ConstantVariables.SITE_PAGE_MENU_TITLE);
                } else {
                    openLightBox(true);
                }
                break;

        }

    }


    private void doLike() {
        final Map<String, String> likeParams = new HashMap<>();
        likeParams.put(ConstantVariables.SUBJECT_TYPE, "sitepage_page");
        likeParams.put(ConstantVariables.SUBJECT_ID, String.valueOf(mContentId));
        likeParams.put("reaction", "like");


        if (!isLiked) {
            newLikeUrl = AppConstant.DEFAULT_URL + "like";
            mAppConst.postJsonResponseForUrl(newLikeUrl, likeParams, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                    Drawable likedIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_thumb_up_24dp);
                    likedIcon.mutate();
                    likedIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor), PorterDuff.Mode.SRC_ATOP);
                    likeCountTextView.setCompoundDrawablesWithIntrinsicBounds(null, likedIcon, null, null);


                    String likeCount = likeCountTextView.getText().toString();
                    likeCountTextView.setText(Integer.parseInt(likeCount) + 1 + "");
                    isLiked = true;
                    mAppConst.hideProgressDialog();

                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mAppConst.hideProgressDialog();
                    if (isRetryOption) {
                        doLike();
                    }
                }
            });
        } else {
            newLikeUrl = AppConstant.DEFAULT_URL + "unlike";
            mAppConst.postJsonResponseForUrl(newLikeUrl, likeParams, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    Drawable likedIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_thumb_up_24dp);
                    likedIcon.mutate();
                    likedIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.icon_grey_color), PorterDuff.Mode.SRC_ATOP);
                    likeCountTextView.setCompoundDrawablesWithIntrinsicBounds(null, likedIcon, null, null);

                    String likeCount = likeCountTextView.getText().toString();
                    likeCountTextView.setText(Integer.parseInt(likeCount) - 1 + "");
                    mAppConst.hideProgressDialog();
                    isLiked = false;
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mAppConst.hideProgressDialog();
                    SnackbarUtils.displaySnackbar(relMainLayout, getResources().getString(R.string.unable_to_like) + message);
                }
            });
        }

    }


    @Override
    public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
        CustomViews.showMarqueeTitle(verticalOffset, collapsingToolbar, mToolbar, mToolBarTitle, title);
    }

    @Override
    public void onItemDelete(String successMessage) {
        // Show Message
        SnackbarUtils.displaySnackbarShortWithListener(relMainLayout, successMessage,
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
    public boolean onLongClick(View v) {
        int[] location = new int[2];
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

        if (mAllReactionObject != null && mReactionsArray != null) {

            reactionsImages = new ArrayList<>();
            for (int i = 0; i < mReactionsArray.size(); i++) {
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
                            if (myReaction != null) {
                                if (myReaction.optInt("reactionicon_id") != reactionId) {
                                    doLikeUnlike(reaction, true, reactionId, reactionIcon, caption);
                                }
                            } else {
                                doLikeUnlike(reaction, false, reactionId, reactionIcon, caption);
                            }
                        }
                    });

            reactionsRecyclerView.setAdapter(reactionsAdapter);
        }
        return true;
    }

    private void doLikeUnlike(String reaction, final boolean isReactionChanged, final int reactionId,
                              final String reactionIcon, final String caption) {

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
        likeParams.put(ConstantVariables.SUBJECT_TYPE, "sitepage_page");
        likeParams.put(ConstantVariables.SUBJECT_ID, String.valueOf(mContentId));

        if (reaction != null) {
            likeParams.put("reaction", reaction);
        }

        if (!isLiked || isReactionChanged) {
            if (mReactionsEnabled == 1 && PreferencesUtils.isNestedCommentEnabled(mContext)) {
                mLikeUnlikeUrl = AppConstant.DEFAULT_URL + "advancedcomments/like?sendNotification=0";
            } else {
                mLikeUnlikeUrl = AppConstant.DEFAULT_URL + "like";
            }
        } else {
            mLikeUnlikeUrl = AppConstant.DEFAULT_URL + "unlike";
        }

        mAppConst.postJsonResponseForUrl(mLikeUnlikeUrl, likeParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                mLikeUnlikeText.setTypeface(null);
                // Set My FeedReaction Changed
                if (mReactionsEnabled == 1) {
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
                if (!isLiked) {
                    likeCount += 1;
                } else if (!isReactionChanged) {
                    likeCount -= 1;
                }

                // Toggle isLike Variable if reaction is not changed
                if (!isReactionChanged)
                    isLiked = !isLiked;

                setLikeAndCommentCount();
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mLikeUnlikeText.setTypeface(null);
                setLikeAndCommentCount();
                SnackbarUtils.displaySnackbar(findViewById(R.id.rel_main_layout), message);
            }

        });
    }

    private void updateContentReactions(int reactionId, String reactionIcon, String caption,
                                        boolean isLiked, boolean isReactionChanged) {

        try {

            // Update the count of previous reaction in reactions object and remove the my_feed_reactions
            if (isLiked && mReactionsObject != null) {
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


    @Override
    public void onOptionItemActionSuccess(Object itemList, String menuName) {
        mBrowseList = (BrowseListItems) itemList;
        switch (menuName) {
            case "follow":
            case "unfollow":
                sIsPageFollowed = (sIsPageFollowed == 0) ? 1 : 0;
                //Update the data inside fragment.
                if (mViewPageFragmentAdapter != null) {
                    mViewPageFragmentAdapter.updateData(bundle, mProfileTabs, true, false);
                }


                break;

            case "upload_cover_photo":
            case "upload_photo":
                if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
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
                bundle.putBoolean("isCoverRequest", isCoverRequest);
                bundle.putBoolean("isSitePageAlbums", true);
                bundle.putString(ConstantVariables.URL_STRING, AppConstant.DEFAULT_URL + "sitepage/photos/index/" + page_id);
                bundle.putString(ConstantVariables.SUBJECT_TYPE, ConstantVariables.SITE_PAGE_TITLE);
                bundle.putInt(ConstantVariables.SUBJECT_ID, page_id);
                bundle.putInt(ConstantVariables.VIEW_PAGE_ID, page_id);
                bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.SITE_PAGE_MENU_TITLE);
                Intent newIntent = new Intent(mContext, FragmentLoadActivity.class);
                newIntent.putExtras(bundle);
                startActivityForResult(newIntent, ConstantVariables.PAGE_EDIT_CODE);
                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case "view_profile_photo":
            case "view_cover_photo":
                openLightBox(isCoverRequest);
                break;

            case "remove_cover_photo":
            case "remove_photo":
                mProgressBar.setVisibility(View.VISIBLE);
                mProgressBar.bringToFront();
                isLoadingFromCreate = false;
                makeRequest();
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
            SnackbarUtils.displaySnackbarLongTime(relMainLayout, successMessage);
            mProgressBar.setVisibility(View.VISIBLE);
            mProgressBar.bringToFront();
            makeRequest();

        } else {
            SnackbarUtils.displaySnackbarLongTime(relMainLayout, jsonObject.optString("message"));
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {

        switch (requestCode) {
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, proceed to the normal flow.
                    startImageUploading();
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
                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, relMainLayout,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);
                    }
                }
                break;

        }
    }

    private void setUpTabs() {

        // Setup the Tabs
        viewPager = (ViewPager) findViewById(R.id.pager);
        mSlidingTabs = (TabLayout) findViewById(R.id.slidingTabs);
        mProgressBar = (ProgressBar) findViewById(R.id.progressBar);
        mCoverImage = (ImageView) findViewById(R.id.coverImage);
        mContentTitle = (TextView) findViewById(R.id.profile_name_text_view);
        mProfileImage = findViewById(R.id.profile_image_view);

    }

    private void setUpToolBar() {


        /* Create Back Button On Action Bar **/
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(mToolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(getResources().getString(R.string.blank_string));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
    }


    private Map<String, String> mPostParams;

    public void onButtonsClicked(View view, int id, JSONArray menuArray, boolean isBrowsePage,
                                 boolean isRequestFromViewPage, String currentList) {
        String mMenuName = null;
        String mRedirectUrl = AppConstant.DEFAULT_URL + "sitepage/reviews/create/" + mContentId;
        Intent intent;
        intent = new Intent(mContext, CreateNewEntry.class);
        intent.putExtra(ConstantVariables.CREATE_URL, mRedirectUrl);
        intent.putExtra(ConstantVariables.FORM_TYPE, "create_review");
        intent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.SITE_PAGE_MENU_TITLE);
        intent.putExtra(ConstantVariables.REQUEST_CODE, ConstantVariables.CREATE_REQUEST_CODE);
        ((Activity) mContext).startActivityForResult(intent, ConstantVariables.CREATE_REQUEST_CODE);
        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);


    }

    @Override
    public void onScrollChanged(int scrollY, boolean firstScroll, boolean dragging) {

        if (mViewPageFragmentAdapter == null) {
            return;
        }
        int baseColor = ContextCompat.getColor(this, R.color.colorPrimary);
        float alpha = Math.min(1, (float) scrollY / mParallaxImageHeight);

        int[] location = new int[2];
        mSlidingTabs.getLocationOnScreen(location);
        int position = mToolbar.getHeight() + (int) mSlidingTabs.getHeight() + iStatusBarHeight;

        BaseFragment baseFragment = mViewPageFragmentAdapter.getFragment(viewPager.getCurrentItem());

        if (baseFragment != null) {
            if (position >= location[1]) {
                baseFragment.setNestedScrollingEnabled(true);
                alpha = 1.0f;
            } else {
                baseFragment.setNestedScrollingEnabled(false);
            }
        }
        mToolbar.setBackgroundColor(ScrollUtils.getColorWithAlpha(alpha, baseColor));

    }

    @Override
    public void onDownMotionEvent() {

    }

    @Override
    public void onUpOrCancelMotionEvent(ScrollState scrollState) {

    }

    private void showSmallTextWithShowLessString(final String detailString, TextView tv) {
        if (detailString.length() > 200) {
            String newString = detailString.substring(0, 200);
            String mDisplayString = newString + " " + getResources().getString(R.string.see_more);

            SpannableString ss = new SpannableString(mDisplayString);
            int mStartIndex = mDisplayString.length() - getResources().getString(R.string.see_more).length();
            int mEndIndex = mDisplayString.length();

            ClickableSpan clickableSpan = new ClickableSpan() {
                @Override
                public void onClick(View textView) {
                    showFullTextWithShowLessString(detailString, tv);
                }

                @Override
                public void updateDrawState(TextPaint ds) {
                    super.updateDrawState(ds);
                    ds.setUnderlineText(false);
                    ds.setColor(ContextCompat.getColor(mContext, R.color.red));
                    ds.setFakeBoldText(true);
                }
            };
            ss.setSpan(clickableSpan, mStartIndex, mEndIndex, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            tv.setText(ss);
            tv.setMovementMethod(LinkMovementMethod.getInstance());
            tv.setHighlightColor(Color.TRANSPARENT);

        } else {
            tv.setText(detailString);
        }


    }

    private void showFullTextWithShowLessString(final String mFullString, TextView tv) {
        String mDisplayString = mFullString + " " + getResources().getString(R.string.readLess);
        SpannableString ss = new SpannableString(mDisplayString);
        int mStartIndex = mDisplayString.length() - getResources().getString(R.string.readLess).length();
        int mEndIndex = mDisplayString.length();
        ClickableSpan clickableSpan = new ClickableSpan() {
            @Override
            public void onClick(View textView) {
                showSmallTextWithShowLessString(mFullString, tv);
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setUnderlineText(false);
                ds.setColor(ContextCompat.getColor(mContext, R.color.red));
                ds.setFakeBoldText(true);
            }
        };
        ss.setSpan(clickableSpan, mStartIndex, mEndIndex, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv.setText(ss);
        tv.setMovementMethod(LinkMovementMethod.getInstance());
        tv.setHighlightColor(Color.TRANSPARENT);

    }
}
