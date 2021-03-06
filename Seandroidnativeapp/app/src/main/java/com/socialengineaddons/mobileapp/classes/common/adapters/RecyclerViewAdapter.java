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
import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.ads.NativeAd;
import com.google.android.gms.ads.formats.NativeAppInstallAd;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.ads.admob.AdMobViewHolder;
import com.socialengineaddons.mobileapp.classes.common.ads.FacebookAdViewHolder;
import com.socialengineaddons.mobileapp.classes.common.ads.communityAds.CommunityAdsHolder;
import com.socialengineaddons.mobileapp.classes.common.ads.communityAds.RemoveAdHolder;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemDeleteListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnMenuClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.viewholder.ProgressViewHolder;
import com.socialengineaddons.mobileapp.classes.common.utils.CommunityAdsList;
import com.socialengineaddons.mobileapp.classes.common.utils.CurrencyUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SlideShowListItems;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.modules.store.ui.CircleIndicator;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class RecyclerViewAdapter extends RecyclerView.Adapter implements OnMenuClickResponseListener {

    public static final int VIEW_PROG = 0;
    public static final int VIEW_ITEM = 1;
    public static final int TYPE_FB_AD = 2;
    public static final int HEADER_TYPE = 3;
    public static final int TYPE_ADMOB = 4;
    public static final int TYPE_COMMUNITY_ADS = 5;
    public static final int REMOVE_COMMUNITY_ADS = 6;


    private List<Object> mBrowseItemList;
    private boolean isBrowsePage, isShowHeader;
    private BrowseListItems mListItem, mBrowseList;
    private String currentSelectedOption;
    private Typeface fontIcon;
    private Context mContext;
    private OnItemClickListener mOnItemClickListener;
    private OnItemDeleteListener mOnItemDeleteListener;
    private Fragment mCallingFragment;
    private int mMLTViewType;
    private GutterMenuUtils mGutterMenuUtils;
    private int placementCount, adType;
    private ImageLoader mImageLoader;
    public static ArrayList<Integer> mRemoveAds;
    private String[] ignoreModules = {"core_main_siteevent", "core_main_sitestoreproduct",
            ConstantVariables.ADV_VIDEO_MENU_TITLE,
            ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE,
            ConstantVariables.CROWD_FUNDING_MAIN_TITLE,
            ConstantVariables.SITE_PAGE_MENU_TITLE,
            ConstantVariables.SITE_PAGE_TITLE_MENU,
            ConstantVariables.ADV_GROUPS_MENU_TITLE,
            ConstantVariables.STORE_MENU_TITLE, "downloadable_product"};


    public RecyclerViewAdapter(Context context, List<Object> listItem, boolean isBrowsePage, boolean isShowHeader, int mltViewType,
                               String currentSelectedOption, OnItemClickListener onItemClickListener) {

        mOnItemClickListener = onItemClickListener;
        this.mContext = context;
        this.mBrowseItemList = listItem;
        this.isBrowsePage = isBrowsePage;
        this.isShowHeader = isShowHeader;
        this.mMLTViewType = mltViewType;
        //Fetch Current Selected Module
        this.currentSelectedOption = currentSelectedOption;
        fontIcon = GlobalFunctions.getFontIconTypeFace(mContext);
        mGutterMenuUtils = new GutterMenuUtils(context);
        mImageLoader = new ImageLoader(mContext);
        mRemoveAds = new ArrayList<>();
    }

    public RecyclerViewAdapter(Context context, List<Object> listItem, boolean isBrowsePage, int mltViewType,
                               BrowseListItems browseListItems, String currentSelectedOption,
                               OnItemClickListener onItemClickListener, OnItemDeleteListener onItemDeleteListener) {

        mOnItemClickListener = onItemClickListener;
        mOnItemDeleteListener = onItemDeleteListener;
        this.mContext = context;
        this.mBrowseItemList = listItem;
        this.isBrowsePage = isBrowsePage;
        this.mMLTViewType = mltViewType;
        mBrowseList = browseListItems;
        //Fetch Current Selected Module
        this.currentSelectedOption = currentSelectedOption;
        fontIcon = GlobalFunctions.getFontIconTypeFace(mContext);
        mGutterMenuUtils = new GutterMenuUtils(context);
        mImageLoader = new ImageLoader(mContext);
        mRemoveAds = new ArrayList<>();

    }

    public RecyclerViewAdapter(Context context, List<Object> listItem, boolean isBrowsePage, int mltViewType,
                               String currentSelectedOption, Fragment callingFragment,
                               OnItemClickListener onItemClickListener) {

        mOnItemClickListener = onItemClickListener;
        this.mContext = context;
        this.mBrowseItemList = listItem;
        this.isBrowsePage = isBrowsePage;
        this.mMLTViewType = mltViewType;
        //Fetch Current Selected Module
        this.currentSelectedOption = currentSelectedOption;
        mCallingFragment = callingFragment;
        fontIcon = GlobalFunctions.getFontIconTypeFace(mContext);
        mGutterMenuUtils = new GutterMenuUtils(context);
        mImageLoader = new ImageLoader(mContext);
        mRemoveAds = new ArrayList<>();
    }

    @Override
    public int getItemViewType(int position) {
        // Header on 0th Position
        if ((currentSelectedOption.equals("sitereview_wishlist") && mBrowseItemList.get(position) instanceof String) ||
                (currentSelectedOption.equals("sitereview_listing") && position == 0 && isShowHeader &&
                        mBrowseItemList.get(position) instanceof BrowseListItems)) {
            return HEADER_TYPE;
        } else if (mBrowseItemList.get(position) instanceof BrowseListItems) {
            return VIEW_ITEM;
        } else if (mBrowseItemList.get(position) != null && !mBrowseItemList.get(position).
                equals(ConstantVariables.FOOTER_TYPE)) {

            if(mRemoveAds.size() != 0 && mRemoveAds.contains(position)){
                return REMOVE_COMMUNITY_ADS;
            } else {
                switch (currentSelectedOption){

                    case "core_main_music":
                        placementCount = ConstantVariables.MUSIC_ADS_POSITION;
                        adType = ConstantVariables.MUSIC_ADS_TYPE;
                        break;

                    case "core_main_classified":
                        placementCount = ConstantVariables.CLASSIFIED_ADS_POSITION;
                        adType = ConstantVariables.CLASSIFIED_ADS_TYPE;
                        break;

                    case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                        placementCount = ConstantVariables.ADV_VIDEO_ADS_POSITION;
                        adType = ConstantVariables.ADV_VIDEO_ADS_TYPE;
                        break;

                    case "sitereview_listing":
                    case "sitereview_wishlist":
                        placementCount = ConstantVariables.MLT_ADS_POSITION;
                        adType = ConstantVariables.MLT_ADS_TYPE;
                        break;

                    case "core_main_album":
                        placementCount = ConstantVariables.ALBUM_ADS_POSITION;
                        adType = ConstantVariables.ALBUM_ADS_TYPE;
                        break;
                }

                switch (adType){
                    case 0:
                        return TYPE_FB_AD;
                    case 1:
                        return TYPE_ADMOB;
                    default:
                        return TYPE_COMMUNITY_ADS;
                }
            }
        } else {
            return VIEW_PROG;
        }
    }

    @Override
    public int getItemCount() {
        return mBrowseItemList.size();
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        RecyclerView.ViewHolder viewHolder = null;
        View itemView = null;
        switch (viewType) {
            case VIEW_ITEM:
                switch (currentSelectedOption) {
                    case "core_main_classified":
                    case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.card_item_view, parent, false);
                        break;
                    case "sitereview_listing":
                    case "sitereview_wishlist":
                        switch (mMLTViewType) {
                            case ConstantVariables.LIST_VIEW:
                                itemView = LayoutInflater.from(parent.getContext()).inflate(
                                        R.layout.list_row, parent, false);
                                break;
                            case ConstantVariables.GRID_VIEW:
                                itemView = LayoutInflater.from(parent.getContext()).inflate(
                                        R.layout.list_event_info, parent, false);
                                break;
                            case ConstantVariables.MATRIX_VIEW:
                                itemView = LayoutInflater.from(parent.getContext()).inflate(
                                        R.layout.card_item_view, parent, false);
                                break;
                        }
                        break;
                    case "core_main_album":
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.album_item_view, parent, false);
                        break;
                    case "core_main_music":
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.card_item_view, parent, false);
                        break;
                    case "core_main_sitestoreproduct":
                    case "core_main_siteevent":
                    case ConstantVariables.ADV_VIDEO_MENU_TITLE:
                    case ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE:
                    case ConstantVariables.CROWD_FUNDING_MAIN_TITLE:
                    case ConstantVariables.SITE_PAGE_TITLE_MENU:
                    case ConstantVariables.SITE_PAGE_MENU_TITLE:
                    case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.category_grid_view, parent, false);
                        break;
                    case ConstantVariables.STORE_MENU_TITLE:
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.shipping_list_item, parent, false);
                        break;
                    case "downloadable_product":
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.downloadable_product_list_item, parent, false);
                        break;

                }

                viewHolder = new ItemViewHolder(itemView, currentSelectedOption, mMLTViewType, mContext);
                break;
            case TYPE_FB_AD:
                switch (currentSelectedOption) {
                    case "core_main_music":
                    case "core_main_classified":
                    case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                    case "core_main_album":
                        itemView = LayoutInflater.
                                from(parent.getContext()).
                                inflate(R.layout.fb_ad_item_card_grid, parent, false);
                        break;
                    case "sitereview_listing":
                    case "sitereview_wishlist":
                        switch (mMLTViewType) {
                            case ConstantVariables.LIST_VIEW:
                                itemView = LayoutInflater.
                                        from(parent.getContext()).
                                        inflate(R.layout.fb_ads_item_list, parent, false);
                                break;
                            case ConstantVariables.GRID_VIEW:
                                itemView = LayoutInflater.
                                        from(parent.getContext()).
                                        inflate(R.layout.feeds_ad_item_card, parent, false);
                                break;
                            case ConstantVariables.MATRIX_VIEW:
                                itemView = LayoutInflater.
                                        from(parent.getContext()).
                                        inflate(R.layout.fb_ad_item_card_grid, parent, false);
                                break;
                        }

                        break;
                }
                if(itemView != null){
                    viewHolder = new FacebookAdViewHolder(itemView);
                }
                break;

            case TYPE_COMMUNITY_ADS:
                switch (currentSelectedOption) {
                    case "core_main_music":
                    case "core_main_classified":
                    case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                        itemView = LayoutInflater.
                                from(parent.getContext()).
                                inflate(R.layout.community_ads_item_card, parent, false);
                        break;
                    case "sitereview_listing":
                    case "sitereview_wishlist":
                        switch (mMLTViewType) {
                            case ConstantVariables.LIST_VIEW:
                                itemView = LayoutInflater.
                                        from(parent.getContext()).
                                        inflate(R.layout.community_ad_item_list, parent, false);
                                break;
                            case ConstantVariables.GRID_VIEW:
                                itemView = LayoutInflater.
                                        from(parent.getContext()).
                                        inflate(R.layout.community_content_ad, parent, false);
                                break;
                            case ConstantVariables.MATRIX_VIEW:
                                itemView = LayoutInflater.
                                        from(parent.getContext()).
                                        inflate(R.layout.community_ads_item_card, parent, false);
                                break;
                        }

                        break;
                    case "core_main_album":
                        itemView = LayoutInflater.
                                from(parent.getContext()).
                                inflate(R.layout.community_content_ad, parent, false);
                        break;
                }
                if(itemView != null){
                    viewHolder = new CommunityAdsHolder(this, itemView, placementCount, adType, mRemoveAds);
                }
                break;

            case TYPE_ADMOB:
                switch (currentSelectedOption) {
                    case "core_main_music":
                    case "core_main_classified":
                    case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                        itemView = LayoutInflater.
                                from(parent.getContext()).
                                inflate(R.layout.admob_install_card, parent, false);
                        viewHolder = new AdMobViewHolder(itemView);
                        break;
                    case "sitereview_listing":
                    case "sitereview_wishlist":
                        switch (mMLTViewType) {
                            case ConstantVariables.LIST_VIEW:
                                itemView = LayoutInflater.
                                        from(parent.getContext()).
                                        inflate(R.layout.admob_install_list, parent, false);
                                viewHolder = new AdMobViewHolder(itemView);
                                break;
                            case ConstantVariables.GRID_VIEW:
                                itemView = LayoutInflater.
                                        from(parent.getContext()).
                                        inflate(R.layout.admob_ad_install, parent, false);
                                viewHolder = new AdMobViewHolder(itemView);
                                break;
                            case ConstantVariables.MATRIX_VIEW:
                                itemView = LayoutInflater.
                                        from(parent.getContext()).
                                        inflate(R.layout.admob_install_card, parent, false);
                                viewHolder = new AdMobViewHolder(itemView);
                                break;
                        }

                        break;
                    case "core_main_album":
                        itemView = LayoutInflater.
                                from(parent.getContext()).
                                inflate(R.layout.admob_ad_install, parent, false);
                        viewHolder = new AdMobViewHolder(itemView);
                        break;
                }
                break;
            case HEADER_TYPE:

                if (currentSelectedOption.equals("sitereview_listing")) {
                    itemView = LayoutInflater.from(parent.getContext()).inflate(
                            R.layout.slide_show_header, parent, false);
                } else {
                    itemView = LayoutInflater.from(parent.getContext()).inflate(
                            R.layout.simple_text_view, parent, false);
                }
                viewHolder = new HeaderViewHolder(itemView, currentSelectedOption);

                break;
            case REMOVE_COMMUNITY_ADS:
                viewHolder =  new RemoveAdHolder(this, LayoutInflater.from(parent.getContext()).inflate(R.layout.remove_ads_layout,
                        parent, false), mRemoveAds, mBrowseItemList);
                break;
            default:
                View view = LayoutInflater.from(parent.getContext()).inflate(
                        R.layout.progress_item, parent, false);
                viewHolder = new ProgressViewHolder(view);
                break;

        }
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, int position) {
        switch (holder.getItemViewType()) {
            case VIEW_ITEM:
                mListItem = (BrowseListItems) mBrowseItemList.get(position);

                ((ItemViewHolder) holder).listItem = mListItem;
                ((ItemViewHolder) holder).mContentTitle.setText(mListItem.getmBrowseListTitle());

                ((ItemViewHolder) holder).container.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mOnItemClickListener.onItemClick(v, holder.getAdapterPosition());
                    }
                });

                switch (currentSelectedOption) {
                    case "core_main_classified":

                        ((ItemViewHolder) holder).itemDesc.setVisibility(View.GONE);
                        ((ItemViewHolder) holder).mCloseIcon.setTypeface(fontIcon);
                        mImageLoader.setImageUrl(mListItem.getmBrowseImgUrl(), ((ItemViewHolder) holder).itemImage);

                        if (mListItem.getmIsClosed() == 1) {
                            ((ItemViewHolder) holder).mCloseIcon.setVisibility(View.VISIBLE);
                            ((ItemViewHolder) holder).mCloseIcon.setText("\uf023");
                        } else {
                            ((ItemViewHolder) holder).mCloseIcon.setVisibility(View.GONE);
                        }

                        break;

                    case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                        ((ItemViewHolder) holder).tvVideoCount.setVisibility(View.VISIBLE);
                        ((ItemViewHolder) holder).itemDesc.setVisibility(View.GONE);
                        mImageLoader.setVideoImage(mListItem.getmBrowseImgUrl(), ((ItemViewHolder) holder).itemImage);
                        ((ItemViewHolder) holder).tvVideoCount.setText(mContext.getResources().
                                getQuantityString(R.plurals.video_counts, mListItem.getVideosCount(),
                                        mListItem.getVideosCount()));
                        break;

                    case "core_main_album":
                        ItemViewHolder albumViewHolder = ((ItemViewHolder) holder);
                        if(position == 0 && mListItem.getmBrowseImgUrl() != null && mListItem.getmBrowseImgUrl()
                                .equals(ConstantVariables.KEY_CREATE_NEW_ALBUM)) {
                            albumViewHolder.itemImage.setVisibility(View.GONE);
                            albumViewHolder.mPhotoCount.setVisibility(View.GONE);
                            albumViewHolder.ivAddAlbum.setVisibility(View.VISIBLE);
                            Drawable addAlbumBackground = ContextCompat.getDrawable(mContext, R.drawable.view_rounded_border).mutate();
                            addAlbumBackground.setColorFilter(ContextCompat.getColor(mContext, R.color.gray_light),
                                    PorterDuff.Mode.SRC_IN);
                            albumViewHolder.rlPhotoWrapper.setBackground(addAlbumBackground);
                            albumViewHolder.ivAddAlbum.setColorFilter(ContextCompat.getColor(mContext, R.color.colorPrimary),
                                    PorterDuff.Mode.SRC_IN);

                        } else {
                            mImageLoader.setProductCoverImage(mListItem.getmBrowseImgUrl(), albumViewHolder.itemImage);
                            albumViewHolder.mOwnerName.setText(mListItem.getmBrowseListOwnerTitle());
                            albumViewHolder.mCommentCount.setText(String.valueOf(mListItem.getmCommentCount()));
                            String quantityPhoto = mContext.getResources().
                                    getQuantityString(R.plurals.photos_count, mListItem.getmPhotoCount(),
                                            mListItem.getmPhotoCount());
                            albumViewHolder.mPhotoCount.setText(quantityPhoto);
                            albumViewHolder.mLikeCount.setText(String.valueOf(mListItem.getmLikeCount()));
                            albumViewHolder.mLikeIcon.setTypeface(fontIcon);
                            albumViewHolder.mLikeIcon.setText("\uf164");
                            albumViewHolder.mCommentIcon.setTypeface(fontIcon);
                            albumViewHolder.mCommentIcon.setText("\uf075");
                            albumViewHolder.rlPhotoWrapper.setBackground(null);
                            albumViewHolder.ivAddAlbum.setVisibility(View.GONE);
                            albumViewHolder.itemImage.setVisibility(View.VISIBLE);
                            albumViewHolder.mPhotoCount.setVisibility(View.VISIBLE);
                        }


                        break;

                    case "core_main_music":
                        String quantityPlay = mContext.getResources().
                                getQuantityString(R.plurals.play_count,
                                        mListItem.getTotalPlayCount(),
                                        mListItem.getTotalPlayCount()
                                );
                        ((ItemViewHolder) holder).mPlayIcon.setVisibility(View.VISIBLE);
                        ((ItemViewHolder) holder).itemDesc.setText(" " + quantityPlay);
                        mImageLoader.setMusicImage(mListItem.getArtistImageUrl(), ((ItemViewHolder) holder).itemImage);
                        break;
                    case "sitereview_listing":
                    case "sitereview_wishlist":
                        String creationDate = AppConstant.convertDateFormat(mContext.getResources(),
                                mListItem.getmBrowseListCreationDate());
                        ((ItemViewHolder) holder).itemDesc.setVisibility(View.VISIBLE);
                        if (mListItem.getmSponsored() == 1) {
                            ((ItemViewHolder) holder).mSponsored.setVisibility(View.VISIBLE);
                        } else {
                            ((ItemViewHolder) holder).mSponsored.setVisibility(View.GONE);
                        }

                        if (mListItem.getmFeatured() == 1) {
                            ((ItemViewHolder) holder).mFeatured.setVisibility(View.VISIBLE);
                        } else {
                            ((ItemViewHolder) holder).mFeatured.setVisibility(View.GONE);
                        }

                        try {
                            if (mListItem.getmPrice() != null && !mListItem.getmPrice().isEmpty() &&
                                    !mListItem.getmPrice().equals("0")) {
                                String priceWithCurrency = CurrencyUtils.getCurrencyConvertedValue(mContext,
                                        mListItem.getmCurrency(),
                                        Double.parseDouble(mListItem.getmPrice()));
                                ((ItemViewHolder) holder).mPriceTag.setVisibility(View.VISIBLE);
                                String price = mListItem.getmPrice();
                                if (priceWithCurrency != null && !priceWithCurrency.isEmpty()) {
                                    price = priceWithCurrency;
                                }

                                if (mMLTViewType == ConstantVariables.LIST_VIEW) {
                                    price = mContext.getResources().getString(R.string.price)+ ": " + price;
                                } else if (mMLTViewType == ConstantVariables.GRID_VIEW) {
                                    ((ItemViewHolder) holder).mLeftArrow.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
                                    ((ItemViewHolder) holder).mLeftArrow.setText("\uf04b");
                                    ((ItemViewHolder) holder).mLeftArrow.setVisibility(View.VISIBLE);
                                }
                                ((ItemViewHolder) holder).mPriceTag.setText(price);
                            } else {
                                if (mMLTViewType == ConstantVariables.GRID_VIEW) {
                                    ((ItemViewHolder) holder).mLeftArrow.setVisibility(View.GONE);
                                }
                                ((ItemViewHolder) holder).mPriceTag.setVisibility(View.GONE);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        switch (mMLTViewType) {
                            case ConstantVariables.GRID_VIEW:
                                ((ItemViewHolder) holder).mLocationIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
                                if (mListItem.getmLocation() != null && !mListItem.getmLocation().isEmpty()) {
                                    ((ItemViewHolder) holder).mLocationLayout.setVisibility(View.VISIBLE);
                                    ((ItemViewHolder) holder).mLocationIcon.setText("\uf041");
                                    ((ItemViewHolder) holder).mLocation.setText(mListItem.getmLocation());
                                } else {
                                    ((ItemViewHolder) holder).mLocationLayout.setVisibility(View.GONE);
                                }

                            case ConstantVariables.LIST_VIEW:
                                ItemViewHolder itemHolder =  ((ItemViewHolder) holder);
                                if (mListItem.getmLocation() != null && !mListItem.getmLocation().isEmpty() && mMLTViewType != ConstantVariables.GRID_VIEW) {
                                    itemHolder.itemDesc.setText(mListItem.getmLocation() + " - " + creationDate);
                                } else {
                                    itemHolder.itemDesc.setText(creationDate);
                                }
                                break;

                            case ConstantVariables.MATRIX_VIEW:
                                ItemViewHolder itemViewHolder =  ((ItemViewHolder) holder);
                                if (mListItem.getmLocation() != null && !mListItem.getmLocation().isEmpty()) {
                                    itemViewHolder.itemDesc.setText(mListItem.getmLocation());
                                }
                                itemViewHolder.mCreationDate.setVisibility(View.VISIBLE);
                                itemViewHolder.mCreationDate.setText(creationDate);
                                break;

                        }
                        // Setting listing image
                        mImageLoader.setListingImageUrl(mListItem.getmBrowseImgUrl(), ((ItemViewHolder) holder).itemImage);

                        ((ItemViewHolder) holder).mCloseIcon.setTypeface(fontIcon);
                        if (mListItem.getmClosed() == 1) {
                            ((ItemViewHolder) holder).mCloseIcon.setVisibility(View.VISIBLE);
                            ((ItemViewHolder) holder).mCloseIcon.setText("\uf023");
                        } else {
                            ((ItemViewHolder) holder).mCloseIcon.setVisibility(View.GONE);
                        }

                        // If Manage Page then show the all counts (view, review, comment, like)
                        if (!isBrowsePage && !currentSelectedOption.equals("sitereview_wishlist")) {
                            ((ItemViewHolder) holder).mCountContainer.setVisibility(View.VISIBLE);
                            ((ItemViewHolder) holder).mViewCountIcon.setTypeface(fontIcon);
                            ((ItemViewHolder) holder).mReviewCountIcon.setTypeface(fontIcon);
                            ((ItemViewHolder) holder).mCommentCountIcon.setTypeface(fontIcon);
                            ((ItemViewHolder) holder).mLikeCountIcon.setTypeface(fontIcon);
                            ((ItemViewHolder) holder).mViewCountIcon.setText("\uf06e");
                            ((ItemViewHolder) holder).mReviewCountIcon.setText("\uf005");
                            ((ItemViewHolder) holder).mCommentCountIcon.setText("\uf075");
                            ((ItemViewHolder) holder).mLikeCountIcon.setText("\uf164");
                            ((ItemViewHolder) holder).mViewCount.setText(String.valueOf(mListItem.getmViewCount()));
                            ((ItemViewHolder) holder).mReviewCount.setText(String.valueOf(mListItem.getmReviewCount()));
                            ((ItemViewHolder) holder).mCommentCount.setText(String.valueOf(mListItem.getmCommentCount()));
                            ((ItemViewHolder) holder).mLikeCount.setText(String.valueOf(mListItem.getmLikeCount()));

                        } else {
                            ((ItemViewHolder) holder).mCountContainer.setVisibility(View.GONE);
                        }
                        break;
                    case "core_main_sitestoreproduct":
                    case "core_main_siteevent":
                    case ConstantVariables.ADV_VIDEO_MENU_TITLE:
                    case ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE:
                    case ConstantVariables.CROWD_FUNDING_MAIN_TITLE:
                    case ConstantVariables.SITE_PAGE_TITLE_MENU:
                    case ConstantVariables.SITE_PAGE_MENU_TITLE:
                    case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                        mImageLoader.setResizeImageUrl(mListItem.getmBrowseImgUrl(), 200, 200,
                                ((ItemViewHolder) holder).itemImage);
                        break;
                    case ConstantVariables.STORE_MENU_TITLE:
                        JSONObject shippingItem = mListItem.getmShippingItem();
                        if (shippingItem != null) {
                            ((ItemViewHolder) holder).mShippingLimit.setText(shippingItem.optJSONObject("limit").optString("value"));
                            ((ItemViewHolder) holder).mShippingTitle.setText(shippingItem.optJSONObject("title").optString("value"));

                            JSONObject handlingType = shippingItem.optJSONObject("handling_type");
                            ((ItemViewHolder) holder).mShippingPrice.setText(CurrencyUtils.getCurrencyConvertedValue(mContext, handlingType.optString("currency"),
                                    handlingType.optDouble("value")));

                            ((ItemViewHolder) holder).mShippingDelivery.setText(shippingItem.optJSONObject("delivery_time").optString("value"));
                        }
                        if (mListItem.getMenuArray() != null) {
                            ((ItemViewHolder) holder).mOptionIconLayout.setVisibility(View.VISIBLE);
                            mGutterMenuUtils.setOnMenuClickResponseListener(this);
                            ((ItemViewHolder) holder).mOptionIcon.setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {
                                    ((ItemViewHolder) holder).mOptionIcon.setTag(holder);
                                    ItemViewHolder holder = (ItemViewHolder) view.getTag();
                                    mGutterMenuUtils.showPopup(view, holder.listItem.getMenuArray(),
                                            holder.getAdapterPosition(), mBrowseItemList,currentSelectedOption);
                                }
                            });
                        }
                        break;
                    case "downloadable_product":
                        JSONObject downloadableItem = mListItem.getmShippingItem();
                        if (downloadableItem != null) {
                            ((ItemViewHolder) holder).mDownloadableTitle.setText(downloadableItem.optJSONObject("title").optString("value"));
                            ((ItemViewHolder) holder).mDownloadableCount.setText(downloadableItem.optJSONObject("download_limit").optString("value"));
                            ((ItemViewHolder) holder).mDownloadableExt.setText(downloadableItem.optJSONObject("extension").optString("value"));
                        }
                        if (mListItem.getMenuArray() != null) {
                            ((ItemViewHolder) holder).mOptionIconLayout.setVisibility(View.VISIBLE);
                            mGutterMenuUtils.setOnMenuClickResponseListener(this);
                            ((ItemViewHolder) holder).mOptionIcon.setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {
                                    ((ItemViewHolder) holder).mOptionIcon.setTag(holder);
                                    ItemViewHolder holder = (ItemViewHolder) view.getTag();
                                    mGutterMenuUtils.showPopup(view, holder.listItem.getMenuArray(),
                                            holder.getAdapterPosition(), mBrowseItemList,currentSelectedOption);
                                }
                            });
                        }
                        break;
                }
                if (!Arrays.asList(ignoreModules).contains(currentSelectedOption)) {

                    if (isBrowsePage) {
                        ((ItemViewHolder) holder).mOptionIconLayout.setVisibility(View.INVISIBLE);
                    } else if (mListItem.getMenuArray() != null) {
                        ((ItemViewHolder) holder).mOptionIconLayout.setVisibility(View.VISIBLE);
                        mGutterMenuUtils.setOnMenuClickResponseListener(this);
                        ((ItemViewHolder) holder).mOptionIcon.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                ((ItemViewHolder) holder).mOptionIcon.setTag(holder);
                                ItemViewHolder holder = (ItemViewHolder) view.getTag();
                                mGutterMenuUtils.showPopup(view, holder.listItem.getMenuArray(),
                                        holder.getAdapterPosition(), mBrowseItemList, currentSelectedOption,
                                        mCallingFragment, null, holder.listItem.getmListingTypeId(), isBrowsePage);
                            }
                        });
                    }
                }


                break;
            case TYPE_FB_AD:
                FacebookAdViewHolder adMob = (FacebookAdViewHolder) holder;
                if (adMob.mNativeAd != null) {
                    adMob.mNativeAd.unregisterView();
                }
                adMob.mNativeAd = (NativeAd) mBrowseItemList.get(position);

                FacebookAdViewHolder.inflateAd(adMob.mNativeAd, adMob.adView, mContext, false);
                break;
            case TYPE_ADMOB:
                AdMobViewHolder adMobViewHolder = (AdMobViewHolder) holder;

                AdMobViewHolder.inflateAd(mContext,
                        (NativeAppInstallAd) mBrowseItemList.get(position), adMobViewHolder.mAdView);
                break;
            case TYPE_COMMUNITY_ADS:
                CommunityAdsHolder communityAdsHolder = (CommunityAdsHolder) holder;
                communityAdsHolder.mCommunityAd = (CommunityAdsList) mBrowseItemList.get(position);

                CommunityAdsHolder.inflateAd(communityAdsHolder.mCommunityAd, communityAdsHolder.adView, mContext,
                        position);
                break;

            case REMOVE_COMMUNITY_ADS:

                // Show Hidden Type Feed
                final RemoveAdHolder removeAdHolder = (RemoveAdHolder) holder;
                removeAdHolder.mCommunityAd = (CommunityAdsList) mBrowseItemList.get(position);
                removeAdHolder.removeAd(removeAdHolder.mCommunityAd, removeAdHolder.adView, mContext, position);
                break;

            case HEADER_TYPE:
                if (currentSelectedOption.equals("sitereview_listing")) {
                    mListItem = (BrowseListItems) mBrowseItemList.get(position);
                    ((HeaderViewHolder) holder).mSlideShowItemList.clear();
                    if (mListItem != null) {
                        ((HeaderViewHolder) holder).mSlideShowAdapter = new SlideShowAdapter(mContext, R.layout.list_item_slide_show,
                                ((HeaderViewHolder) holder).mSlideShowItemList, new OnItemClickListener() {
                            @Override
                            public void onItemClick(View view, int position) {
                                SlideShowListItems listItems = ((HeaderViewHolder) holder).mSlideShowItemList.get(position);
                                Intent mainIntent = GlobalFunctions.getIntentForModule(mContext, listItems.getmListItemId(),
                                        currentSelectedOption, null);
                                mainIntent.putExtra(ConstantVariables.LISTING_TYPE_ID, mListItem.getmListingTypeId());
                                mContext.startActivity(mainIntent);
                            }
                        });

                        ((HeaderViewHolder) holder).mSlideShowPager.setAdapter(((HeaderViewHolder) holder).mSlideShowAdapter);

                        JSONObject mSliderObject = mListItem.getSliderObject();
                        if (mSliderObject != null) {
                            ((HeaderViewHolder) holder).mSlideShowLayout.setVisibility(View.VISIBLE);
                            JSONArray mDataResponse = mSliderObject.optJSONArray("response");
                            if (mDataResponse != null && mDataResponse.length() > 0) {
                                for (int i = 0; i < mDataResponse.length() && i < 5; i++) {
                                    JSONObject jsonDataObject = mDataResponse.optJSONObject(i);
                                    int listingId = jsonDataObject.optInt("listing_id");
                                    String title = jsonDataObject.optString("title");
                                    String image = jsonDataObject.optString("image");

                                    //Add data to slide show adapter
                                    ((HeaderViewHolder) holder).mSlideShowItemList.add(new SlideShowListItems(image, title, listingId));
                                }

                                ((HeaderViewHolder) holder).mSlideShowAdapter.notifyDataSetChanged();
                                if (mDataResponse.length() > 1) {
                                    ((HeaderViewHolder) holder).mCircleIndicator.setViewPager(((HeaderViewHolder) holder).mSlideShowPager);
                                }
                            }

                        } else {
                            ((HeaderViewHolder) holder).mSlideShowLayout.setVisibility(View.GONE);
                        }
                    }
                } else {
                    ((HeaderViewHolder) holder).mHeader.setText((CharSequence) mBrowseItemList.get(position));
                }

                break;
            default:
                ProgressViewHolder.inflateProgressView(mContext, ((ProgressViewHolder) holder).progressView,
                        mBrowseItemList.get(position));
                break;
        }

    }

    @Override
    public void onItemDelete(int position) {
        /* Notify Adapter After Deleting the Entry */
        mBrowseItemList.remove(position);
        mListItem.setmTotalItemCount(mListItem.getmTotalItemCount() - 1);
        notifyDataSetChanged();
    }

    @Override
    public void onItemActionSuccess(int position, Object itemList, String menuName) {

        if (menuName.equals("remove")) {
            try {
                /* Notify Adapter After Deleting the Entry */
                mBrowseItemList.remove(position);
                notifyDataSetChanged();
                BrowseListItems listItems = (BrowseListItems) itemList;
                mBrowseList.setmTotalItemCount(mBrowseList.getmTotalItemCount() - 1);
                if (((AppCompatActivity) mContext).getSupportActionBar() != null) {
                    ((AppCompatActivity) mContext).getSupportActionBar().setTitle
                            (listItems.getTopicTitle() + ": " + "(" +
                                    mBrowseList.getmTotalItemCount() + ")");
                }
                if (mBrowseList.getmTotalItemCount() == 0 && mOnItemDeleteListener != null) {
                    mOnItemDeleteListener.onItemDelete();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {

            mBrowseItemList.set(position, itemList);
            notifyDataSetChanged();
        }
    }

    public static class ItemViewHolder extends RecyclerView.ViewHolder {

        public ImageView itemImage, mOptionIcon, mPlayIcon, ivAddAlbum;
        public BrowseListItems listItem;
        public TextView mContentTitle, mOwnerName, mPhotoCount, mShippingTitle, mShippingPrice, mShippingDelivery, mShippingLimit, mDownloadableTitle, mDownloadableExt, mDownloadableCount;
        public TextView mLikeCount, mCommentCount;
        public TextView mLikeIcon, mCommentIcon, itemDesc, mCloseIcon, mCreationDate, tvVideoCount;
        public View container, rlPhotoWrapper;
        public LinearLayout mLocationLayout, mCountContainer, mOptionIconLayout;
        public TextView mLocationIcon, mLocation, mViewCountIcon, mViewCount, mReviewCountIcon, mReviewCount,
                mCommentCountIcon, mLikeCountIcon, mPriceTag, mLeftArrow, mFeatured, mSponsored;


        public ItemViewHolder(View view, String moduleName, int mMLTViewType, Context context) {
            super(view);
            container = view;
            mOptionIcon = (ImageView) view.findViewById(R.id.optionIcon);
            mCloseIcon = (TextView) view.findViewById(R.id.closeIcon);
            mOptionIconLayout = (LinearLayout) view.findViewById(R.id.option_icon_layout);
            switch (moduleName) {
                case "core_main_sitestoreproduct":
                case "core_main_siteevent":
                case ConstantVariables.ADV_VIDEO_MENU_TITLE:
                case ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE:
                case ConstantVariables.CROWD_FUNDING_MAIN_TITLE:
                case ConstantVariables.SITE_PAGE_TITLE_MENU:
                case ConstantVariables.SITE_PAGE_MENU_TITLE:
                case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                    mContentTitle = (TextView) view.findViewById(R.id.itemTitle);
                    itemImage = (ImageView) view.findViewById(R.id.viewImage);
                    break;

                case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                case "core_main_classified":
                case "core_main_music":
                    itemImage = (ImageView) view.findViewById(R.id.viewImage);
                    mPlayIcon = (ImageView) view.findViewById(R.id.play_button);
                    mContentTitle = (TextView) view.findViewById(R.id.itemTitle);
                    itemDesc = (TextView) view.findViewById(R.id.itemDesc);
                    tvVideoCount = (TextView) view.findViewById(R.id.video_count);
                    break;
                case "sitereview_listing":
                case "sitereview_wishlist":
                    mCountContainer = (LinearLayout) view.findViewById(R.id.counts_container);
                    mViewCountIcon = (TextView) view.findViewById(R.id.view_count_icon);
                    mViewCount = (TextView) view.findViewById(R.id.view_count);
                    mReviewCountIcon = (TextView) view.findViewById(R.id.review_count_icon);
                    mReviewCount = (TextView) view.findViewById(R.id.review_count);
                    mCommentCountIcon = (TextView) view.findViewById(R.id.comment_count_icon);
                    mCommentCount = (TextView) view.findViewById(R.id.comment_count);
                    mLikeCountIcon = (TextView) view.findViewById(R.id.like_count_icon);
                    mLikeCount = (TextView) view.findViewById(R.id.like_count);

                    switch (mMLTViewType) {
                        case ConstantVariables.GRID_VIEW:
                            mLeftArrow = (TextView) view.findViewById(R.id.left_arrow_view);
                            view.findViewById(R.id.day_month_layout).setVisibility(View.GONE);
                            view.findViewById(R.id.date_layout).setVisibility(View.GONE);
                            mLocationLayout = (LinearLayout) view.findViewById(R.id.location_layout);
                            mLocationIcon = (TextView) view.findViewById(R.id.location_icon);
                            mLocation = (TextView) view.findViewById(R.id.eventLocationInfo);

                        case ConstantVariables.LIST_VIEW:
                            itemImage = (ImageView) view.findViewById(R.id.contentImage);
                            mContentTitle = (TextView) view.findViewById(R.id.contentTitle);
                            itemDesc = (TextView) view.findViewById(R.id.contentDetail);
                            mPriceTag = (TextView) view.findViewById(R.id.price_tag);
                            mFeatured = (TextView) view.findViewById(R.id.featuredLabel);
                            mSponsored = (TextView) view.findViewById(R.id.sponsoredLabel);
                            break;

                        case ConstantVariables.MATRIX_VIEW:
                            itemImage = (ImageView) view.findViewById(R.id.viewImage);
                            mContentTitle = (TextView) view.findViewById(R.id.itemTitle);
                            itemDesc = (TextView) view.findViewById(R.id.itemDesc);
                            mCreationDate = (TextView) view.findViewById(R.id.listing_date);
                            mFeatured = (TextView) view.findViewById(R.id.featuredLabel);
                            mSponsored = (TextView) view.findViewById(R.id.sponsoredLabel);
                            mPriceTag = (TextView) view.findViewById(R.id.price_tag);
                            break;
                    }
                    break;

                case "core_main_album":
                    itemImage = view.findViewById(R.id.viewImage);
                    ivAddAlbum = view.findViewById(R.id.ivAddAlbum);
                    mContentTitle = view.findViewById(R.id.itemTitle);
                    container.findViewById(R.id.album_view).setVisibility(View.VISIBLE);
                    mOwnerName = view.findViewById(R.id.ownerName);
                    mPhotoCount = view.findViewById(R.id.photoCount);
                    mPlayIcon = view.findViewById(R.id.play_button);
                    mLikeCount = view.findViewById(R.id.likeCount);
                    mLikeIcon = view.findViewById(R.id.likeImg);
                    rlPhotoWrapper = view.findViewById(R.id.rlPhotoWrapper);
                    mCommentCount = view.findViewById(R.id.commentCount);
                    mCommentIcon = view.findViewById(R.id.commentImg);

                    mOptionIcon.setImageDrawable(ContextCompat.getDrawable(context, R.drawable.ic_item_overflow));
                    mOptionIcon.setColorFilter(ContextCompat.getColor(context, R.color.black),
                            PorterDuff.Mode.SRC_IN);
                    mOptionIconLayout.setVisibility(View.VISIBLE);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        itemImage.setClipToOutline(true);
                    }

                    break;
                case ConstantVariables.STORE_MENU_TITLE:
                    mShippingTitle = (TextView) view.findViewById(R.id.shipping_title);
                    mContentTitle = (TextView) view.findViewById(R.id.shipping_title);
                    mShippingPrice = (TextView) view.findViewById(R.id.shipping_price);
                    mShippingDelivery = (TextView) view.findViewById(R.id.shipping_delivery);
                    mShippingLimit = (TextView) view.findViewById(R.id.shipping_limit);
                    break;
                case "downloadable_product":
                    mDownloadableTitle = (TextView) view.findViewById(R.id.downloadable_title);
                    mContentTitle = (TextView) view.findViewById(R.id.downloadable_title);
                    mDownloadableCount = (TextView) view.findViewById(R.id.downloadable_max_count);
                    mDownloadableExt = (TextView) view.findViewById(R.id.downloadable_extension);
                    break;

            }

        }
    }

    public static class HeaderViewHolder extends RecyclerView.ViewHolder {

        public TextView mHeader;
        public BrowseListItems listItem;
        public SlideShowAdapter mSlideShowAdapter;
        public ViewPager mSlideShowPager;
        public CircleIndicator mCircleIndicator;
        public List<SlideShowListItems> mSlideShowItemList = new ArrayList<>();
        public LinearLayout mSlideShowLayout;

        public HeaderViewHolder(View itemView, String moduleName) {
            super(itemView);

            if (moduleName.equals("sitereview_listing")) {
                mSlideShowLayout = (LinearLayout) itemView.findViewById(R.id.slide_show_header);
                mSlideShowPager = (ViewPager) itemView.findViewById(R.id.slide_show_pager);
                mCircleIndicator = (CircleIndicator) itemView.findViewById(R.id.circle_indicator);
            } else {
                mHeader = (TextView) itemView.findViewById(R.id.locationLabel);
            }
        }
    }

}
