package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding;

import android.content.Context;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.SpinnerAdapter;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.adapters.ProjectViewAdaptor;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.ProjectModelImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenter;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenterImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.views.ProjectView;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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

public class FAQsBrowseFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener, ProjectView, OnItemClickListener, AdapterView.OnItemSelectedListener {
    private Context mContext;
    private View mRootView, mHeaderView;
    private RecyclerView mRecyclerView;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private ProjectPresenter projectPresenter;
    private RecyclerView.Adapter mBrowseAdapter;
    private List<Object> mItemList;
    private String mFAQBrowseUrl = UrlUtil.CROWD_FUNDING_FAQ_BACKER_BROWSE_URL;
    private Snackbar snackbar;
    private GridLayoutManager mLayoutManager;
    private Spinner filterByType;
    private SpinnerAdapter adapter;
    private int mSelectedItem = -1;
    private boolean isVisibleToUser;

    public FAQsBrowseFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mContext = getContext();
        mRootView = inflater.inflate(R.layout.recycler_view_layout, container, false);
        mHeaderView = mRootView.findViewById(R.id.filterLayout);

        setViews();
        projectPresenter = new ProjectPresenterImpl(this, new ProjectModelImpl(this));
        PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
        return mRootView;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

    }

    @Override
    public View getRootView() {
        return mRootView;
    }

    public void setViews() {
        mRecyclerView = (RecyclerView) mRootView.findViewById(R.id.recycler_view);
        mSwipeRefreshLayout = (SwipeRefreshLayout) mRootView.findViewById(R.id.swipe_refresh_layout);
        mSwipeRefreshLayout.setRefreshing(false);
        mSwipeRefreshLayout.setColorSchemeResources(R.color.colorPrimary);
        mSwipeRefreshLayout.setOnRefreshListener(this);
        mRecyclerView.setHasFixedSize(true);
        mItemList = new ArrayList<>();
        mLayoutManager = new GridLayoutManager(mContext, 1);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mBrowseAdapter = new ProjectViewAdaptor(mContext, mItemList, this, "faq", this);
        mRecyclerView.setAdapter(mBrowseAdapter);
        setCategoryBasedFilter();
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
        mItemList.clear();
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
                                projectPresenter.doRequest(mFAQBrowseUrl);
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
        errorMessage.setText(mContext.getResources().getString(R.string.no_faq_to_display));

    }

    @Override
    public void notifyProjectView(List<?> itemList, int itemCount, Map<String, String> categoryList, Map<String, String> subCategoryList) {
        if (itemList != null) {
            mItemList.addAll(itemList);
            mBrowseAdapter.notifyDataSetChanged();
        } else {
            setNoProjectErrorTip();
        }
    }

    @Override
    public void setCategoryBasedFilter() {
        filterByType = (Spinner) mHeaderView.findViewById(R.id.filter_view);
        // Adding header view to main view.
        RelativeLayout.LayoutParams layoutParams = CustomViews.getFullWidthRelativeLayoutParams();
        layoutParams.setMargins(0, mContext.getResources().getDimensionPixelSize(R.dimen.dimen_50dp), 0, 0);
        mSwipeRefreshLayout.setLayoutParams(layoutParams);
        mRootView.findViewById(R.id.filter_block).setVisibility(View.GONE);
        mRootView.findViewById(R.id.filterLayout).setVisibility(View.VISIBLE);

        adapter = new SpinnerAdapter(mContext, R.layout.simple_text_view, mSelectedItem);

        adapter.add(mContext.getResources().getString(R.string.backer));
        adapter.add(mContext.getResources().getString(R.string.project_owner));

        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        filterByType.setAdapter(adapter);
        filterByType.setSelection(0, false);
        filterByType.setOnItemSelectedListener(this);
        filterByType.setTag("faqType");
    }

    @Override
    public String getPseudoName() {
        return "browse_faqs";
    }

    @Override
    public boolean isSetCache() {
        return false;
    }

    @Override
    public boolean isActivityFinishing() {
        return false;
    }

    @Override
    public void onRefresh() {
        mSwipeRefreshLayout.post(new Runnable() {
            @Override
            public void run() {
                mSwipeRefreshLayout.setRefreshing(true);
                projectPresenter.doRequest(mFAQBrowseUrl);
            }
        });
    }

    @Override
    public void onItemClick(View view, int position) {

    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long l) {
        switch (parent.getTag().toString()) {
            case "faqType":
                mSelectedItem = position;
                adapter.getCustomView(position, view, parent, mSelectedItem);
                switch (position) {
                    case 0:
                        mFAQBrowseUrl = UrlUtil.CROWD_FUNDING_FAQ_BACKER_BROWSE_URL;
                        break;
                    case 1:
                        mFAQBrowseUrl = UrlUtil.CROWD_FUNDING_FAQ_OWNER_BROWSE_URL;
                        break;
                }
                mSwipeRefreshLayout.setRefreshing(true);
                projectPresenter.doRequest(mFAQBrowseUrl);
                break;
        }
    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {

    }
    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (visible && !isVisibleToUser) {
            projectPresenter.doRequest(mFAQBrowseUrl);
            isVisibleToUser = true;
        } else {
            if(snackbar != null && snackbar.isShown())
                snackbar.dismiss();
        }
    }
}
