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

package com.socialengineaddons.mobileapp.classes.modules.liveStreaming.listener;

public interface OnAgoraSignalingInterface {

    void onMessageChannelReceive(String channelName, String account, int uid, String msg);
}