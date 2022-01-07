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

package com.socialengineaddons.mobileapp.classes.modules.video;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;

import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.advancedVideos.AdvVideoView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class VideoUtil {
    public static BaseFragment getBrowsePageInstance(){
        return new BrowseVideoFragment();
    }

    public static Fragment getManagePageInstance() {
        return new MyVideoFragment();
    }

    public static Intent getViewPageIntent(Context context, int id, String url, Bundle bundle){
        Intent intent = new Intent(context, AdvVideoView.class);
        List<String> enabledModuleList = null;
        if (PreferencesUtils.getEnabledModuleList(context) != null) {
            enabledModuleList = new ArrayList<>(Arrays.asList(PreferencesUtils.getEnabledModuleList(context).split("\",\"")));
        }
        if (enabledModuleList != null && enabledModuleList.contains("sitevideo")
                && !Arrays.asList(ConstantVariables.DELETED_MODULES).contains("sitevideo")) {
            bundle.putInt(ConstantVariables.ADV_VIDEO_INTEGRATED, 1);
        }
        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.VIDEO_MENU_TITLE);
        bundle.putString(ConstantVariables.VIDEO_URL, url);
        bundle.putInt(ConstantVariables.VIEW_ID, id);
        intent.putExtras(bundle);
        return intent;
    }
}
