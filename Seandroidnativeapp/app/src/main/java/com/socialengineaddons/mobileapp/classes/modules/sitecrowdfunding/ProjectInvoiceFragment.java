package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding;

import android.content.Context;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.adapters.ProjectViewAdaptor;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Invoice;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.ProjectModelImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenter;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenterImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.views.ProjectView;

import org.json.JSONArray;
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

public class ProjectInvoiceFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener, ProjectView, OnItemClickListener, AdapterView.OnItemSelectedListener {

    private Context mContext;
    private View mRootView;
    private RecyclerView mRecyclerView;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private ProjectPresenter projectPresenter;
    private RecyclerView.Adapter mBrowseAdapter;
    private List<Object> mItemList;
    private String mUrl = UrlUtil.CROWD_FUNDING_FAQ_BACKER_BROWSE_URL;
    private Snackbar snackbar;
    private GridLayoutManager mLayoutManager;
    private JSONObject mBody;
    private JSONArray mResponse;


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mContext = getContext();
        mRootView = inflater.inflate(R.layout.recycler_view_layout, container, false);
        if (getArguments() != null) {
            mUrl = getArguments().getString(ConstantVariables.URL_STRING);
        }
        setViews();
        projectPresenter = new ProjectPresenterImpl(this, new ProjectModelImpl(this));
        PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
        projectPresenter.doRequest(mUrl);
        return mRootView;
    }

    @Override
    public View getRootView() {
        return mRootView;
    }

    public void setViews() {
        mRecyclerView = mRootView.findViewById(R.id.recycler_view);
        mSwipeRefreshLayout = mRootView.findViewById(R.id.swipe_refresh_layout);
        mSwipeRefreshLayout.setRefreshing(false);
        mSwipeRefreshLayout.setColorSchemeResources(R.color.colorPrimary);
        mSwipeRefreshLayout.setOnRefreshListener(this);
        mRecyclerView.setHasFixedSize(true);
        mItemList = new ArrayList<>();
        mLayoutManager = new GridLayoutManager(mContext, 1);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mBrowseAdapter = new ProjectViewAdaptor(mContext, mItemList, this, "invoice", this);
        mRecyclerView.setAdapter(mBrowseAdapter);
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
        mResponse = response.optJSONArray("response");
        if (mResponse != null) {
            for (int i = 0; i < mResponse.length(); i++) {
                mBody = mResponse.optJSONObject(i);
                JSONArray infoFieldNamesArray = mBody.names();
                Invoice invoice = new Invoice();
                invoice.backerId = mBody.optString(infoFieldNamesArray.optString(0));
                invoice.backedAmount = mBody.optDouble(infoFieldNamesArray.optString(2));
                invoice.currency = mBody.optString(infoFieldNamesArray.optString(3));
                invoice.backingDate = mBody.optString(infoFieldNamesArray.optString(4));
                invoice.reward = mBody.optString(infoFieldNamesArray.optString(5));

                mItemList.add(invoice);
            }
            mBrowseAdapter.notifyDataSetChanged();
        }
    }

    @Override
    public void onFailedRequest(String errorMessage, boolean isRetryOption, Map<String, String> notifyParams) {
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
                                projectPresenter.doRequest(mUrl);
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
        TextView errorIcon = mRootView.findViewById(R.id.error_icon);
        SelectableTextView errorMessage = mRootView.findViewById(R.id.error_message);
        errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        errorIcon.setText("\uf288");
        errorMessage.setText(mContext.getResources().getString(R.string.no_invoice_to_display));

    }

    @Override
    public void notifyProjectView(List<?> itemList, int itemCount, Map<String, String> categoryList, Map<String, String> subCategoryList) {

    }

    @Override
    public void setCategoryBasedFilter() {

    }

    @Override
    public String getPseudoName() {
        return "invoice";
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
                projectPresenter.doRequest(mUrl);
            }
        });
    }

    @Override
    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {

    }

    @Override
    public void onItemClick(View view, int position) {

    }
}
