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
import android.support.annotation.StringDef;
import android.support.v4.app.Fragment;

import com.google.firebase.messaging.RemoteMessage;
import com.socialengineaddons.mobileapp.classes.common.interfaces.MissedCallCountListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.UnreadMessageCountListener;

import java.lang.annotation.Retention;
import java.util.Locale;

import static java.lang.annotation.RetentionPolicy.SOURCE;


public class Event {

    // Member variables.
    private String event;
    private String email;
    private String userId;
    private String clientServerToken;
    private String message;
    private String displayName;
    private String profileImage;
    private int requestCode;
    private Bundle conversationInfo;
    private Context activityContext;
    private Fragment fragment;
    private Locale locale;
    private Context applicationContext;
    private RemoteMessage remoteMessage;
    private UnreadMessageCountListener unreadMessageCountListener;
    private MissedCallCountListener missedCallCountListener;


    private Event(String event, String email, String userId, String clientServerToken,
                  String message, String displayName, String profileImage,
                  int requestCode, Bundle conversationInfo, Context context,
                  Fragment fragment, Locale locale, Context applicationContext, RemoteMessage remoteMessage,
                  UnreadMessageCountListener unreadMessageCountListener,
                  MissedCallCountListener missedCallCountListener) {
        this.event = event;
        this.email = email;
        this.userId = userId;
        this.clientServerToken = clientServerToken;
        this.message = message;
        this.displayName = displayName;
        this.profileImage = profileImage;
        this.requestCode = requestCode;
        this.conversationInfo = conversationInfo;
        this.activityContext = context;
        this.fragment = fragment;
        this.locale = locale;
        this.applicationContext = applicationContext;
        this.remoteMessage = remoteMessage;
        this.unreadMessageCountListener = unreadMessageCountListener;
        this.missedCallCountListener = missedCallCountListener;
    }

    public String getEvent() {
        return event;
    }

    public String getEmail() {
        return email;
    }

    public String getUserId() {
        return userId;
    }

    public String getClientServerToken() {
        return clientServerToken;
    }

    public String getMessage() {
        return message;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getProfileImage() {
        return profileImage;
    }

    public int getRequestCode() {
        return requestCode;
    }

    public Bundle getConversationInfo() {
        return conversationInfo;
    }

    public Context getActivityContext() {
        return activityContext;
    }

    public Fragment getFragment() {
        return fragment;
    }

    public Locale getLocale() {
        return locale;
    }

    public Context getApplicationContext() {
        return applicationContext;
    }

    public RemoteMessage getRemoteMessage() {
        return remoteMessage;
    }

    public UnreadMessageCountListener getUnreadMessageCountListener() {
        return unreadMessageCountListener;
    }

    public MissedCallCountListener getMissedCallCountListener() {
        return missedCallCountListener;
    }

    /**
     * Builder for creating {@link Event} instances.
     */
    public static class Builder {
        private volatile String event;
        private volatile String email;
        private volatile String userId;
        private volatile String clientServerToken;
        private volatile String message;
        private volatile String displayName;
        private volatile String profileImage;
        private volatile int requestCode;
        private volatile Bundle conversationInfo;
        private volatile Context activityContext;
        private volatile Fragment fragment;
        private volatile Locale locale;
        private volatile Context applicationContext;
        private volatile RemoteMessage remoteMessage;
        private volatile UnreadMessageCountListener unreadMessageCountListener;
        private volatile MissedCallCountListener missedCallCountListener;

        /**
         * Start building a new {@link Event} instance.
         */
        public Builder() {
        }

        /**
         * Method to set the event type.
         *
         * @param event Must be one of @EVENT.
         * @return Returns the Builder instance.
         */
        public Builder setEvent(@EVENT String event) {
            this.event = event;
            return this;
        }

        /**
         * Method to login into channelize.
         *
         * @param email Email id of the user.
         * @return Returns the Builder instance.
         */
        public Builder login(String email) {
            this.email = email;
            return this;
        }

        /**
         * Method to login into channelize.
         *
         * @param userId            UserId of the user.
         * @param clientServerToken Client-Server token to login into Channelize.
         * @return Returns the Builder instance.
         */
        public Builder login(String userId, String clientServerToken) {
            this.userId = userId;
            this.clientServerToken = clientServerToken;
            return this;
        }

        /**
         * Method to send a message to user.
         *
         * @param userId  User id of the receiver.
         * @param message Message which needs to be send to the user.
         * @return Returns the Builder instance.
         */
        public Builder sendMessage(String userId, String message) {
            this.userId = userId;
            this.message = message;
            return this;
        }

        /**
         * Method to share content in channelize.
         *
         * @param context Context of calling Activity/Fragment.
         * @param message Message which needs to be share.
         * @return Returns the Builder instance.
         */
        public Builder shareContent(Context context, String message) {
            this.activityContext = context;
            this.message = message;
            return this;
        }

        public Builder openConversation(Context context, int requestCode, String userId, String displayName,
                                        String profileImage, Fragment fragment) {
            this.activityContext = context;
            this.requestCode = requestCode;
            this.userId = userId;
            this.displayName = displayName;
            this.profileImage = profileImage;
            this.fragment = fragment;
            return this;
        }

        public Builder openChannelize(Context context, Bundle conversationInfo, int requestCode) {
            this.activityContext = context;
            this.conversationInfo = conversationInfo;
            this.requestCode = requestCode;
            return this;
        }

        public Builder updateAppLanguage(Locale locale) {
            this.locale = locale;
            return this;
        }

        public Builder processPushNotification(Context applicationContext, RemoteMessage remoteMessage) {
            this.applicationContext = applicationContext;
            this.remoteMessage = remoteMessage;
            return this;
        }

        public Builder setUnreadMessageCountListener(UnreadMessageCountListener unreadMessageCountListener) {
            this.unreadMessageCountListener = unreadMessageCountListener;
            return this;
        }

        public Builder setMissedCallCountListener(MissedCallCountListener missedCallCountListener) {
            this.missedCallCountListener = missedCallCountListener;
            return this;
        }

        /**
         * Build the {@link Event} instance
         */
        public Event build() {
            return new Event(event, email, userId, clientServerToken, message, displayName, profileImage,
                    requestCode, conversationInfo, activityContext, fragment, locale, applicationContext, remoteMessage,
                    unreadMessageCountListener, missedCallCountListener);
        }
    }


    @Retention(SOURCE)
    @StringDef({EVENT_LOGIN, EVENT_LOGOUT, EVENT_OPEN_CHANNELIZE, EVENT_OPEN_CONVERSATION,
            EVENT_SEND_MESSAGE, EVENT_SHARE_CONTENT, EVENT_UPDATE_LANGUAGE,
            EVENT_CACHE_EXPIRY_TIME, EVENT_FIND_MESSAGE_COUNT, EVENT_FIND_MISSED_CALL_COUNT,
            EVENT_LOGIN_SUCCESS, EVENT_LOGIN_ERROR, EVENT_SEND_MESSAGE_SUCCESS,
            EVENT_SEND_MESSAGE_ERROR, EVENT_PROCESS_FCM_NOTIFICATION, EVENT_CLEAR_FCM_NOTIFICATION})
    public @interface EVENT {
    }

    public static final String EVENT_LOGIN = "event_login";
    public static final String EVENT_LOGOUT = "event_logout";
    public static final String EVENT_OPEN_CHANNELIZE = "event_open_channelize";
    public static final String EVENT_OPEN_CONVERSATION = "event_open_conversation";
    public static final String EVENT_SEND_MESSAGE = "event_send_message";
    public static final String EVENT_SHARE_CONTENT = "event_share_content";
    public static final String EVENT_UPDATE_LANGUAGE = "event_update_language";
    public static final String EVENT_CACHE_EXPIRY_TIME = "event_cache_expiry_time";
    public static final String EVENT_FIND_MESSAGE_COUNT = "event_find_message_count";
    public static final String EVENT_FIND_MISSED_CALL_COUNT = "event_missed_call_count";
    public static final String EVENT_PROCESS_FCM_NOTIFICATION = "event_process_fcm_notifications";
    public static final String EVENT_CLEAR_FCM_NOTIFICATION = "event_clear_fcm_notifications";

    // call backs event
    public static final String EVENT_LOGIN_SUCCESS = "event_login_success";
    public static final String EVENT_LOGIN_ERROR = "event_login_error";
    public static final String EVENT_SEND_MESSAGE_SUCCESS = "event_send_message_success";
    public static final String EVENT_SEND_MESSAGE_ERROR = "event_send_message_error";
}
