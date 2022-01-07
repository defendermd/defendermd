/*
 *   Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 *    You may not use this file except in compliance with the
 *    SocialEngineAddOns License Agreement.
 *    You may obtain a copy of the License at:
 *    https://www.socialengineaddons.com/android-app-license
 *    The full copyright and license information is also mentioned
 *    in the LICENSE file that was distributed with this
 *    source code.
 */

package com.socialengineaddons.mobileapp.classes.modules.advancedGroups;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

public class AdvGroupUtil {
    public static BaseFragment getBrowsePageInstance() {
        return new AdvGroupsBrowseFragment();
    }

    public static BaseFragment getManagePageInstance() {
        return new AdvGroupsManageFragment();
    }

    public static Intent getViewPageIntent(Context context, String id, String url, Bundle bundle) {

        url += "advancedgroup/view/" + id + "?gutter_menu=" + 1;

        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.ADV_GROUPS_MENU_TITLE);
        bundle.putString(ConstantVariables.VIEW_PAGE_URL, url);
        try {
            bundle.putInt(ConstantVariables.VIEW_PAGE_ID, Integer.parseInt(id));
        } catch (NumberFormatException nfe) {
            nfe.printStackTrace();
        }
        Intent intent = new Intent(context, AdvGroupsProfile.class);
        intent.putExtras(bundle);
        return intent;
    }

}
