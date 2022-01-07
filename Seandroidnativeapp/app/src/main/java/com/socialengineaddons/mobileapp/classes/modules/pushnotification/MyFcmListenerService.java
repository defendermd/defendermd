/*
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
package com.socialengineaddons.mobileapp.classes.modules.pushnotification;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.media.RingtoneManager;
import android.support.v4.app.NotificationCompat;
import android.support.v4.content.ContextCompat;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.utils.BitmapUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.core.MainActivity;
import com.socialengineaddons.mobileapp.classes.modules.messagingMiddleware.MessageCoreUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;


import me.leolin.shortcutbadger.ShortcutBadger;


public class MyFcmListenerService extends FirebaseMessagingService {
    public static int counter = 1;
    private String message;
    private JSONObject jsonObject, objectParamsJsonObject;
    int id, listingTypeId, albumId, senderId;
    private String type, imageUrl, title, viewUrl, sound;
    public static NotificationManager notificationManager;
    public static Map<Integer, String> map = new TreeMap<>(Collections.reverseOrder());
    NotificationCompat.InboxStyle inboxStyle;
    private String channelName, videoType;
    private int videoId;


    /**
     * Called when fcm token is refreshed
     */
    @Override
    public void onNewToken(String token) {
        registerRefreshedToken(token);
        super.onNewToken(token);
    }

    /**
     * Called when message is received.
     */
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        String from = remoteMessage.getFrom();
        Map data = remoteMessage.getData();

        RemoteMessage.Notification notification = remoteMessage.getNotification();
        LogUtils.LOGD(MyFcmListenerService.class.getSimpleName(), "data: " + data);

        if (notification == null) {
            String bundleMessage = (String) data.get("message");
            title = (String) data.get("title");
            imageUrl = (String) data.get("imgUrl");
            viewUrl = (String) data.get("href");
            sound = (String) data.get("sound");
            try {
                jsonObject = new JSONObject(bundleMessage);
                message = jsonObject.optString("feed_title");
                objectParamsJsonObject = jsonObject.optJSONObject("object_params");
                id = objectParamsJsonObject.getInt("id");
                type = objectParamsJsonObject.getString("type");
                senderId = objectParamsJsonObject.optInt("sender_id");
                if (type != null && !type.isEmpty()) {
                    switch (type) {
                        case "sitereview_listing":
                        case "sitereview_review":
                            listingTypeId = objectParamsJsonObject.optInt("listingtype_id");
                            break;
                        case "activity_comment":
                            id = objectParamsJsonObject.optInt("resource_id");
                            break;
                        case "video":
                            if (objectParamsJsonObject.has("stream_name")) {
                                channelName = objectParamsJsonObject.optString("stream_name");
                                videoType = objectParamsJsonObject.optString("main_subject_type");
                                videoId = objectParamsJsonObject.optInt("main_subject_id");
                                type = ConstantVariables.LIVE_STREAM_TYPE;
                            }
                            break;
                    }
                }
            } catch (JSONException | NullPointerException e) {
                jsonObject = null;
                e.printStackTrace();
            }

            if (jsonObject == null) {
                message = bundleMessage;
            }
            updateBadgeCount();
            generateCustomNotification(getApplicationContext(), message, title);

        } else {

        } /*else {
            MessageCoreUtils.processPushNotification(getApplicationContext(), remoteMessage);
        }*/

        if(data !=null){
            MessageCoreUtils.processPushNotification(getApplicationContext(), remoteMessage);
        }
    }

    /**
     * Create and show a simple notification containing the received FCM message and title.
     *
     * @param context Context of application.
     * @param message FCM message received.
     * @param title   Title of FCM notification in case of single notification.
     */
    private void generateCustomNotification(Context context, String message, String title) {
        try {
            Intent broadCastInent = new Intent();
            broadCastInent.setAction(ConstantVariables.ACTION_COUNTER_UPDATE);
            context.sendBroadcast(broadCastInent);

            notificationManager = (NotificationManager)
                    context.getSystemService(Context.NOTIFICATION_SERVICE);
            int icon = R.drawable.push_noti_icon;
            long when = System.currentTimeMillis();
            Bitmap bitmapLargeIcon;
            bitmapLargeIcon = BitmapUtils.getBitmapFromURL(imageUrl);

            if (counter == 1) {
                inboxStyle = new NotificationCompat.InboxStyle();
            }

            inboxStyle.addLine(message);

            String summaryText = getApplicationContext().getResources().
                    getQuantityString(R.plurals.notification_count,
                            counter);
            inboxStyle.setSummaryText(String.format(getApplicationContext().getResources().getString
                    (R.string.total_push_notification), counter, summaryText));
            Intent notificationIntent = new Intent(context, MainActivity.class);
            notificationIntent.putExtra("id", id);
            notificationIntent.putExtra("type", (type != null ? type : ""));
            notificationIntent.putExtra(ConstantVariables.LISTING_TYPE_ID, listingTypeId);
            notificationIntent.putExtra(ConstantVariables.ALBUM_ID, albumId);
            notificationIntent.putExtra("notification_view_url", (viewUrl != null ? viewUrl : ""));
            notificationIntent.putExtra("headerTitle", title);
            notificationIntent.putExtra("is_single_notification", counter);
            notificationIntent.putExtra("message", message);
            notificationIntent.putExtra("sender_id", senderId);
            notificationIntent.putExtra("objectParams", (objectParamsJsonObject != null ? objectParamsJsonObject.toString() : ""));
            notificationIntent.putExtra(ConstantVariables.CHANNEL_NAME, channelName);
            notificationIntent.putExtra(ConstantVariables.SUBJECT_ID, videoId);
            notificationIntent.putExtra(ConstantVariables.SUBJECT_TYPE, videoType);

            notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION
                    | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            PendingIntent intent = PendingIntent.getActivity(context, 0 /* Request code */,
                    notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

            String CHANNEL_ID = "default_channel_" + id;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {

                int importance = NotificationManager.IMPORTANCE_HIGH;
                NotificationChannel mChannel = new NotificationChannel(CHANNEL_ID, "default_channel", importance);
                mChannel.enableLights(true);
                mChannel.setLightColor(ContextCompat.getColor(MyFcmListenerService.this, R.color.themeButtonColor));
                mChannel.enableVibration(true);
                mChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
                mChannel.setShowBadge(true);

                if (notificationManager != null) {
                    notificationManager.createNotificationChannel(mChannel);
                }
            }

            NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, CHANNEL_ID)
                    .setWhen(when)
                    .setContentTitle(title)
                    .setContentText(message)
                    .setColor(ContextCompat.getColor(this, R.color.themeButtonColor))
                    .setSmallIcon(icon)
                    .setSound(sound.equals("1") ? RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION) : null)
                    .setLargeIcon(bitmapLargeIcon)
                    .setContentIntent(intent)
                    .setPriority(Notification.PRIORITY_HIGH)
                    .setDefaults(Notification.DEFAULT_VIBRATE | Notification.DEFAULT_LIGHTS)
                    .setLights(ContextCompat.getColor(MyFcmListenerService.this, R.color.themeButtonColor), 3000, 1000)
                    .setStyle(counter > 1 ? inboxStyle : null);
            if (counter > 1) {
                notificationManager.cancelAll();
            }
            notificationManager.notify(id, mBuilder.build());
            counter++;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Method to clear push notification when clicking on it.
     */
    public static void clearPushNotification() {
        if (notificationManager != null && map != null) {
            notificationManager.cancelAll();
            map.clear();
            counter = 1;
        }
    }

    /**
     * Method to clear messenger's push notification when clicking on it.
     */
    public static void clearMessengerPushNotification() {
        MessageCoreUtils.clearPushNotification();
    }

    /*
     * Method to Update FCM token on server when the token is refreshed.
     *
     * @param token Updated FCM token.
     */
    public void registerRefreshedToken(final String token) {
        //TODO, NEED TO OPTIMIZE THE CONTEXT CONCEPT
        AppConstant appConst = new AppConstant(MyFcmListenerService.this, false);
        if (!appConst.isLoggedOutUser() && PreferencesUtils.getUserDetail(getApplicationContext()) != null) {
            Map<String, String> postParams = new HashMap<>();
            try {
                JSONObject userDetail = new JSONObject(PreferencesUtils.getUserDetail(getApplicationContext()));
                postParams.put("user_id", userDetail.optString("user_id"));
                postParams.put("registration_id", token);
                postParams.put("device_uuid", appConst.getDeviceUUID());
                appConst.postJsonRequest(UrlUtil.UPDATE_FCM_TOKEN_URL, postParams);

            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    /* Update badge count on app icon when any push notification is arrived
     */
    private void updateBadgeCount() {
        int badgeCount = counter;
        String notificationCount = PreferencesUtils.getNotificationsCounts(MyFcmListenerService.this, PreferencesUtils.NOTIFICATION_COUNT);
        if (notificationCount != null && !notificationCount.equals("0")) {
            badgeCount = counter + Integer.parseInt(notificationCount);
        }
        ShortcutBadger.applyCount(MyFcmListenerService.this, badgeCount);
    }
}
