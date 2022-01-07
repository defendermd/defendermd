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

package com.socialengineaddons.mobileapp.classes.common.utils;

import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;

import org.json.JSONArray;
import org.json.JSONObject;

public class ImageViewList {
    private String mGridViewImageUrl, mAlbumCover, mContentUrl;
    private Bitmap mGridPhotoBitmap;
    private Drawable drawableIcon;
    private int totalPhotoCount, likeCount, commentCount, mSubjectId, mOwnerId;
    private int remainingPhotoCount;
    float mImageWidth, mImageHeight;
    private String albumDescription,ownerTitle,ownerImageUrl, albumTitle, albumCreationDate, privacyValue, albumViewPrivacy;
    private String mCaption, mReaction;
    private String mReactionIcon, mReactionLargeIcon;
    private int mReactionId, mStickerId, mSelectedItemPos, imageViewHeight;
    private String mStickerTitle, mStickerBackGroundColor, mStickerGuid, mStickerKey;
    private JSONObject privacyObject, mReactionObject;
    private JSONArray mAlbumGutterMenu;
    private boolean isLike;

    public ImageViewList(){

    }

    //For Album View Page
    public ImageViewList (String imgUrl , String albumDescription, String ownerTitle,
                          String ownerImageUrl){
        mGridViewImageUrl=imgUrl;
        this.albumDescription = albumDescription;
        this.ownerImageUrl = ownerImageUrl;
        this.ownerTitle = ownerTitle;

    }

    public ImageViewList(Drawable drawable) {
        drawableIcon = drawable;
    }

    public ImageViewList(Drawable drawable, String description) {
        drawableIcon = drawable;
        this.albumDescription = description;
    }


    public void setOwnerImageUrl(String ownerImageUrl) {
        this.ownerImageUrl = ownerImageUrl;
    }

    public void setOwnerTitle(String ownerTitle) {
        this.ownerTitle = ownerTitle;
    }

    public void setAlbumDescription(String albumDescription) {
        this.albumDescription = albumDescription;
    }

    public String getAlbumDescription() {
        return albumDescription;
    }

    public String getOwnerTitle() {
        return ownerTitle;
    }

    public String getOwnerImageUrl() {
        return ownerImageUrl;
    }

    public ImageViewList(String imgurl){
        mGridViewImageUrl=imgurl;
    }

    public ImageViewList(String imgurl, float width, float height){
        mGridViewImageUrl = imgurl;
        mImageWidth = width;
        mImageHeight = height;
    }

    // For Reaction Icons
    public ImageViewList(String imgurl, String caption, String reaction, int reactionId, String reactionIcon){
        mGridViewImageUrl = imgurl;
        mCaption = caption;
        mReaction = reaction;
        mReactionId = reactionId;
        mReactionIcon = reactionIcon;
    }

    public ImageViewList(String imgurl, String caption, String reaction, int reactionId, String reactionIcon, String reactionLargeIcon){
        mGridViewImageUrl = imgurl;
        mCaption = caption;
        mReaction = reaction;
        mReactionId = reactionId;
        mReactionIcon = reactionIcon;
        mReactionLargeIcon = reactionLargeIcon;
    }

    public ImageViewList(String imgurl, float width, float height, int photoCount){
        mGridViewImageUrl = imgurl;
        mImageWidth = width;
        mImageHeight = height;
        remainingPhotoCount = photoCount;
    }

    public ImageViewList(String imgurl, String stickerGuid){
        mGridViewImageUrl = imgurl;
        mStickerGuid = stickerGuid;
    }

    public ImageViewList(String imgurl, int stickerId, String stickerTitle, String stickersKey, String backGroundColor){
        mGridViewImageUrl = imgurl;
        mStickerId = stickerId;
        mStickerTitle = stickerTitle;
        mStickerKey = stickersKey;
        mStickerBackGroundColor = backGroundColor;
    }

    public ImageViewList(Bitmap imgurl){
        mGridPhotoBitmap = imgurl;
    }

    public ImageViewList(int selectedPosition, Bitmap imgurl){
        mSelectedItemPos = selectedPosition;
        mGridPhotoBitmap = imgurl;
    }

    public int getmSelectedItemPos() {
        return mSelectedItemPos;
    }

    public void setmSelectedItemPos(int mSelectedItemPos) {
        this.mSelectedItemPos = mSelectedItemPos;
    }

    public String getmGridViewImageUrl(){
        return mGridViewImageUrl;
    }

    public Bitmap getmGridPhotoUrl() {
        return mGridPhotoBitmap;
    }

    public int getTotalPhotoCount() {
        return totalPhotoCount;
    }

    public void setTotalPhotoCount(int totalPhotoCount) {
        this.totalPhotoCount = totalPhotoCount;
    }

    public float getmImageWidth() {
        return mImageWidth;
    }

    public float getmImageHeight() {
        return mImageHeight;
    }

    public int getRemainingPhotoCount() {
        return remainingPhotoCount;
    }

    public String getmCaption() {
        return mCaption;
    }

    public String getmReaction() {
        return mReaction;
    }

    public int getmReactionId() {
        return mReactionId;
    }

    public String getmReactionIcon() {
        return mReactionIcon;
    }

    public String getmReactionLargeIcon() {
        return mReactionLargeIcon;
    }

    public int getmStickerId() {
        return mStickerId;
    }

    public String getmStickerTitle() {
        return mStickerTitle;
    }

    public String getmStickerBackGroundColor() {
        return mStickerBackGroundColor;
    }

    public String getmStickerGuid() {
        return mStickerGuid;
    }

    public String getmStickerKey() {
        return mStickerKey;
    }

    public Drawable getDrawableIcon() {
        return drawableIcon;
    }

    public void setAlbumCreationDate(String albumCreationDate) {
        this.albumCreationDate = albumCreationDate;
    }

    public String getAlbumCreationDate() {
        return albumCreationDate;
    }

    public void setAlbumTitle(String albumTitle) {
        this.albumTitle = albumTitle;
    }

    public String getAlbumTitle() {
        return albumTitle;
    }

    public void setPrivacyObject(JSONObject privacyObject) {
        this.privacyObject = privacyObject;
    }

    public JSONObject getPrivacyObject() {
        return privacyObject;
    }

    public void setPrivacyValue(String privacyValue) {
        this.privacyValue = privacyValue;
    }

    public String getPrivacyValue() {
        return privacyValue;
    }

    public void setAlbumViewPrivacy(String albumViewPrivacy) {
        this.albumViewPrivacy = albumViewPrivacy;
    }

    public String getAlbumViewPrivacy() {
        return albumViewPrivacy;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setIsLike(boolean isLike) {
        this.isLike = isLike;
    }

    public boolean getIsLike() {
        return isLike;
    }

    public void setCommentCount(int commentCount) {
        this.commentCount = commentCount;
    }

    public int getCommentCount() {
        return commentCount;
    }

    public void setmReactionObject(JSONObject mReactionObject) {
        this.mReactionObject = mReactionObject;
    }

    public JSONObject getmReactionObject() {
        return mReactionObject;
    }

    public void setmAlbumGutterMenu(JSONArray mGutterMenuObject) {
        this.mAlbumGutterMenu = mGutterMenuObject;
    }

    public JSONArray getmAlbumGutterMenu() {
        return mAlbumGutterMenu;
    }

    public void setmSubjectId(int mSubjectId) {
        this.mSubjectId = mSubjectId;
    }

    public int getmSubjectId() {
        return mSubjectId;
    }

    public void setmAlbumCover(String mAlbumCover) {
        this.mAlbumCover = mAlbumCover;
    }

    public String getmAlbumCover() {
        return mAlbumCover;
    }

    public void setmContentUrl(String mContentUrl) {
        this.mContentUrl = mContentUrl;
    }

    public String getmContentUrl() {
        return mContentUrl;
    }

    public void setmOwnerId(int mOwnerId) {
        this.mOwnerId = mOwnerId;
    }

    public int getmOwnerId() {
        return mOwnerId;
    }

    public void setImageViewHeight(int imageViewHeight) {
        this.imageViewHeight = imageViewHeight;
    }

    public int getImageViewHeight() {
        return imageViewHeight;
    }
}
