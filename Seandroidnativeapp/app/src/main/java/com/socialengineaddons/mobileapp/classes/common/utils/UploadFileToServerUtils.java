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

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.view.View;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnAsyncResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommentPostListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.okhttp.OkHttpUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.okhttp.PostFormBuilder;
import com.socialengineaddons.mobileapp.classes.common.utils.okhttp.StringCallback;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.likeNComment.CommentList;

import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import id.zelory.compressor.Compressor;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;
import okhttp3.Call;
import okhttp3.Request;


public class UploadFileToServerUtils extends StringCallback {

    private Context mContext;
    private View mMainView;
    private ArrayList<String> mSelectPath = new ArrayList<>(), mSelectedMusicFiles;
    private Map<String, String> mPostParams;
    private Map<String, String> mVideoParams;
    private HashMap<String, ArrayList> mHostMap;
    private JSONObject mResponseObject;
    private ProgressDialog mProgressDialog;
    private String mPostUrl, mCurrentSelectedModule, mData, mSelectedFilePath;
    private boolean mIsDataUploadRequest = false, mIsCreateForm, mIsError = false,
            mIsSignUpRequest = false, mIsMainActivityImageUploadRequest;
    private AppConstant mAppConst;
    private OnUploadResponseListener mOnUploadResponseListener;
    private String mRegistrationId, mUriText, mAttachMusicFile, mAttachType;
    private boolean mIsAttachFileRequest = false, mIsNeedToShowDialog = true;
    private OnAsyncResponseListener mCaller;
    private OnCommentPostListener mOnCommentPostListener;
    private CommentList mCommentList;
    private boolean isStoryPost = false;
    private int processCount = 0;


    // For Image File uploading
    public UploadFileToServerUtils(Context context, String postUrl, ArrayList<String> selectPath,
                                   OnUploadResponseListener onUploadResponseListener) {
        this.mContext = context;
        this.mPostUrl = postUrl;
        this.mSelectPath = selectPath;
        this.mOnUploadResponseListener = onUploadResponseListener;

        mIsDataUploadRequest = false;
        mAppConst = new AppConstant(mContext);
    }

    // For Image File uploading from MainActivity
    public UploadFileToServerUtils(Context context, View mainView, String postUrl,
                                   ArrayList<String> selectPath,
                                   OnUploadResponseListener onUploadResponseListener) {
        this.mContext = context;
        this.mMainView = mainView;
        this.mPostUrl = postUrl;
        this.mIsMainActivityImageUploadRequest = true;
        this.mSelectPath = selectPath;
        this.mOnUploadResponseListener = onUploadResponseListener;

        mIsDataUploadRequest = false;
        mAppConst = new AppConstant(mContext);
    }

    // For Create data uploading
    public UploadFileToServerUtils(Context context, String postUrl, String currentSelectedModule,
                                   boolean isCreateForm, ArrayList<String> selectPath,
                                   ArrayList<String> selectedMusicFiles,
                                   Map<String, String> postParams,
                                   HashMap<String, ArrayList> hostMap, String mSelectedFilePath, Map<String, String> videoParams) {
        this.mContext = context;
        this.mPostUrl = postUrl;
        this.mCurrentSelectedModule = currentSelectedModule;
        this.mIsCreateForm = isCreateForm;
        this.mSelectPath = selectPath;
        this.mSelectedMusicFiles = selectedMusicFiles;
        this.mPostParams = postParams;
        this.mHostMap = hostMap;
        this.mSelectedFilePath = mSelectedFilePath;
        this.mVideoParams = videoParams;

        mIsDataUploadRequest = true;
        mOnUploadResponseListener = (OnUploadResponseListener) mContext;
        mAppConst = new AppConstant(mContext);
    }

    // For Edit data uploading
    public UploadFileToServerUtils(Context context, String postUrl, String currentSelectedModule,
                                   boolean isCreateForm, String data, String selectedFilePath,
                                   ArrayList<String> selectPath,
                                   ArrayList<String> selectedMusicFiles,
                                   Map<String, String> postParams,
                                   HashMap<String, ArrayList> hostMap) {
        this.mContext = context;
        this.mPostUrl = postUrl;
        this.mCurrentSelectedModule = currentSelectedModule;
        this.mIsCreateForm = isCreateForm;
        this.mData = data;
        this.mSelectedFilePath = selectedFilePath;
        this.mSelectPath = selectPath;
        this.mSelectedMusicFiles = selectedMusicFiles;
        this.mPostParams = postParams;
        this.mHostMap = hostMap;

        mIsDataUploadRequest = true;
        mOnUploadResponseListener = (OnUploadResponseListener) mContext;
        mAppConst = new AppConstant(mContext);
    }

    // For Editor data uploading
    public UploadFileToServerUtils(Context context, String postUrl, String data,
                                   ArrayList<String> selectPath,
                                   Map<String, String> postParams) {
        this.mContext = context;
        this.mPostUrl = postUrl;
        this.mData = data;
        this.mSelectPath = selectPath;
        this.mPostParams = postParams;

        mIsDataUploadRequest = true;
        mOnUploadResponseListener = (OnUploadResponseListener) mContext;
        mAppConst = new AppConstant(mContext);
    }

    // For SignUp
    public UploadFileToServerUtils(Context context, String postUrl, ArrayList<String> selectPath,
                                   Map<String, String> postParams, String registrationId) {
        this.mContext = context;
        this.mPostUrl = postUrl;
        this.mSelectPath = selectPath;
        this.mPostParams = postParams;
        this.mRegistrationId = registrationId;

        mIsSignUpRequest = true;
        mIsDataUploadRequest = true;
        mOnUploadResponseListener = (OnUploadResponseListener) mContext;
        mAppConst = new AppConstant(mContext);
    }

    // For attaching Music
    public UploadFileToServerUtils(Context context, String postUrl, String selectedMusicFile) {
        mContext = context;
        mPostUrl = postUrl;
        mAttachMusicFile = selectedMusicFile;
        mAttachType = "music";

        mIsAttachFileRequest = true;
        mCaller = (OnAsyncResponseListener) mContext;
        mAppConst = new AppConstant(mContext);
    }

    // For attaching Link
    public UploadFileToServerUtils(Context context, String postUrl, String uriText, String attachType) {
        mContext = context;
        mPostUrl = postUrl;
        mUriText = uriText;
        mAttachType = attachType;

        mIsAttachFileRequest = true;
        mCaller = (OnAsyncResponseListener) mContext;
        mAppConst = new AppConstant(mContext);
    }

    // For Uploading data with attachment.
    public UploadFileToServerUtils(Context context, String postUrl, Map<String, String> postParams,
                                   ArrayList<String> selectPath) {
        mContext = context;
        mPostUrl = postUrl;
        mPostParams = postParams;
        mSelectPath = selectPath;
        mIsAttachFileRequest = false;
        mIsDataUploadRequest = true;
        mCaller = (OnAsyncResponseListener) mContext;
        mAppConst = new AppConstant(mContext);

        if (postParams != null && postParams.containsKey("mVideoPath") && mVideoParams != null) {
            mPostParams.put("type", "3");
            mVideoParams.put("filedata", postParams.get("mVideoPath"));
            mVideoParams.put("photo", postParams.get("mVideoThumbnail"));

        }
    }

    // For Uploading data with attachment. (Story uploading)
    public UploadFileToServerUtils(Context context, String postUrl, Map<String, String> postParams,
                                   ArrayList<String> selectPath, boolean isStoryPost,
                                   OnAsyncResponseListener onAsyncResponseListener,
                                   Map<String, String> videoParams) {
        mContext = context;
        mPostUrl = postUrl;
        mPostParams = postParams;
        mSelectPath = selectPath;
        this.mVideoParams = videoParams;
        this.isStoryPost = isStoryPost;

        if (mVideoParams != null && mVideoParams.size() > 0) {
            if (!isStoryPost) {
                mPostParams.put("type", "3");
            }
        }

        mIsNeedToShowDialog = false;
        mIsAttachFileRequest = false;
        mIsDataUploadRequest = true;
        mCaller = onAsyncResponseListener;
        mAppConst = new AppConstant(mContext);
    }

    //For Comment with photo uploading.
    public UploadFileToServerUtils(Context context, String postUrl, ArrayList<String> selectPath,
                                   CommentList commentList, Map<String, String> params) {
        mContext = context;
        mPostUrl = postUrl;
        mSelectPath = selectPath;
        mIsAttachFileRequest = false;
        mIsNeedToShowDialog = false;
        mIsDataUploadRequest = true;

        mPostParams = params;
        mCommentList = commentList;
        mAppConst = new AppConstant(mContext);
        if (commentList != null) {
            mOnCommentPostListener = (OnCommentPostListener) mContext;
        } else {
            mCaller = (OnAsyncResponseListener) mContext;
        }
    }

    @Override
    public void onBefore(Request request, Object tag) {

        if (mIsNeedToShowDialog) {
            if (mProgressDialog == null) {
                mProgressDialog = new ProgressDialog(mContext);

                if (mIsDataUploadRequest) {
                    mProgressDialog.setMessage(mContext.getResources().getString(R.string.progress_dialog_wait) + "…");
                } else {
                    mProgressDialog.setMessage(mContext.getResources().getString(R.string.dialog_uploading_msg) + "…");
                }
                // Showing progress dialog with spinner when there is no file uploading.
                if ((mSelectPath == null || mSelectPath.isEmpty())
                        && (mSelectedMusicFiles == null || mSelectedMusicFiles.isEmpty())
                        && (mVideoParams == null || mVideoParams.isEmpty())) {
                    mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
                } else {
                    mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
                    mProgressDialog.setProgress(0);
                    mProgressDialog.setMax(100);
                    mProgressDialog.setProgressNumberFormat(null);
                }

                mProgressDialog.setCancelable(false);
                mProgressDialog.show();
            }

        } else if (mIsMainActivityImageUploadRequest) {
            SnackbarUtils.displaySnackbarLongTime(mMainView, mContext.getResources().
                    getQuantityString(R.plurals.photo_uploading_msg,
                            mSelectPath.size()));
        }
        super.onBefore(request, tag);
    }

    public void execute() {

        if (mSelectPath != null && !mSelectPath.isEmpty()) {

            if (mIsNeedToShowDialog) {
                mProgressDialog = new ProgressDialog(mContext);
                mProgressDialog.setMessage(mContext.getResources().getString(R.string.progress_dialog_wait) + "…");
                mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
                mProgressDialog.setProgress(0);
                mProgressDialog.setMax(100);
                mProgressDialog.setProgressNumberFormat(null);
                mProgressDialog.setCancelable(false);
                mProgressDialog.show();
            }

            // Checking is there any image which required rotation.
            for (final String imagePath : mSelectPath) {
                BitmapUtils.decodeSampledBitmapFromFile(mContext, imagePath,
                        AppConstant.getDisplayMetricsWidth(mContext),
                        (int) mContext.getResources().getDimension(R.dimen.feed_attachment_image_height), false);
            }

            if (BitmapUtils.isImageRotated) {
                for (final String imagePath : mSelectPath) {
                    BitmapUtils.decodeSampledBitmapFromFile(mContext, imagePath,
                            AppConstant.getDisplayMetricsWidth(mContext),
                            (int) mContext.getResources().getDimension(R.dimen.feed_attachment_image_height), true);
                }
                mSelectPath = BitmapUtils.updateSelectPath();
            }


            /* Did image compression work before uploading to the server */
            for (int i = 0; i < mSelectPath.size(); i++) {

                if (mSelectPath.get(i).contains(".gif")) {
                    uploadUsingOkHttp();
                } else {
                    int finalI = i;
                    new Compressor(mContext)
                            .compressToFileAsFlowable(new File(mSelectPath.get(i)))
                            .subscribeOn(Schedulers.io())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe(new Consumer<File>() {
                                @Override
                                public void accept(File file) {
                                    processCount++;
                                    mSelectPath.set(finalI, file.getAbsolutePath());

                                    if (processCount == mSelectPath.size()) {
                                        uploadUsingOkHttp();
                                    }
                                }

                            }, new Consumer<Throwable>() {
                                @Override
                                public void accept(Throwable throwable) {
                                    throwable.printStackTrace();

                                    processCount++;
                                    if (processCount == mSelectPath.size()) {
                                        uploadUsingOkHttp();
                                    }
                                }
                            });
                }
            }

        } else {
            uploadUsingOkHttp();
        }

    }

    public void uploadUsingOkHttp() {
        try {
            PostFormBuilder multipartBuilder = OkHttpUtils.post();
            mPostUrl = mAppConst.buildQueryString(mPostUrl, mAppConst.getAuthenticationParams());
            // Put Language Params, location addParams, and version addParams
            mPostUrl = mAppConst.buildQueryString(mPostUrl, mAppConst.getRequestParams());

            LogUtils.LOGD(UploadFileToServerUtils.class.getSimpleName(), "Post Url: " + mPostUrl);

            if (mIsDataUploadRequest) {

                // Adding post params into entity.
                if (mPostParams != null) {
                    if (mPostParams.containsKey("photo")) {
                        mPostParams.remove("photo");
                    }
                    multipartBuilder.addParams(mPostParams);
                    LogUtils.LOGD(UploadFileToServerUtils.class.getSimpleName(), "Post Params: " + mPostParams);
                }

                // Adding Editor data
                if (mData != null) {
                    multipartBuilder.addParam("body", mData);
                }

                if (mVideoParams != null && !mVideoParams.isEmpty()) {
                    Set<String> keySet = mVideoParams.keySet();
                    for (String key : keySet) {
                        String value = mVideoParams.get(key);
                        if (key.equals("photo") && isStoryPost) {
                            multipartBuilder.addFile("video_thumbnail", value, new File(value));
                        } else {
                            multipartBuilder.addFile(key, value, new File(value));
                        }
                    }
                }

                // Adding file path into entity.
                if (mCurrentSelectedModule != null && mCurrentSelectedModule.equals(ConstantVariables.PRODUCT_MENU_TITLE) && mSelectedFilePath != null) {
                    multipartBuilder.addFile("upload_product", mSelectedFilePath, new File(mSelectedFilePath));
                } else if (mSelectedFilePath != null) {
                    multipartBuilder.addFile("filename", mSelectedFilePath, new File(mSelectedFilePath));
                }

                // Adding music files into entity.
                if (mSelectedMusicFiles != null && !mSelectedMusicFiles.isEmpty()) {
                    for (int i = 0; i < mSelectedMusicFiles.size(); i++) {
                        String name = "songs" + i;
                        if (i == 0) {
                            name = "songs";
                        }
                        multipartBuilder.addFile(name, mSelectedMusicFiles.get(i), new File(mSelectedMusicFiles.get(i)));
                    }
                }

                // Adding host photo in case of advanced event.
                if (mCurrentSelectedModule != null
                        && mCurrentSelectedModule.equals(ConstantVariables.ADVANCED_EVENT_MENU_TITLE)
                        && mIsCreateForm) {
                    if (mHostMap.containsKey("host_photo")) {
                        String hostPhoto = mHostMap.get("host_photo").get(0).toString();
                        multipartBuilder.addFile("host_photo", hostPhoto, new File(hostPhoto));
                    }
                    if (mHostMap.containsKey("photo")) {
                        String photo = mHostMap.get("photo").get(0).toString();
                        multipartBuilder.addFile("photo", photo, new File(photo));
                    }
                }

                // Adding registration id and device id in case of sign-up.
                if (mIsSignUpRequest) {
                    if (mRegistrationId != null && !mRegistrationId.isEmpty()) {
                        multipartBuilder.addParam("registration_id", mRegistrationId);
                        multipartBuilder.addParam("device_uuid", mAppConst.getDeviceUUID());
                    }
                }
            } else if (mIsAttachFileRequest) {
                // Add music in post params
                if (mAttachMusicFile != null && !mAttachMusicFile.isEmpty()) {
                    multipartBuilder.addParam("post_attach", "1");
                    multipartBuilder.addParam("type", "wall");
                    multipartBuilder.addFile("Filedata", mAttachMusicFile, new File(mAttachMusicFile));
                }

                if (mAttachType.equals("link")) {
                    if (!mUriText.contains("https://") && !mUriText.contains("http://")) {
                        mUriText = "https://" + mUriText;
                    }
                    multipartBuilder.addParam("uri", mUriText);
                }
            }

            // Adding Image files into entity.
            if (mSelectPath != null && !mSelectPath.isEmpty()) {
                for (int i = 0; i < mSelectPath.size(); i++) {
                    LogUtils.LOGD(UploadFileToServerUtils.class.getSimpleName(), "Image Url: " + mSelectPath.get(i));
                    String key = "photo" + i;
                    if (i == 0) {
                        key = "photo";
                    }
                    multipartBuilder.addFile(key, mSelectPath.get(i), new File(mSelectPath.get(i)));
                }
            }

            multipartBuilder
                    .url(mPostUrl)
                    .build()
                    .execute(this);

        } catch (Exception ex) {
            ex.printStackTrace();
        }

    }


    @Override
    public void inProgress(float progress, long total, Object tag) {
        int uploadProgress = Math.round(100 * progress);
        if (mIsNeedToShowDialog && mProgressDialog != null) {
            mProgressDialog.setProgress(uploadProgress);
        }

        super.inProgress(progress, total, tag);
    }

    @Override
    public void onError(Call call, Exception e, Object tag) {
        if (mIsNeedToShowDialog && mProgressDialog != null && !((Activity) mContext).isFinishing()) {
            mProgressDialog.dismiss();
        }
        LogUtils.LOGD(UploadFileToServerUtils.class.getSimpleName(), "onError: " + e);
        onErrorMessage();
    }

    private void onErrorMessage() {
        if (mOnUploadResponseListener != null) {
            mOnUploadResponseListener.onUploadResponse(GlobalFunctions.getErrorJsonString(mContext),
                    false);
        } else if (mOnCommentPostListener != null) {
            mOnCommentPostListener.onCommentPost(GlobalFunctions.getErrorJsonString(mContext),
                    false, mCommentList);
        } else if (mCaller != null) {
            mCaller.onAsyncSuccessResponse(GlobalFunctions.getErrorJsonString(mContext),
                    false, mIsAttachFileRequest);
        }
    }

    @Override
    public void onResponse(String response, Object tag) {
        LogUtils.LOGD(UploadFileToServerUtils.class.getSimpleName(), "Response: " + response);

        if (mIsNeedToShowDialog && mProgressDialog != null && !((Activity) mContext).isFinishing()) {
            mProgressDialog.dismiss();
        }
        try {
            if ((mIsDataUploadRequest || mIsAttachFileRequest) && GlobalFunctions.isValidJson(response)) {
                mResponseObject = new JSONObject(response);

                int responseStatusCode = mResponseObject.optInt("status_code");
                switch (responseStatusCode) {
                    case 400:
                        if (mOnUploadResponseListener != null) {
                            mResponseObject.put("showValidation", true);
                            mOnUploadResponseListener.onUploadResponse(mResponseObject, false);
                        }
                        mIsError = true;
                        break;

                    case 404:
                    case 401:
                    case 500:
                        mIsError = true;
                        break;

                    default:
                        mIsError = false;

                }
            }

            if (BitmapUtils.isImageRotated) {
                BitmapUtils.deleteImageFolder();
            }

            if (!mIsError) {
                JSONObject obj = new JSONObject(response);
                int statusCode = obj.optInt("status_code");

                if (mOnUploadResponseListener != null) {
                    mOnUploadResponseListener.onUploadResponse(obj,
                            AppConstant.isRequestSuccessful(statusCode));
                } else if (mOnCommentPostListener != null) {
                    mOnCommentPostListener.onCommentPost(obj, AppConstant.isRequestSuccessful(statusCode), mCommentList);
                } else if (mCaller != null) {
                    mCaller.onAsyncSuccessResponse(obj,
                            AppConstant.isRequestSuccessful(statusCode), mIsAttachFileRequest);
                }
            } else if (mResponseObject != null && !mResponseObject.has("showValidation")) {
                if (mOnUploadResponseListener != null) {
                    mOnUploadResponseListener.onUploadResponse(mResponseObject, false);
                }
            } else if (response.contains("OutOfMemoryError")) {
                if (mOnUploadResponseListener != null) {
                    mOnUploadResponseListener.onUploadResponse(GlobalFunctions.getErrorJsonString(mContext.getResources().getString(R.string.large_size_file_error_message)),
                            false);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            onErrorMessage();
        }

    }

    /**
     * Method to return attach params.
     *
     * @param postParams Post params in which attach params will be added.
     * @param attachType Type of attachment.
     * @param uriText    Link attachment uri.
     * @param songId     Music attachment id.
     * @param videoId    Video attachment id.
     * @return Returns the post params with attachment info.
     */
    public static Map<String, String> getAttachmentPostParams(Map<String, String> postParams,
                                                              String attachType, String uriText,
                                                              int songId, int videoId) {
        postParams.put("type", attachType);
        postParams.put("post_attach", "1");
        switch (attachType) {
            case "music":
                postParams.put("song_id", String.valueOf(songId));
                break;
            case "link":
                if (!uriText.contains("https://") && !uriText.contains("http://")) {
                    uriText = "https://" + uriText;
                }
                postParams.put("uri", uriText);
                break;
            case "video":
                postParams.put("video_id", String.valueOf(videoId));
                break;
        }
        return postParams;
    }

    /**
     * Method to return attach params.
     *
     * @param postParams  Post params in which attach params will be added.
     * @param attachType  Type of attachment.
     * @param uriText     Link attachment uri.
     * @param stickerGuid Sticker Guid.
     * @param songId      Music attachment id.
     * @param videoId     Video attachment id.
     * @return Returns the post params with attachment info.
     */
    public static HashMap<String, String> getAttachmentPostParams(HashMap<String, String> postParams,
                                                                  String attachType, String uriText,
                                                                  String stickerGuid, String stickerImage,
                                                                  int songId, int videoId, JSONObject sellSomethingValues,
                                                                  JSONObject body) {
        postParams.put("type", attachType);
        postParams.put("post_attach", "1");
        switch (attachType) {
            case "music":
                postParams.put("song_id", String.valueOf(songId));
                break;
            case "link":
                postParams.put("linkInfo", body.toString());
                break;
            case "video":
                postParams.put("video_id", String.valueOf(videoId));
                break;
            case "sticker":
                postParams.put("sticker_guid", stickerGuid);
                postParams.put("thumb", stickerImage);
                break;
            case "sell":
                if (sellSomethingValues != null && sellSomethingValues.length() > 0) {
                    Iterator<String> keySet = sellSomethingValues.keys();
                    while (keySet.hasNext()) {
                        String key = keySet.next();
                        if (!key.equals("photo")) {
                            postParams.put(key, sellSomethingValues.optString(key));
                        }
                    }
                }
                break;
        }
        return postParams;
    }
}
