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

package com.socialengineaddons.mobileapp.classes.modules.story;

import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.DecelerateInterpolator;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.FeedsFragment;
import com.socialengineaddons.mobileapp.classes.modules.messages.CreateNewMessage;
import com.socialengineaddons.mobileapp.classes.modules.store.adapters.SimpleSheetAdapter;
import com.socialengineaddons.mobileapp.classes.modules.store.utils.SheetItemModel;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;


public class StoryBrowseAdapter extends RecyclerView.Adapter implements View.OnClickListener {


    //Member Variables.
    private Context mContext;
    private List<Object> mBrowseList;
    private BrowseListItems mBrowseListItems;
    private AppConstant mAppConst;
    private FeedsFragment mFeedsFragment;
    private ImageLoader mImageLoader;


    public StoryBrowseAdapter(Context context, FeedsFragment feedsFragment, List<Object> browseList) {
        mContext = context;
        mFeedsFragment = feedsFragment;
        mBrowseList = browseList;
        mAppConst = new AppConstant(mContext);
        mImageLoader = new ImageLoader(mContext);
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ItemViewHolder(mContext, LayoutInflater.from(parent.getContext()).inflate(
                R.layout.story_browse_list, parent, false));
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, final int position) {

        final ItemViewHolder itemViewHolder = (ItemViewHolder) holder;
        mBrowseListItems = (BrowseListItems) this.mBrowseList.get(position);

        // Showing story's main image.
        mImageLoader.setImageForUserProfile(mBrowseListItems.getStoryImage(), itemViewHolder.ivStoryImage);

        // Showing overlay image over the main image if available (applicable only for video filter).
        if (mBrowseListItems.getStoryOverlayImage() != null && !mBrowseListItems.getStoryOverlayImage().isEmpty()) {
            mImageLoader.setReactionImageUrl(mBrowseListItems.getStoryOverlayImage(), itemViewHolder.ivOverlayImage);
            itemViewHolder.ivOverlayImage.setVisibility(View.VISIBLE);
        } else {
            itemViewHolder.ivOverlayImage.setVisibility(View.GONE);
        }

        // Set add story icon drawable color white
        Drawable addDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_add_black_24dp);
        addDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.white),
                PorterDuff.Mode.SRC_ATOP));
        itemViewHolder.ivStoryAdd.setImageDrawable(addDrawable);
        itemViewHolder.isMuteStory = mBrowseListItems.isMuteStory();

        // Showing the owner image if there is any story is published.
        if (mBrowseListItems.getStoryId() != 0) {
            if (itemViewHolder.isMuteStory == 1) {
                itemViewHolder.mContainer.setAlpha(.4f);
            } else {
                itemViewHolder.mContainer.setAlpha(1f);
            }

            itemViewHolder.ivStoryAdd.setVisibility(View.GONE);
            mImageLoader.setImageForUserProfile(mBrowseListItems.getOwnerImage(), itemViewHolder.ivUserProfile);

            if (mBrowseListItems.getmIsLoading()) {
                itemViewHolder.storyImageLayout.setBackgroundResource(R.color.white);
                itemViewHolder.ivUserProfile.setVisibility(View.GONE);
                showUploadingProgress(itemViewHolder);
            } else {
                itemViewHolder.mUploadingBar.setVisibility(View.GONE);
                itemViewHolder.mUploadingBar.clearAnimation();
                itemViewHolder.ivUserProfile.setVisibility(View.VISIBLE);
                itemViewHolder.storyImageLayout.setBackgroundResource(R.drawable.custom_circle_border);
            }

            if (position == 0) {
                itemViewHolder.ivStoryAdd.setVisibility(View.VISIBLE);
                itemViewHolder.ivUserProfile.setVisibility(View.GONE);
            } else {
                itemViewHolder.ivStoryAdd.setVisibility(View.GONE);
            }

        } else {
            itemViewHolder.ivUserProfile.setVisibility(View.GONE);
            itemViewHolder.storyImageLayout.setBackgroundResource(R.color.white);

            // Checking if no story is created then showing the add icon.
            if (mBrowseListItems.getmIsLoading()) {
                itemViewHolder.ivStoryAdd.setVisibility(View.GONE);
                showUploadingProgress(itemViewHolder);

            } else if (mBrowseListItems.getStoryOwnerId() == 0) {
                itemViewHolder.mUploadingBar.setVisibility(View.GONE);
                itemViewHolder.mUploadingBar.clearAnimation();
                itemViewHolder.ivStoryAdd.setVisibility(View.VISIBLE);

            } else {
                // If there are less story then showing the friends,
                // in this case adding color filter to make it different from stories.
                itemViewHolder.ivStoryImage.setColorFilter(Color.argb(211, 211, 211, 211));
                itemViewHolder.ivStoryAdd.setVisibility(View.GONE);
                itemViewHolder.mUploadingBar.setVisibility(View.GONE);
                itemViewHolder.mUploadingBar.clearAnimation();
            }
        }

        // Showing story owner title.
        itemViewHolder.tvUserName.setText(mBrowseListItems.getStoryOwner());

        itemViewHolder.mContainer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final BrowseListItems browseListItems = (BrowseListItems) mBrowseList.get(itemViewHolder.getAdapterPosition());
                // Checking if clicked on story.
                if (browseListItems.getStoryId() != 0) {
                    Intent intent = new Intent(mContext, StoryView.class);
                    if (itemViewHolder.getAdapterPosition() == 0) {
                        intent.putExtra("is_my_story", true);
                    }
                    StoryUtils.sCurrentStory = itemViewHolder.getAdapterPosition();
                    intent.putExtra(ConstantVariables.STORY_ID, browseListItems.getStoryId());
                    mFeedsFragment.startActivityForResult(intent, ConstantVariables.STORY_VIEW_PAGE_CODE);
                    ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

                } else if (browseListItems.getStoryOwnerId() == 0) {
                    // If add story item is clicked.
                    if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                        mFeedsFragment.checkManifestPermissions(null, Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE, false, true);
                    } else {
                        mFeedsFragment.startStoryMediaPickerActivity();
                    }
                } else {
                    // If friends list item is clicked.
                    itemViewHolder.bottomSheetDialog.show();
                    itemViewHolder.tvInflatedViewTitle.setVisibility(View.VISIBLE);
                    itemViewHolder.inflatedView.findViewById(R.id.divider).setVisibility(View.VISIBLE);
                    itemViewHolder.tvInflatedViewTitle.setText(browseListItems.getStoryOwner() + " "
                            + mContext.getResources().getString(R.string.story_not_added));

                    if (browseListItems.isSendMessage() && !itemViewHolder.isItemAdded) {
                        SheetItemModel sheetItemModelMsg = new SheetItemModel(mContext.getResources().getString(R.string.send_photo_video), "send", "f030");
                        itemViewHolder.list.add(0, sheetItemModelMsg);
                        itemViewHolder.isItemAdded = true;
                    }

                    itemViewHolder.mSheetAdapter.setOnItemClickListener(new SimpleSheetAdapter.OnItemClickListener() {
                        @Override
                        public void onItemClick(SheetItemModel value, int position) {
                            itemViewHolder.bottomSheetDialog.hide();
                            Intent intent;
                            SheetItemModel sheetItem = itemViewHolder.list.get(position);
                            if (sheetItem.getKey().equals("send")) {
                                intent = new Intent(mContext, CreateNewMessage.class);
                                intent.putExtra(ConstantVariables.CONTENT_TITLE, browseListItems.getStoryOwner());
                                intent.putExtra("isSendMessageRequest", true);
                            } else {
                                intent = new Intent(mContext, userProfile.class);
                                intent.putExtra(ConstantVariables.USER_ID, browseListItems.getStoryOwnerId());
                                mContext.startActivity(intent);
                                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                            }
                        }
                    });
                }
            }
        });

        /* Set long click listener on story item */
        if (mBrowseListItems.getStoryId() != 0 && mBrowseListItems.getStoryOwnerId() != 0) {
            itemViewHolder.mContainer.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    final BrowseListItems browseListItems = (BrowseListItems) mBrowseList.get(itemViewHolder.getAdapterPosition());
                    // If friends list item is clicked.
                    itemViewHolder.bottomSheetDialog.show();
                    itemViewHolder.tvInflatedViewTitle.setVisibility(View.VISIBLE);
                    itemViewHolder.inflatedView.findViewById(R.id.divider).setVisibility(View.VISIBLE);
                    itemViewHolder.tvInflatedViewTitle.setText(mContext.getResources().getString(R.string.story_more_action)
                            + " " + browseListItems.getStoryOwner());

                    String label, icon;
                    if (browseListItems.isMuteStory() == 1) {
                        label = mContext.getResources().getString(R.string.unmute_story_dialogue_button);
                        icon = "f130";
                    } else {
                        label = mContext.getResources().getString(R.string.mute_story_dialogue_button);
                        icon = "f131";
                    }

                    // Add or set option in bottom sheet and notified the adapter
                    SheetItemModel sheetItemModel = new SheetItemModel(label + " " + browseListItems.getStoryOwner(), "mute", icon);

                    if (!itemViewHolder.isItemAdded) {
                        itemViewHolder.list.add(sheetItemModel);
                        itemViewHolder.isItemAdded = true;
                        if (browseListItems.isSendMessage()) {
                            SheetItemModel sheetItemModelMsg = new SheetItemModel(mContext.getResources().getString(R.string.send_photo_video), "send", "f030");
                            itemViewHolder.list.add(0, sheetItemModelMsg);
                        }
                    } else {
                        itemViewHolder.list.set(itemViewHolder.list.size()-1, sheetItemModel);
                    }
                    itemViewHolder.mSheetAdapter.notifyDataSetChanged();

                    itemViewHolder.mSheetAdapter.setOnItemClickListener(new SimpleSheetAdapter.OnItemClickListener() {
                        @Override
                        public void onItemClick(SheetItemModel value, int position) {
                            itemViewHolder.bottomSheetDialog.hide();
                            Intent intent = null;
                            SheetItemModel sheetItem = itemViewHolder.list.get(position);
                            switch (sheetItem.getKey()) {
                                case "send":
                                    intent = new Intent(mContext, CreateNewMessage.class);
                                    intent.putExtra(ConstantVariables.CONTENT_TITLE, browseListItems.getStoryOwner());
                                    intent.putExtra("isSendMessageRequest", true);
                                    break;
                                case "view":
                                    intent = new Intent(mContext, userProfile.class);
                                    break;
                                case "mute":
                                    muteStory(browseListItems);
                                    break;
                            }

                            if (intent != null) {
                                intent.putExtra(ConstantVariables.USER_ID, browseListItems.getStoryOwnerId());
                                mContext.startActivity(intent);
                                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                            }
                        }
                    });
                    return false;
                }
            });
        }

        // If add story icon is clicked.
        itemViewHolder.ivStoryAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    mFeedsFragment.checkManifestPermissions(null, Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            ConstantVariables.WRITE_EXTERNAL_STORAGE, false, true);
                } else {
                    mFeedsFragment.startStoryMediaPickerActivity();
                }
            }
        });

    }

    private void muteStory(BrowseListItems browseListItems) {
        int isMute;
        if (browseListItems.isMuteStory() == 1) {
            isMute = 0;
        } else {
            isMute = 1;
        }
        String url = UrlUtil.MUTE_UNMUTE_STORY_URL + browseListItems.getStoryId() + "?is_mute=" + isMute;
        String mDialogueMessage, mDialogueTitle, mDialogueButton, mSuccessMessage;

        if (isMute == 1) {
            mDialogueMessage = mContext.getResources().getString(R.string.mute_story_dialogue_message);
            mDialogueTitle = mContext.getResources().getString(R.string.mute_story_dialogue_title);
            mDialogueButton = mContext.getResources().getString(R.string.mute_story_dialogue_button);
            mSuccessMessage = mContext.getResources().getString(R.string.mute_story_dialogue_success_message);
        } else {
            mDialogueMessage = mContext.getResources().getString(R.string.unmute_story_dialogue_message);
            mDialogueTitle = mContext.getResources().getString(R.string.unmute_story_dialogue_title);
            mDialogueButton = mContext.getResources().getString(R.string.unmute_story_dialogue_button);
            mSuccessMessage = mContext.getResources().getString(R.string.unmute_story_dialogue_success_message);
        }

        AlertDialog.Builder alertBuilder = new AlertDialog.Builder(mContext);
        alertBuilder.setMessage(mDialogueMessage);
        alertBuilder.setTitle(mDialogueTitle);
        alertBuilder.setPositiveButton(mDialogueButton, (dialog, which) -> {
            mAppConst.showProgressDialog();
            mAppConst.postJsonResponseForUrl(url, null, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mAppConst.hideProgressDialog();
                    SnackbarUtils.displaySnackbar(((Activity)mContext).findViewById(android.R.id.content), mSuccessMessage);
                    mFeedsFragment.sendStoriesRequest();
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mAppConst.hideProgressDialog();
                    SnackbarUtils.displaySnackbar(((Activity)mContext).findViewById(android.R.id.content), message);
                }
            });
        });


        alertBuilder.setNegativeButton(mContext.getResources().
                        getString(R.string.delete_account_cancel_button_text),
                (dialog, which) -> dialog.cancel());

        alertBuilder.create().show();
    }

    /**
     * Method to show uploading progress bar.
     *
     * @param itemViewHolder ItemViewHolder instance.
     */
    private void showUploadingProgress(final ItemViewHolder itemViewHolder) {
        itemViewHolder.mUploadingBar.setVisibility(View.VISIBLE);
        itemViewHolder.mUploadingBar.setProgress(0);
        itemViewHolder.ivStoryAdd.bringToFront();
        final ObjectAnimator anim = ObjectAnimator.ofInt(itemViewHolder.mUploadingBar, "progress", 0, 500);
        anim.setDuration(5000);
        anim.setInterpolator(new DecelerateInterpolator());
        anim.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                itemViewHolder.mUploadingBar.clearAnimation();
                itemViewHolder.mUploadingBar.setVisibility(View.GONE);
                anim.removeAllListeners();
                anim.cancel();
                notifyItemChanged(itemViewHolder.getAdapterPosition());
            }
        });
        anim.start();
    }

    @Override
    public int getItemCount() {
        return mBrowseList.size();
    }

    @Override
    public void onClick(View v) {

    }

    public static class ItemViewHolder extends RecyclerView.ViewHolder {

        public ImageView ivUserProfile, ivStoryImage, ivStoryAdd, ivOverlayImage;
        public TextView tvUserName, tvInflatedViewTitle;
        public ProgressBar mUploadingBar;
        public View mContainer, inflatedView, storyImageLayout;
        public BottomSheetDialog bottomSheetDialog;
        public SimpleSheetAdapter mSheetAdapter;
        public List<SheetItemModel> list;
        public boolean isItemAdded = false;
        private int isMuteStory;

        public ItemViewHolder(Context context, View view) {
            super(view);
            mContainer = view;
            mUploadingBar = view.findViewById(R.id.progressBar);
            storyImageLayout = view.findViewById(R.id.story_image_layout);
            ivUserProfile = (ImageView) view.findViewById(R.id.owner_image);
            ivStoryImage = (ImageView) view.findViewById(R.id.story_image);
            ivOverlayImage = view.findViewById(R.id.overlay_image);
            ivStoryAdd = (ImageView) view.findViewById(R.id.add_story);
            tvUserName = (TextView) view.findViewById(R.id.owner_name);

            //Views for the friends view Bottom sheet dialog.
            list = new ArrayList<>();
            list.add(new SheetItemModel(context.getResources().getString(R.string.view_profile_text), "view", "f007"));
            mSheetAdapter = new SimpleSheetAdapter(context, list, true);
            inflatedView = ((Activity) context).getLayoutInflater().inflate(R.layout.fragmen_cart, null);
            inflatedView.setBackgroundResource(R.color.white);
            tvInflatedViewTitle = inflatedView.findViewById(R.id.header_title);
            RecyclerView recyclerView = inflatedView.findViewById(R.id.recycler_view);
            inflatedView.findViewById(R.id.cart_bottom).setVisibility(View.GONE);
            recyclerView.getLayoutParams().height = RecyclerView.LayoutParams.WRAP_CONTENT;
            recyclerView.setHasFixedSize(true);
            recyclerView.setLayoutManager(new LinearLayoutManager(context));
            recyclerView.setAdapter(mSheetAdapter);
            bottomSheetDialog = new BottomSheetDialog(context);
            bottomSheetDialog.setContentView(inflatedView);
        }
    }
}
