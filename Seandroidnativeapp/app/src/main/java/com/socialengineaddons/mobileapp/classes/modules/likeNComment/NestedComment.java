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

package com.socialengineaddons.mobileapp.classes.modules.likeNComment;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.CardView;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.MenuItem;
import android.view.View;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.AddPeopleAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnAsyncResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommentDeleteListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.AddPeopleList;
import com.socialengineaddons.mobileapp.classes.common.utils.BitmapUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageViewList;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.Smileys;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.stickers.StickersClickListener;
import com.socialengineaddons.mobileapp.classes.modules.stickers.StickersPopup;
import com.socialengineaddons.mobileapp.classes.modules.stickers.StickersUtil;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import github.ankushsachdeva.emojicon.EmojiconTextView;

public class NestedComment extends AppCompatActivity implements View.OnClickListener, TextWatcher,
        AbsListView.OnScrollListener, AdapterView.OnItemClickListener, OnAsyncResponseListener, OnCommentDeleteListener {

    private Context mContext;
    private LinearLayout mNoCommentsBlock, mCommentPostBlock;
    private int width;
    private AppConstant mAppConst;
    private Typeface fontIcon;
    private List<CommentList> mCommentListItems;
    private CommentList mCommentList, mPostCommentList;
    private TextView mCommentPostButton, mNoCommentsImage, mPhotoUploadingButton, mCommentStickerPost;
    private SelectableTextView mNoCommentsText;
    private ListView mCommentsListView;
    private EditText mCommentBox;
    private RelativeLayout mSelectedImageBlock;
    private StickersPopup mStickersPopup;
    private Map<String, String> params;
    private ImageView mSelectedImageView, mCancelImageView, mSmallLoadIcon;
    private int mItemPosition, mCommentId = 0, mActionId = 0, mSubjectId, pageNumber = 1;
    private boolean mIsReply, mIsScrollToPos;
    private int mReactionsEnabled, mStickersEnabled;
    private int mCanComment, mGetTotalComments;
    public RelativeLayout mStickersParentView;
    private String mSubjectType, nestedRepliesUrl, mCommentNotificationUrl, mCommentType;
    private CommentAdapter mCommentAdapter;
    private AlertDialogWithAction mAlertDialogWithAction;
    private JSONArray mAllCommentsArray, mAllRepliesArray;
    private ArrayList<String> mSelectPath = new ArrayList<>();
    private String mAttachmentType;
    private HashMap<String, String> mClickableParts;
    private ListView mUserListView;
    private CardView mUserView;
    String searchText;
    private JSONObject tagObject;
    private AddPeopleAdapter mAddPeopleAdapter;
    private List<AddPeopleList> mAddPeopleList;
    private String mReplyPostUrl, mLikeCommentUrl;
    private TextView mLoadMoreCommentText, parentAuthorTitle, parentAuthorComment, parentCommentDate,
            parentCommentLike, parentCommentLikeCount, parentCommentReply;
    private ImageView parentAuthorImage, parentStickerImageView;
    private RelativeLayout parentAttachmentImageView;
    private LinearLayout parentLayout;
    View parentItem, header;
    private ImageLoader mImageLoader;
    private int commentReplyCount = 0, parentUserId, editItemPosition, mIsLike = 0, mLikeCount;;
    private JSONObject mLikeJsonObject;
    private boolean likeUnlikeAction = true;
    private int parentItemPosition = 0;
    private ProgressBar mSmallProgressBar;
    private Drawable stickerDrawable, commentPostDrawable;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_comment);
        mContext = this;

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(mContext.getResources().getString(R.string.title_nested_comment));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        width = AppConstant.getDisplayMetricsWidth(mContext);
        fontIcon = GlobalFunctions.getFontIconTypeFace(this);

        mStickersEnabled = PreferencesUtils.getStickersEnabled(mContext);

        mStickersParentView = findViewById(R.id.stickersMainLayout);
        mCommentPostBlock = findViewById(R.id.commentPostBlock);

        mCommentListItems = new ArrayList<>();
        mCommentList = new CommentList();
        mImageLoader = new ImageLoader(mContext);
        mCommentList.setmTotalCommmentCount(-1);

        mAddPeopleList = new ArrayList<>();

        mUserListView = findViewById(R.id.userList);
        mUserView = findViewById(R.id.users_view);

        mNoCommentsBlock = findViewById(R.id.noCommentsBlock);
        mNoCommentsImage = findViewById(R.id.noCommentsImage);
        mNoCommentsText = findViewById(R.id.noCommentsText);

        mNoCommentsImage.setTypeface(fontIcon);

        mCommentsListView = findViewById(R.id.commentList);
        mCommentBox = findViewById(R.id.commentBox);
        mCommentBox.addTextChangedListener(this);
        mCommentBox.requestFocus();
        mCommentPostButton = findViewById(R.id.commentPostButton);
        mCommentPostButton.setTypeface(fontIcon);

        mCommentStickerPost = findViewById(R.id.commentStickerPost);
        mCommentStickerPost.setTypeface(GlobalFunctions.getFontIconTypeFace(this));
        mCommentStickerPost.setOnClickListener(this);
        stickerDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_sticker_icon);
        commentPostDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_post_right_arrow);
        commentPostDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor),
                PorterDuff.Mode.SRC_ATOP));
        mCommentStickerPost.setBackground(stickerDrawable);
        mCommentPostButton.setBackground(commentPostDrawable);
        mCommentPostButton.setAlpha(0.1f);

        mPhotoUploadingButton = findViewById(R.id.photoUploadingButton);
        mPhotoUploadingButton.setOnClickListener(this);

        mSelectedImageBlock = findViewById(R.id.selectedImageBlock);
        mSelectedImageView = findViewById(R.id.imageView);
        mCancelImageView = findViewById(R.id.removeImageButton);
        Drawable addDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_cancel_black_24dp);
        addDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.black),
                PorterDuff.Mode.SRC_ATOP));
        mCancelImageView.setImageDrawable(addDrawable);

        if(mStickersEnabled == 1){
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.dark_grey_color),
                    PorterDuff.Mode.SRC_ATOP));
        } else{
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                    PorterDuff.Mode.SRC_ATOP));
        }

        mCommentPostButton.setOnClickListener(this);
        mAppConst = new AppConstant(this);

        mCommentBox.setHint(getResources().getString(R.string.write_reply_text) + "…");

        mItemPosition = getIntent().getIntExtra(ConstantVariables.ITEM_POSITION, 0);
        mActionId = getIntent().getIntExtra(ConstantVariables.ACTION_ID, 0);
        mSubjectType = getIntent().getStringExtra(ConstantVariables.SUBJECT_TYPE);
        mSubjectId = getIntent().getIntExtra(ConstantVariables.SUBJECT_ID, 0);
        mCommentType = getIntent().getStringExtra(ConstantVariables.COMMENT_TYPE);
        mCommentId = getIntent().getIntExtra("commentId", 0);
        mIsReply = getIntent().getBooleanExtra("isReply", false);
        mIsScrollToPos = getIntent().getBooleanExtra("isScrollToPos", false);

        mCommentAdapter = new CommentAdapter(this, R.layout.list_comment, mCommentListItems,
                mCommentList, true, mSubjectType, mSubjectId, mActionId, true);
        mCommentsListView.setAdapter(mCommentAdapter);
        mCommentsListView.setOnScrollListener(this);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);

        parentLayout = new LinearLayout(mContext);
        parentLayout.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
        parentLayout.setOrientation(LinearLayout.VERTICAL);

        parentItem = getLayoutInflater().inflate(R.layout.list_comment, null, false);
        header = getLayoutInflater().inflate(R.layout.load_comments_progress_item, null, false);

        parentLayout.addView(parentItem);
        parentLayout.addView(header);

        mSmallLoadIcon = parentLayout.findViewById(R.id.smallLoadIcon);
        mSmallProgressBar = parentLayout.findViewById(R.id.smallProgressBar);
        mLoadMoreCommentText = parentLayout.findViewById(R.id.loadMoreCommentText);
        mLoadMoreCommentText.setText(getResources().getString(R.string.previous_replies_text));
        mLoadMoreCommentText.setOnClickListener(this);

        parentAuthorImage = parentLayout.findViewById(R.id.authorImage);
        parentAuthorTitle = parentLayout.findViewById(R.id.authorTitle);
        parentAuthorComment = (EmojiconTextView) parentLayout.findViewById(R.id.commentBody);
        parentStickerImageView = parentLayout.findViewById(R.id.stickerImage);
        parentCommentDate = parentLayout.findViewById(R.id.commentDate);
        parentCommentLike = parentLayout.findViewById(R.id.likeOption);
        parentCommentLikeCount = parentLayout.findViewById(R.id.commentLikeCount);
        parentCommentReply = parentLayout.findViewById(R.id.replyOption);
        parentAttachmentImageView = parentLayout.findViewById(R.id.attachment_imageview);

        parentCommentLike.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark_color));
        parentCommentLikeCount.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark_color));
        parentCommentReply.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark_color));
        mSmallLoadIcon.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor),
                PorterDuff.Mode.SRC_ATOP));

        parentAuthorImage.setOnClickListener(this);
        parentAuthorTitle.setOnClickListener(this);
        parentCommentLike.setOnClickListener(this);
        parentCommentLikeCount.setOnClickListener(this);
        parentCommentReply.setOnClickListener(this);
        parentCommentLikeCount.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));

        if (mCommentType.equals(ConstantVariables.AAF_COMMENT)){
            nestedRepliesUrl = UrlUtil.AAF_LIKE_COMMNET_URL + "&action_id=" + mActionId + "&page=" + pageNumber + "&comment_id=" + mCommentId + "&order=desc";
            mCommentNotificationUrl = AppConstant.DEFAULT_URL + "advancedactivity/add-comment-notifications";

        } else if (mCommentType.equals(ConstantVariables.CONTENT_COMMENT)){
            nestedRepliesUrl = UrlUtil.NESTED_COMMENTS_VIEW_URL + "&subject_type=" + mSubjectType + "&subject_id=" +
                    mSubjectId + "&page=" + pageNumber + "&comment_id=" + mCommentId + "&order=desc";
            mCommentNotificationUrl = AppConstant.DEFAULT_URL + "add-comment-notifications";
        }

        sendRequestToServer(nestedRepliesUrl);

    }

    public void sendRequestToServer(String nestedRepliesUrl) {

        if(mCommentAdapter != null){
            mCommentAdapter.clear();
        }
        mAppConst.getJsonResponseFromUrl(nestedRepliesUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                findViewById(R.id.progressBar).setVisibility(View.GONE);
                if (jsonObject.length() != 0) {
                    try {
                        mCanComment = jsonObject.getInt("canComment");

                        // Show Comment Box only when canComment is true
                        if (mCanComment != 0) {
                            mCommentPostBlock.setVisibility(View.VISIBLE);
                            if (mStickersEnabled == 1) {
                                mAppConst.getJsonResponseFromUrl(UrlUtil.AAF_VIEW_STICKERS_URL, new OnResponseListener() {
                                    @Override
                                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                                        if (jsonObject != null) {
                                            mStickersPopup = StickersUtil.createStickersPopup(NestedComment.this, findViewById(R.id.comment_activity_view),
                                                    mStickersParentView, mCommentBox, jsonObject,
                                                    mPhotoUploadingButton, mCommentStickerPost);
                                            mStickersPopup.setOnStickerClickedListener(new StickersClickListener() {
                                                @Override
                                                public void onStickerClicked(ImageViewList stickerItem) {
                                                    params = new HashMap<>();
                                                    postComment(null, stickerItem.getmStickerGuid(),
                                                            stickerItem.getmGridViewImageUrl());
                                                }
                                            });
                                        }
                                    }

                                    @Override
                                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                                    }
                                });
                            }
                        }

                        mGetTotalComments = jsonObject.getInt("getTotalComments");

                        if(mGetTotalComments != 0) {
                        mNoCommentsBlock.setVisibility(View.GONE);
                        mAllCommentsArray = jsonObject.optJSONArray("viewAllComments");

                            if(mAllCommentsArray != null && mAllCommentsArray.length() != 0) {
                                    final JSONObject commentInfoObject = mAllCommentsArray.getJSONObject(0);

                                    //set data in parent comment view
                                    parentUserId = commentInfoObject.optInt("user_id");
                                    String mCommentBody = commentInfoObject.getString("comment_body");
                                    String mAuthorTitle = commentInfoObject.getString("author_title");
                                    String mCommentDate = commentInfoObject.getString("comment_date");
                                    String mAuthorPhoto = commentInfoObject.getString("author_image_profile");
                                    mLikeJsonObject = commentInfoObject.optJSONObject("like");
                                    mLikeCount = commentInfoObject.optInt("like_count");
                                    if(mLikeJsonObject != null)
                                        mIsLike = mLikeJsonObject.getInt("isLike");

                                    JSONObject parentAttachmentObject = commentInfoObject.optJSONObject("attachment");
                                    String parentStickerImage = null;
                                    JSONObject parentImageSize = null;
                                    if(parentAttachmentObject != null){
                                        parentStickerImage = parentAttachmentObject.optString("image_profile");
                                        parentImageSize = parentAttachmentObject.optJSONObject("size");
                                    }

                                    parentAuthorTitle.setText(mAuthorTitle);
                                    if (mCommentBody != null && !mCommentBody.isEmpty()) {
                                        parentAuthorComment.setText(mCommentBody);
                                        parentAuthorComment.setVisibility(View.VISIBLE);
                                    } else {
                                        parentAuthorComment.setVisibility(View.GONE);
                                    }
                                    String convertedDate = mAppConst.convertCommentsDateFormat(mContext.getResources(), mCommentDate);
                                    parentCommentDate.setText(convertedDate);
                                    mImageLoader.setImageForUserProfile(mAuthorPhoto, parentAuthorImage);

                                    if (parentStickerImage != null && !parentStickerImage.isEmpty()) {
                                        parentAttachmentImageView.setVisibility(View.VISIBLE);
                                        mImageLoader.setStickerImage(parentStickerImage, parentStickerImageView, parentImageSize);
                                    } else {
                                        parentAttachmentImageView.setVisibility(View.GONE);
                                    }

                                    if (mLikeJsonObject != null) {
                                        parentCommentLike.setVisibility(View.VISIBLE);
                                        if (mIsLike == 0) {
                                            parentCommentLike.setText(mContext.getString(R.string.like_text));
                                        } else {
                                            parentCommentLike.setText(mContext.getString(R.string.unlike));
                                        }
                                    } else {
                                        parentCommentLike.setVisibility(View.GONE);
                                    }

                                    if(mLikeCount > 0) {
                                        parentCommentLikeCount.setText(String.format("\uF087 %d", mLikeCount));
                                        parentCommentLikeCount.setVisibility(View.VISIBLE);
                                    }else{
                                        parentCommentLikeCount.setVisibility(View.GONE);
                                    }

                                    if (commentInfoObject.optJSONObject("reply") != null) {
                                        parentCommentReply.setVisibility(View.VISIBLE);
                                        parentCommentReply.setText(getResources().getString(R.string.reply_text));
                                    } else {
                                        parentCommentReply.setVisibility(View.GONE);
                                    }

                                    int replies_count = commentInfoObject.optInt("reply_count");
                                    mCommentList.setmTotalRepliesCount(replies_count);
                                    mCommentList.setmCommentModule(ConstantVariables.CONTENT_COMMENT);

                                    mAllRepliesArray = commentInfoObject.optJSONArray("reply_on_comment");

                                    if (mAllRepliesArray != null && mAllRepliesArray.length() != 0) {
                                        mCommentList.setmAllRepliesJSONArray(mAllRepliesArray);

                                        for (int i = 0; i < mAllRepliesArray.length(); i++) {
                                            JSONObject repliesInfoObject = mAllRepliesArray.getJSONObject(i);

                                            int user_id = repliesInfoObject.optInt("user_id");
                                            int commentId = repliesInfoObject.getInt("comment_id");
                                            String authorPhoto = repliesInfoObject.getString("author_image_profile");
                                            String authorTitle = repliesInfoObject.getString("author_title");
                                            String commentDate = repliesInfoObject.getString("comment_date");
                                            int likeCount = repliesInfoObject.optInt("like_count");
                                            JSONObject likeJsonObject = repliesInfoObject.optJSONObject("like");
                                            JSONObject attachmentObject = repliesInfoObject.optJSONObject("attachment");
                                            //for reply option of nested comments
                                            JSONObject replyJsonObject = repliesInfoObject.optJSONObject("reply");
                                            int replyCount = repliesInfoObject.optInt("reply_count");

                                            JSONArray commentMenus = repliesInfoObject.optJSONArray("gutterMenu");
                                            JSONArray replyOnCommentArray = repliesInfoObject.optJSONArray("reply_on_comment");
                                            JSONObject replyCommentJsonObject = null;
                                            if (replyOnCommentArray != null && replyOnCommentArray.length() != 0) {
                                                replyCommentJsonObject = replyOnCommentArray.optJSONObject(0);
                                            }

                                            /* CODE STARTS FOR  PREPARING Tags and comments body */
                                            String commentBody = repliesInfoObject.getString("comment_body");
                                            JSONArray tagsJsonArray = repliesInfoObject.optJSONArray("userTag");

                                            if (tagsJsonArray != null && tagsJsonArray.length() != 0) {
                                                commentBody = getCommentsBody(commentBody, tagsJsonArray);
                                            }

                                            String stickerImage = null;
                                            JSONObject imageSize = null;
                                            if (attachmentObject != null) {
                                                stickerImage = attachmentObject.optString("image_profile");
                                                imageSize = attachmentObject.optJSONObject("size");
                                            }
                                            int isLike = 0;
                                            if (likeJsonObject != null)
                                                isLike = likeJsonObject.getInt("isLike");

                                            mCommentListItems.add(0, new CommentList(user_id, commentId, likeCount, isLike, authorPhoto, authorTitle,
                                                    commentBody, mClickableParts, commentDate, likeJsonObject, replyJsonObject,
                                                    commentMenus, replyCommentJsonObject, stickerImage, imageSize, replyCount));
                                        }
                                    }

                                    //TODO
                                    /* Didn't show header in pre lollipop device as this row gives some error */
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                        mCommentsListView.addHeaderView(parentLayout);
                                    }
                            }
                        } else {
                            mNoCommentsBlock.setVisibility(View.VISIBLE);
                            mNoCommentsImage.setText("\uf0e5");
                            mNoCommentsText.setText(getResources().getString(R.string.no_replies_message));
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    mCommentAdapter.notifyDataSetChanged();
                    if (mCanComment != 0 && mIsReply) {
                        mAppConst.showKeyboard();
                    }
                    if ((ConstantVariables.COMMENT_LIMIT * pageNumber) < mCommentList.getmTotalRepliesCount()) {
                        header.setVisibility(View.VISIBLE);
                    } else {
                        header.setVisibility(View.GONE);
                    }
                    if (mIsScrollToPos) {
                        // Scroll listView to the bottom when any new comment is posted
                        mCommentsListView.postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                mCommentsListView.smoothScrollToPosition(mCommentAdapter.getCount());
                            }
                        }, 800L);
                    }
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                findViewById(R.id.progressBar).setVisibility(View.GONE);
                SnackbarUtils.displaySnackbarShortWithListener(findViewById(R.id.comment_activity_view),
                        message, new SnackbarUtils.OnSnackbarDismissListener() {
                            @Override
                            public void onSnackbarDismissed() {
                                finish();
                            }
                        });
            }
        });
    }

    private String getCommentsBody(String commentBody, JSONArray actionTypeBodyParams) {
        mClickableParts = new HashMap<>();

        int order = 1, id;
        String type, keyForClick;

        // Make Tagged Friends Name Clickable
        for (int j = 0; j < actionTypeBodyParams.length(); j++) {

            JSONObject actionBodyObject = actionTypeBodyParams.optJSONObject(j);
            String search = actionBodyObject.optString("resource_name");
            String label = search;
            id = actionBodyObject.optInt("resource_id");
            type = actionBodyObject.optString("type");

            if (commentBody.contains(search)) {
                keyForClick = order + "-" + type + "-" + id;
                label = label.replaceAll("\\s+", " ").trim();
                if (mClickableParts.containsKey(keyForClick)) {
                    keyForClick += "-" + label;
                }
                mClickableParts.put(keyForClick, label);

                ++order;

                commentBody = commentBody.replace(search, "<b>" + label + "</b>");
            }
        }

        return commentBody;
    }

    @Override
    public void onBackPressed() {

        if (mStickersParentView != null && mStickersParentView.getVisibility() == View.VISIBLE) {
            mStickersParentView.setVisibility(View.GONE);
        }
        super.onBackPressed();
        mAppConst.hideKeyboard();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here
        int id = item.getItemId();

        switch (id) {
            case android.R.id.home:
                onBackPressed();
                // Playing backSound effect when user tapped on back button from tool bar.
                if (PreferencesUtils.isSoundEffectEnabled(NestedComment.this)) {
                    SoundUtil.playSoundEffectOnBackPressed(NestedComment.this);
                }
                break;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onClick(View view) {

        int id = view.getId();
        String commentBody = mCommentBox.getText().toString().trim();

        switch (id) {
            case R.id.commentStickerPost:
                if (mStickersEnabled == 1 && (commentBody.isEmpty() && mSelectPath.isEmpty())) {
                    if (mStickersPopup != null) {
                        StickersUtil.showStickersKeyboard();
                    }
                }
                break;
            case R.id.commentPostButton:
                try {
                    byte[] bytes = commentBody.getBytes("UTF-8");
                    commentBody = new String(bytes, Charset.forName("UTF-8"));

                    if ((commentBody.length() == 0 || commentBody.trim().isEmpty()) && mSelectPath.isEmpty()) {
                        Toast.makeText(this, getResources().getString(R.string.reply_empty_msg),
                                Toast.LENGTH_SHORT).show();
                    } else {
                        params = new HashMap<>();

                        // Convert text smileys to emoticons in comments
                        commentBody = Smileys.getEmojiFromString(commentBody);

                        mCommentBox.setText("");
                        mCommentBox.setHint(getResources().getString(R.string.write_reply_text) + "…");
                        mAppConst.hideKeyboard();
                        mNoCommentsBlock.setVisibility(View.GONE);

                        postComment(commentBody, null, null);
                    }
                } catch (UnsupportedEncodingException | NullPointerException e) {
                    e.printStackTrace();
                }
                break;

            case R.id.photoUploadingButton:
                if(!mAppConst.checkManifestPermission(Manifest.permission.READ_EXTERNAL_STORAGE)){
                    mAppConst.requestForManifestPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                            ConstantVariables.READ_EXTERNAL_STORAGE);
                }else{
                    startImageUploadActivity(mContext, MultiMediaSelectorActivity.MODE_SINGLE, true, 1);
                }
                mAppConst.hideKeyboard();
                break;

            case R.id.loadMoreCommentText:
                mSmallLoadIcon.setVisibility(View.GONE);
                mSmallProgressBar.setVisibility(View.VISIBLE);
                mLoadMoreCommentText.setText(mContext.getResources().getString(R.string.loading_comments_text) + "...");

                pageNumber += 1;
                if (mCommentType.equals(ConstantVariables.AAF_COMMENT)){
                    nestedRepliesUrl = UrlUtil.AAF_LIKE_COMMNET_URL + "&action_id=" + mActionId + "&page=" + pageNumber + "&comment_id=" + mCommentId + "&order=desc";

                } else if (mCommentType.equals(ConstantVariables.CONTENT_COMMENT)){
                    nestedRepliesUrl = UrlUtil.NESTED_COMMENTS_VIEW_URL + "&subject_type=" + mSubjectType + "&subject_id=" +
                            mSubjectId + "&page=" + pageNumber + "&comment_id=" + mCommentId + "&order=desc";
                }
                loadMoreComments(nestedRepliesUrl);
                break;

            case R.id.authorImage:
            case R.id.authorTitle:
                Intent userProfileIntent = new Intent(mContext, userProfile.class);
                userProfileIntent.putExtra("user_id", parentUserId);
                ((Activity) mContext).startActivityForResult(userProfileIntent, ConstantVariables.
                        USER_PROFILE_CODE);
                ((Activity)mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.replyOption:
                mAppConst.showKeyboard();
                if (mCommentBox != null)
                    mCommentBox.requestFocus();
                break;

            case R.id.likeOption:

                if (likeUnlikeAction) {
                    if (mIsLike == 0) {
                        parentCommentLike.setText(mContext.getString(R.string.unlike));
                        parentCommentLikeCount.setVisibility(View.VISIBLE);
                        mIsLike = 1;
                        mLikeCount += 1;

                    } else {
                        parentCommentLike.setText(mContext.getString(R.string.like_text));
                        mIsLike = 0;
                        mLikeCount -= 1;
                    }
                    parentCommentLikeCount.setText(
                            String.format("\uF087 %d", mLikeCount));
                    if(mLikeCount == 0){
                        parentCommentLikeCount.setVisibility(View.GONE);
                    }
                    doLikeUnlike();
                    likeUnlikeAction = false;
                }
                break;

            case R.id.commentLikeCount:
                String viewAllCommentLikesUrl;
                if (mCommentType.equals(ConstantVariables.AAF_COMMENT)) {
                    viewAllCommentLikesUrl = UrlUtil.AAF_VIEW_LIKES_URL + "&comment_id=" + mCommentId +
                            "&action_id=" +mActionId;
                } else {
                    viewAllCommentLikesUrl = UrlUtil.VIEW_LIKES_URL + "&subject_type=" + mSubjectType + "&subject_id=" + mSubjectId +
                            "&comment_id=" + mCommentId;
                }
                Intent viewAllLikesIntent = new Intent(mContext, Likes.class);
                viewAllLikesIntent.putExtra("ViewAllLikesUrl", viewAllCommentLikesUrl);
                mContext.startActivity(viewAllLikesIntent);
                ((Activity)mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            default:
                break;
        }

    }

    public void doLikeUnlike(){

        try {
            final String likeUrl = mLikeJsonObject.getString("url");
            final int isLikeValue = mLikeJsonObject.optInt("isLike");
            final String likeLabel = mLikeJsonObject.getString("label");
            final String likeName = mLikeJsonObject.getString("name");

            if (mSubjectType.equals("activity_action")) {
                mLikeCommentUrl = AppConstant.DEFAULT_URL + "advancedactivity/" + likeUrl;
            } else {
                mLikeCommentUrl = AppConstant.DEFAULT_URL + likeUrl;
            }
            JSONObject urlParamsJsonObject = mLikeJsonObject.getJSONObject("urlParams");

            Map<String, String> likeUnlikeParams = new HashMap<>();

            JSONArray urlParamsKeys = urlParamsJsonObject.names();

            for (int i = 0; i < urlParamsJsonObject.length(); i++) {
                String keyName = urlParamsKeys.getString(i);
                String value = urlParamsJsonObject.getString(keyName);
                likeUnlikeParams.put(keyName, value);
            }

            mAppConst.postJsonResponseForUrl(mLikeCommentUrl, likeUnlikeParams,
                    new OnResponseListener() {
                        @Override
                        public void onTaskCompleted(JSONObject jsonObject) {

                            try {
                                if (isLikeValue == 0) {
                                    mLikeJsonObject.put("isLike", 1);
                                } else {
                                    mLikeJsonObject.put("isLike", 0);
                                }
                                if (likeLabel.equals("Like")) {
                                    mLikeJsonObject.put("label", "Unlike");
                                } else {
                                    mLikeJsonObject.put("label", "Like");
                                }
                                if (likeUrl.equals("like")) {
                                    mLikeJsonObject.put("url", "unlike");
                                } else {
                                    mLikeJsonObject.put("url", "like");
                                }
                                if (likeName.equals("unlike")) {
                                    mLikeJsonObject.put("name", "like");
                                } else {
                                    mLikeJsonObject.put("name", "unlike");
                                }

                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            Intent intent = new Intent();
                            intent.putExtra(ConstantVariables.ITEM_POSITION, mItemPosition);
                            intent.putExtra(ConstantVariables.COMMENT_OBJECT, String.valueOf(mLikeJsonObject));
                            intent.putExtra("likeCount", mLikeCount);
                            setResult(ConstantVariables.VIEW_lIKE_NESTED_REPLIES_PAGE, intent);

                            likeUnlikeAction = true;

                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                            likeUnlikeAction = true;
                            SnackbarUtils.displaySnackbar(findViewById(R.id.comment_activity_view), message);
                        }
                    });
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    /**
     * Method to start ImageUploadingActivity (MultiImageSelector)
     * @param context Context of Class.
     * @param selectedMode Selected mode i.e. multi images or single image.
     * @param showCamera Whether to display the camera.
     * @param maxNum Max number of images allowed to pick in case of MODE_MULTI.
     */
    public void startImageUploadActivity(Context context, int selectedMode, boolean showCamera, int maxNum){

        Intent intent;

        intent = new Intent(context, MultiMediaSelectorActivity.class);
        // Whether photoshoot
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SHOW_CAMERA, showCamera);
        // The maximum number of selectable image
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_COUNT, maxNum);
        // Select mode
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_MODE, selectedMode);
        // The default selection
        if (mSelectPath != null && mSelectPath.size() > 0) {
            intent.putExtra(MultiMediaSelectorActivity.EXTRA_DEFAULT_SELECTED_LIST, mSelectPath);
        }
        ((Activity) context).startActivityForResult(intent, ConstantVariables.REQUEST_IMAGE);

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        switch (requestCode) {
            case ConstantVariables.READ_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission granted, proceed to the normal flow
                    startImageUploadActivity(mContext, MultiMediaSelectorActivity.MODE_SINGLE, true, 1);
                } else{
                    // If user press deny in the permission popup
                    if (ActivityCompat.shouldShowRequestPermissionRationale((Activity) mContext,
                            Manifest.permission.READ_EXTERNAL_STORAGE)) {

                        // Show an expanation to the user After the user
                        // sees the explanation, try again to request the permission.

                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                                ConstantVariables.READ_EXTERNAL_STORAGE);
                    }else{
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.
                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, findViewById(R.id.rootView),
                                ConstantVariables.READ_EXTERNAL_STORAGE);
                    }
                }
                break;
        }
    }

    @Override
    public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

    }

    @Override
    public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

        if((charSequence != null && charSequence.length() > 0 &&
                !charSequence.toString().trim().isEmpty()) || (mAttachmentType != null && !mAttachmentType.isEmpty()) ){
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                    PorterDuff.Mode.SRC_ATOP));
            mCommentPostButton.setAlpha(1);

            if (charSequence.toString().contains("@")) {
                String chr = charSequence.toString().substring(charSequence.toString().indexOf("@"), charSequence.length());
                if (chr.length() > 1) {
                    StringBuilder stringBuilder = new StringBuilder(chr);
                    searchText = stringBuilder.deleteCharAt(0).toString();
                    getFriendList(UrlUtil.GET_FRIENDS_LIST + "?search=" + searchText);
                } else {
                    mUserView.setVisibility(View.GONE);
                }
            } else {
                mUserView.setVisibility(View.GONE);
            }

        }else if(mStickersEnabled == 1){
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.dark_grey_color),
                    PorterDuff.Mode.SRC_ATOP));
            mCommentPostButton.setAlpha(0.1f);
            if (mUserView.getVisibility() == View.VISIBLE) {
                mUserView.setVisibility(View.GONE);
            }
        } else{
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                    PorterDuff.Mode.SRC_ATOP));
            mCommentPostButton.setAlpha(0.1f);
            if (mUserView.getVisibility() == View.VISIBLE) {
                mUserView.setVisibility(View.GONE);
            }
        }
    }

    public void getFriendList(String url) {
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject body) throws JSONException {
                if (body != null && body.length() != 0) {

                    mAddPeopleList.clear();
                    JSONArray guestListResponse = body.optJSONArray("response");

                    initFriendsListView(guestListResponse.length());

                    for (int i = 0; i < guestListResponse.length(); i++) {
                        JSONObject friendObject = guestListResponse.optJSONObject(i);
                        String username = friendObject.optString("label");
                        int userId = friendObject.optInt("id");
                        String userImage = friendObject.optString("image_icon");

                        mAddPeopleList.add(new AddPeopleList(userId, username, userImage));

                    }
                    mAddPeopleAdapter.notifyDataSetChanged();
                } else {
                    mUserView.setVisibility(View.GONE);
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

            }
        });
    }

    private void initFriendsListView(int length) {

        RelativeLayout.LayoutParams layoutParams;
        if (length > 4) {
            layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT);
            layoutParams.height = (int) mContext.getResources().getDimension(R.dimen.user_list_tag_view_height);
        } else {
            layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT,
                    RelativeLayout.LayoutParams.WRAP_CONTENT);
        }
        layoutParams.addRule(RelativeLayout.ABOVE, mCommentPostBlock.getId());

        int margin10 = (int) mContext.getResources().getDimension(R.dimen.margin_10dp);
        int margin50 = (int) mContext.getResources().getDimension(R.dimen.margin_50dp);

        layoutParams.setMargins(margin10, margin10, margin50, margin10);
        mUserView.setLayoutParams(layoutParams);
        mUserView.setVisibility(View.VISIBLE);

        mAddPeopleAdapter = new AddPeopleAdapter(this, R.layout.list_friends, mAddPeopleList);
        mUserListView.setAdapter(mAddPeopleAdapter);
        mUserListView.setOnItemClickListener(this);
    }

    @Override
    public void afterTextChanged(Editable editable) {

    }

    @Override
    public void onScrollStateChanged(AbsListView absListView, int i) {

    }

    @Override
    public void onScroll(AbsListView absListView, int firstVisibleItem, int visibleItemCount, int totalItemCount) {

    }

    public void loadMoreComments(String nestedRepliesUrl){

        mAppConst.getJsonResponseFromUrl(nestedRepliesUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                header.setVisibility(View.GONE);

                if (jsonObject.length() != 0) {
                    try {
                        mAllCommentsArray = jsonObject.optJSONArray("viewAllComments");

                        if (mAllCommentsArray != null && mAllCommentsArray.length() != 0) {
                            JSONObject commentInfoObject = mAllCommentsArray.getJSONObject(0);

                            int replies_count = commentInfoObject.optInt("reply_count");
                            mCommentList.setmTotalRepliesCount(replies_count);
                            mCommentList.setmCommentModule(ConstantVariables.CONTENT_COMMENT);

                            mAllRepliesArray = commentInfoObject.optJSONArray("reply_on_comment");

                            if (mAllRepliesArray != null && mAllRepliesArray.length() != 0) {

                                for (int i = 0; i < mAllRepliesArray.length(); i++) {
                                    JSONObject repliesInfoObject = mAllRepliesArray.getJSONObject(i);
                                    addCommentsToList(repliesInfoObject);
                                }
                            }
                        }

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                SnackbarUtils.displaySnackbar(findViewById(R.id.comment_activity_view), message);
            }
        });
    }

    private void addCommentsToList(JSONObject repliesInfoObject) {

        if (repliesInfoObject != null) {
            String stickerImage = null;
            JSONObject imageSize = null;

            try {
                int user_id = repliesInfoObject.optInt("user_id");
                int commentId = repliesInfoObject.getInt("comment_id");
                String authorPhoto = repliesInfoObject.getString("author_image_profile");
                String authorTitle = repliesInfoObject.getString("author_title");
                String commentDate = repliesInfoObject.getString("comment_date");
                int likeCount = repliesInfoObject.optInt("like_count");
                JSONObject likeJsonObject = repliesInfoObject.optJSONObject("like");
                JSONObject attachmentObject = repliesInfoObject.optJSONObject("attachment");
                //for reply option of nested comments
                JSONObject replyJsonObject = repliesInfoObject.optJSONObject("reply");
                int replyCount = repliesInfoObject.optInt("reply_count");

                JSONArray commentMenus = repliesInfoObject.optJSONArray("gutterMenu");
                JSONArray replyOnCommentArray = repliesInfoObject.optJSONArray("reply_on_comment");
                JSONObject replyCommentJsonObject = null;
                if (replyOnCommentArray != null && replyOnCommentArray.length() != 0) {
                    replyCommentJsonObject = replyOnCommentArray.optJSONObject(0);
                }

                /* CODE STARTS FOR  PREPARING Tags and comments body */
                String commentBody = repliesInfoObject.getString("comment_body");
                JSONArray tagsJsonArray = repliesInfoObject.optJSONArray("userTag");

                if (tagsJsonArray != null && tagsJsonArray.length() != 0) {
                    commentBody = getCommentsBody(commentBody, tagsJsonArray);
                }
                if (attachmentObject != null) {
                    stickerImage = attachmentObject.optString("image_profile");
                    imageSize = attachmentObject.optJSONObject("size");
                }
                int isLike = 0;
                if (likeJsonObject != null)
                    isLike = likeJsonObject.getInt("isLike");

                mCommentListItems.add(0, new CommentList(user_id, commentId, likeCount, isLike, authorPhoto, authorTitle,
                        commentBody, mClickableParts, commentDate, likeJsonObject, replyJsonObject,
                        commentMenus, replyCommentJsonObject, stickerImage, imageSize, replyCount));


            } catch (JSONException e) {
                e.printStackTrace();
            }
            mCommentAdapter.notifyDataSetChanged();
            mSmallProgressBar.setVisibility(View.GONE);
            mSmallLoadIcon.setVisibility(View.VISIBLE);
            mLoadMoreCommentText.setText(mContext.getResources().getString(R.string.previous_replies_text));

            if ((ConstantVariables.COMMENT_LIMIT * pageNumber) < mCommentList.getmTotalRepliesCount()) {
                header.setVisibility(View.VISIBLE);
            } else {
                header.setVisibility(View.GONE);
            }
        }
    }

    private void postComment(String commentBody, String stickerGuid, String stickerImage) {

        Bitmap bitmap = null;
        if(mStickersEnabled == 1){
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.dark_grey_color),
                    PorterDuff.Mode.SRC_ATOP));
        } else{
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                    PorterDuff.Mode.SRC_ATOP));
        }
        mCommentPostButton.setAlpha(0.1f);

        if (mStickersParentView.getVisibility() == View.VISIBLE)
            mStickersParentView.setVisibility(View.GONE);
            mNoCommentsBlock.setVisibility(View.GONE);

        try {

            LogUtils.LOGD(NestedComment.class.getSimpleName(), "stickerGuid: "+stickerGuid);
            if(stickerGuid != null){
                params.put("attachment_type", "sticker");
                params.put("attachment_id", stickerGuid);
            } else if(mSelectPath != null && !mSelectPath.isEmpty()){
                params.put("attachment_type", mAttachmentType);
                bitmap = BitmapUtils.decodeSampledBitmapFromFile(NestedComment.this, mSelectPath.get(0),
                        width, (int) getResources().getDimension(R.dimen.feed_attachment_image_height), false);
            }
            // Show Comment instantly when user post it without like/delete options.
            if (PreferencesUtils.getUserDetail(this) != null) {

                JSONObject userDetail = new JSONObject(PreferencesUtils.getUserDetail(this));
                String profileIconImage = userDetail.getString("image_profile");
                int mLoggedInUserId = userDetail.getInt("user_id");
                String userName = userDetail.optString("displayname");
                mPostCommentList = new CommentList(mLoggedInUserId, userName, profileIconImage,
                        commentBody, stickerImage, true, bitmap);
                mCommentListItems.add(mPostCommentList);

                // Scroll listView to the bottom when any new comment is posted
                mCommentsListView.post(new Runnable() {
                    @Override
                    public void run() {
                        mCommentsListView.smoothScrollToPosition(mCommentAdapter.getCount());
                    }
                });
            }
            if (commentBody != null) {
                params.put("body", commentBody);
            }

            if (tagObject != null && tagObject.length() > 0) {
                params.put("composer", tagObject.toString());
            }

            if (mCommentType.equals(ConstantVariables.CONTENT_COMMENT)) {
                mReplyPostUrl = AppConstant.DEFAULT_URL + "advancedcomments/comment";
                mCommentNotificationUrl = AppConstant.DEFAULT_URL + "add-comment-notifications";
                params.put(ConstantVariables.SUBJECT_TYPE, mSubjectType);
                params.put(ConstantVariables.SUBJECT_ID, String.valueOf(mSubjectId));
                params.put("comment_id", String.valueOf(mCommentId));

            } else if (mCommentType.equals(ConstantVariables.AAF_COMMENT)) {
                mReplyPostUrl = AppConstant.DEFAULT_URL + "advancedcomments/reply?";
                params.put(ConstantVariables.ACTION_ID, String.valueOf(mActionId));
                params.put("comment_id", String.valueOf(mCommentId));
            }

            params.put("send_notification", "0");

            // Playing postSound effect when comment is posted.
            if (PreferencesUtils.isSoundEffectEnabled(this)) {
                SoundUtil.playSoundEffectOnPost(this);
            }

            if (mSelectPath != null && mSelectPath.size() != 0) {
                mSelectedImageBlock.setVisibility(View.GONE);

                // Uploading files in background with the details.
                new UploadFileToServerUtils(mContext, mReplyPostUrl, mSelectPath,
                        null, params).execute();

            } else {

                mAppConst.postJsonResponseForUrl(mReplyPostUrl, params, new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                        if(jsonObject != null) {
                            addCommentToList(jsonObject);
                        }
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        mCommentListItems.remove(mCommentAdapter.getCount() - 1);
                        SnackbarUtils.displaySnackbar(findViewById(R.id.comment_activity_view), message);
                    }
                });
            }
            } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void addCommentToList(JSONObject jsonObject) {

        if (jsonObject != null) {
            int commentId = 0;
            String stickerImage = null;
            JSONObject imageSize = null;

            try {
                int userId = jsonObject.optInt("user_id");
                commentId = jsonObject.getInt("comment_id");
                String authorPhoto = jsonObject.getString("image_icon");
                String authorTitle = jsonObject.getString("author_title");
                String commentDate = jsonObject.getString("comment_date");
                int likeCount = jsonObject.optInt("like_count");
                JSONObject likeJsonObject = jsonObject.optJSONObject("like");
                JSONObject attachmentObject = jsonObject.optJSONObject("attachment");
                if (attachmentObject != null) {
                    stickerImage = attachmentObject.optString("image_profile");
                    imageSize = attachmentObject.optJSONObject("size");
                }
                JSONObject replyJsonObject = jsonObject.optJSONObject("reply");
                JSONArray commentMenus = jsonObject.optJSONArray("gutterMenu");
                JSONArray replyOnCommentArray = jsonObject.optJSONArray("reply_on_comment");
                JSONObject replyCommentJsonObject = null;
                if (replyOnCommentArray != null && replyOnCommentArray.length() != 0) {
                    replyCommentJsonObject = replyOnCommentArray.optJSONObject(0);
                }
                int replyCount = jsonObject.optInt("reply_count");

                 /*CODE STARTS FOR  PREPARING Tags and comments body */
                String commentBody = jsonObject.getString("comment_body");
                JSONArray tagsJsonArray = jsonObject.optJSONArray("userTag");
                JSONObject paramsJsonObject = jsonObject.optJSONObject("params");

                if (tagsJsonArray != null && tagsJsonArray.length() != 0) {
                    commentBody = getCommentsBody(commentBody, tagsJsonArray);
                }
                int isLike = 0;
                if (likeJsonObject != null)
                    isLike = likeJsonObject.optInt("isLike");


                /*Remove the instantly added comment from the adapter after comment posted
                successfully and add a comment in adapter with full details.*/

                mCommentListItems.remove(mCommentListItems.size() - 1);

                mCommentListItems.add(new CommentList(userId, commentId, likeCount, isLike, authorPhoto, authorTitle,
                        commentBody, mClickableParts, commentDate, likeJsonObject, replyJsonObject,
                        commentMenus, replyCommentJsonObject, stickerImage, imageSize, replyCount));

                mCommentList.setmTotalRepliesCount(mCommentList.getmTotalRepliesCount() + 1);
                mCommentList.setmTotalReplyCount(mCommentList.getmTotalReplyCount() + 1);       //update more reply label count
                commentReplyCount += 1;

                /* Add reply to AllReplies array manually when post a comment */
                if (mAllRepliesArray != null) {
                    mAllRepliesArray.put(jsonObject);
                } else {
                    mAllRepliesArray = new JSONArray();
                    mAllRepliesArray.put(jsonObject);
                }

                mCommentList.setmAllRepliesJSONArray(mAllRepliesArray);

                Intent intent = new Intent();
                intent.putExtra(ConstantVariables.ITEM_POSITION, mItemPosition);
                intent.putExtra("commentReplyCount", mCommentList.getmTotalRepliesCount());
                intent.putExtra(ConstantVariables.COMMENT_OBJECT, String.valueOf(jsonObject));
                setResult(ConstantVariables.VIEW_NESTED_REPLIES_PAGE, intent);

            } catch (JSONException e) {
                e.printStackTrace();
            }
            mCommentAdapter.notifyDataSetChanged();

            // Scroll listView to the bottom when any new comment is posted
            int finalCommentId = commentId;
            mCommentsListView.post(new Runnable() {
                @Override
                public void run() {

                    params.put("comment_id", String.valueOf(finalCommentId));
                    params.remove("body");
                    params.remove("send_notification");

                    mAppConst.postJsonRequest(mCommentNotificationUrl, params);
                    mPhotoUploadingButton.setClickable(true);
                    mPhotoUploadingButton.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark));
                }
            });
        }
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        switch (requestCode) {
            case ConstantVariables.REQUEST_IMAGE:
                if(resultCode == RESULT_OK){

                    if (mSelectPath != null) {
                        mSelectPath.clear();
                    }
                    // Getting image path from uploaded images.
                    mSelectPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);
                    //Checking if there is any image or not.
                    if (mSelectPath != null) {
                        showSelectedImages(mSelectPath);
                    }

                }else if (resultCode != RESULT_CANCELED) {
                    // failed to capture image
                    Toast.makeText(getApplicationContext(),
                            getResources().getString(R.string.image_capturing_failed),
                            Toast.LENGTH_SHORT).show();
                } else {
                    // User cancel the process
                    /**
                     * Finish this activity if Photo Option get clicked from Main Feed page
                     * And if user press back button on photoUploading, so as to show Feedpage again
                     */
                }
                break;

            case ConstantVariables.NESTED_COMMENT_ACTIVITY_CODE:
                String itemObject;
                int itemPosition;

                switch (resultCode) {

                    case ConstantVariables.VIEW_NESTED_REPLIES_PAGE:
                        itemObject = data.getStringExtra(ConstantVariables.COMMENT_OBJECT);
                        itemPosition = data.getIntExtra(ConstantVariables.ITEM_POSITION, 0);
                        int postReplyCount = data.getIntExtra("commentReplyCount", 0);

                        if (itemObject != null && !itemObject.isEmpty()) {
                            try {
                                JSONObject replyObject = new JSONObject(itemObject);

                                CommentList selectedCommentRow = mCommentListItems.get(itemPosition);
                                selectedCommentRow.setmLastCommentReplyObject(replyObject);
                                selectedCommentRow.setmTotalReplyCount(postReplyCount);

                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }

                        break;

                    case ConstantVariables.VIEW_EDIT_NESTED_COMMENT_PAGE:
                        itemObject = data.getStringExtra(ConstantVariables.COMMENT_OBJECT);
                        itemPosition = data.getIntExtra(ConstantVariables.ITEM_POSITION, 0);
                        if (itemObject != null && !itemObject.isEmpty()) {
                            try {
                                JSONObject editedObject = new JSONObject(itemObject);

                                //update parent item if last reply is edited in nested replies
                                CommentList selectedCommentRow = mCommentListItems.get(itemPosition);
                                selectedCommentRow.setmLastCommentReplyObject(editedObject);

                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                        break;

                    case ConstantVariables.VIEW_DELETE_NESTED_REPLIES_PAGE:
                        itemObject = data.getStringExtra(ConstantVariables.COMMENT_OBJECT);
                        itemPosition = data.getIntExtra(ConstantVariables.ITEM_POSITION, 0);
                        boolean deleteLastItem = data.getBooleanExtra("deleteLastItem", false);
                        int deleteReplyCount = data.getIntExtra("deleteReplyCount", 0);

                        CommentList deletedCommentRow = mCommentListItems.get(itemPosition);
                        if (itemObject != null) {
                            try {
                                if (deleteLastItem) {
                                    deletedCommentRow.setmLastCommentReplyObject(null);
                                } else {
                                    JSONObject replyObject = new JSONObject(itemObject);
                                    //update parent item if last reply is deleted in nested replies
                                    deletedCommentRow.setmLastCommentReplyObject(replyObject);
                                }
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                        mCommentList.setmTotalRepliesCount(mCommentList.getmTotalRepliesCount() - 1);

                        deletedCommentRow.setmTotalReplyCount(deletedCommentRow.getmTotalReplyCount() - deleteReplyCount);
                        break;

                    case ConstantVariables.VIEW_lIKE_NESTED_REPLIES_PAGE:
                        itemObject = data.getStringExtra(ConstantVariables.COMMENT_OBJECT);
                        itemPosition = data.getIntExtra(ConstantVariables.ITEM_POSITION, 0);
                        int likeCount = data.getIntExtra("likeCount", 0);

                        if (itemObject != null && !itemObject.isEmpty()) {
                            try {
                                JSONObject likeObject = new JSONObject(itemObject);
                                //update selected item if parent comment is liked in nested replies
                                CommentList selectedCommentRow = mCommentListItems.get(itemPosition);
                                selectedCommentRow.setmLikeJsonObject(likeObject);

                                int mIsLike = likeObject.optInt("isLike");
                                selectedCommentRow.setmIsLike(mIsLike);
                                selectedCommentRow.setmLikeCount(likeCount);

                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                        break;
                }
                mCommentAdapter.notifyDataSetChanged();
                break;

            case ConstantVariables.EDIT_COMMENT_ACTIVITY_CODE:
                if (resultCode == ConstantVariables.VIEW_EDIT_COMMENT_PAGE) {

                    String itemEditObject = data.getStringExtra(ConstantVariables.COMMENT_OBJECT);
                    editItemPosition = data.getIntExtra(ConstantVariables.ITEM_POSITION, 0);

                    if (itemEditObject != null && !itemEditObject.isEmpty()) {
                        try {
                            JSONObject editedObject = new JSONObject(itemEditObject);
                            String mCommentBody = editedObject.optString("comment_body");

                            //update edited item on replies page
                            CommentList selectedCommentRow = mCommentListItems.get(editItemPosition);
                            selectedCommentRow.setmCommentBody(mCommentBody);

                            //update parent item if last reply is edited in nested replies
                            int repliesCount = mCommentList.getmTotalRepliesCount();
                            if (editItemPosition == repliesCount - 1){
                                Intent intent = new Intent();
                                intent.putExtra(ConstantVariables.ITEM_POSITION, mItemPosition);
                                intent.putExtra(ConstantVariables.COMMENT_OBJECT, String.valueOf(editedObject));
                                setResult(ConstantVariables.VIEW_EDIT_NESTED_COMMENT_PAGE, intent);
                            }

                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                    mCommentAdapter.notifyDataSetChanged();
                }
        }
    }

    /**
     * Method to show selected images.
     * @param mSelectPath list of selected images.
     */
    public void showSelectedImages(final ArrayList<String> mSelectPath) {

        mAttachmentType = "photo";
        stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                PorterDuff.Mode.SRC_ATOP));
        mCommentPostButton.setAlpha(1);
        mSelectedImageBlock.setVisibility(View.VISIBLE);

        for (final String imagePath : mSelectPath) {

            // Getting Bitmap from its real path.
            Bitmap bitmap = BitmapUtils.decodeSampledBitmapFromFile(NestedComment.this, imagePath,
                    (int) getResources().getDimension(R.dimen.profile_image_width_height),
                    (int) getResources().getDimension(R.dimen.profile_image_width_height), false);

            // If there is any null image then remove from image path.
            if (bitmap != null) {
                // Creating ImageView & params for this and adding selected images in this view.
                mSelectedImageView.setImageBitmap(bitmap);

                // Setting OnClickListener on cancelImage.
                mCancelImageView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mSelectPath.remove(imagePath);

                        // If canceled all the selected images then hide photoBlockLayout
                        // and enabled other attachement click.
                        if (mSelectPath.isEmpty()) {
                            mAttachmentType = null;
                            mSelectedImageBlock.setVisibility(View.GONE);
                            if(mCommentBox.getText().toString().trim().isEmpty()){
                                if(mStickersEnabled == 1){
                                    stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.dark_grey_color),
                                            PorterDuff.Mode.SRC_ATOP));
                                } else{
                                    stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                                            PorterDuff.Mode.SRC_ATOP));
                                }
                                mCommentPostButton.setAlpha(0.1f);
                            }
                        }
                    }
                });
            }
        }
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {

    }

    @Override
    public void onAsyncSuccessResponse(JSONObject response, boolean isRequestSuccessful, boolean isAttachFileRequest) {

        if (BitmapUtils.isImageRotated)
            BitmapUtils.deleteImageFolder();
        if (response != null) {
            JSONObject bodyObject = response.optJSONObject("body");
            addCommentToList(bodyObject);
            mSelectPath.clear();
        }
    }

    @Override
    public void onCommentDelete() {

    }
}
