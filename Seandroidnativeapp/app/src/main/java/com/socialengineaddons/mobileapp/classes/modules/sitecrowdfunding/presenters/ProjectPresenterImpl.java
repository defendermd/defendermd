package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters;

import android.content.Context;

import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.DataStorage;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.ProjectModel;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.views.ProjectView;

import org.json.JSONException;
import org.json.JSONObject;

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

public class ProjectPresenterImpl implements ProjectPresenter {
    private ProjectView mProjectView;
    private ProjectModel mProjectModel;
    private String pseudoName;
    private Context mContext;
    private String _cacheData;
    private AppConstant mAppConst;

    public ProjectPresenterImpl(ProjectView projectView, ProjectModel projectModel) {
        this.mProjectView = projectView;
        this.mProjectModel = projectModel;
        this.pseudoName = projectView.getPseudoName();
        this.mContext = projectView.getContext();
        this._cacheData = DataStorage.getResponseFromLocalStorage(mContext, pseudoName);
        mAppConst = new AppConstant(mContext);
    }

    @Override
    public void doRequest(String url) {
        if (mProjectView.isSetCache() && _cacheData != null) {
            try {
                mProjectModel.extractDataFromResponse(new JSONObject(_cacheData));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject response) throws JSONException {
                mProjectView.onSuccessRequest(response);
                mProjectModel.extractDataFromResponse(response);
                if (mProjectView.isSetCache()) {
                    DataStorage.createTempFile(mContext, pseudoName, response.toString());
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mProjectView.onFailedRequest(message, isRetryOption, null);
            }
        });
    }

    @Override
    public void doPostRequest(String url, final Map<String, String> postParams) {
        mAppConst.postJsonResponseForUrl(url, postParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject response) throws JSONException {
                response = (response != null) ? response.put("isPost", true) : response;
                mProjectView.onSuccessRequest(response);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mProjectView.onFailedRequest(message, isRetryOption, postParams);
            }
        });
    }

    @Override
    public void doDeleteRequest(String url, final Map<String, String> postParams) {

        mAppConst.deleteResponseForUrl(url, postParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject response) throws JSONException {
                mProjectView.onSuccessRequest(response);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mProjectView.onFailedRequest(message, isRetryOption, postParams);
            }
        });
    }


}
