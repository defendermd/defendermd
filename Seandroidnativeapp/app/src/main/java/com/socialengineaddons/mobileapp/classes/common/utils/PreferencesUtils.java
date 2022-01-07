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

package com.socialengineaddons.mobileapp.classes.common.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Base64;

import com.google.gson.Gson;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.store.data.CartData;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;

public class PreferencesUtils {

    // Module preferences
    private static final String MODULE_INFO_PREF = "ModuleInfo";
    private static final String CURRENT_MODULE = "currentSelectedModule";

    // Language Preferences
    public static final String DASHBOARD_DEFAULT_LANGUAGE = "defaultLanguage";
    public static final String DASHBOARD_MULTI_LANGUAGE = "multiLanguages";
    public static final String DASHBOARD_MENUS = "dashboardMenus";
    public static final String CURRENT_LANGUAGE = "current_language";
    private static final String DEFAULT_LANGUAGE_PREFERENCES = "default_language_preference";
    private static final String DEFAULT_LANGUAGE_KEY = "default_language_key";

    // User preferences
    private static final String USER_PREFERENCES = "authorized_user";
    private static final String USER_DETAILS = "userDetail";
    private static final String OAUTH_TOKEN = "oauth_token";
    private static final String OAUTH_SECRET = "oauth_secret";

    //Guest User Settings
    private static final String GUEST_USER_PREFERENCES = "guest_user_data";
    private static final String BROWSE_AS_GUEST = "browse_As_guest";

    //Notification Preferences
    private static final String NOTIFICATION_PREFERENCES = "notification_pref";
    public static final String MESSAGE_COUNT = "message_count";
    public static final String NOTIFICATION_COUNT = "notification_count";
    public static final String FRIEND_REQ_COUNT = "friend_req_count";
    public static final String CART_COUNT = "cart_count";

    //List Preferences
    private static final String CURRENT_LIST = "currentSelectedList";
    // Location Preferences
    public static final String DASHBOARD_DEFAULT_LOCATION = "defaultLocation";
    public static final String DASHBOARD_MULTI_LOCATION = "multiLocations";
    public static final String LOCATION_PERMISSION_DISPLAYED_ON_MAP = "locationPermissionDisplayedOnMap";

    // MLT Preferences
    private static final String CURRENT_MLT_OPTION_PREF = "current_mlt";
    private static final String CURRENT_MLT_LABEL = "current_mlt_label";
    private static final String CURRENT_MLT_SINGULAR_LABEL = "current_mlt_singular_label";
    private static final String CURRENT_LISTING_ID = "mlt_listing_id";
    private static final String BROWSE_MLT_TYPE = "browse_type";
    private static final String SECONDARY_BROWSE_MLT_TYPE = "secondary_browse_type";
    private static final String VIEW_MLT_TYPE = "view_type";
    private static final String CURRENT_MLT_ICON = "current_mlt_icon";
    private static final String CAN_MLT_CREATE = "can_create";
    private static final String MLT_PACKAGES_ENABLED = "packages_enabled";
    private static final String MLT_CAN_VIEW = "can_view_mlt";

    // App Version Preferences
    private static final String APP_PREFERENCES = "app_pref";
    private static final String APP_VERSION_PREF = "appVersion";
    private static final String APP_VERSION_STRING = "androidVersion";
    private static final String APP_LAUNCH_COUNT = "app_launch_count";
    public static final String APP_RATED = "isAppRated";
    public static final String NOT_RATED = "NotRated";

    // Sound setting Preferences
    private static final String SOUND_SETTING_PREF = "sound_setting";
    private static final String SOUND_ENABLED = "sound_value";

    // Login Info Preferences
    private static final String LOGIN_INFO_PREF = "LoginInfo";
    public static final String LOGIN_EMAIL = "email";
    public static final String LOGIN_PASSWORD = "password";
    private static final String LOGIN_USER_ID = "user_id";

    //Location Enabled Setting
    private static final String LOCATION_SETTING_PREFERENCES = "location_enabled_setting";
    private static final String LOCATION_ENABLED = "location_enabled";

    // Feed Reactions Preferences
    private static final String FEED_REACTIONS_PREF = "FeedReactions";
    public static final String FEED_REACTIONS = "feedReactions";
    public static final String MY_FEED_REACTIONS = "myFeedReactions";

    // Reactions Object Preferences
    private static final String REACTIONS_PREF = "ReactionsPref";
    private static final String REACTIONS = "reactionsObject";

    // Stickers Enabled Pref
    private static final String STICKERS_ENABLED_PREF = "StickersEnabled";
    private static final String STICKERS_ENABLED = "stickersEnabled";

    // Stickers Store Menu Pref
    private static final String STICKERS_STORE_PREF = "StickersStores";
    private static final String STICKERS_STORE_MENU = "stickersMenu";

    // Reactions Enabled Pref
    private static final String REACTIONS_ENABLED_PREF = "ReactionsEnabled";
    private static final String REACTIONS_ENABLED = "reactionsEnabled";

    //NestedCommentEnabled
    private static final String MODULE_ENABLED = "module_enabled";
    private static final String NESTED_COMMENT_ENABLED = "nested_comment_enabled";

    // People Suggestion Pref
    private static final String PEOPLE_SUGGESTION_PREF = "PeopleSuggestion";


    //Site Content Cover Pref
    private static final String SITE_CONTENT_COVER_PHOTO_ENABLED_PREF = "SiteContentCoverPhotoEnable";
    private static final String CONTENT_COVER_ENABLED = "contentCoverEnabled";

    //Enable Module Pref
    private static final String ENABLE_MODULE_PREF = "EnableModule";
    private static final String ENABLE_MODULE_LIST = "enableModuleList";

    //Emoji Enabled Pref
    private static final String EMOJI_ENABLE_PREF = "emoji_enabled_pref";
    private static final String EMOJI_ENABLED = "emoji_enabled";

    //Contacts Pref
    public static final String REPORT_AD_PREF = "report_ads_pref";
    public static final String REPORT_ADS_ARRAY = "report_ads_array";

    //Advancec event Pref
    public static final String TICKET_PREF = "ticket_enabled_pref";
    public static final String IS_TICKET_ENABLED = "is_ticket_enabled";

    //Prime Messenger Enabled Setting
    private static final String PRIME_MESSENGER_ENABLED_SETTING = "prime_messenger_enabled_setting";
    private static final String IS_MESSENGER_ENABLED = "is_messenger_enabled";

    //Paid Member Pref
    private static final String PAID_MEMBER_STATUS = "paid_member_pref";
    private static final String IS_PAID_MEMBER = "is_paid_member";

    // UnRead Message Count Pref
    private static final String UNREAD_MESSAGE_COUNT_PREF = "unread_message_count_pref";
    private static final String UNREAD_MESSAGE_COUNT = "unread_message_count";

    // Video Source Pref
    public static final String VIDEO_SOURCE_PREF = "video_source_pref";
    public static final String IS_MY_DEVICE_ENABLED = "is_my_device_enabled";

    //Browse Member View type Pref
    public static final String MEMBER_VIEW_PREF = "member_view_pref";
    public static final String MEMBER_VIEW_TYPE = "member_view_type";

    // App Upgrade Preferences
    private static final String APP_UPGRADE_PREF = "app_upgrade_pref";
    private static final String APP_UPGRADE_DIALOG_IGNORED = "app_upgrade_dialog_ignored";
    private static final String APP_UPGRADE_REMIND = "app_upgrade_remind";
    private static final String APP_UPGRADE_VERSION = "app_upgrade_version";
    private static final String APP_UPGRADE_DESCRIPTION = "app_upgrade_description";
    private static final String FORCE_APP_UPGRADE = "force_app_upgrade";

    // Video quality Preferences
    private static final String VIDEO_QUALITY_PREF = "video_quality_pref";
    private static final String VIDEO_QUALITY = "video_quality";

    // Story Preferences
    private static final String STORY_PREF = "story_pref";
    private static final String STORY_DURATION = "story_duration";
    private static final String STORY_PRIVACY = "story_privacy";
    private static final String STORY_PRIVACY_KEY = "story_privacy_key";
    public static final String STORY_ENABLED = "story_enabled";

    // AAF filter Preferences
    private static final String AAF_FILTER_PREF = "aaf_filter_pref";
    private static final String IS_FILTER_ENABLED = "is_filter_enabled";

    //OTP enable Preferences
    private static final String OTP_ENABLED_PREF = "otp_enabled_pref";
    private static final String OTP_OPTION = "otp_option";

    //OTP plugin enabled Preferences
    private static final String OTP_PLUGIN_PREF = "otp_plugin_pref";
    private static final String IS_OTP_PLUGIN = "is_otp_plugin";

    // AAF filter Preferences
    private static final String AAF_GREETINGS_PREF = "aaf_greetings_pref";
    private static final String AAF_GREETINGS = "aaf_greetings";
    private static final String BIRTHDAYS = "birthdays";
    private static final String GREETINGS_DATE = "greetings_date";


    // Show case view Preferences

    public static final String APP_TOUR_ENABLED = "app_tour_enabled";

    public static final String SHOW_CASE_VIEW_PREF = "show_case_view_pref";
    public static final String NAVIGATION_ICON_CASE_VIEW = "navigation_case_view";
    public static final String SEARCH_ICON_CASE_VIEW = "search_case_view";
    public static final String SEARCH_BAR_CASE_VIEW = "search_bar_case_view";
    public static final String LOCATION_ICON_CASE_VIEW = "location_case_view";
    public static final String CART_ICON_CASE_VIEW = "cart_case_view";
    public static final String STATUS_POST_CASE_VIEW = "status_case_view";
    public static final String FAB_CREATE_CASE_VIEW = "fab_create_case_view";
    public static final String FAB_MENU_CASE_VIEW = "fab_menu_case_view";
    public static final String USER_PROFILE_SHOW_CASE_VIEW = "user_profile_case_view";
    public static final String FEED_HOME_ICON_SHOW_CASE_VIEW = "feed_home_icon_case_view";

    // Showcase view user profile preferences
    public static final String USER_PROFILE_EDIT_PHOTO_SHOW_CASE_VIEW = "user_profile_edit_photo_case_view";
    public static final String USER_PROFILE_EDIT_SHOW_CASE_VIEW = "user_profile_profile_case_view";
    public static final String USER_PROFILE_MORE_SHOW_CASE_VIEW = "user_profile_more_case_view";
    public static final String USER_PROFILE_FRIENDS_SHOW_CASE_VIEW = "user_profile_friends_case_view";
    public static final String USER_PROFILE_FOLLOW_SHOW_CASE_VIEW = "user_profile_follow_case_view";
    public static final String USER_PROFILE_MESSAGE_SHOW_CASE_VIEW = "user_profile_message_case_view";
    public static final String USER_PROFILE_FAB_CREATE_SHOW_CASE_VIEW = "user_profile_fab_create_case_view";


    // Status privacy key selected
    private static final String STATUS_PRIVACY_PREF = "status_privacy_pref";
    private static final String STATUS_PRIVACY_KEY = "status_privacy_key";
    private static final String STATUS_POST_PRIVACY_OPTIONS = "status_post_privacy_option";
    private static final String STATUS_PRIVACY_MULTI_OPTIONS = "status_privacy_multi_options";

    public static final String USER_LOCATION_LATITUDE ="user_location_latitude";
    public static final String USER_LOCATION_LONGITUDE ="user_location_longitude";
    public static final String MODULE_WISE_SETTINGS ="MODULE_WISE_SETTINGS";


    public static final String APP_MESSAGING_TYPE = "app_messaging_type";

    /* Video auto play preferences */
    private static final String VIDEO_AUTO_PLAY_PREF = "video_auto_play_pref";
    private static final String VIDEO_AUTO_PLAY = "video_auto_play";

    // Live streaming Preferences
    private static final String LIVE_STREAMING_PREF = "live_streaming_pref";
    private static final String LIVE_STREAMING_ENABLED = "live_streaming_enabled";
    private static final String LIVE_STREAMING_LIMIT = "live_streaming_limit";

    // Deeplinking Preferences
    private static final String DEEPLINKING_PREF = "deeplinking_pref";
    private static final String HOST_PATH_PREFIXES = "host_path_prefixes";

    // Add Friends Widget AAF
    private static final String ADD_FRIENDS_AAF = "add_friends_aaf";
    private static final String FRIENDS_WIDGET_PREF = "friends_widget_pref";
    private static final String REMOVE_FRIENDS_AAF = "remove_friends_aaf";


    // Multi currency Preferences
    private static final String MULTI_CURRENCY_PREF = "multi_currency_pref";
    private static final String MULTI_CURRENCY_DATA = "multi_currency_data";
    private static final String MULTI_CURRENCY_ENABLED = "multi_currency_enable";
    private static final String MULTI_CURRENCY_RATES = "multi_currency_rates";
    private static final String MULTI_CURRENCY_DEFAULT = "multi_currency_default";
    private static final String MULTI_CURRENCY_SELECTED = "multi_currency_selected";
    private static final String MULTI_CURRENCY_SELECTED_INFO = "multi_currency_selected_info";
    private static final String MULTI_CURRENCY_FORMAT = "multi_currency_format";

    /* PIP mode video play preferences */
    private static final String PIP_MODE_PREF = "pip_mode_pref";
    private static final String PIP_MODE_ENABLE = "pip_mode_enable";
    private static final String PLAY_VIDEO_IN_PIP = "play_video_in_pip";
    private static final String PIP_USER_POPUP_DISPLAYED = "pip_user_popup_displayed";
    private static final String PIP_PERMISSION_POPUP_DISPLAYED = "pip_permission_popup_displayed";


    // Channelize Access token
    private static final String CHANNELIZE_ACCESS_TOKEN_PREF = "chAccessTokenv2_pref";
    private static final String CHANNELIZE_ACCESS_TOKEN = "chAccessTokenv2";

    /**
     * Used to update current selected module.
     *
     * @param moduleName - module name which will be updated
     */
    public static void updateCurrentModule(Context context, String moduleName) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MODULE_INFO_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(CURRENT_MODULE, moduleName);
        editor.apply();
    }

    //Getting the current module
    public static String getCurrentSelectedModule(Context context) {
        return context.getSharedPreferences(MODULE_INFO_PREF, Context.MODE_PRIVATE)
                .getString(CURRENT_MODULE, null);
    }

    public static void updateCurrentList(Context context, String listName) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MODULE_INFO_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(CURRENT_LIST, listName);
        editor.apply();
    }

    //Getting the current module
    public static String getCurrentSelectedList(Context context) {
        return context.getSharedPreferences(MODULE_INFO_PREF, Context.MODE_PRIVATE)
                .getString(CURRENT_LIST, null);
    }

    //Updating guest user setting data
    public static void updateGuestUserSettings(Context context, String browse_as_guest) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(GUEST_USER_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(BROWSE_AS_GUEST, browse_as_guest);
        editor.apply();
    }

    //Checking for guest user setting
    public static boolean isGuestUserEnabled(Context context) {
        return context.getSharedPreferences(GUEST_USER_PREFERENCES, Context.MODE_PRIVATE)
                .getString(BROWSE_AS_GUEST, "1").equals("1");
    }

    /**
     * Used to update user detail preferences.
     *
     * @param userData     - converted string of the current user's detail json object.
     * @param oauth_secret - Authentication secret key which verifies the user.
     * @param OauthToken   Authentication token of the current user.
     */
    public static void updateUserPreferences(Context context, String userData, String oauth_secret, String OauthToken) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(USER_DETAILS, userData);
        editor.putString(OAUTH_TOKEN, OauthToken);
        editor.putString(OAUTH_SECRET, oauth_secret);
        editor.apply();
    }

    /**
     * Update user details with new Locale when Language get changed of app
     *
     * @param userData - converted string of the current user's detail json object.
     */
    public static void updateUserDetails(Context context, String userData) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(USER_DETAILS, userData);
        editor.apply();
    }

    //Getting the current authentication token
    public static String getAuthToken(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        return sharedPreferences.getString(OAUTH_TOKEN, null);
    }

    //Used to get user preferences which stores the current user's details.
    public static SharedPreferences getUserPreferences(Context context) {
        return context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
    }

    // Used to get current user's details.
    public static String getUserDetail(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        return sharedPreferences.getString(USER_DETAILS, null);
    }

    // Updating default language.
    public static void updateDefaultLanguage(Context context, String language) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(DEFAULT_LANGUAGE_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(DEFAULT_LANGUAGE_KEY, language);
        editor.apply();
    }

    // Used to get default language from preference
    public static String getDefaultLanguage(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(DEFAULT_LANGUAGE_PREFERENCES, Context.MODE_PRIVATE);
        if (sharedPreferences.contains(DEFAULT_LANGUAGE_KEY)) {
            return sharedPreferences.getString(DEFAULT_LANGUAGE_KEY, "en");
        } else {
            sharedPreferences = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
            return sharedPreferences.getString(DASHBOARD_DEFAULT_LANGUAGE, "en");
        }
    }

    /**
     * Used to update dash board menu preferences.
     *
     * @param prefStringName - attribute to update in dashboard preferences.
     * @param data           - data in string format which will be updated.
     */
    public static void updateDashBoardData(Context context, String prefStringName, String data) {
        SharedPreferences mDashBoardPref = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        SharedPreferences.Editor dashBoardEditor = mDashBoardPref.edit();
        dashBoardEditor.putString(prefStringName, data);
        dashBoardEditor.apply();
    }

    // Used to get Dashboard menus data
    public static String getDashboardMenus(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        return sharedPreferences.getString(DASHBOARD_MENUS, null);
    }

    public static JSONObject getMenuByName(Context context, String menuName, String ...args) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        String menus = sharedPreferences.getString(DASHBOARD_MENUS, null);

        try {
            JSONArray menusArray = new JSONArray(menus);
            for (int i = 0; i < menusArray.length(); i++) {
                JSONObject menu = menusArray.getJSONObject(i);
                if (menu.getString("name").equals(menuName)) {
                    if (args == null || args[0].isEmpty() || args[1].isEmpty()) {
                        return menu;
                    } else if (menu.optString(args[0]).equals(args[1])){
                        return menu;
                    }
                }
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Used to get default language from preferences
    public static String getCurrentLanguage(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        if (sharedPreferences.contains(CURRENT_LANGUAGE)) {
            return sharedPreferences.getString(CURRENT_LANGUAGE, "en");
        } else {
            return sharedPreferences.getString(DASHBOARD_DEFAULT_LANGUAGE, "en");
        }
    }

    // Used to get default location from preferences
    public static String getDefaultLocation(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        return sharedPreferences.getString(DASHBOARD_DEFAULT_LOCATION, "");
    }

    // Used to display location permission popup on map
    public static boolean isLocationPermissionDisplayedOnMap(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        return sharedPreferences.getBoolean(LOCATION_PERMISSION_DISPLAYED_ON_MAP, false);
    }

    // Set location permission popup displayed on map
    public static void setLocationPermissionDisplayedOnMap(Context context) {
        SharedPreferences mDashBoardPref = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        SharedPreferences.Editor dashBoardEditor = mDashBoardPref.edit();
        dashBoardEditor.putBoolean(LOCATION_PERMISSION_DISPLAYED_ON_MAP, true);
        dashBoardEditor.apply();
    }

    // get all supported languages
    public static String getLanguages(Context context) {
        SharedPreferences mDashBoardPref = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        return mDashBoardPref.getString(DASHBOARD_MULTI_LANGUAGE, null);
    }

    // get all Locations
    public static String getLocations(Context context) {
        SharedPreferences mDashBoardPref = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        return mDashBoardPref.getString(DASHBOARD_MULTI_LOCATION, null);
    }

    // get app tour setting
    public static int getAppTourEnabled(Context context) {
        SharedPreferences mDashBoardPref = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        return Integer.parseInt(mDashBoardPref.getString(APP_TOUR_ENABLED, "0"));
    }

    // get app messaging type
    public static String getMessagingType(Context context) {
        SharedPreferences mDashBoardPref = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        return mDashBoardPref.getString(APP_MESSAGING_TYPE, "everyone");
    }

    // get story enable/disable setting
    public static boolean getIsStoryEnabled(Context context) {
        SharedPreferences mDashBoardPref = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        return mDashBoardPref.getString(STORY_ENABLED, "0").equals("1");
    }


    // Friends widget pref settings
    public static boolean getIsAddFriendWidgetEnable(Context context) {
        SharedPreferences mDashBoardPref = context.getSharedPreferences(FRIENDS_WIDGET_PREF, Context.MODE_PRIVATE);
        return mDashBoardPref.getInt(ADD_FRIENDS_AAF, 0) == 1;
    }

    public static void setAddFriendWidgetEnable(Context context, int isEnable) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FRIENDS_WIDGET_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(ADD_FRIENDS_AAF, isEnable);
        editor.apply();
    }

    public static boolean getIsAddFriendWidgetRemoved(Context context) {
        SharedPreferences mDashBoardPref = context.getSharedPreferences(FRIENDS_WIDGET_PREF, Context.MODE_PRIVATE);
        return mDashBoardPref.getBoolean(REMOVE_FRIENDS_AAF, false);
    }

    public static void setAddFriendWidgetRemoved(Context context, boolean isRemoved) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FRIENDS_WIDGET_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(REMOVE_FRIENDS_AAF, isRemoved);
        editor.apply();
    }

    public static void clearFriendWidgetPref(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FRIENDS_WIDGET_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
    }



    // Clearing dashboard data.
    public static void clearDashboardData(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(DASHBOARD_MENUS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
    }

    /*
    For storing notification counts for feed and drawer menu
    */
    public static void updateNotificationPreferences(Context context, String msg_count,
                                                     String notification_count,
                                                     String friend_re_count, String cartCount) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(NOTIFICATION_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(NOTIFICATION_COUNT, notification_count);
        editor.putString(MESSAGE_COUNT, msg_count);
        editor.putString(FRIEND_REQ_COUNT, friend_re_count);
        editor.putString(CART_COUNT, cartCount);
        editor.apply();
    }

    //Getting the notification counts preferences
    public static String getNotificationsCounts(Context context, String countName) {
        return context.getSharedPreferences(NOTIFICATION_PREFERENCES, Context.MODE_PRIVATE)
                .getString(countName, "0");
    }

    public static void updateCartCount(Context context, String cartCount) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(NOTIFICATION_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(CART_COUNT, cartCount);
        editor.apply();
    }

    public static void clearNotificationsCount(Context context, String countName) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(NOTIFICATION_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.remove(countName);
        editor.apply();
    }

    /* Used to clear all the stored preferences*
     *  basically used at the time of SignOut  */
    public static void clearSharedPreferences(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.remove(OAUTH_TOKEN);
        editor.remove(OAUTH_SECRET);
        editor.remove(USER_DETAILS);
        editor.apply();

        sharedPreferences = context.getSharedPreferences(LOGIN_INFO_PREF, Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

        sharedPreferences = context.getSharedPreferences(ENABLE_MODULE_PREF, Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

        sharedPreferences = context.getSharedPreferences(EMOJI_ENABLE_PREF, Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

        clearNotificationsCount(context, NOTIFICATION_COUNT);
        clearNotificationsCount(context, FRIEND_REQ_COUNT);
        clearNotificationsCount(context, MESSAGE_COUNT);
        clearNotificationsCount(context, CART_COUNT);
        clearReactionsPref(context);
        clearStickerStoreMenuPref(context);
        clearAllReactionsPref(context);
        clearTicketPref(context);
        clearVideoSourcePref(context);
        clearGreetingPref(context);
        clearFriendWidgetPref(context);
        clearChannelizePref(context);

//        sharedPreferences = context.getSharedPreferences(PEOPLE_SUGGESTION_PREF, Context.MODE_PRIVATE);
//        editor = sharedPreferences.edit();
//        editor.clear();
//        editor.apply();
        CartData.clearCartData(context);

        sharedPreferences = context.getSharedPreferences(REPORT_AD_PREF, Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

        sharedPreferences = context.getSharedPreferences(PRIME_MESSENGER_ENABLED_SETTING, Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

        sharedPreferences = context.getSharedPreferences(MEMBER_VIEW_PREF, Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

        sharedPreferences = context.getSharedPreferences(UNREAD_MESSAGE_COUNT_PREF, Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

        sharedPreferences = context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

        clearPipModePref(context);

    }


    /**
     * Used to update current selected listing type.
     *
     * @param context    Context of calling activity
     * @param key        save value according to key (listingtype_id)
     * @param Label      Label of current mlt.
     * @param listingId  id of current mlt.
     * @param browseType browse type of browse page
     * @param viewType   view type of mlt view page
     * @param mIcon      icon of current mlt.
     * @param canCreate  if 1 then show manage tab.
     * @param canView    if false then redirect to login page for logged out user.
     */
    public static void updateCurrentListingType(Context context, int key, String Label, String singularLabel,
                                                int listingId, int browseType, int viewType, String mIcon,
                                                int canCreate, int packagesEnabled, boolean canView, int secondaryBrowseType) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(CURRENT_MLT_LABEL + key, Label);
        editor.putString(CURRENT_MLT_SINGULAR_LABEL + key, singularLabel);
        editor.putInt(CURRENT_LISTING_ID, listingId);
        editor.putInt(BROWSE_MLT_TYPE + key, browseType);
        editor.putInt(SECONDARY_BROWSE_MLT_TYPE + key, secondaryBrowseType);
        editor.putInt(VIEW_MLT_TYPE + key, viewType);
        editor.putString(CURRENT_MLT_ICON + key, mIcon);
        editor.putInt(CAN_MLT_CREATE + key, canCreate);
        editor.putInt(MLT_PACKAGES_ENABLED + key, packagesEnabled);
        editor.putBoolean(MLT_CAN_VIEW + key, canView);
        editor.apply();
    }

    //Getting the current selected listing label.
    public static String getCurrentSelectedListingLabel(Context context, int key) {
        return context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE)
                .getString(CURRENT_MLT_LABEL + key, null);
    }

    //Getting the current selected listing singular label.
    public static String getCurrentSelectedListingSingularLabel(Context context, int key) {
        return context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE)
                .getString(CURRENT_MLT_SINGULAR_LABEL + key, null);
    }

    //Getting the current selected listing id.
    public static int getCurrentSelectedListingId(Context context) {
        return context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE)
                .getInt(CURRENT_LISTING_ID, 0);
    }

    //Getting the current selected listing icon.
    public static String getCurrentSelectedListingIcon(Context context, int key) {
        return context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE)
                .getString(CURRENT_MLT_ICON + key, null);
    }

    //Getting the browse type of current selected listing.
    public static int getCurrentSelectedListingBrowseType(Context context, int key) {
        return context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE)
                .getInt(BROWSE_MLT_TYPE + key, 0);
    }

    //Getting the secondary browse type of current selected listing.
    public static int getCurrentSelectedListingSecondaryBrowseType(Context context, int key) {
        return context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE)
                .getInt(SECONDARY_BROWSE_MLT_TYPE + key, 0);
    }

    // Setting browse type for a listing type.
    public static void setCurrentSelectedListingId(Context context, int listingId) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(CURRENT_LISTING_ID, listingId);
        editor.apply();
    }

    //Getting the view type of current selected listing.
    public static int getMLTViewType(Context context, int key) {
        return context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE)
                .getInt(VIEW_MLT_TYPE + key, 0);
    }

    //Getting the create permission of current selected listing.
    public static int getMLTCanCreate(Context context, int key) {
        return context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE)
                .getInt(CAN_MLT_CREATE + key, 0);
    }

    //Getting the create permission of current selected listing.
    public static boolean canMLTView(Context context, int key) {
        return context.getSharedPreferences(CURRENT_MLT_OPTION_PREF, Context.MODE_PRIVATE)
                .getBoolean(MLT_CAN_VIEW + key, true);
    }

    // Update Current version of the app.
    public static void updateCurrentAppVersionPref(Context context, String appVersion) {

        SharedPreferences sharedPreferences = context.getSharedPreferences(APP_VERSION_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(APP_VERSION_STRING, appVersion);
        editor.apply();
    }

    //Getting the current version of the app.
    public static String getCurrentAppVersion(Context context) {
        return context.getSharedPreferences(APP_VERSION_PREF, Context.MODE_PRIVATE)
                .getString(APP_VERSION_STRING, null);
    }

    // Update the Login Info Preferences and save the email and password of the logged-in user
    public static void UpdateLoginInfoPref(Context context, String email, String password, int userId) {
        // Save email and base64 encrypted password in SharedPreferences
        SharedPreferences sharedPreferences = context.getSharedPreferences(LOGIN_INFO_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(LOGIN_EMAIL, email);
        editor.putInt(LOGIN_USER_ID, userId);
        try {
            if (password != null) {
                byte[] passwordBytes = password.getBytes("UTF-8");
                String encryptedPassword = Base64.encodeToString(passwordBytes, Base64.NO_WRAP);
                editor.putString(LOGIN_PASSWORD, encryptedPassword);
            } else {
                editor.putString(LOGIN_PASSWORD, null);
            }

        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        editor.apply();
    }

    // Get Login Info (email and password of Login user)
    public static String getLoginInfo(Context context, String keyName) {
        return context.getSharedPreferences(LOGIN_INFO_PREF, Context.MODE_PRIVATE)
                .getString(keyName, null);
    }

    // Get Login Info (email and password of Login user)
    public static int getLoginUserId(Context context) {
        return context.getSharedPreferences(LOGIN_INFO_PREF, Context.MODE_PRIVATE)
                .getInt(LOGIN_USER_ID, 0);
    }

    //Updating location enabled setting
    public static void updateLocationEnabledSetting(Context context, int locationEnabled) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(LOCATION_SETTING_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(LOCATION_ENABLED, locationEnabled);
        editor.apply();
    }

    //Checking for guest user setting
    public static boolean isLocationSettingEnabled(Context context) {
        return context.getSharedPreferences(LOCATION_SETTING_PREFERENCES, Context.MODE_PRIVATE)
                .getInt(LOCATION_ENABLED, 0) == 1;
    }

    // Setting sound effect value into preferences.
    public static void setSoundEffectValue(Context context, boolean isSoundEnabled) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SOUND_SETTING_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(SOUND_ENABLED, isSoundEnabled);
        editor.apply();
    }

    //Getting the sound effect value.
    public static boolean isSoundEffectEnabled(Context context) {
        return context.getSharedPreferences(SOUND_SETTING_PREF, Context.MODE_PRIVATE)
                .getBoolean(SOUND_ENABLED, false);
    }

    /**
     * Update FeedReactions/MyFeedReactions Preferences for feeds
     */
    public static void updateFeedReactionsPref(Context context, String reactionsKey, JSONObject feedReactions) {

        if (feedReactions != null) {
            SharedPreferences sharedPreferences = context.getSharedPreferences(FEED_REACTIONS_PREF, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharedPreferences.edit();

            editor.putString(reactionsKey, feedReactions.toString());

            editor.apply();
        }
    }

    /**
     * Update FeedReactions/MyFeedReactions Preferences for feeds
     */
    public static void storeReactions(Context context, JSONObject reactions) {

        if (reactions != null) {
            SharedPreferences sharedPreferences = context.getSharedPreferences(REACTIONS_PREF, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharedPreferences.edit();

            editor.putString(REACTIONS, reactions.toString());

            editor.apply();
        }
    }

    /**
     * Get All Reactions object
     */
    public static String getAllReactionsObject(Context context) {
        return context.getSharedPreferences(REACTIONS_PREF, Context.MODE_PRIVATE)
                .getString(REACTIONS, null);
    }

    public static void clearAllReactionsPref(Context context) {

        SharedPreferences sharedPreferences = context.getSharedPreferences(REACTIONS_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
    }

    /**
     * Get String value from Like Shared Preferences
     */
    public static String getReactionsObject(Context context, String keyName) {
        return context.getSharedPreferences(FEED_REACTIONS_PREF, Context.MODE_PRIVATE)
                .getString(keyName, null);
    }

    public static void clearReactionsPref(Context context) {

        SharedPreferences sharedPreferences = context.getSharedPreferences(FEED_REACTIONS_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

    }

    public static void updateReactionsEnabledPref(Context context, int reactionsEnabled) {

        SharedPreferences sharedPreferences = context.getSharedPreferences(REACTIONS_ENABLED_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();

        editor.putInt(REACTIONS_ENABLED, reactionsEnabled);
        editor.apply();
    }

    /**
     * Get Stickers Enabled Value
     */
    public static int getReactionsEnabled(Context context) {
        return context.getSharedPreferences(REACTIONS_ENABLED_PREF, Context.MODE_PRIVATE)
                .getInt(REACTIONS_ENABLED, -1);
    }

    public static void updateStickersEnabledPref(Context context, int stickersEnabled) {

        SharedPreferences sharedPreferences = context.getSharedPreferences(STICKERS_ENABLED_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();

        editor.putInt(STICKERS_ENABLED, stickersEnabled);
        editor.apply();
    }

    /**
     * Get Stickers Enabled Value
     */
    public static int getStickersEnabled(Context context) {
        return context.getSharedPreferences(STICKERS_ENABLED_PREF, Context.MODE_PRIVATE)
                .getInt(STICKERS_ENABLED, 0);
    }

    public static void updateStickersStorePref(Context context, JSONArray stickerStoreMenuArray) {

        if (stickerStoreMenuArray != null) {
            SharedPreferences sharedPreferences = context.getSharedPreferences(STICKERS_STORE_PREF, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharedPreferences.edit();

            editor.putString(STICKERS_STORE_MENU, stickerStoreMenuArray.toString());
            editor.apply();
        }
    }

    /**
     * Get Stickers Enabled Value
     */
    public static String getStickersStoreMenu(Context context) {
        return context.getSharedPreferences(STICKERS_STORE_PREF, Context.MODE_PRIVATE)
                .getString(STICKERS_STORE_MENU, null);
    }

    public static void clearStickerStoreMenuPref(Context context) {

        SharedPreferences sharedPreferences = context.getSharedPreferences(STICKERS_STORE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();

    }

    //Updating Nestedcomments Enabled setting
    public static void updateNestedCommentEnabled(Context context, int nestedCommentEnabled) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MODULE_ENABLED, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(NESTED_COMMENT_ENABLED, nestedCommentEnabled);
        editor.apply();
    }

    //Checking for Nested Comment Enabled
    public static boolean isNestedCommentEnabled(Context context) {
        return context.getSharedPreferences(MODULE_ENABLED, Context.MODE_PRIVATE)
                .getInt(NESTED_COMMENT_ENABLED, 0) == 1;
    }

    /**
     * Update Site Content Cover Enabled Value
     */

    public static void updateSiteContentCoverPhotoEnabled(Context context, int contentCoverEnabled) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SITE_CONTENT_COVER_PHOTO_ENABLED_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(CONTENT_COVER_ENABLED, contentCoverEnabled);
        editor.apply();
    }

    /**
     * Get Site Content Cover Enabled Value
     */
    public static int getSiteContentCoverPhotoEnabled(Context context) {
        return context.getSharedPreferences(SITE_CONTENT_COVER_PHOTO_ENABLED_PREF, Context.MODE_PRIVATE)
                .getInt(CONTENT_COVER_ENABLED, 0);

    }

    /**
     * Set enable module data
     */

    public static void setEnabledModuleList(Context context, String enableModule) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(ENABLE_MODULE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(ENABLE_MODULE_LIST, enableModule);
        editor.apply();
    }

    /**
     * Get Enable module list
     */
    public static String getEnabledModuleList(Context context) {
        return context.getSharedPreferences(ENABLE_MODULE_PREF, Context.MODE_PRIVATE)
                .getString(ENABLE_MODULE_LIST, null);
    }

    // Setting emoji enabled value into preferences.
    public static void setEmojiEnablePref(Context context, int emojiEnabled) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(EMOJI_ENABLE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(EMOJI_ENABLED, emojiEnabled);
        editor.apply();
    }

    //Getting the emoji enabled value.
    public static int getEmojiEnabled(Context context) {
        return context.getSharedPreferences(EMOJI_ENABLE_PREF, Context.MODE_PRIVATE)
                .getInt(EMOJI_ENABLED, 0);
    }

    //Storing launch count of the app for Rating dialog
    public static void updateLaunchCount(Context context, int launchCount) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(APP_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(APP_LAUNCH_COUNT, launchCount);
        editor.apply();
    }

    //Getting the launch count value.
    public static int getLaunchCount(Context context) {
        return context.getSharedPreferences(APP_PREFERENCES, Context.MODE_PRIVATE)
                .getInt(APP_LAUNCH_COUNT, 0);
    }

    //Updating the never rate click pref.
    public static void updateRatePref(Context context, String buttonType) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(APP_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(buttonType, true);
        editor.apply();
    }

    public static boolean isAppRated(Context context, String buttonType) {
        return context.getSharedPreferences(APP_PREFERENCES, Context.MODE_PRIVATE)
                .getBoolean(buttonType, false);
    }


    /**
     * Update Report Ads Form JsonArray
     */
    public static void updateReportAdsFormArray(Context context, JSONArray reportAdFormArray) {

        if (reportAdFormArray != null) {
            SharedPreferences sharedPreferences = context.getSharedPreferences(REPORT_AD_PREF, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharedPreferences.edit();

            editor.putString(REPORT_ADS_ARRAY, reportAdFormArray.toString());
            editor.apply();
        }
    }

    /**
     * Get Report Ads Form JsonArray
     */
    public static String getReportAdsArray(Context context) {
        return context.getSharedPreferences(REPORT_AD_PREF, Context.MODE_PRIVATE)
                .getString(REPORT_ADS_ARRAY, null);
    }

    //Updating the ticket enabled pref.
    public static void updateTicketEnabledPref(Context context, int ticketEnabled) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(TICKET_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(IS_TICKET_ENABLED, (ticketEnabled == 1));
        editor.apply();
    }

    public static boolean isTicketEnabled(Context context) {
        return context.getSharedPreferences(TICKET_PREF, Context.MODE_PRIVATE)
                .getBoolean(IS_TICKET_ENABLED, false);
    }

    public static void clearTicketPref(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(TICKET_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
    }


    //Updating guest user setting data
    public static void updatePrimeMessengerEnabled(Context context, int primeMessengerEnabled){
        SharedPreferences sharedPreferences = context.getSharedPreferences(PRIME_MESSENGER_ENABLED_SETTING, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(IS_MESSENGER_ENABLED, primeMessengerEnabled);
        editor.apply();
    }

    //Checking for guest user setting
    public static boolean isPrimeMessengerEnabled(Context context){
        return context.getSharedPreferences(PRIME_MESSENGER_ENABLED_SETTING, Context.MODE_PRIVATE)
                .getInt(IS_MESSENGER_ENABLED, 0) == 1;
    }

    //Updating guest user setting data
    public static void updatePaidMemberStatus(Context context, int paidMemberStatus){
        SharedPreferences sharedPreferences = context.getSharedPreferences(PAID_MEMBER_STATUS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(IS_PAID_MEMBER, paidMemberStatus);
        editor.apply();
    }

    //Checking for guest user setting
    public static boolean isPaidMember(Context context){
        return context.getSharedPreferences(PAID_MEMBER_STATUS, Context.MODE_PRIVATE)
                .getInt(IS_PAID_MEMBER, 0) == 1;
    }

    //Updating guest user setting data
    public static void updateUnReadMessageCount(Context context, int unReadMessageCount){
        SharedPreferences sharedPreferences = context.getSharedPreferences(UNREAD_MESSAGE_COUNT_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(UNREAD_MESSAGE_COUNT, unReadMessageCount);
        editor.apply();
    }

    //Checking for guest user setting
    public static int getUnReadMessageCount(Context context) {
        return context.getSharedPreferences(UNREAD_MESSAGE_COUNT_PREF, Context.MODE_PRIVATE)
                .getInt(UNREAD_MESSAGE_COUNT, 0);
    }


    //Updating the video source pref.
    public static void setVideoSourcePref(Context context, boolean isMyDeviceEnabled) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(VIDEO_SOURCE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(IS_MY_DEVICE_ENABLED, isMyDeviceEnabled);
        editor.apply();
    }

    public static boolean isMyDeviceEnabled(Context context) {
        return context.getSharedPreferences(VIDEO_SOURCE_PREF, Context.MODE_PRIVATE)
                .getBoolean(IS_MY_DEVICE_ENABLED, false);
    }

    public static void clearVideoSourcePref(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(VIDEO_SOURCE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
    }

    // Setting member view type into preferences.
    public static void updateMemberViewType(Context context, int viewType) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MEMBER_VIEW_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(MEMBER_VIEW_TYPE, viewType);
        editor.apply();
    }

    //Getting the member view type.
    public static int getMemberViewType(Context context) {
        return context.getSharedPreferences(MEMBER_VIEW_PREF, Context.MODE_PRIVATE)
                .getInt(MEMBER_VIEW_TYPE, 1);
    }

    // Method to set remind me later time for app upgrade popup.
    public static void setUpgradeRemindMeLaterTime(Context context, String time) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(APP_UPGRADE_REMIND, time);
        editor.apply();
    }

    // Method to set ignore for the app upgrade popup.
    public static void setAppUpgradeDialogIgnored(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(APP_UPGRADE_DIALOG_IGNORED, true);
        editor.apply();
    }

    // Returns true if the user clicked on ignore for app upgrade.
    public static boolean isAppUpgradeDialogIgnored(Context context) {
        return context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE)
                .getBoolean(APP_UPGRADE_DIALOG_IGNORED, false);
    }

    // Returns the time when the user clicked on remind me later.
    public static String getAppUpgradeRemindTime(Context context) {
        return context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE)
                .getString(APP_UPGRADE_REMIND, null);
    }

    // Method to set app upgrade info.
    public static void setAppUpgradeInfo(Context context, String version, String description) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(APP_UPGRADE_VERSION, version);
        editor.putString(APP_UPGRADE_DESCRIPTION, description);
        editor.apply();
    }

    // Returns the version app upgrade.
    public static String getAppUpgradeVersion(Context context) {
        return context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE)
                .getString(APP_UPGRADE_VERSION, null);
    }

    // Returns the description app upgrade.
    public static String getAppUpgradeDescription(Context context) {
        return context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE)
                .getString(APP_UPGRADE_DESCRIPTION, null);
    }

    // Method to set force app upgrade info.
    public static void setForceAppUpgrade(Context context, String forceAppUpgrade) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(FORCE_APP_UPGRADE, forceAppUpgrade);
        editor.apply();
    }

    // Returns the force app upgrade info.
    public static String getForceAppUpgrade(Context context) {
        return context.getSharedPreferences(APP_UPGRADE_PREF, Context.MODE_PRIVATE)
                .getString(FORCE_APP_UPGRADE, null);
    }

    // Setting video quality value into preferences.
    public static void setVideoQualityPref(Context context, int videoQuality) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(VIDEO_QUALITY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(VIDEO_QUALITY, videoQuality);
        editor.apply();
    }

    //Getting the video quality value.
    public static int getVideoQuality(Context context) {
        return context.getSharedPreferences(VIDEO_QUALITY_PREF, Context.MODE_PRIVATE)
                .getInt(VIDEO_QUALITY, 0);
    }

    // Setting story duration value into preferences.
    public static void setStoryDuration(Context context, int storyDuration) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(STORY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(STORY_DURATION, storyDuration);
        editor.apply();
    }

    //Getting the value of story duration
    public static int getStoryDuration(Context context) {
        return context.getSharedPreferences(STORY_PREF, Context.MODE_PRIVATE)
                .getInt(STORY_DURATION, 1);
    }

    // Setting story privacy.
    public static void setStoryPrivacy(Context context, JSONObject storyPrivacy) {
        if (storyPrivacy != null) {
            SharedPreferences sharedPreferences = context.getSharedPreferences(STORY_PREF, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putString(STORY_PRIVACY, storyPrivacy.toString());
            editor.apply();
        }
    }

    //Getting the value of story privacy key
    public static String getStoryPrivacyKey(Context context) {
        return context.getSharedPreferences(STORY_PREF, Context.MODE_PRIVATE)
                .getString(STORY_PRIVACY_KEY, "everyone");
    }

    //Getting the value of story privacy
    public static String getStoryPrivacy(Context context) {
        return context.getSharedPreferences(STORY_PREF, Context.MODE_PRIVATE)
                .getString(STORY_PRIVACY, null);
    }

    // Setting story privacy key
    public static void setStoryPrivacyKey(Context context, String key) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(STORY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(STORY_PRIVACY_KEY, key);
        editor.apply();
    }

    // Setting aaf filter enabled value into preferences.
    public static void setFilterEnabled(Context context, int isFilterEnabled) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(AAF_FILTER_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(IS_FILTER_ENABLED, isFilterEnabled == 1);
        editor.apply();
    }

    //Getting the value filter enabled or not
    public static boolean isAAFFilterEnabled(Context context) {
        return context.getSharedPreferences(AAF_FILTER_PREF, Context.MODE_PRIVATE)
                .getBoolean(IS_FILTER_ENABLED, true);
    }

    // Setting otp enabled value into preferences
    public static void setOtpEnabledOption(Context context, String otpOption) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(OTP_ENABLED_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(OTP_OPTION, otpOption);
        editor.apply();
    }

    //Getting the value otp enabled or not
    public static String getOtpEnabledOption(Context context) {
        return context.getSharedPreferences(OTP_ENABLED_PREF, Context.MODE_PRIVATE)
                .getString(OTP_OPTION, null);
    }

    // Setting otp plugin enabled value into preferences
    public static void setOtpPluginEnabled(Context context, int isOtpEnabled) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(OTP_PLUGIN_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(IS_OTP_PLUGIN, isOtpEnabled == 1);
        editor.apply();
    }

    //Getting the value otp plugin enabled or not
    public static boolean isOTPPluginEnabled(Context context) {
        return context.getSharedPreferences(OTP_PLUGIN_PREF, Context.MODE_PRIVATE)
                .getBoolean(IS_OTP_PLUGIN, false);
    }

    // Setting removed greetings in pref.
    public static void setRemovedGreeting(Context context, String greetingId) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(AAF_GREETINGS_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        ArrayList<String> removedList = getRemovedGreetings(context) != null
                ? getRemovedGreetings(context) : new ArrayList<>();
        removedList.add(greetingId);

        Gson gson = new Gson();
        editor.putString(AAF_GREETINGS, gson.toJson(removedList));
        editor.apply();
    }

    // Getting the list of removed greetings.
    public static ArrayList getRemovedGreetings(Context context) {
        String removedGreetings = context.getSharedPreferences(AAF_GREETINGS_PREF, Context.MODE_PRIVATE)
                .getString(AAF_GREETINGS, "");
        Gson gson = new Gson();
        return gson.fromJson(removedGreetings, ArrayList.class);
    }

    // Setting removed greetings in pref.
    public static void setRemovedBirthday(Context context, String userId) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(AAF_GREETINGS_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        ArrayList<String> removedList = getRemovedBirthdays(context) != null
                ? getRemovedBirthdays(context) : new ArrayList<>();
        removedList.add(userId);

        Gson gson = new Gson();
        editor.putString(BIRTHDAYS, gson.toJson(removedList));
        editor.apply();
    }

    // Setting status privacy key
    public static void setStatusPrivacyKey(Context context, String key) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(STATUS_PRIVACY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(STATUS_PRIVACY_KEY, key);
        editor.apply();
    }

    // Setting multiple options privacy key
    public static void setStatusPrivacyMultiOptions(Context context, String multiOptions) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(STATUS_PRIVACY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(STATUS_PRIVACY_MULTI_OPTIONS, multiOptions);
        editor.apply();
    }

    // Setting all status privacy options
    public static void setStatusPrivacyOptions(Context context, JSONObject statusPostPrivacy) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(STATUS_PRIVACY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(STATUS_POST_PRIVACY_OPTIONS, statusPostPrivacy.toString());
        editor.apply();
    }

    //Getting the value of privacy key
    public static String getStatusPrivacyKey(Context context) {
        return context.getSharedPreferences(STATUS_PRIVACY_PREF, Context.MODE_PRIVATE)
                .getString(STATUS_PRIVACY_KEY, "everyone");
    }

    //Getting the multiple privacy values of privacy key
    public static String getStatusPrivacyMultiOptions(Context context) {
        return context.getSharedPreferences(STATUS_PRIVACY_PREF, Context.MODE_PRIVATE)
                .getString(STATUS_PRIVACY_MULTI_OPTIONS, null);
    }

    //Getting the status post privacy options.
    public static String getStatusPostPrivacyOptions(Context context) {
        return context.getSharedPreferences(STATUS_PRIVACY_PREF, Context.MODE_PRIVATE)
                .getString(STATUS_POST_PRIVACY_OPTIONS, null);
    }

    // Getting the list of removed greetings.
    public static ArrayList getRemovedBirthdays(Context context) {
        String removedGreetings = context.getSharedPreferences(AAF_GREETINGS_PREF, Context.MODE_PRIVATE)
                .getString(BIRTHDAYS, "");
        Gson gson = new Gson();
        return gson.fromJson(removedGreetings, ArrayList.class);
    }

    // Setting removed greetings in pref.
    public static void setCurrentDate(Context context, String currentDate) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(AAF_GREETINGS_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(GREETINGS_DATE, currentDate);
        editor.apply();
    }

    //Getting the Current date value.
    public static String getGreetingCurrentDate(Context context) {
        return context.getSharedPreferences(AAF_GREETINGS_PREF, Context.MODE_PRIVATE)
                .getString(GREETINGS_DATE, null);
    }

    public static void clearGreetingPref(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(AAF_GREETINGS_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
    }


    // Preferences for show case view work
    public static void setShowCaseViewPref(Context context, boolean navigationIcon, boolean searchBar,
                                           boolean cartIcon, boolean location, boolean searchIcon,
                                           boolean statusPost, boolean fabCreate, boolean fabMenu,
                                           boolean feedHomeIcon, boolean userProfile) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SHOW_CASE_VIEW_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(NAVIGATION_ICON_CASE_VIEW, navigationIcon);
        editor.putBoolean(SEARCH_BAR_CASE_VIEW, searchBar);
        editor.putBoolean(CART_ICON_CASE_VIEW, cartIcon);
        editor.putBoolean(LOCATION_ICON_CASE_VIEW, location);
        editor.putBoolean(SEARCH_ICON_CASE_VIEW, searchIcon);
        editor.putBoolean(STATUS_POST_CASE_VIEW, statusPost);
        editor.putBoolean(FAB_CREATE_CASE_VIEW, fabCreate);
        editor.putBoolean(FAB_MENU_CASE_VIEW, fabMenu);
        editor.putBoolean(FEED_HOME_ICON_SHOW_CASE_VIEW, feedHomeIcon);
        editor.putBoolean(USER_PROFILE_SHOW_CASE_VIEW, userProfile);
        editor.apply();
    }

    public static void setProfileShowCaseViewPref(Context context, boolean editProfile, boolean editPhoto,
                                                  boolean moreIcon, boolean message, boolean friends,
                                                  boolean fabCreate, boolean follow) {

        SharedPreferences sharedPreferences = context.getSharedPreferences(SHOW_CASE_VIEW_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(USER_PROFILE_EDIT_SHOW_CASE_VIEW, editProfile);
        editor.putBoolean(USER_PROFILE_EDIT_PHOTO_SHOW_CASE_VIEW, editPhoto);
        editor.putBoolean(USER_PROFILE_MORE_SHOW_CASE_VIEW, moreIcon);
        editor.putBoolean(USER_PROFILE_MESSAGE_SHOW_CASE_VIEW, message);
        editor.putBoolean(USER_PROFILE_FRIENDS_SHOW_CASE_VIEW, friends);
        editor.putBoolean(USER_PROFILE_FAB_CREATE_SHOW_CASE_VIEW, fabCreate);
        editor.putBoolean(USER_PROFILE_FOLLOW_SHOW_CASE_VIEW, follow);
        editor.apply();
    }

    public static void updateShowCaseView(Context context, String showCaseType) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SHOW_CASE_VIEW_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(showCaseType, true);
        editor.apply();
    }

    public static Boolean getShowCaseView(Context context, String showCaseType) {
        return context.getSharedPreferences(SHOW_CASE_VIEW_PREF, Context.MODE_PRIVATE)
                .getBoolean(showCaseType, false);
    }

    // Setting video auto play preferences.
    public static void setVideoAutoPlaySetting(Context context, String type) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(VIDEO_AUTO_PLAY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(VIDEO_AUTO_PLAY, type);
        editor.apply();
    }

    // Getting the video auto play settings value.
    public static String getVideoAutoPlaySetting(Context context) {
        return context.getSharedPreferences(VIDEO_AUTO_PLAY_PREF, Context.MODE_PRIVATE)
                .getString(VIDEO_AUTO_PLAY, "both");
    }

    // Setting story duration value into preferences.
    public static void setLiveStreamingInfo(Context context, JSONObject liveStreamObject) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(LIVE_STREAMING_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(LIVE_STREAMING_ENABLED, liveStreamObject.optBoolean("enableBroadcast"));
        editor.putInt(LIVE_STREAMING_LIMIT, liveStreamObject.optInt("duration"));
        editor.apply();
    }

    // Disabling live stream into preferences.
    public static void disableLiveStreaming(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(LIVE_STREAMING_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(LIVE_STREAMING_ENABLED, false);
        editor.putInt(LIVE_STREAMING_LIMIT, 0);
        editor.apply();
    }

    public static boolean isLiveStreamingEnabled(Context context) {
        return context.getSharedPreferences(LIVE_STREAMING_PREF, Context.MODE_PRIVATE)
                .getBoolean(LIVE_STREAMING_ENABLED, true);
    }

    public static int getLiveStreamingLimit(Context context) {
        return context.getSharedPreferences(LIVE_STREAMING_PREF, Context.MODE_PRIVATE)
                .getInt(LIVE_STREAMING_LIMIT, 0);
    }

    // Setting modules settings
    public static void setModulesSettings(Context context, String moduleSettings) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MODULE_WISE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(MODULE_WISE_SETTINGS, moduleSettings);
        editor.apply();
    }

    //Getting modules settings
    public static JSONObject getModuleSettings(Context context, String moduleName) {
        String jsonStrings = context.getSharedPreferences(MODULE_WISE_SETTINGS, Context.MODE_PRIVATE)
                .getString(MODULE_WISE_SETTINGS, null);
        if (jsonStrings == null) {
            return null;
        }
        try {
            JSONObject jsonObject = new JSONObject(jsonStrings);
            return jsonObject.optJSONObject(moduleName);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    //Getting the value of host path prefix for deeplinking
    public static JSONObject getHostPathPrefix(Context context) {
        if (context.getSharedPreferences(DEEPLINKING_PREF, Context.MODE_PRIVATE)
                .getString(HOST_PATH_PREFIXES, null) != null) {
            try {
                return new JSONObject(context.getSharedPreferences(DEEPLINKING_PREF, Context.MODE_PRIVATE)
                        .getString(HOST_PATH_PREFIXES, null));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    // Setting the values of host path pefix for deepllinking
    public static void setHostPathPrefix(Context context, String response){
        SharedPreferences sharedPreferences = context.getSharedPreferences(DEEPLINKING_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(HOST_PATH_PREFIXES, response);
        editor.apply();
    }


    // Multi currency methods
    // Updating default currency.
    public static void updateDefaultCurrency(Context context, String currency) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(MULTI_CURRENCY_DEFAULT, currency);
        editor.apply();
    }

    // Used to get default currency from preference
    public static String getDefaultCurrency(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        return sharedPreferences.getString(MULTI_CURRENCY_DEFAULT, "");
    }

    // Used to get default currency from preference
    public static String getDefaultCurrencyString(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        try {
            JSONObject jsonObject = new JSONObject(sharedPreferences.getString(MULTI_CURRENCY_DEFAULT, ""));
            if (jsonObject != null && jsonObject.has("code")) {
                return jsonObject.optString("code");
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return "";
    }

    // Used to check multi currency is enabled or not
    public static boolean isMultiCurrencyEnabled(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        return sharedPreferences.getBoolean(MULTI_CURRENCY_ENABLED, false);
    }

    // Set multi currency is enabled or not
    public static void setMultiCurrencyEnabled(Context context, boolean enable) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(MULTI_CURRENCY_ENABLED, enable);
        editor.apply();
    }


    // Set multi currency response
    public static void setMultiCurrencyResponse(Context context, String currencyData) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(MULTI_CURRENCY_DATA, currencyData);
        editor.apply();
    }

    // Used to get multi currency response
    public static String getMultiCurrencyResponse(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        return sharedPreferences.getString(MULTI_CURRENCY_DATA, "");
    }

    // Used to get default currency from preference
    public static String getSelectedCurrency(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        return sharedPreferences.getString(MULTI_CURRENCY_SELECTED, "");
    }

    // Set current selected currency
    public static void setSelectedCurrency(Context context, String currency, String info) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(MULTI_CURRENCY_SELECTED, currency);
        editor.putString(MULTI_CURRENCY_SELECTED_INFO, info);
        editor.apply();
    }

    // Used to get selected currency info from preferences
    public static String getSelectedCurrencyInfo(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        return sharedPreferences.getString(MULTI_CURRENCY_SELECTED_INFO, "");
    }

    // Used to get default currency from preference
    public static String getCurrencyFormat(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        return sharedPreferences.getString(MULTI_CURRENCY_FORMAT, "");
    }

    // Set current selected currency
    public static void setCurrencyFormat(Context context, String currency) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(MULTI_CURRENCY_FORMAT, currency);
        editor.apply();
    }


    /* Clear currency data from preferences */
    public static void clearMultiCurrencyData(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(MULTI_CURRENCY_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
    }

    // Setting pip mode video play preferences.
    public static void setPipModeEnable(Context context, boolean enable) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(PIP_MODE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(PIP_MODE_ENABLE, enable);
        editor.apply();
    }

    // Getting the video auto play settings value.
    public static boolean isPipModeEnabled(Context context) {
        return context.getSharedPreferences(PIP_MODE_PREF, Context.MODE_PRIVATE)
                .getBoolean(PIP_MODE_ENABLE, true) && ConstantVariables.ENABLE_PIP == 1;
    }


    // Getting the video auto play settings value.
    public static boolean isPipUserPopupDisplayed(Context context) {
        return context.getSharedPreferences(PIP_MODE_PREF, Context.MODE_PRIVATE)
                .getBoolean(PIP_USER_POPUP_DISPLAYED, false);
    }

    public static void updatePipUserPopupDisplayed(Context context, boolean update) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(PIP_MODE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(PIP_USER_POPUP_DISPLAYED, update);
        editor.apply();
    }


    public static boolean isPipPermissionPopupDisplayed(Context context) {
        return context.getSharedPreferences(PIP_MODE_PREF, Context.MODE_PRIVATE)
                .getBoolean(PIP_PERMISSION_POPUP_DISPLAYED, false);
    }

    public static void updatePipPermissionPopupDisplayed(Context context, boolean update) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(PIP_MODE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(PIP_PERMISSION_POPUP_DISPLAYED, update);
        editor.apply();
    }


    public static boolean isPlayVideoInPip(Context context) {
        return context.getSharedPreferences(PIP_MODE_PREF, Context.MODE_PRIVATE)
                .getBoolean(PLAY_VIDEO_IN_PIP, false);
    }

    public static void updatePlayVideoInPip(Context context, boolean update) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(PIP_MODE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(PLAY_VIDEO_IN_PIP, update);
        editor.apply();
    }

    public static void clearPipModePref(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(PIP_MODE_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
    }

    /* Channelize preferences */
    public static void setChannelizeAccessToken(Context context, String channelizeAccessToken) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(CHANNELIZE_ACCESS_TOKEN_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(PreferencesUtils.CHANNELIZE_ACCESS_TOKEN, channelizeAccessToken);
        editor.apply();
    }

    public static String getChannelizeAccessToken(Context context) {
        return context.getSharedPreferences(CHANNELIZE_ACCESS_TOKEN_PREF, Context.MODE_PRIVATE)
                .getString(CHANNELIZE_ACCESS_TOKEN, null);
    }

    public static void clearChannelizePref(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(CHANNELIZE_ACCESS_TOKEN_PREF, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
    }
}

