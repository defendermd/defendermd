package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.views.ProjectView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
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

public class ProjectModelImpl implements ProjectModel {
    private JSONArray mDataResponse;
    private JSONObject mResponse;
    private ProjectView mProjectView;

    public ProjectModelImpl(ProjectView projectView) {
        this.mProjectView = projectView;
    }

    @Override
    public void extractDataFromResponse(JSONObject response) {
        List<?> list = null;
        Map<String, String> categoryList = null, subCategoryList = null;

        int itemCount = response.optInt("totalItemCount");
        JSONArray categories = response.optJSONArray("subCategories");
        JSONArray subCategories = response.optJSONArray("subsubCategories");
        response = response.has("projects") ? response.optJSONObject("projects") : response;
        mDataResponse = response.optJSONArray("response");
        mResponse = response.optJSONObject("response");

        try {
            switch (mProjectView.getPseudoName()) {
                case "browse_faqs":
                    list = (mDataResponse != null ) ? Arrays.asList(new ObjectMapper().readValue(mDataResponse.toString(), FAQ[].class)) : null;
                    break;
                case "browse_rewards":
                    list = (mDataResponse != null ) ? Arrays.asList(new ObjectMapper().readValue(mDataResponse.toString(), Reward[].class)) : null;
                    break;
                case "select_reward":
                    mDataResponse = response.optJSONArray("reward_1");
                    list = (mDataResponse != null ) ? Arrays.asList(new ObjectMapper().readValue(mDataResponse.toString(), Reward[].class)) : null;
                    break;
                default:
                    //Code That Need To Be Improve
                    categoryList = _extractItemAsList(categories, "sub_cat");
                    subCategoryList = _extractItemAsList(subCategories, "tree_sub_cat");
                    if (mDataResponse != null && mDataResponse.length() > 0) {
                        list = new ProjectDataHolder().getProjectList(response.toString());
                    } else if (mResponse != null && response.has("profile_tabs")) {
                        mResponse.put("profile_tabs", response.optJSONArray("profile_tabs"));
                        mResponse.put("menu", response.optJSONArray("menu"));
                        list = new ProjectDataHolder().getProjectItem(mResponse.toString());
                    } else if (mResponse != null) {
                        list = new ProjectDataHolder().getProjectItem(mResponse.toString());
                    } else {
                        mProjectView.setNoProjectErrorTip();
                        return;
                    }
            }
            if (!mProjectView.isActivityFinishing()) {
                mProjectView.notifyProjectView(list, itemCount, categoryList, subCategoryList);
            }
        } catch (JSONException | IOException e) {
            e.printStackTrace();
            return;
        }
    }

    private Map<String, String> _extractItemAsList(JSONArray categories, String key) {
        Map<String, String> itemList = new HashMap<>();
        if (categories != null && categories.length() > 0) {
            for (int i = 0; i < categories.length(); i++) {
                JSONObject categoryItem = categories.optJSONObject(i);
                itemList.put(categoryItem.optString(key + "_id"), categoryItem.optString(key + "_name"));
            }
        }
        return itemList;
    }
}
