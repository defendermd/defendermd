package com.socialengineaddons.mobileapp.classes.common.adapters;
/*
 *   Copyright (c) 2019 BigStep Technologies Private Limited.
 *
 *   You may not use this file except in compliance with the
 *   SocialEngineAddOns License Agreement.
 *   You may obtain a copy of the License at:
 *   https://www.socialengineaddons.com/android-app-license
 *   The full copyright and license information is also mentioned
 *   in the LICENSE file that was distributed with this
 *   source code.
 */


import android.content.Context;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.models.GridItemModel;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;

import java.util.List;

/**
 * @GridItemAdapter is used to render grid item layout with the help of @GridItemModel data in recycler-view.
 */
public class GridItemAdapter extends RecyclerView.Adapter {

    private List<GridItemModel> mItemList;
    private Context mContext;
    private ImageLoader mImageLoader;
    private OnItemClickListener mItemClickListener;
    private String mAdapterTagName = GridItemAdapter.class.getSimpleName();
    private int iTotalItemCount;

    /**
     * Public constructor to initiating the adapter
     *
     * @param mItemList
     * @param context
     */
    public GridItemAdapter(List<GridItemModel> mItemList, Context context) {
        this.mItemList = mItemList;
        this.mContext = context;
        this.mImageLoader = new ImageLoader(mContext);
        mItemClickListener = (OnItemClickListener) mContext;

    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
        View itemView = LayoutInflater.from(viewGroup.getContext()).inflate(
                R.layout.grid_item_layout, viewGroup, false);

        return new ItemViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder viewHolder, int position) {
        ItemViewHolder itemViewHolder = (ItemViewHolder) viewHolder;
        GridItemModel itemModel = mItemList.get(position);
        itemViewHolder.llGridContainer.setTag(mAdapterTagName);
        itemViewHolder.llGridContainer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mItemClickListener.onItemClick(view, viewHolder.getAdapterPosition());
            }
        });
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            itemViewHolder.ivItemPhoto.setClipToOutline(true);
        }
        if (itemModel.getStrItemPhoto() != null) {
            mImageLoader.setImageUrl(itemModel.getStrItemPhoto(), itemViewHolder.ivItemPhoto);
        }
        if (itemModel.getStrItemTitle() != null) {
            itemViewHolder.tvItemTitle.setVisibility(View.VISIBLE);
            itemViewHolder.tvItemTitle.setText(itemModel.getStrItemTitle());
            if (mAdapterTagName.equals("Friends") && (position % 3 == 0)) {
                itemViewHolder.tvItemTitle.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_2dp), 0,
                        mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp), 0);
                itemViewHolder.tvItemSubTitle.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_2dp), 0, 0, 0);
            }
        } else {
            itemViewHolder.tvItemTitle.setVisibility(View.GONE);
        }
        if (itemModel.getStrItemSubTitle() != null) {
            itemViewHolder.tvItemSubTitle.setText(itemModel.getStrItemSubTitle());
            itemViewHolder.tvItemSubTitle.setVisibility(View.VISIBLE);
        } else {
            itemViewHolder.tvItemSubTitle.setVisibility(View.GONE);
        }
        if (position == (mItemList.size() - 1) && iTotalItemCount > mItemList.size()) {
            itemViewHolder.tvSeeMore.setVisibility(View.VISIBLE);
            itemViewHolder.tvSeeMore.setTag("SeeMore_" + mAdapterTagName);
            itemViewHolder.tvSeeMore.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mItemClickListener.onItemClick(view, viewHolder.getAdapterPosition());
                }
            });
        } else {
            itemViewHolder.tvSeeMore.setVisibility(View.GONE);
        }

    }

    @Override
    public int getItemCount() {
        return mItemList.size();
    }

    public void setAdapterTagName(String tagName) {
        this.mAdapterTagName = tagName;
    }

    public void setTotalItemCount(int itemCount) {
        this.iTotalItemCount = itemCount;
    }

    /**
     * @ItemViewHolder handle the views of #GridItemLayout
     */
    private static class ItemViewHolder extends RecyclerView.ViewHolder {
        private TextView tvItemTitle, tvItemSubTitle, tvSeeMore;
        private ImageView ivItemPhoto;
        private LinearLayout llGridContainer;

        public ItemViewHolder(@NonNull View itemView) {
            super(itemView);
            llGridContainer = itemView.findViewById(R.id.llGridContainer);
            tvItemTitle = itemView.findViewById(R.id.tvItemTitle);
            tvItemSubTitle = itemView.findViewById(R.id.tvItemSubTitle);
            ivItemPhoto = itemView.findViewById(R.id.ivItemPhoto);
            tvSeeMore = itemView.findViewById(R.id.tvSeeMore);
        }
    }

}
