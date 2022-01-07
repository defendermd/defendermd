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

import android.graphics.Bitmap;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;

public class CommentList {

    private int isFriendshipVerified;
    private int mCommentId, mLikeCount, mIsLike, mTotalCommmentCount, mTotalRepliesCount, mUserId, mReplyCount, mTotalItemCount;
    private String mAuthorPhoto, mAuthorTitle, mCommentBody, mCommentDate, mFriendshipType, mReactionIcon;
    private JSONObject mLikeJsonObject, mImageSize, mReplyJsonObject;
    private boolean showPosting, isFullCommentShowing = true;
    private String mStickerImage;
    private Bitmap mImageBitmap;
    HashMap<String, String> mClickableStringsList;
    private String mCommentModule;
    private JSONArray mAllRepliesJSONArray, mCommentMenus;
    private JSONObject mLastCommentReplyObject;

    public CommentList(){

    }

    public CommentList(int user_id, int mCommentId, int mLikeCount, int mIsLike, String mAuthorPhoto,
                       String mAuthorTitle, String mCommentBody, HashMap<String, String> clickableStrings, String mCommentDate,
                       JSONObject mLikeJsonObject, JSONObject mReplyJsonObject, JSONArray mCommentMenus, JSONObject mLastCommentReplyObject, String stickerImage, JSONObject imageSize, int mReplyCount) {

        mUserId = user_id;
        this.mCommentId = mCommentId;
        this.mLikeCount = mLikeCount;
        this.mIsLike = mIsLike;
        this.mAuthorPhoto = mAuthorPhoto;
        this.mAuthorTitle = mAuthorTitle;
        this.mCommentBody = mCommentBody;
        this.mClickableStringsList = clickableStrings;
        this.mCommentDate = mCommentDate;
        this.mLikeJsonObject = mLikeJsonObject;
        this.mReplyJsonObject = mReplyJsonObject;
        this.mLastCommentReplyObject = mLastCommentReplyObject;
        this.mStickerImage = stickerImage;
        this.mImageSize = imageSize;
        this.mReplyCount = mReplyCount;
        this.mCommentMenus = mCommentMenus;
    }

    public CommentList(int user_id, String mAuthorTitle, String mAuthorPhoto, String friendshipType, int isFriendshipVerified) {
        mUserId = user_id;
        this.mAuthorPhoto = mAuthorPhoto;
        this.mAuthorTitle = mAuthorTitle;
        mFriendshipType = friendshipType;
        this.isFriendshipVerified = isFriendshipVerified;
    }

    public CommentList(int user_id, String mAuthorTitle, String mAuthorPhoto, String friendshipType,
                       String reactionIcon, int isFriendshipVerified) {
        mUserId = user_id;
        this.mAuthorPhoto = mAuthorPhoto;
        this.mAuthorTitle = mAuthorTitle;
        mFriendshipType = friendshipType;
        mReactionIcon = reactionIcon;
        this.isFriendshipVerified = isFriendshipVerified;
    }

    public CommentList(int user_id, String mAuthorTitle, String mAuthorPhoto, String mCommentBody, String stickerImage,
                       boolean showPosting) {
        mUserId = user_id;
        this.mAuthorPhoto = mAuthorPhoto;
        this.mAuthorTitle = mAuthorTitle;
        this.mCommentBody = mCommentBody;
        this.showPosting = showPosting;
        this.mStickerImage = stickerImage;
    }

    public CommentList(int user_id, String mAuthorTitle, String mAuthorPhoto, String mCommentBody, String stickerImage,
                       boolean showPosting, Bitmap imageBitmap) {
        mUserId = user_id;
        this.mAuthorPhoto = mAuthorPhoto;
        this.mAuthorTitle = mAuthorTitle;
        this.mCommentBody = mCommentBody;
        this.showPosting = showPosting;
        this.mStickerImage = stickerImage;
        this.mImageBitmap = imageBitmap;
    }

    public void setUserId(int mUserId) {
        this.mUserId = mUserId;
    }

    public void setAuthorPhoto(String mAuthorPhoto) {
        this.mAuthorPhoto = mAuthorPhoto;
    }

    public void setAuthorTitle(String mAuthorTitle) {
        this.mAuthorTitle = mAuthorTitle;
    }

    public void setCommentBody(String mCommentBody) {
        this.mCommentBody = mCommentBody;
    }

    public void setCommentDate(String mCommentDate) {
        this.mCommentDate = mCommentDate;
    }

    public int getmUserId() {
        return mUserId;
    }

    public int getmCommentId() {
        return mCommentId;
    }

    public int getmLikeCount() {
        return mLikeCount;
    }

    public void setmLikeCount(int mLikeCount) {
        this.mLikeCount = mLikeCount;
    }

    public int getmIsLike() {
        return mIsLike;
    }

    public void setmIsLike(int mIsLike) {
        this.mIsLike = mIsLike;
    }

    public String getmAuthorPhoto() {
        return mAuthorPhoto;
    }

    public String getmAuthorTitle() {
        return mAuthorTitle;
    }

    public void setmCommentBody(String mCommentBody) {
        this.mCommentBody = mCommentBody;
    }

    public String getmCommentBody() {
        return mCommentBody;
    }

    public String getmCommentDate() {
        return mCommentDate;
    }

    public JSONObject getmLikeJsonObject() {
        return mLikeJsonObject;
    }

    public JSONObject getmReplyJsonObject(){
        return mReplyJsonObject;
    }

    public JSONArray getmCommentMenusArray() {
        return mCommentMenus;
    }

    public void setmAllRepliesJSONArray(JSONArray mAllRepliesJSONArray) {
        this.mAllRepliesJSONArray = mAllRepliesJSONArray;
    }

    public JSONArray getmAllRepliesJSONArray(){
        return mAllRepliesJSONArray;
    }

    public void setmLastCommentReplyObject(JSONObject mLastCommentReplyObject) {
        this.mLastCommentReplyObject = mLastCommentReplyObject;
    }

    public JSONObject getmLastCommentReplyObject() {
        return mLastCommentReplyObject;
    }

    public void setmCommentModule(String mCommentModule){
        this.mCommentModule = mCommentModule;
    }

    public String getmCommentModule(){
        return mCommentModule;
    }

    public void setmLikeJsonObject(JSONObject mLikeJsonObject) {
        this.mLikeJsonObject = mLikeJsonObject;
    }

    public int getmTotalCommmentCount() {
        return mTotalCommmentCount;
    }

    public void setmTotalCommmentCount(int mTotalCommmentCount) {
        this.mTotalCommmentCount = mTotalCommmentCount;
    }

    public void setmTotalItemCount(int mTotalItemCount){
        this.mTotalItemCount = mTotalItemCount;
    }

    public int getmTotalItemCount(){
        return mTotalItemCount;
    }

    public void setmTotalRepliesCount(int mTotalRepliesCount) {
        this.mTotalRepliesCount = mTotalRepliesCount;
    }

    public int getmTotalRepliesCount(){
        return mTotalRepliesCount;
    }

    public void setmTotalReplyCount(int mTotalReplyCount){
        this.mReplyCount = mTotalReplyCount;
    }

    public int getmTotalReplyCount(){
        return mReplyCount;
    }

    public boolean isShowPosting() {
        return showPosting;
    }

    public String getmFriendshipType() {
        return mFriendshipType;
    }

    public void setmFriendshipType(String mFriendshipType) {
        this.mFriendshipType = mFriendshipType;
    }

    public String getmReactionIcon() {
        return mReactionIcon;
    }

    public String getmStickerImage() {
        return mStickerImage;
    }

    public Bitmap getmImageBitmap() {
        return mImageBitmap;
    }

    public int getIsFriendshipVerified() {
        return isFriendshipVerified;
    }
    public HashMap<String, String> getmClickableStringsList() {
        return mClickableStringsList;
    }

    public void showFullComment(boolean isFullCommentShowing) {
        this.isFullCommentShowing = isFullCommentShowing;
    }

    public boolean isFullCommentShowing() {
        return isFullCommentShowing;
    }

    public JSONObject getmImageSize() {
        return mImageSize;
    }
}
