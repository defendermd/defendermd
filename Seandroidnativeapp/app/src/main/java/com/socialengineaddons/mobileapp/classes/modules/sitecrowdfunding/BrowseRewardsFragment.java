package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
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

public class BrowseRewardsFragment extends BaseFragment implements SwipeRefreshLayout.OnRefreshListener, ProjectView, OnItemClickListener {
    private Context mContext;
    private View mRootView;
    private RecyclerView mRecyclerView;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private ProjectPresenter projectPresenter;
    private RecyclerView.Adapter mBrowseAdapter;
    private List<Object> mItemList;
    private String mRewardBrowseUrl = UrlUtil.CROWD_FUNDING_REWARD_BROWSE_URL, mRewardCreateUrl = UrlUtil.CROWD_FUNDING_REWARD_CREATE_URL;
    private Snackbar snackbar;
    private GridLayoutManager mLayoutManager;
    private Bundle mExtras;
    private String pseudoName = "browse_rewards";
    public static boolean isEditedReward;

    public static BrowseRewardsFragment newInstance(Bundle args) {
        BrowseRewardsFragment fragment = new BrowseRewardsFragment();
        fragment.setArguments(args);
        return fragment;
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        mContext = getContext();
        mRootView = inflater.inflate(R.layout.recycler_view_layout, container, false);
        setViews();
        projectPresenter = new ProjectPresenterImpl(this, new ProjectModelImpl(this));
        projectPresenter.doRequest(mRewardBrowseUrl);
        return mRootView;
    }

    @Override
    public void onRefresh() {
        mSwipeRefreshLayout.post(new Runnable() {
            @Override
            public void run() {
                mSwipeRefreshLayout.setRefreshing(true);
                projectPresenter.doRequest(mRewardBrowseUrl);
            }
        });

    }

    @Override
    public View getRootView() {
        return mRootView;
    }

    @Override
    public void setViews() {
        mRecyclerView = (RecyclerView) mRootView.findViewById(R.id.recycler_view);
        mRecyclerView.setNestedScrollingEnabled(false);
        mSwipeRefreshLayout = (SwipeRefreshLayout) mRootView.findViewById(R.id.swipe_refresh_layout);
        mSwipeRefreshLayout.setRefreshing(false);
        mSwipeRefreshLayout.setColorSchemeResources(R.color.colorPrimary);
        mSwipeRefreshLayout.setOnRefreshListener(this);
        mRecyclerView.setHasFixedSize(true);
        mItemList = new ArrayList<>();
        mLayoutManager = new GridLayoutManager(mContext, 1);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mBrowseAdapter = new ProjectViewAdaptor(mContext, mItemList, this, "reward", this);
        mRecyclerView.setAdapter(mBrowseAdapter);
        mExtras = getArguments();
        if (mExtras != null){
            if (mExtras.containsKey(ConstantVariables.URL_STRING)) {
                mRewardBrowseUrl = mExtras.getString(ConstantVariables.URL_STRING);
            }
            if (mExtras.containsKey(ConstantVariables.KEY_PSEUDO_NAME)) {
                pseudoName = mExtras.getString(ConstantVariables.KEY_PSEUDO_NAME);
            }
            mRewardBrowseUrl += mExtras.getInt(ConstantVariables.VIEW_PAGE_ID);
            mRewardCreateUrl += mExtras.getInt(ConstantVariables.VIEW_PAGE_ID);
        }
        FloatingActionButton fab = (FloatingActionButton) getActivity().findViewById(R.id.create_fab);
        if (fab != null) {
            fab.setImageDrawable(ContextCompat.getDrawable(
                    mContext, R.drawable.ic_action_new));
            fab.setVisibility(View.VISIBLE);
            fab.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent mIntent = new Intent(mContext, CreateNewEntry.class);
                    mIntent.putExtra(ConstantVariables.CREATE_URL, mRewardCreateUrl);
                    mIntent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
                    mIntent.putExtra(ConstantVariables.FORM_TYPE, "reward");
                    mIntent.putExtra(ConstantVariables.KEY_TOOLBAR_TITLE, mContext.getResources().getString(R.string.create_reward));
                    mIntent.putExtra(ConstantVariables.KEY_SUCCESS_MESSAGE, mContext.getResources().getString(R.string.create_reward_success_message));
                    ((Activity) mContext).startActivityForResult(mIntent, ConstantVariables.CREATE_REQUEST_CODE);
                    ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                }
            });
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
                                projectPresenter.doRequest(mRewardBrowseUrl);
                            }
                        });
            } else {
                SnackbarUtils.displaySnackbar(((Activity) mContext).findViewById(android.R.id.content), errorMessage);
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
        errorIcon.setText("\uf091");
        errorMessage.setText(mContext.getResources().getString(R.string.no_reward_created));
    }

    @Override
    public void notifyProjectView(List<?> itemList, int itemCount, Map<String, String> categoryList, Map<String, String> subCategoryList) {
        if (itemList != null) {
            mItemList.addAll(itemList);
            mBrowseAdapter.notifyDataSetChanged();
            mRootView.findViewById(R.id.message_layout).setVisibility(View.GONE);
        } else {
            setNoProjectErrorTip();
        }
    }

    @Override
    public void setCategoryBasedFilter() {

    }

    @Override
    public String getPseudoName() {
        return pseudoName;
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
    public void onItemClick(View view, int position) {

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (resultCode){
            case ConstantVariables.CREATE_REQUEST_CODE:
            case ConstantVariables.PAGE_EDIT_CODE:
                onRefresh();
                setEditedReward(true);
            break;
        }
    }

    @Override
    public void setNestedScrollingEnabled(boolean enabled) {
        mRecyclerView.setNestedScrollingEnabled(enabled);
    }
    public static boolean isEditedReward(){
        return isEditedReward;
    }

    public static void setEditedReward(boolean isEdited){
        BrowseRewardsFragment.isEditedReward = isEdited;
    }
}
