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

import android.app.Activity;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.viewholder.ProgressViewHolder;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;

import java.util.List;
import java.util.Random;


public class StaggeredGridAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private Activity mActivity;
    private List<PhotoListDetails> mPhotoListDetail;
    private PhotoListDetails mPhotoList;
    private ImageLoader mImageLoader;
    private boolean mIsPhotosTab;
    private AppConstant mAppConst;
    private OnItemClickListener mOnItemClickListener;
    private static final int TYPE_ITEM = 0, TYPE_PROGRESS = 1;


    public StaggeredGridAdapter(Activity activity, List<PhotoListDetails> photoList, boolean isPhotosTab,
                                OnItemClickListener onItemClickListener){
        mActivity = activity;
        this.mPhotoListDetail = photoList;
        this.mIsPhotosTab = isPhotosTab;
        mImageLoader = new ImageLoader(mActivity);
        mAppConst = new AppConstant(mActivity);
        mOnItemClickListener = onItemClickListener;
    }


    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        switch (viewType) {
            case TYPE_ITEM:
                View v = LayoutInflater.from(viewGroup.getContext())
                        .inflate(R.layout.album_photos_item, viewGroup, false);
                return new ViewHolder(v, mIsPhotosTab);

            default:
                View view = LayoutInflater.from(viewGroup.getContext()).inflate(
                        R.layout.progress_item, viewGroup, false);
                return new ProgressViewHolder(view);
        }
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder viewHolder, int position) {

        if (viewHolder instanceof ViewHolder) {
            ViewHolder itemViewHolder = (ViewHolder) viewHolder;
            mPhotoList = mPhotoListDetail.get(position);
            itemViewHolder.photoList = mPhotoList;

            if (mIsPhotosTab) {
                int randomColor = getRandomColor();
                Drawable drawable = ContextCompat.getDrawable(mActivity, R.drawable.photos_round_shape);
                drawable.mutate().setColorFilter(randomColor, PorterDuff.Mode.SRC_ATOP);
                itemViewHolder.imageView.setBackground(drawable);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    itemViewHolder.imageView.setClipToOutline(true);
                }
                mImageLoader.setAlbumPhotosImage(mPhotoList.getImageUrl(), itemViewHolder.imageView, randomColor);

            } else {
                mImageLoader.setFeedImage(mPhotoList.getImageUrl(), itemViewHolder.imageView);
            }

            itemViewHolder.container.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mOnItemClickListener.onItemClick(v, itemViewHolder.getAdapterPosition());
                }
            });

            if (mPhotoList.getImageUrl() != null && !mPhotoList.getImageUrl().isEmpty()
                    && mPhotoList.getImageUrl().contains(".gif")) {
                itemViewHolder.ivGifIcon.setVisibility(View.VISIBLE);
            } else {
                itemViewHolder.ivGifIcon.setVisibility(View.GONE);
            }

        } else {
            ProgressViewHolder.inflateProgressBar(((ProgressViewHolder) viewHolder).progressView);
            StaggeredGridLayoutManager.LayoutParams layoutParams = (StaggeredGridLayoutManager.LayoutParams) viewHolder.itemView.getLayoutParams();
            layoutParams.setFullSpan(true);
        }

    }

    @Override
    public int getItemCount() {
        return mPhotoListDetail.size();
    }

    @Override
    public int getItemViewType(int position) {
            if (mPhotoListDetail.get(position) == null) {
                return TYPE_PROGRESS;
            } else {
                return TYPE_ITEM;
            }
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    public int getRandomColor() {
        Random rand = new Random();
        int randomColor;
        int r = rand.nextInt(256);
        int g = rand.nextInt(256);
        int b = rand.nextInt(256);

        randomColor = Color.argb((int)(255 * 0.2), r,g,b);
        return randomColor;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView imageView, ivGifIcon;
        PhotoListDetails photoList;
        View container;
        int randomHeight;

        public ViewHolder(View v, boolean mIsPhotosTab) {
            super(v);
            container = v;
            imageView = (ImageView) v.findViewById(R.id.thumbnail);
            ivGifIcon = (ImageView) v.findViewById(R.id.gif_icon);
            if (mIsPhotosTab) {
                randomHeight = AppConstant.getRandomNumber((int) imageView.getContext().getResources().getDimension(R.dimen.dimen_350dp), (int) imageView.getContext().getResources().getDimension(R.dimen.dimen_200dp));
            } else {
                randomHeight = AppConstant.getRandomNumber((int) imageView.getContext().getResources().getDimension(R.dimen.dimen_180dp), (int) imageView.getContext().getResources().getDimension(R.dimen.dimen_120dp));
            }
            imageView.setLayoutParams(CustomViews.getCustomWidthHeightRelativeLayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, randomHeight));

        }
    }
}
