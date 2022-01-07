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
import android.graphics.drawable.Drawable;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;

import java.util.List;

public class FilterViewAdapter extends RecyclerView.Adapter {

    private Context mContext;
    private OnItemClickListener mOnItemClickListener;
    private BrowseListItems mListItem, mBrowseList;
    private List<BrowseListItems> mCategoryItemList;
    private int previousSelectedPos = -1;

    public FilterViewAdapter(Context context, List<BrowseListItems> listItem, BrowseListItems browseListItems,
                             OnItemClickListener onItemClickListener) {

        this.mContext = context;
        this.mCategoryItemList = listItem;
        this.mBrowseList = browseListItems;
        mOnItemClickListener = onItemClickListener;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {

        View v = LayoutInflater.from(viewGroup.getContext())
                .inflate(R.layout.album_category_item, viewGroup, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder viewHolder, int position) {

        if (viewHolder instanceof ViewHolder) {
            ViewHolder itemViewHolder = (ViewHolder) viewHolder;
            mListItem = mCategoryItemList.get(position);
            itemViewHolder.listItem = mListItem;

            itemViewHolder.filterName.setText(mListItem.getmFilterCategoryName());
            itemViewHolder.filterLayout.setTag(mListItem.getmFilterCategoryId());

            Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.background_rounded_corner_grey).mutate();

            if (position == previousSelectedPos) {
                drawable.setColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor), PorterDuff.Mode.SRC_ATOP);
                itemViewHolder.filterName.setTextColor(mContext.getResources().getColor(R.color.white));

            } else {
                drawable.setColorFilter(ContextCompat.getColor(mContext, R.color.grey_light), PorterDuff.Mode.SRC_ATOP);
                itemViewHolder.filterName.setTextColor(mContext.getResources().getColor(R.color.black));
            }
            itemViewHolder.filterLayout.setBackground(drawable);

            itemViewHolder.filterLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    mListItem = mCategoryItemList.get(itemViewHolder.getAdapterPosition());

                    previousSelectedPos = (itemViewHolder.getAdapterPosition() == previousSelectedPos && itemViewHolder.getAdapterPosition() != 0) ? -1 : itemViewHolder.getAdapterPosition();
                    mOnItemClickListener.onItemClick(v, itemViewHolder.getAdapterPosition());
                    notifyDataSetChanged();
                }
            });
        }

    }

    @Override
    public int getItemCount() {
        return mCategoryItemList.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView filterName;
        LinearLayout filterLayout;
        private BrowseListItems listItem;

        public ViewHolder(View v) {
            super(v);
            filterName = v.findViewById(R.id.filter_name);
            filterLayout = v.findViewById(R.id.filter_layout);
        }
    }
}
