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
 *
 */

package com.socialengineaddons.mobileapp.classes.modules.directoryPages;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

public class SitePageUtil {
    public static BaseFragment getBrowsePageInstance() {
        return new SitePageBrowseFragment();
    }

    public static BaseFragment getManagePageInstance() {
        return new SitePageManageFragment();
    }

    public static BaseFragment getPopularPageInstance() {
        return new SitePagePopularFragment();
    }

    public static Intent getViewPageIntent(Context context, String id, String url, Bundle bundle) {

        url += "sitepage/view/" + id + "?gutter_menu=" + 1;

        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.SITE_PAGE_MENU_TITLE);
        bundle.putString(ConstantVariables.VIEW_PAGE_URL, url);
        try {
            bundle.putInt(ConstantVariables.VIEW_PAGE_ID, Integer.parseInt(id));
        } catch (NumberFormatException nfe) {
            nfe.printStackTrace();
        }
        Intent intent = new Intent(context, SitePageProfileActivity.class);
        intent.putExtras(bundle);
        return intent;
    }

}
