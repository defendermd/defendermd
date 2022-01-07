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
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.text.Html;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCancelClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnSheetItemClickListner;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUserLayoutClickListener;
import com.socialengineaddons.mobileapp.classes.common.ui.ActionIconThemedTextView;
import com.socialengineaddons.mobileapp.classes.common.ui.BezelImageView;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.viewholder.ProgressViewHolder;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageViewList;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SocialShareUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.likeNComment.Comment;
import com.socialengineaddons.mobileapp.classes.modules.likeNComment.Likes;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;
import com.socialengineaddons.mobileapp.classes.modules.store.adapters.SimpleSheetAdapter;
import com.socialengineaddons.mobileapp.classes.modules.store.utils.SheetItemModel;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.SortedSet;
import java.util.TreeSet;


/**
 * Provide views to RecyclerView with data from mDataSet.
 */
public class CustomImageAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    public static final int TYPE_HEADER = 0;
    public static final int TYPE_ITEM = 1;
    public static final int TYPE_PROGRESS = 2;

    private Activity mActivity;
    private Bundle mBundle;
    private String mSubjectType;
    List<ImageViewList> mPhotoList;
    private int mImageWidth;
    ImageViewList mImageViewList;
    private OnItemClickListener mOnItemClickListener;
    private OnSheetItemClickListner mOnSheetItemClickListner;
    private OnUserLayoutClickListener mOnUserLayoutClickListener;
    private OnCancelClickListener mOnCancelClickListener;
    private boolean mIsBitmapImage = false, mIsStatusImage = false, mIsPhotoAttachment,
            isCarouselImages = false, isStoryImage = false, isAlbumView = false;
    ImageViewList mList;
    private ImageLoader mImageLoader;
    private int padding, mReactionsEnabled;
    private SimpleSheetAdapter mSheetAdapter;
    private BottomSheetDialog mBottomSheetDialog;
    private AppConstant mAppConst;
    private JSONObject myReaction;
    private GutterMenuUtils mGutterMenuUtils;
    private SocialShareUtil socialShareUtil;
    private ArrayList<JSONObject> mReactionsArray;
    JSONObject mAllReactionObject;

    /**
     * Initialize the data set of the Adapter.
     * @param activity Activity instance of the calling class.
     * @param list List object.
     * @param photoList Containing the data to populate views to be used by RecyclerView.
     * @param columnWidth Width of the each image.
     * @param bundle Bundle which contains the data.
     * @param subjectType Subject type of the images.
     * @param onItemClickListener ItemClickListener on each image.
     * @param onUserLayoutClickListener UserInfo click listener.
     */
    public CustomImageAdapter(Activity activity, ImageViewList list, List<ImageViewList> photoList,
                              int columnWidth, Bundle bundle, String subjectType, boolean albumView,
                              OnItemClickListener onItemClickListener,
                              OnUserLayoutClickListener onUserLayoutClickListener) {

        mOnItemClickListener = onItemClickListener;
        mOnUserLayoutClickListener = onUserLayoutClickListener;
        mActivity = activity;
        mPhotoList = photoList;
        mImageWidth = columnWidth;
        mBundle = bundle;
        mSubjectType = subjectType;
        mList = list;
        isAlbumView = albumView;
        mImageLoader = new ImageLoader(mActivity);
        mAppConst = new AppConstant(mActivity);
        socialShareUtil = new SocialShareUtil(mActivity);
        mOnSheetItemClickListner = (OnSheetItemClickListner) mActivity;
    }

    /**
     * Initialize the data set of the Adapter.
     * @param activity Activity instance of the calling class.
     * @param list List object.
     * @param photoList Containing the data to populate views to be used by RecyclerView.
     * @param columnWidth Width of the each image.
     * @param onItemClickListener ItemClickListener on each image.
     */
    public CustomImageAdapter(Activity activity, ImageViewList list, List<ImageViewList> photoList,
                              int columnWidth, OnItemClickListener onItemClickListener) {

        mOnItemClickListener = onItemClickListener;
        mList = list;
        mActivity = activity;
        mPhotoList = photoList;
        mImageWidth = columnWidth;
        mBundle = new Bundle();
        mSubjectType = "";
        mImageLoader = new ImageLoader(mActivity);
    }

    /**
     * Initialize the data set of the Adapter.
     * @param activity Activity instance of the calling class.
     * @param photoList Containing the data to populate views to be used by RecyclerView.
     * @param columnWidth Width of the each image.
     * @param onItemClickListener ItemClickListener on each image.
     */
    public CustomImageAdapter(Activity activity, List<ImageViewList> photoList,
                              int columnWidth, OnItemClickListener onItemClickListener) {

        mOnItemClickListener = onItemClickListener;
        mActivity = activity;
        mPhotoList = photoList;
        mImageWidth = columnWidth;
        mBundle = new Bundle();
        mSubjectType = "";
        isCarouselImages = true;
        mImageLoader = new ImageLoader(mActivity);
    }

    /**
     * Initialize the data set of the Adapter.
     * @param activity Activity instance of the calling class.
     * @param photoList Containing the data to populate views to be used by RecyclerView.
     * @param columnWidth Width of the each image.
     * @param onItemClickListener ItemClickListener on each image.
     */
    public CustomImageAdapter(Activity activity, List<ImageViewList> photoList,
                              int columnWidth, OnItemClickListener onItemClickListener, OnCancelClickListener onCancelClickListener) {

        mOnItemClickListener = onItemClickListener;
        mOnCancelClickListener = onCancelClickListener;
        mActivity = activity;
        mPhotoList = photoList;
        mImageWidth = columnWidth;
        mBundle = new Bundle();
        mSubjectType = "";
        isCarouselImages = false;
        mImageLoader = new ImageLoader(mActivity);
        this.isStoryImage = true;
        mIsBitmapImage = true;
        isCarouselImages = false;
        padding = (int) mActivity.getResources().getDimension(R.dimen.padding_2dp);
    }

    /**
     * Initialize the data set of the Adapter.
     * @param activity Activity instance of the calling class.
     * @param photoList Containing the data to populate views to be used by RecyclerView.
     * @param columnWidth Width of the each image.
     * @param onCancelClickListener CancelClickListener on each image to remove the item from the list.
     */
    public CustomImageAdapter(Activity activity, List<ImageViewList> photoList,
                              int columnWidth, OnCancelClickListener onCancelClickListener) {
        mList = new ImageViewList();
        mActivity = activity;
        mPhotoList = photoList;
        mImageWidth = columnWidth;
        mBundle = new Bundle();
        mSubjectType = "";
        mIsBitmapImage = true;
        mOnCancelClickListener = onCancelClickListener;
        mImageLoader = new ImageLoader(mActivity);
        isStoryImage = false;
    }

    /**
     * Initialize the data set of the Adapter.
     * @param activity Activity instance of the calling class.
     * @param photoList Containing the data to populate views to be used by RecyclerView.
     * @param isStatusImage True if its for status images.
     * @param columnWidth Width of the each image.
     * @param onCancelClickListener CancelClickListener on each image to remove the item from the list.
     */
    public CustomImageAdapter(Activity activity, List<ImageViewList> photoList, boolean isStatusImage,
                              boolean isPhotoAttachment, int columnWidth, OnCancelClickListener onCancelClickListener) {
        mList = new ImageViewList();
        mActivity = activity;
        mPhotoList = photoList;
        mImageWidth = columnWidth;
        mBundle = new Bundle();
        mSubjectType = "";
        mIsBitmapImage = true;
        mIsStatusImage = isStatusImage;
        mIsPhotoAttachment = isPhotoAttachment;
        mOnCancelClickListener = onCancelClickListener;
        mImageLoader = new ImageLoader(mActivity);
    }

    public void setColumnWidth(int columnWidth) {
        mImageWidth = columnWidth;
    }


    // BEGIN_INCLUDE(recyclerViewOnCreateViewHolder)
    // Create new views (invoked by the layout manager)
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {


        switch (viewType) {
            case TYPE_ITEM:
                //inflate your layout and pass it to view holder
                // Create a new view.
                View v = LayoutInflater.from(viewGroup.getContext())
                        .inflate(R.layout.pager_photo_view, viewGroup, false);
                return new ViewHolder(v, mImageWidth, isAlbumView);

            case TYPE_HEADER:
                //inflate your layout and pass it to view holder
                View headerView = LayoutInflater.from(viewGroup.getContext())
                        .inflate(R.layout.recycler_imageview_header, viewGroup, false);
                return new HeaderViewHolder(headerView);
            default:
                View view = LayoutInflater.from(viewGroup.getContext()).inflate(
                        R.layout.progress_item, viewGroup, false);

                return new ProgressViewHolder(view);
        }
    }
    // END_INCLUDE(recyclerViewOnCreateViewHolder)


    // BEGIN_INCLUDE(recyclerViewOnBindViewHolder)
    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder viewHolder, final int position) {

        // Get element from your dataset at this position and replace the contents of the view
        // with that element
        if (viewHolder instanceof ViewHolder) {
            final ViewHolder itemViewHolder = (ViewHolder) viewHolder;
            mImageViewList = getItem(position);
            itemViewHolder.holderImageList = mImageViewList;

            if (isCarouselImages) {
                itemViewHolder.container.findViewById(R.id.main_view).getLayoutParams().width = ViewGroup.LayoutParams.WRAP_CONTENT;
                if (position == 0) {
                    if (mPhotoList.size() == 1) {
                        itemViewHolder.container.findViewById(R.id.main_view).setPadding(0, 0, 0, 0);
                    } else {
                        itemViewHolder.container.findViewById(R.id.main_view).setPadding(
                                mActivity.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0,
                                mActivity.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0);
                    }
                } else {
                    itemViewHolder.container.findViewById(R.id.main_view).setPadding(0, 0,
                            mActivity.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0);
                }
                mImageLoader.setAlbumPhoto(mImageViewList.getmGridViewImageUrl(), ((ViewHolder) viewHolder).imageView);

            } else if (isStoryImage) {
                itemViewHolder.container.findViewById(R.id.main_view).getLayoutParams().width = ViewGroup.LayoutParams.WRAP_CONTENT;
                itemViewHolder.container.findViewById(R.id.main_view).setPadding(padding, padding, padding, padding);

                if (itemViewHolder.holderImageList.getmSelectedItemPos() == 1) {
                    itemViewHolder.mSelectedPosition = position;
                    itemViewHolder.container.setBackgroundColor(ContextCompat.getColor(mActivity, R.color.themeButtonColor));

                } else {
                    itemViewHolder.container.setBackgroundColor(Color.TRANSPARENT);
                }

                if (mImageViewList.getmGridPhotoUrl() != null) {
                    // Setting up the bitmap into image view.
                    itemViewHolder.imageView.setImageBitmap(mImageViewList.getmGridPhotoUrl());
                }

                itemViewHolder.container.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mOnItemClickListener != null) {

                            if (itemViewHolder.mSelectedPosition < getItemCount()) {
                                ImageViewList imageViewListOld = mPhotoList.get(itemViewHolder.mSelectedPosition);
                                imageViewListOld.setmSelectedItemPos(0);
                            }

                            if (position < getItemCount()) {
                                ImageViewList imageViewList = mPhotoList.get(position);
                                imageViewList.setmSelectedItemPos(1);

                                mOnItemClickListener.onItemClick(v, position);
                            }

                            notifyDataSetChanged();

                        }
                    }
                });

                itemViewHolder.tvCancel.setTag(position);
                // Apply click listener on the cancel image view, to remove the item from the list.
                if (mOnCancelClickListener != null) {
                    Drawable drawable = ContextCompat.getDrawable(mActivity, R.drawable.ic_clear_grey);
                    drawable.setColorFilter(ContextCompat.getColor(mActivity, R.color.white), PorterDuff.Mode.SRC_ATOP);
                    drawable.setBounds(0, 0, mActivity.getResources().getDimensionPixelSize(R.dimen.margin_20dp),
                            mActivity.getResources().getDimensionPixelSize(R.dimen.margin_20dp));
                    itemViewHolder.tvCancel.setCompoundDrawables(null, drawable, null, null);

                    itemViewHolder.tvCancel.setVisibility(View.VISIBLE);
                    itemViewHolder.tvCancel.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            mOnCancelClickListener.onCancelButtonClicked((int) ((ViewHolder) viewHolder).tvCancel.getTag());
                        }
                    });
                }
            }
            // This is for the attachments inside form creation.
            // When any image, music, video and file is picked from device the showing them into image view.
            else if (mIsBitmapImage && !mIsStatusImage) {
                itemViewHolder.container.findViewById(R.id.main_view).getLayoutParams().width = ViewGroup.LayoutParams.WRAP_CONTENT;
                itemViewHolder.container.findViewById(R.id.main_view).setPadding(0, 0,
                        mActivity.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0);
                itemViewHolder.llDescriptionBlock.setVisibility(View.VISIBLE);

                // Checking if the image is in bitmap form or in drawable form.
                if (mImageViewList.getmGridPhotoUrl() != null) {

                    // Setting up the bitmap into image view.
                    itemViewHolder.imageView.setImageBitmap(mImageViewList.getmGridPhotoUrl());

                    // Assign layout params of the cancel image view, to show it on top right corner of the image.
                    RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) ((ViewHolder)
                            viewHolder).llDescriptionBlock.getLayoutParams();
                    layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT, 0);
                    layoutParams.addRule(RelativeLayout.RIGHT_OF, 0);
                    layoutParams.addRule(RelativeLayout.END_OF, 0);
                    layoutParams.addRule(RelativeLayout.ALIGN_TOP, R.id.thumbnail);
                    layoutParams.addRule(RelativeLayout.ALIGN_RIGHT, R.id.thumbnail);
                    layoutParams.addRule(RelativeLayout.ALIGN_END, R.id.thumbnail);
                    itemViewHolder.llDescriptionBlock.setLayoutParams(layoutParams);
                } else {

                    // Setting up the drawable into image view.
                    itemViewHolder.imageView.setImageDrawable(mImageViewList.getDrawableIcon());
                    String description = mImageViewList.getAlbumDescription();

                    // Showing text view only for the description.
                    if (description != null && !description.isEmpty()) {
                        itemViewHolder.container.findViewById(R.id.main_view).setPadding(0, 0,
                                mActivity.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                                mActivity.getResources().getDimensionPixelSize(R.dimen.padding_5dp));
                        itemViewHolder.tvDescription.setVisibility(View.VISIBLE);

                        // When the attachment is video or file and contains the next line tag,
                        // Then increasing the max line limit to 2.
                        if (description.contains("</b><br/>")) {
                            itemViewHolder.tvDescription.setMaxLines(2);
                        }
                        itemViewHolder.tvDescription.setText(Html.fromHtml(description.trim()));
                    } else {
                        itemViewHolder.tvDescription.setVisibility(View.GONE);
                    }
                }

                itemViewHolder.ivCancelImage.setTag(position);
                // Apply click listener on the cancel image view, to remove the item from the list.
                if (mOnCancelClickListener != null) {
                    itemViewHolder.ivCancelImage.setVisibility(View.VISIBLE);
                    itemViewHolder.ivCancelImage.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            mOnCancelClickListener.onCancelButtonClicked((int) ((ViewHolder) viewHolder).ivCancelImage.getTag());
                        }
                    });
                }
            } else if (mIsStatusImage && mIsBitmapImage) {
                itemViewHolder.container.findViewById(R.id.main_view).setPadding(0,
                        mActivity.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0,
                        mActivity.getResources().getDimensionPixelSize(R.dimen.padding_5dp));
                if (!mIsPhotoAttachment) {
                    itemViewHolder.container.findViewById(R.id.main_view).getLayoutParams().width = ViewGroup.LayoutParams.WRAP_CONTENT;
                    Drawable drawable = ContextCompat.getDrawable(mActivity, R.drawable.ic_clear_grey);
                    drawable.setBounds(0, 0, mActivity.getResources().getDimensionPixelSize(R.dimen.margin_25dp),
                            mActivity.getResources().getDimensionPixelSize(R.dimen.margin_25dp));
                    itemViewHolder.tvCancel.setCompoundDrawables(null, drawable, null, null);
                }

                // Checking if the image is in bitmap form or in drawable form.
                if (mImageViewList.getmGridPhotoUrl() != null) {
                    // Setting up the bitmap into image view.
                    itemViewHolder.imageView.setImageBitmap(mImageViewList.getmGridPhotoUrl());
                }

                itemViewHolder.tvCancel.setTag(position);
                // Apply click listener on the cancel image view, to remove the item from the list.
                if (mOnCancelClickListener != null) {
                    itemViewHolder.tvCancel.setVisibility(View.VISIBLE);
                    itemViewHolder.tvCancel.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            mOnCancelClickListener.onCancelButtonClicked((int) ((ViewHolder) viewHolder).tvCancel.getTag());
                        }
                    });
                }
            } else {
                if (isAlbumView) {
                    if (mImageViewList.getImageViewHeight() == 0) {
                        int imageHeight = ((ViewHolder) viewHolder).imageViewHeight;
                        ((ViewHolder) viewHolder).imageView.getLayoutParams().height = imageHeight;
                        mImageViewList.setImageViewHeight(imageHeight);

                    } else {
                        ((ViewHolder) viewHolder).imageView.getLayoutParams().height = mImageViewList.getImageViewHeight();
                    }
                    ((ViewHolder) viewHolder).imageView.getLayoutParams().width = ((ViewHolder) viewHolder).imageViewWidth;
                    mImageLoader.setLightGreyPlaceHolder(mImageViewList.getmGridViewImageUrl(), ((ViewHolder) viewHolder).imageView);
                } else {
                    mImageLoader.setAlbumPhoto(mImageViewList.getmGridViewImageUrl(), ((ViewHolder) viewHolder).imageView);
                }
                if (mImageViewList.getmGridViewImageUrl() != null && !mImageViewList.getmGridViewImageUrl().isEmpty()
                        && mImageViewList.getmGridViewImageUrl().contains(".gif")) {
                    itemViewHolder.ivGifIcon.setVisibility(View.VISIBLE);
                } else {
                    itemViewHolder.ivGifIcon.setVisibility(View.GONE);
                }

                itemViewHolder.container.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mOnItemClickListener != null) {
                            mOnItemClickListener.onItemClick(v, position - 1);
                        }
                    }
                });
            }
        } else if (viewHolder instanceof HeaderViewHolder) {
            HeaderViewHolder headerViewHolder = (HeaderViewHolder) viewHolder;

            if (isAlbumView) {
                StaggeredGridLayoutManager.LayoutParams layoutParams = (StaggeredGridLayoutManager.LayoutParams) viewHolder.itemView.getLayoutParams();
                layoutParams.setFullSpan(true);
            }

            if (mList.getAlbumDescription() != null && mList.getAlbumDescription().length() > 0) {
                headerViewHolder.mViewDescription.setVisibility(View.VISIBLE);

                if (mList.getAlbumDescription().trim().length()
                        > ConstantVariables.ALBUM_DESCRIPTION_LENGTH){
                    String text=mList.getAlbumDescription().substring(0,ConstantVariables.ALBUM_DESCRIPTION_LENGTH)+"...";
                    final String fulltext=mList.getAlbumDescription();

                    final SpannableString ss = new SpannableString(text+ mActivity.getResources().getString(R.string.more));
                    int startIndex, endIndex;
                    startIndex = ss.length() - mActivity.getResources().getString(R.string.more).length();
                    endIndex = ss.length();

                    ClickableSpan span1 = new ClickableSpan() {
                        @Override
                        public void onClick(View textView) {

                            SpannableString ss1 = new SpannableString(fulltext + " " + mActivity.getResources().getString(R.string.readLess));
                            ClickableSpan span2 = new ClickableSpan() {
                                @Override
                                public void onClick(View textView) {

                                    headerViewHolder.mViewDescription.setText(ss);
                                    headerViewHolder.mViewDescription.setMovementMethod(LinkMovementMethod.getInstance());
                                }

                                @Override
                                public void updateDrawState(TextPaint ds) {
                                    super.updateDrawState(ds);
                                    ds.setUnderlineText(false);
                                    ds.setColor(ContextCompat.getColor(mActivity, R.color.dark_grey));
                                    ds.setFakeBoldText(true);
                                }
                            };
                            ss1.setSpan(span2, fulltext.length(), ss1.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);

                            headerViewHolder.mViewDescription.setText(ss1);
                            headerViewHolder.mViewDescription.setMovementMethod(LinkMovementMethod.getInstance());
                        }

                        @Override
                        public void updateDrawState(TextPaint ds) {
                            super.updateDrawState(ds);
                            ds.setUnderlineText(false);
                            ds.setColor(ContextCompat.getColor(mActivity, R.color.dark_grey));
                            ds.setFakeBoldText(true);
                        }
                    };
                    ss.setSpan(span1, startIndex, endIndex, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);

                    headerViewHolder.mViewDescription.setText(ss);
                    headerViewHolder.mViewDescription.setMovementMethod(LinkMovementMethod.getInstance());

                } else {
                    headerViewHolder.mViewDescription.setText(mList.getAlbumDescription());
                }

            } else {
                headerViewHolder.mViewDescription.setVisibility(View.GONE);
            }

            if (!isAlbumView) {
                headerViewHolder.mOwnerViewBlock.setVisibility(View.VISIBLE);
                mImageLoader.setImageForUserProfile(mList.getOwnerImageUrl(), headerViewHolder.mOwnerImageView);

                headerViewHolder.mOwnerTitleView.setText(mList.getOwnerTitle());
                headerViewHolder.mOwnerImageView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mOnUserLayoutClickListener != null) {
                            mOnUserLayoutClickListener.onUserLayoutClick();
                        }
                    }
                });
                headerViewHolder.mOwnerTitleView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mOnUserLayoutClickListener != null) {
                            mOnUserLayoutClickListener.onUserLayoutClick();
                        }
                    }
                });

            } else {
                headerViewHolder.mOwnerViewBlock.setVisibility(View.GONE);
                headerViewHolder.albumPrivacy.setTypeface(GlobalFunctions.getFontIconTypeFace(mActivity));

                if (mList.getAlbumTitle() != null && !mList.getAlbumTitle().isEmpty()) {
                    headerViewHolder.albumTitle.setVisibility(View.VISIBLE);
                    headerViewHolder.albumTitle.setText(mList.getAlbumTitle());
                } else {
                    headerViewHolder.albumTitle.setVisibility(View.GONE);
                }

                if (mList.getAlbumCreationDate() != null && !mList.getAlbumCreationDate().isEmpty()) {
                    headerViewHolder.albumCreationDate.setVisibility(View.VISIBLE);
                    String convertedDate = AppConstant.convertDateFormat(mActivity.getResources(), mList.getAlbumCreationDate());
                    String creationDate;
                    if (convertedDate.contains("ago")) {
                        creationDate = mActivity.getResources().getString(R.string.created_text) + " " + convertedDate;
                    } else {
                        creationDate = mActivity.getResources().getString(R.string.created_on_text) + " " + convertedDate;
                    }
                    headerViewHolder.albumCreationDate.setText(creationDate);
                } else {
                    headerViewHolder.albumCreationDate.setVisibility(View.GONE);
                }

                if (mList.getPrivacyObject() != null && mList.getPrivacyObject().length() > 0) {
                    List<SheetItemModel> mOptionsPrivacyList = new ArrayList<>();
                    Iterator iterator = mList.getPrivacyObject().keys();
                    while (iterator.hasNext()) {
                        String key = (String) iterator.next();
                        String value = mList.getPrivacyObject().optString(key);
                        if (value != null) {
                            mOptionsPrivacyList.add(new SheetItemModel(value, key));
                        }
                    }
                    mSheetAdapter = new SimpleSheetAdapter(mOptionsPrivacyList);
                    mSheetAdapter.setOnItemClickListener(new SimpleSheetAdapter.OnItemClickListener() {
                        @Override
                        public void onItemClick(SheetItemModel item, int position) {
                            mBottomSheetDialog.dismiss();
                            headerViewHolder.albumPrivacy.setText(Html.fromHtml(getPrivacyIcon(item.getKey()) + " " +item.getName()));
                            if (item.getKey() != null && mOnSheetItemClickListner != null) {
                                mOnSheetItemClickListner.onItemClick(item, position);
                            }
                        }
                    });
                }

                if (mList.getAlbumViewPrivacy() != null && !mList.getAlbumViewPrivacy().isEmpty() &&
                        mList.getPrivacyValue() != null && !mList.getPrivacyValue().isEmpty()) {
                    headerViewHolder.albumPrivacy.setVisibility(View.VISIBLE);
                    headerViewHolder.albumPrivacy.setText(Html.fromHtml(getPrivacyIcon(mList.getPrivacyValue()) + " " + mList.getAlbumViewPrivacy()));
                } else {
                    headerViewHolder.albumPrivacy.setVisibility(View.GONE);
                }

                headerViewHolder.albumPrivacy.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        int userId = 0;
                        if (PreferencesUtils.getUserDetail(mActivity) != null) {
                            try {
                                JSONObject userDetail = new JSONObject(PreferencesUtils.getUserDetail(mActivity));
                                userId = userDetail.optInt("user_id");
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            if (userId == mList.getmOwnerId()) {
                                View inflateView = LayoutInflater.from(mActivity).inflate(R.layout.fragmen_cart, null);
                                RecyclerView recyclerView = (RecyclerView) inflateView.findViewById(R.id.recycler_view);
                                inflateView.findViewById(R.id.cart_bottom).setVisibility(View.GONE);
                                recyclerView.getLayoutParams().height = RecyclerView.LayoutParams.WRAP_CONTENT;
                                recyclerView.setHasFixedSize(true);
                                recyclerView.setLayoutManager(new LinearLayoutManager(mActivity));
                                recyclerView.setAdapter(mSheetAdapter);
                                mBottomSheetDialog = new BottomSheetDialog(mActivity);
                                mBottomSheetDialog.setContentView(inflateView);
                                mBottomSheetDialog.show();
                            }
                        }
                    }
                });

                int padding = (int) mActivity.getResources().getDimension(R.dimen.padding_10dp);
                headerViewHolder.mViewDescription.setPadding(padding, 0, padding, padding);

                setLikeAndCommentCount(headerViewHolder);

                int reactionId = 0;
                String reactionIcon = null, caption = null;
                JSONObject mReactionsObject = mList.getmReactionObject();

                JSONObject reactionsData = mReactionsObject.optJSONObject("reactions");
                if (reactionsData != null) {
                    mReactionsEnabled = reactionsData.optInt("reactionsEnabled");
                    PreferencesUtils.updateReactionsEnabledPref(mActivity, mReactionsEnabled);
                    mAllReactionObject = reactionsData.optJSONObject("reactions");
                    PreferencesUtils.storeReactions(mActivity, mAllReactionObject);
                    if (mAllReactionObject != null) {
                        mReactionsArray = GlobalFunctions.sortReactionsObjectWithOrder(mAllReactionObject);
                    }

                    if (mReactionsEnabled == 1 && mAllReactionObject != null) {
                        reactionId = mAllReactionObject.optJSONObject("like").optInt("reactionicon_id");
                        reactionIcon = mAllReactionObject.optJSONObject("like").optJSONObject("icon").
                                optString("reaction_image_icon");
                    }
                }

                //show like count
                if (mList.getLikeCount() != 0) {
                    headerViewHolder.mLikeCount.setText(Integer.toString(mList.getLikeCount()));
                } else {
                    headerViewHolder.mLikeCount.setText("");
                }

                //show comment count
                if (mList.getCommentCount() != 0 ) {
                    headerViewHolder.mCommentButton.setText(Integer.toString(mList.getCommentCount()));
                } else {
                    headerViewHolder.mCommentButton.setText("");
                }

                    int finalReactionId = reactionId;
                    String finalReactionIcon = reactionIcon;
                    headerViewHolder.mLikeButton.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {

                        doLikeUnlike(null, false, finalReactionId, finalReactionIcon, caption, headerViewHolder);
                    }
                });

                headerViewHolder.mLikeButton.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        int[] location = new int[2];
                        List<ImageViewList> reactionsImages;
                        headerViewHolder.likeCommentBlock.getLocationOnScreen(location);

                        RecyclerView reactionsRecyclerView = CustomViews.getReactionPopupRecyclerView(mActivity);
                        LinearLayout tipLayout = CustomViews.getReactionPopupTipLinearLayout(mActivity);

                        LinearLayout linearLayout = new LinearLayout(mActivity);
                        linearLayout.setOrientation(LinearLayout.VERTICAL);
                        linearLayout.addView(reactionsRecyclerView);
                        linearLayout.addView(tipLayout);

                        final PopupWindow popUp = new PopupWindow(linearLayout, LinearLayout.LayoutParams.WRAP_CONTENT,
                                LinearLayout.LayoutParams.WRAP_CONTENT);
                        popUp.setTouchable(true);
                        popUp.setFocusable(true);
                        popUp.setOutsideTouchable(true);
                        popUp.setAnimationStyle(R.style.customDialogAnimation);

                        // Playing popup effect when user long presses on like button of a feed.
                        if (PreferencesUtils.isSoundEffectEnabled(mActivity)) {
                            SoundUtil.playSoundEffectOnReactionsPopup(mActivity);
                        }
                        popUp.showAtLocation(linearLayout, Gravity.TOP, location[0] - (int) mActivity.getResources().getDimension(R.dimen.reaction_popup_offset_x) ,
                                location[1] - (int) mActivity.getResources().getDimension(R.dimen.reaction_popup_pos_y));

                        if(mAllReactionObject != null && mReactionsArray != null) {

                            reactionsImages = new ArrayList<>();
                            for(int i = 0; i< mReactionsArray.size(); i++){
                                JSONObject reactionObject = mReactionsArray.get(i);
                                String reaction_image_url = reactionObject.optJSONObject("icon").
                                        optString("reaction_image_icon");
                                String caption = reactionObject.optString("caption");
                                String reaction = reactionObject.optString("reaction");
                                int reactionId = reactionObject.optInt("reactionicon_id");
                                String reactionIconUrl = reactionObject.optJSONObject("icon").
                                        optString("reaction_image_icon");
                                reactionsImages.add(new ImageViewList(reaction_image_url, caption,
                                        reaction, reactionId, reactionIconUrl));
                            }

                            ImageAdapter reactionsAdapter = new ImageAdapter((Activity) mActivity, reactionsImages, true,
                                    new OnItemClickListener() {
                                        @Override
                                        public void onItemClick(View view, int position) {

                                            ImageViewList imageViewList = reactionsImages.get(position);
                                            String reaction = imageViewList.getmReaction();
                                            String caption = imageViewList.getmCaption();
                                            String reactionIcon = imageViewList.getmReactionIcon();
                                            int reactionId = imageViewList.getmReactionId();
                                            popUp.dismiss();

                                            /**
                                             * If the user Presses the same reaction again then don't do anything
                                             */
                                            if(myReaction != null){
                                                if(myReaction.optInt("reactionicon_id") != reactionId){
                                                    doLikeUnlike(reaction, true, reactionId, reactionIcon, caption, headerViewHolder);
                                                }
                                            } else{
                                                doLikeUnlike(reaction, false, reactionId, reactionIcon, caption, headerViewHolder);
                                            }
                                        }
                                    });

                            reactionsRecyclerView.setAdapter(reactionsAdapter);
                        }
                        return false;
                    }
                });

                headerViewHolder.mLikeCount.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {

                        String mViewLikesUrl = UrlUtil.AAF_VIEW_REACTIONS_URL + "?subject_type=" + mSubjectType + "&subject_id=" + mList.getmSubjectId();

                        Intent viewAllLikesIntent = new Intent(mActivity, Likes.class);
                        viewAllLikesIntent.putExtra("ViewAllLikesUrl", mViewLikesUrl);
                        viewAllLikesIntent.putExtra("reactionsEnabled", mReactionsEnabled);
                        mActivity.startActivity(viewAllLikesIntent);
                        mActivity.overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                });

                headerViewHolder.mCommentButton.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {

                        JSONObject mContentReactions = mList.getmReactionObject().optJSONObject("feed_reactions");

                        String likeCommentsUrl = AppConstant.DEFAULT_URL + "likes-comments?subject_type="
                                + mSubjectType + "&subject_id=" + mList.getmSubjectId() +
                                "&viewAllComments=1&page=1&limit=" + AppConstant.LIMIT;
                        Intent commentIntent = new Intent(mActivity, Comment.class);
                        commentIntent.putExtra("LikeCommentUrl", likeCommentsUrl);
                        commentIntent.putExtra(ConstantVariables.SUBJECT_TYPE, mSubjectType);
                        commentIntent.putExtra(ConstantVariables.SUBJECT_ID, mList.getmSubjectId());
                        commentIntent.putExtra("commentCount", mList.getCommentCount());
                        commentIntent.putExtra("reactionsEnabled", mReactionsEnabled);
                        if(mContentReactions != null){
                            commentIntent.putExtra("popularReactions", mContentReactions.toString());
                        }
                        mActivity.startActivityForResult(commentIntent, ConstantVariables.VIEW_COMMENT_PAGE_CODE);
                        mActivity.overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                });

                if (mList.getmAlbumGutterMenu() == null){
                    headerViewHolder.shareView.setVisibility(View.GONE);
                }

                headerViewHolder.mShareButton.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {

                        if(mList.getmAlbumGutterMenu() != null && mList.getmAlbumGutterMenu().length() > 0){
                            for (int i = 0; i < mList.getmAlbumGutterMenu().length(); i++) {
                                try {
                                    JSONObject mMenuJsonObject = mList.getmAlbumGutterMenu().getJSONObject(i);
                                    if (mMenuJsonObject.optString("name").equals("share")) {
                                        String type = mMenuJsonObject.optJSONObject("urlParams").optString("type");
                                        String shareUrl = AppConstant.DEFAULT_URL + mMenuJsonObject.optString("url") + "?id=" + mList.getmSubjectId() + "&type=" + type;
                                        socialShareUtil.sharePost(headerViewHolder.mShareButton, mMenuJsonObject.optString("label"), mList.getmAlbumCover(), shareUrl,
                                                type, mList.getmContentUrl());
                                    }
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    }
                });

            }

        } else {
            ProgressViewHolder.inflateProgressBar(((ProgressViewHolder) viewHolder).progressView);
            if (isAlbumView) {
                StaggeredGridLayoutManager.LayoutParams layoutParams = (StaggeredGridLayoutManager.LayoutParams) ((ProgressViewHolder) viewHolder).itemView.getLayoutParams();
                layoutParams.setFullSpan(true);
            }
        }
    }

    // END_INCLUDE(recyclerViewOnBindViewHolder)

    @Override
    public int getItemViewType(int position) {

        // Hiding header for the subject type = sitereview_album and for the profile/cover update.
        if (position < 1 && mBundle == null && !mSubjectType.equals("sitereview_album")) {
            return TYPE_HEADER;
        } else if (getItem(position) == null) {
            return TYPE_PROGRESS;
        } else {
            return TYPE_ITEM;
        }
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        if (mBundle == null && !mSubjectType.equals("sitereview_album")) {
            return mPhotoList.size() + 1;
        } else {
            return mPhotoList.size();
        }
    }

    private ImageViewList getItem(int position) {
        if (mBundle == null && !mSubjectType.equals("sitereview_album")) {
            return mPhotoList.get(position - 1);
        } else {
            return mPhotoList.get(position);
        }
    }
    // BEGIN_INCLUDE(recyclerViewSampleViewHolder)

    private void setLikeAndCommentCount(HeaderViewHolder headerViewHolder) {

        if(mAppConst.isLoggedOutUser() || mBundle != null || mSubjectType.equals("sitereview_album")){
            headerViewHolder.likeCommentBlock.setVisibility(View.GONE);

        } else {
            headerViewHolder.likeCommentBlock.setVisibility(View.VISIBLE);
            headerViewHolder.mLikeCount.setVisibility(View.VISIBLE);
            headerViewHolder.mLikeCount.setTextColor(ContextCompat.getColor(mActivity, R.color.grey_dark));
            if(!mList.getIsLike()){
                headerViewHolder.mLikeButton.setTextColor(ContextCompat.getColor(mActivity, R.color.grey_dark));
            }else{
                headerViewHolder.mLikeButton.setTextColor(ContextCompat.getColor(mActivity, R.color.themeButtonColor));
            }

            mReactionsEnabled = PreferencesUtils.getReactionsEnabled(mActivity);
            // Check if Reactions is enabled, show that content reaction and it's icon here.
            if(mReactionsEnabled == 1 && mList.getmReactionObject() != null && mList.getmReactionObject().length() != 0){

                myReaction = mList.getmReactionObject().optJSONObject("my_feed_reaction");

                if(myReaction != null && myReaction.length() != 0){
                    String reactionImage = myReaction.optString("reaction_image_icon");
                    mImageLoader.setImageUrl(reactionImage, headerViewHolder.mReactionImage);
                    headerViewHolder.mLikeButton.setCompoundDrawablesWithIntrinsicBounds(
                            null, null, null, null);
                    headerViewHolder.mReactionImage.setVisibility(View.VISIBLE);
                } else {
                    headerViewHolder.mReactionImage.setVisibility(View.GONE);
                    headerViewHolder.mLikeButton.setCompoundDrawablesWithIntrinsicBounds(
                            ContextCompat.getDrawable(mActivity, R.drawable.ic_like_chat),
                            null, null, null);
                    headerViewHolder.mLikeButton.setTextColor(
                            ContextCompat.getColor(mActivity, R.color.grey_dark));
                }
            } else {
                headerViewHolder.mLikeButton.setCompoundDrawablesWithIntrinsicBounds(
                        ContextCompat.getDrawable(mActivity, R.drawable.ic_like_chat),
                        null, null, null);
                headerViewHolder.mLikeButton.setTextColor(
                        ContextCompat.getColor(mActivity, R.color.grey_dark));
            }
        }
    }

    private void doLikeUnlike(String reaction, final boolean isReactionChanged, final int reactionId,
                              final String reactionIcon, final String caption, HeaderViewHolder headerViewHolder){
        String sendLikeNotificationUrl, mLikeUnlikeUrl;

        if (PreferencesUtils.isNestedCommentEnabled(mActivity)) {
            sendLikeNotificationUrl = AppConstant.DEFAULT_URL + "advancedcomments/send-like-notitfication";
        } else {
            sendLikeNotificationUrl = AppConstant.DEFAULT_URL + "send-notification";
        }

        //setting up font icons
        headerViewHolder.mLikeButton.setTypeface(GlobalFunctions.getFontIconTypeFace(mActivity));
        headerViewHolder.mLikeButton.setText("\uf110");
        headerViewHolder.mLikeButton.setCompoundDrawablesWithIntrinsicBounds(
                null, null, null, null);
        headerViewHolder.mLikeCount.setVisibility(View.GONE);
        headerViewHolder.mReactionImage.setVisibility(View.GONE);
        final Map<String, String> likeParams = new HashMap<>();
        likeParams.put(ConstantVariables.SUBJECT_TYPE, mSubjectType);
        likeParams.put(ConstantVariables.SUBJECT_ID, String.valueOf(mList.getmSubjectId()));

        if(reaction != null){
            likeParams.put("reaction", reaction);
        }

        if(!mList.getIsLike() || isReactionChanged){
            if(mReactionsEnabled ==  1 && PreferencesUtils.isNestedCommentEnabled(mActivity)){
                mLikeUnlikeUrl = AppConstant.DEFAULT_URL + "advancedcomments/like?sendNotification=0";
            } else{
                mLikeUnlikeUrl = AppConstant.DEFAULT_URL + "like";
            }
        } else{
            mLikeUnlikeUrl = AppConstant.DEFAULT_URL + "unlike";
        }

        mAppConst.postJsonResponseForUrl(mLikeUnlikeUrl, likeParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                headerViewHolder.mLikeButton.setTypeface(null);
                headerViewHolder.mLikeCount.setTypeface(null);
                headerViewHolder.mLikeButton.setText("");
                // Set My FeedReaction Changed
                if( mReactionsEnabled == 1){
                    /* If a Reaction is posted or a reaction is changed on content
                       put the updated reactions in my feed reactions array
                     */
                    updateContentReactions(reactionId, reactionIcon, caption, mList.getIsLike(), isReactionChanged);

                    /* Calling to send notifications after like action */
                    if (!mList.getIsLike()) {
                        mAppConst.postJsonResponseForUrl(sendLikeNotificationUrl, likeParams, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                            }
                        });
                    }
                }
                /*Increase Like Count if content is liked else
                 decrease like count if the content is unliked
                 Do not need to increase/decrease the like count when it is already liked and only reaction is changed.
                  */
                if(!mList.getIsLike()){
                    mList.setLikeCount(mList.getLikeCount() + 1);
                } else if( !isReactionChanged){
                    mList.setLikeCount(mList.getLikeCount() - 1);
                }

                //show like count
                if (mList.getLikeCount() != 0) {
                    headerViewHolder.mLikeCount.setText(Integer.toString(mList.getLikeCount()));
                } else {
                    headerViewHolder.mLikeCount.setText("");
                }

                // Toggle isLike Variable if reaction is not changed
                if( !isReactionChanged) {
                    mList.setIsLike(!(mList.getIsLike()));
                }

                setLikeAndCommentCount(headerViewHolder);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                headerViewHolder.mLikeButton.setTypeface(null);
                headerViewHolder.mLikeCount.setTypeface(null);
                setLikeAndCommentCount(headerViewHolder);
            }
        });
    }

    private void updateContentReactions(int reactionId, String reactionIcon, String caption,
                                        boolean isLiked, boolean isReactionChanged){

        JSONObject mContentReactions = mList.getmReactionObject().optJSONObject("feed_reactions");
        try{

            // Update the count of previous reaction in reactions object and remove the my_feed_reactions
            if(isLiked){
                if(myReaction != null && mContentReactions != null){
                    int myReactionId = myReaction.optInt("reactionicon_id");
                    if(mContentReactions.optJSONObject(String.valueOf(myReactionId)) != null){
                        int myReactionCount = mContentReactions.optJSONObject(String.valueOf(myReactionId)).
                                optInt("reaction_count");
                        if((myReactionCount - 1) <= 0){
                            mContentReactions.remove(String.valueOf(myReactionId));
                        } else {
                            mContentReactions.optJSONObject(String.valueOf(myReactionId)).put("reaction_count",
                                    myReactionCount - 1);
                        }
                        mList.getmReactionObject().put("feed_reactions", mContentReactions);
                    }
                }
                mList.getmReactionObject().put("my_feed_reaction", null);
            }

            // Update the count of current reaction in reactions object and set new my_feed_reactions object.
            if(!isLiked || isReactionChanged){
                // Set the updated my Reactions

                JSONObject jsonObject = new JSONObject();
                jsonObject.putOpt("reactionicon_id", reactionId);
                jsonObject.putOpt("reaction_image_icon", reactionIcon);
                jsonObject.putOpt("caption", caption);
                mList.getmReactionObject().put("my_feed_reaction", jsonObject);

                if (mContentReactions != null) {
                    if (mContentReactions.optJSONObject(String.valueOf(reactionId)) != null) {
                        int reactionCount = mContentReactions.optJSONObject(String.valueOf(reactionId)).optInt("reaction_count");
                        mContentReactions.optJSONObject(String.valueOf(reactionId)).putOpt("reaction_count", reactionCount + 1);
                    } else {
                        jsonObject.put("reaction_count", 1);
                        mContentReactions.put(String.valueOf(reactionId), jsonObject);
                    }
                } else {
                    mContentReactions = new JSONObject();
                    jsonObject.put("reaction_count", 1);
                    mContentReactions.put(String.valueOf(reactionId), jsonObject);
                }
                mList.getmReactionObject().put("feed_reactions", mContentReactions);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    public String getPrivacyIcon(String name) {
        String icon = null;
        switch (name) {
            case "everyone":
                icon = "\uf0ac";
                break;
            case "owner_network":
                icon = "\uf0c0";
                break;
            case "owner_member":
                icon = "\uf007";
                break;
            case "owner":
                icon = "\uf023";
                break;
            case "owner_member_member":
                icon = "\uf0c0";
                break;
            case "registered":
                icon = "\uf007";
                break;
        }
        return icon;
    }

    /**
     * Provide a reference to the type of views that you are using (custom ViewHolder)
     */
    public static class ViewHolder extends RecyclerView.ViewHolder {

        private ImageView imageView, ivCancelImage, ivGifIcon;
        private TextView tvDescription;
        public ImageViewList holderImageList;
        private RelativeLayout llDescriptionBlock;
        public TextView tvCancel;
        public View container;
        public static int mSelectedPosition;
        public int imageViewHeight, imageViewWidth;

        public ViewHolder(View v, int imageWidth, boolean isAlbumView) {
            super(v);

            container = v;
            imageView = (ImageView) v.findViewById(R.id.thumbnail);
            ivGifIcon = (ImageView) v.findViewById(R.id.gif_icon);
            tvCancel = (TextView) v.findViewById(R.id.btn_image_remove);
            imageViewWidth = RelativeLayout.LayoutParams.MATCH_PARENT;
            imageViewHeight = AppConstant.getRandomNumber((int) imageView.getContext().getResources().getDimension(R.dimen.dimen_180dp), (int) imageView.getContext().getResources().getDimension(R.dimen.dimen_120dp));
            if (!isAlbumView) {
                imageView.setLayoutParams(CustomViews.getCustomWidthHeightRelativeLayoutParams(imageWidth, imageWidth));
            }
            ivCancelImage = (ImageView) v.findViewById(R.id.image_remove);
            tvDescription = (TextView) v.findViewById(R.id.image_desc);
            llDescriptionBlock = (RelativeLayout) v.findViewById(R.id.description_block);

        }

    }
    // END_INCLUDE(recyclerViewSampleViewHolder)

    public static class HeaderViewHolder extends RecyclerView.ViewHolder {

        BezelImageView mOwnerImageView;
        private TextView mOwnerTitleView;
        private SelectableTextView mViewDescription, albumTitle, albumCreationDate, albumPrivacy;
        public View mUserView;
        private LinearLayout mOwnerViewBlock, albumDetailsBlock, likeCommentBlock, likeView, commentView, shareView;
        ActionIconThemedTextView mLikeButton, mCommentButton, mShareButton, mLikeCount;
        ImageView mReactionImage;

        public HeaderViewHolder(View v) {
            super(v);
            mUserView = v;
            mOwnerViewBlock = v.findViewById(R.id.owner_view_block);
            mOwnerImageView = (BezelImageView) v.findViewById(R.id.owner_image);
            mOwnerTitleView = (TextView) v.findViewById(R.id.owner_title);
            albumDetailsBlock = v.findViewById(R.id.album_details_block);
            albumTitle = v.findViewById(R.id.album_title);
            albumCreationDate = v.findViewById(R.id.album_date);
            albumPrivacy = v.findViewById(R.id.album_privacy);

            likeCommentBlock = v.findViewById(R.id.like_comment_block);
            mShareButton = v.findViewById(R.id.share_button);
            mLikeButton = v.findViewById(R.id.like_button);
            mCommentButton = v.findViewById(R.id.comment_button);
            mLikeCount = v.findViewById(R.id.like_count);
            likeView = v.findViewById(R.id.like_view);
            commentView = v.findViewById(R.id.comment_view);
            shareView = v.findViewById(R.id.share_view);
            mReactionImage = v.findViewById(R.id.reactionIcon);
            mViewDescription = (SelectableTextView) v.findViewById(R.id.view_description);

        }
    }

}
