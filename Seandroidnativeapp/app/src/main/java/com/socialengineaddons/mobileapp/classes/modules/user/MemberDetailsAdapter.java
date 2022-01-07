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

package com.socialengineaddons.mobileapp.classes.modules.user;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.ui.viewholder.ProgressViewHolder;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import java.util.List;


public class MemberDetailsAdapter extends RecyclerView.Adapter {

    //Member variables.
    private Context mContext;
    private final int VIEW_ITEM = 1, VIEW_PROGRESSBAR = 0;
    private boolean isLiveStreamViewer = false;
    private List<Object> mMemberDetailsList;
    private MemberDetailsDialog mMemberDetailsDialog;
    private ImageLoader mImageLoader;

    /***
     * Public constructor of MemberDetailsAdapter to add data to the list
     *  @param context                Context of calling class.
     * @param isLiveStreamViewer True, if dialog is showing to display live stream viewer list.
     * @param browseItemList         ListItems which are added to the inflating layout.
     * @param memberDetailsDialog    Instance of MemberDetailsDialog.
     */
    public MemberDetailsAdapter(Context context, boolean isLiveStreamViewer, List<Object> browseItemList, MemberDetailsDialog memberDetailsDialog) {
        mContext = context;
        this.isLiveStreamViewer = isLiveStreamViewer;
        mMemberDetailsList = browseItemList;
        mMemberDetailsDialog = memberDetailsDialog;
        mImageLoader = new ImageLoader(mContext);
    }

    @Override
    public int getItemViewType(int position) {
        return mMemberDetailsList.get(position) instanceof String ? VIEW_PROGRESSBAR : VIEW_ITEM;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        RecyclerView.ViewHolder viewHolder;
        if (viewType == VIEW_ITEM) {
            viewHolder = new ItemViewHolder(mContext, LayoutInflater.from(mContext).inflate(
                    R.layout.list_members, parent, false));
        } else {
            viewHolder = new ProgressViewHolder(LayoutInflater.from(parent.getContext()).inflate(
                    R.layout.progress_item, parent, false));
        }
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder recyclerViewHolder, int position) {

        if (getItemViewType(position) == VIEW_ITEM) {
            final ItemViewHolder holder = (ItemViewHolder) recyclerViewHolder;
            final MemberDetails listItems = (MemberDetails) mMemberDetailsList.get(position);
            holder.tvUserName.setText(listItems.getDisplayName());
            if (listItems.getDescription() != null && !listItems.getDescription().isEmpty()) {

                holder.tvDescription.setVisibility(View.VISIBLE);
                holder.tvDescription.setMaxLines(Integer.MAX_VALUE);
                if (listItems.getDescription().trim().length()
                        > ConstantVariables.FEED_TITLE_BODY_LENGTH) {

                    if (listItems.isLessTextShowing()) {
                        holder.tvDescription.setText(Html.fromHtml(listItems.getDescription()
                                + "<font color=\"#a9a9a9\">" + " ..."
                                + mContext.getResources().getString(R.string.readLess) + " </font>"));
                    } else {
                        holder.tvDescription.setText(Html.fromHtml(listItems.getDescription().substring(0, 150)
                                + "<font color=\"#a9a9a9\">" + " ..."
                                + mContext.getResources().getString(R.string.readMore) + " </font>"));
                    }
                    holder.tvDescription.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            MemberDetails clickedItem = (MemberDetails) mMemberDetailsList.get(recyclerViewHolder.getAdapterPosition());
                            clickedItem.setLessTextShowing(!clickedItem.isLessTextShowing());
                            notifyItemChanged(recyclerViewHolder.getAdapterPosition());
                        }
                    });
                } else {
                    holder.tvDescription.setText(listItems.getDescription());
                }

            } else {
                holder.tvDescription.setVisibility(View.GONE);
            }

            mImageLoader.setImageForUserProfile(listItems.getProfileImage(), holder.ivUserProfile);

            holder.mContainer.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!isLiveStreamViewer) {
                        MemberDetails memberDetails = (MemberDetails) mMemberDetailsList.get(holder.getAdapterPosition());
                        Intent intent = new Intent(mContext, userProfile.class);
                        intent.putExtra(ConstantVariables.USER_ID, memberDetails.getUserId());
                        mContext.startActivity(intent);
                        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                        mMemberDetailsDialog.dismiss();
                    }
                }
            });

        } else {
            ProgressViewHolder.inflateProgressView(mContext, ((ProgressViewHolder) recyclerViewHolder).progressView,
                    mMemberDetailsList.get(position));
        }

    }

    @Override
    public int getItemCount() {
        return mMemberDetailsList.size();
    }

    public class ItemViewHolder extends RecyclerView.ViewHolder {

        public View mContainer;
        public ImageView ivUserProfile;
        public TextView tvUserName, tvDescription;

        public ItemViewHolder(Context context, View itemView) {
            super(itemView);
            mContainer = itemView;
            mContainer.setPadding(0, context.getResources().getDimensionPixelSize(R.dimen.padding_8dp), 0,
                    context.getResources().getDimensionPixelSize(R.dimen.padding_8dp));
            ivUserProfile = itemView.findViewById(R.id.ownerImage);
            tvUserName = itemView.findViewById(R.id.ownerTitle);
            tvDescription = itemView.findViewById(R.id.rsvpInfo);
            tvDescription.setPadding(0, context.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0, 0);
        }
    }
}
