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

package com.socialengineaddons.mobileapp.classes.modules.messagingMiddleware;


import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;

import com.google.firebase.messaging.RemoteMessage;
import com.socialengineaddons.mobileapp.classes.common.interfaces.MissedCallCountListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.UnreadMessageCountListener;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.core.AppController;

import java.util.Locale;


public class MessageCoreUtils {

    /**
     * Method to initialize the Channelize sdk if present.
     * Will be called using package name.
     */
    public static void initializeChannelize() {
        GlobalFunctions.invokeMethod(AppController.getInstance().getPackageName()
                + ".classes.modules.channelize.ChannelizeMediatorUtils", "initializeChannelize", new Bundle());
    }

    /**
     * Method to check channelize is active or not.
     */
    public static void checkChannelize() {
        GlobalFunctions.invokeMethod(AppController.getInstance().getPackageName()
                + ".classes.modules.channelize.ChannelizeMediatorUtils", "checkChannelize", new Bundle());
    }

    /**
     * Method to login into Channelize using emailId or UserId.
     *
     * @param emailId EmailId of the user.
     */
    public static void login(String emailId) {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_LOGIN)
                .login(emailId)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to login into Channelize using UserId and Client-Server Token.
     *
     * @param userId            UserId of the user.
     * @param clientServerToken Client-Server token to login into Channelize.
     */
    public static void login(String userId, String clientServerToken) {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_LOGIN)
                .login(userId, clientServerToken)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to logout from the Channelize.
     */
    public static void logout() {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_LOGOUT)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to open conversation screen between 2 user.
     *
     * @param context      Context of calling Activity/Fragment.
     * @param userId       User id of the user with whom logged-in user wants to chat.
     * @param displayName  Display name of the user with whom logged-in user will chat.
     * @param profileImage Profile image of the other user.
     */
    public static void openTwoUsersConversation(Context context, String userId,
                                                String displayName, String profileImage) {
        openTwoUsersConversation(context, 0, userId, displayName, profileImage, null);
    }

    /**
     * Method to open conversation screen between 2 user.
     *
     * @param context      Context of calling Activity/Fragment.
     * @param requestCode  Request code for which conversation screen needs to be launched.
     * @param userId       User id of the user with whom logged-in user wants to chat.
     * @param displayName  Display name of the user with whom logged-in user will chat.
     * @param profileImage Profile image of the other user.
     */
    public static void openTwoUsersConversation(Context context, int requestCode, String userId,
                                                String displayName, String profileImage) {
        openTwoUsersConversation(context, requestCode, userId, displayName, profileImage, null);
    }

    /**
     * Method to open conversation screen between 2 user.
     *
     * @param context      Context of calling Activity/Fragment.
     * @param requestCode  Request code for which conversation screen needs to be launched.
     * @param userId       User id of the user with whom logged-in user wants to chat.
     * @param displayName  Display name of the user with whom logged-in user will chat.
     * @param profileImage Profile image of the other user.
     */
    public static void openTwoUsersConversation(Context context, int requestCode, String userId,
                                                String displayName, String profileImage,
                                                Fragment fragment) {

        Event event = new Event.Builder()
                .setEvent(Event.EVENT_OPEN_CONVERSATION)
                .openConversation(context, requestCode, userId, displayName, profileImage, fragment)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to launch the Channelize UI.
     *
     * @param context          Context of calling Activity/Fragment.
     * @param conversationInfo Bundle which contains the info that need to be passed to the SDK.
     * @param requestCode      RequestCode to launch the Channelize.
     */
    public static void openChannelize(Context context, Bundle conversationInfo, int requestCode) {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_OPEN_CHANNELIZE)
                .openChannelize(context, conversationInfo, requestCode)
                .build();
        EventBus.getInstance().passEvent(event);

    }

    /**
     * Method to send a message to the user in Channelize.
     *
     * @param userId  UserId of the receiver.
     * @param message Message Body that need to be send to the user.
     */
    public static void sendMessageToUser(String userId, String message) {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_SEND_MESSAGE)
                .sendMessage(userId, message)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to share the content url in Channelize.
     *
     * @param context Context of calling Activity/Fragment.
     * @param linkUrl Content url that need to be shared.
     */
    public static void shareContentInChannelize(Context context, String linkUrl) {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_SHARE_CONTENT)
                .shareContent(context, linkUrl)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to update the Channelize locale when main app's locale has been updated.
     *
     * @param locale New Locale that need to be update.
     */
    public static void updateAppLanguage(Locale locale) {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_UPDATE_LANGUAGE)
                .updateAppLanguage(locale)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to process the fcm push notification of the channelize.
     *
     * @param applicationContext Context of application.
     * @param remoteMessage      RemoteMessage which contains the push notification info.
     */
    public static void processPushNotification(Context applicationContext, RemoteMessage remoteMessage) {
        checkChannelize();
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_PROCESS_FCM_NOTIFICATION)
                .processPushNotification(applicationContext, remoteMessage)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to clear the fcm push notification of the channelize.
     */
    public static void clearPushNotification() {
        checkChannelize();
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_CLEAR_FCM_NOTIFICATION)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to check for the last created cache time.
     */
    public static void checkForOutDatedCache() {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_CACHE_EXPIRY_TIME)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to fetch the unread messages count in Channelize api.
     *
     * @param unreadMessageCountListener UnreadMessageCountListener instance that will be invoked when the response has been fetched.
     */
    public static void findUnReadMessageCount(UnreadMessageCountListener unreadMessageCountListener) {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_FIND_MESSAGE_COUNT)
                .setUnreadMessageCountListener(unreadMessageCountListener)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to fetch the missed call count in Channelize api.
     *
     * @param missedCallCountListener MissedCallCountListener instance that will be invoked when the response has been fetched.
     */
    public static void findMissedCallCount(MissedCallCountListener missedCallCountListener) {
        Event event = new Event.Builder()
                .setEvent(Event.EVENT_FIND_MISSED_CALL_COUNT)
                .setMissedCallCountListener(missedCallCountListener)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * Method to check that video/voice calling is running in Channelize or not.
     *
     * @param context Context of calling class.
     * @return Returns true, if the video/voice call is active.
     */
    public static boolean isVideoCallRunning(Context context) {
        Class videoClass;
        try {
            videoClass = Class.forName("com.channelize.callsdk.pip.VideoService");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
        return GlobalFunctions.isMyServiceRunning(context, videoClass);
    }

    /**
     * Method to get the missed call count which are already fetched from the api.
     *
     * @return Returns the missed call count.
     */
    public static int getMissedCallCount() {
        Object object = GlobalFunctions.invokeMethod(AppController.getInstance().getPackageName()
                + ".classes.modules.channelize.ChannelizeMediatorUtils", "getMissedCallCount", new Bundle());
        // Null check added, when the channelize is not present then the object will be null.
        if (object != null && object instanceof Integer) {
            return (int) object;
        }
        return 0;
    }
}
