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

package com.socialengineaddons.mobileapp.classes.modules.advancedVideos;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;

import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

public class AdvVideoUtil {
    public static BaseFragment getBrowsePageInstance(){
        return new AdvVideoBrowseFragment();
    }

    public static BaseFragment getManagePageInstance() {
        return new AdvVideoManageFragment();
    }

    public static BaseFragment getChannelBrowsePageInstance(){
        return new BrowseChannelFragment();
    }

    public static BaseFragment getChannelManagePageInstance() {
        return new ManageChannelFragment();
    }

    public static BaseFragment getPlaylistBrowsePageInstance(){
        return new BrowsePlaylistFragment();
    }

    public static BaseFragment getPlaylistManagePageInstance() {
        return new ManagePlaylistFragment();
    }

    public static Intent getViewPageIntent(Context context, int id, String url, Bundle bundle){

        GlobalFunctions.checkAndFinishPipWindow();

        Intent intent = new Intent(context, AdvVideoView.class);
        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.ADV_VIDEO_MENU_TITLE);
        bundle.putString(ConstantVariables.VIDEO_URL, url);
        bundle.putString(ConstantVariables.VIEW_PAGE_URL, UrlUtil.ADV_VIDEO_VIEW_URL + id + "?gutter_menu=1");
        bundle.putInt(ConstantVariables.VIEW_ID, id);

        intent.putExtras(bundle);
        return intent;
    }

    public static Intent getChannelViewPageIntent(Context context, String id, String url, Bundle bundle) {
        url += "advancedvideo/channel/view/"+ id +"?gutter_menu=1";
        Intent intent = new Intent(context, ChannelProfilePage.class);
        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE);
        bundle.putString(ConstantVariables.VIEW_PAGE_URL, url);
        try{
            bundle.putInt(ConstantVariables.VIEW_ID, Integer.parseInt(id));
        } catch (NumberFormatException nfe) {
            nfe.printStackTrace();
        }
        intent.putExtras(bundle);
        return intent;
    }

    public static Intent getPlayListViewPageIntent(Context context, int id, String url, Bundle bundle) {
        url += "advancedvideo/playlist/view/"+ id +"?gutter_menu=1";
        Intent intent = new Intent(context, PlaylistProfilePage.class);
        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE);
        bundle.putString(ConstantVariables.VIEW_PAGE_URL, url);
        bundle.putInt(ConstantVariables.VIEW_ID, id);
        intent.putExtras(bundle);
        return intent;
    }
}
