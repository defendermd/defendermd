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

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;

import android.os.Build;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.AppCompatTextView;
import android.support.v7.widget.PopupMenu;
import android.text.Html;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;


import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommentDeleteListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnMenuClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.Smileys;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;


import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoLightBoxActivity;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Text;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedSet;
import java.util.TreeSet;

import github.ankushsachdeva.emojicon.EmojiconTextView;


public class CommentAdapter extends ArrayAdapter<CommentList> implements OnMenuClickResponseListener {

    private Context mContext;
    private List<CommentList> mCommentListItems;
    private CommentList mCommentList, mListComment;
    private int mLayoutResID, mPosition, itemPosition, mSubjectId, mActionId, mLikeCountPosition;
    private View mRootView;
    private JSONObject mLikeOptionArray, mDeleteOptionArray;
    private String mLikeCommentUrl, mDeleteCommentUrl, mSubjectType;
    private AppConstant mAppConst;
    private boolean isCommentPage;
    private boolean likeUnlikeAction = true, isLiveStreaming = false, isLiveStreamSubscriber = false;
    private GutterMenuUtils mGutterMenuUtils;
    private AlertDialogWithAction mAlertDialogWithAction;
    private ImageLoader mImageLoader;
    private boolean mIsNestedReplies = false;
    private int deleteReplyCount = 0;
    private ArrayList<PhotoListDetails> mPhotoDetails;
    int leftPadding, width, height, margin;
    private static int parentItemPosition;
    private OnCommentDeleteListener mOnCommentDeleteListener;

    public CommentAdapter(Context context, int resource, List<CommentList> listItems,
                          CommentList commentList, boolean commentPage, String subject_type,
                          int subject_id, int action_id, boolean isNestedReplies) {

        super(context, resource, listItems);
        mContext = context;
        mCommentListItems = listItems;
        mListComment = commentList;
        mLayoutResID = resource;
        isCommentPage = commentPage;

        mSubjectType = subject_type;
        mSubjectId = subject_id;
        mActionId = action_id;

        mAppConst = new AppConstant(context);
        mGutterMenuUtils = new GutterMenuUtils(context);
        mAlertDialogWithAction = new AlertDialogWithAction(context);
        mImageLoader = new ImageLoader(mContext);
        mPhotoDetails = new ArrayList<>();
        mOnCommentDeleteListener = (OnCommentDeleteListener) mContext;

        mIsNestedReplies = isNestedReplies;
        leftPadding = (int) mContext.getResources().getDimension(R.dimen.nested_listItem_left_padding);
        width = (int) mContext.getResources().getDimension(R.dimen.nested_listItem_imageView_width);
        height = (int) mContext.getResources().getDimension(R.dimen.nested_listItem_imageView_height);
        margin = (int) mContext.getResources().getDimension(R.dimen.margin_8dp);
    }

    public CommentAdapter(Context context, int resource, List<CommentList> listItems, CommentList commentList,
                          boolean commentPage) {

        super(context, resource, listItems);
        mContext = context;
        mCommentListItems = listItems;
        mListComment = commentList;
        mLayoutResID = resource;
        isCommentPage = commentPage;

        mAppConst = new AppConstant(context);
        mGutterMenuUtils = new GutterMenuUtils(context);
        mAlertDialogWithAction = new AlertDialogWithAction(context);
        mImageLoader = new ImageLoader(mContext);
    }

    public CommentAdapter(Context context, int resource, List<CommentList> listItems,
                          CommentList commentList, boolean commentPage, String subject_type,
                          int subject_id) {

        super(context, resource, listItems);
        mContext = context;
        mCommentListItems = listItems;
        mListComment = commentList;
        mLayoutResID = resource;
        isCommentPage = commentPage;
        mSubjectType = subject_type;
        mSubjectId = subject_id;
        mAppConst = new AppConstant(context);
        mGutterMenuUtils = new GutterMenuUtils(context);
        mAlertDialogWithAction = new AlertDialogWithAction(context);
        mImageLoader = new ImageLoader(mContext);
        mPhotoDetails = new ArrayList<>();
        mIsNestedReplies = false;
        leftPadding = (int) mContext.getResources().getDimension(R.dimen.nested_listItem_left_padding);
        width = (int) mContext.getResources().getDimension(R.dimen.nested_listItem_imageView_width);
        height = (int) mContext.getResources().getDimension(R.dimen.nested_listItem_imageView_height);
        margin = (int) mContext.getResources().getDimension(R.dimen.margin_8dp);
    }

    public void setLiveStreaming(boolean liveStreaming) {
        isLiveStreaming = liveStreaming;
    }

    public void setLiveStreamSubscriber(boolean liveStreamSubscriber) {
        isLiveStreamSubscriber = liveStreamSubscriber;
    }

    public View getView(int position, View convertView, ViewGroup parent){

        mRootView = convertView;
        mCommentList = mCommentListItems.get(position);
        final ListItemHolder listItemHolder;
        if(mRootView == null){

            LayoutInflater inflater = (LayoutInflater)mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            listItemHolder = new ListItemHolder();
            mRootView = inflater.inflate(mLayoutResID, parent, false);

            listItemHolder.mAuthorImage = (ImageView) mRootView.findViewById(R.id.authorImage);
            listItemHolder.mAuthorTitle = (TextView) mRootView.findViewById(R.id.authorTitle);
            listItemHolder.mCommentBody = (EmojiconTextView) mRootView.findViewById(R.id.commentBody);
            listItemHolder.mCommentDate = (TextView) mRootView.findViewById(R.id.commentDate);
            listItemHolder.mPostingText = (TextView) mRootView.findViewById(R.id.postingText);
            listItemHolder.mStickerImage = (ImageView) mRootView.findViewById(R.id.stickerImage);
            listItemHolder.mGifIV = (ImageView) mRootView.findViewById(R.id.gif_icon);
            listItemHolder.mAttchmentView = (RelativeLayout) mRootView.findViewById(R.id.attachment_imageview);
            listItemHolder.mAttchmentView.setTag(position);

            listItemHolder.mCommentOptionsBlock = (LinearLayout) mRootView.findViewById(R.id.commentOptionsBlock);
            listItemHolder.mCommentLikeCount = (TextView) mRootView.findViewById(R.id.commentLikeCount);
            listItemHolder.mCommentLikeCount.setTag(position);

            listItemHolder.mMemberOptions = (TextView) mRootView.findViewById(R.id.memberOption);
            listItemHolder.mMemberOptions.setTag(position);
            listItemHolder.mMemberOptions.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            listItemHolder.mLikeOption = (TextView) mRootView.findViewById(R.id.likeOption);
            listItemHolder.mLikeOption.setTag(position);

            listItemHolder.mReplyOption = (TextView) mRootView.findViewById(R.id.replyOption);
            listItemHolder.mReplyOption.setTag(position);

            listItemHolder.mPreviousReplies = (TextView) mRootView.findViewById(R.id.previousReplies);
            listItemHolder.mPreviousReplies.setTag(position);

            listItemHolder.mDeleteOption = (TextView) mRootView.findViewById(R.id.deleteOption);
            listItemHolder.mDeleteOption.setTag(position);

            listItemHolder.mReactionImage = (ImageView) mRootView.findViewById(R.id.reactionIcon);

            if (isLiveStreaming) {
                listItemHolder.mAuthorTitle.setTextColor(ContextCompat.getColor(mContext, R.color.white));
                listItemHolder.mCommentBody.setTextColor(ContextCompat.getColor(mContext, R.color.white));
            }
            listItemHolder.mReplyAuthorImage = (ImageView) mRootView.findViewById(R.id.reply_authorImage);
            listItemHolder.mReplyAuthorTitle = (TextView) mRootView.findViewById(R.id.reply_authorTitle);
            listItemHolder.mReplyCommentBody = (EmojiconTextView) mRootView.findViewById(R.id.reply_commentBody);

            listItemHolder.mCommentReplyBlock = (LinearLayout) mRootView.findViewById(R.id.commentReplyBlock);
            listItemHolder.mCommentReplyBlock.setTag(position);

            listItemHolder.mCommentInfoBlock = (LinearLayout) mRootView.findViewById(R.id.commentInfoBlock);
            listItemHolder.mCommentInfoBlock.setTag(position);

            mRootView.setTag(listItemHolder);
            listItemHolder.mCommentBody.setTag(position);
        } else {
            listItemHolder = (ListItemHolder)mRootView.getTag();
            listItemHolder.mLikeOption.setTag(position);
            listItemHolder.mReplyOption.setTag(position);
            listItemHolder.mPreviousReplies.setTag(position);
            listItemHolder.mCommentReplyBlock.setTag(position);
            listItemHolder.mCommentInfoBlock.setTag(position);
            listItemHolder.mAttchmentView.setTag(position);
            listItemHolder.mMemberOptions.setTag(position);
            listItemHolder.mCommentLikeCount.setTag(position);
            if (listItemHolder.mDeleteOption != null) {
                listItemHolder.mDeleteOption.setTag(position);
            }
            if (listItemHolder.mCommentBody != null) {
                listItemHolder.mCommentBody.setTag(position);
                listItemHolder.mCommentBody.setVisibility(View.GONE);
            }
        }

        listItemHolder.mLikeOption.setClickable(true);
        listItemHolder.mLikeOption.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark_color));

        listItemHolder.mReplyOption.setClickable(true);
        listItemHolder.mReplyOption.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark_color));

        listItemHolder.mPreviousReplies.setClickable(true);
        listItemHolder.mPreviousReplies.setTextColor(ContextCompat.getColor(mContext, R.color.black));

        listItemHolder.mCommentLikeCount.setClickable(true);
        listItemHolder.mCommentLikeCount.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark_color));

        listItemHolder.mDeleteOption.setClickable(true);
        listItemHolder.mDeleteOption.setTextColor(ContextCompat.getColor(mContext, R.color.grey_dark_color));

        listItemHolder.mCommentReplyBlock.setClickable(true);
        listItemHolder.mCommentInfoBlock.setLongClickable(true);
        listItemHolder.mAttchmentView.setLongClickable(true);

        /* Set left padding of list Items for labeling in nested replies page */
        if (mIsNestedReplies) {

            mRootView.setPadding(leftPadding, 0, 0, 0);
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(width, height);
            params.setMargins(0, margin, margin, 0);
            listItemHolder.mAuthorImage.setLayoutParams(params);
            listItemHolder.mAuthorImage.setScaleType(ImageView.ScaleType.CENTER_CROP);
        }

        /*
        Set Data in the List View Items
         */

        final int userId = mCommentList.getmUserId();

        mImageLoader.setImageForUserProfile(mCommentList.getmAuthorPhoto(), listItemHolder.mAuthorImage);

        listItemHolder.mAuthorTitle.setText(mCommentList.getmAuthorTitle());

        if(isCommentPage){

            listItemHolder.mMemberOptions.setVisibility(View.GONE);
            listItemHolder.mAuthorImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {

                    // Clickable only when its normal condition (!isLiveStreaming) or in case of live broadcast comment its the audience page.
                    if (!isLiveStreaming || isLiveStreamSubscriber) {
                        Intent userProfileIntent = new Intent(mContext, userProfile.class);
                        userProfileIntent.putExtra("user_id", userId);
                        ((Activity) mContext).startActivityForResult(userProfileIntent, ConstantVariables.
                                USER_PROFILE_CODE);
                        ((Activity)mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                }
            });

            listItemHolder.mAuthorTitle.setClickable(true);
            listItemHolder.mAuthorTitle.setMovementMethod(LinkMovementMethod.getInstance());
            listItemHolder.mAuthorTitle.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {

                    // Clickable only when its normal condition (!isLiveStreaming) or in case of live broadcast comment its the audience page.
                    if (!isLiveStreaming || isLiveStreamSubscriber) {

                        Intent userProfileIntent = new Intent(mContext, userProfile.class);
                        userProfileIntent.putExtra("user_id", userId);
                        ((Activity) mContext).startActivityForResult(userProfileIntent, ConstantVariables.
                                USER_PROFILE_CODE);
                        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                }
            });
        } else {
            int marginTop = (int) (mContext.getResources().getDimension(R.dimen.margin_40dp) /
                    mContext.getResources().getDisplayMetrics().density);

            LinearLayout.LayoutParams layoutParams = CustomViews.getFullWidthLayoutParams();
            layoutParams.setMargins(0, marginTop, 0, 0);
            listItemHolder.mAuthorTitle.setLayoutParams(layoutParams);
            listItemHolder.mCommentInfoBlock.setLongClickable(false);

            if(mCommentList.getmReactionIcon() != null && !mCommentList.getmReactionIcon().isEmpty()){
                mImageLoader.setImageUrl(mCommentList.getmReactionIcon(), listItemHolder.mReactionImage);
                listItemHolder.mReactionImage.setVisibility(View.VISIBLE);

            } else{
                listItemHolder.mReactionImage.setVisibility(View.GONE);
            }

        }


        listItemHolder.mCommentLikeCount.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        if(isCommentPage) {
            listItemHolder.mMemberOptions.setVisibility(View.GONE);

            if(mCommentList.getmCommentBody() != null && !mCommentList.getmCommentBody().isEmpty()){
                listItemHolder.mCommentBody.setVisibility(View.VISIBLE);
                listItemHolder.mCommentBody.setMovementMethod(LinkMovementMethod.getInstance());
                listItemHolder.mCommentBody.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        int position = (int) v.getTag();
                        CommentList commentList = mCommentListItems.get(position);
                        if (commentList.getmCommentBody().trim().length()
                                > ConstantVariables.FEED_TITLE_BODY_LENGTH) {
                            commentList.showFullComment(!commentList.isFullCommentShowing());
                            notifyDataSetChanged();
                        }
                    }
                });

                HashMap<String, String> clickableParts = mCommentList.getmClickableStringsList();
                String commentBody;
                if (mCommentList.getmCommentBody().trim().length()
                        > ConstantVariables.FEED_TITLE_BODY_LENGTH) {
                    if (mCommentList.isFullCommentShowing()) {
                        commentBody = mCommentList.getmCommentBody().substring(0,
                                ConstantVariables.FEED_TITLE_BODY_LENGTH).concat("..."
                                + mContext.getResources().getString(R.string.more));
                    } else {
                        commentBody = mCommentList.getmCommentBody().concat("..."
                                + mContext.getResources().getString(R.string.readLess));
                    }
                } else {
                    commentBody = mCommentList.getmCommentBody();
                }

                // Show Clickable Parts and Apply Click Listener to redirect
                if (clickableParts != null && clickableParts.size() != 0) {
                    CharSequence title = Smileys.getEmojiFromString(Html.fromHtml(commentBody.replaceAll("\n", "<br/>")).toString());
                    SpannableString text = new SpannableString(title);
                    SortedSet<String> keys = new TreeSet<>(clickableParts.keySet());

                    int lastIndex = 0;
                    for (String key : keys) {

                        String[] keyParts = key.split("-");
                        final int attachment_id = Integer.parseInt(keyParts[2]);
                        final String value = clickableParts.get(key);

                        if (value != null && !value.isEmpty()) {
                            int i1 = title.toString().indexOf(value, lastIndex);
                            if (i1 != -1) {
                                int i2 = i1 + value.length();
                                if (lastIndex != -1) {
                                    lastIndex += value.length();
                                }
                                ClickableSpan myClickableSpan = new ClickableSpan() {
                                    @Override
                                    public void onClick(View widget) {
                                        redirectToActivity(attachment_id);
                                    }

                                    @Override
                                    public void updateDrawState(TextPaint ds) {
                                        super.updateDrawState(ds);
                                        ds.setUnderlineText(false);
                                        ds.setColor(ContextCompat.getColor(mContext, R.color.black));
                                        ds.setFakeBoldText(true);
                                    }
                                };
                                text.setSpan(myClickableSpan, i1, i2, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                            }
                        }
                    }
                    seeMoreOption(listItemHolder.mCommentBody, title, text, mCommentList);
                } else {
                    CharSequence title = Smileys.getEmojiFromString(Html.fromHtml(commentBody.replaceAll("\n", "<br/>")).toString());
                    SpannableString text = new SpannableString(title);
                    seeMoreOption(listItemHolder.mCommentBody, title, text, mCommentList);
                }

            } else{
                listItemHolder.mCommentBody.setVisibility(View.GONE);
            }

            listItemHolder.imageUrl = mCommentList.getmStickerImage();

            if(mCommentList.getmImageBitmap() != null){
                listItemHolder.mAttchmentView.setVisibility(View.VISIBLE);
                int height = (int) mContext.getResources().getDimension(R.dimen.height_150dp);
                int width = mAppConst.getScreenWidth();
                LinearLayout.LayoutParams singleImageParam = CustomViews.getCustomWidthHeightLayoutParams(width, height);
                listItemHolder.mAttchmentView.setLayoutParams(singleImageParam);
                listItemHolder.mGifIV.setVisibility(View.GONE);
                listItemHolder.mStickerImage.setImageBitmap(mCommentList.getmImageBitmap());

            } else if(listItemHolder.imageUrl != null && !listItemHolder.imageUrl.isEmpty()){
                LinearLayout.LayoutParams singleImageParam = getSingleImageParamFromWidthHeight(mCommentList.getmImageSize(), listItemHolder.imageUrl, listItemHolder.mGifIV, listItemHolder.mStickerImage);
                listItemHolder.mAttchmentView.setLayoutParams(singleImageParam);

                listItemHolder.mAttchmentView.setVisibility(View.VISIBLE);

                if (listItemHolder.imageUrl.contains(".gif")) {
                    listItemHolder.mGifIV.setVisibility(View.VISIBLE);
                } else {
                    listItemHolder.mGifIV.setVisibility(View.GONE);
                }

                mImageLoader.setStickerImage(listItemHolder.imageUrl, listItemHolder.mStickerImage, mCommentList.getmImageSize());

                listItemHolder.mGifIV.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listItemHolder.mGifIV.setVisibility(View.GONE);
                        mImageLoader.setAnimationImage(listItemHolder.imageUrl, listItemHolder.mStickerImage);
                    }
                });

                listItemHolder.mAttchmentView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mPhotoDetails.clear();
                        mPhotoDetails.add(new PhotoListDetails(listItemHolder.imageUrl));
                        openLightBox();
                    }
                });

            } else{
                listItemHolder.mAttchmentView.setVisibility(View.GONE);
            }


            if(mCommentList.isShowPosting()){
                listItemHolder.mPostingText.setVisibility(View.VISIBLE);
                listItemHolder.mPostingText.setText(mContext.getResources().getString(R.string.comment_posting)
                        + "...");
                listItemHolder.mCommentOptionsBlock.setVisibility(View.GONE);
                listItemHolder.mPreviousReplies.setVisibility(View.GONE);
                listItemHolder.mCommentReplyBlock.setVisibility(View.GONE);

            }else{
                listItemHolder.mPostingText.setVisibility(View.GONE);
                listItemHolder.mCommentOptionsBlock.setVisibility(View.VISIBLE);
                if (mCommentList.getmCommentDate() != null) {
                    listItemHolder.mCommentDate.setVisibility(View.VISIBLE);
                    String convertedDate = AppConstant.convertDateFormat(mContext.getResources(),
                            mCommentList.getmCommentDate());
                    listItemHolder.mCommentDate.setText(convertedDate);
                } else {
                    listItemHolder.mCommentDate.setVisibility(View.GONE);
                }

                if(mCommentList.getmLikeCount() > 0) {
                    listItemHolder.mCommentLikeCount.setText(String.format("\uF087 %d", mCommentList.getmLikeCount()));
                    listItemHolder.mCommentLikeCount.setVisibility(View.VISIBLE);
                }else{
                    listItemHolder.mCommentLikeCount.setVisibility(View.GONE);
                }

                listItemHolder.mLikeJsonObject = mCommentList.getmLikeJsonObject();
                if (listItemHolder.mLikeJsonObject != null) {
                    listItemHolder.mLikeOption.setVisibility(View.VISIBLE);
                    if (mCommentList.getmIsLike() == 0) {
                        listItemHolder.mLikeOption.setText(mContext.getString(R.string.like_text));
                    } else {
                        listItemHolder.mLikeOption.setText(mContext.getString(R.string.unlike));
                    }
                }else{
                    listItemHolder.mLikeOption.setVisibility(View.GONE);
                }

                listItemHolder.mReplyJsonObject = mCommentList.getmReplyJsonObject();
                if (listItemHolder.mReplyJsonObject != null){
                    listItemHolder.mReplyOption.setVisibility(View.VISIBLE);
                    listItemHolder.mReplyOption.setText(mContext.getString(R.string.reply_text));
                } else {
                    listItemHolder.mReplyOption.setVisibility(View.GONE);
                }

                listItemHolder.mLastCommentReplyObject = mCommentList.getmLastCommentReplyObject();
                if (listItemHolder.mLastCommentReplyObject != null) {
                    try {
                        String reply_authorPhoto = listItemHolder.mLastCommentReplyObject.optString("author_image_profile");
                        String reply_authorTitle = listItemHolder.mLastCommentReplyObject.optString("author_title");
                        String reply_commentBody = listItemHolder.mLastCommentReplyObject.getString("comment_body");

                        // set the data in nested reply list item
                        listItemHolder.mReplyAuthorTitle.setText(reply_authorTitle);
                        mImageLoader.setImageForUserProfile(reply_authorPhoto, listItemHolder.mReplyAuthorImage);

                        if (reply_commentBody != null && !reply_commentBody.isEmpty()){
                            listItemHolder.mReplyCommentBody.setText(reply_commentBody);
                        } else {
                            listItemHolder.mReplyCommentBody.setText(mContext.getResources().getString(R.string.reply_body_text));
                        }
                        listItemHolder.mCommentReplyBlock.setVisibility(View.VISIBLE);

                        if (mCommentList.getmTotalReplyCount() > 1) {
                            String previousText;
                            if (mCommentList.getmTotalReplyCount() == 2)
                                previousText = mContext.getResources().getString(R.string.previous_reply);
                            else
                                previousText = mContext.getResources().getString(R.string.previous_replies);
                            listItemHolder.mPreviousReplies.setText(mContext.getResources().getString(R.string.more_replies_view_text) + " " +
                                    (mCommentList.getmTotalReplyCount() - 1) + " " + previousText);
                            listItemHolder.mPreviousReplies.setVisibility(View.VISIBLE);

                        } else {
                            listItemHolder.mPreviousReplies.setVisibility(View.GONE);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                } else {
                    listItemHolder.mCommentReplyBlock.setVisibility(View.GONE);
                    listItemHolder.mPreviousReplies.setVisibility(View.GONE);
                }
            }

            listItemHolder.mLikeOption.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {

                    itemPosition = (int) view.getTag();
                    CommentList commentList = mCommentListItems.get(itemPosition);
                    int isLike = commentList.getmIsLike();

                    if (likeUnlikeAction) {
                        if (isLike == 0) {
                            listItemHolder.mLikeOption.setText(mContext.getString(R.string.unlike));
                            listItemHolder.mCommentLikeCount.setVisibility(View.VISIBLE);
                            listItemHolder.mCommentLikeCount.setText(
                                    String.format("\uF087 %d", commentList.getmLikeCount() + 1));

                        } else {
                            listItemHolder.mLikeOption.setText(mContext.getString(R.string.like_text));
                            listItemHolder.mCommentLikeCount.setText(
                                    String.format("\uF087 %d", commentList.getmLikeCount() - 1));
                            if(commentList.getmLikeCount() == 1){
                                listItemHolder.mCommentLikeCount.setVisibility(View.GONE);
                            }
                        }
                        doLikeUnlike();
                        likeUnlikeAction = false;
                    }
                }
            });

            listItemHolder.mReplyOption.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    redirectToNestedReplies(view, true, true);
                }
            });

            listItemHolder.mDeleteOption.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mPosition = (int) view.getTag();
                    deleteComment(mPosition);
                }
            });

            listItemHolder.mPreviousReplies.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    redirectToNestedReplies(view, false, false);
                }
            });

            listItemHolder.mCommentReplyBlock.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    redirectToNestedReplies(view, false, true);
                }
            });

            listItemHolder.mCommentLikeCount.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mLikeCountPosition = (int) view.getTag();
                    viewCommentLikes();
                }
            });

            mGutterMenuUtils.setOnMenuClickResponseListener(this);
            listItemHolder.mCommentInfoBlock.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(final View view) {
                    showCommentOption(view, listItemHolder);
                    return false;
                }
            });

            listItemHolder.mAttchmentView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    showCommentOption(view, listItemHolder);
                    return false;
                }
            });

            listItemHolder.mCommentBody.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    showCommentOption(view, listItemHolder);
                    return false;
                }
            });

        } else {
            listItemHolder.mCommentBody.setVisibility(View.GONE);
            listItemHolder.mPostingText.setVisibility(View.GONE);
            listItemHolder.mCommentOptionsBlock.setVisibility(View.GONE);

            // Showing friendship options if condition matches.
            if (mCommentList.getmFriendshipType() != null && !mCommentList.getmFriendshipType().isEmpty() &&
                    mCommentList.getmUserId() != 0) {
                listItemHolder.mMemberOptions.setVisibility(View.VISIBLE);
                switch (mCommentList.getmFriendshipType()) {
                    case "add_friend":
                    case "accept_request":
                    case "member_follow":
                        listItemHolder.mMemberOptions.setText("\uf234");
                        break;
                    case "remove_friend":
                    case "member_unfollow":
                        listItemHolder.mMemberOptions.setText("\uf235");
                        break;
                    case "cancel_request":
                    case "cancel_follow":
                        listItemHolder.mMemberOptions.setText("\uf00d");
                        break;
                }
                mGutterMenuUtils.setOnMenuClickResponseListener(this);
                listItemHolder.mMemberOptions.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        int position = (int) view.getTag();
                        CommentList commentList = mCommentListItems.get(position);
                        mGutterMenuUtils.setPopUpForFriendShipType(position, null, commentList, null);
                    }
                });
            } else {
                listItemHolder.mMemberOptions.setVisibility(View.GONE);
            }
        }

        LinearLayout.LayoutParams layoutParams = CustomViews.getFullWidthLayoutParams();
        layoutParams.setMargins(mContext.getResources().getDimensionPixelSize(R.dimen.margin_2dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.margin_1dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.offset_distance));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            layoutParams.setMarginStart(mContext.getResources().getDimensionPixelSize(R.dimen.margin_2dp));
            layoutParams.setMarginEnd(mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp));
        }
        listItemHolder.mCommentBody.setLayoutParams(layoutParams);
        if (isLiveStreaming) {
            listItemHolder.mMemberOptions.setVisibility(View.GONE);
            listItemHolder.mCommentOptionsBlock.setVisibility(View.GONE);
            listItemHolder.mDeleteOption.setVisibility(View.GONE);
            listItemHolder.mCommentLikeCount.setVisibility(View.GONE);
            listItemHolder.mLikeOption.setVisibility(View.GONE);
            listItemHolder.mCommentDate.setVisibility(View.GONE);
        }

        mRootView.setId(mCommentList.getmCommentId());
        return mRootView;
    }

    private void showCommentOption(View view, ListItemHolder listItemHolder) {
        itemPosition = (int) view.getTag();
        CommentList commentList = mCommentListItems.get(itemPosition);
        JSONArray commentMenu = commentList.getmCommentMenusArray();

        if (commentMenu != null && commentMenu.length() > 0) {
            if (commentMenu.length() == 1) {
                if (!commentMenu.optJSONObject(0).optString("name").equals("comment_cancel")) {
                    mGutterMenuUtils.showPopup(listItemHolder.mCommentOptionsBlock, commentList.getmCommentMenusArray(),
                            itemPosition, null, "commentOptionMenu", null, null, 0, true);
                    }
                } else {
                    mGutterMenuUtils.showPopup(listItemHolder.mCommentOptionsBlock, commentList.getmCommentMenusArray(),
                            itemPosition, null, "commentOptionMenu", null, null, 0, true);
            }
        }
    }

    private LinearLayout.LayoutParams getSingleImageParamFromWidthHeight(JSONObject size, String url, ImageView gifView, ImageView stickerView) {

        float height = mContext.getResources().getDimension(R.dimen.height_160dp);
        int width = (int) height;
        LinearLayout.LayoutParams singleImageParam;
        if (size != null && size.optInt("width") != 0 && size.optInt("height") != 0) {
            float ratio = ((float)size.optInt("width") / (float)size.optInt("height"));
            width = (int) (height * ratio);
            if (url.contains(".gif")) {
                int gifWH = (int) mContext.getResources().getDimension(R.dimen.gif_wdith_height);
                int padding = (width /2) - gifWH/2;
                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(gifWH, gifWH);
                layoutParams.setMargins(padding, 0, 0, mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp));
                layoutParams.addRule(RelativeLayout.CENTER_VERTICAL);
                gifView.setLayoutParams(layoutParams);
            }
        }

        singleImageParam = CustomViews.getCustomWidthHeightLayoutParams(width, (int) height);
        singleImageParam.setMargins(0, 0, mContext.getResources().getDimensionPixelSize(R.dimen.element_spacing_small),
                mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp));
        return singleImageParam;
    }

    private void redirectToActivity(int attachment_id) {

        // Clickable only when its normal condition (!isLiveStreaming) or in case of live broadcast comment its the audience page.
        if (!isLiveStreaming || isLiveStreamSubscriber) {

            Intent viewIntent = new Intent(mContext, userProfile.class);
            viewIntent.putExtra(ConstantVariables.USER_ID, attachment_id);
            ((Activity) mContext).startActivityForResult(viewIntent, ConstantVariables.USER_PROFILE_CODE);
            ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }
    }

    private void redirectToNestedReplies(View view, boolean isReply, boolean isScrollToPos) {

        itemPosition = (int) view.getTag();
        JSONObject likeUrlParams = null;
        parentItemPosition = itemPosition;

        if (itemPosition < mCommentListItems.size()) {
            CommentList commentList = mCommentListItems.get(itemPosition);
            JSONObject likeJsonObject = commentList.getmLikeJsonObject();
            if (likeJsonObject != null) {
                likeUrlParams = likeJsonObject.optJSONObject("urlParams");
            }
            Intent repliesIntent = new Intent(mContext, NestedComment.class);
            repliesIntent.putExtra(ConstantVariables.ITEM_POSITION, itemPosition);
            repliesIntent.putExtra(ConstantVariables.ACTION_ID, mActionId);
            repliesIntent.putExtra(ConstantVariables.SUBJECT_TYPE, likeUrlParams.optString("subject_type"));
            repliesIntent.putExtra(ConstantVariables.SUBJECT_ID, likeUrlParams.optInt("subject_id"));
            repliesIntent.putExtra(ConstantVariables.COMMENT_TYPE, mListComment.getmCommentModule());
            repliesIntent.putExtra("commentId", commentList.getmCommentId());
            repliesIntent.putExtra("isReply", isReply);
            repliesIntent.putExtra("isScrollToPos", isScrollToPos);
            ((Activity) mContext).startActivityForResult(repliesIntent, ConstantVariables.NESTED_COMMENT_ACTIVITY_CODE);
            ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }
    }

    private void redirectToEditComment(int itemPosition) {

        CommentList commentList = mCommentListItems.get(itemPosition);
        JSONArray commentMenu = commentList.getmCommentMenusArray();

        if (itemPosition < mCommentListItems.size()) {
            Intent editIntent = new Intent(mContext, EditComment.class);
            editIntent.putExtra(ConstantVariables.ITEM_POSITION, itemPosition);
            editIntent.putExtra(ConstantVariables.COMMENT_TYPE, mListComment.getmCommentModule());
            editIntent.putExtra("commentId", commentList.getmCommentId());
            editIntent.putExtra("authorPhoto", commentList.getmAuthorPhoto());
            editIntent.putExtra("commentBody", commentList.getmCommentBody());

            if (commentMenu != null && commentMenu.length() > 0) {
                for (int i = 0; i < commentMenu.length(); i++) {
                    JSONObject mMenuJsonObject = commentMenu.optJSONObject(i);
                    String mMenuName = mMenuJsonObject.optString("name");
                    if (mMenuName.equals("comment_edit") && mMenuJsonObject.optJSONObject("urlParams") != null) {
                        editIntent.putExtra("updateUrl", mMenuJsonObject.optString("url"));
                        JSONObject editUrlParams = mMenuJsonObject.optJSONObject("urlParams");
                        editIntent.putExtra(ConstantVariables.ACTION_ID, editUrlParams.optInt("action_id"));
                        editIntent.putExtra(ConstantVariables.SUBJECT_TYPE, editUrlParams.optString("subject_type"));
                        editIntent.putExtra(ConstantVariables.SUBJECT_ID, editUrlParams.optInt("subject_id"));
                    }
                }
            }
            ((Activity) mContext).startActivityForResult(editIntent, ConstantVariables.EDIT_COMMENT_ACTIVITY_CODE);
            ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }
    }

    public void openLightBox() {
        Bundle bundle = new Bundle();
        bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mPhotoDetails);
        Intent i = new Intent(mContext, PhotoLightBoxActivity.class);
        i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, 1);
        i.putExtra(ConstantVariables.SHOW_OPTIONS, false);
        i.putExtras(bundle);
        mContext.startActivity(i);
    }

    /**
     * Method to show more/less option on comment body.
     * @param tvCommentBody Text view in which comment needs to be shown.
     * @param title Comment body text.
     * @param text Spannable String created from comment body.
     * @param commentList Comment list of particular position.
     */
    private void seeMoreOption(TextView tvCommentBody, CharSequence title, SpannableString text,
                               final CommentList commentList) {
        try {
            if (commentList.getmCommentBody().trim().length()
                    > ConstantVariables.FEED_TITLE_BODY_LENGTH) {
                int startIndex, endIndex;
                if (commentList.isFullCommentShowing()) {
                    startIndex = title.length() -
                            mContext.getResources().getString(R.string.more).length();
                    endIndex = title.length();
                } else {
                    startIndex = title.length() -
                            mContext.getResources().getString(R.string.readLess).length();
                    endIndex = title.length();
                }

                ClickableSpan myClickableSpan = new ClickableSpan() {
                    @Override
                    public void onClick(View widget) {

                    }

                    @Override
                    public void updateDrawState(TextPaint ds) {
                        super.updateDrawState(ds);
                        ds.setUnderlineText(false);
                        ds.setColor(ContextCompat.getColor(mContext, R.color.black));
                        ds.setFakeBoldText(true);
                    }
                };
                text.setSpan(myClickableSpan, startIndex, endIndex, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
            tvCommentBody.setText(text);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @Override
    public void onItemDelete(int position) {
        deleteComment(position);
    }

    @Override
    public void onItemActionSuccess(int position, Object itemList, String menuName) {
        if (menuName.equals("friendship_type")) {
            mCommentListItems.set(position, (CommentList) itemList);
            notifyDataSetChanged();

        } else if (menuName.equals("comment_copy")) {
            CommentList mCommentList = mCommentListItems.get(position);
            if (mCommentList.getmCommentBody() != null && !mCommentList.getmCommentBody().isEmpty()) {
                ClipboardManager clipboard = (ClipboardManager) mContext.getSystemService(Context.CLIPBOARD_SERVICE);
                ClipData clip = ClipData.newPlainText("Comment Text", mCommentList.getmCommentBody());
                clipboard.setPrimaryClip(clip);
            }
        } else if (menuName.equals("comment_edit")) {
            redirectToEditComment(position);
        }
    }

    private static class ListItemHolder{

        ImageView mAuthorImage, mStickerImage, mReplyAuthorImage;
        TextView mAuthorTitle,  mCommentDate, mLikeOption, mReplyOption, mDeleteOption, mCommentLikeCount,
                mPostingText, mMemberOptions, mPreviousReplies, mReplyAuthorTitle;
        JSONObject mLikeJsonObject, mDeleteJsonObject, mReplyJsonObject;
        EmojiconTextView mCommentBody, mReplyCommentBody;
        LinearLayout mCommentOptionsBlock, mCommentReplyBlock, mCommentInfoBlock;
        ImageView mReactionImage, mGifIV;
        JSONObject mLastCommentReplyObject;
        RelativeLayout mAttchmentView;
        String imageUrl;
    }

    public void doLikeUnlike(){

        final CommentList commentList = mCommentListItems.get(itemPosition);
        mLikeOptionArray = commentList.getmLikeJsonObject();
        try {
            final String likeUrl = mLikeOptionArray.getString("url");
            final int isLikeValue = mLikeOptionArray.optInt("isLike");
            final String likeLabel = mLikeOptionArray.getString("label");
            final String likeName = mLikeOptionArray.getString("name");

            if (mSubjectType.equals("activity_action")) {
                mLikeCommentUrl = AppConstant.DEFAULT_URL + "advancedactivity/" + likeUrl;
            } else {
                mLikeCommentUrl = AppConstant.DEFAULT_URL + likeUrl;
            }
            JSONObject urlParamsJsonObject = mLikeOptionArray.getJSONObject("urlParams");

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

                            int isLike = commentList.getmIsLike();
                            if (isLike == 0) {
                                commentList.setmIsLike(1);
                                commentList.setmLikeCount(commentList.getmLikeCount() + 1);
                            }else {
                                commentList.setmIsLike(0);
                                commentList.setmLikeCount(commentList.getmLikeCount() - 1);
                            }

                            try {
                                if (isLikeValue == 0)
                                    mLikeOptionArray.put("isLike", 1);
                                else
                                    mLikeOptionArray.put("isLike", 0);
                                if (likeLabel.equals("Like"))
                                    mLikeOptionArray.put("label", "Unlike");
                                else
                                    mLikeOptionArray.put("label", "Like");
                                if (likeUrl.equals("like"))
                                    mLikeOptionArray.put("url", "unlike");
                                else
                                    mLikeOptionArray.put("url", "like");
                                if (likeName.equals("unlike"))
                                    mLikeOptionArray.put("name", "like");
                                else
                                    mLikeOptionArray.put("name", "unlike");

                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            commentList.setmLikeJsonObject(mLikeOptionArray);
                            notifyDataSetChanged();
                            likeUnlikeAction = true;

                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                            notifyDataSetChanged();
                            likeUnlikeAction = true;
                            SnackbarUtils.displaySnackbar(mRootView, message);
                        }
                    });
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    public void deleteComment(int mPosition) {

        mAlertDialogWithAction.showAlertDialogWithAction(mContext.getResources().getString(R.string.delete_comment_dialogue_title),
                mContext.getResources().getString(R.string.delete_comment_dialogue_message),
                mContext.getResources().getString(R.string.delete_comment_dialogue_delete_button),
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int which) {

                        final CommentList commentList = mCommentListItems.get(mPosition);
                        JSONArray commentMenu = commentList.getmCommentMenusArray();
                        if (commentMenu != null && commentMenu.length() != 0) {
                            for (int i = 0; i < commentMenu.length(); i++) {
                                JSONObject mMenuJsonObject = commentMenu.optJSONObject(i);
                                String mMenuName = mMenuJsonObject.optString("name");
                                if (mMenuName.equals("comment_delete") && mMenuJsonObject.optJSONObject("urlParams") != null) {

                                    try {
                                        if (mSubjectType.equals("activity_action")) {
                                            mDeleteCommentUrl = AppConstant.DEFAULT_URL + "advancedactivity/delete";
                                        } else {
                                            mDeleteCommentUrl = AppConstant.DEFAULT_URL + mMenuJsonObject.getString("url");
                                        }
                                        JSONObject urlParamsJsonObject = mMenuJsonObject.getJSONObject("urlParams");
                                        JSONArray urlParamsKeys = urlParamsJsonObject.names();
                                        Map<String, String> deleteParams = new HashMap<>();

                                        for (int j = 0; j < urlParamsJsonObject.length(); j++) {
                                            String keyName = urlParamsKeys.getString(j);
                                            String value = urlParamsJsonObject.getString(keyName);
                                            deleteParams.put(keyName, value);
                                        }

                                        if (deleteParams.size() != 0) {
                                            mDeleteCommentUrl = mAppConst.buildQueryString(mDeleteCommentUrl, deleteParams);
                                        }
                                        mAppConst.showProgressDialog();
                                        mAppConst.deleteResponseForUrl(mDeleteCommentUrl, null, new OnResponseListener() {
                                            @Override
                                            public void onTaskCompleted(JSONObject jsonObject) {
                                                mAppConst.hideProgressDialog();
                                                /* Notify the adapter After Deleting the Entry */
                                                mCommentListItems.remove(mPosition);
                                                mListComment.setmTotalCommmentCount(mListComment.getmTotalCommmentCount() - 1);
                                                deleteReplyCount += 1;
                                                if (mOnCommentDeleteListener != null) {
                                                    mOnCommentDeleteListener.onCommentDelete();
                                                }
                                                // for update last reply item of the parent list item
                                                JSONArray mTotalRepliesArray = mListComment.getmAllRepliesJSONArray();
                                                if (mTotalRepliesArray != null && mTotalRepliesArray.length() != 0) {
                                                    Intent intent = new Intent();
                                                    if (mPosition == mTotalRepliesArray.length() - 1) {
                                                        try {
                                                            if (mPosition == 0) {
                                                                intent.putExtra("deleteLastItem", true);
                                                                intent.putExtra(ConstantVariables.COMMENT_OBJECT, "");
                                                            } else {
                                                                int itemIndex = mTotalRepliesArray.length() - mPosition;                    //response is coming from latest to oldest
                                                                JSONObject repliesInfoObject = mTotalRepliesArray.getJSONObject(itemIndex);
                                                                intent.putExtra(ConstantVariables.COMMENT_OBJECT, String.valueOf(repliesInfoObject));
                                                            }
                                                        } catch (JSONException e) {
                                                            e.printStackTrace();
                                                        }
                                                    }
                                                    intent.putExtra(ConstantVariables.ITEM_POSITION, parentItemPosition);
                                                    intent.putExtra("deleteReplyCount", deleteReplyCount);
                                                    ((Activity) mContext).setResult(ConstantVariables.VIEW_DELETE_NESTED_REPLIES_PAGE, intent);
                                                }
                                                notifyDataSetChanged();
                                            }

                                            @Override
                                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                                mAppConst.hideProgressDialog();
                                                SnackbarUtils.displaySnackbar(mRootView, message);
                                            }
                                        });
                                    } catch (JSONException | NullPointerException e) {
                                        e.printStackTrace();
                                    }
                                }
                            }
                        }
                }
        });
    }

    public void viewCommentLikes(){

        CommentList commentList = mCommentListItems.get(mLikeCountPosition);
        String viewAllCommentLikesUrl;
        if (mSubjectType.equals("activity_action")) {
            viewAllCommentLikesUrl = UrlUtil.AAF_VIEW_LIKES_URL + "&comment_id=" + commentList.getmCommentId() +
                    "&action_id=" +mActionId;
        } else {
            viewAllCommentLikesUrl = UrlUtil.VIEW_LIKES_URL + "&subject_type=" + mSubjectType + "&subject_id=" + mSubjectId +
                    "&comment_id=" + commentList.getmCommentId();
        }
        Intent viewAllLikesIntent = new Intent(mContext, Likes.class);
        viewAllLikesIntent.putExtra("ViewAllLikesUrl", viewAllCommentLikesUrl);
        mContext.startActivity(viewAllLikesIntent);
        ((Activity)mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

    }

}
