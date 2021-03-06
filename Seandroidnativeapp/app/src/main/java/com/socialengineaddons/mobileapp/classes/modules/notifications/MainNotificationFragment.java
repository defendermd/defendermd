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

package com.socialengineaddons.mobileapp.classes.modules.notifications;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;

import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.WebViewActivity;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.SingleFeedPage;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.modules.advancedVideos.AdvVideoUtil;
import com.socialengineaddons.mobileapp.classes.modules.likeNComment.Comment;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoLightBoxActivity;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 */
public class MainNotificationFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener{

    private View rootView;
    private Context mContext;
    private SwipeRefreshLayout swipeRefreshLayout;
    private RecyclerView mRecyclerView;
    private RecyclerView.LayoutManager mLayoutManager;
    private RecyclerView.Adapter mNotificationViewAdapter;
    private AppConstant mAppConst;
    private List mDeletedModulesList;
    private List<Object> mBrowseItemList;
    private BrowseListItems mBrowseList;
    private HashMap<String, String> postParams;
    private int pageNumber = 1, mNotificationId, mCurrentUserId, mObjectId, mSubjectId, isRead;
    private String mNotificationRequestUrl;
    private boolean isLoading=false;
    private String mSubjectType, mObjectType;
    private String mViewForumTopicPageTitle, mViewForumTopicPageSlug;
    private JSONObject mBody,mSubjectResponse, mObjectResponse, mNotificationObject;
    private JSONArray mRecentUpdatedItemArray, mActionBodyParamsArray;
    private String mNotificationType, mActionTypeBody, mFeedTitle, mNotificationUrl;
    private int mTotalUpdatedItemCount ;
    private Snackbar snackbar;
    private AlertDialogWithAction mAlertDialogWithAction;


    public MainNotificationFragment() {
        // Required empty public constructor
    }

    public static MainNotificationFragment newInstance(Bundle bundle) {
        // Required  public constructor
        MainNotificationFragment fragment = new MainNotificationFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = getActivity();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        mBrowseItemList = new ArrayList<>();
        mBrowseList = new BrowseListItems();
        postParams = new HashMap<>();

        mAppConst = new AppConstant(getActivity());
        mDeletedModulesList = Arrays.asList(ConstantVariables.DELETED_MODULES);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);

        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.recycler_view_layout, null);

        mRecyclerView = (RecyclerView) rootView.findViewById(R.id.recycler_view);
        mRecyclerView.setHasFixedSize(true);

        mLayoutManager = new LinearLayoutManager(getActivity());
        mRecyclerView.setLayoutManager(mLayoutManager);


        swipeRefreshLayout = (SwipeRefreshLayout) rootView.findViewById(R.id.swipe_refresh_layout);
        swipeRefreshLayout.setOnRefreshListener(this);
        swipeRefreshLayout.setColorSchemeResources(R.color.colorAccent);

        mNotificationRequestUrl = UrlUtil.MAIN_NOTIFICATION_URL + "&page=" + pageNumber;

        mNotificationViewAdapter = new NotificationViewAdapter(getActivity(), mBrowseItemList,false,
                new NotificationViewAdapter.OnItemClickListener() {
                    BrowseListItems listItems;
                    int id;
                    @Override
                    public void onItemClick(View view, int position) {

                        listItems = (BrowseListItems) mBrowseItemList.get(position);
                        /*
                        Send request to server if unread notification is being read to update read/unread flag
                         */
                        if(listItems.getIsRead() == 0){
                            view.setBackground(ContextCompat.getDrawable(mContext,
                                    R.drawable.selectable_background_white));
                            String messageReadUrl = UrlUtil.NOTIFICATION_READ_URL;
                            postParams.put("action_id", String.valueOf(listItems.getNotificationId()));
                            mAppConst.postJsonResponseForUrl(messageReadUrl, postParams,
                                    new OnResponseListener() {
                                        @Override
                                        public void onTaskCompleted(JSONObject jsonObject)
                                                throws JSONException {
                                            listItems.setIsRead(1);
                                            mNotificationViewAdapter.notifyDataSetChanged();
                                        }

                                        @Override
                                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                            SnackbarUtils.displaySnackbar(rootView, message);
                                        }
                                    });
                        }

                        JSONObject jsonObject;
                        String type;

                        switch (listItems.getNotificationType()) {
                            case "friend_accepted":
                            case "siteverify_new":
                                jsonObject = listItems.getSubjectResponse();
                                type = listItems.getNotificationSubjectType();
                                break;

                            case "admin_post_android":
                                jsonObject = listItems.getObjectResponse();
                                type = listItems.getNotificationType();
                                break;

                            default:
                                jsonObject = listItems.getObjectResponse();
                                type = listItems.getNotificationObjectType();
                                break;
                        }

                        id = GlobalFunctions.getIdOfModule(jsonObject, type);

                        if (listItems.getNotificationObjectType().equals("forum_topic")) {
                            mViewForumTopicPageTitle = jsonObject.optString("title");
                            mViewForumTopicPageSlug = jsonObject.optString("slug");
                        }

                        // If its live stream notification.
                        if (listItems.getNotificationType().equals(ConstantVariables.LIVE_STREAM_TYPE)) {
                            JSONObject paramsObject = listItems.getParamsObject();
                            GlobalFunctions.openLiveStreamActivity(mContext, paramsObject.optString("stream_name"),
                                    paramsObject.optString("main_subject_type"), paramsObject.optInt("main_subject_id"));
                        } else {
                            startNewActivity(type, id, listItems, jsonObject);
                        }

                    }

                    @Override
                    public void onProfilePictureClicked(View view, int position) {
                        listItems = (BrowseListItems) mBrowseItemList.get(position);
                        id = GlobalFunctions.getIdOfModule(listItems.getSubjectResponse(),
                                listItems.getNotificationSubjectType());
                        startNewActivity(listItems.getNotificationSubjectType(), id, listItems, null);
                    }


                    @Override
                    public void onOptionSelected(View v, BrowseListItems listItems, int position) {

                    }


                });

        mRecyclerView.setAdapter(mNotificationViewAdapter);


        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);

                final LinearLayoutManager linearLayoutManager = (LinearLayoutManager) mRecyclerView
                        .getLayoutManager();
                int firstVisibleItem = linearLayoutManager.findFirstVisibleItemPosition();
                int totalItemCount = linearLayoutManager.getItemCount();
                int lastVisibleCount = linearLayoutManager.findLastVisibleItemPosition() + 1;
                int visibleItemCount = lastVisibleCount - firstVisibleItem;

                int limit = firstVisibleItem + visibleItemCount;

                if (limit == totalItemCount && !isLoading) {

                    if (limit >= AppConstant.LIMIT && (AppConstant.LIMIT * pageNumber)
                            < mBrowseList.getmTotalItemCount()) {

                        pageNumber = pageNumber + 1;
                        String url = UrlUtil.MAIN_NOTIFICATION_URL + "&page=" + pageNumber;
                        isLoading = true;
                        loadMoreData(url);
                    }

                }
            }
        });

        makeRequest();
        return rootView;
    }

    public void startNewActivity(String type, int id, BrowseListItems customList, JSONObject jsonObject){

        Intent viewIntent;

        switch (type) {
            case "user":
                viewIntent = new Intent(mContext, userProfile.class);
                viewIntent.putExtra("user_id", id);
                getActivity().startActivityForResult(viewIntent, ConstantVariables.USER_PROFILE_CODE);
                getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case ConstantVariables.VIDEO_TITLE:
            case ConstantVariables.MLT_VIDEO_MENU_TITLE:
            case ConstantVariables.ADV_EVENT_VIDEO_MENU_TITLE:
            case ConstantVariables.ADV_GROUPS_VIDEO_MENU_TITLE:
            case ConstantVariables.SITE_STORE_VIDEO_MENU_TITLE:
            case ConstantVariables.PRODUCT_VIDEO_MENU_TITLE:
                List<String> enabledModuleList = null;
                if (PreferencesUtils.getEnabledModuleList(mContext) != null) {
                    enabledModuleList = new ArrayList<>(Arrays.asList(PreferencesUtils.getEnabledModuleList(mContext).split("\",\"")));
                }

                if (enabledModuleList != null && enabledModuleList.contains("sitevideo")
                        && !mDeletedModulesList.contains("core_main_sitevideo") && type.equals("video")) {
                    viewIntent = AdvVideoUtil.getViewPageIntent(mContext, id, jsonObject.optString("video_url"),
                            new Bundle());
                } else {
                    viewIntent = GlobalFunctions.getIntentForModule(mContext, id, type, mViewForumTopicPageSlug);

                    viewIntent.putExtra(ConstantVariables.VIDEO_TYPE,
                            customList.getObjectResponse().optInt("type"));
                    viewIntent.putExtra(ConstantVariables.VIDEO_URL,
                            customList.getObjectResponse().optString("video_url"));
                    if (!type.equals("video")) {
                        viewIntent = GlobalFunctions.setIntentParamForVideo(type, jsonObject, id, viewIntent);
                    }
                }
                if (viewIntent != null) {
                    startActivity(viewIntent);
                    getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                }
                break;

            case "activity_action":
            case "activity_comment":
                int action_id;

                if (type.equals("activity_comment") && customList.getObjectResponse() != null
                        && customList.getObjectResponse().length() > 0) {
                    action_id = customList.getObjectResponse().optInt("resource_id");
                } else {
                    action_id = customList.getNotificationObjectId();
                }

                viewIntent = new Intent(mContext, SingleFeedPage.class);
                if (type.equals("activity_action") && jsonObject.optInt("attachment_count") > 1) {
                    viewIntent.putExtra("isFromNotifications", true);
                }

                viewIntent.putExtra(ConstantVariables.ACTION_ID, action_id);
                startActivity(viewIntent);
                getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case "core_comment":
                viewIntent = new Intent(mContext, Comment.class);
                viewIntent.putExtra(ConstantVariables.SUBJECT_TYPE, jsonObject.optString("resource_type"));
                viewIntent.putExtra(ConstantVariables.SUBJECT_ID, jsonObject.optInt("resource_id"));
                startActivity(viewIntent);
                getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case "forum_topic":
                viewIntent = GlobalFunctions.getIntentForModule(mContext, id, type, mViewForumTopicPageSlug);
                viewIntent.putExtra(ConstantVariables.CONTENT_TITLE, mViewForumTopicPageTitle);
                startActivity(viewIntent);
                getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case "admin_post_android":
                JSONObject paramObject = jsonObject.optJSONObject("params");
                if (paramObject != null && paramObject.length() > 0) {
                    mAlertDialogWithAction.showPushNotificationAlertDialog(paramObject.optString("title"),
                            paramObject.optString("message"));
                }
                break;

            case ConstantVariables.ALBUM_PHOTO_MENU_TITLE:
                ArrayList<PhotoListDetails> mPhotoDetails = new ArrayList<>();
                if (jsonObject != null) {
                    int photoId = jsonObject.optInt("photo_id");
                    int albumId = jsonObject.optInt("album_id");
                    String image = jsonObject.optString("image_profile");
                    int likesCount = jsonObject.optInt("like_count");
                    int commentCount = jsonObject.optInt("comment_count");
                    int is_like = jsonObject.optInt("is_like");
                    String reactions = jsonObject.optString("reactions");
                    String mUserTagArray = jsonObject.optString("tags");
                    final String menuArray = jsonObject.optString("menu");

                    boolean likeStatus = is_like != 0;

                    String albumViewUrl = UrlUtil.ALBUM_VIEW_PAGE + albumId + "?gutter_menu=1";

                    mPhotoDetails.add(new PhotoListDetails(photoId, image,
                            likesCount, commentCount, mUserTagArray, likeStatus, reactions));
                    openPhotoLightBox(mPhotoDetails, albumViewUrl, albumId);
                }

                break;

            default:
                viewIntent = GlobalFunctions.getIntentForModule(mContext, id, type, null);
                if (viewIntent != null && !Arrays.asList(ConstantVariables.DELETED_MODULES).contains(type)) {

                    if (type.equals("sitereview_listing") || type.equals("sitereview_review")) {
                        viewIntent.putExtra(ConstantVariables.LISTING_TYPE_ID, jsonObject.optInt("listingtype_id"));
                    } else if (type.equals("sitereview_wishlist")) {
                        viewIntent.putExtra(ConstantVariables.CONTENT_TITLE, jsonObject.optString("title"));
                    }

                    startActivityForResult(viewIntent, ConstantVariables.VIEW_PAGE_CODE);
                    getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                } else {
                    if(customList.getmNotificationUrl() != null && !customList.getmNotificationUrl().isEmpty()) {
                        Intent webViewActivity = new Intent(mContext, WebViewActivity.class);
                        webViewActivity.putExtra("headerText", customList.getNotificationObject().
                                optString("title"));
                        webViewActivity.putExtra("url", customList.getmNotificationUrl());
                        startActivity(webViewActivity);
                        getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                }
        }

    }

    public void makeRequest() {

        pageNumber = 1;
        mAppConst.getJsonResponseFromUrl(mNotificationRequestUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject)
                    throws JSONException {
                mBrowseItemList.clear();
                rootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                GlobalFunctions.updateBadgeCount(mContext, false);
                if(snackbar != null && snackbar.isShown()) {
                    snackbar.dismiss();
                }

                addNotificationToTheList(jsonObject);
                mNotificationViewAdapter.notifyDataSetChanged();
                if(mBrowseItemList.size() == 0){
                    rootView.findViewById(R.id.message_layout).setVisibility(View.VISIBLE);
                    TextView errorIcon = (TextView) rootView.findViewById(R.id.error_icon);
                    SelectableTextView errorMessage = (SelectableTextView) rootView.findViewById(R.id.error_message);
                    errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
                    errorIcon.setText("\uf0f3");
                    errorMessage.setText(mContext.getResources().getString(R.string.no_notifications));
                }
                if (swipeRefreshLayout.isRefreshing()) {
                    swipeRefreshLayout.setRefreshing(false);
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                rootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                if(swipeRefreshLayout.isRefreshing()) {
                    swipeRefreshLayout.setRefreshing(false);
                }
                if (isRetryOption) {
                    snackbar = SnackbarUtils.displaySnackbarWithAction(getActivity(), ((Activity)mContext).findViewById(android.R.id.content), message,
                            new SnackbarUtils.OnSnackbarActionClickListener() {
                                @Override
                                public void onSnackbarActionClick() {
                                    rootView.findViewById(R.id.progressBar).setVisibility(View.VISIBLE);
                                    makeRequest();
                                }
                            });
                } else {
                    SnackbarUtils.displaySnackbar(rootView, message);
                }
            }
        });
    }

    private void loadMoreData(String url){

        //add null , so the adapter will check view_type and show progress bar at bottom
        mBrowseItemList.add("progress");
        mNotificationViewAdapter.notifyItemInserted(mBrowseItemList.size() - 1);

        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                //   remove progress item
                mBrowseItemList.remove(mBrowseItemList.size() - 1);
                mNotificationViewAdapter.notifyItemRemoved(mBrowseItemList.size());

                addNotificationToTheList(jsonObject);
                mNotificationViewAdapter.notifyItemInserted(mBrowseItemList.size());
                isLoading = false;
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                SnackbarUtils.displaySnackbar(rootView, message);
            }
        });
    }
    public void addNotificationToTheList(JSONObject jsonObject){
        mBody = jsonObject;

        mTotalUpdatedItemCount = mBody.optInt("recentUpdateTotalItemCount");
        mBrowseList.setmTotalItemCount(mTotalUpdatedItemCount);
        if(mTotalUpdatedItemCount != 0){
            rootView.findViewById(R.id.message_layout).setVisibility(View.GONE);
            mRecentUpdatedItemArray = mBody.optJSONArray("recentUpdates");
            for(int i = 0;i<mRecentUpdatedItemArray.length();i++){
                mNotificationObject = mRecentUpdatedItemArray.optJSONObject(i);
                mNotificationId = mNotificationObject.optInt("notification_id");
                mCurrentUserId = mNotificationObject.optInt("user_id");
                mSubjectId = mNotificationObject.optInt(ConstantVariables.SUBJECT_ID);
                isRead = mNotificationObject.optInt("read");
                mObjectId = mNotificationObject.optInt("object_id");
                mSubjectType = mNotificationObject.optString(ConstantVariables.SUBJECT_TYPE);
                mObjectType = mNotificationObject.optString("object_type");
                mActionTypeBody = mNotificationObject.optString("action_type_body");
                mFeedTitle = mNotificationObject.optString("feed_title");
                mNotificationType = mNotificationObject.optString("type");
                mNotificationUrl = mNotificationObject.optString("url");
                mSubjectResponse = mNotificationObject.optJSONObject("subject");
                mObjectResponse = mNotificationObject.optJSONObject("object");
                JSONObject param = mNotificationObject.optJSONObject("params");
                mActionBodyParamsArray = mNotificationObject.optJSONArray("action_type_body_params");
                mBrowseItemList.add(new BrowseListItems(mNotificationId, mCurrentUserId, mSubjectId,
                        mObjectId, isRead, mSubjectType, mObjectType, mNotificationObject,
                        mActionTypeBody, mFeedTitle, mNotificationType,mNotificationUrl, mSubjectResponse,
                        mObjectResponse, mActionBodyParamsArray, param));

            }
        }else {
            rootView.findViewById(R.id.message_layout).setVisibility(View.VISIBLE);
            TextView errorIcon = (TextView) rootView.findViewById(R.id.error_icon);
            TextView errorMessage = (TextView) rootView.findViewById(R.id.error_message);
            errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            errorIcon.setText("\uf0f3");
            errorMessage.setText(mContext.getResources().getString(R.string.no_notifications));
        }

    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mAppConst.hideKeyboard();

    }


    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (!isVisible() && snackbar != null && snackbar.isShown()) {
            snackbar.dismiss();
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mContext = context;
        if(mRecyclerView != null){
            mRecyclerView.smoothScrollToPosition(0);
        }
    }

    @Override
    public void onRefresh() {
        /**
         * Showing Swipe Refresh animation on activity create
         * As animation won't start on onCreate, post runnable is used
         */
        swipeRefreshLayout.post(new Runnable() {
            @Override
            public void run() {
                swipeRefreshLayout.setRefreshing(true);
                makeRequest();
            }
        });
    }

    private void openPhotoLightBox(ArrayList<PhotoListDetails> mFeedPhotoDetails, String albumUrl, int albumId){

        Bundle bundle = new Bundle();
        bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mFeedPhotoDetails);
        Intent i = new Intent(mContext, PhotoLightBoxActivity.class);
        i.putExtra(ConstantVariables.SUBJECT_TYPE, "album_photo");
        i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, 1);
        i.putExtra(ConstantVariables.SHOW_ALBUM_BUTTON,true);
        i.putExtra(ConstantVariables.PHOTO_REQUEST_URL, albumUrl);
        i.putExtra(ConstantVariables.ALBUM_ID, albumId);
        i.putExtras(bundle);
        startActivity(i);
    }


}
