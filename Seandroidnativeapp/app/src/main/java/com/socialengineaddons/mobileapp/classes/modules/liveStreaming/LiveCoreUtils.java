/*
 *   Copyright (c) 2018 BigStep Technologies Private Limited.
 *
 *   You may not use this file except in compliance with the
 *   SocialEngineAddOns License Agreement.
 *   You may obtain a copy of the License at:
 *   https://www.socialengineaddons.com/android-app-license
 *   The full copyright and license information is also mentioned
 *   in the LICENSE file that was distributed with this
 *   source code.
 */

package com.socialengineaddons.mobileapp.classes.modules.liveStreaming;

import android.content.Intent;
import android.os.Bundle;

import com.socialengineaddons.mobileapp.classes.core.AppController;

public class LiveCoreUtils {

    public static Intent getLivePreviewIntent(Bundle params) {
        Intent intent = new Intent(AppController.getInstance().getApplicationContext(),
                LivePreviewActivity.class);
        intent.putExtras(params);
        return intent;
    }

    public static Intent getLiveStreamIntent(Bundle params) {
        Intent intent = new Intent(AppController.getInstance().getApplicationContext(),
                LiveRoomActivity.class);
        intent.putExtras(params);
        return intent;
    }

    public static Intent onAppClosed(Bundle params) {
        LiveStreamUtils liveStreamUtils = LiveStreamUtils.getInstance();
        liveStreamUtils.onAppClosed();
        return getLivePreviewIntent(params);
    }
}
