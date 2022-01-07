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

package com.socialengineaddons.mobileapp.classes.modules.album;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.AppBarLayout;
import android.support.design.widget.CollapsingToolbarLayout;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.ImageAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.StaggeredGridAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnOptionItemClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnSheetItemClickListner;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUserLayoutClickListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.ActionIconThemedTextView;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.DeepLinksHandler;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.common.adapters.CustomImageAdapter;
import com.socialengineaddons.mobileapp.classes.common.ui.SplitToolbar;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageViewList;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.modules.likeNComment.Comment;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoLightBoxActivity;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;
import com.socialengineaddons.mobileapp.classes.modules.store.utils.SheetItemModel;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AlbumView extends AppCompatActivity implements View.OnClickListener,
        AppBarLayout.OnOffsetChangedListener, OnOptionItemClickResponseListener,
        OnUploadResponseListener, DeepLinksHandler, OnSheetItemClickListner {


    private Context mContext;
    private Activity mActivity;
    private AppConstant mAppConst;
    private GutterMenuUtils mGutterMenuUtils;
    private BrowseListItems mBrowseList;
    private String mItemViewUrl,mRequestMoreDataUrl,normalImgUrl, redirectUrl;
    private String mLoadingImageUrl;
    private JSONArray mDataResponseArray,mGutterMenus, mViewPrivacy;
    private JSONObject mDataResponse,mBody,mAlbumResponseObject, privacyObject;

    private int columnWidth,mTotalItemCount;
    private String  actionUrl, successMessage;
    private String title,body,owner_image,owner_title,creation_date,convertedDate,albumCover,privacyValue, viewPrivacy;
    private int view_count,mCommentCount, mLikeCount;
    private boolean isLoadingFromCreate = false, isLoading = false, isContentEdited = false, isContentDeleted = false, isScroll = false;
    private int mTotalPhotoCount, canEdit = 0, mLoadingPageNo = 1;
    private int mContent_id, mUserId;
    private String mSubjectType, mModuleName, mPhotoSubjectType;
    private int mSubjectId;
    private ImageView coverImageView;
    private List<ImageViewList> mPhotoUrls;
    private ArrayList<PhotoListDetails> mPhotoDetails, mCoverImageDetails;
    private Map<String, String> postParams;
    private ImageViewList mGridViewImages;
    private RecyclerView mRecyclerView;
    private StaggeredGridLayoutManager mStaggeredLayoutManager;
    private CustomImageAdapter recyclerViewAdapter;
    private FrameLayout mCoverImageLayout;
    private CollapsingToolbarLayout collapsingToolbarLayout;
    private CoordinatorLayout mMainLayout;
    private Typeface fontIcon;
    private boolean isLike, mIsCoverRequest;
    private String mContentUrl;
    private ArrayList<String> mSelectPath;
    private Toolbar mToolbar;
    private SplitToolbar mBottomToolBar;
    private Bundle bundle;
    private TextView mToolBarTitle;
    private AppBarLayout appBar;
    private JSONObject mReactionsObject, mAllReactionObject, mContentReactions;
    private int mReactionsEnabled;
    private AlertDialogWithAction mAlertDialogWithAction;
    private ArrayList<JSONObject> mReactionsArray;
    private ImageLoader mImageLoader;
    private FloatingActionButton mFabCreate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_album_view);


        /* Create Back Button On Action Bar **/

        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mToolBarTitle = (TextView) findViewById(R.id.toolbar_title);
        mToolBarTitle.setSelected(true);
        setSupportActionBar(mToolbar);
        if(getSupportActionBar() != null) {
            getSupportActionBar().setTitle(getResources().getString(R.string.blank_string));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        mActivity = this;
        mContext = this;

        //Creating a new instance of AppConstant class
        mAppConst = new AppConstant(this);
        mBrowseList = new BrowseListItems();
        mGutterMenuUtils = new GutterMenuUtils(this);
        mGutterMenuUtils.setOnOptionItemClickResponseListener(this);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        mImageLoader = new ImageLoader(getApplicationContext());

        postParams = new HashMap<>();
        //setting up font icons
        fontIcon = GlobalFunctions.getFontIconTypeFace(mContext);

        mContent_id = getIntent().getIntExtra(ConstantVariables.VIEW_PAGE_ID, 0);
        mModuleName = getIntent().getStringExtra(ConstantVariables.EXTRA_MODULE_TYPE);
        mPhotoSubjectType= getIntent().getStringExtra(ConstantVariables.SUBJECT_TYPE);

        if(mModuleName != null){
            switch (mModuleName){
                case ConstantVariables.SITE_PAGE_MENU_TITLE:
                    mSubjectType = "sitepage_album";
                    mPhotoSubjectType = "sitepage_photo";
                    break;
                case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                    mSubjectType = "sitegroup_album";
                    mPhotoSubjectType = "sitegroup_photo";
                    break;
                case ConstantVariables.STORE_MENU_TITLE:
                    mSubjectType = "sitestore_album";
                    mPhotoSubjectType = "sitestore_photo";
                    break;
                default:
                    mSubjectType = "album";
                    break;
            }
        }else if (mPhotoSubjectType != null && !mPhotoSubjectType.isEmpty()) {
            mSubjectType = mPhotoSubjectType.replace("_photo", "_album");
        } else {
            mSubjectType = "album";
        }

        mSubjectId = mContent_id;

        // For the user profile and cover photo update.
        bundle = getIntent().getExtras();
        if (bundle != null && bundle.getBundle(ConstantVariables.USER_PROFILE_COVER_BUNDLE) != null) {
            bundle = bundle.getBundle(ConstantVariables.USER_PROFILE_COVER_BUNDLE);
            mIsCoverRequest = bundle.getBoolean("isCoverRequest", false);
        } else {
            bundle = null;
        }

        // If response coming from create page.
        mBody = GlobalFunctions.getCreateResponse(getIntent().getStringExtra(ConstantVariables.EXTRA_CREATE_RESPONSE));

        //Getting all the views
        mMainLayout = (CoordinatorLayout) findViewById(R.id.main_content);
        mCoverImageLayout = (FrameLayout) findViewById(R.id.cover_image_layout);
        coverImageView = (ImageView) findViewById(R.id.backdropImage);
        mRecyclerView = (RecyclerView) findViewById(R.id.recyclerView);
        mBottomToolBar = (SplitToolbar) findViewById(R.id.toolbarBottom);
        appBar = (AppBarLayout) findViewById(R.id.appbar);
        appBar.addOnOffsetChangedListener(this);
        collapsingToolbarLayout = (CollapsingToolbarLayout) findViewById(R.id.collapsing_toolbar);
        mFabCreate = (FloatingActionButton) findViewById(R.id.create_fab);
        mFabCreate.setOnClickListener(this);
        mFabCreate.hide();

        // Hiding cover image layout.
        if ((bundle != null && !bundle.isEmpty()) || mSubjectType.equals("sitereview_album")) {
            mCoverImageLayout.setVisibility(View.GONE);
        }

        InitializeGridLayout();

        mPhotoUrls = new ArrayList<>();
        mPhotoDetails = new ArrayList<>();
        mCoverImageDetails = new ArrayList<>();
        mGridViewImages = new ImageViewList();
        recyclerViewAdapter = new CustomImageAdapter(this, mGridViewImages, mPhotoUrls, columnWidth, bundle,
                mSubjectType, true, new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {

                // Uploading selected image as cover/profile photo.
                if (bundle != null && !bundle.isEmpty()) {
                    PhotoListDetails photoListDetails = mPhotoDetails.get(position + 1);
                    if (mIsCoverRequest) {
                        if (bundle.containsKey(ConstantVariables.SUBJECT_TYPE)) {
                            actionUrl = UrlUtil.UPLOAD_COVER_PHOTO_URL +  "subject_id="
                                    + bundle.getInt(ConstantVariables.SUBJECT_ID) + "&subject_type="
                                    + bundle.getString(ConstantVariables.SUBJECT_TYPE)
                                    + "&photo_id=" + photoListDetails.getPhotoId();
                        } else {
                            actionUrl =  UrlUtil.UPLOAD_USER_COVER_PHOTO_URL + "user_id/"
                                    + bundle.getInt("user_id") + "/photo_id/"
                                    + photoListDetails.getPhotoId() + "/special/cover";
                        }
                        successMessage = mContext.getResources().getString(R.string.cover_photo_updated);

                    } else {
                        if (bundle.containsKey(ConstantVariables.SUBJECT_TYPE)) {
                            actionUrl = UrlUtil.UPLOAD_COVER_PHOTO_URL + "special=profile&subject_id="
                                    + bundle.getInt(ConstantVariables.SUBJECT_ID) + "&subject_type="
                                    + bundle.getString(ConstantVariables.SUBJECT_TYPE) + "&photo_id="
                                    + photoListDetails.getPhotoId();
                        } else {
                            actionUrl = UrlUtil.UPLOAD_USER_COVER_PHOTO_URL + "user_id/"
                                    + bundle.getInt("user_id") + "/photo_id/"
                                    + photoListDetails.getPhotoId() + "/special/profile";
                        }
                        successMessage = mContext.getResources().getString(R.string.profile_photo_updated);
                    }

                    mAppConst.showProgressDialog();
                    mAppConst.postJsonResponseForUrl(actionUrl, postParams, new OnResponseListener() {
                        @Override
                        public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                            launchUserProfileOnSuccessOrError(successMessage);
                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                            launchUserProfileOnSuccessOrError(message);
                        }
                    });

                } else {
                    // on selecting grid view image
                    // launch full screen activity

                    // increasing position for the subject type = sitereview_album.
                    // because 1st position item i.e. header is hiding in this case.
                    if (mSubjectType.equals("sitereview_album")) {
                        position++;
                    }
                    Bundle bundle = new Bundle();
                    bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mPhotoDetails);
                    Intent i = new Intent(mActivity, PhotoLightBoxActivity.class);
                    i.putExtra(ConstantVariables.ITEM_POSITION, position);
                    i.putExtra(ConstantVariables.CAN_EDIT, canEdit);
                    i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, mTotalItemCount);
                    i.putExtra(ConstantVariables.PHOTO_REQUEST_URL, mRequestMoreDataUrl);
                    i.putExtra(ConstantVariables.IS_ALBUM_PHOTO_REQUEST, true);
                    i.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, mModuleName);
                    i.putExtra(ConstantVariables.SHOW_ALBUM_BUTTON, false);
                    i.putExtra(ConstantVariables.IS_ALBUM_VIEW, false);
                    i.putExtra(ConstantVariables.ALBUM_ID, mPhotoDetails.get(position).geAlbumId());
                    if(mPhotoSubjectType != null && !mPhotoSubjectType.isEmpty()){
                        i.putExtra(ConstantVariables.SUBJECT_TYPE, mPhotoSubjectType);
                    }
                    i.putExtras(bundle);
                    //TODO getting Parcelable encountered IOException writing serializable object
                    mActivity.startActivityForResult(i, ConstantVariables.VIEW_LIGHT_BOX);
                }
            }

        }, new OnUserLayoutClickListener() {

            @Override
            public void onUserLayoutClick() {

                Intent intent = new Intent(AlbumView.this, userProfile.class);
                intent.putExtra(ConstantVariables.USER_ID,mUserId);
                startActivityForResult(intent, ConstantVariables.USER_PROFILE_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            }
        });
        mRecyclerView.setAdapter(recyclerViewAdapter);

        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {

            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);

                int visibleItemCount = mStaggeredLayoutManager.getChildCount();
                int totalItemCount = mStaggeredLayoutManager.getItemCount();
                int pastVisibleItems = 0;
                int[] firstVisibleItems = null;
                firstVisibleItems = mStaggeredLayoutManager.findFirstVisibleItemPositions(firstVisibleItems);
                if(firstVisibleItems != null && firstVisibleItems.length > 0) {
                    pastVisibleItems = firstVisibleItems[0];
                }

                if (!isLoading && (visibleItemCount + pastVisibleItems) >= totalItemCount) {

                    if ((visibleItemCount + pastVisibleItems) >= AppConstant.LIMIT && (AppConstant.LIMIT * mLoadingPageNo)
                            < mGridViewImages.getTotalPhotoCount()) {
                        mPhotoUrls.add(null);
                        recyclerViewAdapter.notifyItemInserted(mPhotoUrls.size() - 1);
                        mLoadingPageNo = mLoadingPageNo + 1;
                        mLoadingImageUrl = mItemViewUrl + "&page=" + mLoadingPageNo;
                        isLoading = true;
                        isScroll = true;
                        mAppConst.getJsonResponseFromUrl(mLoadingImageUrl, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                                mPhotoUrls.remove(mPhotoUrls.size() - 1);
                                recyclerViewAdapter.notifyItemRemoved(mPhotoUrls.size());
                                mBody = jsonObject;
                                mDataResponseArray = mBody.optJSONArray("albumPhotos");
                                mTotalPhotoCount = mBody.optInt("totalPhotoCount");
                                canEdit = mBody.optInt("canEdit");
                                mGridViewImages.setTotalPhotoCount(mTotalPhotoCount);
                                loadMorePhotos();
                                recyclerViewAdapter.notifyItemInserted(mPhotoUrls.size());
                                isScroll = false;
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                            }
                        });
                    }
                }
            }
        });

        mItemViewUrl = getIntent().getStringExtra(ConstantVariables.VIEW_PAGE_URL);
        handleAppLinks();

        mReactionsEnabled = PreferencesUtils.getReactionsEnabled(mContext);
        /*
            Check if Reactions and nested comment plugin is enabled on the site
            send request to get the reactions on a particular content
            send this request only if the reactions Enabled is not saved yet in Preferences
             or if it is set to 1
         */
        if(mReactionsEnabled == 1 || mReactionsEnabled == -1){
            String getContentReactionsUrl = UrlUtil.CONTENT_REACTIONS_URL + "&subject_type=" + mSubjectType +
                    "&subject_id=" + mSubjectId;
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
                        PreferencesUtils.storeReactions(mContext, mAllReactionObject);
                        if(mAllReactionObject != null){
                            mReactionsArray = GlobalFunctions.sortReactionsObjectWithOrder(mAllReactionObject);
                        }
                    }

                    // Send Request to load View page data after fetching Reactions on the content.
                    if(mBody != null) {
                        isLoadingFromCreate = true;
                        isContentEdited = true;
                        makePhotoRequest();
                        setValuesInView();
                    }else {
                        makeRequest();
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    // Send Request to load View page data after fetching Reactions on the content.
                    if(mBody != null) {
                        isLoadingFromCreate = true;
                        isContentEdited = true;
                        makePhotoRequest();
                        setValuesInView();
                    }else {
                        makeRequest();
                    }
                }

            });
        } else{
            if(mBody != null) {
                isLoadingFromCreate = true;
                isContentEdited = true;
                makePhotoRequest();
                setValuesInView();
            }else {
                makeRequest();
            }
        }

    }

    /**
     * Method to launch user profile activity when photo uploaded successfully or there is an error.
     * @param successMessage success or error message
     */
    public void launchUserProfileOnSuccessOrError(String successMessage) {
        mAppConst.hideProgressDialog();
        SnackbarUtils.displaySnackbarLongWithListener(mMainLayout, successMessage,
                new SnackbarUtils.OnSnackbarDismissListener() {
                    @Override
                    public void onSnackbarDismissed() {
                        Intent intent;
                        if (bundle.containsKey(ConstantVariables.SUBJECT_TYPE)) {
                            intent = GlobalFunctions.getIntentForModule(mContext,
                                    bundle.getInt(ConstantVariables.SUBJECT_ID),
                                    bundle.getString(ConstantVariables.SUBJECT_TYPE), null);

                        } else {
                            intent = new Intent(mContext, userProfile.class);
                        }
                        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        intent.putExtras(bundle);
                        intent.putExtra(ConstantVariables.IS_PHOTO_UPLOADED, true);
                        startActivityForResult(intent, ConstantVariables.USER_PROFILE_CODE);
                        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                });
    }

    /**
     * Method to calculate the grid dimensions Calculates number columns and
     * columns width in grid
     * */
    private void InitializeGridLayout() {

        // Column width
        columnWidth = (mAppConst.getScreenWidth()/ AppConstant.NUM_OF_COLUMNS_FOR_VIEW_PAGE);
        // set a StaggeredGridLayoutManager with 3 number of columns and vertical orientation
        mStaggeredLayoutManager = new StaggeredGridLayoutManager(3, LinearLayoutManager.VERTICAL);
        mRecyclerView.setLayoutManager(mStaggeredLayoutManager);
        mRecyclerView.setItemAnimator(null);

    }

    public void makeRequest(){
        mLoadingPageNo = 1;
        findViewById(R.id.progressBar).bringToFront();
        if(!isLoadingFromCreate) {

            mAppConst.getJsonResponseFromUrl(mItemViewUrl, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) {
                    mBody = jsonObject;
                    makePhotoRequest();
                    setValuesInView();
                    if (isContentEdited) {
                        recyclerViewAdapter.notifyItemChanged(0);
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    findViewById(R.id.progressBar).setVisibility(View.GONE);
                    SnackbarUtils.displaySnackbarLongWithListener(mMainLayout, message,
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

    public void makePhotoRequest(){

        String url = UrlUtil.VIEW_PHOTOS_URL + "?subject_id=" + mSubjectId + "&subject_type=" + mSubjectType;
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                findViewById(R.id.progressBar).setVisibility(View.GONE);
                if(jsonObject != null){
                    mDataResponseArray = jsonObject.optJSONArray("albumPhotos");
                    mPhotoDetails.clear();
                    mPhotoUrls.clear();
                    loadMorePhotos();
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                findViewById(R.id.progressBar).setVisibility(View.GONE);
                SnackbarUtils.displaySnackbarLongWithListener(mMainLayout, message,
                    new SnackbarUtils.OnSnackbarDismissListener() {
                        @Override
                        public void onSnackbarDismissed() {
                            finish();
                        }
                    });
            }

        });
    }


    public void setValuesInView(){

        mRecyclerView.setVisibility(View.VISIBLE);

        try {

            // Parsing json object response
            // response will be a json object
            mDataResponse = mBody.optJSONObject("response");
            mGutterMenus = mBody.optJSONArray("gutterMenu");
            mViewPrivacy = mBody.optJSONArray("viewPrivacy");

            if (mDataResponse == null) {
                mDataResponseArray = mBody.optJSONArray("response");
                mDataResponse = mAppConst.convertToJsonObject(mDataResponseArray);
            }

            if (mGutterMenus != null) {
                invalidateOptionsMenu();
                for (int i = 0; i < mGutterMenus.length(); i++) {
                    try {
                        JSONObject mMenuJsonObject = mGutterMenus.getJSONObject(i);
                        if (mMenuJsonObject.optString("name").equals("add")) {
                            mFabCreate.show();
                            String albumId = mMenuJsonObject.optJSONObject("urlParams").optString("album_id");
                            this.redirectUrl = mAppConst.DEFAULT_URL + mMenuJsonObject.optString("url") + "?album_id=" + albumId;
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }

            mTotalPhotoCount = mBody.optInt("totalPhotoCount");
            canEdit = mBody.optInt("canEdit");
            mGridViewImages.setTotalPhotoCount(mTotalPhotoCount);
            mAlbumResponseObject = mBody.optJSONObject("album");

            // Checking if album is coming or not.
            if (mAlbumResponseObject != null) {
                mSubjectId = mAlbumResponseObject.optInt("album_id");
                mTotalItemCount = mBody.optInt("totalPhotoCount");
                view_count = mAlbumResponseObject.optInt("view_count");
                title = mAlbumResponseObject.optString("title");
                body = mAlbumResponseObject.optString("description");
                mCommentCount = mAlbumResponseObject.optInt("comment_count");
                mLikeCount = mAlbumResponseObject.optInt("like_count");
                isLike = mAlbumResponseObject.optBoolean("is_like");
                albumCover = mAlbumResponseObject.optString("image");
                owner_image = mAlbumResponseObject.optString("owner_image_icon");
                owner_title = mAlbumResponseObject.optString("owner_title");
                mUserId = mAlbumResponseObject.optInt("owner_id");
                creation_date = mAlbumResponseObject.optString("creation_date");
                convertedDate = AppConstant.convertDateFormat(getResources(), creation_date);
                mContentUrl = mAlbumResponseObject.optString("content_url");
                viewPrivacy = mAlbumResponseObject.optString("view_privacy");

            } else {
                mTotalItemCount = mBody.optInt("totalItemCount");
            }
            mBrowseList = new BrowseListItems(mSubjectId, title, albumCover, mContentUrl, redirectUrl);

            if (mViewPrivacy != null) {
                for (int i = 0; i < mViewPrivacy.length(); i++) {
                    try {
                        JSONObject mMenuJsonObject = mViewPrivacy.getJSONObject(i);
                        String name = mMenuJsonObject.optString("name");

                        if (name.equals("auth_view")) {
                            privacyObject = mMenuJsonObject.optJSONObject("multiOptions");
                            privacyValue = mMenuJsonObject.optString("value");

                            /* Set view privacy selected by user if it's available */
                            if (viewPrivacy != null && !viewPrivacy.isEmpty()) {
                                privacyValue = viewPrivacy;
                                viewPrivacy = privacyObject.optString(viewPrivacy);
                            }
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }

            mGridViewImages.setAlbumTitle(title);
            mGridViewImages.setAlbumCreationDate(creation_date);
            mGridViewImages.setAlbumViewPrivacy(viewPrivacy);
            mGridViewImages.setPrivacyObject(privacyObject);
            mGridViewImages.setPrivacyValue(privacyValue);
            mGridViewImages.setLikeCount(mLikeCount);
            mGridViewImages.setIsLike(isLike);
            mGridViewImages.setCommentCount(mCommentCount);
            mGridViewImages.setmReactionObject(mReactionsObject);
            mGridViewImages.setmAlbumGutterMenu(mGutterMenus);
            mGridViewImages.setmSubjectId(mSubjectId);
            mGridViewImages.setmAlbumCover(albumCover);
            mGridViewImages.setmContentUrl(mContentUrl);
            mGridViewImages.setmOwnerId(mUserId);

            mCoverImageDetails.add(new PhotoListDetails(albumCover));
            mImageLoader.setImageUrl(albumCover, coverImageView);

            coverImageView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Bundle bundle = new Bundle();
                    bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mCoverImageDetails);
                    Intent i = new Intent(mContext, PhotoLightBoxActivity.class);
                    i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, 1);
                    i.putExtra(ConstantVariables.SHOW_OPTIONS, false);
                    i.putExtras(bundle);
                    startActivity(i);
                }
            });

            collapsingToolbarLayout.setTitle(title);
            mToolBarTitle.setText(title);

        } catch (Exception e) {
            e.printStackTrace();
            SnackbarUtils.displaySnackbar(mMainLayout,
                    getResources().getString(R.string.no_data_available));
        }

    }

    public void loadMorePhotos(){

        if (mDataResponseArray != null) {
            for (int i = 0; i < mDataResponseArray.length(); i++) {
                JSONObject imageUrlsObj = mDataResponseArray.optJSONObject(i);
                String menuArray = imageUrlsObj.optString("menu");

                normalImgUrl = imageUrlsObj.optString("image");
                String image_title = imageUrlsObj.optString("title");
                String image_desc = imageUrlsObj.optString("description");
                int photo_id = imageUrlsObj.optInt("photo_id");
                int album_id = imageUrlsObj.optInt("album_id");
                int likeCount = imageUrlsObj.optInt("like_count");
                int commentCount = imageUrlsObj.optInt("comment_count");
                boolean likeStatus = imageUrlsObj.optBoolean("is_like");
                String contentUrl = imageUrlsObj.optString("content_url");
                if (imageUrlsObj.has("isLike")) {
                    likeStatus = imageUrlsObj.optBoolean("isLike");
                }
                String reactions = imageUrlsObj.optString("reactions");
                String mUserTagArray = imageUrlsObj.optString("tags");
                int albumId = imageUrlsObj.optInt("album_id");

                mRequestMoreDataUrl = AppConstant.DEFAULT_URL + "albums/photo/list?" +
                        "album_id="+album_id+"&limit=" + AppConstant.LIMIT;

                mPhotoDetails.add(new PhotoListDetails(title, owner_title,
                        image_title, image_desc, photo_id, normalImgUrl, likeCount,
                        commentCount, likeStatus, menuArray, reactions, mUserTagArray, contentUrl, null, albumId));
                mPhotoUrls.add(new ImageViewList(normalImgUrl));

                mGridViewImages.setAlbumDescription(body);
                mGridViewImages.setOwnerImageUrl(owner_image);
                mGridViewImages.setOwnerTitle(owner_title);

                isLoading = false;
            }
            if (!isScroll) {
                recyclerViewAdapter.notifyDataSetChanged();
            }
        }

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
        //noinspection SimplifiableIfStatement

        if (id == android.R.id.home) {
            onBackPressed();
            // Playing backSound effect when user tapped on back button from tool bar.
            if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
                SoundUtil.playSoundEffectOnBackPressed(mContext);
            }
        } else {

            if(mGutterMenus != null) {
                mGutterMenuUtils.onMenuOptionItemSelected(mMainLayout, findViewById(item.getItemId()),
                        id, mGutterMenus);
            }
        }
        return super.onOptionsItemSelected(item);
    }


    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {

        menu.clear();

        // Not showing the option menu when the request is for choose picture for profile/cover
        // or if the gutter menus null.
        if(mGutterMenus != null && bundle == null){
            mGutterMenuUtils.showOptionMenus(menu, mGutterMenus, ConstantVariables.ALBUM_MENU_TITLE,
                    mBrowseList);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public void onBackPressed() {
        if (!isFinishing()) {
        /*
        Set Result to Manage page to refresh the page if any changes made in the content.
         */
            if (isContentEdited || isLoadingFromCreate || isContentDeleted) {
                Intent intent = new Intent();
                intent.putExtra(ConstantVariables.KEY_CAN_REFRESH, true);
                setResult(ConstantVariables.ALBUM_VIEW_PAGE, intent);
            }
            super.onBackPressed();
            overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {

            case ConstantVariables.REQUEST_IMAGE:
                if (resultCode == RESULT_OK) {
                    mSelectPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);

                    StringBuilder sb = new StringBuilder();
                    for (String p : mSelectPath) {
                        sb.append(p);
                        sb.append("\n");
                    }

                    // uploading the photos to server
                    new UploadFileToServerUtils(mContext, redirectUrl, mSelectPath, this).execute();

                } else if (resultCode != RESULT_CANCELED) {

                    // failed to capture image
                    SnackbarUtils.displaySnackbar(mBottomToolBar,
                            getResources().getString(R.string.image_capturing_failed));

                }
                break;

            case ConstantVariables.CREATE_REQUEST_CODE:
            case ConstantVariables.VIEW_PAGE_EDIT_CODE:
                isLoadingFromCreate = false;
                isContentEdited = true;
                makeRequest();
                break;

            case ConstantVariables.VIEW_LIGHT_BOX:

                switch (resultCode) {
                    case ConstantVariables.LIGHT_BOX_DELETE:
                        isLoadingFromCreate = false;
                        makeRequest();
                        recyclerViewAdapter.notifyItemChanged(1);
                        break;

                    case ConstantVariables.LIGHT_BOX_EDIT:
                        if (data.getBooleanExtra(ConstantVariables.IS_CONTENT_EDITED, false)) {
                            isLoadingFromCreate = false;
                            makeRequest();
                            recyclerViewAdapter.notifyItemChanged(1);
                        } else {
                            mPhotoDetails = (ArrayList<PhotoListDetails>) data.getSerializableExtra(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST);
                        }
                        break;
                }
                break;

            case ConstantVariables.USER_PROFILE_CODE:
            case ConstantVariables.CONTENT_COVER_EDIT_CODE:
                PreferencesUtils.updateCurrentModule(mContext, mModuleName);
                break;

            case ConstantVariables.VIEW_COMMENT_PAGE_CODE:
                if (resultCode == ConstantVariables.VIEW_COMMENT_PAGE_CODE && data != null) {
                    mCommentCount = data.getIntExtra(ConstantVariables.PHOTO_COMMENT_COUNT, mCommentCount);
                    mGridViewImages.setCommentCount(mCommentCount);
                    recyclerViewAdapter.notifyItemChanged(0);                }
                break;

            default:
                break;

        }
    }


    public void onClick(View view) {
        int id = view.getId();

        switch (id){

            case R.id.create_fab:
                addMorePhotos();
                break;

        }

    }

    @Override
    public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
        if(verticalOffset == -collapsingToolbarLayout.getHeight() + mToolbar.getHeight()){
            mToolBarTitle.setVisibility(View.VISIBLE);
            collapsingToolbarLayout.setTitle("");
        }else{
            mToolBarTitle.setVisibility(View.GONE);
            collapsingToolbarLayout.setTitle(title);
        }
    }

    public void onItemDelete(String successMessage) {
        // Show Message
        SnackbarUtils.displaySnackbarShortWithListener(mMainLayout, successMessage,
                new SnackbarUtils.OnSnackbarDismissListener() {
                    @Override
                    public void onSnackbarDismissed() {
                        isContentDeleted = true;
                        onBackPressed();
                    }
                });
    }

    @Override
    public void onOptionItemActionSuccess(Object itemList, String menuName) {
        mBrowseList = (BrowseListItems) itemList;
        switch (menuName) {
            case "add":
            case "photo":
            case "add_photo":
            case "addphoto":
                this.redirectUrl = mBrowseList.getmRedirectUrl();
                addMorePhotos();
                break;
        }
    }

    private void addMorePhotos() {
        /* Check if permission is granted or not */
        if(!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)){
            mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    ConstantVariables.WRITE_EXTERNAL_STORAGE);
        }else{
            startImageUploading();
        }
    }

    @Override
    public void onUploadResponse(JSONObject jsonObject, boolean isRequestSuccessful) {

        String message;
        if (isRequestSuccessful) {
            message = getResources().getQuantityString(R.plurals.photo_upload_msg,
                    mSelectPath.size(),
                    mSelectPath.size());

            isContentEdited = true;
            isLoadingFromCreate = false;
            makeRequest();
        } else {
            message = jsonObject.optString("message");
        }
        SnackbarUtils.displaySnackbar(mMainLayout, message);

    }

    private void startImageUploading(){

        Intent uploadPhoto = new Intent(AlbumView.this, MultiMediaSelectorActivity.class);
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

        startActivityForResult(uploadPhoto, ConstantVariables.REQUEST_IMAGE);
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

                    }else{
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.
                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, mMainLayout,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    }
                }
                break;

        }
    }

    @Override
    public void onItemClick(SheetItemModel item, int position) {
        if (item != null) {
            final Map<String, String> privacyParams = new HashMap<>();
            privacyParams.put("auth_view", item.getKey());
            String privacyUrl = UrlUtil.ALBUM_PRIVACY_URL + mSubjectId;
            mAppConst.postJsonResponseForUrl(privacyUrl, privacyParams, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                }
            });
        }
    }

    @Override
    public void handleAppLinks() {
        Intent intent = getIntent();
        Uri data = intent.getData();
        if (mContent_id == 0 && mItemViewUrl == null && data != null) {
            try {
                String strQueries = data.getPath().replaceAll("[^0-9]+", " ");
                List<String> ids = Arrays.asList(strQueries.trim().split(" "));
                mContent_id = Integer.parseInt(ids.get(0));
                mSubjectId = mContent_id;
                mItemViewUrl = AppConstant.DEFAULT_URL + "albums/view/" + mContent_id;
            } catch (IndexOutOfBoundsException | NullPointerException e) {
                e.printStackTrace();
            }
        }
    }
}
