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

package com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds;


import android.Manifest;
import android.app.Activity;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SimpleItemAnimator;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.work.Data;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;

import com.facebook.ads.AdError;
import com.facebook.ads.NativeAd;
import com.facebook.ads.NativeAdsManager;
import com.facebook.shimmer.ShimmerFrameLayout;
import com.google.android.gms.ads.formats.NativeAppInstallAd;
import com.google.android.gms.tasks.Tasks;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.VideoLightBox;
import com.socialengineaddons.mobileapp.classes.common.adapters.FeedAdapter;
import com.socialengineaddons.mobileapp.classes.common.ads.admob.AdFetcher;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnAsyncResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommunityAdsLoadedListnerFeeds;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnFeedPostListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnFilterSelectedListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnGifPlayListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnPinPostListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.CommunityAdsList;
import com.socialengineaddons.mobileapp.classes.common.utils.DataStorage;
import com.socialengineaddons.mobileapp.classes.common.utils.DownloadWorker;
import com.socialengineaddons.mobileapp.classes.common.utils.FeedList;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.OkHttpUploadHandler;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.SponsoredStoriesList;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.core.MainActivity;
import com.socialengineaddons.mobileapp.classes.modules.advancedVideos.AdvVideoView;
import com.socialengineaddons.mobileapp.classes.modules.autoplayvideo.Utils;
import com.socialengineaddons.mobileapp.classes.modules.story.StoryUtils;
import com.socialengineaddons.mobileapp.classes.modules.story.photofilter.PhotoEditActivity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Field;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;


/**
 * A simple {@link Fragment} subclass.
 */
public class FeedsFragment extends BaseFragment implements SwipeRefreshLayout.OnRefreshListener,
        OnFilterSelectedListener, NativeAdsManager.Listener, OnCommunityAdsLoadedListnerFeeds,
        OnPinPostListener, OnAsyncResponseListener, OnGifPlayListener, OnFeedPostListener {


    public static int previewItemPosition = 0;
    int j = 0;

    private Map<Integer, OkHttpUploadHandler> uploadUtilMap = new HashMap<>();
    private String mFeedsUrl;
    private View rootView;
    private Context mContext;
    private AppConstant mAppConst;
    private AdFetcher mAdFetcher;
    private int mMaxFeedId, mMinFeedId, mSubjectId, mPeriod = 60000, mListId;
    public int defaultFeedCount, mAccurateActivityCount, defaultFeedCountTemp;
    private JSONArray mDataJsonArray, mFilterTabsArray, mHashTagArray, mAdvertisementsArray, mGreetingsArray, mBirthdayArray;
    private JSONObject mFeedPostMenu;
    private RelativeLayout mMainContent;
    private SwipeRefreshLayout swipeRefreshLayout;
    private RecyclerView mFeedsRecyclerView;
    private List<Object> mFeedItemsList;
    private FeedAdapter mFeedAdapter;
    private String mFilterType;
    private boolean isLoading = false, isAdLoaded = false, isSuggestionLoaded = false, isCommunityAds = false;
    private RelativeLayout mshowNewUpdateCount;
    private HashMap<String, String> mClickableParts, mClickablePartsNew, mShareClickableParts;
    private HashMap<Integer, String> mVideoInformation;
    private HashMap<String, String> mWordStylingClickableParts;
    private String mSubjectType = "", mModuleName = "", mHashTagString = "";
    private String mActionTypeBody = null;
    private double mLatitude, mLongitude;
    private String mPlaceId, mHashTagValue, mLocationLabel;
    private NativeAdsManager listNativeAdsManager;
    private Intent activityIntent;
    private boolean mIsStatusActivity, mIsStoryRequest, isNewPost = false;
    private boolean isHandlerStopped = false;
    private int mReactionsEnabled, mStickersEnabled, startIndex, endIndex;
    private JSONObject reactions;
    private AlertDialogWithAction mAlertDialogWithAction;
    private JSONObject mBody;
    private LinearLayoutManager layoutManager;
    private boolean isVisibleToUser = false;
    private List<Object> mBrowseListItem = new ArrayList<>();
    private JSONArray otherMembers;
    private int pageNumber = 1, addAtPosition = -1;
    private boolean isFeedUpdate = false;
    private int mGifPosition, muteStoryCount = 0;
    private List<Object> browseItemArrayList;
    private JSONArray usersArray;
    private static boolean isStoryPosted = true;
    private Snackbar snackbar;
    private int playPosition = -1;
    private boolean isResumeVideo = false, isAutoPlayVideo = false;
    private static boolean isPauseFromDrawer = false;
    private boolean isFragmentVisible;
    private boolean downloadVideos = true;
    private int oldPlayPosition = -1;
    private FeedAdapter.ListItemHolder holder;
    private ShimmerFrameLayout mShimmerViewContainer;
    public static long playbackPosition = 0;
    public static int playbackWindow = 0;


    public FeedsFragment() {
        // Required empty public constructor
    }

    @Override
    public void setNestedScrollingEnabled(boolean enabled) {
        if (mFeedsRecyclerView != null) {
            mFeedsRecyclerView.setNestedScrollingEnabled(enabled);
        }
    }

    public static FeedsFragment newInstance(Bundle bundle) {
        isPauseFromDrawer = false;
        // Required  public constructor
        FeedsFragment fragment = new FeedsFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = getActivity();
    }

    @Override
    public void onPrepareOptionsMenu(final Menu menu) {
        super.onPrepareOptionsMenu(menu);
        MenuItem toggle = menu.findItem(R.id.viewToggle);
        if (toggle != null) {
            toggle.setVisible(false);
        }
    }

    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (visible && !isVisibleToUser && mContext != null) {
            getFeeds(mFeedsUrl, false);
        }

        new Handler(Looper.getMainLooper()).post(() -> {
            if (visible) {
                isFragmentVisible = true;
                resumeVideos(false);
            } else {
                pauseVideos(false);
                isFragmentVisible = false;
            }

        });
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        if (outState != null && outState.containsKey(ConstantVariables.IS_CURRENCY_UPDATED)
                && mFeedAdapter != null) {
            mFeedAdapter.notifyDataSetChanged();
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mContext = getActivity();
        mAppConst = new AppConstant(mContext);
        mFeedItemsList = new ArrayList<>();
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        layoutManager = new LinearLayoutManager(mContext);
        usersArray = null;

        mFeedsUrl = UrlUtil.FFEDS_URL;

        boolean bNestedScrollEnabled = true;
        setHasOptionsMenu(true);

        if (getArguments() != null) {
            mSubjectType = getArguments().getString(ConstantVariables.SUBJECT_TYPE);
            mSubjectId = getArguments().getInt(ConstantVariables.SUBJECT_ID, 0);
            mModuleName = getArguments().getString(ConstantVariables.MODULE_NAME);
            mHashTagValue = getArguments().getString("hashtag");
            isNewPost = getArguments().getBoolean("isPosted");
            bNestedScrollEnabled = getArguments().getBoolean(ConstantVariables.SET_NESTED_SCROLLING_ENABLED, true);
            if (mSubjectType != null && mSubjectId != 0) {
                mFeedsUrl += "&subject_type=" + mSubjectType + "&subject_id=" + mSubjectId;
            }

            if (mHashTagValue != null && !mHashTagValue.isEmpty()) {
                isHandlerStopped = true;
                handler.removeCallbacksAndMessages(runnableCode);
                try {
                    mFeedsUrl += "&hashtag=" + URLEncoder.encode(mHashTagValue, "utf-8");
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
            }
        }

        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.recycler_view_layout, container, false);

        mMainContent = (RelativeLayout) rootView.findViewById(R.id.main_view_recycler);
        mMainContent.setBackgroundColor(ContextCompat.getColor(mContext, R.color.gray_progress_bar));

        swipeRefreshLayout = rootView.findViewById(R.id.swipe_refresh_layout);
        mShimmerViewContainer = rootView.findViewById(R.id.shimmer_view_container);
        mShimmerViewContainer.setVisibility(View.VISIBLE);
        mShimmerViewContainer.startShimmer();
        swipeRefreshLayout.setVisibility(View.GONE);
        rootView.findViewById(R.id.progressBar).setVisibility(View.GONE);

        mFeedsRecyclerView = rootView.findViewById(R.id.recycler_view);
        mFeedsRecyclerView.setHasFixedSize(true);
        mFeedsRecyclerView.setNestedScrollingEnabled(bNestedScrollEnabled);
        mFeedsRecyclerView.setLayoutManager(layoutManager);
        mFeedsRecyclerView.setItemAnimator(new DefaultItemAnimator());
        ((SimpleItemAnimator) mFeedsRecyclerView.getItemAnimator()).setSupportsChangeAnimations(false);
        /* Setting Padding and Spacing between Items of recyclerView */
        mFeedsRecyclerView.addItemDecoration(new VerticalSpaceItemDecoration(ConstantVariables.VERTICAL_ITEM_SPACE));
        swipeRefreshLayout.setOnRefreshListener(this);
        swipeRefreshLayout.setColorSchemeResources(R.color.colorAccent);

        /* Set Scrolling on Feeds */
        mFeedsRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {

            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);

                final LinearLayoutManager gridLayoutManager = (LinearLayoutManager) mFeedsRecyclerView
                        .getLayoutManager();
                int firstVisibleItem = gridLayoutManager.findFirstVisibleItemPosition();
                int totalItemCount = gridLayoutManager.getItemCount();
                int lastVisibleCount = gridLayoutManager.findLastVisibleItemPosition() + 1;
                int visibleItemCount = lastVisibleCount - firstVisibleItem;


                if (firstVisibleItem == 0) {
                    isFeedUpdate = false;
                    if (mshowNewUpdateCount != null && mshowNewUpdateCount.getVisibility() == View.VISIBLE) {
                        if (!isFeedUpdate) {
                            String feedsUrl = mFeedsUrl;
                            if (mFilterType != null && !mFilterType.isEmpty()) {
                                feedsUrl += "&filter_type=" + mFilterType + "&list_id=" + mListId;
                            }
                            getFeeds(feedsUrl, true);
                        }
                        isFeedUpdate = false;

                        mshowNewUpdateCount.setVisibility(View.GONE);
                    }
                }

                int limit = firstVisibleItem + visibleItemCount;

                if (limit == totalItemCount && !isLoading) {

                    // Loading more feeds when the limit is greater than or equal to the defaultFeedCount
                    // and the accurate activity count(No. of feeds which needs to come) is >= defaultFeedCount
                    if (limit >= defaultFeedCountTemp && mAccurateActivityCount >= defaultFeedCountTemp) {

                        if (mMaxFeedId != 0) {

                            // Insert an Item for Footer View with null position
                            Tasks.call(new Callable<Void>() {
                                @Override
                                public Void call() throws Exception {
                                    mFeedItemsList.add(null);
                                    mFeedAdapter.notifyItemInserted(mFeedItemsList.size());
                                    return null;
                                }
                            });

                            String feedUrl = UrlUtil.FFEDS_URL;
                            feedUrl += "&limit=" + defaultFeedCount;
                            //When update request contains subject id & type (eg. user profile, group, event).
                            if (mSubjectType != null && mSubjectId != 0) {
                                feedUrl += "&subject_type=" + mSubjectType + "&subject_id=" + mSubjectId;
                            }
                            if (mFilterType != null && !mFilterType.isEmpty()) {
                                feedUrl += "&filter_type=" + mFilterType + "&list_id=" + mListId;
                            }
                            feedUrl += "&maxid=" + mMaxFeedId;
                            isLoading = true;
                            loadMoreFeeds(feedUrl);
                        } else {
                            // Show End Of Results Message
                            mFeedItemsList.add(ConstantVariables.FOOTER_TYPE);
                        }
                    }
                }
            }

            @Override
            public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);

                if (isAutoPlayVideo && !VideoLightBox.isInPictureInPictureMode && !AdvVideoView.isInPictureInPictureMode) {
                    autoPlayVideos(newState, false);
                }

                // For stop playing gif when on scrolling top or bottom
                if (mFeedItemsList.size() > 0 && mGifPosition <= mFeedItemsList.size()) {
                    FeedList mFeedItem = (FeedList) mFeedItemsList.get(mGifPosition);
                    if ((mGifPosition >= layoutManager.findFirstVisibleItemPosition() &&
                            mGifPosition <= layoutManager.findLastVisibleItemPosition()) && !mFeedItem.getIsGifLoad()) {
                        mFeedItem.setIsGifLoad(true);
                        mFeedAdapter.notifyItemChanged(mGifPosition);
                    } else if (mFeedItem.getIsGifLoad()) {
                        mFeedItem.setIsGifLoad(false);
                        mFeedAdapter.notifyItemChanged(mGifPosition);
                        mGifPosition = 0;
                    }
                }
            }
        });

        /* Set fling listener for check the gesture's speed and pause the video*/
        mFeedsRecyclerView.setOnFlingListener(new RecyclerView.OnFlingListener() {
            @Override
            public boolean onFling(int velocityX, int velocityY) {

                if (isAutoPlayVideo) {
                    if (velocityY < 0) {
                        velocityY = -(velocityY);
                    }

                    if ((velocityY > 0 && velocityY > 3800)) {
                        if (oldPlayPosition != -1 && oldPlayPosition != playPosition) {
                            if (holder != null) {
                                holder.pauseVideo(true);
                            }
                        }
                    }
                }
                return false;
            }
        });


        mFeedAdapter = new FeedAdapter(mContext, R.layout.list_feeds, mFeedItemsList, false, null,
                mSubjectType, mSubjectId, mModuleName, -1, false, this);

        mFeedAdapter.setmFilterSelectedListener(FeedsFragment.this);
        mFeedAdapter.setOnGifPlayListener(FeedsFragment.this);
        mFeedsRecyclerView.setAdapter(mFeedAdapter);

        if (mSubjectType != null && !mSubjectType.isEmpty() && mSubjectId != 0) {
            mFeedAdapter.setPinPostListener(this);
        }

        if (ConstantVariables.ENABLE_FEED_ADS == 1) {
            switch (ConstantVariables.FEED_ADS_TYPE) {
                case ConstantVariables.TYPE_FACEBOOK_ADS:
                    //TODO
                    // Enable below line code when checking facebook test ad
//                    AdSettings.addTestDevice("046ab195-7c95-4e4e-b504-19bd56edf901");
                    listNativeAdsManager = new NativeAdsManager(mContext,
                            mContext.getResources().getString(R.string.facebook_placement_id),
                            ConstantVariables.DEFAULT_AD_COUNT);
                    listNativeAdsManager.setListener(this);
                    listNativeAdsManager.loadAds(NativeAd.MediaCacheFlag.ALL);
                    break;
                case ConstantVariables.TYPE_GOOGLE_ADS:
                    mAdFetcher = new AdFetcher(mContext);
                    mAdFetcher.loadAds(mFeedItemsList, mFeedAdapter, ConstantVariables.FEED_ADS_POSITION);
                    break;
                default:
                    //Community Ads
                    isCommunityAds = true;
                    break;
            }
        }


        if ((mSubjectType != null && !mSubjectType.isEmpty() && mSubjectId != 0)) {

            isHandlerStopped = true;
            handler.removeCallbacksAndMessages(runnableCode);
        }

        if (mSubjectType == null || !mSubjectType.equals(ConstantVariables.SITE_VIDEO_CHANNEL_MENU_TITLE))
            getFeeds(mFeedsUrl, false);

        // Kick off the first runnable task right away
        isHandlerStopped = false;
        handler.post(runnableCode);

        return rootView;

    }

    // Create the Handler object (on the main thread by default)
    Handler handler = new Handler();

    // Define the task to be run here
    private Runnable runnableCode = new Runnable() {
        @Override
        public void run() {

            if (!isHandlerStopped) {

                // Get the No of New Feeds
                getFeedCounts();

                // Repeat this runnable code again every 60 seconds
                handler.postDelayed(runnableCode, mPeriod);
            }
        }
    };


    /**
     * Send Request to server and load feeds.
     *
     * @param url          Url to send request on server.
     * @param isRefreshing
     */
    public void getFeeds(String url, final boolean isRefreshing) {
        if (defaultFeedCount != 0) {
            url += "&limit=" + defaultFeedCount;
        }

        getStoryAndPostPrivacy();

        // Do Not Load Data from Caching in case of profile pages.
        if (!isRefreshing && mHashTagValue == null
                && !(mSubjectType != null && !mSubjectType.isEmpty() && mSubjectId != 0)) {
            try {
                if (mFeedItemsList != null) {
                    mFeedItemsList.clear();
                }
                String tempData = DataStorage.getResponseFromLocalStorage(mContext, DataStorage.ACTIVITY_FEED_FILE);
                if (tempData != null) {
                    swipeRefreshLayout.post(new Runnable() {
                        @Override
                        public void run() {
                            swipeRefreshLayout.setRefreshing(true);
                        }
                    });
                    JSONObject jsonObject = new JSONObject(tempData);

                    if (jsonObject.length() != 0) {
                        addHeader(jsonObject, true);
                        addDataToList(jsonObject, true);
                        if (isNewPost) {
                            scrollToTop(0);
                        }
                    }
                } else {
                    // Show Welcome userName when feeds are getting loaded at the first time.
                    if (PreferencesUtils.getUserDetail(mContext) != null) {
                        try {
                            JSONObject userDetail = new JSONObject(PreferencesUtils.getUserDetail(mContext));
                            String displayName = userDetail.getString("displayname");

                            Toast.makeText(mContext, String.format(mContext.getResources().
                                            getString(R.string.welcome_user_text),
                                    mContext.getResources().getString(R.string.welcomeText), displayName), Toast.LENGTH_LONG).show();

                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                }
            } catch (NullPointerException | JSONException e) {
                e.printStackTrace();
            }
        }

        // Send Request to server
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                isVisibleToUser = true;
                if (mFeedItemsList != null) {
                    mFeedItemsList.clear();
                }
                mFeedAdapter.clearLists();

                if (jsonObject != null && jsonObject.length() != 0) {
                    mBody = jsonObject;

                    mMinFeedId = jsonObject.optInt("minid");
                    mMaxFeedId = jsonObject.optInt("maxid");
                    defaultFeedCountTemp = defaultFeedCount = jsonObject.optInt("defaultFeedCount");
                    mAccurateActivityCount = jsonObject.optInt("accurateActivityCount");

                    addHeader(jsonObject, false);
                    addDataToList(jsonObject, false);
                    if (isCommunityAds) {
                        mAppConst.getCommunityAds(ConstantVariables.FEED_ADS_POSITION,
                                ConstantVariables.FEED_ADS_TYPE, jsonObject, new OnCommunityAdsLoadedListnerFeeds() {
                                    @Override
                                    public void onCommunityAdsLoaded(JSONArray advertisementsArray, JSONObject jsonObject) {
                                        mAdvertisementsArray = advertisementsArray;
                                        isLoading = false;
                                        if (!isAdLoaded && mAdvertisementsArray != null) {
                                            isAdLoaded = true;
                                            int j = 0;
                                            for (int i = 0; i <= mFeedItemsList.size(); i++) {
                                                if (i != 0 && i % ConstantVariables.FEED_ADS_POSITION == 0 &&
                                                        j < mAdvertisementsArray.length()) {
                                                    if (ConstantVariables.FEED_ADS_TYPE == ConstantVariables.TYPE_COMMUNITY_ADS) {
                                                        mFeedItemsList.add(i, addCommunityAddsToList(j));
                                                    } else {
                                                        mFeedItemsList.add(i, addSponsoredStoriesToList(j));
                                                    }
                                                    j++;
                                                    mFeedAdapter.notifyDataSetChanged();
                                                }
                                            }
                                        } else {
                                            if (pageNumber > 1) {
                                                if (mFeedItemsList != null && mFeedItemsList.size() != 0) {
                                                    mFeedItemsList.remove(mFeedItemsList.size() - 1);
                                                    mFeedAdapter.notifyItemRemoved(mFeedItemsList.size());
                                                }
                                                addDataToList(jsonObject, false);
                                            }
                                        }
                                    }
                                });
                    }

                    // Do not save data in caching in case of profile pages.
                    if ((mSubjectType == null || mSubjectType.isEmpty())
                            && mSubjectId == 0 && mHashTagValue == null) {
                        DataStorage.createTempFile(mContext, DataStorage.ACTIVITY_FEED_FILE, jsonObject.toString());
                    }
                }

                if (swipeRefreshLayout != null)
                    swipeRefreshLayout.setRefreshing(false);


                // playing sound effect when post is posted and sound option is enabled.
                if (getArguments() != null && getArguments().containsKey("isPosted")) {
                    if (mFeedsRecyclerView != null && isNewPost) {
                        isNewPost = false;
                        scrollToTop(1);
                    }
                    if (PreferencesUtils.isSoundEffectEnabled(mContext) && !isRefreshing) {
                        SoundUtil.playSoundEffectOnPost(mContext);
                    }
                }

            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mShimmerViewContainer.stopShimmer();
                if (swipeRefreshLayout.isRefreshing()) {
                    swipeRefreshLayout.setRefreshing(false);
                }
                if (isRetryOption) {
                    snackbar = SnackbarUtils.displaySnackbarWithAction(getActivity(), rootView, message,
                            new SnackbarUtils.OnSnackbarActionClickListener() {
                                @Override
                                public void onSnackbarActionClick() {
                                    mShimmerViewContainer.startShimmer();
                                    String feedsUrl = mFeedsUrl;
                                    if (mFilterType != null && !mFilterType.isEmpty()) {
                                        feedsUrl += "&filter_type=" + mFilterType + "&list_id=" + mListId;
                                    }
                                    getFeeds(feedsUrl, false);
                                }
                            });
                } else {
                    SnackbarUtils.displaySnackbar(rootView, message);
                }

            }
        });
    }

    /**
     * Method to get privacy options and store them in preferences.
     */
    private void getStoryAndPostPrivacy() {
        if (mAppConst == null) {
            mAppConst = new AppConstant(getActivity());
        }
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/feeds/feed-post-menus",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) {
                        if (jsonObject != null && jsonObject.optJSONObject("feed_post_menu") != null) {
                            PreferencesUtils.setStatusPrivacyOptions(mContext, jsonObject.optJSONObject("feed_post_menu"));
                        }
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });

        if (isDisplayStories()) {
            mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/stories/create",
                    new OnResponseListener() {
                        @Override
                        public void onTaskCompleted(JSONObject jsonObject) {
                            if (jsonObject != null && jsonObject.optJSONArray("response") != null) {
                                for (int i = 0; i < jsonObject.optJSONArray("response").length(); i++) {
                                    if (jsonObject.optJSONArray("response").optJSONObject(i).optString("name").equals("privacy")) {
                                        JSONObject privacy = jsonObject.optJSONArray("response").optJSONObject(i).optJSONObject("multiOptions");
                                        PreferencesUtils.setStoryPrivacy(mContext, privacy);
                                    }
                                }
                            }
                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                        }
                    });
        }
    }

    private CommunityAdsList addCommunityAddsToList(int j) {

        JSONObject singleAdObject = mAdvertisementsArray.optJSONObject(j);
        int adId = singleAdObject.optInt("userad_id");
        String ad_type = singleAdObject.optString("ad_type");
        String cads_title = singleAdObject.optString("cads_title");
        String cads_body = singleAdObject.optString("cads_body");
        String cads_url = singleAdObject.optString("cads_url");
        String image = singleAdObject.optString("image");
        return new CommunityAdsList(adId, ad_type, cads_title, cads_body,
                cads_url, image);
    }

    private SponsoredStoriesList addSponsoredStoriesToList(int j) {

        JSONObject singleAdObject = mAdvertisementsArray.optJSONObject(j);
        int adId = singleAdObject.optInt("ad_id");
        int resourceId = singleAdObject.optInt("resource_id");
        String resourceType = singleAdObject.optString("resource_type");
        String resourceTitle = singleAdObject.optString("resource_title");
        JSONArray likes = singleAdObject.optJSONArray("likes");
        String contentUrl = singleAdObject.optString("content_url");
        String image = singleAdObject.optString("image");
        int isLike = singleAdObject.optInt("isLike");
        String moduleTitle = singleAdObject.optString("module_title");
        int likeCount = singleAdObject.optInt("like_count");
        return new SponsoredStoriesList(adId, resourceId, resourceType, resourceTitle, likes,
                contentUrl, image, isLike, moduleTitle, likeCount);
    }

    /**
     * Return Title of the feed.
     *
     * @param actionTypeBody       String which contains objects of feed title
     * @param actionTypeBodyParams Array by which we replace the strings in actionTypeBody
     * @param tagsJsonArray        Friends Tag Array
     * @param wordStyleArray       Word styling Array
     * @param paramsJsonObject     Location Tag Info
     * @param feelingObject        Feeling Object.
     * @param isTranslation        Is word translation
     * @param attachmentArray      Feeds Attachment array
     */

    public String getActionBody(String actionTypeBody, JSONArray actionTypeBodyParams,
                                JSONArray tagsJsonArray, JSONArray wordStyleArray, JSONObject paramsJsonObject,
                                JSONObject feelingObject, String isTranslation, JSONArray attachmentArray,
                                JSONArray userTagJsonArray, boolean isShareFeed) {

        mClickableParts = new HashMap<>();
        mVideoInformation = new HashMap<>();
        if (isShareFeed) {
            mShareClickableParts = new HashMap<>();
        }
        int order = 1, id;
        String type, keyForClick, url;

        try {
            otherMembers = null;
            for (int j = 0; j < actionTypeBodyParams.length(); j++) {
                JSONObject actionBodyObject = actionTypeBodyParams.optJSONObject(j);
                String search = actionBodyObject.optString("search");
                String label = actionBodyObject.optString("label");
                id = actionBodyObject.optInt("id");
                type = actionBodyObject.optString("type");
                url = actionBodyObject.optString("url");
                if (actionTypeBody.contains(search)) {

                    switch (search) {
                        case "{item:$product}":
                        case "{item:$subject}":
                        case "{item:$object}":
                        case "{item:$owner}":
                        case "{item:$listing}":
                            keyForClick = order + "-" + type + "-" + id;
                            label = label.replaceAll("\\s+", " ").trim();

                            if (isShareFeed) {
                                if (mShareClickableParts.containsKey(keyForClick)) {
                                    keyForClick += "-" + label;
                                }
                                mShareClickableParts.put(keyForClick, label);
                            } else {
                                if (mClickableParts.containsKey(keyForClick)) {
                                    keyForClick += "-" + label;
                                }
                                mClickableParts.put(keyForClick, label);
                            }

                            if (type.equals("video")) {
                                if (attachmentArray != null && attachmentArray.length() != 0) {
                                    for (int k = 0; k < attachmentArray.length(); k++) {
                                        JSONObject singleAttachmentObject = attachmentArray.optJSONObject(k);
                                        String attachmentType = singleAttachmentObject.optString("attachment_type");
                                        if (attachmentType.equals("video")) {
                                            int attachmentId = singleAttachmentObject.optInt("attachment_id");
                                            String attachment_video_type = singleAttachmentObject.
                                                    optString("attachment_video_type");
                                            String attachment_video_url = singleAttachmentObject.
                                                    optString("attachment_video_url");
                                            String videoInfo = attachment_video_type + "-" + attachment_video_url;

                                            mVideoInformation.put(attachmentId, videoInfo);
                                        }

                                    }
                                }
                            }
                            ++order;

                            actionTypeBody = actionTypeBody.replace(search, "<b>" + label + "</b>");
                            break;

                        case "{body:$body}":
                            mActionTypeBody = label;

                            if (userTagJsonArray != null && userTagJsonArray.length() > 0) {

                                mClickablePartsNew = new HashMap<>();
                                int serial = 1;

                                for (int k = 0; k < userTagJsonArray.length(); k++) {
                                    JSONObject singleTagJsonObject = userTagJsonArray.optJSONObject(k);
                                    String tagType = singleTagJsonObject.optString("type");
                                    int user_id = singleTagJsonObject.optInt("resource_id");
                                    String taggedFriendName = singleTagJsonObject.optString("resource_name");

                                    if (mActionTypeBody.contains(taggedFriendName)) {
                                        keyForClick = serial + "-" + tagType + "-" + user_id;
                                        label = label.replaceAll("\\s+", " ").trim();
                                        if (mClickablePartsNew.containsKey(keyForClick)) {
                                            keyForClick += "-" + taggedFriendName;
                                        }
                                        mClickablePartsNew.put(keyForClick, taggedFriendName);
                                        ++serial;
                                    }
                                }
                            }

                            if (wordStyleArray != null && wordStyleArray.length() > 0) {
                                int counter = 1;

                                mWordStylingClickableParts = new HashMap<>();

                                for (int k = 0; k < wordStyleArray.length(); k++) {
                                    JSONObject wordStyleObject = wordStyleArray.optJSONObject(k);
                                    String wordStyleTitle = wordStyleObject.optString("title");

                                    if (mActionTypeBody.toLowerCase().contains(wordStyleTitle.toLowerCase())) {
                                        keyForClick = String.valueOf(counter);
                                        label = label.replaceAll("\\s+", " ").trim();
                                        if (mWordStylingClickableParts.containsKey(keyForClick)) {
                                            keyForClick += "-" + wordStyleTitle;
                                        }
                                        mWordStylingClickableParts.put(keyForClick, wordStyleObject.toString());

                                        ++counter;
                                    }
                                }
                            }

                            actionTypeBody = actionTypeBody.replace(search, "");

                            // Removing all line breaking from the action type body,
                            // because we are not showing body in feed title,
                            // so if there is any line break in body it will show in feed body.
                            actionTypeBody = actionTypeBody.replaceAll("<br />", "");
                            break;

                        case "{var:$type}":
                            if (isShareFeed) {
                                keyForClick = order + "-" + type + "-" + id;
                                mShareClickableParts.put(keyForClick, label);
                                ++order;
                                actionTypeBody = actionTypeBody.replace(search, "<b>" + label + "</b>");
                            } else {
                                actionTypeBody = actionTypeBody.replace(search, label);
                            }
                            break;

                        case "{item:$object:topic}":
                            String slug = actionBodyObject.optString("slug");
                            keyForClick = order + "-" + type + "-" + id + "-" + slug;

                            mClickableParts.put(keyForClick, mContext.getResources().getString(R.string.topic_text));
                            actionTypeBody = actionTypeBody.replace(search, mContext.getResources().getString(R.string.topic_text));
                            ++order;
                            break;
                        case "{itemParent:$object:forum}":
                            String forumSlug = actionBodyObject.optString("slug");
                            keyForClick = order + "-" + type + "-" + id + "-" + forumSlug;

                            mClickableParts.put(keyForClick, label);
                            actionTypeBody = actionTypeBody.replace(search, label);
                            ++order;
                            break;

                        case "{actors:$subject:$object}":
                            keyForClick = order + "-" + type + "-" + id;
                            label = label.replaceAll("\\s+", " ").trim();
                            mClickableParts.put(keyForClick, label);
                            ++order;

                            JSONObject objectDetails = actionBodyObject.optJSONObject("object");
                            if (objectDetails != null) {
                                String object_type = objectDetails.getString("type");
                                int object_id = objectDetails.getInt("id");
                                String object_label = objectDetails.getString("label");
                                object_label = object_label.replaceAll("\\s+", " ").trim();

                                mClickableParts.put(order + "-" + object_type + "-" + object_id, object_label);
                                ++order;
                                actionTypeBody = actionTypeBody.replace(search, "<b>"
                                        + label + " ??? " + object_label + "</b>");
                            }
                            break;

                        case "{item:$object:challenge}":
                            keyForClick = order + "-" + type + "-" + id;
                            mClickableParts.put(keyForClick, label);
                            ++order;
                            actionTypeBody = actionTypeBody.replace(search, label);

                            break;

                        case "{itemchild:$object:sitepage_album:$child_id}":
                            keyForClick = order + "-" + type + "-" + id;
                            mClickableParts.put(keyForClick, label);
                            ++order;
                            actionTypeBody = actionTypeBody.replace(search, label);
                            break;

                        case "{item:$object:post}":
                            keyForClick = order + "-" + type + "-" + id;
                            mClickableParts.put(keyForClick, label);
                            ++order;
                            actionTypeBody = actionTypeBody.replace(search, "<b>" + label + "</b>");
                            break;
                        case "{others:$otheritems}":
                            otherMembers = actionBodyObject.optJSONArray("groupUser");
                            keyForClick = order + "-" + type + "-" + id + "-otherMembers";
                            mClickableParts.put(keyForClick, label);
                            ++order;
                            actionTypeBody = actionTypeBody.replace(search, "<b>" + label + "</b>");
                            break;
                        default:

                            // Making a part is clickable when it contains the url,
                            // so that if its not integrated then it can be opened in WebView.
                            if (url != null && !url.isEmpty()) {
                                keyForClick = order + "-" + type + "-" + id;
                                if (isShareFeed) {
                                    mShareClickableParts.put(keyForClick, label);
                                } else {
                                    mClickableParts.put(keyForClick, label);
                                }

                                ++order;
                                actionTypeBody = actionTypeBody.replace(search, "<b>" + label + "</b>");
                            } else {
                                actionTypeBody = actionTypeBody.replace(search, label);
                            }
                    }
                }
            }

            // Adding feeling Activity.
            if (feelingObject != null && feelingObject.length() > 0) {
                startIndex = Html.fromHtml(actionTypeBody).length();
                actionTypeBody += isTranslation + "  &nbsp;  " + feelingObject.optString("parenttitle")
                        + " " + feelingObject.optString("childtitle");
                endIndex = Html.fromHtml(actionTypeBody).length();
            }

            // Make Tagged Friends Name Clickable
            if (tagsJsonArray != null && tagsJsonArray.length() != 0) {

                actionTypeBody += " -  <font color=\"#de000000\">" +
                        mContext.getResources().getString(R.string.location_with) + " </font>";

                for (int k = 0; k < tagsJsonArray.length(); k++) {

                    JSONObject singleTagJsonObject = tagsJsonArray.optJSONObject(k);
                    String tagType = singleTagJsonObject.optString("tag_type");
                    JSONObject tagObject = singleTagJsonObject.optJSONObject("tag_obj");
                    int user_id = tagObject.optInt("user_id");
                    String taggedFriendName = tagObject.optString("displayname");

                    if (k == 0) {
                        if (taggedFriendName != null && !taggedFriendName.isEmpty()) {
                            actionTypeBody += "<b>" + taggedFriendName + "</b>";
                            mClickableParts.put(order + "-" + tagType + "-" + user_id, taggedFriendName);
                            ++order;
                        }
                    } else if (k == 1 && tagsJsonArray.length() == 2) {
                        actionTypeBody += " " + mContext.getResources().getString(R.string.and) + "  "
                                + "<b>" + taggedFriendName + "<b>";
                        mClickableParts.put(order + "-" + tagType + "-" + user_id, taggedFriendName);
                        ++order;
                    } else if (k == 2) {
                        id = 0;
                        type = "tagged_users_list";
                        String label = tagsJsonArray.length() - 1 + " " + getResources().getString(R.string.others_tag_text);
                        actionTypeBody += " " + mContext.getResources().getString(R.string.and)
                                + " " + "<b>" + label + "<b>";
                        mClickableParts.put(order + "-" + type + "-" + id, label);
                        ++order;
                    }
                }
            }

            if (paramsJsonObject != null && paramsJsonObject.length() != 0) {
                JSONObject checkInJsonObject = paramsJsonObject.optJSONObject("checkin");
                if (checkInJsonObject != null && checkInJsonObject.length() != 0) {
                    String checkIn_type = checkInJsonObject.optString("type");
                    if (checkIn_type != null && !checkIn_type.isEmpty()) {
                        mLocationLabel = checkInJsonObject.optString("label");
                        String locationPrefix = checkInJsonObject.optString("prefixadd");
                        String locationId = checkInJsonObject.optString("id");
                        mLatitude = checkInJsonObject.optDouble("latitude");
                        mLongitude = checkInJsonObject.optDouble("longitude");
                        mPlaceId = checkInJsonObject.optString("place_id");

                        String[] locationIdParts = locationId.split("_");
                        if (locationIdParts.length == 2) {
                            int location_id = Integer.parseInt(locationIdParts[1]);
                            String locationKey = "checkIn" + "-" + location_id;
                            mClickableParts.put(order + "-" + locationKey, mLocationLabel);
                            ++order;

                            if (tagsJsonArray != null && tagsJsonArray.length() != 0)
                                actionTypeBody += "  <font color=\"#de000000\">" + locationPrefix + " </font>"
                                        + " " + "<b>" + mLocationLabel + "</b>";
                            else
                                actionTypeBody += " -  <font color=\"#de000000\">" + locationPrefix + " </font>"
                                        + " " + "<b>" + mLocationLabel + "</b>";
                        }

                    }

                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return actionTypeBody;
    }

    public void getFeeds() {
        String feedsUrl = mFeedsUrl;
        if (mFilterType != null && !mFilterType.isEmpty()) {
            feedsUrl += "&filter_type=" + mFilterType + "&list_id=" + mListId;
        }
        getFeeds(feedsUrl, false);
    }

    /**
     * Load More Feeds On Scroll
     *
     * @param url Url to send request on server
     */
    public void loadMoreFeeds(String url) {
        pageNumber++;
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                if (jsonObject != null) {
                    mBody = jsonObject;
                    mMaxFeedId = jsonObject.optInt("maxid");
                    defaultFeedCountTemp = defaultFeedCount = jsonObject.optInt("defaultFeedCount");
                    mAccurateActivityCount = jsonObject.optInt("accurateActivityCount");
                    if (isCommunityAds) {
                        loadCommunityAds(jsonObject);
                    } else {
                        isLoading = false;
                        if (mFeedItemsList != null && mFeedItemsList.size() != 0) {
                            mFeedItemsList.remove(mFeedItemsList.size() - 1);
                            mFeedAdapter.notifyItemRemoved(mFeedItemsList.size());
                        }
                        addDataToList(jsonObject, false);
                    }

                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

            }
        });
    }

    private void loadCommunityAds(JSONObject jsonObject) {
        AppConstant mAppConst = new AppConstant(mContext);
        mAppConst.getCommunityAds(ConstantVariables.FEED_ADS_POSITION,
                ConstantVariables.FEED_ADS_TYPE, jsonObject, new OnCommunityAdsLoadedListnerFeeds() {
                    @Override
                    public void onCommunityAdsLoaded(JSONArray advertisementsArray, JSONObject jsonObject) {
                        mAdvertisementsArray = advertisementsArray;
                        isLoading = false;
                        if (!isAdLoaded && mAdvertisementsArray != null) {
                            isAdLoaded = true;
                            int j = 0;
                            mMaxFeedId = jsonObject.optInt("maxid");
                            for (int i = 0; i <= mFeedItemsList.size(); i++) {
                                if (i != 0 && i % ConstantVariables.FEED_ADS_POSITION == 0 &&
                                        j < mAdvertisementsArray.length()) {
                                    if (ConstantVariables.FEED_ADS_TYPE == ConstantVariables.TYPE_COMMUNITY_ADS) {
                                        mFeedItemsList.add(i, addCommunityAddsToList(j));
                                    } else {
                                        mFeedItemsList.add(i, addSponsoredStoriesToList(j));
                                    }
                                    j++;
                                    mFeedAdapter.notifyDataSetChanged();
                                }
                            }
                        } else {
                            if (pageNumber > 1) {
                                if (mFeedItemsList != null && mFeedItemsList.size() != 0) {
                                    mFeedItemsList.remove(mFeedItemsList.size() - 1);
                                    mFeedAdapter.notifyItemRemoved(mFeedItemsList.size());
                                }
                                addDataToList(jsonObject, false);
                            }
                        }
                    }
                });
    }

    /**
     * Add Header to the RecyclerView for Posting Options
     *
     * @param jsonObject  Response from server
     * @param isCacheData
     */

    public void addHeader(JSONObject jsonObject, final boolean isCacheData) {

        mFilterTabsArray = jsonObject.optJSONArray("filterTabs");
        mDataJsonArray = jsonObject.optJSONArray("data");
        mFeedPostMenu = jsonObject.optJSONObject("feed_post_menu");
        mReactionsEnabled = jsonObject.optInt("reactionsEnabled");
        mStickersEnabled = jsonObject.optInt("stickersEnabled");
        reactions = jsonObject.optJSONObject("reactions");
        JSONObject videoSource = jsonObject.optJSONObject("video_source");
        PreferencesUtils.setVideoSourcePref(mContext, (videoSource != null && videoSource.has("3")));
        PreferencesUtils.setEmojiEnablePref(mContext, jsonObject.optInt("emojiEnabled"));

        PreferencesUtils.updateReactionsEnabledPref(mContext, mReactionsEnabled);
        PreferencesUtils.updateStickersEnabledPref(mContext, mStickersEnabled);
        if (reactions != null) {
            PreferencesUtils.storeReactions(mContext, reactions);
        }

        if ((mFeedPostMenu != null && mFeedPostMenu.length() != 0) ||
                (mFilterTabsArray != null && mFilterTabsArray.length() != 0)) {
            if (mDataJsonArray != null && mDataJsonArray.length() != 0)
                mFeedItemsList.add(0, new FeedList(mFeedPostMenu, mFilterTabsArray, false,
                        mReactionsEnabled, reactions));
            else
                mFeedItemsList.add(0, new FeedList(mFeedPostMenu, mFilterTabsArray, true,
                        mReactionsEnabled, reactions));
        } else {
            mFeedItemsList.add(0, new FeedList(null, null, false, mReactionsEnabled, reactions));
        }

        // Adding greetings when its Main activity feed.
        if ((mSubjectType == null || mSubjectType.isEmpty()) && mSubjectId == 0) {
            if (mBirthdayArray != null && mBirthdayArray.length() > 0) {
                FeedList feedList = (FeedList) mFeedItemsList.get(0);
                feedList.setBirthdayArray(mBirthdayArray);
            }
            if (mGreetingsArray != null && mGreetingsArray.length() > 0) {
                FeedList feedList = (FeedList) mFeedItemsList.get(0);
                feedList.setGreetingsArray(mGreetingsArray, false);
            }

            if (mBrowseListItem != null && mBrowseListItem.size() > 0) {
                FeedList feedList = (FeedList) mFeedItemsList.get(0);
                feedList.setBrowseItemList(mBrowseListItem, muteStoryCount, true);
            }
            // Checking if data is loaded from caching or its fresh API request.
            if (isDisplayStories()) {
                if (isCacheData) {
                    try {
                        String tempData = DataStorage.getResponseFromLocalStorage(mContext, DataStorage.STORY_BROWSE);
                        if (tempData != null) {
                            addStoriesInList(new JSONObject(tempData));
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                } else {
                    sendStoriesRequest();
                }
            } else if (mBrowseListItem != null && mBrowseListItem.size() > 0) {
                removeStoryFromApp();
            }

            // Checking if data is loaded from caching or its fresh API request.
            if (isCacheData) {
                try {
                    String tempData = DataStorage.getResponseFromLocalStorage(mContext, DataStorage.AAF_GREETINGS_CONTENT);
                    if (tempData != null) {
                        addGreetingsInList(new JSONObject(tempData));
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                sendGreetingsRequest();
            }
        }

    }

    /**
     * Method to send API server calling for stories browse data.
     */
    public void sendStoriesRequest() {
        // Checking if the story is enabled.
        if (isDisplayStories()) {

            mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/stories/browse",
                    new OnResponseListener() {
                        @Override
                        public void onTaskCompleted(JSONObject jsonObject) {
                            DataStorage.createTempFile(mContext, DataStorage.STORY_BROWSE, jsonObject.toString());
                            addStoriesInList(jsonObject);
                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                            if (message.equals(ConstantVariables.STORY_PLUGIN_DISABLED)) {
                                removeStoryFromApp();
                            }
                        }
                    });
        }
    }

    /* Execute when admin disabled stories plugin from admin settings and
     * we need remove stories from app */
    private void removeStoryFromApp() {
        mBrowseListItem.clear();
        StoryUtils.STORY.clear();
        FeedList feedList = (FeedList) mFeedItemsList.get(0);
        feedList.setBrowseItemList(mBrowseListItem, muteStoryCount, true);
        mFeedAdapter.notifyItemChanged(0);
        // Set story enable/disable settings in preferences
        PreferencesUtils.updateDashBoardData(mContext, PreferencesUtils.STORY_ENABLED, "0");
    }

    /**
     * Method to add stories in header list.
     */
    public void addStoriesInList(JSONObject jsonObject) {
        if (jsonObject != null && jsonObject.length() > 0) {
            mBrowseListItem.clear();
            StoryUtils.STORY.clear();
            muteStoryCount = jsonObject.optInt("muteStoryCount");

            JSONArray responseArray = jsonObject.optJSONArray("response");
            if (responseArray != null && responseArray.length() > 0) {
                for (int i = 0; i < responseArray.length(); i++) {
                    JSONObject storyObject = responseArray.optJSONObject(i);
                    StoryUtils.STORY.put(i, storyObject.optInt("story_id"));
                    StoryUtils.isMuteStory.put(i, storyObject.optInt("isMute"));
                    mBrowseListItem.add(new BrowseListItems(storyObject));
                }
            }

            if (!isStoryPosted) {
                BrowseListItems listItem = (BrowseListItems) mBrowseListItem.get(0);
                listItem.setmIsLoading(true);
                mBrowseListItem.set(0, listItem);
            }

            // Updating feed list with the stories.
            FeedList feedList = (FeedList) mFeedItemsList.get(0);
            feedList.setBrowseItemList(mBrowseListItem, muteStoryCount, true);
            mFeedAdapter.notifyItemChanged(0);
        }
    }

    public void addDataToList(JSONObject jsonObject, boolean isCacheData, int position) {
        addAtPosition = position;
        addDataToList(jsonObject, isCacheData);
    }

    public void addDataToList(JSONObject jsonObject, boolean isCacheData) {

        /* Hide shimmer effect when api request is completed */
        mShimmerViewContainer.setVisibility(View.GONE);
        mShimmerViewContainer.stopShimmer();
        swipeRefreshLayout.setVisibility(View.VISIBLE);

        if (isAdded()) {
            try {
                if (!isCacheData) {
                    addPeopleSuggestionList(isSuggestionLoaded, false);
                }
                mDataJsonArray = jsonObject.optJSONArray("data");
                int activityCount = jsonObject.optInt("activityCount");

                if (mDataJsonArray != null && mDataJsonArray.length() != 0) {
                    for (int i = 0; i < mDataJsonArray.length(); i++) {
                        if ((isAdLoaded || AdFetcher.isAdLoaded()) && mFeedItemsList.size() != 0
                                && mFeedItemsList.size() % ConstantVariables.FEED_ADS_POSITION == 0) {
                            switch (ConstantVariables.FEED_ADS_TYPE) {
                                case ConstantVariables.TYPE_FACEBOOK_ADS:
                                    NativeAd ad = this.listNativeAdsManager.nextNativeAd();
                                    mFeedItemsList.add(ad);
                                    break;
                                case ConstantVariables.TYPE_GOOGLE_ADS:
                                    if (j < mAdFetcher.getAdList().size()) {
                                        NativeAppInstallAd nativeAppInstallAd = (NativeAppInstallAd) mAdFetcher.getAdList().get(j);
                                        j++;
                                        mFeedItemsList.add(nativeAppInstallAd);
                                    } else {
                                        j = 0;
                                    }
                                    break;
                                default:
                                    if (mAdvertisementsArray != null) {
                                        if (j < mAdvertisementsArray.length()) {
                                            if (ConstantVariables.FEED_ADS_TYPE == ConstantVariables.TYPE_COMMUNITY_ADS) {
                                                mFeedItemsList.add(addCommunityAddsToList(j));
                                            } else {
                                                mFeedItemsList.add(addSponsoredStoriesToList(j));
                                            }
                                            j++;
                                        } else {
                                            j = 0;
                                        }
                                    }
                                    break;
                            }
                        }
                        String url = null;
                        JSONObject singleFeedJsonObject = mDataJsonArray.getJSONObject(i);

                        // Get Feed Info Object
                        JSONObject feedInfo = singleFeedJsonObject.optJSONObject("feed");
                        mHashTagArray = singleFeedJsonObject.optJSONArray("hashtags");
                        if (mHashTagArray != null) {
                            mHashTagString = "";
                            for (int k = 0; k < mHashTagArray.length(); k++) {
                                mHashTagString += mHashTagArray.get(k) + " ";
                            }
                        } else {
                            mHashTagString = "";
                        }
                        JSONObject userObject = feedInfo.optJSONObject("object");
                        if (userObject != null && userObject.length() != 0) {
                            url = userObject.optString("url");
                        }
                        JSONArray feedMenus = singleFeedJsonObject.optJSONArray("feed_menus");
                        JSONObject feedFooterMenus = singleFeedJsonObject.optJSONObject("feed_footer_menus");
                        int canComment = singleFeedJsonObject.optInt("can_comment");

                        String feedIcon = feedInfo.optString("feed_icon");
                        int isLike = singleFeedJsonObject.optInt("is_like");
                        int actionId = feedInfo.optInt("action_id");
                        int subjectId = feedInfo.optInt(ConstantVariables.SUBJECT_ID);
                        int feedType = feedInfo.optInt("feed_type");
                        String objectType = feedInfo.optString("object_type");
                        int objectId = feedInfo.optInt("object_id");
                        String body = feedInfo.optString("body");
                        int commentCount = feedInfo.optInt("comment_count");
                        int attachmentCount = feedInfo.optInt("attachment_count");
                        int likeCount = feedInfo.optInt("like_count");
                        int commentAble = feedInfo.optInt("commentable");
                        int shareAble = feedInfo.optInt("shareable");
                        int isSaveFeedOption = singleFeedJsonObject.optInt("isSaveFeedOption");
                        boolean isNotificationTurnedOn = singleFeedJsonObject.optBoolean("isNotificationTurnedOn");
                        String feedLink = singleFeedJsonObject.optString("feed_link");
                        int pinPostDuration = singleFeedJsonObject.optInt("pin_post_duration");
                        boolean isPostPinned = singleFeedJsonObject.optBoolean("isPinned");
                        String schedulePostTime = feedInfo.optString("publish_date");
                        String date = feedInfo.optString("date");
                        JSONObject feedObject = feedInfo.optJSONObject("object");
                        String postPrivacy = feedInfo.optString("privacy");
                        String privacyIcon = feedInfo.optString("privacy_icon");

                        String type = feedInfo.optString("type");
                        String feedAttachmentType = feedInfo.optString("attachment_content_type");
                        String isTranslation = feedInfo.optString("is_translation");

                        /* CODE FOR FETCHING FEED ATTACHMENT */
                        JSONArray attachmentArray = feedInfo.optJSONArray("attachment");
                        int photoAttachmentCount = feedInfo.optInt("photo_attachment_count");

                        /* CODE STARTS FOR  PREPARING Feed TITLE */
                        String feedActionTitle = feedInfo.optString("feed_title");

                        String actionTypeBody = feedInfo.optString("action_type_body");
                        JSONArray actionTypeBodyParams = feedInfo.optJSONArray("action_type_body_params");
                        JSONArray tagsJsonArray = feedInfo.optJSONArray("tags");
                        JSONObject paramsJsonObject = feedInfo.optJSONObject("params");

                        JSONArray userTagJsonArray = feedInfo.optJSONArray("userTag");
                        JSONArray wordStyleArray = feedInfo.optJSONArray("wordStyle");

                        JSONObject feedReactions = singleFeedJsonObject.optJSONObject("feed_reactions");

                        JSONObject myFeedReaction = singleFeedJsonObject.optJSONObject("my_feed_reaction");

                        JSONObject decoration = feedInfo.optJSONObject("decoration");
                        JSONObject bannerObject = null, feelingObject = null, userTagObject = null;
                        if (paramsJsonObject != null && paramsJsonObject.length() > 0) {
                            bannerObject = paramsJsonObject.optJSONObject("feed-banner");
                            feelingObject = paramsJsonObject.optJSONObject("feelings");
                            userTagObject = paramsJsonObject.optJSONObject("tags");
                        }
                        JSONObject subjectProfileInfo = feedInfo.optJSONObject("subjectIformation");
                        mActionTypeBody = null;
                        startIndex = 0;
                        endIndex = 0;

                        /* Declare variables for shared feed */
                        int shareActionId = 0, shareSubjectId = 0, shareFeedType = 0, shareObjectId = 0;
                        String shareObjectType = "", shareBody = "", shareDate = "", shareActionTypeBody = "",
                                shareFeedActionTitle = "", shareFeedIcon = "";
                        JSONArray shareActionTypeBodyParams;
                        boolean isShareFeed = false;

                        if (attachmentArray != null && attachmentArray.optJSONObject(0) != null &&
                                attachmentArray.optJSONObject(0).has("shared_post_data")) {
                            shareActionId = actionId;
                            shareSubjectId = subjectId;
                            shareFeedType = feedType;
                            shareObjectType = objectType;
                            shareObjectId = objectId;
                            shareBody = body;
                            shareDate = date;
                            shareActionTypeBody = actionTypeBody;
                            shareActionTypeBodyParams = actionTypeBodyParams;
                            shareFeedActionTitle = feedActionTitle;
                            shareFeedIcon = feedIcon;
                            isShareFeed = true;

                            if (shareActionTypeBodyParams != null && shareActionTypeBodyParams.length() != 0) {
                                shareFeedActionTitle = getActionBody(shareActionTypeBody, shareActionTypeBodyParams,
                                        null, null, null, null,
                                        null, null, null, true);
                            }

                            JSONArray shareFeedArray = attachmentArray.optJSONObject(0).optJSONArray("shared_post_data");
                            JSONObject shareObject = shareFeedArray.optJSONObject(0);
                            JSONObject shareFeedObject = shareObject.optJSONObject("feed");

                            actionId = shareFeedObject.optInt("action_id");
                            feedIcon = shareFeedObject.optString("feed_icon");
                            subjectId = shareFeedObject.optInt(ConstantVariables.SUBJECT_ID);
                            feedType = shareFeedObject.optInt("feed_type");
                            objectType = shareFeedObject.optString("object_type");
                            objectId = shareFeedObject.optInt("object_id");
                            body = shareFeedObject.optString("body");

                            attachmentArray = shareFeedObject.optJSONArray("attachment");
                            attachmentCount = shareFeedObject.optInt("attachment_count");
                            photoAttachmentCount = shareFeedObject.optInt("photo_attachment_count");
                            date = shareFeedObject.optString("date");
                            feedObject = shareFeedObject.optJSONObject("object");

                            type = shareFeedObject.optString("type");
                            feedAttachmentType = shareFeedObject.optString("attachment_content_type");

                            actionTypeBody = shareFeedObject.optString("action_type_body");
                            actionTypeBodyParams = shareFeedObject.optJSONArray("action_type_body_params");
                            tagsJsonArray = shareFeedObject.optJSONArray("tags");
                            paramsJsonObject = shareFeedObject.optJSONObject("params");

                            userTagJsonArray = shareFeedObject.optJSONArray("userTag");
                            feedActionTitle = shareFeedObject.optString("feed_title");
                        }
                        mActionTypeBody = null;

                        if (actionTypeBodyParams != null && actionTypeBodyParams.length() != 0) {
                            feedActionTitle = getActionBody(actionTypeBody, actionTypeBodyParams,
                                    tagsJsonArray, wordStyleArray, paramsJsonObject, feelingObject, isTranslation, attachmentArray, userTagJsonArray, false);
                        }

                        /* END FEED TITLE CODE */
                        if (addAtPosition < 0) {

                            mFeedItemsList.add(new FeedList(actionId, subjectId, feedType, objectType, objectId,
                                    feedActionTitle, feedIcon, postPrivacy, privacyIcon, feedMenus, date, feedLink, schedulePostTime, pinPostDuration, attachmentCount, likeCount,
                                    commentCount, canComment, isLike, feedObject, decoration, bannerObject, feelingObject, userTagObject, attachmentArray, photoAttachmentCount,
                                    feedFooterMenus, commentAble, shareAble, isSaveFeedOption, isNotificationTurnedOn, isPostPinned,
                                    mClickableParts, mClickablePartsNew, mActionTypeBody, mVideoInformation, mWordStylingClickableParts, url,
                                    feedAttachmentType, type, mLocationLabel, mLatitude, mLongitude, mPlaceId,
                                    mHashTagString, feedReactions, myFeedReaction, tagsJsonArray, isTranslation, startIndex, endIndex,
                                    isShareFeed, shareFeedIcon, shareActionId, shareSubjectId, shareFeedType, shareObjectType, shareObjectId,
                                    shareBody, shareDate, shareFeedActionTitle, mShareClickableParts, otherMembers, subjectProfileInfo));


                        } else {
                            mMinFeedId = jsonObject.optInt("minid");
                            try {
                                mFeedItemsList.set(addAtPosition, new FeedList(actionId, subjectId, feedType, objectType, objectId,
                                        feedActionTitle, feedIcon, postPrivacy, privacyIcon, feedMenus, date, feedLink, schedulePostTime, pinPostDuration, attachmentCount, likeCount,
                                        commentCount, canComment, isLike, feedObject, decoration, bannerObject, feelingObject, userTagObject, attachmentArray, photoAttachmentCount,
                                        feedFooterMenus, commentAble, shareAble, isSaveFeedOption, isNotificationTurnedOn, isPostPinned,
                                        mClickableParts, mClickablePartsNew, mActionTypeBody, mVideoInformation, mWordStylingClickableParts, url,
                                        feedAttachmentType, type, mLocationLabel, mLatitude, mLongitude, mPlaceId,
                                        mHashTagString, feedReactions, myFeedReaction, tagsJsonArray, isTranslation, startIndex, endIndex,
                                        isShareFeed, shareFeedIcon, shareActionId, shareSubjectId, shareFeedType, shareObjectType, shareObjectId,
                                        shareBody, shareDate, shareFeedActionTitle, mShareClickableParts, otherMembers, subjectProfileInfo));
                            } catch (IndexOutOfBoundsException e) {
                                e.printStackTrace();
                                addAtPosition--;

                            }
                            addAtPosition = -1;
                        }

                    }

                    // Showing end of result when the actual feed count(No. of Feeds which are coming right now)
                    // and Accurate activity count(No. of Feeds which needs to come) are equal
                    // and less than the defaultFeedCount.
                    if (mAccurateActivityCount == activityCount && activityCount < defaultFeedCount) {
                        // Show End Of Results Message
                        mFeedItemsList.add(ConstantVariables.FOOTER_TYPE);
                    }
                }

            } catch (JSONException e) {
                e.printStackTrace();
            }

            if (!isFeedUpdate) {
                mFeedAdapter.notifyDataSetChanged();
            }

            // Play video if it's coming on 1st position
            if (pageNumber == 1 && isAutoPlayVideo) {
                mFeedAdapter.onViewDetachedFromWindow(mFeedsRecyclerView.findViewHolderForAdapterPosition(1));
                Thread t = new Thread() {
                    public void run() {
                        try {
                            synchronized (this) {
                                wait(100);
                                ((Activity) mContext).runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        oldPlayPosition = -1;
                                        autoPlayVideos(0, true);
                                    }
                                });

                            }
                        } catch (InterruptedException e) {
                            //e.printStackTrace();
                        }
                    }
                };
                t.start();
            }
        }

    }

    /**
     * Making server call to get greetings response.
     */
    private void sendGreetingsRequest() {
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/feelings/greeting-manage",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) {
                        DataStorage.createTempFile(mContext, DataStorage.AAF_GREETINGS_CONTENT, jsonObject.toString());
                        addGreetingsInList(jsonObject);
                        mFeedAdapter.notifyItemChanged(0);
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });
    }

    /**
     * Adding Greetings response into feed list.
     *
     * @param jsonObject JSONObject which contains the greetings.
     */
    private void addGreetingsInList(JSONObject jsonObject) {
        mGreetingsArray = jsonObject.optJSONArray("greetings");
        mBirthdayArray = jsonObject.optJSONArray("usersBirthday");
        if (mFeedItemsList != null && mFeedItemsList.get(0) != null) {
            FeedList feedList = (FeedList) mFeedItemsList.get(0);
            feedList.setGreetingsArray(mGreetingsArray, false);
            feedList.setBirthdayArray(mBirthdayArray);
            mFeedAdapter.notifyItemChanged(0);
        }
    }

    /**
     * Method to send people suggestion request on server then add the data in specified position.
     *
     * @param isLoaded True if the Suggestions are already loaded into list.
     */
    public void addPeopleSuggestionList(boolean isLoaded, boolean isRemovedAll) {

        // Getting enabled module array to check suggestion plugin is enabled or not.
        List<String> enabledModuleList = null;
        if (PreferencesUtils.getEnabledModuleList(mContext) != null) {
            enabledModuleList = new ArrayList<>(Arrays.asList(PreferencesUtils.getEnabledModuleList(mContext).split("\",\"")));
        }

        // Sending request only when the user is logged-in and the people suggestion is enabled
        // And not showing on content's/user's profile page.
        if (!mAppConst.isLoggedOutUser() && ConstantVariables.ENABLE_PEOPLE_SUGGESTION == 1 && pageNumber == 1
                && enabledModuleList != null && enabledModuleList.contains("suggestion") && ConstantVariables.PEOPLE_SUGGESTION_POSITION != 0
                && (mSubjectType == null || mSubjectType.isEmpty())) {
            isSuggestionLoaded = isLoaded;

            if (usersArray == null || isRemovedAll) {
                mAppConst.getJsonResponseFromUrl(UrlUtil.PEOPLE_SUGGESTION_URL + ConstantVariables.PEOPLE_SUGGESTION_LIMIT,
                        new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) {
                                usersArray = jsonObject.optJSONArray("users");
                                setUserArrayList();
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                mFeedItemsList.remove(browseItemArrayList);
                                mFeedAdapter.notifyDataSetChanged();
                            }
                        });
            } else {
                setUserArrayList();
            }
        }
    }

    private void setUserArrayList() {
        if (usersArray != null && usersArray.length() > 0) {
            browseItemArrayList = new ArrayList<>();

            // Adding all the users into list.
            for (int i = 0; i < usersArray.length(); i++) {
                JSONObject userObject = usersArray.optJSONObject(i);
                int userId = userObject.optInt("user_id");
                int mutualFriendCount = userObject.optInt("mutualFriendCount");
                String userName = userObject.optString("displayname");
                String userImage = userObject.optString("image");
                JSONArray userMenuArray = userObject.optJSONArray("menus");
                browseItemArrayList.add(new BrowseListItems(userId, mutualFriendCount,
                        userName, userImage, false, userMenuArray));
            }

            // Adding footer type at the end of the list to show Find More Friends option.
            browseItemArrayList.add(ConstantVariables.FOOTER_TYPE);

            // Adding the people suggestion list into feed list.
            for (int i = 0; i <= mFeedItemsList.size(); i++) {
                if (!isSuggestionLoaded && i != 0 && browseItemArrayList.size() > 0
                        && i % ConstantVariables.PEOPLE_SUGGESTION_POSITION == 0) {
                    mFeedItemsList.add(i, browseItemArrayList);
                    mFeedAdapter.notifyDataSetChanged();
                    isSuggestionLoaded = true;
                    mFeedAdapter.isPeopleSuggestionAdapterSet(false);
                }
            }
        } else {
            mFeedItemsList.remove(browseItemArrayList);
            mFeedAdapter.notifyDataSetChanged();
        }
    }

    /**
     * Function to get the New Feed count
     */
    public void getFeedCounts() {

        if (mMinFeedId != 0) {

            String getFeedCountUrl = AppConstant.DEFAULT_URL + "advancedactivity/feeds?minid=" +
                    mMinFeedId + "&feed_count_only=true";

            if (mSubjectType != null && !mSubjectType.isEmpty()) {
                getFeedCountUrl += "&subject_type=" + mSubjectType + "&subject_id=" + mSubjectId;
            }

            if (mFilterType != null && !mFilterType.isEmpty()) {
                getFeedCountUrl += "&filter_type=" + mFilterType + "&list_id=" + mListId;
            }

            mAppConst.getJsonResponseFromUrl(getFeedCountUrl, new OnResponseListener() {
                @Override
                public void onTaskCompleted(final JSONObject jsonObject) {

                    if (jsonObject != null && jsonObject.length() != 0) {
                        int feedCount = jsonObject.optInt("body");

                        if (feedCount != 0) {
                            //TODO
//                            String feedsUrl = mFeedsUrl;
//                            if (mFilterType != null && !mFilterType.isEmpty()) {
//                                feedsUrl += "&filter_type=" + mFilterType;
//                            }
//                            getFeeds(feedsUrl, true);
                            if (mshowNewUpdateCount == null) {
                                mshowNewUpdateCount = new RelativeLayout(mContext);
                                mshowNewUpdateCount.setBackgroundResource(R.drawable.new_feeds_tip_message);
                                mshowNewUpdateCount.getBackground().setAlpha(220);
                                int marginTop = (int) (mContext.getResources().getDimension(R.dimen.margin_20dp) /
                                        mContext.getResources().getDisplayMetrics().density);
                                RelativeLayout.LayoutParams layoutParams = CustomViews.getWrapRelativeLayoutParams();
                                layoutParams.setMargins(marginTop, marginTop, marginTop, 0);
                                layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                                layoutParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
                                int paddingTopBottom = mContext.getResources().getDimensionPixelOffset
                                        (R.dimen.padding_10dp);
                                int paddingRightLeft = mContext.getResources().getDimensionPixelOffset
                                        (R.dimen.padding_20dp);
                                mshowNewUpdateCount.setPadding(paddingRightLeft, paddingTopBottom, paddingRightLeft, paddingTopBottom);
                                mshowNewUpdateCount.setLayoutParams(layoutParams);
                                TextView updateTextView = new TextView(mContext);
                                updateTextView.setText(mContext.getResources().getString(R.string.new_stories_text));
                                updateTextView.setTextColor(ContextCompat.getColor(mContext, R.color.white));
                                updateTextView.setGravity(Gravity.TOP);
                                updateTextView.setClickable(true);
                                updateTextView.setMovementMethod(LinkMovementMethod.getInstance());
                                updateTextView.setOnClickListener(new View.OnClickListener() {
                                    @Override
                                    public void onClick(View view) {
                                        mshowNewUpdateCount.setVisibility(View.GONE);
                                        String feedsUrl = mFeedsUrl;
                                        if (mFilterType != null && !mFilterType.isEmpty()) {
                                            feedsUrl += "&filter_type=" + mFilterType + "&list_id=" + mListId;
                                        }
                                        if (mFeedsRecyclerView != null) {
                                            mFeedsRecyclerView.scrollToPosition(0);
                                        }
                                        swipeRefreshLayout.post(() -> swipeRefreshLayout.setRefreshing(true));
                                        getFeeds(feedsUrl, true);

                                    }
                                });
                                mshowNewUpdateCount.addView(updateTextView);
                                mMainContent.addView(mshowNewUpdateCount);

                            } else if (mshowNewUpdateCount.getVisibility() == View.GONE) {
                                mshowNewUpdateCount.setVisibility(View.VISIBLE);
                            }
                        } else if (mshowNewUpdateCount != null && mshowNewUpdateCount.getVisibility() ==
                                View.VISIBLE) {
                            mshowNewUpdateCount.setVisibility(View.GONE);
                        }
                    }

                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                }
            });
        }
    }

    @Override
    public void onRefresh() {

        // Playing pull to refresh sound effect on refreshing.
        if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
            SoundUtil.playSoundEffectOnPullToRefresh(mContext);
        }

        /* Check and dismiss if no internet connection snackbar is displaying */
        if (snackbar != null && snackbar.isShown()) {
            snackbar.dismiss();
        }

        String feedsUrl = mFeedsUrl;
        if (mFilterType != null && !mFilterType.isEmpty()) {
            feedsUrl += "&filter_type=" + mFilterType + "&list_id=" + mListId;
        }
        isSuggestionLoaded = false;
        usersArray = null;
        isAdLoaded = false;
        pageNumber = 1;
        getFeeds(feedsUrl, true);
        if (listNativeAdsManager != null) {
            listNativeAdsManager.loadAds(NativeAd.MediaCacheFlag.ALL);
        }
    }

    /**
     * When Filters will be applied
     *
     * @param filterType Selected Filter Type
     */
    @Override
    public void setFilterType(String filterType, int listId) {

        mFilterType = filterType;
        mListId = listId;
        String feedsUrl = mFeedsUrl;
        if (mFilterType != null && !mFilterType.isEmpty()) {
            oldPlayPosition = -1;
            pageNumber = 1;
            feedsUrl += "&filter_type=" + mFilterType + "&list_id=" + mListId;
            getFeeds(feedsUrl, false);
        }
    }

    @Override
    public void onAdsLoaded() {
        if (!isAdLoaded) {
            isAdLoaded = true;
            for (int i = 0; i <= mFeedItemsList.size(); i++) {
                if (i != 0 && i % ConstantVariables.FEED_ADS_POSITION == 0) {
                    NativeAd ad = this.listNativeAdsManager.nextNativeAd();
                    mFeedItemsList.add(i, ad);
                    mFeedAdapter.notifyDataSetChanged();
                }
            }
        }
    }

    @Override
    public void onAdError(AdError adError) {

    }

    @Override
    public void onCommunityAdsLoaded(JSONArray advertisementsArray, JSONObject jsonObject) {
        mAdvertisementsArray = advertisementsArray;
        isLoading = false;
        if (!isAdLoaded && mAdvertisementsArray != null) {
            isAdLoaded = true;
            int j = 0;
            for (int i = 0; i <= mFeedItemsList.size(); i++) {
                if (i != 0 && i % ConstantVariables.FEED_ADS_POSITION == 0 &&
                        j < mAdvertisementsArray.length()) {
                    if (ConstantVariables.FEED_ADS_TYPE == ConstantVariables.TYPE_COMMUNITY_ADS) {
                        mFeedItemsList.add(i, addCommunityAddsToList(j));
                    } else {
                        mFeedItemsList.add(i, addSponsoredStoriesToList(j));
                    }
                    j++;
                    mFeedAdapter.notifyDataSetChanged();
                }
            }
        } else {
            if (pageNumber > 1) {
                if (mFeedItemsList != null && mFeedItemsList.size() != 0) {
                    mFeedItemsList.remove(mFeedItemsList.size() - 1);
                    mFeedAdapter.notifyItemRemoved(mFeedItemsList.size());
                }
                addDataToList(jsonObject, false);
            }
        }
    }

    @Override
    public void onPostPinUnpin() {
        if (swipeRefreshLayout != null)
            swipeRefreshLayout.setRefreshing(true);
        onRefresh();
    }

    @Override
    public void onGifPlay(int position) {
        mGifPosition = position;
    }

    @Override
    public void updateProgress(int notifyItemAt, int progress) {
        int position = mFeedItemsList.indexOf(new FeedList(String.valueOf(notifyItemAt)));
        if (position >= 0) {
            FeedList feedList = (FeedList) mFeedItemsList.get(position);
            feedList.setProgress(progress);
            if (progress > 98) {
                feedList.isRequestProcessing = true;
            }
            mFeedAdapter.notifyItemChanged(position);
        }

    }

    @Override
    public void onPause() {
        super.onPause();
        handler.removeCallbacks(runnableCode);
        if (swipeRefreshLayout != null) {
            swipeRefreshLayout.setRefreshing(false);
            swipeRefreshLayout.setEnabled(false);
            swipeRefreshLayout.destroyDrawingCache();
            swipeRefreshLayout.clearAnimation();
        }

        new Handler(Looper.getMainLooper()).post(() -> pauseVideos(false));

    }


    @Override
    public void onResume() {


        /**
         * Start the handler again if coming back from any profile page
         * or hashtag search
         */
        if ((mSubjectType == null || mSubjectType.isEmpty()) && mSubjectId == 0 && mHashTagValue == null) {
            isHandlerStopped = false;

            // Repeat this runnable code again every 60 seconds
            handler.postDelayed(runnableCode, mPeriod);
        }

        if (swipeRefreshLayout != null) {
            swipeRefreshLayout.setEnabled(true);
        }

        isAutoPlayVideo = Utils.isAutoPlayVideos(mContext);

        new Handler(Looper.getMainLooper()).post(() -> {
            resumeVideos(false);
        });

        super.onResume();
    }

    /**
     * Clear callback on detach to prevent null reference errors after the view has been
     */
    @Override
    public void onDetach() {
        super.onDetach();
        handler.removeCallbacks(runnableCode);
        try {
            Field childFragmentManager = Fragment.class.getDeclaredField("mChildFragmentManager");
            childFragmentManager.setAccessible(true);
            childFragmentManager.set(this, null);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mContext = context;
        if (mFeedsRecyclerView != null) {
            mFeedsRecyclerView.scrollToPosition(0);
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        handler.removeCallbacks(runnableCode);
        isStoryPosted = true;
    }

    int processCount = 0;

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        LogUtils.LOGD(" FeedsFragment :: onActivityRequest: ", requestCode + " " + resultCode + " -- data: " + data + " - " + VideoLightBox.isInPictureInPictureMode);

        Bundle bundle;
        int feedPosition, isLike;
        switch (resultCode) {
            // When PhotoLightBox is opened from AAF
            // and any changes occured at light box page then update the like/comment count.
            case ConstantVariables.LIGHT_BOX_EDIT:
                try {
                    bundle = data.getExtras();
                    feedPosition = bundle.getInt(ConstantVariables.ITEM_POSITION);
                    isLike = bundle.getBoolean(ConstantVariables.IS_LIKED) ? 1 : 0;
                    feedPosition = updateFeedPositionIfNeed(feedPosition);

                    if (mFeedItemsList != null && mFeedItemsList.size() != 0) {
                        FeedList selectedFeedRow = (FeedList) mFeedItemsList.get(feedPosition);
                        selectedFeedRow.setmCommentCount(bundle.getInt(ConstantVariables.PHOTO_COMMENT_COUNT));
                        selectedFeedRow.setmLikeCount(bundle.getInt(ConstantVariables.PHOTO_LIKE_COUNT));
                        if (bundle.getString(ConstantVariables.MY_PHOTO_REACTIONS) != null && !bundle.getString(ConstantVariables.MY_PHOTO_REACTIONS).isEmpty()) {
                            selectedFeedRow.setmMyFeedReactions(new JSONObject(bundle.
                                    getString(ConstantVariables.MY_PHOTO_REACTIONS)));
                        }

                        if (bundle.getString(ConstantVariables.PHOTO_POPULAR_REACTIONS) != null && !bundle.getString(ConstantVariables.MY_PHOTO_REACTIONS).isEmpty()) {
                            selectedFeedRow.setmFeedReactions(new JSONObject(bundle.
                                    getString(ConstantVariables.PHOTO_POPULAR_REACTIONS)));
                        }
                        selectedFeedRow.setmIsLike(isLike);
                        mFeedAdapter.updatePhotoLikeCommentCount(feedPosition);

                        // Set gif play false
                        if (selectedFeedRow.getIsGifLoad()) {
                            selectedFeedRow.setIsGifLoad(false);
                        }
                        mFeedAdapter.notifyItemChanged(feedPosition);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }


                break;

            // When Single Feed page is opened from AAF
            // and any changes occured at Single Feed page then update the list at clicked position.
            case ConstantVariables.VIEW_SINGLE_FEED_PAGE:
                bundle = data.getExtras();
                feedPosition = bundle.getInt(ConstantVariables.ITEM_POSITION);
                feedPosition = updateFeedPositionIfNeed(feedPosition);

                if (mFeedItemsList != null && mFeedItemsList.size() != 0) {
                    FeedList feedList = bundle.getParcelable(ConstantVariables.FEED_LIST);
                    mFeedItemsList.set(feedPosition, feedList);
                    mFeedAdapter.updatePhotoLikeCommentCount(feedPosition);
                    mFeedAdapter.notifyItemChanged(feedPosition);
                }
                resumeVideos(true);
                break;

            // When Comment page is opened from AAF
            // and any changes occured at Comment page then update the comment count.
            case ConstantVariables.VIEW_COMMENT_PAGE_CODE:
                bundle = data.getExtras();
                feedPosition = bundle.getInt(ConstantVariables.ITEM_POSITION);
                feedPosition = updateFeedPositionIfNeed(feedPosition);
                if (mFeedItemsList != null && mFeedItemsList.size() != 0) {
                    FeedList feedList = (FeedList) mFeedItemsList.get(feedPosition);
                    feedList.setmCommentCount(bundle.getInt(ConstantVariables.PHOTO_COMMENT_COUNT));
                    mFeedAdapter.updatePhotoLikeCommentCount(feedPosition);
                    mFeedAdapter.notifyItemChanged(feedPosition);
                }
                break;

            case ConstantVariables.REQUEST_STORY_POST:
                if (data != null) {
                    uploadStory(data);
                }
                break;

            case ConstantVariables.STORY_VIEW_PAGE_CODE:
                sendStoriesRequest();
                break;

            case ConstantVariables.POSTED_NEW_FEED:
                try {
                    if (mFeedItemsList.size() == 1) {
                        FeedList feedList = (FeedList) mFeedItemsList.get(0);
                        feedList.setNoFeed(false);
                        mFeedItemsList.set(0, feedList);
                        mFeedAdapter.notifyItemChanged(0);
                        mFeedItemsList.add(ConstantVariables.FOOTER_TYPE);
                    }
                    HashMap<String, String> postParams = (HashMap<String, String>) data.getSerializableExtra("postParam");
                    String feedBody = postParams.get("body");
                    JSONObject userDetail = new JSONObject(PreferencesUtils.getUserDetail(mContext));
                    previewItemPosition++;
                    postParams.put("notifyItemAt", String.valueOf(previewItemPosition));
                    mFeedItemsList.add(1, new FeedList(userDetail.optString("displayname"), userDetail.optString("image_normal"), feedBody, data.getStringArrayListExtra("mSelectPath"), String.valueOf(previewItemPosition), postParams));
                    mFeedAdapter.notifyItemInserted(1);

                    OkHttpUploadHandler uploadAttachmentUtil = new OkHttpUploadHandler(false, mContext, data.getStringExtra("mStatusPostUrl"),
                            postParams, data.getStringArrayListExtra("mSelectPath"), this, true);
                    uploadUtilMap.put(previewItemPosition, uploadAttachmentUtil);
                    uploadAttachmentUtil.execute();

                } catch (JSONException e) {
                    e.printStackTrace();
                }

                break;

            case ConstantVariables.AUTO_PLAY_VIDEO_VIEW_CODE:
                if (data != null && !VideoLightBox.isInPictureInPictureMode && !AdvVideoView.isInPictureInPictureMode) {
                    isResumeVideo = true;
                    resumeVideoFromPlaybackState(data.getIntExtra(VideoLightBox.STATE_RESUME_WINDOW, 0), data.getLongExtra(VideoLightBox.STATE_PLAY_BACK_POSITION, 0));
                }

                break;
        }

        // Notifying adapter when the user clicked on write a post or Message option (Birthday Greeting)
        if (requestCode == ConstantVariables.UPDATE_REQUEST_CODE
                && mFeedItemsList != null && mFeedItemsList.size() > 0) {
            mFeedAdapter.notifyItemChanged(0);
        }
    }

    @Override
    public void onAsyncSuccessResponse(JSONObject response, boolean isRequestSuccessful, boolean isAttachFileRequest) {
        try {
            if (isRequestSuccessful) {
                final JSONObject bodyObject = response.optJSONObject("body");
                if (bodyObject != null && bodyObject.has("response")
                        && bodyObject.optJSONObject("response").has("story_id")) {
                    isStoryPosted = true;
                    sendStoriesRequest();
                } else if (bodyObject != null && bodyObject.optInt("notifyItemAt", 0) != 0) {
                    int notifyAtPosition = bodyObject.optInt("notifyItemAt", 1);
                    int position = mFeedItemsList.indexOf(new FeedList(String.valueOf(notifyAtPosition)));
                    addDataToList(bodyObject, false, position);
                    NotificationManager notificationManager = (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
                    notificationManager.cancelAll();

                    if (uploadUtilMap != null && uploadUtilMap.size() > notifyAtPosition)
                        uploadUtilMap.remove(notifyAtPosition);
                } else {
                    getFeeds(mFeedsUrl, true);
                    SnackbarUtils.displaySnackbar(rootView, mContext.getResources().getString(R.string.feed_post_success_message));
                }

            } else {
                if (!isStoryPosted) {
                    isStoryPosted = true;
                    // Stop story upload bar when some error is coming in story upload
                    if (mBrowseListItem != null && mBrowseListItem.size() > 0) {
                        BrowseListItems listItem = (BrowseListItems) mBrowseListItem.get(0);
                        listItem.setmIsLoading(false);
                        mBrowseListItem.set(0, listItem);

                        FeedList feedList = (FeedList) mFeedItemsList.get(0);
                        feedList.setBrowseItemList(mBrowseListItem, muteStoryCount, true);
                        mFeedAdapter.notifyItemChanged(0);
                    }
                }
                SnackbarUtils.displaySnackbarLongTimeWithMultiLine(mMainContent, response.optString("message"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Method to upload story and status when it comes from story create page.
     *
     * @param data Intent which contains all the required info.
     */
    private void uploadStory(Intent data) {


        HashMap<String, String> postParam, storyParam;
        ArrayList<String> selectPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);
        UploadFileToServerUtils mUploadAttachmentUtil = null;

        HashMap<String, String> videoParams = (HashMap<String, String>) data.getSerializableExtra("video_params");
        String postMessage = "";
        if (data.hasExtra("post_param")) {
            postMessage = mContext.getResources().getString(R.string.post_will_update_soon);
            postParam = (HashMap<String, String>) data.getSerializableExtra("post_param");

            mUploadAttachmentUtil = new UploadFileToServerUtils(mContext, data.getStringExtra("post_url"),
                    postParam, selectPath, false, this, videoParams);
        }

        if (data.hasExtra("story_param")) {
            postMessage = mContext.getResources().getString(R.string.story_post_message);
            isStoryPosted = false;
            storyParam = (HashMap<String, String>) data.getSerializableExtra("story_param");
            BrowseListItems listItem = (BrowseListItems) mBrowseListItem.get(0);
            listItem.setmIsLoading(true);
            mBrowseListItem.set(0, listItem);
            FeedList feedList = (FeedList) mFeedItemsList.get(0);
            feedList.setBrowseItemList(mBrowseListItem, muteStoryCount, true);
            mFeedAdapter.notifyItemChanged(0);

            new UploadFileToServerUtils(mContext, data.getStringExtra("story_url"),
                    storyParam, selectPath, true, this, videoParams).execute();
        }

        if (data.hasExtra("post_param") && data.hasExtra("story_param")) {
            postMessage = mContext.getResources().getString(R.string.story_and_post_message);
        }

        SnackbarUtils.displaySnackbar(rootView, postMessage);

        if (mUploadAttachmentUtil != null) {
            mUploadAttachmentUtil.execute();
        }
    }

    /**
     * Method to update updated feed position when People suggestion are loaded after an item click.
     *
     * @param itemPosition Position of the updated feed.
     * @return Returns the updated position is any such case exist other returns the original position.
     */
    public int updateFeedPositionIfNeed(int itemPosition) {

        if (mFeedItemsList != null && mFeedItemsList.size() > 0
                && mFeedItemsList.get(itemPosition) instanceof ArrayList) {
            itemPosition = itemPosition + 1;
        }
        return itemPosition;
    }

    public void checkManifestPermissions(Intent intent, String ManifestPermission, int requestcode,
                                         boolean isStatusActivity, boolean isStoryRequest) {
        activityIntent = intent;
        mIsStatusActivity = isStatusActivity;
        mIsStoryRequest = isStoryRequest;
        /* Request Permission if not already granted */
        if (!mAppConst.checkManifestPermission(ManifestPermission)) {
            requestPermissions(new String[]{ManifestPermission}, requestcode);

        } else if (mIsStoryRequest) {
            startStoryMediaPickerActivity();
        } else {
            startIntentActivity();
        }
    }

    public void startStoryMediaPickerActivity() {
        Intent intent = new Intent(mContext, PhotoEditActivity.class);
        startActivityForResult(intent, ConstantVariables.REQUEST_STORY_POST);
        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    /* Open Activities using intent */
    private void startIntentActivity() {

        if (mIsStatusActivity) {
            ((Activity) mContext).startActivityForResult(activityIntent, ConstantVariables.FEED_REQUEST_CODE);
        } else {
            mContext.startActivity(activityIntent);
        }
        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission granted, proceed to the normal flow
                    if (mIsStoryRequest) {
                        startStoryMediaPickerActivity();
                    } else {
                        startIntentActivity();
                    }
                } else {
                    // If user press deny in the permission popup
                    if (shouldShowRequestPermissionRationale(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {

                        // Show an expanation to the user After the user
                        // sees the explanation, try again to request the permission.

                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    } else {
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.

                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, rootView,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    }
                }
                break;

            case ConstantVariables.ACCESS_FINE_LOCATION:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission granted, proceed to the normal flow
                    startIntentActivity();
                } else {
                    // If user press deny in the permission popup
                    if (shouldShowRequestPermissionRationale(Manifest.permission.ACCESS_FINE_LOCATION)) {

                        // Show an expanation to the user After the user
                        // sees the explanation, try again to request the permission.

                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.ACCESS_FINE_LOCATION,
                                ConstantVariables.ACCESS_FINE_LOCATION);

                    } else {
                        // If user pressed never ask again on permission popup
                        // Show Snackbar with setting activity button to open App Info
                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, rootView,
                                ConstantVariables.ACCESS_FINE_LOCATION);

                    }
                }
                break;

        }
    }

    public void cancelRequest(int notifyItemAt) {
        int position = mFeedItemsList.indexOf(new FeedList(String.valueOf(notifyItemAt)));
        if (position >= 0 && uploadUtilMap != null && uploadUtilMap.size() > 0) {
            previewItemPosition--;
            OkHttpUploadHandler uploadAttachmentUtil = uploadUtilMap.get(notifyItemAt);
            uploadAttachmentUtil.cancelRequest();
            mFeedItemsList.remove(position);
            mFeedAdapter.notifyItemRemoved(position);
            NotificationManager notificationManager = (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.cancelAll();

            uploadUtilMap.remove(notifyItemAt);

        } else {
            /* If we got some connection related error at the time of content posting,
             * then we didn't get tag/position so remove all item from list of quick
             * content posting */
            if (previewItemPosition > 0) {
                for (int i = 0; i < previewItemPosition; i++) {
                    if (mFeedAdapter.getItemViewType(i + 1) == 12) {
                        OkHttpUploadHandler uploadAttachmentUtil = uploadUtilMap.get(i);
                        if (uploadAttachmentUtil != null)
                            uploadAttachmentUtil.cancelRequest();
                        mFeedItemsList.remove(i + 1);
                        mFeedAdapter.notifyItemRemoved(i + 1);
                    }
                }
                previewItemPosition = 0;
                uploadUtilMap.clear();
            }
        }
    }

    public class VerticalSpaceItemDecoration extends RecyclerView.ItemDecoration {

        private final int mVerticalSpaceHeight;

        public VerticalSpaceItemDecoration(int mVerticalSpaceHeight) {
            this.mVerticalSpaceHeight = mVerticalSpaceHeight;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent,
                                   RecyclerView.State state) {
            outRect.bottom = mVerticalSpaceHeight;
        }
    }

    public void scrollToTop(int position) {
        layoutManager.scrollToPositionWithOffset(position, 0);
    }


    /* Method for auto play videos in feeds */
    public void autoPlayVideos(int newState, boolean isNewPosted) {
        List<Thread> threads = new ArrayList<Thread>();

        playPosition = findThePlayingPosition(newState);

        if (newState == 0) {

            /* Pause previously played video which is not on screen now */
            if (oldPlayPosition != -1 && oldPlayPosition != playPosition) {
                if (holder != null) {
                    holder.pauseVideo(true);
                    oldPlayPosition = -1;
                }
            }

            if (playPosition != -1 && playPosition != oldPlayPosition) {

                final RecyclerView.ViewHolder holder = mFeedsRecyclerView.findViewHolderForLayoutPosition(playPosition);
                this.holder = (FeedAdapter.ListItemHolder) holder;

                if (this.holder != null && this.holder.getIsVideoCanAutoPlay() && this.holder.getVideoUrl() != null && !this.holder.getVideoUrl().isEmpty()) {
                    if (isNewPosted) {
                        this.holder.changePlayAgainIconVisibility(View.GONE);
                        this.holder.setPlaybackPosition(0);
                    }

                    if (Utils.getString(mContext, this.holder.getVideoUrl()) != null && new File(Utils.getString(mContext, this.holder.getVideoUrl())).exists()) {
                        this.holder.initVideoView(Utils.getString(mContext, this.holder.getVideoUrl()), (Activity) mContext);
                    } else {
                        this.holder.initVideoView(this.holder.getVideoUrl(), (Activity) mContext);
                    }

                    if (downloadVideos) {
                        startDownloadInBackground(this.holder.getVideoUrl());
                    }

                    //Bug fixing for freezing: Only the original thread that created a view hierarchy can touch its views
                    Thread t = new Thread() {
                        public void run() {
                            try {
                                synchronized (this) {
                                    wait(100);

                                    ((Activity) mContext).runOnUiThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            if (getActivity() instanceof MainActivity && !isPauseFromDrawer) {
                                                FeedsFragment.this.holder.playVideo();
                                            } else {
                                                FeedsFragment.this.holder.playVideo();
                                            }
                                        }
                                    });

                                }
                            } catch (InterruptedException e) {
                                e.printStackTrace();
                            }
                        }
                    };
                    t.start();
                    threads.add(t);
                }

                oldPlayPosition = playPosition;
            }

        } else {
            if (threads.size() > 0) {
                for (Thread t : threads) {
                    t.interrupt();
                    t.stop();
                    t.destroy();
                }
                threads.clear();
            }
        }
    }

    /* Method for find the video position on screen */
    private int findThePlayingPosition(int state) {

        int firstVisiblePosition = layoutManager.findFirstVisibleItemPosition();
        int lastVisiblePosition = layoutManager.findLastVisibleItemPosition();
        int playPosition = -1;
        int initialPercent = 33;

        for (int i = firstVisiblePosition; i <= lastVisiblePosition; i++) {
            final RecyclerView.ViewHolder holder = mFeedsRecyclerView.findViewHolderForLayoutPosition(i);
            if (holder instanceof FeedAdapter.ListItemHolder) {
                FeedAdapter.ListItemHolder cvh = (FeedAdapter.ListItemHolder) holder;

                if (cvh.mPlayIcon.getVisibility() == View.VISIBLE)
                    cvh.mPlayIcon.setVisibility(View.GONE);

                if (state != 0) {
                    return playPosition;
                }

                int percent = getVisiblePercent(cvh.getViAutoPlay());

                if (initialPercent < percent) {
                    playPosition = i;
                    initialPercent = percent;
                }

                if (i == lastVisiblePosition && initialPercent > 33) {
                    return playPosition;
                }
            }
        }

        return playPosition;
    }

    /* Method for calculate the visible percentage of video on screen */
    public int getVisiblePercent(View view) {

        final Rect mClipRect = new Rect();
        if (view == null || view.getVisibility() != View.VISIBLE || view.getParent() == null) {
            return 0;
        }

        if (!view.getGlobalVisibleRect(mClipRect)) {
            return 0;
        }

        final long visibleArea = (long) mClipRect.height() * mClipRect.width();
        final long totalViewArea = (long) view.getHeight() * view.getWidth();

        return (int) (100 * visibleArea / totalViewArea);
    }


    /* Starting Download Service to download video for future user */
    public void startDownloadInBackground(String url) {
        if ((Utils.getString(mContext, url) == null || !(new File(Utils.getString(mContext, url)).exists())) && url != null && !url.equalsIgnoreCase("null")) {

            // Passing params
            Data.Builder data = new Data.Builder();
            data.putString("url", url);

            OneTimeWorkRequest compressionWork =
                    new OneTimeWorkRequest.Builder(DownloadWorker.class)
                            .setInputData(data.build())
                            .build();
            WorkManager.getInstance().enqueue(compressionWork);
        }
    }


    /* Pause playing video */
    public void pauseVideos(boolean pauseFromDrawer) {
        if (!isFragmentVisible)
            return;

        isResumeVideo = false;
        if (!isPauseFromDrawer)
            this.isPauseFromDrawer = pauseFromDrawer;

        if (isAutoPlayVideo && playPosition != -1 && mFeedsRecyclerView.findViewHolderForAdapterPosition(playPosition) instanceof FeedAdapter.ListItemHolder) {
            final FeedAdapter.ListItemHolder cvh = (FeedAdapter.ListItemHolder) mFeedsRecyclerView.findViewHolderForAdapterPosition(playPosition);
            if (cvh != null && cvh.getIsVideoCanAutoPlay() && cvh.getVideoUrl() != null && !cvh.getVideoUrl().equalsIgnoreCase("null") && !cvh.getVideoUrl().isEmpty()) {
                cvh.pauseVideo(false);
            }
        }
    }

    /* Resume paused video */
    public void resumeVideos(boolean resumeFromDrawer) {

        if (!isFragmentVisible) {
            return;
        }

        if (VideoLightBox.isInPictureInPictureMode || AdvVideoView.isInPictureInPictureMode) {
            return;
        }

        if (playbackPosition > 0) {
            resumeVideoFromPlaybackState(playbackWindow, playbackPosition);
            playbackPosition = 0;
            playbackWindow = 0;

        } else if ((isPauseFromDrawer == resumeFromDrawer) && isAutoPlayVideo && !isResumeVideo && playPosition != -1
                && mFeedsRecyclerView.findViewHolderForAdapterPosition(playPosition) instanceof FeedAdapter.ListItemHolder) {
            final FeedAdapter.ListItemHolder cvh = (FeedAdapter.ListItemHolder) mFeedsRecyclerView.findViewHolderForAdapterPosition(playPosition);
            if (cvh != null && cvh.getVideoUrl() != null && !cvh.getVideoUrl().equalsIgnoreCase("null")
                    && !cvh.getVideoUrl().isEmpty() && cvh.getViAutoPlay().getVisibility() == View.VISIBLE) {
                cvh.playVideo();
            }
            isPauseFromDrawer = false;
        }
    }

    /* Resume video from playback state */
    private void resumeVideoFromPlaybackState(int resumeWindow, long playbackPosition) {
        if (isAutoPlayVideo && playPosition != -1 && mFeedsRecyclerView.findViewHolderForAdapterPosition(playPosition) instanceof FeedAdapter.ListItemHolder) {
            final FeedAdapter.ListItemHolder cvh = (FeedAdapter.ListItemHolder) mFeedsRecyclerView.findViewHolderForAdapterPosition(playPosition);
            if (cvh != null && cvh.getVideoUrl() != null && !cvh.getVideoUrl().equalsIgnoreCase("null") && !cvh.getVideoUrl().isEmpty()) {
                cvh.setResumeVideoPlaybackState(resumeWindow, playbackPosition);
            }
        }
    }

    /* Check stories need to display in feeds or not */
    private boolean isDisplayStories() {
        if (!mAppConst.isLoggedOutUser() && ConstantVariables.ENABLE_STORY == 1
                && PreferencesUtils.getIsStoryEnabled(mContext)) {
            return true;
        }
        return false;
    }
}
