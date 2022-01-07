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

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.ImageView;


public class VideoImage extends FrameLayout {
    private CustomExoVideoView customExoVideoView;
    private ImageView iv;

    public VideoImage(Context context) {
        super(context);
        init();
    }

    public VideoImage(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public VideoImage(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public VideoImage(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    public CustomExoVideoView getCustomExoVideoView() {
        return customExoVideoView;
    }

    public ImageView getImageView() {
        return iv;
    }


    private void init() {
        this.setTag("viAutoPlay");
        customExoVideoView = new CustomExoVideoView(getContext());
        iv = new ImageView(getContext());
        this.addView(customExoVideoView);
        this.addView(iv);
    }
}
