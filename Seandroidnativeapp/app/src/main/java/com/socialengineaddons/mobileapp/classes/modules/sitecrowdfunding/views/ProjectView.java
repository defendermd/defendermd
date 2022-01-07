package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.views;

import android.content.Context;
import android.view.View;

import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.FAQ;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Project;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Reward;

import org.json.JSONObject;

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

public interface ProjectView {
    View getRootView();

    Context getContext();

    void setViews();

    void onSuccessRequest(JSONObject response);

    void onFailedRequest(String errorMessage, boolean isRetryOption, Map<String, String> notifyParams);

    void setNoProjectErrorTip();

    void notifyProjectView(List<?> itemList, int itemCount, Map<String, String> categoryList, Map<String, String> subCategoryList);

    void setCategoryBasedFilter();

    String getPseudoName();

    boolean isSetCache();

    boolean isActivityFinishing();
}
