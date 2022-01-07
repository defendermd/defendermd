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


package com.socialengineaddons.mobileapp.classes.modules.autoplayvideo;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.BatteryManager;
import android.os.Handler;
import android.preference.PreferenceManager;

import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSourceFactory;
import com.google.android.exoplayer2.util.Util;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;

import java.io.File;

public class Utils {

    private static SharedPreferences sharedPrefs;

    public static void initialize(Context context) {
        sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
    }

    public static String getString(Context context, String key) {
        if (sharedPrefs == null) {
            initialize(context);
        }
        return sharedPrefs.getString(key, null);
    }

    public static void saveString(Context context, String key, String value) {
        if (sharedPrefs == null) {
            initialize(context);
        }
        sharedPrefs.edit().putString(key, value).apply();
    }

    public static void remove(Context context, String key) {
        if (sharedPrefs == null) {
            initialize(context);
        }
        sharedPrefs.edit().remove(key).apply();
    }

    public static boolean isVideoDownloaded(Context c, String url) {
        return getString(c, url) != null;

    }

    /* Build media source to play video on the basis of type */
    public static MediaSource buildMediaSource(Context context, String videoUrl) {

        /* If video is playing from offline storage
         * Else If video format is .m3u8
         * Else any other kind of video */
        if (videoUrl.contains(context.getPackageName())) {
            DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(context,
                    Util.getUserAgent(context, context.getResources().getString(R.string.app_name)));

            return new ExtractorMediaSource.Factory(dataSourceFactory)
                    .createMediaSource(Uri.parse(videoUrl));

        } else if (videoUrl.contains(".m3u8")) {
            DefaultBandwidthMeter defaultBandwidthMeter = new DefaultBandwidthMeter();
            // Produces DataSource instances through which media data is loaded.
            DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(context,
                    Util.getUserAgent(context, context.getResources().getString(R.string.app_name)),
                    defaultBandwidthMeter);

            Handler mainHandler = new Handler();
            return new HlsMediaSource(Uri.parse(videoUrl),
                    dataSourceFactory, mainHandler, null);

        } else {
            return new ExtractorMediaSource.Factory(
                    new DefaultHttpDataSourceFactory("exoplayer-codelab")).
                    createMediaSource(Uri.parse(videoUrl));
        }

    }

    public static int getBatteryPercentage(Context context) {

        IntentFilter iFilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent batteryStatus = context.registerReceiver(null, iFilter);

        int level = batteryStatus != null ? batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) : -1;
        int scale = batteryStatus != null ? batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1) : -1;

        float batteryPct = level / (float) scale;

        return (int) (batteryPct * 100);
    }

    /* Check when we need to play videos auto in feeds */
    public static boolean isAutoPlayVideos(Context context) {
        if (Utils.getBatteryPercentage(context) > 20) {
            switch (PreferencesUtils.getVideoAutoPlaySetting(context)) {
                case "both":
                    if (Connectivity.isConnectedWifi(context)
                            || Connectivity.isConnectedMobile(context)) {
                        return true;
                    }
                    break;
                case "only_wifi":
                    if (Connectivity.isConnectedWifi(context)) {
                        return true;
                    }
                    break;
                default:
                    return false;
            }
        }
        return  false;
    }


    /* Calculate folder size */
    public static long getFileFolderSize(File dir) {
        long size = 0;
        if (dir.isDirectory()) {
            for (File file : dir.listFiles()) {
                if (file.isFile()) {
                    size += file.length();
                } else
                    size += getFileFolderSize(file);
            }
        } else if (dir.isFile()) {
            size += dir.length();
        }
        return size;
    }

}
