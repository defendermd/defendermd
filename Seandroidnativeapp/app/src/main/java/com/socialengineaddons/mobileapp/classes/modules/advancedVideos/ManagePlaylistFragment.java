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

package com.socialengineaddons.mobileapp.classes.modules.advancedVideos;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import com.facebook.ads.AdError;
import com.facebook.ads.NativeAd;
import com.facebook.ads.NativeAdsManager;
import com.google.android.gms.ads.formats.NativeAppInstallAd;
import com.socialengineaddons.mobileapp.classes.common.ads.admob.AdFetcher;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommunityAdsLoadedListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.utils.CommunityAdsList;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;

import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.RecyclerViewAdapter;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class ManagePlaylistFragment extends BaseFragment implements SwipeRefreshLayout.OnRefreshListener,
        NativeAdsManager.Listener, OnCommunityAdsLoadedListener {

    private Context mContext;
    private View mRootView;
    private RecyclerView mRecyclerView;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private Snackbar mSnackbar;
    private String mManagePlaylistUrl, mCurrentSelectedModule;
    private int mLoadingPageNo = 1;
    private boolean isLoading = false, isAdLoaded = false, isVisibleToUser = false, isCommunityAds = false;
    private List<Object> mBrowseItemList;
    private JSONObject mResponseObject;
    private JSONArray mAdvertisementsArray;
    private AdFetcher mAdFetcher;
    private NativeAdsManager mListNativeAdsManager;
    private BrowseListItems mBrowseList;
    private AppConstant mAppConst;
    private RecyclerView.Adapter mManageAdapter;


    public static ManagePlaylistFragment newInstance(Bundle bundle) {
        // Required  public constructor
        ManagePlaylistFragment fragment = new ManagePlaylistFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = getActivity();
    }

    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (visible && !isVisibleToUser) {
            if(ConstantVariables.ADV_VIDEO_ADS_TYPE == ConstantVariables.TYPE_GOOGLE_ADS){
                mAdFetcher = new AdFetcher(mContext);
                mAdFetcher.loadAds(mBrowseItemList, mManageAdapter, ConstantVariables.ADV_VIDEO_ADS_POSITION);
            }
            makeRequest();
        } else if(mSnackbar != null && mSnackbar.isShown()) {
            mSnackbar.dismiss();
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        // Initializing member variables.
        mContext = getActivity();
        mAppConst = new AppConstant(mContext);
        mAppConst.setOnCommunityAdsLoadedListener(ManagePlaylistFragment.this);
        mBrowseItemList = new ArrayList<>();
        mBrowseList = new BrowseListItems();
        mManagePlaylistUrl = UrlUtil.ADV_VIDEO_PLAYLIST_MANAGE_URL;

        // Updating current selected module
        PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE);
        mCurrentSelectedModule = PreferencesUtils.getCurrentSelectedModule(mContext);

        // Inflate the layout for this fragment
        mRootView = inflater.inflate(R.layout.recycler_view_layout, container, false);
        // Getting the all views.
        getViews();

        // The number of Columns
        GridLayoutManager gridLayoutManager = new GridLayoutManager(mContext, 2);
        mRecyclerView.setLayoutManager(gridLayoutManager);
        mManageAdapter = new RecyclerViewAdapter(mContext, mBrowseItemList, false, 0,
                ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE, ManagePlaylistFragment.this,
                new OnItemClickListener() {

                    @Override
                    public void onItemClick(View view, int position) {
                        BrowseListItems listItems = (BrowseListItems) mBrowseItemList.get(position);

                        Intent mainIntent = GlobalFunctions.getIntentForModule(mContext,
                                listItems.getmListItemId(), mCurrentSelectedModule, null);
                        startActivityForResult(mainIntent, ConstantVariables.VIEW_PAGE_CODE);
                        getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                });
        mRecyclerView.setAdapter(mManageAdapter);

        gridLayoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int position) {
                switch (mManageAdapter.getItemViewType(position)) {
                    case RecyclerViewAdapter.TYPE_ADMOB:
                    case RecyclerViewAdapter.TYPE_FB_AD:
                    case RecyclerViewAdapter.VIEW_ITEM:
                    case RecyclerViewAdapter.TYPE_COMMUNITY_ADS:
                    case RecyclerViewAdapter.REMOVE_COMMUNITY_ADS:
                        return 1;
                    case RecyclerViewAdapter.VIEW_PROG:
                        return 2;//number of columns of the grid
                    default:
                        return -1;
                }
            }
        });

        if(ConstantVariables.ENABLE_ADV_VIDEO_ADS == 1){
            switch (ConstantVariables.ADV_VIDEO_ADS_TYPE){
                case ConstantVariables.TYPE_FACEBOOK_ADS :
                    mListNativeAdsManager = new NativeAdsManager(mContext,
                            mContext.getResources().getString(R.string.facebook_placement_id),
                            ConstantVariables.DEFAULT_AD_COUNT);
                    mListNativeAdsManager.setListener(this);
                    mListNativeAdsManager.loadAds(NativeAd.MediaCacheFlag.ALL);
                    break;
                case ConstantVariables.TYPE_COMMUNITY_ADS:
                    isCommunityAds = true;
                    break;
            }
        }

        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {

            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                final GridLayoutManager gridLayoutManager = (GridLayoutManager) mRecyclerView
                        .getLayoutManager();
                int firstVisibleItem = gridLayoutManager.findFirstVisibleItemPosition();
                int totalItemCount = gridLayoutManager.getItemCount();
                int lastVisibleCount = gridLayoutManager.findLastVisibleItemPosition() + 1;
                int visibleItemCount = lastVisibleCount - firstVisibleItem;

                int limit = firstVisibleItem + visibleItemCount;

                if (limit == totalItemCount && !isLoading) {

                    if (limit >= AppConstant.LIMIT && (AppConstant.LIMIT * mLoadingPageNo)
                            < mBrowseList.getmTotalItemCount()) {

                        mLoadingPageNo = mLoadingPageNo + 1;
                        isLoading = true;
                        loadMoreData(mManagePlaylistUrl + "&page=" + mLoadingPageNo);
                    }

                }
            }
        });

        return mRootView;
    }

    /**
     * Method to get the views.
     */
    private void getViews() {
        mRecyclerView = (RecyclerView) mRootView.findViewById(R.id.recycler_view);
        mRecyclerView.setHasFixedSize(true);
        mSwipeRefreshLayout = (SwipeRefreshLayout) mRootView.findViewById(R.id.swipe_refresh_layout);
        mSwipeRefreshLayout.setOnRefreshListener(this);
        mSwipeRefreshLayout.setColorSchemeResources(R.color.colorAccent);
    }

    /**
     * Method to make request to server to get the browse page response.
     */
    private void makeRequest() {

        mLoadingPageNo = 1;

        mAppConst.getJsonResponseFromUrl(mManagePlaylistUrl + "&page=" + mLoadingPageNo, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mRootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                if (mSnackbar != null && mSnackbar.isShown()) {
                    mSnackbar.dismiss();
                }

                isVisibleToUser = true;
                mBrowseItemList.clear();
                addItemsToList(jsonObject);
                if (isCommunityAds) {
                    mAppConst.getCommunityAds(ConstantVariables.ADV_VIDEO_ADS_POSITION,
                            ConstantVariables.ADV_VIDEO_ADS_TYPE);
                }
                mManageAdapter.notifyDataSetChanged();
                if (mSwipeRefreshLayout.isRefreshing()) {
                    mSwipeRefreshLayout.setRefreshing(false);
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mRootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                mSwipeRefreshLayout.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mSwipeRefreshLayout.setRefreshing(false);
                    }
                }, ConstantVariables.REFRESH_DELAY_TIME);

                if (isRetryOption) {
                    mSnackbar = SnackbarUtils.displaySnackbarWithAction(mContext, mRootView, message,
                            new SnackbarUtils.OnSnackbarActionClickListener() {
                                @Override
                                public void onSnackbarActionClick() {
                                    mRootView.findViewById(R.id.progressBar).setVisibility(View.VISIBLE);
                                    makeRequest();
                                }
                            });
                } else {
                    SnackbarUtils.displaySnackbar(mRootView, message);
                }

            }
        });
    }

    /**
     * Function to load more data on scrolling.
     *
     * @param url Url to send request on server.
     */
    private void loadMoreData(String url) {
        //add null , so the adapter will check view_type and show progress bar at bottom
        mBrowseItemList.add(null);
        mManageAdapter.notifyItemInserted(mBrowseItemList.size() - 1);
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mResponseObject = jsonObject;
                //   remove progress item
                if(isCommunityAds){
                    mAppConst.getCommunityAds(ConstantVariables.ADV_VIDEO_ADS_POSITION,
                            ConstantVariables.ADV_VIDEO_ADS_TYPE);
                } else{
                    mBrowseItemList.remove(mBrowseItemList.size() - 1);
                    mManageAdapter.notifyItemRemoved(mBrowseItemList.size());
                    addItemsToList(jsonObject);
                }
                mManageAdapter.notifyItemInserted(mBrowseItemList.size());
                isLoading = false;
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                SnackbarUtils.displaySnackbar(mRootView, message);
            }
        });
    }

    int j = 0;
    /**
     * Method to add browse page data into list.
     *
     * @param jsonObject Object which contains the browse page data.
     */
    public void addItemsToList(JSONObject jsonObject) {
        if (jsonObject != null) {
            int totalItemCount = jsonObject.optInt("totalItemCount");
            mBrowseList.setmTotalItemCount(totalItemCount);
            JSONArray dataResponseArray = jsonObject.optJSONArray("response");
            if (dataResponseArray != null && dataResponseArray.length() > 0) {
                mRootView.findViewById(R.id.message_layout).setVisibility(View.GONE);
                for (int i = 0; i < dataResponseArray.length(); i++) {
                    if ((isAdLoaded || AdFetcher.isAdLoaded()) && mBrowseItemList.size() != 0
                            && mBrowseItemList.size() % ConstantVariables.ADV_VIDEO_ADS_POSITION == 0) {
                        switch (ConstantVariables.ADV_VIDEO_ADS_TYPE){
                            case ConstantVariables.TYPE_FACEBOOK_ADS :
                                NativeAd ad = this.mListNativeAdsManager.nextNativeAd();
                                mBrowseItemList.add(ad);
                                break;
                            case ConstantVariables.TYPE_GOOGLE_ADS:
                                if(j < mAdFetcher.getAdList().size()) {
                                    NativeAppInstallAd nativeAppInstallAd = (NativeAppInstallAd) mAdFetcher.getAdList().get(j);
                                    j++;
                                    mBrowseItemList.add(nativeAppInstallAd);
                                }else {
                                    j = 0;
                                }
                                break;
                            default:
                                if(mAdvertisementsArray != null){
                                    if(j < mAdvertisementsArray.length()){
                                        mBrowseItemList.add(addCommunityAddsToList(j));
                                        j++;
                                    } else {
                                        j = 0;
                                    }
                                }
                                break;
                        }
                    }
                    JSONObject jsonDataObject = dataResponseArray.optJSONObject(i);
                    int playlistId = jsonDataObject.optInt("playlist_id");
                    int videoCount = jsonDataObject.optInt("video_count");
                    String title = jsonDataObject.optString("title");
                    String playlistImage = jsonDataObject.optString("image");
                    JSONArray menuArray = jsonDataObject.optJSONArray("menu");
                    mBrowseItemList.add(new BrowseListItems(playlistId, title, playlistImage,
                            videoCount, menuArray));

                }

            } else {
                mRootView.findViewById(R.id.message_layout).setVisibility(View.VISIBLE);
                TextView errorIcon = (TextView) mRootView.findViewById(R.id.error_icon);
                SelectableTextView errorMessage = (SelectableTextView) mRootView.findViewById(R.id.error_message);
                errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
                errorIcon.setText("\uf16a");
                errorMessage.setText(mContext.getResources().getString(R.string.no_music));
            }
        }
    }

    /***
     * Method to add community ads into the list.
     *
     * @param j Position, where ads will be added.
     * @return Returns the Community ads list at the desired position.
     */
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

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mAppConst.hideKeyboard();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        switch (resultCode) {
            case ConstantVariables.VIEW_PAGE_CODE:
                mSwipeRefreshLayout.post(new Runnable() {
                    @Override
                    public void run() {
                        mSwipeRefreshLayout.setRefreshing(true);
                        makeRequest();
                    }
                });
                break;
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mContext = context;
        if (mRecyclerView != null) {
            mRecyclerView.smoothScrollToPosition(0);
        }
    }

    @Override
    public void onRefresh() {
        /**
         * Showing Swipe Refresh animation on activity create
         * As animation won't start on onCreate, post runnable is used
         */
        mSwipeRefreshLayout.post(new Runnable() {
            @Override
            public void run() {
                mSwipeRefreshLayout.setRefreshing(true);
                makeRequest();
            }
        });
    }

    @Override
    public void onAdsLoaded() {
        if (!isAdLoaded) {
            isAdLoaded = true;
            for (int i = 0; i <= mBrowseItemList.size(); i++) {
                if (i != 0 && i % ConstantVariables.ADV_VIDEO_ADS_POSITION == 0) {
                    NativeAd ad = this.mListNativeAdsManager.nextNativeAd();
                    mBrowseItemList.add(i, ad);
                    mManageAdapter.notifyDataSetChanged();
                }
            }
        }
    }

    @Override
    public void onAdError(AdError adError) {

    }

    @Override
    public void onCommunityAdsLoaded(JSONArray advertisementsArray) {
        mAdvertisementsArray = advertisementsArray;

        int j = 0;
        if (!isAdLoaded && mAdvertisementsArray != null) {
            isAdLoaded = true;
            for (int i = 0; i <= mBrowseItemList.size(); i++) {
                if (i != 0 && i % ConstantVariables.ADV_VIDEO_ADS_POSITION == 0 &&
                        j < mAdvertisementsArray.length()) {
                    mBrowseItemList.add(i, addCommunityAddsToList(j));
                    j++;
                    mManageAdapter.notifyDataSetChanged();
                }
            }
        } else if (!(mBrowseItemList.size() < AppConstant.LIMIT)) {
                mBrowseItemList.remove(mBrowseItemList.size() - 1);
                mManageAdapter.notifyItemRemoved(mBrowseItemList.size());
                addItemsToList(mResponseObject);
        }
    }

    @Override
    public void setNestedScrollingEnabled(boolean enabled) {

    }
}
