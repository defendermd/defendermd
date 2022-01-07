package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.utils;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.activities.SearchActivity;
import com.socialengineaddons.mobileapp.classes.common.fragments.AdvBrowseCategoriesFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.ModulesHomeFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.PhotoFragment;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.FeedsFragment;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.BrowseProjectsFragments;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.FAQsBrowseFragment;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.ProjectViewActivity;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.ProfileTab;
import com.socialengineaddons.mobileapp.classes.modules.user.BrowseMemberFragment;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.MemberInfoFragment;
import com.socialengineaddons.mobileapp.classes.modules.video.VideoUtil;

import java.util.HashMap;
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

public class CoreUtil {

    public static Intent getProjectViewPageIntent(Context context, String project_id) {
        Intent intent = new Intent(context, ProjectViewActivity.class);
        intent.putExtra("project_id", project_id);
        return intent;
    }
    
    public static BaseFragment getTabFragment(ProfileTab tab, String project_id, Context context) {
        String tabName = tab.name;
        String tabUrl = tab.url;
        ProfileTab.UrlParams mUrlParams = tab.urlParams;
        AppConstant mAppConst = new AppConstant(context);
        Bundle bundle = new Bundle();
        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
        bundle.putString(ConstantVariables.SUBJECT_TYPE, "sitecrowdfunding_project");
        bundle.putInt(ConstantVariables.SUBJECT_ID, Integer.parseInt(project_id));
        bundle.putInt(ConstantVariables.VIEW_PAGE_ID, Integer.parseInt(project_id));
        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> params = mapper.convertValue(mUrlParams, Map.class);
        if (params != null && params.size() != 0) {
            Map<String, String> mPostParams = new HashMap<>();
            for (Map.Entry<String, Object> entry : params.entrySet()) {
                if (entry.getValue() instanceof String && !((String) entry.getValue()).isEmpty()) {
                    mPostParams.put(entry.getKey(), entry.getValue().toString());
                }
            }
            tabUrl = mAppConst.buildQueryString(tabUrl, mPostParams);
        }
        BaseFragment fragment = null;
        switch (tabName) {

            case "photo":
                fragment = new PhotoFragment();
                bundle.putInt(ConstantVariables.CAN_UPLOAD, tab.canUpload ? 1 : 0);
                bundle.putBoolean(ConstantVariables.IS_PROFILE_PAGE_REQUEST, true);
                bundle.putString(ConstantVariables.UPLOAD_URL, UrlUtil.CROWD_FUNDING_PROJECT_UPLOAD_PHOTO_URL + project_id);
                bundle.putString(ConstantVariables.SUBJECT_TYPE, "sitecrowdfunding_photo");
                break;
            case "update":
                fragment = new FeedsFragment();
                bundle.putBoolean(ConstantVariables.SET_NESTED_SCROLLING_ENABLED, false);
                break;
            case "information":
                fragment = new MemberInfoFragment();
                bundle.putBoolean("isProfilePageRequest", true);
                bundle.putString(ConstantVariables.FORM_TYPE, "info_tab");
                break;
            case "overview":
                fragment = new MemberInfoFragment();
                bundle.putBoolean("isProfilePageRequest", true);
                bundle.putString(ConstantVariables.FORM_TYPE, "overview");
                break;
            case "video":
                fragment = VideoUtil.getBrowsePageInstance();
                bundle.putBoolean("isProfilePageRequest", true);
                bundle.putString(ConstantVariables.UPLOAD_URL,AppConstant.DEFAULT_URL + tab.uploadUrl);
                bundle.putBoolean(ConstantVariables.CAN_UPLOAD, tab.canUpload);
                break;
            case "project_backer":
                bundle.putString(ConstantVariables.URL_STRING, tabUrl);
                bundle.putBoolean(ConstantVariables.IS_PROFILE_PAGE_REQUEST, true);
                fragment = BrowseMemberFragment.newInstance(bundle);
                break;
        }
        if (fragment != null) {
            bundle.putString(ConstantVariables.URL_STRING, AppConstant.DEFAULT_URL + tabUrl);
            fragment.setArguments(bundle);
        }
        return fragment;
    }

    public static Intent getCreatedPageIntent(Bundle params) {
        Intent intent = new Intent(CreateNewEntry.mContext, ProjectViewActivity.class);
        intent.putExtra("project_id", CreateNewEntry.mCreatedItemId);
        intent.putExtra("isJustCreated", true);
        return intent;
    }

    public void addFragments(Bundle params) {
        if (ModulesHomeFragment.adapter != null) {
            Context mContext = ModulesHomeFragment.mContext;
            AppConstant mAppConst = new AppConstant(mContext);
            ModulesHomeFragment.adapter.addFragment(BrowseProjectsFragments.newInstance(params), mContext.getResources().getString(R.string.browse_projects));
            if (!mAppConst.isLoggedOutUser()) {
                Bundle bundle = (params != null) ? new Bundle(params) : new Bundle() ;
                bundle.putString(ConstantVariables.FRAGMENT_NAME, "manage");
                ModulesHomeFragment.adapter.addFragment(BrowseProjectsFragments.newInstance(bundle),
                        mContext.getResources().getString(R.string.my_projects));
            }
            Bundle args = new Bundle();
            args.putString(ConstantVariables.URL_STRING, UrlUtil.CROWD_FUNDING_CATEGORY_URL);
            args.putString(ConstantVariables.FRAGMENT_NAME, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
            ModulesHomeFragment.adapter.addFragment(AdvBrowseCategoriesFragment.newInstance((args)), mContext.getResources().getString(R.string.category_tab));
            ModulesHomeFragment.adapter.addFragment(new FAQsBrowseFragment(), mContext.getResources().getString(R.string.faqs));
        }
    }

    public Fragment setLoadFragment(Bundle params) {
        return  BrowseProjectsFragments.newInstance(params);
    }
    public void setSearchFragment(Bundle params) {
        SearchActivity.fragment = new BrowseProjectsFragments();
    }
}
