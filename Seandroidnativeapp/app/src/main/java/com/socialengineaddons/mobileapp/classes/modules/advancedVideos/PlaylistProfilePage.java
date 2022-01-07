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

package com.socialengineaddons.mobileapp.classes.modules.advancedVideos;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.AppBarLayout;
import android.support.design.widget.CollapsingToolbarLayout;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.AdvModulesRecyclerViewAdapter;
import com.socialengineaddons.mobileapp.classes.common.activities.VideoLightBox;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnOptionItemClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.GetVideoDataSourceUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.LinearDividerItemDecorationUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoLightBoxActivity;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Class to show playlist of videos. And play all the videos in the cover layout of the view.
 */
public class PlaylistProfilePage extends AppCompatActivity implements AppBarLayout.OnOffsetChangedListener,
        OnOptionItemClickResponseListener {

    // Member variables.
    private Context mContext;
    private View mRootView;
    private ImageView ivCoverImage;
    private TextView tvTitle, tvToolBarTitle;
    private CollapsingToolbarLayout collapsingToolbar;
    private RecyclerView mRecyclerView;
    private RelativeLayout rlTitleBlock, rlVideoPlayer;
    private FloatingActionButton fabPlayAll;
    private ProgressBar mProgressBar;
    private Toolbar mToolbar;
    private String mPlaylistProfileUrl, mTitle;
    private int mContentId;
    private boolean isContentEdited = false, isContentDeleted = false, isVideoPlaying = false;
    private JSONObject mBody;
    private JSONArray mGutterMenus;
    private List<Object> mBrowseItemList;
    private ArrayList<PhotoListDetails> mCoverImageDetails;
    private BrowseListItems mBrowseList;
    private AppConstant mAppConst;
    private GutterMenuUtils mGutterMenuUtils;
    private GetVideoDataSourceUtils mGetVideoDataSourceUtils;
    private RecyclerView.Adapter mBrowseAdapter;
    private ImageLoader mImageLoader;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_playlist_view);

        // Initializing member variables.
        mContext = PlaylistProfilePage.this;
        mAppConst = new AppConstant(this);
        mGutterMenuUtils = new GutterMenuUtils(this);
        mBrowseItemList = new ArrayList<>();
        mCoverImageDetails = new ArrayList<>();
        mGutterMenuUtils.setOnOptionItemClickResponseListener(this);
        mImageLoader = new ImageLoader(getApplicationContext());

        // Getting all the views.
        getViews();

        /** Getting Intent Key's. **/
        mContentId = getIntent().getIntExtra(ConstantVariables.VIEW_ID, 0);
        mPlaylistProfileUrl = getIntent().getStringExtra(ConstantVariables.VIEW_PAGE_URL);
        if (mPlaylistProfileUrl == null || mPlaylistProfileUrl.isEmpty()) {
            mPlaylistProfileUrl = AppConstant.DEFAULT_URL + "advancedvideo/playlist/view/" + mContentId
                    + "?gutter_menu=1";
        }
        // If response coming from create page.
        mBody = GlobalFunctions.getCreateResponse(getIntent().getStringExtra(ConstantVariables.EXTRA_CREATE_RESPONSE));

        //Getting the reference of adapter.
        mBrowseAdapter = new AdvModulesRecyclerViewAdapter(mContext, mBrowseItemList, "videos",
                ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE, new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {

                // Making video playing option visible.
                BrowseListItems listItems = (BrowseListItems) mBrowseItemList.get(position);

                if (!listItems.isAllowToView()) {
                    SnackbarUtils.displaySnackbar(mRootView, mContext.getResources().
                            getString(R.string.unauthenticated_view_message));
                } else {
                    Intent lightBox = new Intent(mContext, VideoLightBox.class);
                    Bundle args = new Bundle();
                    args.putString(ConstantVariables.VIDEO_URL, listItems.getmVideoUrl());
                    args.putInt(ConstantVariables.VIDEO_TYPE, listItems.getmVideoType());
                    lightBox.putExtras(args);
                    startActivity(lightBox);
                    overridePendingTransition(R.anim.slide_up_in, R.anim.push_down_out);
                }
            }
        });
        mRecyclerView.setAdapter(mBrowseAdapter);

        // Calling to server.
        // Load Data Directly if Coming from Create Page.
        if (mBody != null && mBody.length() != 0) {
            isContentEdited = true;
            loadViewPageData(mBody);
        } else {
            makeRequest();
        }
    }

    /**
     * Method to get all the view page views.
     */
    private void getViews() {

        // Getting header views.
        mRootView = findViewById(R.id.main_layout);
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(mToolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(getResources().getString(R.string.blank_string));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        mRecyclerView = (RecyclerView) findViewById(R.id.recycler_view);
        mRecyclerView.setHasFixedSize(true);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(mContext);
        mRecyclerView.setLayoutManager(linearLayoutManager);

        fabPlayAll = (FloatingActionButton) findViewById(R.id.play_all_btn);
        collapsingToolbar = (CollapsingToolbarLayout) findViewById(R.id.collapsing_toolbar);
        AppBarLayout appBarLayout = (AppBarLayout) findViewById(R.id.appbar);
        appBarLayout.addOnOffsetChangedListener(this);
        tvToolBarTitle = (TextView) findViewById(R.id.toolbar_title);
        tvToolBarTitle.setSelected(true);
        ivCoverImage = (ImageView) findViewById(R.id.cover_image);
        tvTitle = (TextView) findViewById(R.id.content_title);
        mProgressBar = (ProgressBar) findViewById(R.id.progressBar);

        rlTitleBlock = (RelativeLayout) findViewById(R.id.title_block);
        fabPlayAll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                BrowseListItems listItems = (BrowseListItems) mBrowseItemList.get(1);
                Intent lightBox = new Intent(mContext, VideoLightBox.class);
                Bundle args = new Bundle();
                args.putString(ConstantVariables.VIDEO_URL, listItems.getmVideoUrl());
                args.putInt(ConstantVariables.VIDEO_TYPE, listItems.getmVideoType());
                lightBox.putExtras(args);
                startActivity(lightBox);
                overridePendingTransition(R.anim.slide_up_in, R.anim.push_down_out);

            }
        });
    }

    /**
     * Sending request to server to get the view page data.
     */
    private void makeRequest() {
        mAppConst.getJsonResponseFromUrl(mPlaylistProfileUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mBody = jsonObject;
                loadViewPageData(mBody);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mProgressBar.setVisibility(View.GONE);
                SnackbarUtils.displaySnackbarLongWithListener(mRootView, message,
                        new SnackbarUtils.OnSnackbarDismissListener() {
                            @Override
                            public void onSnackbarDismissed() {
                                finish();
                            }
                        });
            }
        });
    }

    /**
     * Method to get view page data.
     *
     * @param bodyJsonObject jsonObject, which contains view page data.
     */
    private void loadViewPageData(JSONObject bodyJsonObject) {
        try {
            if (bodyJsonObject != null && bodyJsonObject.length() != 0) {
                mProgressBar.setVisibility(View.GONE);
                mGutterMenus = bodyJsonObject.optJSONArray("gutterMenu");
                JSONObject responseObject = bodyJsonObject.optJSONObject("response");
                mTitle = responseObject.optString("title");
                mContentId = responseObject.optInt("playlist_id");
                int ownerId = responseObject.optInt("owner_id");
                String contentUrl = responseObject.optString("content_url");
                String coverImageUrl = responseObject.optString("image");
                String ownerImage = responseObject.optString("owner_image");
                String ownerTitle = responseObject.optString("owner_title");
                int likeCount = responseObject.optInt("like_count");
                int viewCount = responseObject.optInt("view_count");

                mBrowseList = new BrowseListItems(mContentId, mTitle, coverImageUrl, contentUrl);
                mBrowseItemList.clear();
                mBrowseItemList.add(0, new BrowseListItems(mContentId, ownerTitle, ownerImage, ownerId, likeCount, viewCount));
                if (mGutterMenus != null) {
                    invalidateOptionsMenu();
                }

                //Setting data in views
                tvTitle.setText(mTitle);
                collapsingToolbar.setTitle(mTitle);
                tvToolBarTitle.setText(mTitle);
                CustomViews.setCollapsingToolBarTitle(collapsingToolbar);
                // Showing cover image.
                mImageLoader.setImageUrl(coverImageUrl, ivCoverImage);
                // Adding cover image into list to display it in PhotoLightBox.
                mCoverImageDetails.clear();
                mCoverImageDetails.add(new PhotoListDetails(coverImageUrl));
                ivCoverImage.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Bundle bundle = new Bundle();
                        bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mCoverImageDetails);
                        Intent lightBoxIntent = new Intent(mContext, PhotoLightBoxActivity.class);
                        lightBoxIntent.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, 1);
                        lightBoxIntent.putExtra(ConstantVariables.SHOW_OPTIONS, false);
                        lightBoxIntent.putExtras(bundle);
                        startActivity(lightBoxIntent);
                    }
                });

                // Showing videos data.
                JSONArray videosArray = bodyJsonObject.optJSONArray("videos");
                if (videosArray != null && videosArray.length() > 0) {
                    fabPlayAll.setVisibility(View.VISIBLE);
                    mRecyclerView.addItemDecoration(new LinearDividerItemDecorationUtil(mContext));
                    loadVideosResponse(videosArray);
                } else {
                    fabPlayAll.setVisibility(View.GONE);
                    mBrowseAdapter.notifyDataSetChanged();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Method to load videos into recycler view.
     *
     * @param videosArray JsonArray of videos.
     */
    private void loadVideosResponse(JSONArray videosArray) {

        for (int i = 0; i < videosArray.length(); i++) {
            JSONObject jsonDataObject = videosArray.optJSONObject(i);
            int videoId = jsonDataObject.optInt("video_id");
            int duration = jsonDataObject.optInt("duration");
            String title = jsonDataObject.optString("title");
            String ownerTitle = jsonDataObject.optString("owner_title");
            if (jsonDataObject.optInt("owner_id") == 0) {
                ownerTitle = mContext.getResources().getString(R.string.deleted_member_text);
            }
            String image = jsonDataObject.optString("image");
            int allowToView = jsonDataObject.optInt("allow_to_view");
            String videoUrl = jsonDataObject.optString("video_url");
            int type = jsonDataObject.optInt("type");
            int isRemoveOption = jsonDataObject.optInt("is_remove");
            mBrowseItemList.add(new BrowseListItems(videoId, title, ownerTitle, image, duration, videoUrl,
                    type, allowToView == 1, isRemoveOption == 1));

        }
        mBrowseAdapter.notifyDataSetChanged();
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
        } else if (mGutterMenus != null) {
            mGutterMenuUtils.onMenuOptionItemSelected(findViewById(R.id.main_content),
                    findViewById(item.getItemId()), id, mGutterMenus);
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {

        menu.clear();
        if (mGutterMenus != null) {
            mGutterMenuUtils.showOptionMenus(menu, mGutterMenus, ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE,
                    mBrowseList);
        }

        // If video is playing then showing the video player layout and hide the cover image layout.
        // And add the close icon to stop the video player.
        if (isVideoPlaying) {
            rlTitleBlock.setVisibility(View.GONE);
            ivCoverImage.setVisibility(View.GONE);
            menu.add(Menu.NONE, R.id.close_player, Menu.NONE,
                    mContext.getResources().getString(R.string.close_group_label)).
                    setIcon(R.drawable.ic_close_white_24dp).
                    setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public void onBackPressed() {
        if (!isFinishing()) {
            /*
            Set Result to Manage page to refresh the page if any changes made in the content.
             */
            if (isContentEdited || isContentDeleted) {
                Intent intent = new Intent();
                setResult(ConstantVariables.VIEW_PAGE_CODE, intent);
            }
            super.onBackPressed();
            overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
        }
    }

    @Override
    public void onItemDelete(String successMessage) {
        // Show Message
        SnackbarUtils.displaySnackbarShortWithListener(mRootView, successMessage,
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

    }

    @Override
    public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
        CustomViews.showMarqueeTitle(verticalOffset, collapsingToolbar, mToolbar, tvToolBarTitle, mTitle);
    }

}
