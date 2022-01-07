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

package com.socialengineaddons.mobileapp.classes.modules.event;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;

import com.socialengineaddons.mobileapp.classes.common.activities.ViewGroupEvent;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

public class EventUtil {
    public static BaseFragment getBrowsePageInstance(){
        return new UpcomingEventsFragment();
    }

    public static BaseFragment getPastEventsFragmentInstance(){
        return new PastEventsFragment();
    }

    public static BaseFragment getManagePageInstance(){
        return new MyEventsFragment();
    }

    public static Intent getViewPageIntent(Context context, int id, String url, Bundle bundle){
        url += "events/view/"+ id +"?gutter_menu=" + 1;
        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.EVENT_MENU_TITLE);
        bundle.putString(ConstantVariables.VIEW_PAGE_URL, url);
        bundle.putInt(ConstantVariables.VIEW_PAGE_ID, id);
        Intent intent = new Intent(context, ViewGroupEvent.class);
        intent.putExtras(bundle);
        return intent;
    }
}
