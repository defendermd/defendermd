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
 *
 */

package com.socialengineaddons.mobileapp.classes.modules.story.photofilter;

import android.Manifest;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatCheckBox;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.PopupMenu;
import android.support.v7.widget.RecyclerView;
import android.util.TypedValue;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.adapters.CustomImageAdapter;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCancelClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.BezelImageView;
import com.socialengineaddons.mobileapp.classes.common.ui.NonSwipeableViewPager;
import com.socialengineaddons.mobileapp.classes.common.utils.BitmapUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.DrawableClickListener;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageViewList;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.stickers.StickersUtil;
import com.socialengineaddons.mobileapp.classes.modules.story.photofilter.colorFilter.ThumbnailCallback;
import com.yalantis.ucrop.UCrop;
import com.zomato.photofilters.imageprocessors.Filter;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ja.burhanrashid52.photoeditor.PhotoEditor;

import static com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.Status.NETWORK_LIST_ARRAY;
import static com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.Status.USER_LIST_ARRAY;

public class PhotoEditActivity extends AppCompatActivity implements
        View.OnClickListener, ThumbnailCallback, CompoundButton.OnCheckedChangeListener {

    private AppConstant mAppConst;
    private int NUM_OF_COLUMN = 6;
    private Context mContext;
    private Activity activity;
    private ArrayList<String> mSelectPath;
    private String videoPath, storyType;
    private int columnWidth, width, recentSelected = 0;
    private CustomImageAdapter mCustomImageAdapter;
    public static RecyclerView mRecyclerViewList;
    private NonSwipeableViewPager nsViewPager;
    public static JSONObject mStickerResponse;
    private EditText mCaptionEdit;
    public static RelativeLayout mCaptionView;
    public static TextView mTapFilter;
    public ImageView sendButton;
    public ArrayList<Fragment> fragmentArrayList;
    private Intent storyIntent;
    private StickerResponseListener mStickerResponseListener;
    private MyPagerAdapter adapterViewPager;
    public static String mVideoThumb = "";
    public int duration;
    public static Uri destination;
    private ArrayList<Integer> sDataSet;

    public BottomSheetDialog bottomSheetDialog;
    private LinearLayout llStory, llPost;
    private AppCompatCheckBox cbStory, cbPost;
    private TextView tvStoryTitle, tvPostTitle, tvStoryDesc, tvPostDesc;
    private BezelImageView ivUser;
    private ProgressBar pbLoading;
    private ArrayList<String> mStoryCaption;
    private String mStoryPrivacy = "everyone", mPostPrivacy = "everyone";
    private JSONObject mFeedPostMenus, mUserPrivacyObject, userDetails, mStoryPrivacyObject;
    private Map<String, String> mMultiSelectUserPrivacy;
    private ArrayList<String> popupMenuList = new ArrayList<>();
    private ImageLoader mImageLoader;
    private int mDuration;
    private ImageView postImage;
    private TextView tvPostStory;
    private String mVideoOverlayThumb;


    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putIntegerArrayList("dataset", sDataSet);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_photo_edit);

        /* Use integer list to identify photo fragments position in viewpager */
        if (savedInstanceState == null) {
            sDataSet = new ArrayList<>();
            for (int i = 0; i < 5; i++) {
                sDataSet.add(i);
            }
        } else {
            sDataSet = savedInstanceState.getIntegerArrayList("dataset");
        }

        mContext = activity = this;
        mAppConst = new AppConstant(mContext);
        mStoryCaption = new ArrayList<>();

        selectMediaFromGallery();
    }

    private void selectMediaFromGallery() {
        Intent intent = new Intent(mContext, MultiMediaSelectorActivity.class);
        // Selection type photo/video to display items in grid
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECTION_TYPE, MultiMediaSelectorActivity.SELECTION_PHOTO_VIDEO);
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SHOW_CAMERA, true);
        intent.putExtra(MultiMediaSelectorActivity.IS_STORY_POST, true);
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_COUNT, ConstantVariables.STORY_POST_COUNT_LIMIT);

        // Select mode
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_MODE, MultiMediaSelectorActivity.MODE_MULTI);
        startActivityForResult(intent, ConstantVariables.REQUEST_STORY_IMAGE_VIDEO);
    }

    /**
     * Class to load the images in background thread
     * so that it will load the images in background and don't make the main thread slow.
     */
    public class LoadImageAsync extends AsyncTask<Void,String,Void> {

        private ProgressDialog mProgressDialog;
        private RecyclerView mRecyclerView;
        private List<ImageViewList> mPhotoUrls = new ArrayList<>();

        public LoadImageAsync(RecyclerView recyclerView, boolean isPhotoPreview) {
            this.mRecyclerView = recyclerView;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mProgressDialog = new ProgressDialog(mContext);
            mProgressDialog.setMessage(getApplicationContext().getResources().
                    getString(R.string.loading_text));
            mProgressDialog.setCancelable(false);
            mProgressDialog.show();
        }

        @Override
        protected Void doInBackground(Void... params) {
            runOnUiThread(new Runnable() {

                @Override
                public void run() {
                    mRecyclerView.setLayoutManager(new LinearLayoutManager(mContext,
                            LinearLayoutManager.HORIZONTAL, false));

                    for(int i = 0; i < mSelectPath.size(); i++) {
                        int selectItem = 0;
                        if (i == 0) {
                            selectItem = 1;
                        }
                        // Getting Bitmap from its real path.
                        Bitmap bitmap = BitmapUtils.decodeSampledBitmapFromFile(mContext, mSelectPath.get(i), width,
                                (int) getResources().getDimension(R.dimen.feed_attachment_image_height), false);
                        if (bitmap != null) {
                            mPhotoUrls.add(new ImageViewList(selectItem, bitmap));
                        }

                        mStoryCaption.add(i, "");
                    }
                }
            });
            return null;
        }

        @Override
        protected void onPostExecute(Void param) {
            mProgressDialog.dismiss();
            mCustomImageAdapter = new CustomImageAdapter(activity, mPhotoUrls, columnWidth, new OnItemClickListener() {
                @Override
                public void onItemClick(View view, int position) {
                    addCaptionIntoList(recentSelected);
                    setCaptionInView(position);
                    recentSelected = position;
                    nsViewPager.setCurrentItem(position);
                }
            }, new OnCancelClickListener() {
                @Override
                public void onCancelButtonClicked(int removedImage) {
                    if (mSelectPath != null && !mSelectPath.isEmpty()) {
                        mSelectPath.remove(removedImage);
                        mPhotoUrls.remove(removedImage);
                        mCustomImageAdapter.notifyDataSetChanged();
                        synchronized (nsViewPager) {
                            nsViewPager.notify();
                        }
                        sDataSet.remove(removedImage);
                        fragmentArrayList.remove(removedImage);
                        adapterViewPager.notifyDataSetChanged();
                            if (mSelectPath.isEmpty()) {
                                finish();
                            }  else {
                                if (recentSelected >= removedImage) {
                                    recentSelected--;
                                }
                                nsViewPager.setCurrentItem(recentSelected);
                                adapterViewPager.notifyDataSetChanged();
                            }
                    }
                }
            });
            mRecyclerView.setAdapter(mCustomImageAdapter);
            mRecyclerView.setVisibility(View.VISIBLE);

            getStickers();
        }
    }

    private void getStickers() {
        mAppConst.getJsonResponseFromUrl(UrlUtil.AAF_VIEW_STICKERS_URL, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mStickerResponse = jsonObject;
                mStickerResponseListener.onStickerResponse(jsonObject);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

            }
        });
    }

    @Override
    public void onBackPressed() {

        if (fragmentArrayList != null) {
            PhotoFilterFragment fragment = (PhotoFilterFragment) fragmentArrayList.get(recentSelected);

            if (fragment.isFilterDisplayed ) {
                fragment.isFilterDisplayed = false;
                fragment.isEditToolbarDisplay = false;
                fragment.imgColorFilter.setVisibility(View.GONE);
                PhotoEditActivity.mTapFilter.setVisibility(View.VISIBLE);
                PhotoEditActivity.mCaptionView.setVisibility(View.VISIBLE);
                PhotoEditActivity.mRecyclerViewList.setVisibility(View.VISIBLE);

            } else if (fragment.isStickerViewDisplayed) {
                fragment.isStickerViewDisplayed = false;
                StickersUtil.showStickerViewForFilter(true);
                fragment.mEditToolbar.setVisibility(View.VISIBLE);
                Animation slideUp = AnimationUtils.loadAnimation(mContext, R.anim.push_up_in);
                fragment.mEditToolbar.startAnimation(slideUp);

            } else if (fragment.isEditToolbarDisplay) {
                fragment.isEditToolbarDisplay = false;
                fragment.mEditToolbar.setVisibility(View.GONE);
                PhotoEditActivity.mTapFilter.setVisibility(View.VISIBLE);
                PhotoEditActivity.mRecyclerViewList.setVisibility(View.VISIBLE);
                PhotoEditActivity.mCaptionView.setVisibility(View.VISIBLE);

            } else {
                super.onBackPressed();
            }
        } else {
            super.onBackPressed();
        }
    }

    public interface StickerResponseListener{
        void onStickerResponse(JSONObject jsonObject);
    }

    public void setStickerResponseListener(StickerResponseListener stickerResponseListener) {
        mStickerResponseListener = stickerResponseListener;
    }


    // Get photo caption from list and show it in caption view
    private void setCaptionInView(int position) {
        mCaptionEdit.setText(mStoryCaption.get(position));
        mCaptionEdit.setSelection(mStoryCaption.get(position).length());
    }

    // Add photo caption in there respective position
    private void addCaptionIntoList(int pos) {
        if (mCaptionEdit.getText() != null && !mCaptionEdit.getText().toString().isEmpty()) {
            mStoryCaption.set(pos, mCaptionEdit.getText().toString());
        }
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {
            case R.id.sendButton:
                initializeBottomSheet();
                break;

            case R.id.story_layout:
            case R.id.select_story:
                cbStory.setChecked(!cbStory.isChecked());
                setTitleTypeFace();
                break;

            case R.id.post_layout:
            case R.id.select_post:
                cbPost.setChecked(!cbPost.isChecked());
                setTitleTypeFace();
                break;

            case R.id.submit:
                if (bottomSheetDialog != null && bottomSheetDialog.isShowing()) {
                    bottomSheetDialog.dismiss();
                }

                if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            ConstantVariables.WRITE_EXTERNAL_STORAGE);
                } else {
                    saveImage();
                }

                break;
        }
    }

    int counter;
    private void saveImage() {
        counter = fragmentArrayList.size();
        for (int i = 0; i < fragmentArrayList.size(); i++) {
            PhotoFilterFragment fragment = (PhotoFilterFragment) fragmentArrayList.get(i);

            // If user do any editing on image then create a bitmap and get path
            if (fragment.btnSkip.getVisibility() == View.VISIBLE) {
                saveImage(fragment.mPhotoEditor, i, counter);
            } else {
                counter--;
                if (counter == 0) {
                    mAppConst.hideProgressDialog();
                    redirectToUploadStory();
                }
            }
        }
    }

    public void saveImage(PhotoEditor photoEditor, final int  position, int count) {
        mAppConst.showProgressDialog();
        if (mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            File file = new File(Environment.getExternalStorageDirectory()
                    + File.separator + ""
                    + System.currentTimeMillis() + ".png");
            try {
                file.createNewFile();
                photoEditor.saveImage(file.getAbsolutePath(), new PhotoEditor.OnSaveListener() {
                    @Override
                    public void onSuccess(@NonNull String imagePath) {

                        if (storyType.equals("video")) {
                            mVideoOverlayThumb = imagePath;
                        } else {
                            mSelectPath.set(position, imagePath);
                        }
                        counter--;
                        if (counter == 0) {
                            mAppConst.hideProgressDialog();
                            redirectToUploadStory();
                        }
                    }

                    @Override
                    public void onFailure(@NonNull Exception exception) {
                        counter--;
                        mAppConst.hideProgressDialog();
                        SnackbarUtils.displaySnackbar(nsViewPager, "Failed to save image");
                    }
                });
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void redirectToUploadStory() {
        if (storyType.equals("video")) {
            mStoryCaption.add(0, mCaptionEdit.getText().toString());
        } else {
            mStoryCaption.set(recentSelected, mCaptionEdit.getText().toString());
        }

        storyIntent = getPostParams(new Intent());
        finish();
    }

    private void initializeBottomSheet() {
        View inflatedView = ((Activity) mContext).getLayoutInflater().inflate(R.layout.activity_story_create, null);
        inflatedView.setBackgroundResource(R.color.white);

        mImageLoader = new ImageLoader(mContext);
        bottomSheetDialog = new BottomSheetDialog(mContext);
        bottomSheetDialog.setContentView(inflatedView);
        mMultiSelectUserPrivacy = new HashMap<>();

        getViews(inflatedView);

        try {
            userDetails = new JSONObject(PreferencesUtils.getUserDetail(mContext));
        } catch (JSONException e) {
            e.printStackTrace();
        }

        if (PreferencesUtils.getStatusPostPrivacyOptions(mContext) != null
                && PreferencesUtils.getStoryPrivacy(mContext) != null) {
            setPrivacy();
        } else {
            pbLoading.setVisibility(View.VISIBLE);
            showHideViews(false);
            getStoryAndPostPrivacy();
        }
    }

    /**
     * Method to get all views.
     */
    private void getViews(View view) {
        tvPostStory = view.findViewById(R.id.submit);
        tvStoryTitle = view.findViewById(R.id.story_title);
        tvPostTitle = view.findViewById(R.id.post_title);
        tvStoryDesc = view.findViewById(R.id.story_desc);
        tvPostDesc = view.findViewById(R.id.post_desc);
        ivUser = view.findViewById(R.id.owner_image);
        llStory = view.findViewById(R.id.story_layout);
        llPost = view.findViewById(R.id.post_layout);
        cbStory = view.findViewById(R.id.select_story);
        cbPost = view.findViewById(R.id.select_post);
        pbLoading = view.findViewById(R.id.loadingProgress);
        postImage = view.findViewById(R.id.post_image);

        tvPostStory.setOnClickListener(this);
        llStory.setOnClickListener(this);
        llPost.setOnClickListener(this);
        cbStory.setOnCheckedChangeListener(this);
        cbPost.setOnCheckedChangeListener(this);
    }


    /**
     * Method to get privacy options and store them in preferences.
     */
    private void getStoryAndPostPrivacy() {
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/feeds/feed-post-menus",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) {
                        if (jsonObject != null && jsonObject.optJSONObject("feed_post_menu") != null) {
                            PreferencesUtils.setStatusPrivacyOptions(mContext, jsonObject.optJSONObject("feed_post_menu"));
                        }
                        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/stories/create",
                                new OnResponseListener() {
                                    @Override
                                    public void onTaskCompleted(JSONObject jsonObject) {
                                        for (int i = 0; i < jsonObject.optJSONArray("response").length(); i++) {
                                            if (jsonObject.optJSONArray("response").optJSONObject(i).optString("name").equals("privacy")) {
                                                JSONObject privacy = jsonObject.optJSONArray("response").optJSONObject(i).optJSONObject("multiOptions");
                                                PreferencesUtils.setStoryPrivacy(mContext, privacy);
                                            }
                                        }
                                        setPrivacy();
                                    }

                                    @Override
                                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                                    }
                                });
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });
    }

    /**
     * Method to set privacy.
     */
    private void setPrivacy() {
        try {
            mFeedPostMenus = new JSONObject(PreferencesUtils.getStatusPostPrivacyOptions(mContext));
            mStoryPrivacyObject = new JSONObject(PreferencesUtils.getStoryPrivacy(mContext));
            mUserPrivacyObject = mFeedPostMenus.optJSONObject("userprivacy");
            USER_LIST_ARRAY = mFeedPostMenus.optJSONArray("userlist");
            NETWORK_LIST_ARRAY = mFeedPostMenus.optJSONArray("multiple_networklist");


            // When the user selected custom network or friend list then putting the all options into map.
            if ((mPostPrivacy.equals("network_list_custom")
                    || mPostPrivacy.equals("friend_list_custom"))
                    && PreferencesUtils.getStatusPrivacyMultiOptions(mContext) != null) {
                List<String> multiOptionList = Arrays.asList(PreferencesUtils.
                        getStatusPrivacyMultiOptions(mContext).split("\\s*,\\s*"));
                if (!multiOptionList.isEmpty()) {
                    for (int i = 0; i < multiOptionList.size(); i++) {
                        mMultiSelectUserPrivacy.put(multiOptionList.get(i), "1");
                    }
                }
            }

            setPrivacyOption(false);
            setStoryPrivacyOption(false);

            // once all data setup showing data in views.
            setDataInView();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Method to show/hide views when the data is loaded.
     *
     * @param isNeedToShow True if need to show views.
     */
    private void showHideViews(boolean isNeedToShow) {
        ivUser.setVisibility(isNeedToShow ? View.VISIBLE : View.GONE);
        llStory.setVisibility(isNeedToShow ? View.VISIBLE : View.GONE);
        cbStory.setVisibility(isNeedToShow ? View.VISIBLE : View.GONE);
        postImage.setVisibility(isNeedToShow ? View.VISIBLE : View.GONE);
        llPost.setVisibility(isNeedToShow ? View.VISIBLE : View.GONE);
        cbPost.setVisibility(isNeedToShow ? View.VISIBLE : View.GONE);
    }

    /**
     * Method to set default privacy option when status page opened up.
     */
    private void setPrivacyOption(boolean isOptionChanged) {
        switch (mPostPrivacy) {
            case "network_list_custom":
            case "friend_list_custom":
                if (isOptionChanged) {
                    getPrivacyForm(mPostPrivacy.equals("friend_list_custom"), mPostPrivacy);
                    mPostPrivacy = !PreferencesUtils.getStatusPrivacyKey(mContext).equals("network_list_custom")
                            && !PreferencesUtils.getStatusPrivacyKey(mContext).equals("friend_list_custom")
                            ? PreferencesUtils.getStatusPrivacyKey(mContext) : null;
                } else {
                    setDescription(mUserPrivacyObject.optString(mPostPrivacy), false);
                    PreferencesUtils.setStatusPrivacyKey(mContext, mPostPrivacy);
                    mPostPrivacy = null;
                }
                break;

            default:
                setDescription(mUserPrivacyObject.optString(mPostPrivacy), false);
                break;
        }

        if (mPostPrivacy != null && !mPostPrivacy.equals("network_list_custom")
                && !mPostPrivacy.equals("friend_list_custom")) {
            PreferencesUtils.setStatusPrivacyKey(mContext, mPostPrivacy);
            if (mMultiSelectUserPrivacy != null) {
                mMultiSelectUserPrivacy.clear();
            }
        }
    }

    /**
     * Method to set default privacy key.
     */
    private void setDefaultPrivacyKey() {
        mPostPrivacy = !PreferencesUtils.getStatusPrivacyKey(mContext).equals("network_list_custom")
                && !PreferencesUtils.getStatusPrivacyKey(mContext).equals("friend_list_custom")
                ? PreferencesUtils.getStatusPrivacyKey(mContext) : "everyone";
        setDescription(mUserPrivacyObject.optString(mPostPrivacy), false);
    }

    /**
     * Method to set default story privacy when privacy change
     */
    private void setStoryPrivacyOption(boolean isOptionChanged) {
        if (mStoryPrivacy != null && !mStoryPrivacy.equals(PreferencesUtils.getStoryPrivacyKey(mContext))
                && isOptionChanged){
            PreferencesUtils.setStoryPrivacyKey(mContext, mStoryPrivacy);
        }
        setDescription(mStoryPrivacyObject.optString(mStoryPrivacy), true);
    }

    /**
     * Method to set data in respective views.
     */
    private void setDataInView() {
        pbLoading.setVisibility(View.GONE);
        showHideViews(true);
        try {
            mImageLoader.setImageForUserProfile(userDetails.optString("image"), ivUser);
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Getting drawable for setting
        Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_settings_white_24dp);
        drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                PorterDuff.Mode.SRC_ATOP));
        drawable.setBounds(0, 0, mContext.getResources().getDimensionPixelSize(R.dimen.margin_15dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.margin_15dp));
        tvStoryTitle.setCompoundDrawables(null, null, drawable, null);
        tvPostTitle.setCompoundDrawables(null, null, drawable, null);

        tvStoryTitle.setOnTouchListener(new DrawableClickListener.RightDrawableClickListener(tvStoryTitle) {
            @Override
            public boolean onDrawableClick() {
                showPopup(tvStoryTitle, true);
                return true;
            }
        });

        tvPostTitle.setOnTouchListener(new DrawableClickListener.RightDrawableClickListener(tvPostTitle) {
            @Override
            public boolean onDrawableClick() {
                showPopup(tvPostTitle, false);
                return true;
            }
        });

        setTitleTypeFace();

        bottomSheetDialog.show();
    }


    /**
     * Method to show popup when the
     *
     * @param view    View on which popup need to be shown
     * @param isStory True if it is for story.
     */
    public void showPopup(View view, final boolean isStory) {

        PopupMenu popup = new PopupMenu(mContext, view);
        popupMenuList.clear();

        if (!isStory && mUserPrivacyObject != null && mUserPrivacyObject.length() != 0) {
            JSONArray mPrivacyKeys = mUserPrivacyObject.names();

            for (int i = 0; i < mUserPrivacyObject.length(); i++) {
                String key = mPrivacyKeys.optString(i);
                popupMenuList.add(key);
                String privacyLabel = mUserPrivacyObject.optString(key);
                if (mPostPrivacy != null && mPostPrivacy.equals(key)) {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(true).setChecked(true);
                } else if (mPostPrivacy == null && key.equals("everyone")
                        && (mMultiSelectUserPrivacy == null || mMultiSelectUserPrivacy.isEmpty())) {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(true).setChecked(true);
                } else {
                    boolean isSelected = (mMultiSelectUserPrivacy != null && mMultiSelectUserPrivacy.size() > 0)
                            && mMultiSelectUserPrivacy.get(key) != null && mMultiSelectUserPrivacy.get(key).equals("1");
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(isSelected).setChecked(isSelected);
                }
            }
        }

        if (isStory && mStoryPrivacyObject != null && mStoryPrivacyObject.length() != 0) {
            JSONArray mPrivacyKeys = mStoryPrivacyObject.names();

            for (int i = 0; i < mStoryPrivacyObject.length(); i++) {
                String key = mPrivacyKeys.optString(i);
                popupMenuList.add(key);
                String privacyLabel = mStoryPrivacyObject.optString(key);
                if (mStoryPrivacy != null && mStoryPrivacy.equals(key)) {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(true).setChecked(true);
                } else {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel);
                }
            }
        }

        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            public boolean onMenuItemClick(MenuItem item) {
                int id = item.getItemId();

                if (isStory) {
                    mStoryPrivacy = popupMenuList.get(id);
                    setStoryPrivacyOption(true);

                } else {
                    mPostPrivacy = popupMenuList.get(id);

                    // Clearing list when any other popup option(other than multiple friend/network list) is clicked.
                    if (!mPostPrivacy.equals("network_list_custom")
                            && !mPostPrivacy.equals("friend_list_custom")) {
                        mMultiSelectUserPrivacy.clear();
                    }
                    setPrivacyOption(true);
                }
                return true;
            }
        });
        popup.show();
    }

    /**
     * Method to set description on story/post description view according to privacy.
     *
     * @param privacyTitle Privacy title of respected view.
     * @param isStory      True if it is for story.
     */
    private void setDescription(String privacyTitle, boolean isStory) {
        if (isStory) {
            tvStoryDesc.setText(mContext.getResources().getString(R.string.visible_in_story) + " "
                    + mContext.getResources().getString(R.string.to_text) + " " + privacyTitle + " "
                    + mContext.getResources().getQuantityString(R.plurals.for_days,
                    PreferencesUtils.getStoryDuration(mContext), PreferencesUtils.getStoryDuration(mContext)));
        } else {
            tvPostDesc.setText(mContext.getResources().getString(R.string.share_with) + " " + privacyTitle);
        }
    }

    /**
     * Method to set title in bold format when the checkbox is selected.
     */
    private void setTitleTypeFace() {
        invalidateOptionsMenu();
        tvStoryTitle.setTypeface(cbStory.isChecked() ? Typeface.DEFAULT_BOLD : null);
        tvPostTitle.setTypeface(cbPost.isChecked() ? Typeface.DEFAULT_BOLD : null);

        if (!cbStory.isChecked() && !cbPost.isChecked()) {
            tvPostStory.setAlpha(.5f);
            tvPostStory.setClickable(false);
        } else {
            tvPostStory.setAlpha(1);
            tvPostStory.setClickable(true);
        }

    }

    /**
     * Method to launch Form Creation activity for multiple friend/network list.
     *
     * @param isFriendList True if the form is to be load for friend list.
     * @param key          Key of the selected privacy option.
     */
    private void getPrivacyForm(boolean isFriendList, String key) {
        Intent intent = new Intent(mContext, CreateNewEntry.class);
        intent.putExtra("is_status_privacy", true);
        intent.putExtra("isFriendList", isFriendList);
        intent.putExtra("privacy_key", key);
        intent.putExtra("user_id", userDetails.optInt("user_id"));
        intent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.HOME_MENU_TITLE);
        intent.putExtra(ConstantVariables.CONTENT_TITLE, mUserPrivacyObject.optString(key));
        startActivityForResult(intent, ConstantVariables.USER_PRIVACY_REQUEST_CODE);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        setTitleTypeFace();
    }

    /**
     * Method to get postparams for story/post uploading.
     *
     * @return Returns the post params with required details.
     */
    private Intent getPostParams(Intent intent) {
        if (cbStory.isChecked()) {
            HashMap<String, String> storyParams = new HashMap<>();
            storyParams.put("privacy", mStoryPrivacy);
            for(int i = 0; i < mStoryCaption.size(); i++) {
                if (i == 0) {
                    storyParams.put("description", mStoryCaption.get(i));
                } else {
                    storyParams.put("description" + i, mStoryCaption.get(i));
                }
            }
            storyParams.put("duration", String.valueOf(mDuration));
            intent.putExtra("story_url", AppConstant.DEFAULT_URL + "advancedactivity/stories/create");
            intent.putExtra("story_param", storyParams);
        }

        if (cbPost.isChecked()) {
            String statusPostUrl = AppConstant.DEFAULT_URL + "advancedactivity/feeds/post";
            HashMap<String, String> postParams = new HashMap<>();

            if (videoPath != null) {
                List<String> enabledModuleList = null;
                if (PreferencesUtils.getEnabledModuleList(mContext) != null) {
                    enabledModuleList = new ArrayList<>(Arrays.asList(PreferencesUtils.getEnabledModuleList(mContext).split("\",\"")));
                }
                if (enabledModuleList != null && enabledModuleList.contains("sitevideo")
                        && !Arrays.asList(ConstantVariables.DELETED_MODULES).contains("sitevideo")) {
                    statusPostUrl = AppConstant.DEFAULT_URL + "advancedvideos/create";
                } else {
                    statusPostUrl = AppConstant.DEFAULT_URL + "videos/create";
                }
                postParams.put("duration", String.valueOf(mDuration));
                postParams.put("is_storyPost", "1");

            } else {
                postParams.put("type", "photo");
                postParams.put("locationLibrary", "client");
                postParams.put("body", "");

            }

            // Adding post privacy option.
            if (mMultiSelectUserPrivacy != null && !mMultiSelectUserPrivacy.isEmpty()) {
                for (Map.Entry<String, String> entry : mMultiSelectUserPrivacy.entrySet()) {
                    if (entry.getValue().equals("1")) {
                        if (mPostPrivacy != null) {
                            mPostPrivacy += entry.getKey() + ",";
                        } else {
                            mPostPrivacy = entry.getKey() + ",";
                        }
                    }
                }
                mPostPrivacy = mPostPrivacy.substring(0, mPostPrivacy.lastIndexOf(","));

            } else if (mPostPrivacy == null) {
                mPostPrivacy = "everyone";
            }
            postParams.put("auth_view", mPostPrivacy);
            postParams.put("body", mStoryCaption.get(0));
            postParams.put("post_attach", "1");
            intent.putExtra("post_param", postParams);
            intent.putExtra("post_url", statusPostUrl);

        }

        HashMap<String, String> mVideoParams = new HashMap<>();
        if (videoPath != null && mVideoThumb != null) {
            mVideoParams.put("filedata", videoPath);
            mVideoParams.put("photo", mVideoThumb);
        }

        if (mVideoOverlayThumb != null && !mVideoOverlayThumb.isEmpty()) {
            mVideoParams.put("video_overlay_image", mVideoOverlayThumb);
        }
        intent.putExtra("video_params", mVideoParams);
        intent.putStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT, mSelectPath);
        return intent;
    }


    @Override
    public void finish() {
        if (storyIntent != null) {
            setResult(ConstantVariables.REQUEST_STORY_POST, storyIntent);
        }  else {
            Intent data = new Intent();
            setResult(ConstantVariables.STORY_VIEW_PAGE_CODE, data);
        }
        super.finish();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        LogUtils.LOGD("PhotoEditActivity :: onActivityResult: ", requestCode + " " + resultCode);

        switch (requestCode) {
            case ConstantVariables.REQUEST_STORY_IMAGE_VIDEO:
                if (resultCode == RESULT_OK) {
                    loadImageVideosDataInView(data);
                } else {
                    setResult(ConstantVariables.REQUEST_STORY_POST, data);
                    finish();
                }
                break;

            case UCrop.REQUEST_CROP:
                if (resultCode == RESULT_OK) {
                    PhotoFilterFragment fragment = (PhotoFilterFragment) fragmentArrayList.get(recentSelected);
                    fragment.onActivityResult(requestCode, resultCode, data);
                    if (UCrop.getOutput(data) != null) {
                        String path = GlobalFunctions.getRealPathFromURI(mContext, destination);
                        mSelectPath.set(recentSelected, path);
                    }
                }
                break;

            case ConstantVariables.USER_PRIVACY_REQUEST_CODE:
                Bundle bundle = null;
                if (data != null) {
                    bundle = data.getExtras();
                }

                if (bundle != null && bundle.getSerializable("param") != null) {
                    mMultiSelectUserPrivacy = (HashMap<String, String>) bundle.getSerializable("param");

                    if (bundle.getString("feed_post_menu") != null
                            && bundle.getString("feed_post_menu").length() > 0
                            && bundle.getString("privacy_key").equals("friend_list_custom")) {
                        try {
                            mFeedPostMenus = new JSONObject(bundle.getString("feed_post_menu"));
                            mUserPrivacyObject = mFeedPostMenus.optJSONObject("userprivacy");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                    if (mMultiSelectUserPrivacy != null && mMultiSelectUserPrivacy.size() > 0) {
                        boolean isAnyOptionSelected = false;
                        for (Map.Entry<String, String> entry : mMultiSelectUserPrivacy.entrySet()) {
                            if (entry.getValue().equals("1")) {
                                isAnyOptionSelected = true;
                                break;
                            }
                        }

                        // When there is any option is selected then showing the name of multi select list.
                        if (isAnyOptionSelected) {
                            mPostPrivacy = null;
                            setDescription(mUserPrivacyObject.optString(bundle.getString("privacy_key")), false);
                            String multiOptions = null;
                            for (Map.Entry<String, String> entry : mMultiSelectUserPrivacy.entrySet()) {
                                if (entry.getValue().equals("1")) {
                                    if (multiOptions != null) {
                                        multiOptions += entry.getKey() + ",";
                                    } else {
                                        multiOptions = entry.getKey() + ",";
                                    }
                                }
                            }
                            if (multiOptions != null) {
                                multiOptions = multiOptions.substring(0, multiOptions.lastIndexOf(","));
                                PreferencesUtils.setStatusPrivacyKey(mContext, bundle.getString("privacy_key"));
                                PreferencesUtils.setStatusPrivacyMultiOptions(mContext, multiOptions);
                            }
                        } else {
                            mPostPrivacy = !PreferencesUtils.getStatusPrivacyKey(mContext).equals("network_list_custom")
                                    && !PreferencesUtils.getStatusPrivacyKey(mContext).equals("friend_list_custom")
                                    ? PreferencesUtils.getStatusPrivacyKey(mContext) : "everyone";
                            mMultiSelectUserPrivacy.clear();
                            PreferencesUtils.setStatusPrivacyKey(mContext, mPostPrivacy);
                            setDescription(mUserPrivacyObject.optString(mPostPrivacy), false);
                        }
                    } else {
                        setDefaultPrivacyKey();
                    }
                } else {
                    mMultiSelectUserPrivacy.clear();
                    setDefaultPrivacyKey();
                }
                break;
        }
    }

    private void loadImageVideosDataInView(Intent intent) {
        mSelectPath = intent.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);
        videoPath = intent.getStringExtra(MultiMediaSelectorActivity.VIDEO_RESULT);

        long length = 0;
        if (videoPath != null && !videoPath.isEmpty()) {
            storyType = "video";
            File file = new File(videoPath);
            long size = file.length();
            length = (int)size/(1024 * 1024);
            mDuration = GlobalFunctions.getDurationFromVideoFile(mContext, file);
        } else if (mSelectPath != null && mSelectPath.size() > 0) {
            storyType = "image";
            for (int i = 0; i < mSelectPath.size(); ++i) {
                File file = new File(mSelectPath.get(i));
                long size = file.length();
                length += (int)size/(1024 * 1024);
            }
        }
        String message = ConstantVariables.VALID_FILE_SIZE;
        if ((message = GlobalFunctions.validateFileSize(length, mContext)).equals(ConstantVariables.VALID_FILE_SIZE)) {

            mCaptionView = findViewById(R.id.captionView);
            mCaptionEdit = findViewById(R.id.captionEdit);
            mTapFilter = findViewById(R.id.tap_filter);
            sendButton = findViewById(R.id.sendButton);
            sendButton.setOnClickListener(this);

            mTapFilter.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            mTapFilter.setText("\uf106" + "\n" + mContext.getResources().getString(R.string.tap_filter_text));

            nsViewPager = findViewById(R.id.view_pager);
            adapterViewPager = new MyPagerAdapter(getSupportFragmentManager(), sDataSet);
            nsViewPager.setAdapter(adapterViewPager);
            nsViewPager.setOffscreenPageLimit(adapterViewPager.getCount() + 1);

            mRecyclerViewList = findViewById(R.id.recycler_view_list);
            if (storyType.equals("image")) {

                width = AppConstant.getDisplayMetricsWidth(mContext);
                InitializeColumnWidth(NUM_OF_COLUMN);

                new LoadImageAsync(mRecyclerViewList, true).execute();

            } else {
                getStickers();
                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT);

                layoutParams.setMargins(0, 0, 0,
                        (int) mContext.getResources().getDimension(R.dimen.margin_10dp));
                layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                mCaptionView.setLayoutParams(layoutParams);
                mTapFilter.setVisibility(View.VISIBLE);
                mRecyclerViewList.setVisibility(View.GONE);
                mStoryCaption.add(0, "");
            }
        } else {
            SnackbarUtils.displayMultiLineSnackbarWithAction(mContext, findViewById(android.R.id.content), message, mContext.getResources().
                    getString(R.string.try_again), new SnackbarUtils.OnSnackbarActionClickListener() {

                @Override
                public void onSnackbarActionClick() {
                    selectMediaFromGallery();
                }
            });
        }
    }

    @Override
    public void onThumbnailClick(Filter filter) {
        PhotoFilterFragment fragment = (PhotoFilterFragment) fragmentArrayList.get(recentSelected);
        fragment.onThumbnailClick(filter);
    }


    class MyPagerAdapter extends UpdatableFragmentPagerAdapter {

        private final List<Integer> mItems;

        public MyPagerAdapter(FragmentManager fragmentManager, List<Integer> items) {
            super(fragmentManager);
            fragmentArrayList = new ArrayList<>();
            mItems = items;
        }

        // Returns total number of pages
        @Override
        public int getCount() {
            if (storyType.equals("image")) {
                return mSelectPath.size();
            } else {
                return 1;
            }
        }

        @Override
        public long getItemId(int position) {
            return mItems.get(position);
        }

        @Override
        public int getItemPosition(Object object) {
            PhotoFilterFragment item = (PhotoFilterFragment) object;
            int itemValue = item.getSomeIdentifier();
            for (int i = 0; i < mItems.size(); i++) {
                if (mItems.get(i).equals(itemValue)) {
                    return i;
                }
            }
            return POSITION_NONE;
        }

        // Returns the fragment to display for that page
        @Override
        public Fragment getItem(int position) {
            String image;
            if (storyType.equals("image")) {
                image = mSelectPath.get(position);
            } else {
                image = videoPath;
            }

            Bundle bundle = new Bundle();
            bundle.putString(ConstantVariables.IMAGE, image);
            bundle.putString("type", storyType);
            bundle.putInt("position", position);

            if (mStickerResponse != null)
                bundle.putString(ConstantVariables.RESPONSE_OBJECT, mStickerResponse.toString());

            Fragment returnFragment;
            if (fragmentArrayList != null && position < fragmentArrayList.size()) {
                returnFragment = fragmentArrayList.get(position);
            } else {
                returnFragment = new PhotoFilterFragment();
                returnFragment.setArguments(bundle);
                fragmentArrayList.add(position, returnFragment);
            }

            return returnFragment;
        }

        // Returns the page title for the top indicator
        @Override
        public CharSequence getPageTitle(int position) {
            return "Page " + position;
        }
    }

    private void InitializeColumnWidth(int numColumn) {
        Resources r = getResources();
        float padding = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                AppConstant.GRID_PADDING, r.getDisplayMetrics());

        // Column width
        columnWidth = (int) ((mAppConst.getScreenWidth() - ((10 + 1) * padding)) /
                numColumn);
    }

}
