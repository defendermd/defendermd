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

package com.socialengineaddons.mobileapp.classes.modules.store.adapters;


import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.PopupMenu;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.SlideShowAdapter;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CircularImageView;
import com.socialengineaddons.mobileapp.classes.common.ui.ProgressBarHolder;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.SlideShowListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.store.ui.CircleIndicator;
import com.socialengineaddons.mobileapp.classes.modules.store.utils.StoreInfoModel;
import com.socialengineaddons.mobileapp.classes.modules.store.utils.StoreUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class StoreViewAdapter extends RecyclerView.Adapter {

    public static final int VIEW_ITEM = 1;
    public static final int VIEW_PROG = 0;
    public static final int TYPE_FB_AD = 2;
    public static final int TYPE_ADMOB = 5;
    public static final int HEADER_TYPE = 3;

    public Context mContext;
    public List<Object> mStoreItemList;
    public StoreInfoModel mStoreInfo;
    private OnItemClickListener mOnItemClickListener;
    private AppConstant mAppConst;
    private ImageLoader mImageLoader;

    private Boolean fromBrowsePage;

    public StoreViewAdapter(Context context, List<Object> storeList, OnItemClickListener onItemClickListener, boolean fromBrowsePage) {
        mContext = context;
        mStoreItemList = storeList;
        mOnItemClickListener = onItemClickListener;
        mAppConst = new AppConstant(mContext);
        mImageLoader = new ImageLoader(mContext);
        this.fromBrowsePage = fromBrowsePage;
    }


    @Override
    public int getItemViewType(int position) {

        // Header on 0th Position
        if (position == 0 && mStoreItemList.get(position) != null && fromBrowsePage) {
            return HEADER_TYPE;
        } else
            return (mStoreItemList.get(position) != null
                    && !mStoreItemList.get(position).equals(ConstantVariables.FOOTER_TYPE)) ? VIEW_ITEM : VIEW_PROG;
    }

    @Override
    public int getItemCount() {
        return mStoreItemList.size();
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        RecyclerView.ViewHolder viewHolder = null;
        View itemView;
        switch (viewType) {
            case HEADER_TYPE:
                itemView = LayoutInflater.from(parent.getContext()).inflate(
                        R.layout.slide_show_header, parent, false);
                return new HeaderViewHolder(itemView);

            case VIEW_ITEM:
                itemView = LayoutInflater.from(parent.getContext()).inflate(
                        R.layout.store_item_view, parent, false);
                viewHolder = new StoreViewHolder(itemView);
                break;
            case TYPE_FB_AD:
                break;
            case TYPE_ADMOB:
                break;
            default:
                itemView = LayoutInflater.from(parent.getContext()).inflate(
                        R.layout.progress_item, parent, false);
                viewHolder = new ProgressBarHolder(itemView);
                break;

        }
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, int position) {

        switch (holder.getItemViewType()) {

            case HEADER_TYPE:
                HeaderViewHolder headerHolder = (HeaderViewHolder) holder;
                headerHolder.mSlideShowItemList.clear();
                mStoreInfo = (StoreInfoModel) mStoreItemList.get(position);
                if (mStoreInfo != null) {
                    headerHolder.mSlideShowAdapter = new SlideShowAdapter(mContext, R.layout.list_item_slide_show,
                            headerHolder.mSlideShowItemList, new OnItemClickListener() {
                        @Override
                        public void onItemClick(View view, int position) {
                            SlideShowListItems listItems = headerHolder.mSlideShowItemList.get(position);
//                            Intent mainIntent = GlobalFunctions.getIntentForModule(mContext, listItems.getmListItemId(),
//                                    ConstantVariables.MLT_MENU_TITLE, null);
//                            mainIntent.putExtra(ConstantVariables.LISTING_TYPE_ID, listingModel.getListingTypeId());
//                            mContext.startActivity(mainIntent);

                            mContext.startActivity(StoreUtil.getStoreViewPageIntent(mContext, String.valueOf(listItems.getmListItemId()), listItems.getmObject()));

                        }
                    });

                    headerHolder.mSlideShowPager.setAdapter(headerHolder.mSlideShowAdapter);

                    JSONObject mSliderObject = mStoreInfo.getSliderObject();
                    if (mSliderObject != null) {
                        headerHolder.mSlideShowLayout.setVisibility(View.VISIBLE);
                        JSONArray mDataResponse = mSliderObject.optJSONArray("response");
                        if (mDataResponse != null && mDataResponse.length() > 0) {
                            for (int i = 0; i < mDataResponse.length() && i < 5; i++) {
                                JSONObject jsonDataObject = mDataResponse.optJSONObject(i);
                                int listingId = jsonDataObject.optInt("store_id");
                                String title = jsonDataObject.optString("title");
                                String image = jsonDataObject.optString("image");

                                //Add data to slide show adapter
                                headerHolder.mSlideShowItemList.add(new SlideShowListItems(image, title, listingId,jsonDataObject));
                            }

                            headerHolder.mSlideShowAdapter.notifyDataSetChanged();
                            if (mDataResponse.length() > 1) {
                                headerHolder.mCircleIndicator.setViewPager(headerHolder.mSlideShowPager);
                            }
                        }

                    } else {
                        headerHolder.mSlideShowLayout.setVisibility(View.GONE);
                    }
                }
                break;

            case VIEW_ITEM:
                ((StoreViewHolder) holder).mainView.setTag("mainView");
                ((StoreViewHolder) holder).mainView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        mOnItemClickListener.onItemClick(view, holder.getAdapterPosition());
                    }
                });

                mStoreInfo = (StoreInfoModel) mStoreItemList.get(position);
                ((StoreViewHolder) holder).titleView.setText(mStoreInfo.getStoreTitle());
                ((StoreViewHolder) holder).categoryView.setText(
                        mContext.getResources().getString(R.string.category_salutation) + " " +
                                mStoreInfo.getStoreCategory());
                String likeCount = mStoreInfo.getLikeCount() + " " + mContext.getResources().
                        getQuantityString(R.plurals.profile_page_like, mStoreInfo.getLikeCount());
                String commentCount = mStoreInfo.getCommentCount() + " " +
                        mContext.getResources().getQuantityString(R.plurals.profile_page_comment,
                                mStoreInfo.getCommentCount());
                ((StoreViewHolder) holder).likeFollowCountView.setText(likeCount + "  " + commentCount);

                mImageLoader.setImageUrl(mStoreInfo.getStoreImage(), ((StoreViewHolder) holder).mainImageView);
                mImageLoader.setPersonImageUrl(mStoreInfo.getOwnerImage(), ((StoreViewHolder) holder).ownerImageView);

                ((StoreViewHolder) holder).ownerImageView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        mOnItemClickListener.onItemClick(view, holder.getAdapterPosition());
                    }
                });
                ((StoreViewHolder) holder).optionMenu.setColorFilter(ContextCompat.getColor(mContext, R.color.white));
                if (mStoreInfo.getMenuArray() != null) {
                    ((StoreViewHolder) holder).optionMenu.setVisibility(View.VISIBLE);
                    ((StoreViewHolder) holder).optionMenu.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            showPopup(view, holder.getAdapterPosition());
                        }
                    });
                } else {
                    ((StoreViewHolder) holder).optionMenu.setVisibility(View.GONE);
                }

                if (mStoreInfo.getIsFeatured() == 1) {
                    ((StoreViewHolder) holder).featuredView.setVisibility(View.VISIBLE);
                } else {
                    ((StoreViewHolder) holder).featuredView.setVisibility(View.GONE);
                }

                if (mStoreInfo.getIsSponsored() == 1) {
                    ((StoreViewHolder) holder).sponsoredView.setVisibility(View.VISIBLE);
                } else {
                    ((StoreViewHolder) holder).sponsoredView.setVisibility(View.GONE);
                }
                break;
            case TYPE_FB_AD:
                break;
            case TYPE_ADMOB:
                break;
            default:
                          /*
                Show Footer ProgressBar on Scrolling
                Show End Of Result Text if there are no more results.
                */
                if (mStoreItemList.get(position) == null) {
                    ((ProgressBarHolder) holder).progressBar.setVisibility(View.VISIBLE);
                    ((ProgressBarHolder) holder).progressBar.setIndeterminate(true);
                    ((ProgressBarHolder) holder).mFooterText.setVisibility(View.GONE);
                } else {
                    ((ProgressBarHolder) holder).mFooterText.setVisibility(View.VISIBLE);
                    ((ProgressBarHolder) holder).mFooterText.setText(mContext.getResources().
                            getString(R.string.end_of_results));
                    ((ProgressBarHolder) holder).progressBar.setVisibility(View.GONE);
                }
                break;
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


        public HeaderViewHolder(View itemView) {
            super(itemView);

            mSlideShowLayout = itemView.findViewById(R.id.slide_show_header);
            mSlideShowPager = itemView.findViewById(R.id.slide_show_pager);
            mCircleIndicator = itemView.findViewById(R.id.circle_indicator);
        }
    }

    public class StoreViewHolder extends RecyclerView.ViewHolder {
        View mainView;
        TextView titleView, categoryView, likeFollowCountView;
        ImageView mainImageView, optionMenu;
        CircularImageView ownerImageView;
        TextView featuredView, sponsoredView;

        public StoreViewHolder(View itemView) {
            super(itemView);
            mainView = itemView;
            titleView = (TextView) itemView.findViewById(R.id.store_title);
            mainImageView = (ImageView) itemView.findViewById(R.id.header_imageview);
            ownerImageView = (CircularImageView) itemView.findViewById(R.id.owner_image);
            categoryView = (TextView) itemView.findViewById(R.id.store_category);
            likeFollowCountView = (TextView) itemView.findViewById(R.id.store_like_follow_count);
            optionMenu = (ImageView) itemView.findViewById(R.id.option_icon_view);
            featuredView = (TextView) itemView.findViewById(R.id.featuredLabel);
            sponsoredView = (TextView) itemView.findViewById(R.id.sponsoredLabel);
        }
    }

    private JSONObject menuJsonObject;
    private String menuName, redirectUrl;
    private HashMap<String, String> postParams;

    public void showPopup(View v, int position) {
        final StoreInfoModel storeInfoModel = (StoreInfoModel) mStoreItemList.get(position);
        postParams = new HashMap<>();
        PopupMenu popup = new PopupMenu(mContext, v);

        if (storeInfoModel.getMenuArray().length() != 0) {

            for (int i = 0; i < storeInfoModel.getMenuArray().length(); i++) {

                try {
                    menuJsonObject = storeInfoModel.getMenuArray().getJSONObject(i);
                    if (menuJsonObject.getString("name").equals("close") ||
                            menuJsonObject.getString("name").equals("open")) {
                        if (storeInfoModel.getIsClosed() == 0) {
                            popup.getMenu().add(Menu.NONE, i, Menu.NONE, mContext.getResources().getString(R.string.close_listing_dialogue_title));
                        } else {
                            popup.getMenu().add(Menu.NONE, i, Menu.NONE, mContext.getResources().getString(R.string.open_listing_dialogue_title));
                        }
                    } else {
                        popup.getMenu().add(Menu.NONE, i, Menu.NONE, menuJsonObject.getString("label").trim());
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            public boolean onMenuItemClick(MenuItem item) {
                int id = item.getItemId();
                try {
                    menuJsonObject = storeInfoModel.getMenuArray().getJSONObject(id);
                    menuName = menuJsonObject.getString("name");
                    JSONObject urlParams = menuJsonObject.optJSONObject("urlParams");
                    redirectUrl = AppConstant.DEFAULT_URL + menuJsonObject.getString("url");
                    if (urlParams != null && urlParams.length() != 0) {
                        JSONArray urlParamsNames = urlParams.names();
                        for (int j = 0; j < urlParams.length(); j++) {

                            String name = urlParamsNames.getString(j);
                            String value = urlParams.getString(name);

                            postParams.put(name, value);
                        }

                        redirectUrl = mAppConst.buildQueryString(redirectUrl, postParams);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                switch (menuName) {
                    case "delete":
                        performAction(redirectUrl, mContext.getResources().getString(R.string.delete_dialogue_message),
                                mContext.getResources().getString(R.string.delete_dialogue_title),
                                mContext.getResources().getString(R.string.delete_dialogue_button),
                                mContext.getResources().getString(R.string.delete_dialogue_success_message),
                                menuName, storeInfoModel);
                        break;

                    case "open":
                    case "close":
                        if (storeInfoModel.getIsClosed() == 1) {
                            performAction(redirectUrl, mContext.getResources().getString(R.string.open_listing_msg),
                                    mContext.getResources().getString(R.string.open_listing_dialogue_title),
                                    mContext.getResources().getString(R.string.open_listing_label),
                                    mContext.getResources().getString(R.string.open_listing_success),
                                    menuName, storeInfoModel);

                        } else {
                            performAction(redirectUrl, mContext.getResources().getString(R.string.close_listing_msg),
                                    mContext.getResources().getString(R.string.close_listing_dialogue_title),
                                    mContext.getResources().getString(R.string.close_listing_dialogue_title),
                                    mContext.getResources().getString(R.string.close_listing_success),
                                    menuName, storeInfoModel);
                        }
                        break;

                }
                return true;
            }
        });
        popup.show();
    }
 /*
   Code to perform Action according to the selected option
    */

    public void performAction(final String url, String message, String title, String buttonTitle,
                              final String showSuccessMessage, final String menuName, final StoreInfoModel storeInfoModel) {
        final View windowView = ((AppCompatActivity) mContext).getCurrentFocus();

        AlertDialog.Builder alertBuilder = new AlertDialog.Builder(mContext);

        alertBuilder.setMessage(message);
        alertBuilder.setTitle(title);

        alertBuilder.setPositiveButton(buttonTitle, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        mAppConst.showProgressDialog();
                        switch (menuName) {

                            case "delete":
                                mAppConst.deleteResponseForUrl(url, postParams, new OnResponseListener() {
                                    @Override
                                    public void onTaskCompleted(JSONObject jsonObject) {
                                        mAppConst.hideProgressDialog();
                                        /* Show Message */
                                        SnackbarUtils.displaySnackbar(windowView, showSuccessMessage);

                                        /* Notify Adapter After Deleting the Entry */
                                        mStoreItemList.remove(storeInfoModel);
                                        mStoreInfo.setTotalItemCount(mStoreInfo.getTotalItemCount() - 1);
                                        notifyDataSetChanged();
                                    }

                                    @Override
                                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                        mAppConst.hideProgressDialog();
                                    }
                                });
                                break;
                            case "open":
                            case "close":
                                mAppConst.postJsonResponseForUrl(url, postParams, new OnResponseListener() {
                                            @Override
                                            public void onTaskCompleted(JSONObject jsonObject) {
                                                mAppConst.hideProgressDialog();
                                                /* Show Message */
                                                if (storeInfoModel.getIsClosed() == 0) {
                                                    storeInfoModel.setIsClosed(1);
                                                } else {
                                                    storeInfoModel.setIsClosed(0);
                                                }
                                                notifyDataSetChanged();
                                                SnackbarUtils.displaySnackbar(windowView, showSuccessMessage);
                                            }

                                            @Override
                                            public void onErrorInExecutingTask(String message,
                                                                               boolean isRetryOption) {
                                                mAppConst.hideProgressDialog();
                                                SnackbarUtils.displaySnackbar(windowView, message);
                                            }
                                        }

                                );
                                break;
                        }

                    }
                }

        );

        alertBuilder.setNegativeButton(mContext.getResources().

                        getString(R.string.cancel),

                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                }

        );
        alertBuilder.create().show();
    }
}
