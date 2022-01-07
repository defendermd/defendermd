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
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.PagerAdapter;
import android.support.v7.widget.CardView;
import android.text.Editable;
import android.text.Html;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.TextWatcher;

import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
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
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommentDeleteListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommentPostListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.AddPeopleList;
import com.socialengineaddons.mobileapp.classes.common.utils.BitmapUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
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
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.modules.stickers.StickersClickListener;
import com.socialengineaddons.mobileapp.classes.modules.stickers.StickersGridView;
import com.socialengineaddons.mobileapp.classes.modules.stickers.StickersPopup;
import com.socialengineaddons.mobileapp.classes.modules.stickers.StickersUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Comment extends AppCompatActivity implements View.OnClickListener, TextWatcher,
        AbsListView.OnScrollListener, OnCommentPostListener, AdapterView.OnItemClickListener, OnCommentDeleteListener {

    private String mLikeCommentUrl, mSubjectType;
    private String mCommentPostUrl, mViewLikesUrl, mCommentNotificationUrl;
    private int mSubjectId;
    private AppConstant mAppConst;
    private View mLikeCommentSeparator;
    private TextView mNextIcon;
    private SelectableTextView mLikeCountInfo, mNoCommentsText;
    private ListView mCommentsListView;
    private EditText mCommentBox;
    private TextView mCommentPostButton, mNoCommentsImage, mPhotoUploadingButton, mCommentStickerPost;
    private RelativeLayout mLikeCountInfoContainer;
    private LinearLayout mNoCommentsBlock, mCommentPostBlock, mPopularReactionsLayout;
    private int mFeedItemPosition;
    private int mCanComment, mGetTotalComments, mGetTotalLikes, mGetTotalItemCount;
    private JSONArray mAllCommentsArray;
    private List<CommentList> mCommentListItems;
    private CommentList mCommentList, mPostCommentList;
    private CommentAdapter mCommentAdapter;
    private Toolbar mToolbar;
    private Typeface fontIcon;
    private boolean isPhotoComment;
    private boolean isLoading = false;
    private int pageNumber = 1, mActionId = 0, mPhotoPosition;
    private View headerView;
    private Map<String, String> params;
    private int mReactionsEnabled, mStickersEnabled;
    private JSONObject mPopularReactions;
    private Context mContext;
    private StickersPopup mStickersPopup;
    private ArrayList<String> mSelectPath = new ArrayList<>();
    private RelativeLayout mSelectedImageBlock;
    private ImageView mSelectedImageView, mCancelImageView, mSmallLoadIcon;
    private String mAttachmentType;
    private AlertDialogWithAction mAlertDialogWithAction;
    private int width;
    public RelativeLayout mStickersParentView;
    private boolean isNestedCommentEnabled, isContentModule = false;
    private AddPeopleAdapter mAddPeopleAdapter;
    private List<AddPeopleList> mAddPeopleList;
    private String tagString;
    private ListView mUserListView;
    private CardView mUserView;
    String searchText;
    private JSONObject tagObject;
    private HashMap<String, String> mClickableParts;
    private TextView mLoadMoreCommentText;
    private ProgressBar mSmallProgressBar;
    private Drawable stickerDrawable, commentPostDrawable;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_comment);
        mContext = this;

         /*
        Set Back Button on Action Bar
         */
        mToolbar = (Toolbar) findViewById(R.id.toolbar);

        setSupportActionBar(mToolbar);
        if(getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        CustomViews.createMarqueeTitle(this, mToolbar);
        width = AppConstant.getDisplayMetricsWidth(mContext);

        fontIcon = GlobalFunctions.getFontIconTypeFace(this);

        mCommentListItems = new ArrayList<>();
        mCommentList = new CommentList();
        mCommentList.setmTotalCommmentCount(-1);

        mAddPeopleList = new ArrayList<>();

        mSubjectType = getIntent().getStringExtra(ConstantVariables.SUBJECT_TYPE);

        if(mSubjectType != null && !mSubjectType.equals("activity_action")){
            isContentModule = true;
        }

        mStickersEnabled = PreferencesUtils.getStickersEnabled(mContext);
        isNestedCommentEnabled = PreferencesUtils.isNestedCommentEnabled(mContext);

        mStickersParentView = (RelativeLayout) findViewById(R.id.stickersMainLayout);
        mCommentPostBlock = (LinearLayout) findViewById(R.id.commentPostBlock);
        mLikeCountInfoContainer = (RelativeLayout) findViewById(R.id.likeCountInfoContainer);
        mLikeCountInfoContainer.setClickable(true);
        mLikeCountInfoContainer.setOnClickListener(this);

        mPopularReactionsLayout = (LinearLayout) findViewById(R.id.popularReactionIcons);

        mUserListView = (ListView) findViewById(R.id.userList);
        mUserView = (CardView) findViewById(R.id.users_view);

        mLikeCountInfo = (SelectableTextView) findViewById(R.id.likeCountInfo);
        mNextIcon = (TextView) findViewById(R.id.nextIcon);

        mNoCommentsBlock = (LinearLayout) findViewById(R.id.noCommentsBlock);
        mNoCommentsImage = findViewById(R.id.noCommentsImage);
        mNoCommentsText = (SelectableTextView) findViewById(R.id.noCommentsText);

        mCommentsListView = (ListView) findViewById(R.id.commentList);
        mCommentBox = (EditText) findViewById(R.id.commentBox);
        mCommentBox.addTextChangedListener(this);
        mCommentBox.requestFocus();
        mCommentPostButton = (TextView) findViewById(R.id.commentPostButton);
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

        mPhotoUploadingButton = (TextView) findViewById(R.id.photoUploadingButton);
        mPhotoUploadingButton.setOnClickListener(this);

        mSelectedImageBlock = (RelativeLayout) findViewById(R.id.selectedImageBlock);
        mSelectedImageView = (ImageView) findViewById(R.id.imageView);
        mCancelImageView = (ImageView) findViewById(R.id.removeImageButton);
        Drawable addDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_cancel_black_24dp);
        addDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.black),
                PorterDuff.Mode.SRC_ATOP));
        mCancelImageView.setImageDrawable(addDrawable);

        /*
            In case of AAF: Show Stickers icon only if stickers are enabled,
             we do not put nestedcomment plugin's dependency on AAF.

             In case of Content modules comments: Show stickers icon if stickers
             nestedcomments both are enabled from website else do not show stickers icon.
         */
        if(mStickersEnabled == 1 && (!isContentModule ||  (isContentModule && isNestedCommentEnabled))){
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.dark_grey_color),
                    PorterDuff.Mode.SRC_ATOP));
        } else{
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                    PorterDuff.Mode.SRC_ATOP));
        }

        mLikeCommentSeparator = findViewById(R.id.likeCommentSaperator);

        mCommentPostButton.setOnClickListener(this);
        mAppConst = new AppConstant(this);

        mCommentBox.setHint(getResources().getString(R.string.write_comment_text) + "…");

        mSubjectType = getIntent().getStringExtra(ConstantVariables.SUBJECT_TYPE);
        mSubjectId = getIntent().getIntExtra(ConstantVariables.SUBJECT_ID, 0);
        mLikeCommentUrl = getIntent().getStringExtra(ConstantVariables.LIKE_COMMENT_URL);
        mSubjectId = getIntent().getIntExtra(ConstantVariables.SUBJECT_ID, 0);
        isPhotoComment = getIntent().getBooleanExtra(ConstantVariables.IS_PHOTO_COMMENT, false);
        mPhotoPosition = getIntent().getIntExtra(ConstantVariables.PHOTO_POSITION, -1);
        mFeedItemPosition = getIntent().getIntExtra(ConstantVariables.ITEM_POSITION, 0);

        mLikeCommentUrl = getLikeCommentUrl();

        mActionId = getIntent().getIntExtra(ConstantVariables.ACTION_ID, 0);
        if(mActionId != 0) {
            mLikeCommentUrl += "&action_id=" + mActionId;
        }

        mReactionsEnabled = getIntent().getIntExtra("reactionsEnabled", 0);
        if (PreferencesUtils.getEmojiEnabled(mContext) == 1) {
            mPhotoUploadingButton.setVisibility(View.VISIBLE);
        } else {
            mPhotoUploadingButton.setVisibility(View.GONE);
            LinearLayout.LayoutParams commentBoxParams = (LinearLayout.LayoutParams) mCommentBox.getLayoutParams();
            commentBoxParams.weight = 0.9f;
            mCommentBox.setLayoutParams(commentBoxParams);
        }
        try {
            if(getIntent().getStringExtra("popularReactions") != null)
                mPopularReactions = new JSONObject(getIntent().getStringExtra("popularReactions"));
        } catch (JSONException e) {
            e.printStackTrace();
        }

        mCommentAdapter = new CommentAdapter(this, R.layout.list_comment, mCommentListItems,
                mCommentList, true, mSubjectType, mSubjectId, mActionId, false);
        mCommentsListView.setAdapter(mCommentAdapter);
        mCommentsListView.setOnScrollListener(this);
        mAppConst = new AppConstant(this);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        headerView = CustomViews.getHeaderView(getLayoutInflater());
        mSmallLoadIcon = (ImageView) headerView.findViewById(R.id.smallLoadIcon);
        mSmallProgressBar = (ProgressBar) headerView.findViewById(R.id.smallProgressBar);
        mLoadMoreCommentText = (TextView) headerView.findViewById(R.id.loadMoreCommentText);
        mLoadMoreCommentText.setOnClickListener(this);
        mSmallLoadIcon.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor),
                PorterDuff.Mode.SRC_ATOP));

        sendRequestToServer(mLikeCommentUrl);

    }

    public void sendRequestToServer(String commentListUrl){

        if(mCommentAdapter != null){
            mCommentAdapter.clear();
        }

        mAppConst.getJsonResponseFromUrl(commentListUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                findViewById(R.id.progressBar).setVisibility(View.GONE);
                if (jsonObject.length() != 0) {
                    try {
                        mCanComment = jsonObject.optInt("canComment");
                        mGetTotalLikes = jsonObject.getInt("getTotalLikes");

                        // Show Comment Box only when canComment is true
                        if(mCanComment != 0) {
                            mCommentPostBlock.setVisibility(View.VISIBLE);
                            if (mStickersEnabled == 1) {
                                mAppConst.getJsonResponseFromUrl(UrlUtil.AAF_VIEW_STICKERS_URL, new OnResponseListener() {

                                    @Override
                                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                                        if(jsonObject != null){
                                            mStickersPopup = StickersUtil.createStickersPopup(Comment.this, findViewById(R.id.comment_activity_view),
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

                        // Show Like Count info
                        if(mGetTotalLikes != 0){
                            if(mReactionsEnabled == 1){

                                if(mPopularReactions != null && mPopularReactions.length() != 0){
                                    mPopularReactionsLayout.setVisibility(View.VISIBLE);

                                    JSONArray reactionIds = mPopularReactions.names();

                                    for(int i = 0; i < mPopularReactions.length() && i < 3; i++){
                                        String imageUrl = mPopularReactions.optJSONObject(reactionIds.optString(i)).
                                                optString("reaction_image_icon");
                                        int reactionId = mPopularReactions.optJSONObject(reactionIds.optString(i)).
                                                optInt("reactionicon_id");

                                        mPopularReactionsLayout.addView(CustomViews
                                                .generateReactionImageView(mContext, reactionId, imageUrl));
                                    }
                                }
                                mLikeCountInfo.setText(String.valueOf(mGetTotalLikes));
                                RelativeLayout.LayoutParams layoutParams = CustomViews.
                                        getCustomWidthHeightRelativeLayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1);
                                layoutParams.addRule(RelativeLayout.BELOW, R.id.likeCountInfoContainer);
                                int margin_10dp = (int) mContext.getResources().getDimension(R.dimen.margin_10dp);
                                layoutParams.setMargins(margin_10dp, 0, margin_10dp, margin_10dp);
                                mLikeCommentSeparator.setLayoutParams(layoutParams);
                            } else {
                                mLikeCountInfo.setPadding((int) mContext.getResources().getDimension(R.dimen.padding_5dp), 0, 0, 0);
                                mLikeCountInfo.setTypeface(fontIcon);
                                String likeText = getResources().getQuantityString(R.plurals.comment_page_like,
                                        mGetTotalLikes);
                                String peopleText = getResources().getQuantityString(R.plurals.comment_page_people_text,
                                        mGetTotalLikes, mGetTotalLikes);
                                mLikeCountInfo.setText(Html.fromHtml(String.format(
                                        "\uf087" + "  " + getResources().getString(R.string.comment_page_like_count_text_format),
                                        "<b>" + peopleText + "</b>", likeText,
                                        getResources().getString(R.string.comment_page_like_count_text)
                                )));
                            }


                            mNextIcon.setTypeface(fontIcon);
                            mNextIcon.setText("\uf054");
                            mLikeCommentSeparator.setVisibility(View.VISIBLE);
                            mLikeCountInfoContainer.setVisibility(View.VISIBLE);
                        }else{
                            mLikeCommentSeparator.setVisibility(View.GONE);
                            mLikeCountInfoContainer.setVisibility(View.GONE);
                        }

                        mGetTotalComments = jsonObject.getInt("getTotalComments");
                        mCommentList.setmTotalCommmentCount(mGetTotalComments);

                        mGetTotalItemCount = jsonObject.optInt("getTotalItemCount");
                        mCommentList.setmTotalItemCount(mGetTotalItemCount);

                        if(mGetTotalComments != 0){
                            mNoCommentsBlock.setVisibility(View.GONE);
                            mAllCommentsArray = jsonObject.optJSONArray("viewAllComments");

                            if(mAllCommentsArray != null && mAllCommentsArray.length() != 0){
                                for (int i = 0; i < mAllCommentsArray.length(); i++){
                                    JSONObject commentInfoObject = mAllCommentsArray.getJSONObject(i);
                                    int user_id = commentInfoObject.optInt("user_id");
                                    int commentId = commentInfoObject.getInt("comment_id");
                                    String authorPhoto = commentInfoObject.getString("author_image_profile");
                                    String authorTitle = commentInfoObject.getString("author_title");
                                    String commentDate = commentInfoObject.getString("comment_date");
                                    int likeCount = commentInfoObject.optInt("like_count");
                                    JSONObject likeJsonObject = commentInfoObject.optJSONObject("like");
                                    JSONObject attachmentObject = commentInfoObject.optJSONObject("attachment");
                                    //for reply option of nested comments
                                    JSONObject replyJsonObject = commentInfoObject.optJSONObject("reply");
                                    int replyCount = commentInfoObject.optInt("reply_count");

                                    JSONArray commentMenus = commentInfoObject.optJSONArray("gutterMenu");
                                    JSONArray replyOnCommentArray = commentInfoObject.optJSONArray("reply_on_comment");
                                    JSONObject replyCommentJsonObject = null;
                                    if (replyOnCommentArray != null && replyOnCommentArray.length() != 0) {
                                        replyCommentJsonObject = replyOnCommentArray.optJSONObject(0);
                                    }

                                     /* CODE STARTS FOR  PREPARING Tags and comments body */
                                    String commentBody = commentInfoObject.getString("comment_body");
                                    JSONArray tagsJsonArray = commentInfoObject.optJSONArray("userTag");

                                    if (tagsJsonArray != null && tagsJsonArray.length() != 0) {
                                        commentBody = getCommentsBody(commentBody, tagsJsonArray);
                                    }

                                    String stickerImage = null;
                                    JSONObject imageSize = null;
                                    if(attachmentObject != null){
                                        stickerImage = attachmentObject.optString("image_profile");
                                        imageSize = attachmentObject.optJSONObject("size");
                                    }
                                    int isLike = 0;
                                    if(likeJsonObject != null)
                                        isLike = likeJsonObject.getInt("isLike");

                                    mCommentListItems.add(0, new CommentList(user_id, commentId, likeCount, isLike, authorPhoto,
                                            authorTitle, commentBody, mClickableParts, commentDate, likeJsonObject,
                                            replyJsonObject, commentMenus, replyCommentJsonObject, stickerImage, imageSize, replyCount));
                                }
                            }
                        }else{
                            mNoCommentsBlock.setVisibility(View.VISIBLE);
                        }

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    mCommentAdapter.notifyDataSetChanged();

                    if (ConstantVariables.COMMENT_LIMIT * pageNumber < mCommentList.getmTotalItemCount()) {
                        mCommentsListView.addHeaderView(headerView);
                    }

                    mCommentsListView.postDelayed( new Runnable() {
                        @Override
                        public void run() {
                            //call smooth scroll
                            mCommentsListView.smoothScrollToPosition(mCommentAdapter.getCount());
                        }
                    }, 500L);

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
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        switch (id){
            case android.R.id.home:
                onBackPressed();
                // Playing backSound effect when user tapped on back button from tool bar.
                if (PreferencesUtils.isSoundEffectEnabled(Comment.this)) {
                    SoundUtil.playSoundEffectOnBackPressed(Comment.this);
                }
                return true;
            default:
                break;

        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {

        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public void onBackPressed() {

        if (mStickersParentView != null && mStickersParentView.getVisibility() == View.VISIBLE) {
            mStickersParentView.setVisibility(View.GONE);

        } else {
            int totalComments = mCommentList.getmTotalCommmentCount();
            if (totalComments >= 0) {
                Intent intent = new Intent();
                intent.putExtra(ConstantVariables.ITEM_POSITION, mFeedItemPosition);
                intent.putExtra(ConstantVariables.PHOTO_POSITION, mPhotoPosition);
                intent.putExtra(ConstantVariables.IS_PHOTO_COMMENT, isPhotoComment);
                intent.putExtra(ConstantVariables.PHOTO_COMMENT_COUNT, totalComments);
                setResult(ConstantVariables.VIEW_COMMENT_PAGE_CODE, intent);
            }
            super.onBackPressed();
            mAppConst.hideKeyboard();
            overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
        }
    }

    @Override
    public void onClick(View view) {

        int id = view.getId();
        String commentBody = mCommentBox.getText().toString().trim();

        switch (id){
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
                        Toast.makeText(this, getResources().getString(R.string.comment_empty_msg),
                                Toast.LENGTH_SHORT).show();
                    } else {
                        params = new HashMap<>();

                        // Convert text smileys to emoticons in comments
                        commentBody = Smileys.getEmojiFromString(commentBody);

                        mCommentBox.setText("");
                        mCommentBox.setHint(getResources().getString(R.string.write_comment_text) + "…");
                        mAppConst.hideKeyboard();
                        mNoCommentsBlock.setVisibility(View.GONE);

                        postComment(commentBody, null, null);
                    }
                } catch (UnsupportedEncodingException | NullPointerException e) {
                    e.printStackTrace();
                }
                break;
            case R.id.likeCountInfoContainer:

                if(mReactionsEnabled == 1){
                    mViewLikesUrl = UrlUtil.AAF_VIEW_REACTIONS_URL;
                    if(mActionId != 0){
                        mViewLikesUrl += "?action_id=" + mActionId;
                    } else {
                        mViewLikesUrl += "?subject_type=" + mSubjectType +
                                "&subject_id=" + mSubjectId;;
                    }
                } else {
                    //Changing url for the activity_action.
                    if (mSubjectType.equals("activity_action")) {
                        mViewLikesUrl = UrlUtil.AAF_VIEW_LIKES_URL;
                    } else {
                        mViewLikesUrl = UrlUtil.VIEW_LIKES_URL + "&subject_type=" + mSubjectType + "&subject_id=" + mSubjectId;
                    }
                    if(mActionId != 0)
                        mViewLikesUrl += "&action_id=" + mActionId;
                }

                Intent viewAllLikesIntent = new Intent(this, Likes.class);
                viewAllLikesIntent.putExtra("ViewAllLikesUrl", mViewLikesUrl);
                viewAllLikesIntent.putExtra("reactionsEnabled", mReactionsEnabled);
                startActivity(viewAllLikesIntent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

                break;

            case R.id.photoUploadingButton:
                if(!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)){
                    mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            ConstantVariables.WRITE_EXTERNAL_STORAGE);
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
                String url = getLikeCommentUrl();
                if (mSubjectType.equals("activity_action") && mActionId != 0) {
                    url += "&action_id=" + mActionId;
                }
                loadMoreComments(url);
                break;

            default:
                break;
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
        // Selection type photo to display items in grid
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECTION_TYPE, MultiMediaSelectorActivity.SELECTION_PHOTO);
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
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission granted, proceed to the normal flow
                    startImageUploadActivity(mContext, MultiMediaSelectorActivity.MODE_SINGLE, true, 1);
                } else{
                    // If user press deny in the permission popup
                    if (ActivityCompat.shouldShowRequestPermissionRationale((Activity) mContext,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE)) {

                        // Show an expanation to the user After the user
                        // sees the explanation, try again to request the permission.

                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);
                    }else{
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
    public void beforeTextChanged(CharSequence charSequence, int i, int i2, int i3) {

    }

    @Override
    public void onTextChanged(CharSequence charSequence, int i, int i2, int i3) {

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
            public void onTaskCompleted(JSONObject body) {
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
    public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {

    }

    public void loadMoreComments(String commentListUrl){

        mAppConst.getJsonResponseFromUrl(commentListUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mCommentsListView.removeHeaderView(headerView);

                if (jsonObject.length() != 0) {
                    try {
                        mGetTotalComments = jsonObject.getInt("getTotalComments");
                        mCommentList.setmTotalCommmentCount(mGetTotalComments);

                        mGetTotalItemCount = jsonObject.optInt("getTotalItemCount");
                        mCommentList.setmTotalItemCount(mGetTotalItemCount);
                        mAllCommentsArray = jsonObject.optJSONArray("viewAllComments");

                        if(mAllCommentsArray != null && mAllCommentsArray.length() != 0){
                            for (int i = 0; i < mAllCommentsArray.length(); i++){
                                JSONObject commentInfoObject = mAllCommentsArray.getJSONObject(i);
                                int userId = commentInfoObject.optInt("user_id");
                                int commentId = commentInfoObject.getInt("comment_id");
                                String authorPhoto = commentInfoObject.getString("author_image_profile");
                                String authorTitle = commentInfoObject.getString("author_title");
                                String commentDate = commentInfoObject.getString("comment_date");
                                int likeCount = commentInfoObject.getInt("like_count");
                                JSONObject likeJsonObject = commentInfoObject.optJSONObject("like");
                                JSONObject attachmentObject = commentInfoObject.optJSONObject("attachment");
                                String stickerImage = null;
                                JSONObject imageSize = null;
                                if(attachmentObject != null){
                                    stickerImage = attachmentObject.optString("image_profile");
                                    imageSize = attachmentObject.optJSONObject("size");
                                }
                                //for reply option of nested comments
                                JSONObject replyJsonObject = commentInfoObject.optJSONObject("reply");
                                int replyCount = commentInfoObject.optInt("reply_count");

                                JSONArray commentMenus = commentInfoObject.optJSONArray("gutterMenu");
                                JSONArray replyOnCommentArray = commentInfoObject.optJSONArray("reply_on_comment");
                                JSONObject replyCommentJsonObject = null;
                                if (replyOnCommentArray != null && replyOnCommentArray.length() != 0) {
                                    replyCommentJsonObject = replyOnCommentArray.optJSONObject(0);
                                }

                                 /* CODE STARTS FOR  PREPARING Tags and comments body */
                                String commentBody = commentInfoObject.getString("comment_body");
                                JSONArray tagsJsonArray = commentInfoObject.optJSONArray("userTag");

                                if (tagsJsonArray != null && tagsJsonArray.length() != 0) {
                                    commentBody = getCommentsBody(commentBody, tagsJsonArray);
                                }

                                int isLike = 0;
                                if(likeJsonObject != null)
                                    isLike = likeJsonObject.getInt("isLike");

                                mCommentListItems.add(0, new CommentList(userId, commentId, likeCount, isLike, authorPhoto,
                                        authorTitle, commentBody, mClickableParts, commentDate, likeJsonObject,
                                        replyJsonObject, commentMenus, replyCommentJsonObject, stickerImage, imageSize, replyCount));
                            }
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    mCommentAdapter.notifyDataSetChanged();
                    isLoading = false;
                    mSmallProgressBar.setVisibility(View.GONE);
                    mSmallLoadIcon.setVisibility(View.VISIBLE);
                    mLoadMoreCommentText.setText(mContext.getResources().getString(R.string.previous_comment_text));

                    if (ConstantVariables.COMMENT_LIMIT * pageNumber < mCommentList.getmTotalItemCount()) {
                        mCommentsListView.addHeaderView(headerView);
                    }
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                SnackbarUtils.displaySnackbar(findViewById(R.id.comment_activity_view), message);
            }
        });
    }

    private void postComment(final String commentBody, String stickerGuid, String stickerImage) {
        isLoading = true;
        Bitmap bitmap = null;
        if(mStickersEnabled == 1){
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.dark_grey_color),
                    PorterDuff.Mode.SRC_ATOP));
        } else{
            stickerDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                    PorterDuff.Mode.SRC_ATOP));
        }
        mCommentPostButton.setAlpha(0.1f);

        if (mStickersParentView.getVisibility() == View.VISIBLE) {
            mStickersParentView.setVisibility(View.GONE);
            mNoCommentsBlock.setVisibility(View.GONE);
        }

        try {

            LogUtils.LOGD(Comment.class.getSimpleName(), "stickerGuid: "+stickerGuid);
            if(stickerGuid != null){
                params.put("attachment_type", "sticker");
                params.put("attachment_id", stickerGuid);
            } else if(mSelectPath != null && !mSelectPath.isEmpty()){
                params.put("attachment_type", mAttachmentType);
                bitmap = BitmapUtils.decodeSampledBitmapFromFile(Comment.this, mSelectPath.get(0),
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

                mCommentAdapter.notifyDataSetChanged();

            }

            //After adding comment to the list, scroll the list view to last position.
            mCommentsListView.post( new Runnable() {
                @Override
                public void run() {
                    //call smooth scroll
                    mCommentsListView.smoothScrollToPosition(mCommentAdapter.getCount());

                    if (mSubjectType.equals("activity_action")) {
                        mCommentPostUrl = AppConstant.DEFAULT_URL + "advancedactivity/comment";
                        mCommentNotificationUrl = AppConstant.DEFAULT_URL + "advancedactivity/add-comment-notifications";
                        params.put(ConstantVariables.ACTION_ID, String.valueOf(mActionId));
                    } else if(isNestedCommentEnabled){
                        mCommentPostUrl = AppConstant.DEFAULT_URL + "advancedcomments/comment";
                        mCommentNotificationUrl = AppConstant.DEFAULT_URL + "add-comment-notifications";
                        params.put(ConstantVariables.SUBJECT_TYPE, mSubjectType);
                        params.put(ConstantVariables.SUBJECT_ID, String.valueOf(mSubjectId));
                    } else {
                        mCommentPostUrl = AppConstant.DEFAULT_URL + "comment-create";
                        mCommentNotificationUrl = AppConstant.DEFAULT_URL + "add-comment-notifications";
                        params.put(ConstantVariables.SUBJECT_TYPE, mSubjectType);
                        params.put(ConstantVariables.SUBJECT_ID, String.valueOf(mSubjectId));
                    }
                    if(commentBody != null){
                        params.put("body", commentBody);
                    }
                    params.put("send_notification", "0");

                    if (tagObject != null && tagObject.length() > 0) {
                        params.put("composer", tagObject.toString());
                    }

                    // Playing postSound effect when comment is posted.
                    if (PreferencesUtils.isSoundEffectEnabled(Comment.this)) {
                        SoundUtil.playSoundEffectOnPost(Comment.this);
                    }

                    ArrayList<String> selectPath = new ArrayList<>();
                    if(mSelectPath != null && mSelectPath.size() != 0){
                        for (int i = 0; i<mSelectPath.size(); i++) {
                            selectPath.add(i, mSelectPath.get(i));
                        }
                        mSelectedImageBlock.setVisibility(View.GONE);

                        new UploadFileToServerUtils(mContext, mCommentPostUrl, selectPath,
                                mPostCommentList, params).execute();

                        mSelectPath.clear();

                    } else{
                        mAppConst.postJsonResponseForUrl(mCommentPostUrl, params, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) {
                                if (!isFinishing()) {
                                    addCommentToList(jsonObject, true);
                                }

                            }
                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                isLoading = false;
                                SnackbarUtils.displaySnackbar(findViewById(R.id.comment_activity_view), message);
                            }
                        });
                    }
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onCommentPost(JSONObject response, boolean isRequestSuccessful, CommentList commentList) {
        try {
            if (isRequestSuccessful) {
                mCommentListItems.remove(commentList);
                mCommentAdapter.notifyDataSetChanged();
                JSONObject bodyObject = response.optJSONObject("body");
                addCommentToList(bodyObject, false);
            } else {
                isLoading = false;
                if (mCommentListItems.size() > 0) {
                    mCommentListItems.remove(mCommentListItems.size() - 1);
                    mCommentAdapter.notifyDataSetChanged();
                }
                SnackbarUtils.displaySnackbar(findViewById(R.id.comment_activity_view), response.optString("message"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        switch (requestCode){
            case ConstantVariables.STICKER_STORE_REQUEST:
                if(resultCode == ConstantVariables.STICKER_STORE_REQUEST){
                    JSONObject jsonObject = ConstantVariables.STICKERS_STORE_ARRAY;
                    JSONArray collectionIds = jsonObject.names();
                    for(int i = 0; i < jsonObject.length(); i++) {
                        JSONObject stickerStoreObject = jsonObject.optJSONObject(collectionIds.optString(i));
                        String stickerAction = stickerStoreObject.optString("action");
                        int collectionId = stickerStoreObject.optInt("collection_id");

                        if (stickerAction.equals("add")) {
                            StickersGridView stickersGridView = new StickersGridView(mContext, collectionId, mStickersPopup);
                            mStickersPopup.viewsList.add(stickersGridView);
                            mStickersPopup.stickerGridViewList.put(collectionId, stickersGridView);
                            ((PagerAdapter) mStickersPopup.myAdapter).notifyDataSetChanged();
                            mStickersPopup.mCollectionsList.put(stickerStoreObject);
                            mStickersPopup.setupTabIcons();
                        } else {
                            mStickersPopup.viewsList.remove(mStickersPopup.stickerGridViewList.get(collectionId));
                            mStickersPopup.stickerGridViewList.remove(collectionId);
                            ((PagerAdapter) mStickersPopup.myAdapter).notifyDataSetChanged();
                            for(int j = 0; j < mStickersPopup.mCollectionsList.length(); j++){
                                JSONObject collectionObject = mStickersPopup.mCollectionsList.optJSONObject(j);
                                int collection_id = collectionObject.optInt("collection_id");

                                if(collection_id == collectionId){
                                    mStickersPopup.mCollectionsList.remove(j);
                                    break;
                                }
                            }
                            mStickersPopup.setupTabIcons();
                        }
                    }
                    ConstantVariables.STICKERS_STORE_ARRAY = new JSONObject();
                }
                break;
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
                        int postReplyCount = data.getIntExtra("commentReplyCount", 0);
                        itemPosition = data.getIntExtra(ConstantVariables.ITEM_POSITION, 0);

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
                    int itemEditPosition = data.getIntExtra(ConstantVariables.ITEM_POSITION, 0);

                    if (itemEditObject != null && !itemEditObject.isEmpty()) {
                        try {
                            JSONObject editedObject = new JSONObject(itemEditObject);
                            String mCommentBody = editedObject.optString("comment_body");

                            CommentList selectedCommentRow = mCommentListItems.get(itemEditPosition);
                            selectedCommentRow.setmCommentBody(mCommentBody);

                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                    mCommentAdapter.notifyDataSetChanged();
                }
        }
    }

    private void addCommentToList(JSONObject jsonObject, boolean isTextComment){

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
            JSONObject replyJsonObject = jsonObject.optJSONObject("reply");
            JSONArray commentMenus = jsonObject.optJSONArray("gutterMenu");
            JSONArray replyOnCommentArray = jsonObject.optJSONArray("reply_on_comment");
            JSONObject replyCommentJsonObject = null;
            if (replyOnCommentArray != null && replyOnCommentArray.length() != 0) {
                replyCommentJsonObject = replyOnCommentArray.optJSONObject(0);
            }
            int replyCount = jsonObject.optInt("reply_count");

            if(attachmentObject != null){
                stickerImage = attachmentObject.optString("image_profile");
                imageSize = attachmentObject.optJSONObject("size");
            }
            int isLike = 0;
            if (likeJsonObject != null)
                isLike = likeJsonObject.optInt("isLike");
            /*
                Remove the instantly added comment from the adapter after comment posted
                successfully and add a comment in adapter with full details.
            */

              /* CODE STARTS FOR  PREPARING Tags and comments body */
            String commentBody = jsonObject.getString("comment_body");
            JSONArray tagsJsonArray = jsonObject.optJSONArray("userTag");

            if (tagsJsonArray != null && tagsJsonArray.length() != 0) {
                commentBody = getCommentsBody(commentBody, tagsJsonArray);
            }

            if (isTextComment) {
                mCommentListItems.remove(mCommentListItems.size() - 1);
            }
            mCommentListItems.add( new CommentList(userId, commentId, likeCount, isLike, authorPhoto, authorTitle,
                    commentBody, mClickableParts, commentDate, likeJsonObject, replyJsonObject,
                    commentMenus, replyCommentJsonObject, stickerImage, imageSize, replyCount));

            mCommentList.setmTotalCommmentCount(mCommentList.getmTotalCommmentCount() + 1);
            mNoCommentsBlock.setVisibility(View.GONE);

        } catch (JSONException e) {
            e.printStackTrace();
        }
        mCommentAdapter.notifyDataSetChanged();

        //After adding comment to the list, scroll the list view to last position.
        final int finalCommentId = commentId;
        mCommentsListView.post(new Runnable() {
            @Override
            public void run() {

                params.put("comment_id", String.valueOf(finalCommentId));
                params.remove("body");
                params.remove("send_notification");

                mAppConst.postJsonRequest(mCommentNotificationUrl, params);

                isLoading = false;
                mPhotoUploadingButton.setClickable(true);
                mPhotoUploadingButton.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark));
            }
        });
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
            Bitmap bitmap = BitmapUtils.decodeSampledBitmapFromFile(Comment.this, imagePath,
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

    private String getLikeCommentUrl(){
        String url;

        //Changing url for the activity_action.
        if (mSubjectType.equals("activity_action")) {
            url = UrlUtil.AAF_LIKE_COMMNET_URL + "&page=" + pageNumber + "&order=desc";
            mCommentList.setmCommentModule(ConstantVariables.AAF_COMMENT);

        } else if(isNestedCommentEnabled){
            url = UrlUtil.NESTED_COMMENTS_VIEW_URL + "&subject_type=" + mSubjectType + "&subject_id=" +
                    mSubjectId + "&page=" + pageNumber + "&order=desc";
            mCommentList.setmCommentModule(ConstantVariables.CONTENT_COMMENT);

        } else{
            url = UrlUtil.LIKE_COMMENT_URL + "&subject_type=" + mSubjectType + "&subject_id=" +
                    mSubjectId + "&page=" + pageNumber;
        }
        return url;
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view, int position, long l) {

        mUserView.setVisibility(View.GONE);

        AddPeopleList addPeopleList = mAddPeopleList.get(position);
        String label = addPeopleList.getmUserLabel();
        int userId = addPeopleList.getmUserId();

        String string = "user_" + userId + "=" + label;

        if (tagString != null && tagString.length() > 0) {
            tagString =  tagString + "&" + string;
        } else {
            tagString = string;
        }

        tagObject = new JSONObject();
        try {
            tagObject.put("tag", tagString);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        if(mAddPeopleAdapter != null){
            mAddPeopleAdapter.clear();
        }
        mCommentBox.setText(mCommentBox.getText().toString().replace("@" + searchText, label));
        mCommentBox.setSelection(mCommentBox.getText().length());
    }

    @Override
    public void onCommentDelete() {
        if (mCommentList.getmTotalCommmentCount() == 0) {
            mNoCommentsBlock.setVisibility(View.VISIBLE);
        } else {
            mNoCommentsBlock.setVisibility(View.GONE);
        }
    }
}
