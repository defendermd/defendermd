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

package com.socialengineaddons.mobileapp.classes.modules.channelize;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.TextUtils;

import com.channelize.apisdk.Channelize;
import com.channelize.apisdk.ChannelizeConfig;
import com.channelize.apisdk.model.User;
import com.channelize.apisdk.network.api.ChannelizeApi;
import com.channelize.apisdk.network.api.ChannelizeApiClient;
import com.channelize.apisdk.network.response.ChannelizeError;
import com.channelize.apisdk.network.response.CompletionHandler;
import com.channelize.apisdk.network.response.TotalCountResponse;
import com.channelize.apisdk.network.services.ApiService;
import com.channelize.apisdk.utils.ChannelizePreferences;
import com.channelize.apisdk.utils.Logcat;
import com.channelize.uisdk.ChannelizeMainActivity;
import com.channelize.uisdk.ChannelizeUI;
import com.channelize.uisdk.ChannelizeUIConfig;
import com.channelize.uisdk.Constants;
import com.channelize.uisdk.conversation.ConversationUtils;
import com.channelize.uisdk.utils.ChannelizeUtils;
import com.channelize.uisdk.utils.GlobalFunctionsUtil;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.iid.FirebaseInstanceId;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.AppController;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.messagingMiddleware.Event;
import com.socialengineaddons.mobileapp.classes.modules.messagingMiddleware.EventBus;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import java.io.IOException;
import java.util.Locale;
import java.util.Map;

import io.reactivex.disposables.Disposable;

import static com.channelize.apisdk.Channelize.connect;


/**
 * All the public static method should remain public static
 * as these methods will be called by the package name.
 */
public class ChannelizeMediatorUtils {

    private static final long CACHE_EXPIRY_TIME = 15;
    @SuppressLint("StaticFieldLeak")
    private static FirebaseApp channelizeApp;
    private static Disposable disposable;


    //============================================================
    //                      Package invoked methods             //
    //============================================================


    /**
     * Method to initialize the channelize. Will be calling from the package name.
     *
     * @param params Bundle Params.
     */
    public static Intent initializeChannelize(Bundle params) {

        LogUtils.LOGD(ChannelizeMediatorUtils.class.getSimpleName(), "initializeChannelize method invoked");
        Logcat.d(ChannelizeMediatorUtils.class.getSimpleName(), "initializeChannelize method invoked");
        setEventBusHandler();
        Context context = AppController.getInstance().getApplicationContext();
        ChannelizeConfig channelizeConfig = new ChannelizeConfig.Builder(context)
                .setAPIKey(ConstantVariables.API_KEY)
                .setLoggingEnabled(true)
                .build();
        Channelize.initialize(channelizeConfig);
        Channelize.getInstance().setCurrentUserId(ChannelizePreferences.getCurrentUserId(context));
        connect();

        ChannelizeUIConfig channelizeUIConfig = new ChannelizeUIConfig.Builder()
                .enableCall(true)
                .build();
        ChannelizeUI.initialize(channelizeUIConfig);
        ChannelizeUtils.getInstance().enableFirstTimeAppLaunch();
        if (Channelize.getInstance().getCurrentUserId() != null
                && !Channelize.getInstance().getCurrentUserId().isEmpty()) {
        }

        setUserProfileRedirectListener();
        setOnConversationClickListener();
        setPushNotificationClearListener();
        setFirebaseToken();

        /*
         ForceLogout
         */
        if (PreferencesUtils.getUserPreferences(context).getString("oauth_token", null) != null
                && PreferencesUtils.getUserPreferences(context).getString("oauth_secret", null) != null
                && (ChannelizePreferences.getAccessToken(context) == null)
                || ChannelizePreferences.getAccessToken(context).isEmpty()) {
            AppConstant appConstant = new AppConstant(AppController.getInstance().getApplicationContext());
            appConstant.eraseUserDatabase();
        }

        return new Intent();
    }

    /**
     * Method to check that channelize is active or not. Will be calling from the package name.
     *
     * @param params Bundle Params.
     */
    public static Intent checkChannelize(Bundle params) {
        LogUtils.LOGD(ChannelizeMediatorUtils.class.getSimpleName(), "checkChannelize method invoked");
        Logcat.d(ChannelizeMediatorUtils.class.getSimpleName(), "checkChannelize method invoked");
        setEventBusHandler();
        return new Intent();
    }

    /**
     * Method to get the missed call count from preferences.
     * Will be calling from the package name.
     *
     * @param bundle Bundle Params.
     * @return Returns the missed call count.
     */
    public static int getMissedCallCount(Bundle bundle) {
        Object object = GlobalFunctionsUtil.invokeMethod(Constants.CALL_SDK_PATH,
                Constants.GET_MISSED_CALL_COUNT, bundle);
        // Null check added, when the channelize video-voice is not present then the object will be null.
        if (object != null && object instanceof Integer) {
            return (int) object;
        }
        return 0;
    }


    //============================================================
    //                      Class invoked methods               //
    //============================================================


    /**
     * Method to launch the Channelize.
     *
     * @param context          Context of calling Activity/Fragment.
     * @param conversationInfo Bundle which contains the info that need to be passed to the SDK.
     * @param requestCode      RequestCode to launch the Channelize.
     */
    private static void launchChannelize(Context context, Bundle conversationInfo, int requestCode) {
        Logcat.d(ChannelizeMediatorUtils.class.getSimpleName(), "launchChannelize, requestCode: " + requestCode + ", conversationInfo : " + conversationInfo);
        Intent intent = new Intent(Channelize.getInstance().getContext(), ChannelizeMainActivity.class);
        if (conversationInfo != null) {
            conversationInfo = ChannelizeUtils.getInstance().getPushNotificationData(conversationInfo);
            intent.putExtras(conversationInfo);
        }

        if (requestCode != 0 && context != null) {
            ((Activity) context).startActivityForResult(intent, requestCode);
        } else {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            Channelize.getInstance().getContext().startActivity(intent);
        }
    }

    /**
     * Method to set the event handler when the Channelize sdk has been initialized.
     */
    private static void setEventBusHandler() {
        if (disposable != null) {
            return;
        }
        disposable = EventBus.getInstance().getEvents().subscribe(event -> {
            Logcat.d(ChannelizeMediatorUtils.class.getSimpleName(), "ChannelizeMediatorUtils accept Event : " + event.getEvent());
            switch (event.getEvent()) {
                case Event.EVENT_LOGIN:
                    loginIntoChannelize(event.getUserId(), event.getClientServerToken());
                    break;

                case Event.EVENT_LOGOUT:
                    logoutUser();
                    break;

                case Event.EVENT_OPEN_CHANNELIZE:
                    launchChannelize(event.getActivityContext(),
                            event.getConversationInfo(), event.getRequestCode());
                    break;

                case Event.EVENT_UPDATE_LANGUAGE:
                    updateAppLanguage(event.getLocale());
                    break;

                case Event.EVENT_SEND_MESSAGE:
                    sendMessageToUser(event.getUserId(), event.getMessage());
                    break;

                case Event.EVENT_SHARE_CONTENT:
                    shareContentInChannelize(event.getActivityContext(), event.getMessage());
                    break;

                case Event.EVENT_OPEN_CONVERSATION:
                    openTwoUsersConversation(event.getActivityContext(), event.getRequestCode(), event.getUserId(),
                            event.getDisplayName(), event.getProfileImage(), event.getFragment());
                    break;

                case Event.EVENT_CACHE_EXPIRY_TIME:
                    ChannelizeUtils channelizeUtils = ChannelizeUtils.getInstance();
                    if (channelizeUtils.getDateDiff() == CACHE_EXPIRY_TIME
                            || channelizeUtils.getDateDiff() == -1) {
                        ChannelizeUtils.getInstance().clearLastCache();
                    }
                    break;

                case Event.EVENT_FIND_MESSAGE_COUNT:
                    fetchUnreadMessageCount(event);
                    break;

                case Event.EVENT_FIND_MISSED_CALL_COUNT:
                    fetchMissedCallCount(event);
                    break;

                case Event.EVENT_PROCESS_FCM_NOTIFICATION: {
                    Map data = event.getRemoteMessage().getData();
                    boolean isChannelizeNotification = data.containsKey("messageType") && data.get("messageType").equals("primemessenger");

                    boolean isCallTypeNotifications = data.containsKey("type") && data.get("type") != null
                            && (data.get("type").toString().equalsIgnoreCase("voice")
                            || data.get("type").toString().equalsIgnoreCase("video")
                            || data.get("type").toString().equalsIgnoreCase("call"));


                    if (isChannelizeNotification) {
                        ChannelizeUI.getInstance().processPushNotification(event.getApplicationContext(), event.getRemoteMessage());
                    } else if (isCallTypeNotifications) {
                        ChannelizeUI.getInstance().processChannelizeCallNotification(event.getApplicationContext(), event.getRemoteMessage());
                        //ChannelizeCall.getInstance().handleCallNotifications(remoteMessage.getData(), getApplicationContext());
                    }
                }
                /*ChannelizeUI.getInstance().processPushNotification(event.getApplicationContext(),
                        event.getRemoteMessage());*/

                break;

                case Event.EVENT_CLEAR_FCM_NOTIFICATION:
                    ChannelizeUI.getInstance().clearPushNotifications(Channelize.getInstance().getContext());
                    break;
            }

        }, throwable -> {
            Logcat.d(ChannelizeMediatorUtils.class.getSimpleName(), "ChannelizeMediatorUtils throwable : " + throwable);
        });
    }

    /**
     * Method to login into Channelize with UserId and Client-Server token.
     *
     * @param userId      UserId of the user.
     * @param accessToken AccessToken token of Channelize.
     */
    private static void loginIntoChannelize(String userId, String accessToken) {
        if (!isLoggedInUser()) {
            ChannelizePreferences.setCurrentUserId(Channelize.getInstance().getContext(), userId);
            Channelize.getInstance().setCurrentUserId(userId);
            ChannelizePreferences.setAccessToken(Channelize.getInstance().getContext(), accessToken);
            Channelize.getInstance().addAuthHeader();
            connect();
            passEvent(Event.EVENT_LOGIN_SUCCESS);
            setFirebaseToken();

            ChannelizeApi channelizeApi = new ChannelizeApiClient(Channelize.getInstance().getContext());
            channelizeApi.getUser(userId, (user, error) -> {
                if (user != null) {
                    ChannelizePreferences.setChannelizeCurrentUser(Channelize.getInstance().getContext(), user);
                    ChannelizePreferences.setCurrentUserProfileImage(Channelize.getInstance().getContext(), user.getProfileImageUrl());
                }
            });
        }
    }

    private static FirebaseApp getChannelizeFirebaseApp() {
        if (channelizeApp == null) {
            FirebaseOptions options = new FirebaseOptions.Builder()
                    .setApplicationId(ConstantVariables.FIREBASE_APPLICATION_ID)
                    .setGcmSenderId(ConstantVariables.FIREBASE_SENDER_ID)
                    .build();
            channelizeApp = FirebaseApp.initializeApp(Channelize.getInstance().getContext(), options, "messenger");
        }
        return channelizeApp;
    }

    private static void setFirebaseToken() {
        getChannelizeFirebaseApp();
        new FirebaseToken(true).execute();
    }

    /**
     * Method to logout from the Channelize app.
     */
    private static void logoutUser() {
        Channelize.logout((requestResponse, channelizeError) -> {
            Logcat.d(ChannelizeMediatorUtils.class, "logoutUser requestResponse: " + requestResponse + ", channelizeError: " + channelizeError);
        });
        new FirebaseToken(false).execute();
    }

    private static boolean isLoggedInUser() {
        return (Channelize.getInstance().getCurrentUserId() != null
                && !Channelize.getInstance().getCurrentUserId().isEmpty());
    }

    /**
     * Method to fetch the unread messages count from api.
     *
     * @param event Event instance that will contains the event info.
     */
    private static void fetchUnreadMessageCount(Event event) {
        if (isLoggedInUser()) {
            ChannelizeApi channelizeApi = new ChannelizeApiClient(Channelize.getInstance().getContext());
            channelizeApi.getTotalUnReadMessageCount((result, error) -> {
                if (result != null && event.getUnreadMessageCountListener() != null) {
                    event.getUnreadMessageCountListener().updateMessageCount(result.getCount());
                }
            });
        }
    }

    /**
     * Method to fetch the missed call count from api.
     *
     * @param event Event instance that will contains the event info.
     */
    private static void fetchMissedCallCount(Event event) {
        if (isLoggedInUser()) {
            ApiService apiService = new ApiService(Channelize.getInstance().getContext());
            apiService.getResponse(Channelize.getInstance().getApiDefaultUrl()
                    + "users/unread_missed_calls/count", null, null, TotalCountResponse.class, new CompletionHandler<TotalCountResponse>() {
                @Override
                public void onComplete(TotalCountResponse result, ChannelizeError error) {
                    if (result != null) {
                        Bundle missedCallBundle = new Bundle();
                        missedCallBundle.putInt(Constants.GET_MISSED_CALL_COUNT, result.getCount());
                        // Setting up the missed call count through the package calling.
                        GlobalFunctionsUtil.invokeMethod(Constants.CALL_SDK_PATH,
                                Constants.SET_MISSED_CALL_COUNT, missedCallBundle);
                        if (event.getMissedCallCountListener() != null) {
                            event.getMissedCallCountListener().updateMissedCallCount(result.getCount());
                        }
                    }
                }
            });
        }
    }

    /**
     * Method to set the listener when user click on view profile option in messenger then
     * open the social engine app.
     */
    private static void setUserProfileRedirectListener() {
        ChannelizeUtils channelizeUtils = ChannelizeUtils.getInstance();
        channelizeUtils.setOnUserProfileListener(userId -> {
            Intent intent = new Intent(Channelize.getInstance().getContext(), userProfile.class);
            intent.putExtra(ConstantVariables.USER_ID, Integer.parseInt(userId));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            Channelize.getInstance().getContext().startActivity(intent);
        });
    }

    /**
     * Method to set the conversation click listener when the user clicked on any conversation
     * then need to check push notification for the corresponding conversation
     * is still showing or not.
     */
    private static void setOnConversationClickListener() {
        ChannelizeUtils channelizeUtils = ChannelizeUtils.getInstance();
        channelizeUtils.setOnConversationClickListener(conversationId -> {
            ChannelizeUI.getInstance().onConversationOpen(Channelize.getInstance().getContext(), conversationId);
        });
    }

    /**
     * Method to set the push notification clear listener in order to clear all the existing push notifications.
     */
    private static void setPushNotificationClearListener() {
        ChannelizeUtils channelizeUtils = ChannelizeUtils.getInstance();
        channelizeUtils.setPushNotificationClearListener(() -> ChannelizeUI.getInstance().clearPushNotifications(Channelize.getInstance().getContext()));
    }

    /**
     * Method to open conversation screen between 2 user.
     *
     * @param activityContext Context of calling Activity/Fragment.
     * @param requestCode     Request code for which conversation screen needs to be launched.
     * @param userId          User id of the user with whom logged-in user wants to chat.
     * @param displayName     Display name of the user with whom logged-in user will chat.
     * @param profileImage    Profile image of the other user.
     */
    private static void openTwoUsersConversation(Context activityContext, int requestCode, String userId,
                                                 String displayName, String profileImage,
                                                 Fragment fragment) {
        User user = new User();
        user.setDisplayName(displayName);
        user.setId(userId);
        user.setProfileColor();
        user.setProfileImageUrl(profileImage);
        ConversationUtils.startConversationActivity(activityContext, true, requestCode, fragment, user);
    }


    /**
     * Method to send a message to user in channelize app.
     *
     * @param userId  User id of the story owner.
     * @param message Message which needs to be send to the user.
     */
    private static void sendMessageToUser(String userId, String message) {
        message = TextUtils.htmlEncode(message);
        ChannelizeUtils.getInstance().sendMessageToUser(userId, message, (responseMessage, error) -> {
            if (error != null) {
                passEvent(Event.EVENT_SEND_MESSAGE_ERROR);
            } else if (responseMessage != null && !responseMessage.isInstantMsg()) {
                passEvent(Event.EVENT_SEND_MESSAGE_SUCCESS);
            }
        });
    }

    /**
     * Method to share content in Channelize.
     *
     * @param activityContext Context of calling Activity/Fragment.
     * @param shareMessage    Content which needs to be shared.
     */
    private static void shareContentInChannelize(Context activityContext, String shareMessage) {
        ChannelizeUtils.getInstance().shareInMessenger(activityContext, shareMessage);
    }

    /**
     * Method to update the Channelize app's language when SocialEngine app's language gets changed.
     *
     * @param locale Locale which needs to set as default in Channelize.
     */
    private static void updateAppLanguage(Locale locale) {
        if (locale != null) {
            ChannelizeUtils.getInstance().updateAppLocale(locale);
        }
    }

    /**
     * Method to pass the event when an operation has been successfully completed.
     *
     * @param eventType Type of the success event.
     */
    private static void passEvent(@Event.EVENT String eventType) {
        Event event = new Event.Builder()
                .setEvent(eventType)
                .build();
        EventBus.getInstance().passEvent(event);
    }

    /**
     * channelInviteAccept
     * Class to get the firebase token and update it to server.
     */
    public static class FirebaseToken extends AsyncTask<Void, Boolean, String> {

        // Member variables.
        private boolean isGenerateToken;

        FirebaseToken(boolean isGenerateToken) {
            this.isGenerateToken = isGenerateToken;
        }

        @Override
        protected String doInBackground(Void... params) {

            try {
                if (isGenerateToken) {
                    return FirebaseInstanceId.getInstance(getChannelizeFirebaseApp()).
                            getToken(ConstantVariables.FIREBASE_SENDER_ID, "FCM");
                } else {
                    ChannelizeUtils.getInstance().clearCache();
                    Channelize.disconnect();
                    FirebaseInstanceId.getInstance(getChannelizeFirebaseApp()).
                            deleteToken(ConstantVariables.FIREBASE_SENDER_ID, "FCM");
                    return null;
                }
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }

        @Override
        protected void onPostExecute(String token) {
            super.onPostExecute(token);
            Logcat.d(ChannelizeMediatorUtils.class, "Firebase Token: " + token);
            Channelize.getInstance().registerFcmToken(token);
        }
    }
}
