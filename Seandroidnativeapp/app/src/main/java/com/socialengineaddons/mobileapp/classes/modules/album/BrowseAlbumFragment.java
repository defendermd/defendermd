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
 *
 */

package com.socialengineaddons.mobileapp.classes.modules.album;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.design.widget.BottomSheetDialog;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import android.widget.TextView;

import com.facebook.ads.AdError;
import com.facebook.ads.NativeAd;
import com.facebook.ads.NativeAdsManager;
import com.google.android.gms.ads.formats.NativeAppInstallAd;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.adapters.FilterViewAdapter;
import com.socialengineaddons.mobileapp.classes.common.ads.admob.AdFetcher;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommunityAdsLoadedListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.utils.CommunityAdsList;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GridSpacingItemDecorationUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.LinearDividerItemDecorationUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.common.adapters.RecyclerViewAdapter;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.utils.DataStorage;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.modules.store.adapters.SimpleSheetAdapter;
import com.socialengineaddons.mobileapp.classes.modules.store.utils.SheetItemModel;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * to handle interaction events.
 * Use the {@link BrowseAlbumFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class BrowseAlbumFragment extends BaseFragment implements SwipeRefreshLayout.OnRefreshListener,
        NativeAdsManager.Listener, OnCommunityAdsLoadedListener {

    private View rootView;
    private Context mContext;
    private List<Object> mBrowseItemList;
    private List<BrowseListItems> mCategoryList;
    private int  pageNumber = 1, mLoadingPageNo = 1, mTotalItemCount = 0, mUserId, mPreviousFilterPos = -1, mPreviousCategoryPos = -1;
    private String mBrowseAlbumUrl, mExtraModuleType, mCurrentSelectedModule, sortingId, categoryId;
    private AppConstant mAppConst;
    private AdFetcher mAdFetcher;
    private BrowseListItems mBrowseList;
    private JSONObject mBody;
    private JSONArray mDataResponse, mAdvertisementsArray, mFilterResponse;
    private boolean isLoading = false, isSearchTextSubmitted = false, isVisibleToUser = false, isFirstTab = false, mIsFilterSelected = false, isHideFilter = false, isSorting = false;
    private boolean isMemberAlbums = false, isAdLoaded = false, isSitePageAlbums = false, isSiteGroupAlbums = false, canCreate = true;
    private SwipeRefreshLayout swipeRefreshLayout;
    private RecyclerView mRecyclerView, mRecyclerViewCategory;
    private RecyclerView.Adapter mBrowseAdapter, mFilterAdapter;
    private HashMap<String, String> searchParams = new HashMap<>();
    private Snackbar snackbar;
    private NativeAdsManager listNativeAdsManager;
    private int mContentId, ignoredAlbumCount;
    private Bundle mBundle;
    private boolean isCommunityAds = false;
    private SimpleSheetAdapter mSheetAdapter;
    private BottomSheetDialog mBottomSheetDialog;


    @Override
    public void onPrepareOptionsMenu(final Menu menu) {
        super.onPrepareOptionsMenu(menu);
        MenuItem toggle = menu.findItem(R.id.viewToggle);
        if (toggle != null) {
            toggle.setVisible(false);
        }
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     * @return A new instance of fragment BrowseAlbumFragment.
     */
    public static BrowseAlbumFragment newInstance(Bundle bundle) {
        BrowseAlbumFragment fragment = new BrowseAlbumFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    public BrowseAlbumFragment() {
        // Required empty public constructor
    }

    @Override
    public void setNestedScrollingEnabled(boolean enabled) {
            if(mRecyclerView != null) {
                mRecyclerView.setNestedScrollingEnabled(enabled);
            }
    }

    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (visible && !isVisibleToUser && mContext != null) {
            if(mCurrentSelectedModule != null && !mCurrentSelectedModule.equals("core_main_album")){
                canCreate =false;
                PreferencesUtils.updateCurrentModule(mContext, "core_main_album");
                mCurrentSelectedModule = PreferencesUtils.getCurrentSelectedModule(mContext);
            }
            makeRequest();
        }
        if (!isVisible() && snackbar != null && snackbar.isShown()) {
            snackbar.dismiss();
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = getActivity();
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mAppConst = new AppConstant(mContext);
        mAppConst.setOnCommunityAdsLoadedListener(this);

        mBrowseItemList = new ArrayList<>();
        mCategoryList = new ArrayList<>();
        mBrowseList = new BrowseListItems();

        if (mAppConst.isLoggedOutUser())
            setHasOptionsMenu(true);

        // Inflate the layout for this fragment

      rootView = inflater.inflate(R.layout.recycler_view_layout, null);
        mRecyclerView = (RecyclerView) rootView.findViewById(R.id.recycler_view);
        mRecyclerViewCategory = rootView.findViewById(R.id.recycler_view_category);
        rootView.setBackgroundColor(ContextCompat.getColor(mContext, R.color.white));
        mRecyclerView.setHasFixedSize(true);
        mRecyclerViewCategory.setHasFixedSize(true);

        // The number of Columns
        GridLayoutManager mLayoutManager = new GridLayoutManager(mContext, 2);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mLayoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int position) {
                if (mBrowseAdapter.getItemViewType(position) == 0) {
                    return 2;
                } else {
                    return 1;
                }
            }
        });
        mRecyclerView.addItemDecoration(new GridSpacingItemDecorationUtil(mContext,
                R.dimen.loading_bar_height, mRecyclerView, true));

        // Set layout manager of filterView
        LinearLayoutManager layoutManager = new LinearLayoutManager(mContext);
        layoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRecyclerViewCategory.setLayoutManager(layoutManager);
        mRecyclerViewCategory.addItemDecoration(new LinearDividerItemDecorationUtil(mContext));

        // Updating current selected module
        mCurrentSelectedModule = PreferencesUtils.getCurrentSelectedModule(mContext);

        //Editing the url for browse album

        mBrowseAlbumUrl = UrlUtil.BROWSE_ALBUM_URL;

        if(getArguments() != null) {

            mBundle = getArguments();

            // If The Fragment Being called from User profile page.
            isMemberAlbums = mBundle.getBoolean("isMemberAlbums");
            isSitePageAlbums = mBundle.getBoolean("isSitePageAlbums", false);
            isSiteGroupAlbums = mBundle.getBoolean("isSiteGroupAlbums", false);
            mBrowseAlbumUrl = mBundle.getString(ConstantVariables.URL_STRING, mBrowseAlbumUrl);
            mContentId = mBundle.getInt(ConstantVariables.VIEW_PAGE_ID, 0);
            mExtraModuleType = mBundle.getString(ConstantVariables.EXTRA_MODULE_TYPE);
            isFirstTab = getArguments().getBoolean(ConstantVariables.IS_FIRST_TAB_REQUEST);
            canCreate = getArguments().getBoolean(ConstantVariables.CAN_CREATE, false);
            isHideFilter = getArguments().getBoolean("isHideFilter", false);
            if (isSitePageAlbums) {
                mExtraModuleType = "sitepage_album";
            } else if (isSiteGroupAlbums) {
                mExtraModuleType = "sitegroup_album";
            }
            mUserId = mBundle.getInt("user_id");

            /**
             * Add Search Params in url when the fragment is not being called from
             * user, page and group profile pages.
             */
            if (!isMemberAlbums && !isSitePageAlbums && !isSiteGroupAlbums && mExtraModuleType == null) {

                Set<String> searchArgumentSet = getArguments().keySet();

                for (String key : searchArgumentSet) {
                    String value = getArguments().getString(key);
                    if (value != null && !value.isEmpty()) {
                        searchParams.put(key, value);
                    }
                }
            }
        }

        //getting the reference of BrowseDataAdapter class

        mBrowseAdapter = new RecyclerViewAdapter(mContext, mBrowseItemList, true, false, 0,
                ConstantVariables.ALBUM_MENU_TITLE,
                new OnItemClickListener() {

                    @Override
                    public void onItemClick(View view, int position) {

                        BrowseListItems listItems = (BrowseListItems) mBrowseItemList.get(position);

                        boolean isAllowedToView = listItems.isAllowToView();

                        if (!isAllowedToView) {
                            SnackbarUtils.displaySnackbar(rootView,
                                    mContext.getResources().getString(R.string.unauthenticated_view_message));

                        } else if (canCreate && position == 0){
                            Intent createNewAlbum = new Intent(mContext, CreateNewEntry.class);
                            createNewAlbum.putExtra(ConstantVariables.CREATE_URL, AppConstant.DEFAULT_URL+"albums/upload?create_new_album=1");
                            createNewAlbum.putExtra(ConstantVariables.KEY_TOOLBAR_TITLE, mContext.getResources().getString(R.string.title_activity_create_new_album));
                            startActivityForResult(createNewAlbum, ConstantVariables.CREATE_REQUEST_CODE);
                            ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                        } else {
                            Intent mainIntent;

                            if (mExtraModuleType == null
                                    || (mExtraModuleType != null && mExtraModuleType.equals("userProfile"))) {
                                mainIntent = GlobalFunctions.getIntentForModule(mContext, listItems.getmListItemId(),
                                        ConstantVariables.ALBUM_MENU_TITLE, null);
                            } else {
                                mainIntent = GlobalFunctions.getIntentForSubModule(mContext, mContentId,
                                        listItems.getmListItemId(), mExtraModuleType);
                            }
                            if(mainIntent != null) {
                                // For the user profile/cover update.
                                if (mBundle != null && !mBundle.isEmpty() && mBundle.containsKey("isCoverRequest")) {
                                    Bundle bundle = mainIntent.getExtras();
                                    bundle.putBundle(ConstantVariables.USER_PROFILE_COVER_BUNDLE, mBundle);
                                    mainIntent.putExtras(bundle);
                                }
                                startActivityForResult(mainIntent, ConstantVariables.ALBUM_VIEW_PAGE);
                                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                            }
                        }

                    }
                });

        mRecyclerView.setAdapter(mBrowseAdapter);

        mFilterAdapter = new FilterViewAdapter(mContext, mCategoryList, mBrowseList,
                new OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {

                        mIsFilterSelected = true;
                        if (view.getTag() != null && view.getTag().equals("sort") && mBrowseList.getmSortFilterObject() != null && mBrowseList.getmSortFilterObject().length() > 0) {
                            List<SheetItemModel> mOptionsSortingList = new ArrayList<>();
                            Iterator iterator = mBrowseList.getmSortFilterObject().keys();
                            while (iterator.hasNext()) {
                                String key = (String) iterator.next();
                                String value = mBrowseList.getmSortFilterObject().optString(key);
                                if (value != null) {
                                    mOptionsSortingList.add(new SheetItemModel(value, key));
                                }
                            }
                            mSheetAdapter = new SimpleSheetAdapter(mOptionsSortingList);
                            mSheetAdapter.setOnItemClickListener(new SimpleSheetAdapter.OnItemClickListener() {
                                @Override
                                public void onItemClick(SheetItemModel item, int position) {

                                    if (mPreviousFilterPos != position) {
                                        sortingId = item.getKey();
                                        categoryId = "";
                                        if (sortingId.equals("none")) {
                                            sortingId = "";
                                        }
                                        mPreviousFilterPos = position;
                                        makeRequest();
                                    }
                                    mBottomSheetDialog.dismiss();
                                }
                            });
                            View inflateView = LayoutInflater.from(mContext).inflate(R.layout.fragmen_cart, null);
                            RecyclerView recyclerView = (RecyclerView) inflateView.findViewById(R.id.recycler_view);
                            inflateView.findViewById(R.id.cart_bottom).setVisibility(View.GONE);
                            recyclerView.getLayoutParams().height = RecyclerView.LayoutParams.WRAP_CONTENT;
                            recyclerView.setHasFixedSize(true);
                            recyclerView.setLayoutManager(new LinearLayoutManager(mContext));
                            recyclerView.setAdapter(mSheetAdapter);
                            mBottomSheetDialog = new BottomSheetDialog(mContext);
                            mBottomSheetDialog.setContentView(inflateView);
                            mBottomSheetDialog.show();

                            mBottomSheetDialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
                                @Override
                                public void onDismiss(DialogInterface dialog) {
                                    Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.background_rounded_corner_grey).mutate();
                                    if (sortingId != null && sortingId.equals("")) {
                                        ((TextView) view.findViewById(R.id.filter_name)).setTextColor(mContext.getResources().getColor(R.color.black));
                                        drawable.setColorFilter(ContextCompat.getColor(mContext, R.color.grey_light), PorterDuff.Mode.SRC_ATOP);
                                    } else {
                                        drawable.setColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor), PorterDuff.Mode.SRC_ATOP);
                                        ((TextView) view.findViewById(R.id.filter_name)).setTextColor(mContext.getResources().getColor(R.color.white));
                                    }
                                    view.setBackground(drawable);

                                }
                            });

                        } else {
                            if (mPreviousCategoryPos == position) {
                                sortingId = "";
                                categoryId = "";
                                mPreviousCategoryPos = -1;
                            } else {
                                categoryId = view.getTag().toString();
                                sortingId = "";
                                mPreviousCategoryPos = position;
                            }
                            makeRequest();
                        }
                    }
                });

        mRecyclerViewCategory.setAdapter(mFilterAdapter);

        swipeRefreshLayout = (SwipeRefreshLayout) rootView.findViewById(R.id.swipe_refresh_layout);
        swipeRefreshLayout.setOnRefreshListener(this);
        swipeRefreshLayout.setPadding(0, mContext.getResources().getDimensionPixelSize(R.dimen.dimen_7dp),
                0, 0);
        swipeRefreshLayout.setColorSchemeResources(R.color.colorAccent);
        if(ConstantVariables.ENABLE_ALBUM_ADS == 1) {
            switch (ConstantVariables.ALBUM_ADS_TYPE){
                case ConstantVariables.TYPE_FACEBOOK_ADS:
                    listNativeAdsManager = new NativeAdsManager(mContext,
                            mContext.getResources().getString(R.string.facebook_placement_id),
                            ConstantVariables.DEFAULT_AD_COUNT);
                    listNativeAdsManager.setListener(this);
                    listNativeAdsManager.loadAds(NativeAd.MediaCacheFlag.ALL);
                    break;
                case ConstantVariables.TYPE_GOOGLE_ADS:
                    mAdFetcher = new AdFetcher(mContext);
                    mAdFetcher.loadAds(mBrowseItemList,mBrowseAdapter,ConstantVariables.ALBUM_ADS_POSITION);
                    break;
                default:
                    isCommunityAds = true;
                    break;
            }
        }

        // Making server call when the album fragment is launched from FragmentLoadActivity.
        if (((!isMemberAlbums && !isSiteGroupAlbums && !isSitePageAlbums)
                || mBundle != null && !mBundle.isEmpty() && mBundle.containsKey("isCoverRequest")) || isFirstTab){
            makeRequest();
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

                int limit=firstVisibleItem+visibleItemCount;

                if(limit == totalItemCount && !isLoading) {

                    if((limit + ignoredAlbumCount) >= AppConstant.LIMIT && (AppConstant.LIMIT * mLoadingPageNo)  <
                            mBrowseList.getmTotalItemCount()){

                        mLoadingPageNo = mLoadingPageNo + 1;
                        String albumsListingUrl = getBrowseAlbumUrl() + "&page=" + mLoadingPageNo;

                        isLoading = true;
                        loadMoreData(albumsListingUrl);
                    }

                }
            }
        });

        return rootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mAppConst.hideKeyboard();
    }

    public void makeRequest() {

        mLoadingPageNo = 1;
        String albumsListingUrl = getBrowseAlbumUrl() + "&page=" + pageNumber;

        if (!isSearchTextSubmitted && !isMemberAlbums && !isSitePageAlbums && !isSiteGroupAlbums
                && mExtraModuleType == null) {

            try {

                // Don't show data in case of searching and User Profile Tabs.
                mBrowseItemList.clear();
                String tempData = DataStorage.getResponseFromLocalStorage(mContext, DataStorage.ALBUM_FILE);
                if (tempData != null) {
                    swipeRefreshLayout.post(new Runnable() {
                        @Override
                        public void run() {
                            swipeRefreshLayout.setRefreshing(true);
                        }
                    });
                    rootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                    JSONObject jsonObject = new JSONObject(tempData);
                    addDataToList(jsonObject);
                    mBrowseAdapter.notifyDataSetChanged();
                    if (!mIsFilterSelected) {
                        mFilterAdapter.notifyDataSetChanged();
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        mAppConst.getJsonResponseFromUrl(albumsListingUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mBrowseItemList.clear();
                isVisibleToUser = true;
                rootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                if (snackbar != null && snackbar.isShown()) {
                    snackbar.dismiss();
                }
                addDataToList(jsonObject);
                if(isCommunityAds){
                    mAppConst.getCommunityAds(ConstantVariables.ALBUM_ADS_POSITION,
                            ConstantVariables.ALBUM_ADS_TYPE);
                }
                // Don't save data in case of searching and User Profile Tabs.
                if(!isSearchTextSubmitted && !isMemberAlbums && !isSitePageAlbums && !isSiteGroupAlbums
                        && mExtraModuleType == null) {
                    DataStorage.createTempFile(mContext,DataStorage.ALBUM_FILE, jsonObject.toString());
                }
                mBrowseAdapter.notifyDataSetChanged();
                if (!mIsFilterSelected) {
                    mFilterAdapter.notifyDataSetChanged();
                }
                if (swipeRefreshLayout.isRefreshing()) {
                    swipeRefreshLayout.setRefreshing(false);
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                rootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                swipeRefreshLayout.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        swipeRefreshLayout.setRefreshing(false);
                    }
                }, ConstantVariables.REFRESH_DELAY_TIME);
                if (isRetryOption) {
                    snackbar = SnackbarUtils.displaySnackbarWithAction(getActivity(), rootView, message,
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

    private  void loadMoreData(String url){
        //add null , so the adapter will check view_type and show progress bar at bottom
        mBrowseItemList.add(null);
        mBrowseAdapter.notifyItemInserted(mBrowseItemList.size() - 1);

        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mBody = jsonObject;
                if(isCommunityAds){
                    mAppConst.getCommunityAds(ConstantVariables.ALBUM_ADS_POSITION,
                            ConstantVariables.ALBUM_ADS_TYPE);
                } else {
                    // remove progress item
                    mBrowseItemList.remove(mBrowseItemList.size() - 1);
                    mBrowseAdapter.notifyItemRemoved(mBrowseItemList.size());
                    addDataToList(jsonObject);
                }
                mBrowseAdapter.notifyItemInserted(mBrowseItemList.size());
                isLoading = false;
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                SnackbarUtils.displaySnackbar(rootView, message);
            }
        });
    }


    int j = 0;
    public void addDataToList(JSONObject jsonObject){
        mBody = jsonObject;
        mTotalItemCount = mBody.optInt("totalItemCount");
        mBrowseList.setmTotalItemCount(mTotalItemCount);
        mDataResponse = mBody.optJSONArray("response");
        mFilterResponse = mBody.optJSONArray("filter");

        if (!isHideFilter && mFilterResponse != null && mFilterResponse.length() > 0) {
            mRecyclerViewCategory.setVisibility(View.VISIBLE);
            mCategoryList.clear();
            for (int i = 0; i < mFilterResponse.length(); i++) {
                JSONObject jsonFilterObject = mFilterResponse.optJSONObject(i);
                String filterName = jsonFilterObject.optString("name");
                if (filterName.equals("sort")) {
                    mBrowseList.setmSortFilterObject(jsonFilterObject.optJSONObject("multiOptions"));
                    mCategoryList.add(0, new BrowseListItems(filterName, mContext.getResources().getString(R.string.sort), false));

                } else if (filterName.equals("category_id")) {
                    JSONObject categoryObject = jsonFilterObject.optJSONObject("multiOptions");
                    if (categoryObject != null) {
                        Iterator iterator = categoryObject.keys();
                        while (iterator.hasNext()) {
                            String key = (String) iterator.next();
                            String value = categoryObject.optString(key);
                            if (value != null) {
                                mCategoryList.add(new BrowseListItems(key, value, false));
                            }
                        }
                    }
                }
            }
        } else {
            mRecyclerViewCategory.setVisibility(View.GONE);
        }

        if(mDataResponse != null && mDataResponse.length() > 0) {
            rootView.findViewById(R.id.message_layout).setVisibility(View.GONE);
            if (canCreate && mBrowseItemList.size() == 0) {
                ignoredAlbumCount = -1;
                mBrowseItemList.add(new BrowseListItems(ConstantVariables.KEY_CREATE_NEW_ALBUM, mContext.getResources().getString(R.string.title_activity_create_new_album),
                        null, 0, 0, 0, 0, 0, true));
            }
            for (int i = 0; i < mDataResponse.length(); i++) {
                if ((isAdLoaded || AdFetcher.isAdLoaded()) && mBrowseItemList.size() != 0
                        && mBrowseItemList.size() % ConstantVariables.ALBUM_ADS_POSITION == 0) {
                    switch (ConstantVariables.ALBUM_ADS_TYPE){
                        case ConstantVariables.TYPE_FACEBOOK_ADS:
                            NativeAd ad = this.listNativeAdsManager.nextNativeAd();
                            mBrowseItemList.add(ad);
                            break;
                        case ConstantVariables.TYPE_GOOGLE_ADS:
                            if(mAdFetcher.getAdList() != null && !mAdFetcher.getAdList().isEmpty()){
                                if(j < mAdFetcher.getAdList().size()) {
                                    NativeAppInstallAd nativeAppInstallAd = (NativeAppInstallAd) mAdFetcher.getAdList().get(j);
                                    j++;
                                    mBrowseItemList.add(nativeAppInstallAd);
                                }else {
                                    j = 0;
                                }
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
                JSONObject jsonDataObject = mDataResponse.optJSONObject(i);
                int album_id = jsonDataObject.optInt("album_id");
                int comment_count = jsonDataObject.optInt("comment_count");
                int photo_count = jsonDataObject.optInt("photo_count");
                int view_count = jsonDataObject.optInt("view_count");
                int like_count = jsonDataObject.optInt("like_count");
                String title = jsonDataObject.optString("title");
                String image = jsonDataObject.optString("image");
                String owner_title = jsonDataObject.optString("owner_title");
                int allow_to_view = jsonDataObject.optInt("allow_to_view");
                int searchable = jsonDataObject.optInt("search");
                if (searchable == 1 && allow_to_view == 1) {
                    mBrowseItemList.add(new BrowseListItems(image, title, owner_title,
                            photo_count, comment_count, view_count, like_count, album_id, true));
                } else {
                    ignoredAlbumCount++;
                }
            }
            // Show End of Result Message when there are less results
            if(mTotalItemCount <= AppConstant.LIMIT * mLoadingPageNo){
                 mBrowseItemList.add(ConstantVariables.FOOTER_TYPE);
            }
        }else {
            rootView.findViewById(R.id.message_layout).setVisibility(View.VISIBLE);
            TextView errorIcon = (TextView) rootView.findViewById(R.id.error_icon);
            SelectableTextView errorMessage = (SelectableTextView) rootView.findViewById(R.id.error_message);
            errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            errorIcon.setText("\uf1c5");
            errorMessage.setText(mContext.getResources().getString(R.string.no_albums));
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
                isAdLoaded = false;
                makeRequest();
                if (listNativeAdsManager != null) {
                    listNativeAdsManager.loadAds(NativeAd.MediaCacheFlag.ALL);
                }
            }
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        switch (resultCode){
            case ConstantVariables.ALBUM_VIEW_PAGE:
                swipeRefreshLayout.post(new Runnable() {
                    @Override
                    public void run() {
                        swipeRefreshLayout.setRefreshing(true);
                        makeRequest();
                    }
                });
                break;
        }

    }

    private String getBrowseAlbumUrl(){

        String albumsListingUrl = mBrowseAlbumUrl + "?limit=" + AppConstant.LIMIT;

        // Add user_id in the url if the fragment is being called from user profile page.
        if(mUserId != 0){
            albumsListingUrl += "&user_id=" + mUserId;
        } else {
            /* Filter's are applicable only browse album not on user's album */
            if (sortingId != null && !sortingId.isEmpty()) {
                albumsListingUrl += "&sort=" + sortingId;
            }

            if (categoryId != null && !categoryId.isEmpty()) {
                albumsListingUrl += "&category_id=" + categoryId;
            }
        }

        // Adding Search Params in the url if the fragment is being called from search page.
        if(searchParams != null && searchParams.size() != 0){
            isSearchTextSubmitted = true;
            albumsListingUrl = mAppConst.buildQueryString(albumsListingUrl, searchParams);
        }

        return albumsListingUrl;
    }

    @Override
    public void onAdsLoaded() {
        if (!isAdLoaded) {
            isAdLoaded = true;
            for (int i = 0 ; i <= mBrowseItemList.size(); i++) {
                if (i != 0 && i % ConstantVariables.ALBUM_ADS_POSITION == 0) {
                    NativeAd ad = this.listNativeAdsManager.nextNativeAd();
                    mBrowseItemList.add(i, ad);
                    mBrowseAdapter.notifyDataSetChanged();
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

        if(!isAdLoaded && mAdvertisementsArray != null){
            isAdLoaded = true;
            int j = 0;
            for (int i = 0 ; i <= mBrowseItemList.size(); i++) {
                if (i != 0 && i % ConstantVariables.POLL_ADS_POSITION == 0 &&
                        j < mAdvertisementsArray.length()) {
                    mBrowseItemList.add(i, addCommunityAddsToList(j));
                    j++;
                    mBrowseAdapter.notifyDataSetChanged();
                }
            }
        } else if (!(mBrowseItemList.size() < AppConstant.LIMIT)) {
            mBrowseItemList.remove(mBrowseItemList.size() - 1);
            mBrowseAdapter.notifyItemRemoved(mBrowseItemList.size());
            addDataToList(mBody);
        }

    }
}
