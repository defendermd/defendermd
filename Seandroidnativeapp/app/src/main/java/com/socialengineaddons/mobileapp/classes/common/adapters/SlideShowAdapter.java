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

package com.socialengineaddons.mobileapp.classes.common.adapters;

import android.content.Context;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.PagerAdapter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.utils.SlideShowListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;

import java.util.List;


public class SlideShowAdapter extends PagerAdapter {
    List<SlideShowListItems> mSlideShowList;
    LayoutInflater inflater;
    View mRootView;
    private OnItemClickListener mOnItemClickListener;
    private SlideShowListItems listItems;
    private int mLayoutResID;
    Context mContext;
    private ImageLoader mImageLoader;


    public SlideShowAdapter(Context context, int layoutResourceID, List<SlideShowListItems> slideShowList,
                            OnItemClickListener onItemClickListener) {
        this.mContext = context;
        this.mLayoutResID = layoutResourceID;
        this.mSlideShowList = slideShowList;
        mOnItemClickListener = onItemClickListener;
        mImageLoader = new ImageLoader(mContext);
    }

    public int getItemPosition(Object object) {
        return POSITION_NONE;
    }


    @Override
    public int getCount() {
        return mSlideShowList.size();
    }


    @Override
    public boolean isViewFromObject(View view, Object object) {
        return view == object;
    }


    @Override
    public Object instantiateItem(ViewGroup container, final int position) {

        // Initialize view
        final ListItemHolder listItemHolder = new ListItemHolder();
        inflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        mRootView = inflater.inflate(mLayoutResID, container, false);

        listItemHolder.mListImage = mRootView.findViewById(R.id.contentImage);
        listItemHolder.mContentTitle = mRootView.findViewById(R.id.title);
        listItemHolder.tvFeatured = mRootView.findViewById(R.id.featuredLabel);
        float mRadius = mContext.getResources().getDimensionPixelOffset(R.dimen.dimen_5dp);
        GradientDrawable drawable=new GradientDrawable();
        drawable.setShape(GradientDrawable.RECTANGLE);
        drawable.setCornerRadii(new float[]{0, 0, mRadius, mRadius, mRadius, mRadius, 0, 0});
        drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.featured_label),
                PorterDuff.Mode.SRC_ATOP));
        listItemHolder.tvFeatured.setBackground(drawable);
        Drawable imageDrawable = ContextCompat.getDrawable(mContext, R.drawable.rounded_corner_grey).mutate();
        imageDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.white),
                PorterDuff.Mode.SRC_ATOP));
        listItemHolder.mListImage.setBackground(imageDrawable);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            listItemHolder.mListImage.setClipToOutline(true);
        }
        mRootView.findViewById(R.id.featuredLabel).setVisibility(View.VISIBLE);

        mRootView.setTag(listItemHolder);
        listItems = this.mSlideShowList.get(position);

        //Set content in view
        mImageLoader.setImageUrl(listItems.getmBrowseImgUrl(), listItemHolder.mListImage);
        listItemHolder.mContentTitle.setText(listItems.getmBrowseListTitle());

        mRootView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mOnItemClickListener.onItemClick(view, position);
            }
        });

        container.addView(mRootView);
        return mRootView;
    }


    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        container.removeView((View) object);
    }

    private static class ListItemHolder {

        ImageView mListImage;
        TextView mContentTitle, tvFeatured;
    }
}
