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

package com.socialengineaddons.mobileapp.classes.modules.music;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;

import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

public class MusicUtil {
    public static BaseFragment getBrowsePageInstance(){
        return new BrowseMusicFragment();
    }

    public static BaseFragment getManagePageInstance(){
        return new MyMusicFragment();
    }

    public static Intent getViewPageIntent(Context context, int id, String url, Bundle bundle){
        Intent intent = new Intent(context, MusicView.class);
        url +=  "music/playlist/view/"+ id  +"?gutter_menu=" + 1;
        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.MUSIC_MENU_TITLE);
        bundle.putString(ConstantVariables.VIEW_PAGE_URL, url);
        bundle.putInt(ConstantVariables.VIEW_PAGE_ID, id);
        intent.putExtras(bundle);
        return intent;
    }
}
