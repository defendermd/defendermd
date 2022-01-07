package com.socialengineaddons.mobileapp.classes.modules.liveStreaming;

import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;
import android.widget.AbsListView;
import android.widget.Chronometer;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;


import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.ImageAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.BezelImageView;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.DrawableClickListener;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageViewList;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.likeNComment.CommentAdapter;
import com.socialengineaddons.mobileapp.classes.modules.likeNComment.CommentList;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.listener.KeyboardCloseListener;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.listener.OnAgoraSignalingInterface;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.listener.OnAppCloseListener;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.model.AGEventHandler;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.ui.CustomEditText;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.ui.MaxHeightListView;
import com.socialengineaddons.mobileapp.classes.modules.user.MemberDetails;
import com.socialengineaddons.mobileapp.classes.modules.user.MemberDetailsDialog;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.agora.AgoraAPIOnlySignal;
import io.agora.rtc.Constants;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.video.VideoCanvas;


public class LiveRoomActivity extends LiveBaseActivity implements AGEventHandler, View.OnClickListener,
        KeyboardCloseListener, OnAgoraSignalingInterface, OnAppCloseListener, AbsListView.OnScrollListener {

    // Member variables.
    private Context mContext;
    private RelativeLayout mMainView;
    private View cameraFlip, bottomOptionsView, footerView;
    private FrameLayout flVideoView;
    private LinearLayout llLikeView;
    private CustomEditText etCommentBox;
    private TextView tvCommentBox, tvEndLive, tvLiveText, tvViewCount, tvEndStreamMsg;
    private ImageView ivLike;
    private Chronometer tvLiveDuration;
    private MaxHeightListView lvComment;

    // Custom classes and remote view.
    private AgoraAPIOnlySignal mAgoraAPISignal;
    private LiveStreamUtils liveStreamUtils;
    private AppConstant mAppConst;
    private CommentList mCommentList;
    private CommentAdapter mCommentAdapter;
    private ImageAdapter reactionsAdapter;
    private ImageLoader mImageLoader;
    private AlertDialogWithAction mAlertDialogWithAction;
    private Handler viewHandler = new Handler();
    private Handler liveInfoHandler = new Handler();
    private BottomSheetDialog bottomSheetDialog;

    // Class variables.
    private long viewShowTime = 3000;
    private int mReactionsEnabled, pageNumber = 1;
    private int subjectId, userId, liveReactionId, clientRole, videoId;
    private boolean isBroadCaster, isStreamViewed = false, isLiked = false, canShowDurationMsg = false,
            isStreamingLive = false, isNestedCommentEnabled, isLoading = false, isLiveDurationMsgDisplayed = false;
    private String channelName, subjectType, userImage, displayName, videoType, commentPostUrl,
            sid = "";
    private Map<String, String> postParams, commentPostParam;
    private final HashMap<Integer, SurfaceView> mUidsList = new HashMap<>(); // uid = 0 || uid == EngineConfig.mUid
    private List<CommentList> mCommentListItems;
    private List<ImageViewList> reactionsImages;
    private List<MemberDetails> viewerBrowseList;
    private List<Integer> totalViewers;
    private JSONObject userDetails;
    private JSONObject mReactionsObject;
    private ArrayList<JSONObject> mReactionsArray;
    private RecyclerView reactionsRecyclerView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_streaming);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON |
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);

        // Initialize member variables.
        mContext = LiveRoomActivity.this;
        postParams = new HashMap<>();
        commentPostParam = new HashMap<>();
        reactionsImages = new ArrayList<>();
        mCommentListItems = new ArrayList<>();
        viewerBrowseList = new ArrayList<>();
        totalViewers = new ArrayList<>();
        isStreamingLive = false;


        mImageLoader = new ImageLoader(mContext);
        mAppConst = new AppConstant(mContext);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        mCommentList = new CommentList();
        liveStreamUtils = LiveStreamUtils.getInstance();
        liveStreamUtils.setContext(mContext);
        mAgoraAPISignal = liveStreamUtils.getAgoraAPISignal();
        liveStreamUtils.setOnAgoraSignalingInterface(this);
        liveStreamUtils.setOnAppCloseListener(this);
        isNestedCommentEnabled = PreferencesUtils.isNestedCommentEnabled(mContext);
        if (getIntent().hasExtra(ConstantVariables.POST_PARAMS)) {
            postParams = (HashMap<String, String>) getIntent().getSerializableExtra(ConstantVariables.POST_PARAMS);
        }

        try {
            userDetails = new JSONObject(PreferencesUtils.getUserDetail(mContext));
            userImage = userDetails.optString("image_profile");
            userId = userDetails.optInt("user_id");
            displayName = userDetails.optString("displayname");
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        return false;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        return false;
    }

    @Override
    protected void initUIEvent() {
        // Getting intent values.
        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            channelName = bundle.getString(ConstantVariables.CHANNEL_NAME);
            subjectType = bundle.getString(ConstantVariables.SUBJECT_TYPE);
            subjectId = bundle.getInt(ConstantVariables.SUBJECT_ID);
            isBroadCaster = bundle.getBoolean(ConstantVariables.IS_BROADCASTER, false);
            clientRole = isBroadCaster ? Constants.CLIENT_ROLE_BROADCASTER : Constants.CLIENT_ROLE_AUDIENCE;
            videoId = bundle.getInt(ConstantVariables.VIDEO_ID);
            videoType = bundle.getString(ConstantVariables.VIDEO_TYPE, "video");
        }

        initializeViews();
        onKeyboardClosed(null);
        showReactions();
        if (isNestedCommentEnabled) {
            commentPostUrl = AppConstant.DEFAULT_URL + "advancedcomments/comment";
        } else {
            commentPostUrl = AppConstant.DEFAULT_URL + "comment-create";
        }
        commentPostParam.put(ConstantVariables.SUBJECT_TYPE, videoType);
        commentPostParam.put(ConstantVariables.SUBJECT_ID, String.valueOf(videoId));
        commentPostParam.put("send_notification", "0");

        mCommentAdapter = new CommentAdapter(this, R.layout.list_comment, mCommentListItems,
                mCommentList, true, subjectType, subjectId);
        mCommentAdapter.setLiveStreaming(true);
        mCommentAdapter.setLiveStreamSubscriber(!isBroadCaster);
        lvComment.setAdapter(mCommentAdapter);
    }

    @Override
    protected void performAfterPermission() {
        event().addEventHandler(this);

        worker().configEngine(clientRole, Constants.VIDEO_PROFILE_480P);

        if (isBroadcaster(clientRole)) {
            SurfaceView surfaceV = RtcEngine.CreateRendererView(getApplicationContext());
            rtcEngine().setupLocalVideo(new VideoCanvas(surfaceV, VideoCanvas.RENDER_MODE_HIDDEN, 0));
            surfaceV.setZOrderOnTop(true);
            surfaceV.setZOrderMediaOverlay(true);
            flVideoView.removeAllViews();
            flVideoView.addView(surfaceV);
            mUidsList.put(0, surfaceV); // get first surface view

            worker().preview(true, surfaceV, 0);
            tvEndStreamMsg.setVisibility(View.VISIBLE);
            tvEndStreamMsg.setText(mContext.getResources().getString(R.string.checking_connection) + "...");
            tvEndLive.setVisibility(View.VISIBLE);
            tvEndLive.setText(mContext.getResources().getString(R.string.close_listing_label));
        } else {
            getComments(1, false);
            lvComment.setOnScrollListener(this);
            tvEndLive.setVisibility(View.VISIBLE);
        }
        worker().joinChannel(channelName, config().mUid);
        mAgoraAPISignal.channelJoin(channelName);
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {
            case R.id.cameraFlip:
                liveStreamUtils.rtcEngine().switchCamera();
                break;

            case R.id.commentBox:
                if (isStreamingLive) {
                    initializeCommentsBox();
                }
                break;

            case R.id.end:
                if (isBroadCaster && isStreamingLive) {
                    if (GlobalFunctions.isNetworkAvailable(mContext)) {
                        mAlertDialogWithAction.showAlertDialogWithAction(mContext.getResources().getString(R.string.end_live_stream_dialogue_title),
                                mContext.getResources().getString(R.string.end_live_stream_dialogue_message),
                                mContext.getResources().getString(R.string.end_live_stream_dialogue_title),
                                new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialogInterface, int which) {
                                        Intent intent = new Intent(mContext, EndLiveStreamingActivity.class);
                                        intent.putExtra(ConstantVariables.CHANNEL_NAME, channelName);
                                        intent.putExtra(ConstantVariables.SID, sid);
                                        intent.putExtra(ConstantVariables.LIVE_STREAM_VIEWERS_COUNT, totalViewers.size());
                                        if (postParams != null && !postParams.isEmpty()) {
                                            intent.putExtra(ConstantVariables.POST_PARAMS, (Serializable) postParams);
                                        }
                                        intent.addFlags(Intent.FLAG_ACTIVITY_FORWARD_RESULT);
                                        mContext.startActivity(intent);
                                        terminateLiveStreaming();
                                    }
                                });
                    } else {
                        Toast.makeText(mContext, mContext.getResources().getString(R.string.network_connectivity_error),
                                Toast.LENGTH_SHORT).show();
                    }
                } else {
                    terminateLiveStreaming();
                }
                break;

            case R.id.liveText:
                viewHandler.removeCallbacks(showViewRunnableCode);
                viewHandler.postDelayed(showViewRunnableCode, viewShowTime);
                break;

            case R.id.viewCount:
                if (isBroadCaster && viewerBrowseList.size() > 0) {
                    Bundle viewDetailsBundle = new Bundle();
                    viewDetailsBundle.putString(ConstantVariables.TITLE, mContext.getResources().getString(R.string.people_viewing_live_video));
                    viewDetailsBundle.putBoolean(ConstantVariables.IS_LIVE_STREAM_VIEWER, true);
                    viewDetailsBundle.putSerializable(ConstantVariables.LIVE_STREAM_VIEWERS_LIST, (Serializable) viewerBrowseList);
                    MemberDetailsDialog memberDetailsDialog = new MemberDetailsDialog();
                    memberDetailsDialog.setArguments(viewDetailsBundle);
                    memberDetailsDialog.show(getSupportFragmentManager(), "list");
                }
                break;

            case R.id.video_view_container:
                if (isStreamingLive) {
                    viewHandler.removeCallbacks(showViewRunnableCode);
                    showHideViewOnTouch(bottomOptionsView.getVisibility() == View.INVISIBLE);
                }
                break;

            case R.id.likeView:
                int color;
                if (ivLike.isActivated()) {
                    color = R.color.white;
                } else {
                    color = R.color.colorPrimary;
                }
                ivLike.setColorFilter(ContextCompat.getColor(mContext, color),
                        PorterDuff.Mode.SRC_ATOP);
                ivLike.setActivated(!ivLike.isActivated());
                if (ivLike.isActivated()) {
                    JSONObject likeObject = new JSONObject();
                    try {
                        likeObject.put("user_id", userId);
                        likeObject.put("user_image", userImage);
                        likeObject.put("is_live_stream_like", true);
                        mAgoraAPISignal.messageChannelSend(channelName, likeObject.toString(), UUID.randomUUID().toString());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                doLikeUnlike(null);
                break;
        }
    }

    private void initializeCommentsBox() {

        if (bottomSheetDialog == null) {
            View inflatedView = ((Activity) mContext).getLayoutInflater().inflate(R.layout.layout_comment_box, null);
            inflatedView.setBackgroundResource(R.color.white);

            bottomSheetDialog = new BottomSheetDialog(mContext);
            bottomSheetDialog.setContentView(inflatedView);
            bottomSheetDialog.setCancelable(true);
            bottomSheetDialog.setCanceledOnTouchOutside(true);

            etCommentBox = inflatedView.findViewById(R.id.commentEditText);
            etCommentBox.setKeyboardCloseListener(this);
            Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_send_white_24dp);
            drawable.mutate();
            drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.colorPrimary),
                    PorterDuff.Mode.SRC_ATOP));
            etCommentBox.setCompoundDrawablesWithIntrinsicBounds(null, null, drawable, null);
            etCommentBox.setHint(mContext.getResources().getString(R.string.write_comment_text) + " ...");
            etCommentBox.setOnTouchListener(new DrawableClickListener.RightDrawableClickListener(etCommentBox) {
                @Override
                public boolean onDrawableClick() {
                    if (etCommentBox != null && etCommentBox.getText() != null
                            && !etCommentBox.getText().toString().trim().isEmpty()) {
                        sendComment(etCommentBox.getText().toString());
                    }
                    return true;
                }
            });
        }

        bottomSheetDialog.show();
        etCommentBox.setVisibility(View.VISIBLE);
        bottomSheetDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                bottomSheetDialog.dismiss();
                etCommentBox.setVisibility(View.GONE);
            }
        });
        etCommentBox.requestFocus();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return (keyCode != KeyEvent.KEYCODE_BACK || !isBroadCaster) && super.onKeyDown(keyCode, event);
    }

    @Override
    public void onScrollStateChanged(AbsListView absListView, int i) {

    }

    @Override
    public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {

        int limit = firstVisibleItem + visibleItemCount;
        if (limit == totalItemCount && !isLoading) {
            if (limit >= ConstantVariables.COMMENT_LIMIT && (ConstantVariables.COMMENT_LIMIT * pageNumber) <
                    mCommentList.getmTotalCommmentCount()) {
                CustomViews.addFooterView(lvComment, footerView);
                pageNumber += 1;
                isLoading = true;
                getComments(pageNumber, true);
            }
        }

    }

    @Override
    protected void onResume() {
        super.onResume();
        if (isBroadCaster && liveStreamUtils.rtcEngine() != null) {
            liveStreamUtils.rtcEngine().enableLocalVideo(true);
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        if (etCommentBox != null && etCommentBox.getText() != null) {
            onKeyboardClosed(etCommentBox.getText().toString());
        }
        if (!isFinishing() && isBroadCaster && liveStreamUtils.rtcEngine() != null) {
            liveStreamUtils.rtcEngine().enableLocalVideo(false);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (etCommentBox != null && etCommentBox.getText() != null) {
            onKeyboardClosed(etCommentBox.getText().toString());
        }
    }


    @Override
    public void onAppClosed() {
        LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "onAppClosed");
        doLeaveChannel(true);
        event().removeEventHandler(this);
        terminateLiveStreaming();
    }

    @Override
    public void onKeyboardClosed(String text) {
        if (bottomSheetDialog != null) {
            bottomSheetDialog.dismiss();
            etCommentBox.setVisibility(View.GONE);
        }

        if (text != null && !text.trim().isEmpty()) {
            tvCommentBox.setText(text);
        } else {
            tvCommentBox.setText(mContext.getResources().getString(R.string.write_comment_text) + " ...");
        }
    }

    @Override
    protected void destroyUIEvent() {
        doLeaveChannel(false);
        mUidsList.clear();
        if (etCommentBox != null && etCommentBox.getText() != null) {
            onKeyboardClosed(etCommentBox.getText().toString());
        }
        LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "destroyUIEvent");
    }

    @Override
    public void onFirstRemoteVideoDecoded(int uid, int width, int height, int elapsed) {
    }

    @Override
    public void onJoinChannelSuccess(final String channel, final int uid, final int elapsed) {

        if (!isFinishing()) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "onJoinChannelSuccess: " + uid);
                    if (isBroadCaster && uid == userId) {
                        isStreamingLive = true;
                        setDataInView();

                        tvEndStreamMsg.setText(mContext.getResources().getString(R.string.you_are_live_now));
                        tvEndLive.setText(mContext.getResources().getString(R.string.live_stream_end_text));
                        liveInfoHandler.removeCallbacks(showLiveInfoViewRunnableCode);
                        liveInfoHandler.postDelayed(showLiveInfoViewRunnableCode, viewShowTime);

                        startLiveStreamingTimer();
                        tvLiveDuration.setClickable(true);
                        Map<String, String> postParam = new HashMap<>();
                        String actionUrl = AppConstant.DEFAULT_URL + "livestreamingvideo/" +
                                "stop-video-streaming?stream_name=" + channelName + "&endType=normal";
                        actionUrl = mAppConst.buildQueryString(actionUrl, mAppConst.getAuthenticationParams());
                        actionUrl = mAppConst.buildQueryString(actionUrl, mAppConst.getRequestParams());

                        postParam.put("appid", mContext.getResources().getString(R.string.agora_app_id));
                        postParam.put("channel", channelName);
                        postParam.put("actionUrl", actionUrl);
                        mAppConst.postLiveStreamJsonRequest(AppConstant.LIVE_STREAM_DEFAULT_URL + "start", postParam, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) {
                                LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "Start LiveStreamJsonRequest, jsonObject: " + jsonObject);
                                sid = jsonObject.optString("sid", "");
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "Start LiveStreamJsonRequest, onErrorInExecutingTask: " + message);
                            }
                        });

                        // Making a request to server so that server will send notifications to all the users.
                        mAppConst.postJsonRequest(AppConstant.DEFAULT_URL + "livestreamingvideo/process-notification");
                    }

                    if (isFinishing()) {
                        return;
                    }

                    if (mUidsList.containsKey(uid)) {
                        return;
                    }

                    worker().getEngineConfig().mUid = uid;

                    SurfaceView surfaceV = mUidsList.remove(0);
                    if (surfaceV != null) {
                        mUidsList.put(uid, surfaceV);
                    }
                }
            });
        }
    }

    @Override
    public void onUserOffline(int uid, int reason) {
        LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "onUserOffline , uid: " + uid + " , " + (uid & 0xFFFFFFFFL) + " , reason: " + reason);
        doRemoveRemoteUi(uid);
    }

    @Override
    public void onUserJoined(int uid, int elapsed) {
        LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "onUserJoined , uid: " + uid + " , " + (uid & 0xFFFFFFFFL) + " , elapsed: " + elapsed);
        doRenderRemoteUi(uid);
    }

    @Override
    public void onRemoteStreamStatus(boolean showing) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!showing && tvEndStreamMsg.getVisibility() == View.GONE) {
                    LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "onRemoteStreamStatus video paused");
                    tvEndStreamMsg.setText(mContext.getResources().getString(R.string.live_video_paused));
                    tvEndStreamMsg.setVisibility(View.VISIBLE);
                } else if (showing && tvEndStreamMsg.getVisibility() == View.VISIBLE) {
                    LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "onRemoteStreamStatus video resumed");
                    tvEndStreamMsg.setVisibility(View.GONE);
                }
            }
        });
    }

    @Override
    public void onMessageChannelReceive(String channelName, String account, int uid, String msg) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (msg != null && channelName.equals(LiveRoomActivity.this.channelName)) {
                    JSONObject messageObject = new JSONObject();
                    try {
                        messageObject = new JSONObject(msg);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    if (messageObject.optBoolean("is_live_stream_viewer")) {
                        int userId = messageObject.optInt("user_id");
                        boolean isViewer = messageObject.optBoolean("is_viewer");
                        if (isBroadCaster) {
                            String userName = messageObject.optString("displayname");
                            String userImage = messageObject.optString("image_profile");
                            MemberDetails memberDetails = new MemberDetails(userId, userName, userImage, null);
                            if (!totalViewers.contains(userId)) {
                                totalViewers.add(userId);
                            }

                            if (isViewer && !viewerBrowseList.contains(memberDetails)) {
                                viewerBrowseList.add(memberDetails);
                            } else if (!isViewer) {
                                viewerBrowseList.remove(memberDetails);
                            }
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    tvViewCount.setText(String.valueOf(viewerBrowseList.size()));
                                }
                            });
                        }

                    } else if (messageObject.optBoolean("is_live_stream_reaction")) {
                        int userId = messageObject.optInt("user_id");
                        String reactionIcon = messageObject.optString("reaction_icon");
                        String userImage = messageObject.optString("user_image");
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                showLiveReaction(userImage, reactionIcon);
                            }
                        });
                    } else if (messageObject.optBoolean("is_live_stream_like")) {
                        int userId = messageObject.optInt("user_id");
                        String userImage = messageObject.optString("user_image");
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                showLiveReaction(userImage, null);
                            }
                        });

                    } else if (messageObject.optBoolean("is_live_stream_comment")) {
                        CommentList commentList = new CommentList();
                        commentList.setCommentBody(messageObject.optString("comment_body"));
                        commentList.setAuthorTitle(messageObject.optString("displayname"));
                        commentList.setAuthorPhoto(messageObject.optString("image_profile"));
                        commentList.setUserId(messageObject.optInt("user_id"));
                        mCommentListItems.add(commentList);
                        mCommentAdapter.notifyDataSetChanged();
                        //After adding comment to the list, scroll the list view to last position.
                        lvComment.post(new Runnable() {
                            @Override
                            public void run() {
                                //call smooth scroll
                                lvComment.smoothScrollToPosition(mCommentAdapter.getCount());
                            }
                        });
                    }
                }
            }
        });
    }

    /**
     * Method to initialize the views.
     */
    private void initializeViews() {

        footerView = CustomViews.getFooterView(getLayoutInflater());
        ProgressBar progressBar = footerView.findViewById(R.id.progressBar);
        if (progressBar != null) {
            Drawable drawable = progressBar.getIndeterminateDrawable();
            if (drawable != null) {
                drawable.mutate();
                drawable.setColorFilter(ContextCompat.getColor(mContext, R.color.white),
                        PorterDuff.Mode.MULTIPLY);
            }
        }
        mMainView = findViewById(R.id.rootView);
        bottomOptionsView = findViewById(R.id.bottomOptions);
        reactionsRecyclerView = findViewById(R.id.recycler_view);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        reactionsRecyclerView.setHasFixedSize(true);
        reactionsRecyclerView.setLayoutManager(linearLayoutManager);

        flVideoView = findViewById(R.id.video_view_container);
        cameraFlip = findViewById(R.id.cameraFlip);
        tvViewCount = findViewById(R.id.viewCount);
        tvLiveText = findViewById(R.id.liveText);
        tvLiveDuration = findViewById(R.id.liveTime);
        tvEndLive = findViewById(R.id.end);
        tvCommentBox = findViewById(R.id.commentBox);
        tvEndStreamMsg = findViewById(R.id.streamEndMessage);
        ivLike = findViewById(R.id.likeBtn);
        llLikeView = findViewById(R.id.likeView);
        GradientDrawable gradientDrawable = (GradientDrawable) tvCommentBox.getBackground();
        gradientDrawable.mutate();
        gradientDrawable.setStroke(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_0_2_dp),
                ContextCompat.getColor(mContext, R.color.white));
        gradientDrawable.setColor(ContextCompat.getColor(mContext, R.color.black_translucent));
        lvComment = findViewById(R.id.commentList);

        tvCommentBox.setOnClickListener(this);
        tvEndLive.setOnClickListener(this);
        if (isBroadCaster) {
            tvViewCount.setText("0");
            cameraFlip.setOnClickListener(this);
            tvLiveDuration.setOnClickListener(this);
            tvViewCount.setOnClickListener(this);
            tvLiveText.setOnClickListener(this);
        } else {
            tvEndLive.setText(mContext.getResources().getString(R.string.close_listing_label));
        }
        tvLiveDuration.setClickable(false);
        flVideoView.setOnClickListener(this);
        llLikeView.setOnClickListener(this);
    }

    /**
     * Method to start timer for live streaming in case of user is broadcaster.
     */
    private void startLiveStreamingTimer() {
        tvLiveDuration.setBase(SystemClock.elapsedRealtime());
        int allowedMinutes = PreferencesUtils.getLiveStreamingLimit(mContext);
        long allowedSeconds = allowedMinutes * 60;

        tvLiveDuration.setOnChronometerTickListener(chronometer -> {
            long time = SystemClock.elapsedRealtime() - chronometer.getBase();
            int liveSeconds = (int) (time/1000);

            showLiveDurationLimitMsg();

            // When the live video reached the maximum allowed duration.
            if (allowedSeconds != 0 && allowedSeconds < liveSeconds + 1
                    && !isFinishing()) {
                Intent intent = new Intent(mContext, EndLiveStreamingActivity.class);
                intent.putExtra(ConstantVariables.CHANNEL_NAME, channelName);
                intent.putExtra(ConstantVariables.SID, sid);
                intent.putExtra(ConstantVariables.LIVE_STREAM_VIEWERS_COUNT, totalViewers.size());
                if (postParams != null && !postParams.isEmpty()) {
                    intent.putExtra(ConstantVariables.POST_PARAMS, (Serializable) postParams);
                }
                intent.addFlags(Intent.FLAG_ACTIVITY_FORWARD_RESULT);
                mContext.startActivity(intent);
                terminateLiveStreaming();
            }
        });
        tvLiveDuration.setText("00:00");
        tvLiveDuration.start();
    }

    /**
     * Method to send comment through agora and update on server as well.
     *
     * @param commentBody Comment which needs to be send.
     */
    private void sendComment(String commentBody) {
        CommentList commentList = new CommentList();
        commentList.setAuthorPhoto(userImage);
        commentList.setAuthorTitle(displayName);
        commentList.setUserId(userId);
        commentList.setCommentBody(commentBody);

        JSONObject commentObject = new JSONObject();
        try {
            commentObject.put("user_id", userId);
            commentObject.put("displayname", displayName);
            commentObject.put("image_profile", userImage);
            commentObject.put("comment_body", commentBody);
            commentObject.put("is_live_stream_comment", true);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        mAgoraAPISignal.messageChannelSend(channelName, commentObject.toString(), UUID.randomUUID().toString());

        etCommentBox.setText("");

        if (bottomSheetDialog != null) {
            bottomSheetDialog.dismiss();
            etCommentBox.setVisibility(View.GONE);
        }

        //After adding comment to the list, scroll the list view to last position.
        lvComment.post(new Runnable() {
            @Override
            public void run() {
                //call smooth scroll
                lvComment.smoothScrollToPosition(mCommentAdapter.getCount());
            }
        });

        commentPostParam.put("body", commentBody);
        mAppConst.postJsonRequest(commentPostUrl, commentPostParam);
    }

    private void doLeaveChannel(boolean isAppClosed) {
        if (worker() != null && config() != null) {
            if (isAppClosed && isBroadCaster) {
                mAppConst.postJsonRequest(AppConstant.DEFAULT_URL + "livestreamingvideo/" +
                        "share-video?stream_name=" + channelName + "&endType=normal" +
                        "&sid=" + sid);
            }
            event().removeEventHandler(this);
            worker().leaveChannel(config().mChannel);
            if (isBroadcaster()) {
                worker().preview(false, null, 0);
            } else {
                publishJoinLeaveMessage(false);
            }
        }
    }

    /**
     * Method invoked when live streaming has been ended from broadcaster's side.
     */
    private void publishEndLiveStreamMessage() {
        if (isBroadCaster) {
            JSONObject endLiveStream = new JSONObject();
            try {
                endLiveStream.put("endmessage", mContext.getResources().getString(R.string.live_video_ended));
                endLiveStream.put("is_live_stream_dismiss", true);
                mAgoraAPISignal.messageChannelSend(channelName, endLiveStream.toString(), UUID.randomUUID().toString());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    private boolean isBroadcaster(int cRole) {
        return cRole == Constants.CLIENT_ROLE_BROADCASTER;
    }

    private boolean isBroadcaster() {
        return isBroadcaster(config().mClientRole);
    }

    /**
     * Method to set view according the type of the user broadcaster or subscriber.
     */
    private void setDataInView() {
        bottomOptionsView.setVisibility(View.VISIBLE);
        tvEndLive.setVisibility(View.VISIBLE);
        if (isBroadCaster) {
            tvLiveText.setVisibility(View.VISIBLE);
            tvViewCount.setVisibility(View.VISIBLE);
            cameraFlip.setVisibility(View.VISIBLE);
        } else {
            tvViewCount.setVisibility(View.GONE);
            cameraFlip.setVisibility(View.GONE);
            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) reactionsRecyclerView.getLayoutParams();
            layoutParams.weight = 0.6f;
        }
    }

    private void getComments(int pageNumber, boolean isLoadMoreRequest) {
        String commentUrl;
        if (isNestedCommentEnabled) {
            commentUrl = UrlUtil.NESTED_COMMENTS_VIEW_URL + "&order=asc&subject_type=" + subjectType + "&subject_id=" +
                    subjectId + "&page=" + pageNumber;
        } else {
            commentUrl = UrlUtil.LIKE_COMMENT_URL + "&subject_type=" + subjectType + "&subject_id=" +
                    subjectId + "&page=" + pageNumber;
        }
        mAppConst.getJsonResponseFromUrl(commentUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                if (isLoadMoreRequest) {
                    CustomViews.removeFooterView(lvComment, footerView);
                    isLoading = false;
                }

                if (jsonObject.length() != 0) {
                    try {
                        int totalComments = jsonObject.getInt("getTotalComments");
                        mCommentList.setmTotalCommmentCount(totalComments);
                        JSONArray commentsArray = jsonObject.optJSONArray("viewAllComments");
                        if (commentsArray != null && commentsArray.length() != 0) {
                            for (int i = 0; i < commentsArray.length(); i++) {
                                JSONObject commentInfoObject = commentsArray.getJSONObject(i);
                                int userId = commentInfoObject.optInt("user_id");
                                String authorPhoto = commentInfoObject.getString("author_image_profile");
                                String authorTitle = commentInfoObject.getString("author_title");
                                String commentBody = commentInfoObject.getString("comment_body");
                                CommentList commentList = new CommentList();
                                commentList.setAuthorPhoto(authorPhoto);
                                commentList.setAuthorTitle(authorTitle);
                                commentList.setUserId(userId);
                                commentList.setCommentBody(commentBody);
                                mCommentListItems.add(commentList);
                            }
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    mCommentAdapter.notifyDataSetChanged();

                    lvComment.postDelayed(() -> {
                        //call smooth scroll
                        lvComment.smoothScrollToPosition(mCommentAdapter.getCount());
                    }, 100L);
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                if (isLoadMoreRequest) {
                    CustomViews.removeFooterView(lvComment, footerView);
                    isLoading = false;
                }
            }
        });
    }

    // Reactions work in live streaming
    private void showReactions() {
        mReactionsEnabled = PreferencesUtils.getReactionsEnabled(mContext);

        if (PreferencesUtils.getAllReactionsObject(this) != null) {
            try {
                mReactionsObject = new JSONObject(PreferencesUtils.getAllReactionsObject(this));
                mReactionsArray = GlobalFunctions.sortReactionsObjectWithOrder(mReactionsObject);
            } catch (JSONException e) {
                e.printStackTrace();
            }

            if (mReactionsObject != null && mReactionsArray != null) {
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

                reactionsAdapter = new ImageAdapter(this, reactionsImages, true,
                        new OnItemClickListener() {
                            @Override
                            public void onItemClick(final View view, int position) {
                                if (isStreamingLive && position < mReactionsArray.size()) {
                                    ImageViewList imageViewList = reactionsImages.get(position);
                                    String reaction = imageViewList.getmReaction();
                                    final String reactionIcon = imageViewList.getmReactionIcon();
                                    int reactionId = imageViewList.getmReactionId();

                                    JSONObject liveReactions = new JSONObject();
                                    try {
                                        liveReactions.put("user_id", userId);
                                        liveReactions.put("reaction_icon", reactionIcon);
                                        liveReactions.put("user_image", userImage);
                                        liveReactions.put("is_live_stream_reaction", true);
                                        mAgoraAPISignal.messageChannelSend(channelName, liveReactions.toString(), UUID.randomUUID().toString());
                                    } catch (JSONException e) {
                                        e.printStackTrace();
                                    }

                                    /**
                                     * If the user Presses the same reaction again then don't do anything
                                     */
                                    if (liveReactionId != reactionId) {
                                        doLikeUnlike(reaction);
                                        liveReactionId = reactionId;
                                    }
                                }
                            }
                        });

                reactionsRecyclerView.setAdapter(reactionsAdapter);
                reactionsAdapter.notifyDataSetChanged();
            } else {
                showLikeOption();
            }
        } else {
            showLikeOption();
        }
    }

    /**
     * Method to show like option when reactions are not available.
     */
    private void showLikeOption() {
        reactionsRecyclerView.setVisibility(View.GONE);
        llLikeView.setVisibility(View.VISIBLE);
        LinearLayout.LayoutParams commentBoxParam = (LinearLayout.LayoutParams) tvCommentBox.getLayoutParams();
        commentBoxParam.weight = 0.68f;
        tvCommentBox.setLayoutParams(commentBoxParam);
    }

    /**
     * Method to show live reactions with animations.
     *
     * @param userImage    Image of the reaction owner.
     * @param reactionIcon Icon which needs to be float.
     */
    private void showLiveReaction(String userImage, String reactionIcon) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            final BezelImageView imageView = new BezelImageView(mContext);
            imageView.setMaskDrawable(ContextCompat.getDrawable(mContext, R.drawable.circle_mask));
            imageView.setBorderDrawable(ContextCompat.getDrawable(mContext, R.drawable.circle_border));
            if (reactionIcon != null && !reactionIcon.isEmpty()) {
                mImageLoader.setFeedImageWithAnimation(reactionIcon, imageView);
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
            mMainView.addView(imageView);

            float x1 = mAppConst.getScreenWidth() - 100;
            float y1 = mAppConst.getScreenHeight() - 200;

            if (x1 > mAppConst.getScreenWidth()) {
                x1 = mAppConst.getScreenWidth() - 70;
            }

            Path path = new Path();
            int random = (int) (Math.random() * 100);

            path.moveTo(x1 - 0, y1 - 40);
            path.lineTo(x1 - 0, y1 - 100);
            path.lineTo(x1 - 0, y1 - (400 + random));
            path.lineTo(x1 - 20, y1 - (430 + random));
            path.lineTo(x1 - 100, y1 - (450 + random));
            path.lineTo(x1 - (x1 + 150), y1 - (440 + random));

            ObjectAnimator objectAnimator =
                    ObjectAnimator.ofFloat(imageView, View.X,
                            View.Y, path);
            objectAnimator.setDuration(5000);
            objectAnimator.start();
            objectAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    if (bottomOptionsView.getVisibility() == View.INVISIBLE) {
                        imageView.bringToFront();
                    }
                }
            });
        }
    }

    /**
     * Method to make and api request to update reaction info.
     *
     * @param reaction Reaction which user has sent.
     */
    private void doLikeUnlike(String reaction) {

        String likeUnlikeUrl;
        final Map<String, String> likeParams = new HashMap<>();
        likeParams.put(ConstantVariables.SUBJECT_TYPE, videoType);
        likeParams.put(ConstantVariables.SUBJECT_ID, String.valueOf(videoId));
        if (reaction != null) {
            likeParams.put("reaction", reaction);
        }

        if (!isLiked || (mReactionsEnabled == 1 && reaction != null)) {
            if (mReactionsEnabled == 1 && isNestedCommentEnabled) {
                likeUnlikeUrl = AppConstant.DEFAULT_URL + "advancedcomments/like?sendNotification=0";
            } else {
                likeUnlikeUrl = AppConstant.DEFAULT_URL + "like";
            }
        } else {
            likeUnlikeUrl = AppConstant.DEFAULT_URL + "unlike";
        }

        mAppConst.postJsonResponseForUrl(likeUnlikeUrl, likeParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                if (mReactionsEnabled != 1 || reaction == null) {
                    isLiked = !isLiked;
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
            }
        });
    }

    /**
     * Method to show/hide the other views when user touches the video view.
     *
     * @param isNeedToShow True, if need to show views.
     */
    private void showHideViewOnTouch(boolean isNeedToShow) {
        tvLiveText.setVisibility(isNeedToShow ? View.VISIBLE : View.INVISIBLE);
        bottomOptionsView.setVisibility(isNeedToShow ? View.VISIBLE : View.INVISIBLE);
        lvComment.setVisibility(isNeedToShow ? View.VISIBLE : View.GONE);
        tvEndLive.setVisibility(isNeedToShow ? View.VISIBLE : View.GONE);
        tvViewCount.setVisibility(isNeedToShow && isBroadCaster ? View.VISIBLE : View.GONE);

        /* Change gravity/alignment of live time when end text visibility is changed */
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) tvLiveDuration.getLayoutParams();
        if (tvEndLive.getVisibility() == View.VISIBLE) {
            layoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT, 0);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                layoutParams.addRule(RelativeLayout.START_OF, R.id.end);
                layoutParams.addRule(RelativeLayout.ALIGN_PARENT_END, 0);
            }
            layoutParams.addRule(RelativeLayout.LEFT_OF, R.id.end);
        } else {
            layoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                layoutParams.addRule(RelativeLayout.ALIGN_PARENT_END);
            }
        }
    }

    private void doRenderRemoteUi(final int uid) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (isFinishing()) {
                    return;
                }

                SurfaceView surfaceV = RtcEngine.CreateRendererView(getApplicationContext());
                surfaceV.setZOrderOnTop(true);
                surfaceV.setZOrderMediaOverlay(true);
                mUidsList.put(uid, surfaceV);
                if (isBroadCaster) {
                    rtcEngine().setupLocalVideo(new VideoCanvas(surfaceV, VideoCanvas.RENDER_MODE_HIDDEN, uid));
                } else {
                    rtcEngine().setupRemoteVideo(new VideoCanvas(surfaceV, VideoCanvas.RENDER_MODE_HIDDEN, uid));
                }

                flVideoView.removeAllViews();
                flVideoView.addView(surfaceV);
                isStreamingLive = true;

                // Send the details to the broadcaster regarding streaming view info.
                if (!isStreamViewed && !isBroadCaster) {
                    setDataInView();
                    publishJoinLeaveMessage(true);
                    isStreamViewed = true;
                }
            }
        });
    }

    /**
     * Method to publish the agora signalling message when joined a stream and leaved that.
     *
     * @param isJoined True, if joined a stream.
     */
    private void publishJoinLeaveMessage(boolean isJoined) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("user_id", userId);
            jsonObject.put("displayname", displayName);
            jsonObject.put("image_profile", userImage);
            jsonObject.put("is_viewer", isJoined);
            jsonObject.put("is_live_stream_viewer", true);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        mAgoraAPISignal.messageChannelSend(channelName, jsonObject.toString(), UUID.randomUUID().toString());
    }

    private void doRemoveRemoteUi(final int uid) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (isFinishing()) {
                    return;
                }
                mUidsList.remove(uid);

                isStreamingLive = false;
                liveInfoHandler.removeCallbacks(showLiveInfoViewRunnableCode);
                tvEndLive.setVisibility(View.VISIBLE);
                tvEndStreamMsg.setText(mContext.getResources().getString(R.string.end_live_stream_message));
                tvEndStreamMsg.setVisibility(View.VISIBLE);
                cameraFlip.setVisibility(View.GONE);
                if (etCommentBox != null) {
                    etCommentBox.setVisibility(View.GONE);
                }
                tvCommentBox.setVisibility(View.GONE);
                llLikeView.setVisibility(View.GONE);
                reactionsRecyclerView.setVisibility(View.GONE);
                bottomOptionsView.getLayoutParams().height = 0;
                bottomOptionsView.setClickable(false);
                tvLiveText.setClickable(false);
                tvViewCount.setClickable(false);
                tvLiveDuration.setClickable(false);
            }
        });
    }

    /**
     * Method to terminate the live streaming.
     */
    private void terminateLiveStreaming() {
        if (isBroadCaster ) {
            mAppConst.postJsonRequest(AppConstant.DEFAULT_URL + "livestreamingvideo/" +
                    "stop-video-streaming?stream_name=" + channelName + "&endType=normal");

            if (isStreamingLive) {
                Map<String, String> postParam = new HashMap<>();
                postParam.put("sid", sid);

                mAppConst.postLiveStreamJsonRequest(AppConstant.LIVE_STREAM_DEFAULT_URL + "stop", postParam, new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) {
                        LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "Stop LiveStreamJsonRequest, jsonObject: " + jsonObject);
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        LogUtils.LOGD(LiveRoomActivity.class.getSimpleName(), "Stop LiveStreamJsonRequest, onErrorInExecutingTask: " + message);
                    }
                });
                publishEndLiveStreamMessage();
            }

        }
        finish();
    }

    /**
     * Method to display duration message for the live stream.
     */
    private void showLiveDurationLimitMsg() {
        if (!isLiveDurationMsgDisplayed && canShowDurationMsg
                && PreferencesUtils.getLiveStreamingLimit(mContext) != 0) {
            int minutes = PreferencesUtils.getLiveStreamingLimit(mContext);
            int hour = minutes / 60;
            String msg = mContext.getResources().getString(R.string.go_live_limit);
            if (hour != 0) {
                msg = msg + " " + hour;
                minutes = minutes % 60;
                if (minutes != 0) {
                    msg = msg + ":" + (minutes < 10 ? "0"+ minutes : minutes);
                }
                msg += " " + mContext.getResources().getQuantityString(R.plurals.plural_time_hour, hour);
            } else {
                msg = msg + " " + mContext.getResources().getQuantityString(R.plurals.plural_time_minute, minutes, minutes);
            }
            isLiveDurationMsgDisplayed = true;
            tvEndStreamMsg.setVisibility(View.VISIBLE);
            tvEndStreamMsg.setText(msg);
            liveInfoHandler.removeCallbacks(showLiveInfoViewRunnableCode);
            liveInfoHandler.postDelayed(showLiveInfoViewRunnableCode, viewShowTime);
            tvLiveDuration.setVisibility(View.VISIBLE);
        }
    }

    // Runnable for showing the view.
    private Runnable showViewRunnableCode = new Runnable() {
        @Override
        public void run() {
            tvLiveText.setVisibility(View.VISIBLE);
        }
    };

    // Runnable for showing the view.
    private Runnable showLiveInfoViewRunnableCode = new Runnable() {
        @Override
        public void run() {
            tvEndStreamMsg.setVisibility(View.GONE);
            canShowDurationMsg = true;
            showLiveDurationLimitMsg();
        }
    };
}
