package com.socialengineaddons.mobileapp.classes.common.activities;

import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AppOpsManager;
import android.app.PendingIntent;
import android.app.PictureInPictureParams;
import android.app.RemoteAction;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.drawable.Icon;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.DrawableRes;
import android.support.annotation.RequiresApi;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatCheckBox;
import android.util.Rational;
import android.view.LayoutInflater;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.Timeline;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
import com.google.android.exoplayer2.ui.AspectRatioFrameLayout;
import com.google.android.exoplayer2.ui.PlayerControlView;
import com.google.android.exoplayer2.ui.PlayerView;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.ui.BezelImageView;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.FeedsFragment;
import com.socialengineaddons.mobileapp.classes.modules.autoplayvideo.Utils;
import java.io.File;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class VideoLightBox extends AppCompatActivity {

    public static final String STATE_RESUME_WINDOW = "resumeWindow";
    public static final String STATE_PLAY_BACK_POSITION = "resumePosition";
    PlayerView playerView;
    SimpleExoPlayer exoPlayer;
    long playbackPosition;
    int currentWindow;
    boolean playWhenReady;
    private RelativeLayout rootView;
    private Context mContext;
    private String mVideoViewUrl;
    private WebView mVideoWebView;
    private ProgressBar pbVideoLoading;
    private int mVideoType, resizeMode = 1;
    private boolean canPlay;
    private FrameLayout mFullScreenButton;
    private ImageView mFullScreenIcon, mIvOverlay;
    private View mainFrame;
    private int mResumeWindow;
    private long mPlayBackPosition;
    private String mOverlayImage;
    private JSONObject liveStreamReaction;
    private RelativeLayout mainVideoHeaderContent;
    private int liveReactionPosition = 0;
    private Handler reactionHandler = new Handler();
    private List<String> liveReactions = new ArrayList<>();
    private ImageLoader mImageLoader;
    private AppConstant mAppConst;
    private boolean isRedirectForAllowPermission = false;
    public static WeakReference<Activity> mActivityRef;
    public static boolean isInPictureInPictureMode = false, isPipModeIconClicked = false;
    private ImageView ivPipIcon;
    private boolean  isFromAaf = false;


    /** Intent action for media controls from Picture-in-Picture mode. */
    private static final String ACTION_MEDIA_CONTROL = "media_control";

    /** Intent extra for media controls from Picture-in-Picture mode. */
    private static final String EXTRA_CONTROL_TYPE = "control_type";

    /** The request code for play action PendingIntent. */
    private static final int REQUEST_PLAY = 1;

    /** The request code for pause action PendingIntent. */
    private static final int REQUEST_PAUSE = 2;

    /** The intent extra value for play action. */
    private static final int CONTROL_TYPE_PLAY = 1;

    /** The intent extra value for pause action. */
    private static final int CONTROL_TYPE_PAUSE = 2;

    /** The arguments to be used for Picture-in-Picture mode. */
    private PictureInPictureParams.Builder mPictureInPictureParamsBuilder;

    private BroadcastReceiver mReceiver;
    private PlayerControlView controlView;
    private String mPlay;
    private String mPause;


    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.video_light_box);
        rootView = findViewById(R.id.video_view_light_box);
        mContext = this;
        mActivityRef = new WeakReference<Activity>(this);
        isInPictureInPictureMode = false;

        // Prepare string resources for Picture-in-Picture actions.
        mPlay = getResources().getString(R.string.play);
        mPause = getResources().getString(R.string.pause);

        mImageLoader = new ImageLoader(mContext);
        mAppConst = new AppConstant(mContext, false);

        if (savedInstanceState != null) {
            mResumeWindow = savedInstanceState.getInt(STATE_RESUME_WINDOW);
            mPlayBackPosition = savedInstanceState.getLong(STATE_PLAY_BACK_POSITION);
        }

        _init();


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            ViewCompat.setTransitionName(mainFrame, "play_video");
        }

        playVideos();
    }

    private void playVideos() {
        try {
            if (mVideoType == 3 && mVideoViewUrl != null) {
                pbVideoLoading.setVisibility(View.VISIBLE);


                /* Check if video is available offline then play it from offline storage,
                 else play from server url */
                if (Utils.getString(mContext, mVideoViewUrl) != null && new File(Utils.getString(mContext, mVideoViewUrl)).exists()) {
                    initializePlayer(Utils.getString(mContext, mVideoViewUrl));
                } else {
                    initializePlayer(mVideoViewUrl);
                }
            } else {
                renderVideoLightBox(mVideoType, mVideoViewUrl);
            }
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        }
    }


    /* Picture in picture mode code */
    /* To check we need to play in pip or not and device is support pip or not*/
    public boolean supportsPiPMode() {

        if ((Utils.isAutoPlayVideos(mContext) || isPipModeIconClicked) && PreferencesUtils.isPipModeEnabled(mContext)) {
            return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && mVideoType == 3;
        } else {
            return false;
        }
    }


    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        doOnPause();
        mResumeWindow = 0;
        mPlayBackPosition = 0;

        _init();
        playVideos();
    }


    /** Enters Picture-in-Picture mode. */
    public void minimize() {
        if (playerView == null) {
            return;
        }
        // Hide the controls in picture-in-picture mode.
        if (controlView != null)
            controlView.hide();

        // Calculate the aspect ratio of the PiP screen.
        Rational aspectRatio = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            aspectRatio = new Rational(25, 16);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                mPictureInPictureParamsBuilder = new PictureInPictureParams.Builder();
                mPictureInPictureParamsBuilder.setAspectRatio(aspectRatio).build();
                enterPictureInPictureMode(mPictureInPictureParamsBuilder.build());
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                enterPictureInPictureMode();
            }
        }
    }


    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, Configuration configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, configuration);

        this.isInPictureInPictureMode = isInPictureInPictureMode;


        if (isInPictureInPictureMode ) {

            if (controlView != null) {
                controlView.hide();
            }

            ivPipIcon.setVisibility(View.GONE);

            if (exoPlayer.getPlayWhenReady()) {
                updatePictureInPictureActions(
                        R.drawable.ic_pause_white_24dp, mPause, CONTROL_TYPE_PAUSE, REQUEST_PAUSE);
            } else {
                updatePictureInPictureActions(
                        R.drawable.ic_play_white_24dp, mPlay, CONTROL_TYPE_PLAY, REQUEST_PLAY);
            }



            // Starts receiving events from action items in PiP mode.
            mReceiver = new BroadcastReceiver() {
                        @Override
                        public void onReceive(Context context, Intent intent) {

                            if (intent == null || !ACTION_MEDIA_CONTROL.equals(intent.getAction())) {
                                return;
                            }

                            // This is where we are called back from Picture-in-Picture action
                            // items.
                            final int controlType = intent.getIntExtra(EXTRA_CONTROL_TYPE, 0);
                            switch (controlType) {
                                case CONTROL_TYPE_PLAY:
                                    onResume();
                                    updatePictureInPictureActions(
                                            R.drawable.ic_pause_white_24dp, mPause, CONTROL_TYPE_PAUSE, REQUEST_PAUSE);
                                    break;

                                case CONTROL_TYPE_PAUSE:
                                    doOnPause();
                                    updatePictureInPictureActions(
                                            R.drawable.ic_play_white_24dp, mPlay, CONTROL_TYPE_PLAY, REQUEST_PLAY);
                                    break;

                            }
                        }
                    };
            registerReceiver(mReceiver, new IntentFilter(ACTION_MEDIA_CONTROL));
        } else {

            if (isFromAaf) {
                FeedsFragment.playbackWindow = exoPlayer.getCurrentWindowIndex();
                FeedsFragment.playbackPosition = exoPlayer.getCurrentPosition();
            }

            if (mReceiver != null) {
                // We are out of PiP mode. We can stop receiving events from it.
                unregisterReceiver(mReceiver);
                mReceiver = null;
            }

            // Show the video controls if the video is not playing
            if (controlView != null) {
                controlView.show();
            }
            setPipIconVisibility();
            isPipModeIconClicked = false;
        }
    }

    private void setPipIconVisibility() {
        if (PreferencesUtils.isPipModeEnabled(mContext)) {
            ivPipIcon.setVisibility(View.VISIBLE);
        } else {
            ivPipIcon.setVisibility(View.GONE);
        }
    }


    @Override
    public void onResume() {
        super.onResume();
        mVideoWebView.onResume();
        mVideoWebView.resumeTimers();
        canPlay = true;
        startPlayer();
    }

    @Override
    public void onPause() {
        super.onPause();
        if (!supportsPiPMode()) {
            doOnPause();
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public void onStop() {
        super.onStop();
        if (supportsPiPMode() && !isRedirectForAllowPermission) {
            finishAndRemoveTask();
        }
    }

    /**
     * Update the state of pause/resume action item in Picture-in-Picture mode.
     *
     * @param iconId The icon to be used.
     * @param title The title text.
     * @param controlType The type of the action. either {@link #CONTROL_TYPE_PLAY} or {@link
     *     #CONTROL_TYPE_PAUSE}.
     * @param requestCode The request code for the {@link PendingIntent}.
     */
    void updatePictureInPictureActions(
            @DrawableRes int iconId, String title, int controlType, int requestCode) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            final ArrayList<RemoteAction> actions = new ArrayList<>();

            // This is the PendingIntent that is invoked when a user clicks on the action item.
            // You need to use distinct request codes for play and pause, or the PendingIntent won't
            // be properly updated.
            final PendingIntent intent =
                    PendingIntent.getBroadcast(
                            VideoLightBox.this,
                            requestCode,
                            new Intent(ACTION_MEDIA_CONTROL).putExtra(EXTRA_CONTROL_TYPE, controlType),
                            0);
            final Icon icon = Icon.createWithResource(VideoLightBox.this, iconId);
            actions.add(new RemoteAction(icon, title, title, intent));


            mPictureInPictureParamsBuilder.setActions(actions);

            // This is how you can update action items (or aspect ratio) for Picture-in-Picture mode.
            // Note this call can happen even when the app is not in PiP mode. In that case, the
            // arguments will be used for at the next call of #enterPictureInPictureMode.
            setPictureInPictureParams(mPictureInPictureParamsBuilder.build());
        }

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        releasePlayer();
        if (mReceiver != null) {
            unregisterReceiver(mReceiver);
            mReceiver = null;
        }
        mActivityRef = null;
        isInPictureInPictureMode = false;
    }

    public void _init() {

        mVideoWebView = rootView.findViewById(R.id.webView);
        pbVideoLoading = rootView.findViewById(R.id.loadingProgress);
        playerView = rootView.findViewById(R.id.exo_video_player);
        mIvOverlay = rootView.findViewById(R.id.image);
        mainFrame = rootView.findViewById(R.id.main_media_frame);
        mainVideoHeaderContent = rootView.findViewById(R.id.video_view_light_box);
        ivPipIcon = rootView.findViewById(R.id.pip_icon);
        isPipModeIconClicked = false;
        ivPipIcon.setOnClickListener(v -> {
            isPipModeIconClicked = true;
            onBackPressed();
        });

        Bundle args = getIntent().getExtras();
        if (args != null) {
            mVideoType = args.getInt(ConstantVariables.VIDEO_TYPE, 0);
            mVideoViewUrl = args.getString(ConstantVariables.VIDEO_URL);
            mOverlayImage = args.getString(ConstantVariables.VIDEO_OVERLAY_IMAGE, "");
            isFromAaf = args.getBoolean("isFromAaf", false);

            if (args.containsKey(STATE_RESUME_WINDOW)) {
                mResumeWindow = args.getInt(STATE_RESUME_WINDOW);
                mPlayBackPosition = args.getLong(STATE_PLAY_BACK_POSITION);
            }

            if (args.get(ConstantVariables.LIVE_STREAM_REACTIONS) != null) {
                try {
                    liveStreamReaction = new JSONObject(args.getString(ConstantVariables.LIVE_STREAM_REACTIONS));
                    showLiveVideoReactions();
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }

    }


    @TargetApi(Build.VERSION_CODES.O)
    public boolean canEnterPiPMode() {
        AppOpsManager appOpsManager = (AppOpsManager) getSystemService(Context.APP_OPS_SERVICE);
        return (AppOpsManager.MODE_ALLOWED== appOpsManager.checkOpNoThrow(AppOpsManager.OPSTR_PICTURE_IN_PICTURE, android.os.Process.myUid(), mContext.getPackageName()));
    }

    private void initializePlayer(String videoURL) {

        mVideoWebView.setVisibility(View.GONE);
        mainFrame.setVisibility(View.VISIBLE);

        setPipIconVisibility();

        LogUtils.LOGD(VideoLightBox.class.getSimpleName(), "Device VideoUrl: " + videoURL + " - " + mPlayBackPosition);

        if (mOverlayImage != null && !mOverlayImage.isEmpty()) {
            ImageLoader imageLoader = new ImageLoader(mContext);
            imageLoader.setReactionImageUrl(mOverlayImage, mIvOverlay);
            mIvOverlay.setVisibility(View.VISIBLE);
        } else {
            mIvOverlay.setVisibility(View.GONE);
        }

        exoPlayer = ExoPlayerFactory.newSimpleInstance(mContext);

        playerView.setPlayer(exoPlayer);
        exoPlayer.setPlayWhenReady(playWhenReady);

        MediaSource mediaSource = Utils.buildMediaSource(mContext, videoURL);

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

                if (playWhenReady && playbackState == Player.STATE_READY) {
                    reactionHandler.removeCallbacks(runnableCode);
                    reactionHandler.post(runnableCode);
                } else if (!playWhenReady && playbackState == Player.STATE_READY) {
                    reactionHandler.removeCallbacks(runnableCode);
                }
                switch (playbackState) {
                    case Player.STATE_READY:
                        pbVideoLoading.setVisibility(View.GONE);
                        if (mPlayBackPosition > 0) {
                            exoPlayer.seekTo(mResumeWindow, mPlayBackPosition);
                            mPlayBackPosition = 0;
                        }

                        if (isInPictureInPictureMode) {
                            updatePictureInPictureActions(
                                    R.drawable.ic_pause_white_24dp, mPause, CONTROL_TYPE_PAUSE, REQUEST_PAUSE);
                        }
                        break;

                    case Player.STATE_BUFFERING:
                        pbVideoLoading.setVisibility(View.VISIBLE);
                        break;

                    case Player.STATE_ENDED:
                    case Player.STATE_IDLE:
                        if (isInPictureInPictureMode) {
                            if (controlView != null) {
                                controlView.hide();
                            }
                            updatePictureInPictureActions(
                                    R.drawable.ic_play_white_24dp, mPlay, CONTROL_TYPE_PLAY, REQUEST_PLAY);
                            finish();
                        }
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
        playerView.setFastForwardIncrementMs(ConstantVariables.VALUE_FAST_FORWARD_INCREMENT);
        playerView.setRewindIncrementMs(ConstantVariables.VALUE_REWIND_INCREMENT);
        _initMediaAction();
    }

    private void releasePlayer() {
        if (exoPlayer != null) {
            playbackPosition = exoPlayer.getCurrentPosition();
            currentWindow = exoPlayer.getCurrentWindowIndex();
            playWhenReady = exoPlayer.getPlayWhenReady();
            exoPlayer.release();
            exoPlayer = null;
            reactionHandler.removeCallbacks(runnableCode);
        }
    }

    private void pausePlayer() {
        if (exoPlayer != null) {
            exoPlayer.setPlayWhenReady(false);
            exoPlayer.getPlaybackState();
            mResumeWindow = exoPlayer.getCurrentWindowIndex();
            mPlayBackPosition = Math.max(0, exoPlayer.getContentPosition());
            reactionHandler.removeCallbacks(runnableCode);
        }
    }

    private void startPlayer() {
        if (exoPlayer != null) {
            exoPlayer.setPlayWhenReady(true);
            exoPlayer.getPlaybackState();
        }
    }

    public void loadVideoUrl() {

        pbVideoLoading.setVisibility(View.VISIBLE);
        ivPipIcon.setVisibility(View.GONE);

        if (mVideoType != 0 && mVideoType != 3) {

            LogUtils.LOGD(VideoLightBox.class.getSimpleName(), "Web VideoUrl: " + mVideoViewUrl);

            //Auto playing videos in webview
            mVideoWebView.setClickable(true);
            mVideoWebView.setFocusableInTouchMode(true);
            mVideoWebView.getSettings().setJavaScriptEnabled(true);
            mVideoWebView.getSettings().setAppCacheEnabled(true);
            mVideoWebView.getSettings().setDomStorageEnabled(true);

            mVideoWebView.setVisibility(View.GONE);
            mVideoWebView.onResume();

            if (mVideoViewUrl == null) {
                return;
            }

            if (!mVideoViewUrl.contains("http://") && !mVideoViewUrl.contains("https://")) {
                mVideoViewUrl = "http://" + mVideoViewUrl;
            }

            /* Check if video url is coming with iframe tag
             * then load it in webview with html content */
            if (mVideoViewUrl.contains("<iframe")) {
                mVideoWebView.loadData(mVideoViewUrl, "text/html", "utf-8");
            } else if (mVideoViewUrl.contains("youtube")) {
                Map<String, String> extraHeaders = new HashMap<>();
                extraHeaders.put("Referer", "http://www.youtube.com");
                mVideoWebView.loadUrl(mVideoViewUrl, extraHeaders);
            } else {
                mVideoWebView.loadUrl(mVideoViewUrl);
            }

            mVideoWebView.setWebChromeClient(new WebChromeClient());
            mVideoWebView.setWebViewClient(new WebViewClient() {
                @Override
                public void onPageFinished(WebView view, String url) {

                    String javascript = "javascript:" +
                            "   document.getElementsByClassName('ytp-large-play-button')[0].click();" +
                            "   setTimeout(function() {" +
                            "   var endScreen = document.getElementsByClassName('videowall-endscreen')[0];" +
                            "   endScreen.style.opacity = 0;" +
                            "   endScreen.style.display = 'none';" +
                            "   var replayButton = document.getElementsByClassName('ytp-icon-replay')[0];" +
                            "   replayButton.style.marginBottom = '90px';" +
                            "   var headerTitle = document.getElementsByClassName('ytp-chrome-top')[0];" +
                            "   headerTitle.style.display = 'none';" +
                            "   }, 2000);";

                    if (canPlay) {
                        view.loadUrl(javascript);
                    }
                    super.onPageFinished(view, url);
                    pbVideoLoading.setVisibility(View.GONE);
                    mVideoWebView.setVisibility(View.VISIBLE);
                }
            });
        } else {
            finish();
            Toast.makeText(mContext, mContext.getResources().getString(R.string.video_under_process), Toast.LENGTH_LONG).show();
        }

    }

    public void renderVideoLightBox(int videoType, String videoViewUrl) {
        mVideoType = videoType;
        mVideoViewUrl = videoViewUrl;
        mainFrame.setVisibility(View.GONE);
        loadVideoUrl();
    }

    private void doOnPause() {
        mVideoWebView.onPause();
        mVideoWebView.pauseTimers();
        canPlay = false;
        pausePlayer();

        if (isInPictureInPictureMode) {
            if (controlView != null) {
                controlView.hide();
            }

        }
    }

    private void _initMediaAction() {

        controlView = playerView.findViewById(R.id.exo_controller);
        mFullScreenIcon = controlView.findViewById(R.id.exo_fullscreen_icon);
        mFullScreenIcon.setImageDrawable(ContextCompat.getDrawable(mContext, R.drawable.ic_fit_x));
        mFullScreenButton = controlView.findViewById(R.id.exo_fullscreen_button);
        mFullScreenButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                playerView.setResizeMode(resizeMode);

                switch (resizeMode) {
                    case AspectRatioFrameLayout.RESIZE_MODE_FIT:
                        mFullScreenIcon.setImageDrawable(ContextCompat.getDrawable(mContext, R.drawable.ic_fit_x));
                        break;
                    case AspectRatioFrameLayout.RESIZE_MODE_FIXED_WIDTH:
                        mFullScreenIcon.setImageDrawable(ContextCompat.getDrawable(mContext, R.drawable.ic_fit_y));
                        break;
                    case AspectRatioFrameLayout.RESIZE_MODE_FIXED_HEIGHT:
                        mFullScreenIcon.setImageDrawable(ContextCompat.getDrawable(mContext, R.drawable.ic_view_carousel));
                        break;
                    case AspectRatioFrameLayout.RESIZE_MODE_FILL:
                        mFullScreenIcon.setImageDrawable(ContextCompat.getDrawable(mContext, R.drawable.ic_crop));
                        break;
                    case AspectRatioFrameLayout.RESIZE_MODE_ZOOM:
                        mFullScreenIcon.setImageDrawable(ContextCompat.getDrawable(mContext, R.drawable.ic_fullscreen));
                        break;
                }
                if (resizeMode == 4) {
                    resizeMode = 0;
                } else {
                    resizeMode++;
                }
            }
        });
        View rotateIcon = controlView.findViewById(R.id.exo_rotate_icon);
        rotateIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                toggleOrientation(getRequestedOrientation());
            }
        });
    }

    private void toggleOrientation(int orientation) {
        if (android.os.Build.VERSION.SDK_INT != Build.VERSION_CODES.O) {
            try {
                if (orientation == ActivityInfo.SCREEN_ORIENTATION_PORTRAIT) {
                    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                } else {
                    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                }
            } catch (NullPointerException npe) {
                npe.printStackTrace();
            }
        }
    }


    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        if (supportsPiPMode()) {
            outState.putInt(STATE_RESUME_WINDOW, 0);
            outState.putLong(STATE_PLAY_BACK_POSITION, 0);
        } else {
            outState.putInt(STATE_RESUME_WINDOW, mResumeWindow);
            outState.putLong(STATE_PLAY_BACK_POSITION, mPlayBackPosition);
        }

        super.onSaveInstanceState(outState);
    }

    @Override
    public void onBackPressed() {

        if (supportsPiPMode()) {
            if (PreferencesUtils.isPipUserPopupDisplayed(mContext)) {
                if (PreferencesUtils.isPipModeEnabled(mContext) && canEnterPiPMode()) {
                    minimize();
                } else {
                    onBackPressedSuper();
                }
            } else {
                displayPipPopup();
            }
        } else {
            onBackPressedSuper();
        }
    }

    private void onBackPressedSuper() {
        mActivityRef = null;
        Intent intent = new Intent();
        if (exoPlayer !=  null) {
            intent.putExtra(STATE_RESUME_WINDOW, exoPlayer.getCurrentWindowIndex());
            intent.putExtra(STATE_PLAY_BACK_POSITION, Math.max(0, exoPlayer.getContentPosition()));
        }
        setResult(ConstantVariables.AUTO_PLAY_VIDEO_VIEW_CODE, intent);
        ((Activity) mContext).overridePendingTransition(0, 0);
        super.onBackPressed();
    }


    /* Display user confirmation popup to user, before navigating to pip mode*/
    private void displayPipPopup() {

        AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(this);

        LayoutInflater inflater = this.getLayoutInflater();
        View dialogView = inflater.inflate(R.layout.pip_custom_permission_popup, null);
        dialogBuilder.setView(dialogView);


        AlertDialog alertDialogWithAction = dialogBuilder.create();
        alertDialogWithAction.setCanceledOnTouchOutside(false);
        alertDialogWithAction.show();

        TextView tvHeader = dialogView.findViewById(R.id.header);
        TextView tvDescription = dialogView.findViewById(R.id.description);
        AppCompatCheckBox cbNeverAskAgain = dialogView.findViewById(R.id.never_ask_again);
        TextView tvCancel = dialogView.findViewById(R.id.cancel);
        TextView tvSubmit = dialogView.findViewById(R.id.submit);

        tvHeader.setText(getResources().getString(R.string.pip_video_confirmation_dialog_title));
        tvDescription.setText(getResources().getString(R.string.pip_video_confirmation_dialog_message));
        tvSubmit.setText(getResources().getString(R.string.pip_video_confirmation_dialog_yes));

        tvCancel.setOnClickListener(v -> {
            alertDialogWithAction.dismiss();

            // set value when user check never ask again
            if (cbNeverAskAgain.isChecked()) {
                PreferencesUtils.setPipModeEnable(mContext, false);
                PreferencesUtils.updatePipUserPopupDisplayed(mContext, true);
            }

            onBackPressedSuper();
        });

        tvSubmit.setOnClickListener(v -> {
            alertDialogWithAction.dismiss();
            PreferencesUtils.updatePipUserPopupDisplayed(mContext, true);
            PreferencesUtils.setPipModeEnable(mContext, true);

            if (!canEnterPiPMode()) {
                if (!PreferencesUtils.isPipPermissionPopupDisplayed(mContext)) {
                    displayPipModePermissionDialog();
                } else {
                    Toast.makeText(mContext, getResources().getString(R.string.allow_from_phone_app_settings_text), Toast.LENGTH_LONG).show();
                    onBackPressedSuper();
                }

            } else {
                minimize();
            }
        });
    }

    private void displayPipModePermissionDialog() {

        AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(this);

        LayoutInflater inflater = this.getLayoutInflater();
        View dialogView = inflater.inflate(R.layout.pip_custom_permission_popup, null);
        dialogBuilder.setView(dialogView);


        AlertDialog alertDialogWithAction = dialogBuilder.create();
        alertDialogWithAction.setCanceledOnTouchOutside(false);
        alertDialogWithAction.show();

        TextView tvHeader = dialogView.findViewById(R.id.header);
        TextView tvDescription = dialogView.findViewById(R.id.description);
        AppCompatCheckBox cbNeverAskAgain = dialogView.findViewById(R.id.never_ask_again);
        TextView tvCancel = dialogView.findViewById(R.id.cancel);
        TextView tvSubmit = dialogView.findViewById(R.id.submit);

        tvHeader.setText(getResources().getString(R.string.pip_mode_permission_title));
        tvDescription.setText(R.string.pip_mode_permission_message);
        tvSubmit.setText(R.string.pip_mode_permission_yes_button);

        tvCancel.setOnClickListener(v -> {
            alertDialogWithAction.dismiss();

            // set value when user check never ask again
            if (cbNeverAskAgain.isChecked()) {
                PreferencesUtils.updatePipPermissionPopupDisplayed(mContext, true);
            }
            onBackPressedSuper();
        });

        tvSubmit.setOnClickListener(v -> {
            alertDialogWithAction.dismiss();
            isRedirectForAllowPermission = true;
            PreferencesUtils.updatePipPermissionPopupDisplayed(mContext, true);
            Intent intent = new Intent("android.settings.PICTURE_IN_PICTURE_SETTINGS", Uri.parse("package:" + mContext.getPackageName()));
            startActivityForResult(intent, ConstantVariables.PIP_MODE_REQUEST_CODE);
        });
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == ConstantVariables.PIP_MODE_REQUEST_CODE) {
            isRedirectForAllowPermission = false;
            if (canEnterPiPMode()) {
                new Handler().postDelayed(new Runnable() {
                    public void run() {
                        onBackPressed();
                    }
                }, 500);

            } else {
                finish();
            }
        }
    }

    /**
     * Method to show live video's reaction.
     */
    private void showLiveVideoReactions() {
        liveReactions.clear();
        if (liveStreamReaction != null && liveStreamReaction.length() > 0) {
            Iterator<String> reactionKeys = liveStreamReaction.keys();
            for (; reactionKeys.hasNext(); ) {
                String key = reactionKeys.next();
                JSONObject reactionObject = liveStreamReaction.optJSONObject(key);
                if (reactionObject != null && reactionObject.length() > 0) {
                    int reactionCount = reactionObject.optInt("reaction_count");
                    String reactionIcon = reactionObject.optString("reaction_image_icon");
                    for (int i = 0; i < reactionCount; i++) {
                        liveReactions.add(reactionIcon);
                    }
                }
            }
            liveReactionPosition = 0;
        }
    }

    // runnable code for show floating reactions
    private Runnable runnableCode = new Runnable() {
        @Override
        public void run() {

            if (liveReactions.size() > 0 && liveReactionPosition < liveReactions.size()
                    && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {

                String reactionIconUrl = liveReactions.get(liveReactionPosition);
                final BezelImageView imageView = new BezelImageView(mContext);
                imageView.setMaskDrawable(ContextCompat.getDrawable(mContext, R.drawable.circle_mask));
                imageView.setBorderDrawable(ContextCompat.getDrawable(mContext, R.drawable.circle_border));
                if (reactionIconUrl != null && !reactionIconUrl.isEmpty()) {
                    mImageLoader.setFeedImageWithAnimation(reactionIconUrl, imageView);
                } else {
                    imageView.setImageResource(R.drawable.ic_thumb_up_24dp);
                    imageView.setColorFilter(ContextCompat.getColor(mContext, R.color.colorPrimary),
                            PorterDuff.Mode.SRC_ATOP);
                }
                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT,
                        RelativeLayout.LayoutParams.WRAP_CONTENT);
                imageView.setMinimumWidth(mContext.getResources().getDimensionPixelSize(R.dimen.reactions_tab_icon_width_height));
                imageView.setMinimumHeight(mContext.getResources().getDimensionPixelSize(R.dimen.reactions_tab_icon_width_height));
                layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE);

                imageView.setId(R.id.image);
                imageView.setLayoutParams(layoutParams);

                mainVideoHeaderContent.addView(imageView);
                // TODO in case if need to show animation From bottom to middle
//                float x1 = mAppConst.getScreenWidth() - 100;
//                float y1 = mAppConst.getScreenHeight() - 200;
//
//                if (x1 > mAppConst.getScreenWidth()) {
//                    x1 = mAppConst.getScreenWidth() - 70;
//                }
//
//                Path path = new Path();
//                int random = (int) (Math.random() * 100);
//
//                path.moveTo(x1 - 0, y1 - 40);
//                path.lineTo(x1 - 0, y1 - 100);
//                path.lineTo(x1 - 0, y1 - (400 + random));
//                path.lineTo(x1 - 20, y1 - (430 + random));
//                path.lineTo(x1 - 100, y1 - (450 + random));
//                path.lineTo(x1 - (x1 + 150), y1 - (440 + random));

                // From right to left
                float x1 = mAppConst.getScreenWidth() + 20;
                float y1 = pbVideoLoading.getY() - 70;

                Path path = new Path();
                int random = (int) (Math.random()*100);
                path.moveTo(x1 - 0, y1 - random);
                path.lineTo(x1 - 20, y1 - random + 10);
                path.lineTo(x1 - 100, y1 - random - 10);
                path.lineTo(x1 - (x1 + 150), y1 - random - 20);

                ObjectAnimator objectAnimator = ObjectAnimator.ofFloat(imageView, View.X,
                        View.Y, path);
                int animateTime = (int) (Math.random() * 10000);
                if (animateTime < 3000) {
                    animateTime = animateTime + 3000;
                }
                objectAnimator.setDuration(animateTime);
                objectAnimator.start();
                objectAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                    @Override
                    public void onAnimationUpdate(ValueAnimator animation) {
                        imageView.bringToFront();
                    }
                });
                liveReactionPosition++;

                // Uncomment this code if reactions need to display in repeating mode
//                if (liveReactionPosition == liveReactions.size() - 1) {
//                    liveReactionPosition = 0;
//                }
                reactionHandler.postDelayed(runnableCode, 900);
            }
        }
    };
}
