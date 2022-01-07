/*
 *
 * Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 * You may not use this file except in compliance with the
 * SocialEngineAddOns License Agreement.
 * You may obtain a copy of the License at:
 * https://www.socialengineaddons.com/android-app-license
 * The full copyright and license information is also mentioned
 * in the LICENSE file that was distributed with this
 * source code.
 *
 */

package com.socialengineaddons.mobileapp.classes.modules.advancedEvents;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;

import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.InviteGuest;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.advancedEvents.ticketsSelling.AdvEventsOrderViewPage;
import com.socialengineaddons.mobileapp.classes.modules.offers.BrowseOffersFragment;


public class AdvEventsUtil {

    public static final String EVENT_TYPE = "event_type", SEARCH_BY_DATE = "search_by_date", SITE_GROUP ="site_group",
            CATEGORY_FILTER = "category_filter", SEARCH_EVENT = "search_event", BROWSE_EVENT ="browse";

    public static BaseFragment getBrowsePageInstance(){
        return new AdvEventsBrowseEventsFragment();
    }

    public static BaseFragment getManagePageInstance(){
        return new AdvEventsMyEventsFragment();
    }

    public static BaseFragment getDiariesPageInstance(){
        return new AdvEventsBrowseDiariesFragment();
    }

    public static BaseFragment getCalendarPageInstance(){
        return new AdvEventsCalendarFragment();
    }

    public static BaseFragment getBrowseDiariesInstance(){
        return new AdvEventsBrowseDiariesFragment();
    }

    public static BaseFragment getTicketPageInstance() {
        return new AdvEventsMyTicketsFragment();
    }

    public static BaseFragment getCouponPageInstance() {
        BrowseOffersFragment browseOffersFragment = new BrowseOffersFragment();
        Bundle bundle = new Bundle();
        bundle.putString(ConstantVariables.URL_STRING, UrlUtil.BROWSE_COUPONS_ADV_EVENTS_URL);
        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.ADVANCED_EVENT_MENU_TITLE);
        browseOffersFragment.setArguments(bundle);
        return browseOffersFragment;
    }

    public static Intent getViewPageIntent(Context context, int id, String url, Bundle bundle){

        url += "advancedevents/view/"+ id +"?gutter_menu=" + 1;

        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.ADVANCED_EVENT_MENU_TITLE);
        bundle.putString(ConstantVariables.VIEW_PAGE_URL, url);
        bundle.putInt(ConstantVariables.VIEW_PAGE_ID, id);
        Intent intent = new Intent(context, AdvEventsProfilePage.class);
        intent.putExtras(bundle);
        return intent;
    }

    public static Intent getViewDiaryIntent(Context context, int id, String url, Bundle bundle) {

        url += "advancedevents/diary/"+ id +"?&limit=" + AppConstant.LIMIT;

        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.ADVANCED_EVENT_MENU_TITLE);
        bundle.putString(ConstantVariables.VIEW_PAGE_URL, url);
        bundle.putInt(ConstantVariables.VIEW_PAGE_ID, id);
        Intent intent = new Intent(context, AdvEventsViewDiaries.class);
        intent.putExtras(bundle);
        return intent;
    }

    public static Intent getUserReviewPageIntent (Context context, int id, String url, Bundle bundle ) {

        url += "advancedevents/reviews/browse/event_id/" + id;

        bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.ADVANCED_EVENT_MENU_TITLE);
        bundle.putString(ConstantVariables.URL_STRING, url);
        bundle.putString(ConstantVariables.FRAGMENT_NAME, "reviews");
        bundle.putInt(ConstantVariables.VIEW_PAGE_ID, id);
        Intent intent = new Intent(context, FragmentLoadActivity.class);
        intent.putExtras(bundle);
        return intent;

    }

    public static Intent getInviteGuestIntent(Context context) {
        return new Intent(context, InviteGuest.class);
    }

    public static Intent getEventTicketOrderIntent (Context context, int id, String url, Bundle bundle) {

        url = UrlUtil.ORDER_VIEW_PAGE_ADV_EVENTS_URL + "order_id=" + id;

        bundle.putString(ConstantVariables.URL_STRING, url);
        bundle.putString("order_id", String.valueOf(id));
        Intent intent = new Intent(context, AdvEventsOrderViewPage.class);
        intent.putExtras(bundle);
        return intent;

    }
}
