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

package com.socialengineaddons.mobileapp.classes.modules.story;

import android.Manifest;
import android.app.Activity;
import android.app.DownloadManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.PorterDuff;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.text.Html;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.Timeline;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
import com.google.android.exoplayer2.ui.PlayerView;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSourceFactory;
import com.google.android.exoplayer2.util.Util;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.VideoLightBox;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnImageLoadingListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnMenuClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnPopUpDismissListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnViewTouchListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.messages.CreateNewMessage;
import com.socialengineaddons.mobileapp.classes.modules.story.photofilter.PhotoEditActivity;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class StoryView extends AppCompatActivity implements StoriesProgressView.StoriesListener,
        View.OnClickListener, OnPopUpDismissListener, OnMenuClickResponseListener {

    // Member variables.
    private Context mContext;
    private View mRootView;
    private StoriesProgressView storiesProgressView;
    private TextView tvUserName, tvStoryTime, tvViewCount, tvWriteMessage, tvAddToStory, tvStoryCaption;
    private ImageView ivMain, ivUserProfile, ivOptionMenu, ivCloseIcon;
    private ProgressBar pbLoading;
    private int storyId, mUserId, counter = 0;
    private boolean isStoryDeleted = false, mIsMyStory = false, mIsVideoLoading = false, mIsPhotoLoading = false,
            mIsActivityRunning = true, isPopUpShowing = false, canSendMessage = false;
    private String mStoryResponse, mUserName;
    private JSONArray mStoryArray, mGutterMenuArray;
    private AppConstant mAppConst;
    private GutterMenuUtils mGutterMenuUtils;
    private AlertDialogWithAction mAlertDialogWithAction;
    private Intent storyIntent;
    private ImageLoader mImageLoader;
    private boolean isTextExpanded = false;
    private String fullCaption, shortCaption;
    private RelativeLayout mBottomView;

    private PlayerView playerView;
    private SimpleExoPlayer exoPlayer;
    private boolean ifOverlayLoaded = false;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_story_view);

        // Getting references of member variables.
        mContext = StoryView.this;
        mAppConst = new AppConstant(mContext);
        mGutterMenuUtils = new GutterMenuUtils(mContext);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        mImageLoader = new ImageLoader(mContext);
        mGutterMenuUtils.setOnMenuClickResponseListener(this);
        mGutterMenuUtils.setOnPopUpDismissListener(this);
        mStoryResponse = getIntent().getStringExtra("story_response");
        storyId = getIntent().getIntExtra(ConstantVariables.STORY_ID, 0);
        mIsMyStory = getIntent().getBooleanExtra("is_my_story", false);

        //getting views.
        getViews();

        // Set details.
        storiesProgressView.setStoriesListener(this);
        makeRequest();
    }

    /**
     * Method to get all views.
     */
    private void getViews() {
        mRootView = findViewById(R.id.main_view);
        storiesProgressView = (StoriesProgressView) findViewById(R.id.stories);
        tvUserName = (TextView) findViewById(R.id.user_name);
        tvStoryTime = (TextView) findViewById(R.id.story_time);
        mBottomView = (RelativeLayout) findViewById(R.id.bottom_view);
        tvViewCount = (TextView) findViewById(R.id.view_count);
        tvStoryCaption = (TextView) findViewById(R.id.story_caption);
        tvWriteMessage = (TextView) findViewById(R.id.write_message);
        tvAddToStory = (TextView) findViewById(R.id.add_to_story);
        ivMain = (ImageView) findViewById(R.id.image);
        ivUserProfile = (ImageView) findViewById(R.id.user_image);
        ivOptionMenu = (ImageView) findViewById(R.id.optionMenu);
        playerView = (PlayerView) findViewById(R.id.exo_video_player);
        pbLoading = (ProgressBar) findViewById(R.id.loadingProgress);
        ivOptionMenu.setColorFilter(ContextCompat.getColor(mContext, R.color.white), PorterDuff.Mode.SRC_IN);
        ivCloseIcon = (ImageView) findViewById(R.id.closeIcon);
        ivCloseIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.white), PorterDuff.Mode.SRC_IN);
    }

    private void makeRequest() {
        pbLoading.setVisibility(View.VISIBLE);
        String url;
        url = AppConstant.DEFAULT_URL + "advancedactivity/story/view/" + storyId;

        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {

            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                try {
                    pbLoading.setVisibility(View.GONE);
                    if (jsonObject.optJSONArray("response") != null) {
                        mStoryResponse = jsonObject.optJSONArray("response").toString();
                        setDetails();
                    } else {
                        finish();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                pbLoading.setVisibility(View.GONE);
                if (message.equals(ConstantVariables.STORY_PLUGIN_DISABLED)) {
                    message = mContext.getResources().getString(R.string.user_does_not_have_access_resources);
                }
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
     * Method to set details for each image view.
     */
    private void setDetails() {
        try {
            mStoryArray = new JSONArray(mStoryResponse);
            if (mStoryArray.length() > 0) {

                long duration[] = new long[mStoryArray.length()];
                for (int i = 0; i < mStoryArray.length(); i++) {
                    JSONObject storyObject = mStoryArray.optJSONObject(i);
                    duration[i] = storyObject.optInt("duration") == 0 ? 3400L : storyObject.optInt("duration") * 1000L;

                    if (i == mStoryArray.length() -1 ) {
                        storiesProgressView.setStoriesCountWithDurations(duration);
                    }
                }

                showStory(counter);
                JSONObject storyObject = mStoryArray.optJSONObject(counter);
                if (storyObject.optString("videoUrl") == null || storyObject.optString("videoUrl").isEmpty()) {
                    storiesProgressView.startStories();
                } else {
                    storiesProgressView.startStoriesWithPause(counter);
                }

                mRootView.setOnTouchListener(new OnViewTouchListener(mContext) {

                    @Override
                    public void onLongPressed() {

                    }

                    @Override
                    public void onLongPressedCustom() {
                        if (!mIsVideoLoading && !mIsPhotoLoading) {
                            playPauseVideo(counter, false);
                        }
                        checkForVisibility(false);
                    }

                    @Override
                    public void onTouchRelease() {

                        // If video/image is currently loading then not doing any action
                        // otherwise performing action accordingly.
                        if (!mIsVideoLoading && !mIsPhotoLoading) {
                            playPauseVideo(counter, true);
                        }

                        if (isTextExpanded){
                            isTextExpanded = false;
                            tvStoryCaption.setText(Html.fromHtml(shortCaption));
                        } else {
                            checkForVisibility(true);
                        }

                    }

                    @Override
                    public void onLeftClick() {
                        if (isTextExpanded){
                            isTextExpanded = false;
                            tvStoryCaption.setText(Html.fromHtml(shortCaption));
                            if (!mIsVideoLoading && !mIsPhotoLoading) {
                                playPauseVideo(counter, true);
                            }
                        } else {
                            storiesProgressView.reverse();
                        }
                    }

                    @Override
                    public void onRightClick() {
                        if (isTextExpanded){
                            isTextExpanded = false;
                            tvStoryCaption.setText(Html.fromHtml(shortCaption));
                            if (!mIsVideoLoading && !mIsPhotoLoading) {
                                playPauseVideo(counter, true);
                            }
                        } else {
                            storiesProgressView.skip();
                            pauseAnimationForVideo(counter);
                        }
                    }

                    @Override
                    public void onTopToBottomSwipe() {
                        finish();
                    }

                    @Override
                    public void onSwipeLeft() {
                        displayPreviousStory();
                    }

                    @Override
                    public void onSwipeRight() {
                        storiesProgressView.setLast();
                    }

                });

                ivUserProfile.setOnClickListener(this);
                ivCloseIcon.setOnClickListener(this);
                tvUserName.setOnClickListener(this);
                ivOptionMenu.setOnClickListener(this);
                tvViewCount.setOnClickListener(this);
                tvWriteMessage.setOnClickListener(this);
                tvAddToStory.setOnClickListener(this);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    /**
     * Method to show story media for each position.
     *
     * @param position Position of story.
     */
    private void showStory(final int position) {

        JSONObject storyObject = mStoryArray.optJSONObject(position);
        String image = storyObject.optString("image");
        String userImage = storyObject.optString("owner_image_profile");
        mUserId = storyObject.optInt("owner_id");
        storyId = storyObject.optInt("story_id");
        isStoryDeleted = storyObject.optBoolean("isDeleted");
        mUserName = storyObject.optString("owner_title");
        canSendMessage = storyObject.optInt("isSendMessage") == 1;
        String storyCaption = storyObject.optString("description");

        // Showing story owner name and story creation time.
        tvUserName.setText(mUserName);
        tvStoryTime.setText(AppConstant.convertDateFormat(mContext.getResources(), storyObject.optString("create_date")));

        // Display story owner image.
        mImageLoader.setImageForUserProfile(userImage, ivUserProfile);

        // Checking if the story is video or photo.
        if (isVideoStory(position)) {

            /* Close pip window if video is playing in it */
            GlobalFunctions.checkAndFinishPipWindow();

            // Making videoLoading true.
            mIsVideoLoading = true;
            mIsPhotoLoading = false;

            pbLoading.setVisibility(View.VISIBLE);
            pbLoading.bringToFront();

            String overlayImage = null;
            if (storyObject.optJSONObject("video_overlay_image") != null) {
                overlayImage = storyObject.optJSONObject("video_overlay_image").optString("url");
            }

            initializePlayer(storyObject.optString("videoUrl"), position, overlayImage);

        } else {
            // If the Story is photo type then making videoLoading false.
            mIsVideoLoading = false;
            mIsPhotoLoading = true;

            // If any video is playing then stopping it.
            releasePlayer();
            playerView.setVisibility(View.GONE);
            ivMain.setVisibility(View.VISIBLE);
            pbLoading.bringToFront();
            pbLoading.setVisibility(View.VISIBLE);
            if (storiesProgressView.getAnimatorSize() != 0) {
                storiesProgressView.stopAnimation(counter);
            }
        }

        tvWriteMessage.setTag(String.valueOf(storyId));

        // Showing the story view count.
        tvViewCount.setText(String.valueOf(storyObject.optInt("view_count")));
        mGutterMenuArray = storyObject.optJSONArray("gutterMenu");

        setCaptionInView(storyCaption);

        checkForVisibility(true);

        // Making server call to mark the story as viewed.
        if (storyObject.optInt("isViewed") == 0) {
            mAppConst.postJsonRequest(AppConstant.DEFAULT_URL + "advancedactivity/story/viewer-count/" + storyId);
        }

        // Showing story main image into Main ImageView.
        mImageLoader.setImageWithCallbackListener(image, ivMain, new OnImageLoadingListener() {
            @Override
            public void onLoadFailed() {
                mIsPhotoLoading = false;
                if (!isVideoStory(counter) && mIsActivityRunning && !isPopUpShowing) {
                    pbLoading.setVisibility(View.GONE);
                    storiesProgressView.playAnimation(counter);
                }

            }

            @Override
            public void onResourceReady() {
                mIsPhotoLoading = false;
                if (!isVideoStory(counter) && mIsActivityRunning && !isPopUpShowing) {
                    pbLoading.setVisibility(View.GONE);
                    storiesProgressView.playAnimation(counter);
                }
            }
        });
    }

    private void initializePlayer(String videoURL, int position, String overlayImage) {
        exoPlayer = ExoPlayerFactory.newSimpleInstance(mContext);

        playerView.setPlayer(exoPlayer);
        boolean playWhenReady = true;
        ifOverlayLoaded = false;

        exoPlayer.setPlayWhenReady(playWhenReady);
        MediaSource mediaSource = buildMediaSource(videoURL);
        exoPlayer.prepare(mediaSource, true, false);

        exoPlayer.addListener(new Player.EventListener() {
            @Override
            public void onTimelineChanged(Timeline timeline, Object manifest, int reason) {

            }

            @Override
            public void onTracksChanged(TrackGroupArray trackGroups, TrackSelectionArray trackSelections) {

            }

            @Override
            public void onLoadingChanged(boolean isLoading) {

            }

            @Override
            public void onPlayerStateChanged(boolean playWhenReady, int playbackState) {
                switch (playbackState) {
                    case ExoPlayer.STATE_READY:
                        pbLoading.setVisibility(View.GONE);
                        if (!ifOverlayLoaded) {
                            ifOverlayLoaded = true;
                            if (overlayImage != null && !overlayImage.isEmpty()) {
                                ivMain.setVisibility(View.VISIBLE);
                                ivMain.setImageDrawable(null);
                                try {
                                    mImageLoader.setReactionImageUrl(overlayImage, ivMain);
                                } catch (IllegalArgumentException e) {
                                    e.printStackTrace();
                                }
                            } else {
                                ivMain.setVisibility(View.GONE);
                            }
                        }

                        playerView.setVisibility(View.VISIBLE);
                        if (mIsActivityRunning && !isPopUpShowing) {
                            storiesProgressView.playAnimation(position);
                        }
                        break;
                    case ExoPlayer.STATE_BUFFERING:
                        pbLoading.setVisibility(View.VISIBLE);
                        storiesProgressView.stopAnimation(counter);
                        break;
                }
            }

            @Override
            public void onRepeatModeChanged(int repeatMode) {

            }

            @Override
            public void onShuffleModeEnabledChanged(boolean shuffleModeEnabled) {

            }

            @Override
            public void onPlayerError(ExoPlaybackException error) {

            }

            @Override
            public void onPositionDiscontinuity(int reason) {

            }

            @Override
            public void onPlaybackParametersChanged(PlaybackParameters playbackParameters) {

            }

            @Override
            public void onSeekProcessed() {

            }
        });
    }

    private MediaSource buildMediaSource(String videoUrl) {

        Uri uri = Uri.parse(videoUrl);

        if (videoUrl.contains(".m3u8")) {
            DefaultBandwidthMeter defaultBandwidthMeter = new DefaultBandwidthMeter();
            // Produces DataSource instances through which media data is loaded.
            DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(mContext,
                    Util.getUserAgent(mContext, "Exo2"), defaultBandwidthMeter);

            Handler mainHandler = new Handler();
            return new HlsMediaSource(uri,
                    dataSourceFactory, mainHandler, null);
        } else {
            return new ExtractorMediaSource.Factory(
                    new DefaultHttpDataSourceFactory("exoplayer-codelab")).
                    createMediaSource(uri);
        }

    }

    private void releasePlayer() {
        if (exoPlayer != null) {
            exoPlayer.release();
            exoPlayer = null;
        }
    }

    private void setCaptionInView(String description) {
        if (description != null && !description.isEmpty()) {
            fullCaption = description;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                if (description.length() < 100) {
                    tvStoryCaption.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
                } else {
                    tvStoryCaption.setTextAlignment(View.TEXT_ALIGNMENT_VIEW_START);
                }
            }

            if (description.length() > ConstantVariables.STORY_WORD_LIMIT) {
                shortCaption = description.substring(0, ConstantVariables.STORY_WORD_LIMIT) + "... <b>See more</b>";
                tvStoryCaption.setText(Html.fromHtml(shortCaption));
                tvStoryCaption.setClickable(true);
                tvStoryCaption.setOnClickListener(this);
            } else {
                tvStoryCaption.setClickable(false);
                tvStoryCaption.setText(fullCaption);
            }
            tvStoryCaption.setVisibility(View.VISIBLE);

        } else {
            tvStoryCaption.setVisibility(View.GONE);
            tvStoryCaption.setText("");
        }
    }

    /**
     * Method to check view's visibility when long pressed and released.
     *
     * @param isNeedToShow If true then showing view accordingly.
     */
    private void checkForVisibility(boolean isNeedToShow) {
        if (isNeedToShow) {
            findViewById(R.id.user_info_layout).setVisibility(View.VISIBLE);
            ivUserProfile.setVisibility(View.VISIBLE);
            ivOptionMenu.setVisibility(View.VISIBLE);
            ivCloseIcon.setVisibility(View.VISIBLE);
            if (mGutterMenuArray != null && mGutterMenuArray.length() > 0 && !isStoryDeleted) {
                ivOptionMenu.setVisibility(View.VISIBLE);
            } else {
                ivOptionMenu.setVisibility(View.GONE);
            }
            tvAddToStory.setVisibility(mIsMyStory ? View.VISIBLE : View.GONE);
            tvViewCount.setVisibility(!isStoryDeleted && mIsMyStory ? View.VISIBLE : View.GONE);
            tvWriteMessage.setVisibility(!isStoryDeleted && !mIsMyStory && canSendMessage ? View.VISIBLE : View.GONE);
            mBottomView.setVisibility(View.VISIBLE);
        } else {
            findViewById(R.id.user_info_layout).setVisibility(View.GONE);
            ivUserProfile.setVisibility(View.GONE);
            ivCloseIcon.setVisibility(View.GONE);
            ivOptionMenu.setVisibility(View.GONE);
            tvViewCount.setVisibility(View.GONE);
            tvWriteMessage.setVisibility(View.GONE);
            tvAddToStory.setVisibility(View.GONE);
            mBottomView.setVisibility(View.GONE);
        }
    }

    /**
     * Method to check if the current visible story is video type and start/pause videoplayer accordingly.
     *
     * @param position      Position of currently visible story.
     * @param isPlayRequest True if need to play video.
     */
    public void checkForVideoOption(int position, boolean isPlayRequest) {
        if (isVideoStory(position)) {
            if (isPlayRequest) {
                startPlayer();
            } else {
                pausePlayer();
            }
        }

        if (isPlayRequest) {
            storiesProgressView.playAnimation(counter);
        } else {
            storiesProgressView.stopAnimation(counter);
        }
    }


    private void pausePlayer() {
        if (exoPlayer != null) {
            exoPlayer.setPlayWhenReady(false);
            exoPlayer.getPlaybackState();
        }
    }

    private void startPlayer() {
        if (exoPlayer != null) {
            exoPlayer.setPlayWhenReady(true);
            exoPlayer.getPlaybackState();
        }
    }

    /**
     * Method to check if the current visible story is video type and start/pause videoplayer accordingly.
     *
     * @param position      Position of currently visible story.
     * @param isPlayRequest True if need to play video.
     */
    public void playPauseVideo(int position, boolean isPlayRequest) {
        if (isVideoStory(position)) {
            if (isPlayRequest) {
                startPlayer();
            } else {
                pausePlayer();
            }
        }
        if (isPlayRequest) {
            storiesProgressView.playAnimation(counter);
        } else {
            storiesProgressView.stopAnimation(counter);
        }
    }

    /**
     * Method to pause video player when new story changed from 1 video/photo type to another.
     *
     * @param position Position of currently visible story.
     */
    public void pauseAnimationForVideo(int position) {
        if (isVideoStory(position)) {
            if (mIsVideoLoading) {
                startPlayer();
            } else {
                pausePlayer();
                storiesProgressView.stopAnimation(counter);
            }
        } else if (mIsPhotoLoading) {
            storiesProgressView.stopAnimation(counter);
        }
    }

    /**
     * Method to get currently visible story is belongs to video or image.
     *
     * @param position Position of currently visible story.
     * @return Returns true if the current story is video type.
     */
    public boolean isVideoStory(int position) {
        JSONObject storyObject = mStoryArray.optJSONObject(position);
        return (storyObject.optString("videoUrl") != null && !storyObject.optString("videoUrl").isEmpty());
    }

    /**
     * Method to get video url from story.
     *
     * @param position Position of current story.
     * @return Returns the story video url.
     */
    public String getVideoUrl(int position) {
        JSONObject storyObject = mStoryArray.optJSONObject(position);
        return storyObject.optString("videoUrl");
    }

    /**
     * Method to get Image url from story.
     *
     * @param position Position of current story.
     * @return Returns the story Image url.
     */
    public String getImageUrl(int position) {
        JSONObject storyObject = mStoryArray.optJSONObject(position);
        return storyObject.optString("image");
    }

    /**
     * Method to start media picker activity for story uploading.
     */
    public void startStoryMediaPickerActivity() {
        Intent intent = new Intent(mContext, PhotoEditActivity.class);
        startActivityForResult(intent, ConstantVariables.REQUEST_STORY_POST);
        ((Activity)mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    @Override
    public void onNext() {
        counter++;
        playPauseVideo(counter, false);
        showStory(counter);
    }

    @Override
    public void onNextStarted() {
    }

    @Override
    public void onPrev() {
        if (counter - 1 < 0)
            return;

        counter--;
        playPauseVideo(counter, false);
        releasePlayer();
        showStory(counter);
    }

    @Override
    public void onComplete() {
        StoryUtils.sCurrentStory = StoryUtils.sCurrentStory + 1;
        if (StoryUtils.sCurrentStory < StoryUtils.STORY.size()
                && StoryUtils.isMuteStory.get(StoryUtils.sCurrentStory) != 1 && StoryUtils.STORY.get(StoryUtils.sCurrentStory) != 0) {
            Intent intent = getIntent();
            intent.putExtra("is_my_story", false);
            intent.putExtra(ConstantVariables.STORY_ID, StoryUtils.STORY.get(StoryUtils.sCurrentStory));
            finish();
            startActivity(intent);
        } else {
            finish();
        }
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }


    /* Display previous story on left swipe */
    public void displayPreviousStory() {
        StoryUtils.sCurrentStory = StoryUtils.sCurrentStory - 1;
        if (StoryUtils.sCurrentStory > 0
                && StoryUtils.isMuteStory.get(StoryUtils.sCurrentStory) != 1) {
            Intent intent = getIntent();
            intent.putExtra("is_my_story", false);
            intent.putExtra(ConstantVariables.STORY_ID, StoryUtils.STORY.get(StoryUtils.sCurrentStory));
            finish();
            startActivity(intent);
            overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
        } else {
            finish();
        }
    }


    @Override
    public void onPause() {
        super.onPause();
        if (storiesProgressView != null && mStoryResponse != null) {
            mIsActivityRunning = false;
            checkForVideoOption(counter, false);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        mIsActivityRunning = true;
        if (storiesProgressView != null && mStoryResponse != null && !mIsVideoLoading && !isPopUpShowing
                && !mIsPhotoLoading) {
            checkForVideoOption(counter, true);
        }
    }

    @Override
    protected void onDestroy() {
        // Very important !
        releasePlayer();
        storiesProgressView.destroy();
        super.onDestroy();
    }

    @Override
    public void finish() {
        releasePlayer();
        if (storyIntent != null) {
            setResult(ConstantVariables.REQUEST_STORY_POST, storyIntent);
        }  else {
            Intent data = new Intent();
            setResult(ConstantVariables.STORY_VIEW_PAGE_CODE, data);
        }
        super.finish();
    }

    @Override
    public void onClick(View view) {

        Intent intent;
        switch (view.getId()) {

            case R.id.user_name:
            case R.id.user_image:
                intent = new Intent(mContext, userProfile.class);
                intent.putExtra(ConstantVariables.USER_ID, mUserId);
                startActivityForResult(intent, ConstantVariables.VIEW_PAGE_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.optionMenu:
                mGutterMenuUtils.showPopup(view, counter, mGutterMenuArray,
                        new BrowseListItems(), ConstantVariables.STORY_MENU_TITLE);
                isPopUpShowing = true;
                playPauseVideo(counter, false);
                break;

            case R.id.view_count:
                intent = new Intent(mContext, FragmentLoadActivity.class);
                intent.putExtra("story_id", storyId);
                intent.putExtra(ConstantVariables.CONTENT_TITLE, mContext.getResources().getString(R.string.story_viewers));
                intent.putExtra(ConstantVariables.FRAGMENT_NAME, "story_viewer");
                intent.putExtra("isStoryViewer", true);
                startActivityForResult(intent, ConstantVariables.VIEW_PAGE_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.write_message:
                intent = new Intent(mContext, CreateNewMessage.class);
                intent.putExtra("isStoryReply", true);
                intent.putExtra(ConstantVariables.USER_ID, mUserId);
                intent.putExtra(ConstantVariables.STORY_ID, (String) view.getTag());
                intent.putExtra(ConstantVariables.CONTENT_TITLE, mUserName);
                if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                    intent.putExtra(ConstantVariables.SEND_MESSAGE_IN_MESSENGER, true);
                }
                startActivityForResult(intent, ConstantVariables.VIEW_PAGE_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.add_to_story:
                if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            ConstantVariables.WRITE_EXTERNAL_STORAGE);
                } else {
                    startStoryMediaPickerActivity();
                }
                break;

            case R.id.closeIcon:
                onBackPressed();
                break;

            case R.id.story_caption:
                if (!isTextExpanded) {
                    tvStoryCaption.setText(fullCaption);
                    if (mIsVideoLoading && !mIsPhotoLoading) {
                        playPauseVideo(counter, false);
                    }
                } else {
                    tvStoryCaption.setText(Html.fromHtml(shortCaption));
                    if (mIsVideoLoading && !mIsPhotoLoading) {
                        playPauseVideo(counter, true);
                    }
                }
                isTextExpanded = !isTextExpanded;
                break;
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (resultCode) {
            case RESULT_OK:
                if (data != null && requestCode == ConstantVariables.REQUEST_STORY_IMAGE_VIDEO) {
                    redirectToImageFilter(data);
                }
                break;

            case ConstantVariables.REQUEST_STORY_POST:
                if (data != null) {
                    storyIntent = data;
                    setResult(ConstantVariables.REQUEST_STORY_POST, storyIntent);
                    finish();
                }
                break;

            case ConstantVariables.PAGE_EDIT_CODE:
                if (requestCode == ConstantVariables.PAGE_EDIT_CODE && data != null) {
                    String jsonObject = data.getStringExtra("response");
                    try {
                        JSONObject responseObject = new JSONObject(jsonObject);
                        String description = responseObject.optJSONObject("body").optString("description");
                        mStoryArray.optJSONObject(counter).put("description", description);
                        setCaptionInView(description);

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                checkForVideoOption(counter, true);
                break;

            case ConstantVariables.STORY_VIEW_PAGE_CODE:
            case RESULT_CANCELED:
                if (requestCode == ConstantVariables.REQUEST_STORY_POST
                        || requestCode == ConstantVariables.PAGE_EDIT_CODE) {
                    checkForVideoOption(counter, true);
                }
                break;
        }

        if (requestCode == ConstantVariables.VIEW_PAGE_CODE) {
            checkForVideoOption(counter, true);
        }
    }

    private void redirectToImageFilter(Intent data) {
        ArrayList<String> selectPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);
        String selectedVideoPath = data.getStringExtra(MultiMediaSelectorActivity.VIDEO_RESULT);

        Intent intent = new Intent(mContext, PhotoEditActivity.class);
        intent.putStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT, selectPath);
        intent.putExtra(MultiMediaSelectorActivity.VIDEO_RESULT, selectedVideoPath);
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_DEFAULT_SELECTED_LIST, ConstantVariables.STORY_POST_COUNT_LIMIT);
        startActivityForResult(intent, ConstantVariables.REQUEST_STORY_POST);

        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission granted, proceed to the normal flow
                    startStoryMediaPickerActivity();
                } else {
                    // If user press deny in the permission popup
                    if (ActivityCompat.shouldShowRequestPermissionRationale((Activity) mContext,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE)) {

                        // Show an expanation to the user After the user
                        // sees the explanation, try again to request the permission.

                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    } else {
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.

                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, findViewById(R.id.rootView),
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    }
                }
                break;
        }
    }

    @Override
    public void onPopUpDismiss(boolean isDismissed) {
        isPopUpShowing = false;
        if (!isTextExpanded) {
            playPauseVideo(counter, true);
        }
    }

    @Override
    public void onItemDelete(int position) {
        JSONObject storyObject = mStoryArray.optJSONObject(position);
        try {
            storyObject.put("isDeleted", true);
            mStoryArray.put(position, storyObject);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        isPopUpShowing = false;
        ivOptionMenu.setVisibility(View.GONE);
        tvViewCount.setVisibility(View.GONE);
        if (!mIsVideoLoading && !mIsPhotoLoading) {
            checkForVideoOption(counter, true);
        }
        storiesProgressView.skip();
        pauseAnimationForVideo(counter);
    }

    @Override
    public void onItemActionSuccess(int position, Object itemList, String menuName) {

        isPopUpShowing = false;
        switch (menuName) {
            case "save":
                downloadMedia(getImageUrl(position), "Image");
                break;
            case "save_video":
                downloadMedia(getVideoUrl(position), "Video");
                break;
            case "mute":
                storiesProgressView.setLast();
                break;
        }
    }

    /**
     * Method to download media.
     *
     * @param mediaUrl Media(Image/Video) url.
     * @param fileType Type of media.
     */
    private void downloadMedia(String mediaUrl, String fileType) {

        String message;
        if (mediaUrl != null && !mediaUrl.isEmpty() && !mediaUrl.equals("null")) {

            // Getting the DownloadManager Request.
            DownloadManager.Request request = new DownloadManager.Request(Uri.parse(mediaUrl));
            request.setTitle(mContext.getResources().getString(R.string.app_name) + "_" + fileType);
            request.allowScanningByMediaScanner();
            request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
            request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS,
                    mContext.getResources().getString(R.string.app_name) + "_" + fileType);

            // Get download service and enqueue file
            DownloadManager manager = (DownloadManager) getSystemService(Context.DOWNLOAD_SERVICE);
            manager.enqueue(request);
            if (fileType.equals("Image")) {
                message = mContext.getResources().getString(R.string.photo_saved_success_message);
            } else {
                message = mContext.getResources().getString(R.string.video_saved_success_message);
            }
        } else {
            message = mContext.getResources().getString(R.string.url_not_valid);
        }
        SnackbarUtils.displaySnackbar(mRootView, message);
    }
}
