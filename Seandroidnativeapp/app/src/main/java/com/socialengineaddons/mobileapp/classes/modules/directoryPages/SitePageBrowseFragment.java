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

package com.socialengineaddons.mobileapp.classes.modules.directoryPages;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewCompat;
import android.support.v4.view.ViewPager;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.CardView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;

import com.facebook.ads.AdError;
import com.facebook.ads.NativeAd;
import com.facebook.ads.NativeAdsManager;
import com.google.android.gms.ads.formats.NativeAppInstallAd;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.BrowseDataAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.SlideShowAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.SpinnerAdapter;
import com.socialengineaddons.mobileapp.classes.common.ads.admob.AdFetcher;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommunityAdsLoadedListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.GridViewWithHeaderAndFooter;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.CommunityAdsList;
import com.socialengineaddons.mobileapp.classes.common.utils.DataStorage;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.SlideShowListItems;
import com.socialengineaddons.mobileapp.classes.modules.store.ui.CircleIndicator;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;



/**
 * A simple {@link Fragment} subclass.
 */
public class SitePageBrowseFragment extends BaseFragment implements
        AdapterView.OnItemClickListener, SwipeRefreshLayout.OnRefreshListener, AbsListView.OnScrollListener,
        NativeAdsManager.Listener, AdapterView.OnItemSelectedListener, OnCommunityAdsLoadedListener {

    View rootView, footerView;
    private int mUserId, pageNumber = 1, mTotalItemCount = 0, mLoadingPageNo = 1;
    private String  mBrowsePageUrl, mCurrentSelectedModule;
    private AppConstant mAppConst;
    private AdFetcher mAdFetcher;
    private GridViewWithHeaderAndFooter mGridView;
    private JSONObject mBody;
    private List<Object> mBrowseItemList;
    private BrowseListItems mBrowseList;
    private BrowseDataAdapter mBrowseDataAdapter;
    private SwipeRefreshLayout swipeRefreshLayout;
    private boolean isLoading = false, isSearchTextSubmitted = false, isMemberPages = false,
            isAdLoaded = false, isVisibleToUser = false, isCommunityAds = false, isFirstTab = false;
    private Context mContext;
    private HashMap<String, String> searchParams;
    Snackbar snackbar;
    private NativeAdsManager listNativeAdsManager;
    private boolean isCategoryResults = false, isLoadSubCategory = true, isLoadSubSubcategory = true, isFirstRequest = true;
    private int mCategoryId;
    Spinner subCategorySpinner, subSubCategorySpinner;
    SpinnerAdapter subCategoryAdapter, subSubCategoryAdapter;
    private String mSubCategoryId, mSubSubCategoryId;
    private CardView subCategoryLayout, subSubCategoryLayout;
    private LinearLayout categoryFilterBlock;
    private int mSelectedItem = -1, mSubsubcategorySelectedItem = -1;
    private HashMap<String, String> postParams = new HashMap<>();
    private JSONArray mDataResponse, mSubCategoryResponse = null, mSubSubCategoryResponse = null;
    private ViewPager mSlideShowPager;
    private CircleIndicator mCircleIndicator;
    private SlideShowAdapter mSlideShowAdapter;
    private List<SlideShowListItems> mSlideShowItemList;
    private LinearLayout mSlideShowLayout;
    private Spinner spinner;
    private SpinnerAdapter adapter;
    private String mPagesFilter = "";
    private int mFeaturedCount = 0;
    private JSONArray mAdvertisementsArray;


    public static SitePageBrowseFragment newInstance(Bundle bundle) {
        // Required public constructor
        SitePageBrowseFragment fragment = new SitePageBrowseFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);

        if (visible && !isVisibleToUser && mContext != null) {
            sendRequestToServer();
        }
        if (!isVisible() && snackbar != null && snackbar.isShown()) {
            snackbar.dismiss();
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mContext = context;
        if(mGridView != null){
            mGridView.smoothScrollToPosition(0);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        mBrowseItemList = new ArrayList<>();
        mBrowseList = new BrowseListItems();
        mSlideShowItemList = new ArrayList<>();

        searchParams = new HashMap<>();
        mAppConst = new AppConstant(getActivity());
        mAppConst.setOnCommunityAdsLoadedListener(this);

        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.grid_view_layout, container, false);
        footerView = CustomViews.getFooterView(inflater);
        mSlideShowLayout = (LinearLayout) inflater.inflate(R.layout.slide_show_header, container, false);
        spinner = (Spinner) rootView.findViewById(R.id.filter_view);
        rootView.findViewById(R.id.eventFilterBlock).setVisibility(View.VISIBLE);

        mSlideShowLayout = (LinearLayout) inflater.inflate(R.layout.slide_show_header, container, false);
        mSlideShowPager = (ViewPager) mSlideShowLayout.findViewById(R.id.slide_show_pager);
        mCircleIndicator = (CircleIndicator) mSlideShowLayout.findViewById(R.id.circle_indicator);

        mGridView = (GridViewWithHeaderAndFooter) rootView.findViewById(R.id.gridView);

        mGridView.addFooterView(footerView);
        mGridView.addHeaderView(mSlideShowLayout);
        footerView.setVisibility(View.GONE);

        CustomViews.initializeGridLayout(mContext, AppConstant.getNumOfColumns(mContext), mGridView);
        ViewCompat.setNestedScrollingEnabled(mGridView, true);

        mCurrentSelectedModule = PreferencesUtils.getCurrentSelectedModule(mContext);
        if(mCurrentSelectedModule != null && !mCurrentSelectedModule.equals("sitepage")){
            PreferencesUtils.updateCurrentModule(mContext, "sitepage");
            mCurrentSelectedModule = PreferencesUtils.getCurrentSelectedModule(mContext);
        }

        mBrowsePageUrl = UrlUtil.BROWSE_SITE_PAGE_URL;

        mBrowseDataAdapter = new BrowseDataAdapter(getActivity(), R.layout.page_item_view, mBrowseItemList);
        mGridView.setAdapter(mBrowseDataAdapter);
        mGridView.setOnScrollListener(this);
        mGridView.setOnItemClickListener(this);


        /*
        GET SEARCH ARGUMENTS AND ADD THESE PARAMETERS TO THE URL
         */

        if(getArguments() != null) {
            mSlideShowLayout.setVisibility(View.GONE);
            Bundle bundle = getArguments();

            // If The Fragment Being called from User profile page.
            isMemberPages = bundle.getBoolean("isMemberPages");
            mUserId = bundle.getInt("user_id");

            isCategoryResults = bundle.getBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, false);
            mCategoryId = bundle.getInt(ConstantVariables.VIEW_PAGE_ID, 0);
            postParams.put("category_id", String.valueOf(mCategoryId));
            isFirstTab = getArguments().getBoolean(ConstantVariables.IS_FIRST_TAB_REQUEST);

            if(!isMemberPages && !isCategoryResults) {

                Set<String> searchArgumentSet = getArguments().keySet();

                for (String key : searchArgumentSet) {
                    String value = getArguments().getString(key, null);
                    if (value != null && !value.isEmpty()) {
                        searchParams.put(key, value);
                    }
                }

            }

        } else {
            mSlideShowAdapter = new SlideShowAdapter(mContext, R.layout.list_item_slide_show,
                    mSlideShowItemList, new OnItemClickListener() {
                @Override
                public void onItemClick(View view, int position) {
                    SlideShowListItems listItems =  mSlideShowItemList.get(position);
                    Intent mainIntent = GlobalFunctions.getIntentForModule(mContext, listItems.getmListItemId(),
                            PreferencesUtils.getCurrentSelectedModule(mContext), null);
                    startActivityForResult(mainIntent, ConstantVariables.VIEW_PAGE_CODE);
                    getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                }
            });

            mSlideShowPager.setAdapter(mSlideShowAdapter);
            sendRequestForFeaturedContent();
        }

        swipeRefreshLayout = (SwipeRefreshLayout) rootView.findViewById(R.id.swipe_refresh_layout);
        swipeRefreshLayout.setOnRefreshListener(this);
        swipeRefreshLayout.setColorSchemeResources(R.color.colorAccent);

        /**
         * Show Order by Spinner when fragment is loaded from dashboard.
         */
        if(isCategoryResults){

            rootView.findViewById(R.id.eventFilterBlock).setVisibility(View.GONE);

            categoryFilterBlock = (LinearLayout) rootView.findViewById(R.id.category_filter_block);
            categoryFilterBlock.setVisibility(View.VISIBLE);
            categoryFilterBlock.findViewById(R.id.toolbar).setVisibility(View.GONE);

            subCategoryLayout = (CardView) rootView.findViewById(R.id.categoryFilterLayout);
            subSubCategoryLayout = (CardView) rootView.findViewById(R.id.subCategoryFilterLayout);
            subCategorySpinner = (Spinner) subCategoryLayout.findViewById(R.id.filter_view);
            subSubCategorySpinner = (Spinner) subSubCategoryLayout.findViewById(R.id.filter_view);


            /*
            Add swipeRefreshLayout layout below category filter
             */
            RelativeLayout.LayoutParams layoutParams = CustomViews.getFullWidthRelativeLayoutParams();
            layoutParams.addRule(RelativeLayout.BELOW, R.id.category_filter_block);
            swipeRefreshLayout.setLayoutParams(layoutParams);

            subCategoryAdapter = new SpinnerAdapter(mContext, R.layout.simple_text_view, mSelectedItem);
            subCategoryAdapter.add(getResources().getString(R.string.select_sub_category_text));

            //    ArrayAdapter adapter = new ArrayAdapter(this,R.layout.simple_spinner_item,list);
            subCategoryAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            subCategorySpinner.setAdapter(subCategoryAdapter);
            subCategorySpinner.setSelection(0, false);
            subCategorySpinner.setOnItemSelectedListener(this);
            subCategorySpinner.setTag("subCategory");

            subSubCategoryAdapter = new SpinnerAdapter(mContext, R.layout.simple_text_view, mSubsubcategorySelectedItem);
            subSubCategoryAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            subSubCategorySpinner.setAdapter(subSubCategoryAdapter);
            subSubCategorySpinner.setSelection(0, false);
            subSubCategorySpinner.setOnItemSelectedListener(this);
            subSubCategorySpinner.setTag("subSubCategory");
        } else {
            rootView.findViewById(R.id.eventFilterBlock).setVisibility(View.VISIBLE);
            adapter = new SpinnerAdapter(mContext, R.layout.simple_text_view, mSelectedItem);

            /* Add pages filter type to spinner using adapter */
            adapter.add(getResources().getString(R.string.browse_event_filter_sell_all));
            adapter.add(mContext.getResources().getString(R.string.featured));
            adapter.add(mContext.getResources().getString(R.string.sponsored));

            adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            spinner.setAdapter(adapter);
            spinner.setOnItemSelectedListener(this);
            spinner.setTag("pagesFilter");
        }

        // Hide Filter View if Fragment is being called from user profile page or search page
        if ((searchParams != null && searchParams.size() != 0) || isMemberPages) {
            rootView.findViewById(R.id.eventFilterBlock).setVisibility(View.GONE);
            if(categoryFilterBlock != null){
                categoryFilterBlock.setVisibility(View.GONE);
            }
        }


        if(ConstantVariables.ENABLE_SITE_PAGE_ADS == 1) {
            switch (ConstantVariables.SITE_PAGE_ADS_TYPE){
                case ConstantVariables.TYPE_FACEBOOK_ADS:
                    listNativeAdsManager = new NativeAdsManager(mContext,
                            mContext.getResources().getString(R.string.facebook_placement_id),
                            ConstantVariables.DEFAULT_AD_COUNT);
                    listNativeAdsManager.setListener(this);
                    listNativeAdsManager.loadAds(NativeAd.MediaCacheFlag.ALL);
                    break;
                case ConstantVariables.TYPE_GOOGLE_ADS:
                    mAdFetcher = new AdFetcher(mContext);
                    mAdFetcher.loadAds(mBrowseItemList,mBrowseDataAdapter,ConstantVariables.SITE_PAGE_ADS_POSITION);
                    break;
                default:
                    isCommunityAds = true;
                    break;
            }
        }

        if (!isMemberPages || isFirstTab) {
            sendRequestToServer();
        }

        return rootView;
    }

    private void sendRequestForFeaturedContent() {

        String featuredContentUrl = UrlUtil.BROWSE_SITE_PAGE_URL + "limit=" + AppConstant.FEATURED_CONTENT_LIMIT +
                "&show=5&page=1";

        mSlideShowItemList.clear();
        String tempData = DataStorage.getResponseFromLocalStorage(mContext,DataStorage.SITE_PAGE_FEATURED_CONTENT);
        if (tempData != null) {
            try {
                JSONObject jsonObject = new JSONObject(tempData);
                addDataToFeaturedList(jsonObject);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        mAppConst.getJsonResponseFromUrl(featuredContentUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mSlideShowItemList.clear();
                addDataToFeaturedList(jsonObject);
                DataStorage.createTempFile(mContext,DataStorage.SITE_PAGE_FEATURED_CONTENT, jsonObject.toString());
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

            }
        });
    }

    private void addDataToFeaturedList(JSONObject mFeaturedObject) {
        if (mFeaturedObject != null) {
            mDataResponse = mFeaturedObject.optJSONArray("response");
            mFeaturedCount = mFeaturedObject.optInt("totalItemCount");
            if(mDataResponse != null && mDataResponse.length() > 0) {
                mSlideShowLayout.setVisibility(View.VISIBLE);
                for (int i = 0; i < 5 && i < mDataResponse.length(); i++) {
                    JSONObject jsonDataObject = mDataResponse.optJSONObject(i);
                    int page_id = jsonDataObject.optInt("page_id");
                    String title = jsonDataObject.optString("title");
                    String image_icon = jsonDataObject.optString("image");

                    //Add data to slide show adapter
                    mSlideShowItemList.add(new SlideShowListItems(image_icon, title, page_id));
                    mSlideShowAdapter.notifyDataSetChanged();
                }

                if (mDataResponse.length() > 1) {
                    mCircleIndicator.setViewPager(mSlideShowPager);
                }
            } else {
                mSlideShowLayout.setVisibility(View.GONE);
            }

        }
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view, int position, long l) {

        BrowseListItems listItems = (BrowseListItems) mBrowseItemList.get(position);

        boolean isAllowedToView = listItems.isAllowToView();
        String groupTitle = listItems.getmBrowseListTitle();

        if (!isAllowedToView) {
            SnackbarUtils.displaySnackbar(rootView,
                    mContext.getResources().getString(R.string.unauthenticated_view_message));
        }else {
            Intent mainIntent = GlobalFunctions.getIntentForModule(mContext, listItems.getmListItemId(),
                    mCurrentSelectedModule, null);
            mainIntent.putExtra(ConstantVariables.CONTENT_TITLE, groupTitle);
            startActivityForResult(mainIntent, ConstantVariables.VIEW_PAGE_CODE);
            getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }

    }

    /**
     * Function to send request to server
     */
    public void sendRequestToServer() {
        try {
            mLoadingPageNo = 1;


            String browsePageUrl = getBrowsePageUrl() + "&page=" + pageNumber;

            // Don't show data in case of searching and User Profile Tabs.
            if (!isSearchTextSubmitted && !isMemberPages && !isCategoryResults) {
                mBrowseItemList.clear();
                String tempData = DataStorage.getResponseFromLocalStorage(mContext, DataStorage.SITE_PAGE_FILE);
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
                }

            }

            mAppConst.getJsonResponseFromUrl(browsePageUrl, new OnResponseListener() {
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
                        mAppConst.getCommunityAds(ConstantVariables.SITE_PAGE_ADS_POSITION,
                                ConstantVariables.SITE_PAGE_ADS_TYPE);
                    }

                    // Don't save data in case of searching and User Profile Tabs.
                    if (!isSearchTextSubmitted && !isMemberPages && !isCategoryResults) {
                        DataStorage.createTempFile(mContext, DataStorage.SITE_PAGE_FILE, jsonObject.toString());
                    }
                    if (swipeRefreshLayout.isRefreshing()) {
                        swipeRefreshLayout.setRefreshing(false);
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    rootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                    if (swipeRefreshLayout.isRefreshing()) {
                        swipeRefreshLayout.setRefreshing(false);
                    }
                    if (isRetryOption) {
                        snackbar = SnackbarUtils.displaySnackbarWithAction(getActivity(), rootView, message,
                                new SnackbarUtils.OnSnackbarActionClickListener() {
                                    @Override
                                    public void onSnackbarActionClick() {
                                        rootView.findViewById(R.id.progressBar).setVisibility(View.VISIBLE);
                                        sendRequestToServer();
                                    }
                                });
                    } else {
                        SnackbarUtils.displaySnackbar(rootView, message);
                    }
                }
            });

        } catch (NullPointerException | JSONException e) {
            e.printStackTrace();
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


    int j=0;
    public void addDataToList(JSONObject jsonObject) {

        mBody = jsonObject;
        if (mBody != null) {

            if(isCategoryResults){
                /**
                 * Show Sub Categories of the selected category
                 */
                if (isLoadSubCategory) {
                    mSubCategoryResponse = mBody.optJSONArray("subCategories");

                    if (mSubCategoryResponse != null && mSubCategoryResponse.length() != 0) {
                        subCategoryLayout.setVisibility(View.VISIBLE);
                        for (int k = 0; k < mSubCategoryResponse.length(); k++) {
                            JSONObject object = mSubCategoryResponse.optJSONObject(k);
                            String sub_cat_name = object.optString("sub_cat_name");
                            subCategoryAdapter.add(sub_cat_name);
                        }
                    } else {
                        subCategoryLayout.setVisibility(View.GONE);
                    }

                    isLoadSubCategory = false;
                }

                /**
                 * Show 3rd level categories when sub category will be selected
                 */
                if (mBody.has("subsubCategories") && isLoadSubSubcategory) {

                    mSubSubCategoryResponse = mBody.optJSONArray("subsubCategories");
                    if (mSubSubCategoryResponse != null && mSubSubCategoryResponse.length() != 0) {
                        subSubCategoryLayout.setVisibility(View.VISIBLE);

                        for (int k = 0; k < mSubSubCategoryResponse.length(); k++) {
                            JSONObject object = mSubSubCategoryResponse.optJSONObject(k);
                            String sub_sub_cat_name = object.optString("tree_sub_cat_name");
                            subSubCategoryAdapter.add(sub_sub_cat_name);
                        }
                    } else {
                        subSubCategoryLayout.setVisibility(View.GONE);
                    }

                    isLoadSubSubcategory = false;
                }

                mTotalItemCount = mBody.optInt("totalPageCount");
                mDataResponse = mBody.optJSONArray("pages");
                if(mTotalItemCount == 0 && isFirstRequest){
                    subCategoryLayout.setVisibility(View.GONE);
                    subSubCategoryLayout.setVisibility(View.GONE);
                }
            } else {
                mTotalItemCount = mBody.optInt("totalItemCount");
                mDataResponse = mBody.optJSONArray("response");
            }

            mBrowseList.setmTotalItemCount(mTotalItemCount);

            if(mDataResponse != null && mDataResponse.length() > 0) {
                rootView.findViewById(R.id.message_layout).setVisibility(View.GONE);
                for (int i = 0; i < mDataResponse.length(); i++) {

                    if ((isAdLoaded || AdFetcher.isAdLoaded())  && mBrowseItemList.size() != 0
                            && mBrowseItemList.size() % ConstantVariables.SITE_PAGE_ADS_POSITION == 0) {
                        switch (ConstantVariables.SITE_PAGE_ADS_TYPE){
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
                    int page_id = jsonDataObject.optInt("page_id");
                    String title = jsonDataObject.optString("title");
                    String image_icon = jsonDataObject.optString("image");
                    int allow_to_view = jsonDataObject.optInt("allow_to_view");
                    int like_count = jsonDataObject.optInt("like_count");
                    int follow_count = jsonDataObject.optInt("follow_count");
                    int closed = jsonDataObject.optInt("closed");
                    String location = jsonDataObject.optString("location");
                    int rating = jsonDataObject.optInt("rating");
                    int review_count = jsonDataObject.optInt("review_count");
                    int featured = jsonDataObject.optInt("featured");
                    int sponsored = jsonDataObject.optInt("sponsored");
                    String contact = jsonDataObject.optString("phone");
                    String distance = jsonDataObject.optString("distance");
                    boolean canMessage = jsonDataObject.optBoolean("canMessage");

                    mBrowseItemList.add(new BrowseListItems(image_icon, title, page_id, (allow_to_view == 1),
                            like_count, follow_count, closed, location, review_count, rating, featured, sponsored, contact, canMessage, distance));

                }
                // Show End of Result Message when there are less results
                if(mTotalItemCount <= AppConstant.LIMIT * mLoadingPageNo){
                    CustomViews.showEndOfResults(mContext, footerView);
                }

            } else {
                CustomViews.removeFooterView(footerView);
                LinearLayout error_view = (LinearLayout) rootView.findViewById(R.id.message_layout);
                String message = mContext.getResources().getString(R.string.no_pages);

                if (mFeaturedCount > 0) {
                    RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT,
                            RelativeLayout.LayoutParams.WRAP_CONTENT);
                    layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT);
                    error_view.setLayoutParams(layoutParams);

                    error_view.setPadding(0, (int) mContext.getResources().getDimension(R.dimen.error_view_top_margin), 0 ,0);

                    if (PreferencesUtils.getDefaultLocation(mContext) != null && !PreferencesUtils.getDefaultLocation(mContext).isEmpty()) {
                        message = message + " " + mContext.getResources().getString(R.string.for_this_location_text);
                    }
                }

                error_view.setVisibility(View.VISIBLE);
                TextView errorIcon = (TextView) error_view.findViewById(R.id.error_icon);
                TextView errorMessage = (TextView) error_view.findViewById(R.id.error_message);
                errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
                errorIcon.setText("\uF15C");
                errorMessage.setText(message);
            }
            mBrowseDataAdapter.notifyDataSetChanged();
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
                sendRequestToServer();
                if (listNativeAdsManager != null) {
                    listNativeAdsManager.loadAds(NativeAd.MediaCacheFlag.ALL);
                }
            }
        });
    }

    @Override
    public void onScrollStateChanged(AbsListView absListView, int i) {

    }

    @Override
    public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {

        int limit = firstVisibleItem + visibleItemCount;
        if(limit == totalItemCount && !isLoading) {
            if(limit >= AppConstant.LIMIT && (AppConstant.LIMIT * mLoadingPageNo) <
                    mBrowseList.getmTotalItemCount()){

                CustomViews.addFooterView(footerView);
                mLoadingPageNo = mLoadingPageNo + 1;
                String url = getBrowsePageUrl() + "&page=" + mLoadingPageNo;

                isLoading = true;
                loadMoreData(url);
            }

        }
    }

    /* Load More Pages On Scroll */

    public void loadMoreData(String url) {

        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mBody = jsonObject;
                if(isCommunityAds){
                    mAppConst.getCommunityAds(ConstantVariables.SITE_PAGE_ADS_POSITION,
                            ConstantVariables.SITE_PAGE_ADS_TYPE);
                } else {
                    CustomViews.removeFooterView(footerView);
                    addDataToList(jsonObject);
                }
                isLoading = false;
                isFirstRequest = false;
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                SnackbarUtils.displaySnackbar(rootView, message);
            }
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        /* Update currentSelected Option on back press*/
        switch (requestCode){
            case ConstantVariables.VIEW_PAGE_CODE:
                PreferencesUtils.updateCurrentModule(mContext, mCurrentSelectedModule);
                if(resultCode == ConstantVariables.VIEW_PAGE_CODE){
                    swipeRefreshLayout.post(new Runnable() {
                        @Override
                        public void run() {
                            swipeRefreshLayout.setRefreshing(true);
                            sendRequestToServer();
                        }
                    });
                }
                break;
        }

    }

    @Override
    public void onAdsLoaded() {
        if (!isAdLoaded) {
            isAdLoaded = true;
            for (int i = 0 ; i <= mBrowseItemList.size(); i++) {
                if (i != 0 && i % ConstantVariables.SITE_PAGE_ADS_POSITION == 0) {
                    NativeAd ad = this.listNativeAdsManager.nextNativeAd();
                    mBrowseItemList.add(i, ad);
                    mBrowseDataAdapter.notifyDataSetChanged();
                }
            }
        }
    }

    @Override
    public void onAdError(AdError adError) {

    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long l) {
        postParams.clear();

        switch (parent.getTag().toString()){

            case "subCategory":
                isFirstRequest = false;
                mSelectedItem = position;
                subCategoryAdapter.getCustomView(position, view, parent, mSelectedItem);
                if (position != 0){
                    isLoadSubSubcategory = true;
                    subSubCategoryAdapter.clear();
                    subSubCategoryAdapter.add(getResources().getString(R.string.select_3rd_level_category_text));
                    JSONObject object = mSubCategoryResponse.optJSONObject(position - 1);
                    mSubCategoryId = object.optString("sub_cat_id");
                    postParams.put("subcategory_id", mSubCategoryId);
                    postParams.put("category_id", String.valueOf(mCategoryId));
                    swipeRefreshLayout.setRefreshing(true);
                    sendRequestToServer();

                } else {
                    subCategoryLayout.setVisibility(View.VISIBLE);
                    subSubCategoryLayout.setVisibility(View.GONE);
                    postParams.put("category_id", String.valueOf(mCategoryId));
                    swipeRefreshLayout.setRefreshing(true);
                    sendRequestToServer();
                }
                break;

            case "subSubCategory":
                isFirstRequest = false;
                mSubsubcategorySelectedItem = position;
                subSubCategoryAdapter.getCustomView(position, view, parent, mSubsubcategorySelectedItem);
                if (position != 0) {
                    JSONObject object = mSubSubCategoryResponse.optJSONObject(position - 1);
                    mSubSubCategoryId = object.optString("tree_sub_cat_id");
                    postParams.put("subcategory_id", mSubCategoryId);
                    postParams.put("category_id", String.valueOf(mCategoryId));
                    postParams.put("subsubcategory_id", mSubSubCategoryId);
                    swipeRefreshLayout.setRefreshing(true);
                    sendRequestToServer();

                } else {
                    postParams.put("subcategory_id", mSubCategoryId);
                    postParams.put("category_id", String.valueOf(mCategoryId));
                    swipeRefreshLayout.setRefreshing(true);
                    sendRequestToServer();
                }
                break;

            case "pagesFilter":
                switch (position){
                    case 0:
                        mPagesFilter = "all";
                        break;
                    case 1:
                        mPagesFilter = "5";
                        break;
                    case 2:
                        mPagesFilter = "6";
                        break;
                }
                sendRequestToServer();
                break;
        }
    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {

    }

    private String getBrowsePageUrl() {

        String url = mBrowsePageUrl + "?limit=" + AppConstant.LIMIT + "&show=" + mPagesFilter;

        /*
            Adding user_id or category_id in the url if the fragment is being called from user profile page
            or category page
         */
        if (mUserId != 0) {
            url += "&user_id=" + mUserId + "&type=userPages";
        } else if (isCategoryResults) {
            url = UrlUtil.CATEGORY_SITE_PAGE_URL + "&limit=" + AppConstant.LIMIT;
            url = mAppConst.buildQueryString(url, postParams);
        }

        // Adding Search params in the url if the fragment is being called from search page.
        if (searchParams != null && searchParams.size() != 0) {
            isSearchTextSubmitted = true;
            url = mAppConst.buildQueryString(url, searchParams);
        }

        return url;
    }

    @Override
    public void onCommunityAdsLoaded(JSONArray advertisementsArray) {
        mAdvertisementsArray = advertisementsArray;

        if(!isAdLoaded && mAdvertisementsArray != null){
            isAdLoaded = true;
            int j = 0;
            for (int i = 0 ; i <= mBrowseItemList.size(); i++) {
                if (i != 0 && i % ConstantVariables.SITE_PAGE_ADS_POSITION == 0 &&
                        j < mAdvertisementsArray.length()) {
                    mBrowseItemList.add(i, addCommunityAddsToList(j));
                    j++;
                    mBrowseDataAdapter.notifyDataSetChanged();
                }
            }
        } else if (!(mBrowseItemList.size() < AppConstant.LIMIT)) {
            CustomViews.removeFooterView(footerView);
            addDataToList(mBody);
        }
    }

    @Override
    public void setNestedScrollingEnabled(boolean enabled) {

    }

}
