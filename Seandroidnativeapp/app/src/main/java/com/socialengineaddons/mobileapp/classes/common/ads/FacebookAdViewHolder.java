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

package com.socialengineaddons.mobileapp.classes.common.ads;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.facebook.ads.AdOptionsView;
import com.facebook.ads.MediaView;
import com.facebook.ads.NativeAd;
import com.facebook.ads.NativeAdLayout;
import com.socialengineaddons.mobileapp.R;

import java.util.ArrayList;
import java.util.List;

public class FacebookAdViewHolder extends RecyclerView.ViewHolder {
    public NativeAd mNativeAd;
    public View adView;

    public FacebookAdViewHolder(View itemView) {
        super(itemView);
        adView = itemView;
    }


    public static void inflateAd(NativeAd nativeAd, View adView, Context context, boolean isVideoModule) {

        List<View> viewList = new ArrayList<>();

        // Create native UI using the ad metadata.
        TextView nativeAdTitle = adView.findViewById(R.id.native_ad_title);
        nativeAdTitle.setText(nativeAd.getAdvertiserName());

        TextView nativeAdSubtitle = adView.findViewById(R.id.native_ad_sponsored_label);
        if (nativeAdSubtitle != null) {
            nativeAdSubtitle.setText(nativeAd.getSponsoredTranslation());
            nativeAdSubtitle.setVisibility(View.VISIBLE);
        }


        TextView nativeAdBody = adView.findViewById(R.id.native_ad_body);
        nativeAdBody.setText(nativeAd.getAdBodyText());

        TextView nativeAdSocialContext = adView.findViewById(R.id.native_ad_social_context);
        if (nativeAdSocialContext!= null) {
            nativeAdSocialContext.setText(nativeAd.getAdSocialContext());
        }


        Button nativeAdCallToAction = adView.findViewById(R.id.native_ad_call_to_action);
        if(nativeAdCallToAction != null) {
            nativeAdCallToAction = adView.findViewById(R.id.native_ad_call_to_action);
            nativeAdCallToAction.setText(nativeAd.getAdCallToAction());
            nativeAdCallToAction.setVisibility(View.VISIBLE);
            viewList.add(nativeAdCallToAction);
        }

        MediaView nativeAdIconView = adView.findViewById(R.id.native_icon_view);
        if (nativeAdIconView != null) {
            viewList.add(nativeAdIconView);
        }

        ImageView nativeAdIcon = adView.findViewById(R.id.native_ad_icon);
        if(nativeAdIcon != null ) {
            nativeAdIcon.setVisibility(View.VISIBLE);
            viewList.add(nativeAdIcon);
        }

        // Setting the ad choice options.
        LinearLayout adChoicesContainer = adView.findViewById(R.id.ad_choices_container);
        if(adChoicesContainer != null ) {
            adChoicesContainer.setVisibility(View.VISIBLE);
            NativeAdLayout adLayout = adView.findViewById(R.id.native_ad_layout);
            AdOptionsView adOptionsView = new AdOptionsView(context, nativeAd, adLayout);
            adChoicesContainer.removeAllViews();
            adChoicesContainer.addView(adOptionsView, 0);
        }

        // Downloading and setting the cover image.
        NativeAd.Image adCoverImage = nativeAd.getAdCoverImage();
        int bannerWidth = adCoverImage.getWidth();
        int bannerHeight = adCoverImage.getHeight();

        MediaView nativeAdMedia = adView.findViewById(R.id.native_ad_media);

        if(nativeAdMedia != null) {
            nativeAdMedia = adView.findViewById(R.id.native_ad_media);
//            nativeAdMedia.setAutoplay(AdSettings.isVideoAutoplay());
            nativeAdMedia.setSoundEffectsEnabled(true);
            DisplayMetrics metrics = context.getResources().getDisplayMetrics();
            int mediaWidth = adView.getWidth() > 0 ? adView.getWidth() : metrics.widthPixels;
            nativeAdMedia.setLayoutParams(new LinearLayout.LayoutParams(
                    mediaWidth,
                    Math.min(
                            (int) (((double) mediaWidth / (double) bannerWidth) * bannerHeight),
                            metrics.heightPixels / 3)));
            viewList.add(nativeAdMedia);
        }

        // Wire up the View with the native ad, the whole nativeAdContainer will be clickable.
        if (nativeAdIconView != null) {
            nativeAd.registerViewForInteraction(
                    adView,
                    nativeAdIconView,
                    viewList);
        } else {
            nativeAd.registerViewForInteraction(
                    adView,
                    nativeAdMedia,
                    nativeAdIcon,
                    viewList);
        }
        adView.setClickable(true);
        adView.setFocusable(true);
    }

}
