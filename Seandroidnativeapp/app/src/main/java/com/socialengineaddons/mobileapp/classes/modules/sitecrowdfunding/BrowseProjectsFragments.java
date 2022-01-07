package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityOptionsCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.CardView;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SimpleItemAnimator;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;

import com.google.android.gms.tasks.Tasks;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.SpinnerAdapter;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnMenuClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.adapters.ProjectViewAdaptor;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Project;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.ProjectModelImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenter;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenterImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.utils.CoreUtil;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.views.ProjectView;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.Callable;

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

public class BrowseProjectsFragments extends BaseFragment implements ProjectView, SwipeRefreshLayout.OnRefreshListener, OnItemClickListener, AdapterView.OnItemSelectedListener, OnMenuClickResponseListener {


    public static Project mProjectInfo = null;
    String mBrowseProjectUrl = UrlUtil.CROWD_FUNDING_PROJECT_BROWSE_URL;
    BrowseListItems mFeaturedBrowseList;
    private Context mContext;
    private View mRootView, mHeaderView;
    private GridLayoutManager mLayoutManager;
    private RecyclerView.Adapter mBrowseAdapter;
    private List<Object> mProjectItemList;
    private RecyclerView mRecyclerView;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private Snackbar snackbar;
    private ProjectPresenter projectPresenter;
    private CardView subCategoryLayout, subSubCategoryLayout;
    private Spinner subCategorySpinner, subSubCategorySpinner, orderBySpinner;
    private SpinnerAdapter subCategoryAdapter, subSubCategoryAdapter, adapter;
    private Map<String, String> postParams;
    private int mSelectedItem = -1, mSubsubcategorySelectedItem = -1, mTotalItemCount;
    private boolean isCategoryResults = false, isLoaded = false, isLoading;
    private Bundle mExtraArgs;
    private List<String> categoryIds, subCategoryIds;
    private int mCategoryId, mLoadingPageNo = 1, mUserId;
    private AppConstant mAppConstant;
    private String mFragmentName = "browse", orderBy = "";
    private boolean isSetCache = true, isVisibleToUser, isSearchMode, canCreate, isPackageEnabled, isBackedProjects;
    private LayoutInflater layoutInflater;
    private HashMap<String, String> searchParams;
    private HashMap<Integer, String> filtersValue = new HashMap<Integer, String>()  {{
        put(0, "myProjects");
        put(1, "backed");
        put(2, "liked");
        put(3, "favourite");
    }};
    private HashMap<Integer, String> browseFiltersValue = new HashMap<Integer, String>()  {{
        put(0, "all");
        put(1, "featured");
        put(2, "sponsored");
        put(3, "ongoing");
        put(4, "backed");
        put(5, "failed");
        put(6, "liked");
    }};

    public static BrowseProjectsFragments newInstance(Bundle bundle) {
        BrowseProjectsFragments projectsFragment = new BrowseProjectsFragments();
        projectsFragment.setArguments(bundle);
        return projectsFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mContext = getContext();
        layoutInflater = inflater;
        mRootView = inflater.inflate(R.layout.recycler_view_layout, container, false);
        mHeaderView = inflater.inflate(R.layout.spinner_view, null, false);
        mAppConstant = new AppConstant(mContext);
        setExtraArgs();
        setViews();
        setCategoryBasedFilter();
        addListeners();
        projectPresenter = new ProjectPresenterImpl(this, new ProjectModelImpl(this));
        if (mFragmentName.equals("browse") || isCategoryResults || isBackedProjects) {
            projectPresenter.doRequest(getBrowseProjectUrl());
        }
        PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
        return mRootView;
    }

    @Override
    public View getRootView() {
        return mRootView;
    }

    @Override
    public void setViews() {
        mRecyclerView = (RecyclerView) mRootView.findViewById(R.id.recycler_view);
        RecyclerView.ItemAnimator itemAnimator = mRecyclerView.getItemAnimator();
        if (itemAnimator instanceof SimpleItemAnimator) {
            SimpleItemAnimator simpleItemAnimator = (SimpleItemAnimator) itemAnimator;
            simpleItemAnimator.setSupportsChangeAnimations(false);
        }
        itemAnimator.setChangeDuration(0);
        itemAnimator.setAddDuration(0);
        mSwipeRefreshLayout = (SwipeRefreshLayout) mRootView.findViewById(R.id.swipe_refresh_layout);
        mSwipeRefreshLayout.setRefreshing(false);
        mSwipeRefreshLayout.setColorSchemeResources(R.color.colorPrimary);
        mSwipeRefreshLayout.setOnRefreshListener(this);
        mRecyclerView.setHasFixedSize(true);
        mProjectItemList = new ArrayList<>();

        mLayoutManager = new GridLayoutManager(mContext, 1);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mBrowseAdapter = new ProjectViewAdaptor(mContext, mProjectItemList, this, "project", this);
        mRecyclerView.setAdapter(mBrowseAdapter);
        mRecyclerView.setBackgroundColor(mContext.getResources().getColor(R.color.fragment_background));

        if (isSetCache()) {
            mRootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
            mSwipeRefreshLayout.setRefreshing(true);
        } else {
            mRootView.findViewById(R.id.progressBar).setVisibility(View.VISIBLE);
            mRootView.findViewById(R.id.progressBar).bringToFront();
        }
        if (mFragmentName.equals("browse") && !isCategoryResults) {
            setFeaturedRequest();
        }
    }

    @Override
    public void onRefresh() {
        mLoadingPageNo = 1;
        mSwipeRefreshLayout.post(new Runnable() {
            @Override
            public void run() {
                mSwipeRefreshLayout.setRefreshing(true);
                projectPresenter.doRequest(getBrowseProjectUrl());
            }
        });
    }

    @Override
    public void onItemClick(View view, int position) {
        mProjectInfo = (Project) mProjectItemList.get(position);
        if (view.getTag() != null && view.getTag().equals("mainView")) {
            Intent projectViewIntent = CoreUtil.getProjectViewPageIntent(mContext, String.valueOf(mProjectInfo.project_id));
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                ActivityOptionsCompat options = ActivityOptionsCompat.makeSceneTransitionAnimation(
                        ((Activity) mContext),
                        view.findViewById(R.id.project_thumb), "project_thumb");
                ((Activity) mContext).startActivityForResult(projectViewIntent, ConstantVariables.
                        VIEW_PAGE_CODE, options.toBundle());
            } else {
                ((Activity) mContext).startActivityForResult(projectViewIntent, ConstantVariables.
                        VIEW_PAGE_CODE);
                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            }
        }
    }

    @Override
    public void onSuccessRequest(JSONObject response) {
        mRootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
        if (snackbar != null && snackbar.isShown()) {
            snackbar.dismiss();
        }
        if (mSwipeRefreshLayout.isRefreshing()) {
            mSwipeRefreshLayout.setRefreshing(false);
        }

    }

    @Override
    public void onFailedRequest(String errorMessage, boolean isRetryOption, Map<String, String> notifyParam) {
        mRootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
        mSwipeRefreshLayout.postDelayed(new Runnable() {
            @Override
            public void run() {
                mSwipeRefreshLayout.setRefreshing(false);
            }
        }, ConstantVariables.REFRESH_DELAY_TIME);
        try {
            if (isRetryOption) {
                snackbar = SnackbarUtils.displaySnackbarWithAction(mContext, mRootView, errorMessage,
                        new SnackbarUtils.OnSnackbarActionClickListener() {
                            @Override
                            public void onSnackbarActionClick() {
                                mRootView.findViewById(R.id.progressBar).setVisibility(View.VISIBLE);
                                projectPresenter.doRequest(getBrowseProjectUrl());
                            }
                        });
            } else {
                SnackbarUtils.displaySnackbar(mRootView, errorMessage);
            }
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void setNoProjectErrorTip() {
        mRootView.findViewById(R.id.message_layout).setVisibility(View.VISIBLE);
        TextView errorIcon = (TextView) mRootView.findViewById(R.id.error_icon);
        SelectableTextView errorMessage = (SelectableTextView) mRootView.findViewById(R.id.error_message);
        errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        errorIcon.setText("\uf288");
        errorMessage.setText(mContext.getResources().getString(R.string.no_projects_available));
        mRecyclerView.setVisibility(View.GONE);
    }

    @Override
    public void notifyProjectView(List<?> projectList, int itemCount, Map<String, String> categoryList, Map<String, String> subCategoryList) {
        if (!isLoading) {
            mProjectItemList.clear();
            if (isSetCache() && mFeaturedBrowseList != null) {
                mProjectItemList.add(0, mFeaturedBrowseList);
            }
        } else if (mProjectItemList.size() > AppConstant.LIMIT) {
            mProjectItemList.remove(mProjectItemList.size() - 1);
        }
        if (projectList != null) {
            mProjectItemList.addAll(projectList);
            mTotalItemCount = itemCount;
            // Show End of Result Message when there are less results
            if (mTotalItemCount <= AppConstant.LIMIT * mLoadingPageNo) {
                mProjectItemList.add(ConstantVariables.FOOTER_TYPE);
            }
            mBrowseAdapter.notifyDataSetChanged();
            notifyCategoryFilter(categoryList, subCategoryList);
            mRecyclerView.setVisibility(View.VISIBLE);
            mRootView.findViewById(R.id.message_layout).setVisibility(View.GONE);
        } else {
            setNoProjectErrorTip();
        }
        isLoaded = true;
        isLoading = false;
    }

    public void setFeaturedRequest() {
        AppConstant mAppConst = new AppConstant(mContext);
        mAppConst.getJsonResponseFromUrl(UrlUtil.CROWD_FUNDING_PROJECT_BROWSE_URL + "orderby=featured", new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                addDataToFeaturedList(jsonObject);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

            }
        });
    }

    private void addDataToFeaturedList(JSONObject jsonObject) {
        JSONArray mDataResponse = jsonObject.optJSONArray("response");
        if (mDataResponse != null && mDataResponse.length() > 0) {
            ;
            mFeaturedBrowseList = new BrowseListItems(jsonObject, 0);
            mProjectItemList.add(0, mFeaturedBrowseList);
            mBrowseAdapter.notifyDataSetChanged();
        }
    }

    @Override
    public void setCategoryBasedFilter() {
        if (!isCategoryResults && !isBackedProjects) {
            mHeaderView = layoutInflater.inflate(R.layout.spinner_view, null, false);
            orderBySpinner = (Spinner) mHeaderView.findViewById(R.id.filter_view);
            // Adding header view to main view.
            RelativeLayout mainView = (RelativeLayout) mRootView.findViewById(R.id.main_view_recycler);
            mainView.addView(mHeaderView);
            CustomViews.addHeaderView(R.id.spinnerCardView, mSwipeRefreshLayout);
            mHeaderView.findViewById(R.id.spinnerCardView).getLayoutParams().width = ViewGroup.LayoutParams.MATCH_PARENT;

            mRootView.findViewById(R.id.filter_block).setVisibility(View.VISIBLE);

            adapter = new SpinnerAdapter(mContext, R.layout.simple_text_view, mSelectedItem);

            /* Add filter type to spinner using adapter */
            if (mFragmentName.equals("manage")) {
                adapter.add(mContext.getResources().getString(R.string.my_projects));
                adapter.add(mContext.getResources().getString(R.string.backed));
                adapter.add(mContext.getResources().getString(R.string.liked));
                adapter.add(mContext.getResources().getString(R.string.favourites));
            } else {
                adapter.add(getResources().getString(R.string.browse_event_filter_sell_all));
                adapter.add(mContext.getResources().getString(R.string.featured));
                adapter.add(mContext.getResources().getString(R.string.sponsored));
                adapter.add(mContext.getResources().getString(R.string.ongoing));
                adapter.add(mContext.getResources().getString(R.string.backed));
                adapter.add(mContext.getResources().getString(R.string.failed));
                adapter.add(mContext.getResources().getString(R.string.most_liked));
            }
            adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            orderBySpinner.setAdapter(adapter);
            orderBySpinner.setSelection(0, false);
            orderBySpinner.setOnItemSelectedListener(this);
            orderBySpinner.setTag("orderBy");
            return;
        }
        mHeaderView = layoutInflater.inflate(R.layout.layout_category_block, null, false);
        subCategoryLayout = (CardView) mHeaderView.findViewById(R.id.categoryFilterLayout);
        subSubCategoryLayout = (CardView) mHeaderView.findViewById(R.id.subCategoryFilterLayout);
        subCategorySpinner = (Spinner) subCategoryLayout.findViewById(R.id.filter_view);
        subSubCategorySpinner = (Spinner) subSubCategoryLayout.findViewById(R.id.filter_view);
        mHeaderView.findViewById(R.id.mlt_category_block).setVisibility(View.VISIBLE);
        mHeaderView.findViewById(R.id.toolbar).setVisibility(View.GONE);
        // Adding header view to main view.
        RelativeLayout mainView = (RelativeLayout) mRootView.findViewById(R.id.main_view_recycler);
        mainView.addView(mHeaderView);
        CustomViews.addHeaderView(R.id.mlt_category_block, mSwipeRefreshLayout);
        mHeaderView.findViewById(R.id.mlt_category_block).getLayoutParams().width = ViewGroup.LayoutParams.MATCH_PARENT;

        subCategoryAdapter = new SpinnerAdapter(mContext, R.layout.simple_text_view, mSelectedItem);

        subCategoryAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        subCategorySpinner.setAdapter(subCategoryAdapter);
        subCategorySpinner.setSelection(0, false);
        subCategorySpinner.setTag("subCategory");

        subSubCategoryAdapter = new SpinnerAdapter(mContext, R.layout.simple_text_view, mSubsubcategorySelectedItem);
        subSubCategoryAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        subSubCategorySpinner.setAdapter(subSubCategoryAdapter);
        subSubCategorySpinner.setSelection(0, false);
        subSubCategorySpinner.setTag("subSubCategory");
        subCategorySpinner.setOnItemSelectedListener(this);
        subSubCategorySpinner.setOnItemSelectedListener(this);
    }

    @Override
    public String getPseudoName() {
        return BrowseProjectsFragments.class.getName();
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long l) {
        if (!isLoaded) return;
        postParams.clear();
        switch (parent.getTag().toString()) {

            case "subCategory":
                subCategoryAdapter.getCustomView(position, view, parent, position);
                if (position != 0) {
                    subSubCategoryAdapter.clear();
                    postParams.put("subcategory_id", categoryIds.get(position - 1));
                    mSwipeRefreshLayout.setRefreshing(true);
                    projectPresenter.doRequest(getBrowseProjectUrl());

                } else {
                    subCategoryLayout.setVisibility(View.VISIBLE);
                    mSwipeRefreshLayout.setRefreshing(true);
                    projectPresenter.doRequest(getBrowseProjectUrl());
                }
                subSubCategoryLayout.setVisibility(View.GONE);
                break;

            case "subSubCategory":
                subSubCategoryAdapter.getCustomView(position, view, parent, position);
                if (position != 0) {
                    postParams.put("subcategory_id", categoryIds.get(position - 1));
                    postParams.put("subsubcategory_id", subCategoryIds.get(position - 1));
                    mSwipeRefreshLayout.setRefreshing(true);
                    projectPresenter.doRequest(getBrowseProjectUrl());

                } else {
                    postParams.put("subcategory_id", categoryIds.get(position));
                    mSwipeRefreshLayout.setRefreshing(true);
                    projectPresenter.doRequest(getBrowseProjectUrl());
                }
                break;
            case "orderBy":
                mSelectedItem = position;
                adapter.getCustomView(position, view, parent, mSelectedItem);
                if (mFragmentName.equals("browse")) {
                    orderBy = browseFiltersValue.get(position);
                } else {
                    orderBy = filtersValue.get(position);
                }
                isSetCache = false;
                mSwipeRefreshLayout.setRefreshing(true);
                projectPresenter.doRequest(getBrowseProjectUrl());
                break;
        }
    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {

    }

    public void setExtraArgs() {
        postParams = new HashMap<>();
        if (getArguments() != null) {
            mExtraArgs = getArguments();
            isCategoryResults = mExtraArgs.getBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, false);
            mCategoryId = mExtraArgs.getInt(ConstantVariables.VIEW_PAGE_ID, 0);
            String title = mExtraArgs.getString(ConstantVariables.CONTENT_TITLE, " ") + " (" + mExtraArgs.getInt(ConstantVariables.TOTAL_ITEM_COUNT, 0) + ")";
            if (isCategoryResults) {
                getActivity().setTitle(title);
            }
            mFragmentName = mExtraArgs.getString(ConstantVariables.FRAGMENT_NAME, "browse");
            isSearchMode = mExtraArgs.getBoolean(ConstantVariables.IS_SEARCH_MODE, false);
            isSetCache = !(isCategoryResults || mFragmentName.equals("manage") || isSearchMode);
            canCreate = mExtraArgs.getBoolean(ConstantVariables.CAN_CREATE, false);
            isPackageEnabled = mExtraArgs.getBoolean(ConstantVariables.IS_PACKAGE_ENABLED, false);
            isBackedProjects = mExtraArgs.getBoolean(ConstantVariables.KEY_PROJECT_BACKED_SUCCESS, false);
            if (isBackedProjects) {
                orderBy = "backed";
            }
            mUserId = mExtraArgs.getInt(ConstantVariables.USER_ID, 0);

        }
    }

    public String getBrowseProjectUrl() {
        if (isCategoryResults) {
            mBrowseProjectUrl = UrlUtil.CROWD_FUNDING_CATEGORY_URL + "category_id=" + mCategoryId + "&limit=" + AppConstant.LIMIT;
            mBrowseProjectUrl = mAppConstant.buildQueryString(mBrowseProjectUrl, postParams);
        } else {
            mBrowseProjectUrl = UrlUtil.CROWD_FUNDING_PROJECT_BROWSE_URL + "orderby=" + orderBy + "&limit=" + AppConstant.LIMIT;
        }
        if (mFragmentName.equals("manage")) {
            mBrowseProjectUrl = UrlUtil.CROWD_FUNDING_PROJECT_MANAGE_URL + "orderby=" + orderBy + "&limit=" + AppConstant.LIMIT;
            ;
        }
        mBrowseProjectUrl += "&user_id=" + mUserId;
        if (isSearchMode) {
            Set<String> searchArgumentSet = getArguments().keySet();
            Bundle args = getArguments();
            args.remove(ConstantVariables.IS_SEARCH_MODE);
            args.remove(ConstantVariables.IS_PACKAGE_ENABLED);
            args.remove(ConstantVariables.CAN_CREATE);
            searchParams = new HashMap<>();
            for (String key : searchArgumentSet) {
                String value = args.getString(key);
                if (value != null && !value.isEmpty()) {
                    searchParams.put(key, value);
                }
            }
            if (searchParams != null && searchParams.size() != 0) {
                mBrowseProjectUrl = mAppConstant.buildQueryString(mBrowseProjectUrl, searchParams);
            }
        }
        return mBrowseProjectUrl;
    }

    public void notifyCategoryFilter(Map<String, String> categoryList, Map<String, String> subCategoryList) {
        if (categoryList != null && categoryList.size() > 0 && isCategoryResults) {
            categoryIds = new ArrayList<>(categoryList.keySet());
            subCategoryAdapter.clear();
            subCategoryAdapter.add(mContext.getResources().getString(R.string.select_sub_category_text));
            subCategoryAdapter.addAll(new ArrayList<>(categoryList.values()));
            subCategoryLayout.setVisibility(View.VISIBLE);
            subSubCategoryLayout.setVisibility(View.GONE);
        }
        if (subCategoryList != null && subCategoryList.size() > 0 && isCategoryResults && subCategoryList.size() > 0) {
            subCategoryIds = new ArrayList<>(subCategoryList.keySet());
            subSubCategoryAdapter.clear();
            subSubCategoryAdapter.add(getResources().getString(R.string.select_3rd_level_category_text));
            subSubCategoryAdapter.addAll(new ArrayList<>(subCategoryList.values()));
            subSubCategoryAdapter.notifyDataSetChanged();
            subSubCategoryLayout.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onItemDelete(int position) {
        mSwipeRefreshLayout.post(new Runnable() {
            @Override
            public void run() {
                mSwipeRefreshLayout.setRefreshing(true);
                projectPresenter.doRequest(getBrowseProjectUrl());
            }
        });
    }

    @Override
    public void onItemActionSuccess(int position, Object itemList, String menuName) {

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (resultCode) {
            case ConstantVariables.VIEW_PAGE_CODE:
            case ConstantVariables.PAGE_EDIT_CODE:
                isSetCache = false;
                mSwipeRefreshLayout.post(new Runnable() {
                    @Override
                    public void run() {
                        mSwipeRefreshLayout.setRefreshing(true);
                        projectPresenter.doRequest(getBrowseProjectUrl());
                    }
                });
                break;
        }
    }

    @Override
    public boolean isSetCache() {
        return isSetCache;
    }

    @Override
    public boolean isActivityFinishing() {
        return false;
    }

    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (visible && !isVisibleToUser && (mFragmentName != null && (mFragmentName.equals("manage") || mFragmentName.equals("project")))) {
            projectPresenter.doRequest(getBrowseProjectUrl());
            isVisibleToUser = true;
        } else {
            if (snackbar != null && snackbar.isShown())
                snackbar.dismiss();
        }
    }

    public void addListeners() {
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

                if (limit == totalItemCount && !isLoading && isLoaded) {

                    if (limit >= AppConstant.LIMIT && (AppConstant.LIMIT * mLoadingPageNo)
                            < mTotalItemCount) {

                        mLoadingPageNo = mLoadingPageNo + 1;
                        String url;
                        url = mBrowseProjectUrl + "&page=" + mLoadingPageNo;
                        isLoading = true;
                        //add null , so the adapter will check view_type and show progress bar at bottom
                        Tasks.call(new Callable<Void>() {
                            @Override
                            public Void call() throws Exception {
                                mProjectItemList.add(null);
                                mBrowseAdapter.notifyItemInserted(mProjectItemList.size() - 1);
                                return null;
                            }
                        });

                        projectPresenter.doRequest(url);
                    }

                }
            }
        });

    }

    @Override
    public void setNestedScrollingEnabled(boolean enabled) {
        if (mRecyclerView != null) {
            mRecyclerView.setNestedScrollingEnabled(enabled);
        }
    }
}
