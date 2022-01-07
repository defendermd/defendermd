package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.adapters;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Environment;
import android.support.design.widget.BottomSheetBehavior;
import android.support.design.widget.BottomSheetDialog;
import android.support.design.widget.Snackbar;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.GravityCompat;
import android.support.v4.view.ViewPager;
import android.support.v4.widget.NestedScrollView;
import android.support.v7.widget.AppCompatRadioButton;
import android.support.v7.widget.AppCompatTextView;
import android.support.v7.widget.RecyclerView;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewManager;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.WebViewActivity;
import com.socialengineaddons.mobileapp.classes.common.adapters.SlideShowAdapter;
import com.socialengineaddons.mobileapp.classes.common.formgenerator.FormActivity;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnMenuClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnOptionItemClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.ui.viewholder.ProgressViewHolder;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.CurrencyUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.SlideShowListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.BackThisProjectFragment;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.BrowseProjectsFragments;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Element;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.FAQ;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Invoice;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Project;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.ProjectModelImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Reward;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenter;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenterImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.utils.CoreUtil;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.utils.MenuUtils;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.views.ProjectView;
import com.socialengineaddons.mobileapp.classes.modules.store.ui.CircleIndicator;
import com.socialengineaddons.mobileapp.classes.modules.store.utils.SheetItemModel;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.wordpress.android.util.ToastUtils;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.TimeUnit;

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

public class ProjectViewAdaptor extends RecyclerView.Adapter implements OnMenuClickResponseListener, OnOptionItemClickResponseListener, ProjectView {

    public static final int FEATURED_VIEW_ITEM = 2;
    public static final int VIEW_ITEM = 1;
    public static final int VIEW_PROG = 0;
    public Context mContext;
    public List<Object> mItemList;
    private OnItemClickListener mOnItemClickListener;
    private AppConstant mAppConst;
    private Project mProject;
    private FAQ mFAQ;
    private String mAdapterName = "project", paymentData;
    private MenuUtils mGutterMenuUtils;
    private Reward mReward;
    private ImageLoader mImageLoader;
    private ProjectPresenter mProjectPresenter;
    private Snackbar snackbar;
    private int selectedItem = -1;
    private BottomSheetDialog mShippingMethodDialog, mPaymentOptionDialog, mBottomSheetDialog;
    private Map<String, String> postParams;
    private ProjectView mProjectView;
    private List<SheetItemModel> mOptionsItemList = new ArrayList<>();
    private LayoutInflater mLayoutInflater;
    private View bottomSheet;
    private NestedScrollView filterView;
    private BottomSheetBehavior<View> behavior;
    private Invoice mInvoice;

    public ProjectViewAdaptor(Context context, List<Object> itemList, OnItemClickListener onItemClickListener, String adapterName, ProjectView projectView) {
        mContext = context;
        mItemList = itemList;
        mOnItemClickListener = onItemClickListener;
        mAppConst = new AppConstant(mContext);
        mAdapterName = adapterName;
        mGutterMenuUtils = new MenuUtils(mContext);
        mGutterMenuUtils.setOnMenuClickResponseListener(this);
        mGutterMenuUtils.setOnOptionItemClickResponseListener(this);
        mImageLoader = new ImageLoader(mContext);
        mProjectView = projectView;
        mLayoutInflater = ((Activity) mContext).getLayoutInflater();
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0 && mItemList.get(position) instanceof BrowseListItems) {
            return FEATURED_VIEW_ITEM;
        } else
            return (mItemList.get(position) != null
                    && !mItemList.get(position).equals(ConstantVariables.FOOTER_TYPE)) ? VIEW_ITEM : VIEW_PROG;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        RecyclerView.ViewHolder viewHolder = null;
        View itemView;
        switch (viewType) {
            case VIEW_ITEM:
                switch (mAdapterName) {
                    case "project":
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.project_item_card, parent, false);
                        viewHolder = new ProjectViewHolder(itemView);
                        break;
                    case "faq":
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.faq_item_view, parent, false);
                        viewHolder = new FAQViewHolder(itemView);
                        break;
                    case "reward":
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.reward_item_view, parent, false);
                        viewHolder = new RewardItemViewHolder(itemView);
                        break;
                    case "invoice":
                        itemView = LayoutInflater.from(parent.getContext()).inflate(
                                R.layout.project_invoice_item_view, parent, false);
                        viewHolder = new InvoiceViewHolder(itemView);
                        break;
                }

                break;

            case FEATURED_VIEW_ITEM:
                itemView = LayoutInflater.from(parent.getContext()).inflate(
                        R.layout.slide_show_header, parent, false);
                viewHolder = new HeaderViewHolder(itemView);
                break;

            default:
                itemView = LayoutInflater.from(parent.getContext()).inflate(
                        R.layout.progress_item, parent, false);
                viewHolder = new ProgressViewHolder(itemView);
                break;

        }
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, int position) {
        switch (holder.getItemViewType()) {
            case VIEW_ITEM:
                switch (mAdapterName) {
                    case "project":
                        setProjectContent(holder, position);
                        break;
                    case "faq":
                        setFAQContent(holder, position);
                        break;
                    case "reward":
                        setRewardContent(holder, position);
                        break;
                    case "invoice":
                        setInvoiceContent(holder, position);
                        break;
                }
                break;
            case FEATURED_VIEW_ITEM:
                BrowseListItems mListItem = (BrowseListItems) mItemList.get(position);

                ((HeaderViewHolder) holder).mSlideShowItemList.clear();
                if (mListItem != null) {
                    ((HeaderViewHolder) holder).mSlideShowAdapter = new SlideShowAdapter(mContext, R.layout.list_item_slide_show,
                            ((HeaderViewHolder) holder).mSlideShowItemList, new OnItemClickListener() {
                        @Override
                        public void onItemClick(View view, int position) {
                            SlideShowListItems listItems = ((HeaderViewHolder) holder).mSlideShowItemList.get(position);
                            Intent mainIntent = CoreUtil.getProjectViewPageIntent(mContext, String.valueOf(listItems.getmListItemId()));
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
                                String title = jsonDataObject.optString("title");
                                String image = jsonDataObject.optString("image");
                                int id = jsonDataObject.optInt("project_id");

                                //Add data to slide show adapter
                                ((HeaderViewHolder) holder).mSlideShowItemList.add(new SlideShowListItems(image, title, id));
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
                break;
            default:
                ProgressViewHolder.inflateProgressView(mContext, ((ProgressViewHolder) holder).progressView,
                        mItemList.get(position));
                break;
        }
    }

    @Override
    public int getItemCount() {
        return mItemList.size();
    }

    @Override
    public void onItemDelete(int position) {
        mItemList.remove(position);
        notifyItemRemoved(position);
        if (mItemList.size() == 0 && mProjectView != null) {
            mProjectView.setNoProjectErrorTip();
        }
    }

    @Override
    public void onItemActionSuccess(int position, Object itemList, String menuName) {

    }

    private void setProjectContent(final RecyclerView.ViewHolder holder, final int position) {
        ProjectViewHolder projectHolder = ((ProjectViewHolder) holder);
        projectHolder.mainView.setTag("mainView");
        projectHolder.mainView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mOnItemClickListener.onItemClick(view, holder.getAdapterPosition());
            }
        });
        mProject = (Project) mItemList.get(position);
        projectHolder.titleView.setText(mProject.title);
        projectHolder.categoryView.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_TAG) + "  " + mProject.category_name);
        if (mProject.location != null && !mProject.location.isEmpty()) {
            projectHolder.locationView.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_MAP_MARKER) + "  " + mProject.location);
            projectHolder.locationView.setVisibility(View.VISIBLE);
            projectHolder.categoryLocationDivider.setVisibility(View.VISIBLE);
        } else {
            projectHolder.locationView.setVisibility(View.GONE);
            projectHolder.categoryLocationDivider.setVisibility(View.GONE);
        }
        projectHolder.backers.setText(mProject.backer_count);

        String backedAmount = "0";
        if (mProject.backed_amount > 0) {
            backedAmount = CurrencyUtils.getCurrencyConvertedValue(mContext, mProject.currency, mProject.backed_amount);
        }

        projectHolder.backed.setText(backedAmount + " " + mContext.getResources().getString(R.string.backed).toLowerCase());
        projectHolder.lifetime.setText(mProject.state);

        mImageLoader.setResizeImageUrl(mProject.image, mContext.getResources().getDimensionPixelSize(R.dimen.dimen_250dp), mAppConst.getScreenWidth(), projectHolder.thumb);
        if (mProject.menu != null && mProject.menu.size() > 0) {
            projectHolder.optionIcon.setVisibility(View.VISIBLE);
            projectHolder.optionIcon.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mProject = (Project) mItemList.get(holder.getAdapterPosition());
                    mGutterMenuUtils.showPopup(view,
                            holder.getAdapterPosition(), null, new BrowseProjectsFragments(),
                            mProject.menu);

                }
            });
        }
        projectHolder.fundedRatioText.setText(mProject.funded_ratio_title);
        projectHolder.progressBarView.setProgress(mProject.fundedRatio);
        if (mProject != null && mProject.isFavourite) {
            projectHolder.favouriteView.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_SOLID_HEART));
            projectHolder.favouriteView.setTextColor(mContext.getResources().getColor(R.color.red));
        } else {
            projectHolder.favouriteView.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_SOLID_HEART));
            projectHolder.favouriteView.setTextColor(mContext.getResources().getColor(R.color.light_gray));
        }
        projectHolder.favouriteView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                int itemPosition = holder.getAdapterPosition();
                Project project = (Project) mItemList.get(itemPosition);
                project.isFavourite = !project.isFavourite;
                mItemList.set(itemPosition, project);
                notifyItemChanged(itemPosition);
                Map<String, String> postParams = new HashMap<>();
                postParams.put("value", project.isFavourite ? "1" : "0");
                postParams.put("position", String.valueOf(itemPosition));
                mProjectPresenter = new ProjectPresenterImpl(ProjectViewAdaptor.this, new ProjectModelImpl(ProjectViewAdaptor.this));
                mProjectPresenter.doPostRequest(UrlUtil.CROWD_FUNDING_PROJECT_FAVOURITE_URL + project.project_id, postParams);
            }
        });
        if (mProject.featured == 1) {
            projectHolder.tvFeatured.setVisibility(View.VISIBLE);
        } else {
            projectHolder.tvFeatured.setVisibility(View.GONE);
        }
        if (mProject.sponsored == 1) {
            projectHolder.tvSponsored.setVisibility(View.VISIBLE);
        } else {
            projectHolder.tvSponsored.setVisibility(View.GONE);
        }
    }

    private void setFAQContent(final RecyclerView.ViewHolder holder, int position) {
        mFAQ = (FAQ) mItemList.get(position);
        final FAQViewHolder faqViewHolder = ((FAQViewHolder) holder);
        ((FAQViewHolder) holder).faqQuery.setText(mFAQ.question);
        faqViewHolder.faqQuery.setActivated(!mFAQ.isExpended);
        if (mFAQ.isExpended) {
            faqViewHolder.faqAnswer.setVisibility(View.VISIBLE);
        } else {
            faqViewHolder.faqAnswer.setVisibility(View.GONE);
        }
        faqViewHolder.faqQuery.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                int itemPosition = holder.getAdapterPosition();
                FAQ faq = (FAQ) mItemList.get(itemPosition);
                faq.isExpended = !faq.isExpended;
                mItemList.set(itemPosition, faq);
                notifyItemChanged(itemPosition);
            }
        });

        ((FAQViewHolder) holder).faqAnswer.setText(mFAQ.answer);
    }

    @Override
    public void onItemDelete(String successMessage) {

    }

    @Override
    public void onOptionItemActionSuccess(Object itemList, String menuName) {
        BrowseListItems listItems = (BrowseListItems) itemList;
        switch (menuName) {
            case "info":
                Bundle args = new Bundle();
                args.putString(ConstantVariables.URL_STRING, listItems.getmRedirectUrl());
                args.putString(ConstantVariables.FRAGMENT_NAME, "invoice");
                args.putString(ConstantVariables.CONTENT_TITLE, mContext.getResources().getString(R.string.backing_details));
                Intent intent = new Intent(mContext, FragmentLoadActivity.class);
                intent.putExtras(args);
                ((Activity) mContext).startActivityForResult(intent, ConstantVariables.VIEW_PAGE_CODE);
                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

        }
    }

    private void setRewardContent(final RecyclerView.ViewHolder holder, final int position) {
        mReward = (Reward) mItemList.get(position);
        RewardItemViewHolder itemHolder = ((RewardItemViewHolder) holder);
        itemHolder.rewardTitle.setText(mReward.title);
        itemHolder.rewardDescription.setText(mReward.description);
        if (mReward.description != null && mReward.description.length() > 100) {
            itemHolder.rewardDescription.makeTextViewResizable(itemHolder.rewardDescription, 4, "..more", true);
        }
        if (mReward.image_profile != null && !mReward.image_profile.contains("nophoto_user")) {
            mImageLoader.setImageUrl(mReward.image_profile, itemHolder.rewardThumb);
        } else {
            Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_giftbox).mutate();
            drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.colorAccent),
                    PorterDuff.Mode.SRC_ATOP));
            itemHolder.rewardThumb.setImageDrawable(drawable);
        }
        if (mReward.menu != null) {
            itemHolder.optionsIcon.setVisibility(View.VISIBLE);
            itemHolder.optionsIcon.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mReward = (Reward) mItemList.get(position);
                    mGutterMenuUtils.showPopup(view,
                            position, null, new BrowseProjectsFragments(),
                            mReward.menu);

                }
            });
            itemHolder.selectedReward.setVisibility(View.GONE);
            itemHolder.rewardFooter.setVisibility(View.GONE);
        } else {
            itemHolder.optionsIcon.setVisibility(View.GONE);
            itemHolder.selectedReward.setVisibility(View.VISIBLE);
            itemHolder.selectedReward.setChecked(mReward.isSelected());
            if (mReward.isSelected()) {
                itemHolder.rewardFooter.setVisibility(View.VISIBLE);
            } else {
                itemHolder.rewardFooter.setVisibility(View.GONE);
            }
            itemHolder.selectedReward.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    int itemPosition = holder.getAdapterPosition();
                    if ((selectedItem != itemPosition)) {
                        if ((selectedItem < 0)) {
                            Reward reward = (Reward) mItemList.get(itemPosition);
                            reward.setSelected(true);
                            reward.minBackAmount = reward.shipping_amt;
                            mItemList.set(itemPosition, reward);
                            notifyItemChanged(itemPosition);
                        } else {
                            Reward reward = (Reward) mItemList.get(selectedItem);
                            reward.setSelected(false);
                            mItemList.set(selectedItem, reward);
                            notifyItemChanged(selectedItem);
                            Reward item = (Reward) mItemList.get(itemPosition);
                            item.minBackAmount = item.shipping_amt;
                            item.setSelected(true);
                            mItemList.set(itemPosition, item);
                            notifyItemChanged(itemPosition);
                        }
                        selectedItem = itemPosition;
                    }


                }
            });
            itemHolder.submit.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mAppConst.hideKeyboard();
                    itemHolder.backAmount.clearFocus();
                    Reward reward = (Reward) mItemList.get(holder.getAdapterPosition());
                    reward.amount = itemHolder.backAmount.getText().toString();
                    showPaymentOptions(reward);
                }
            });
            if (mReward.minBackAmount > 0) {
                itemHolder.backAmount.setText("" + mReward.minBackAmount);
            }
        }

        String pledgeAmount = "0";
        if (mReward.pledge_amount > 0) {
            pledgeAmount = CurrencyUtils.getCurrencyConvertedValue(mContext, mReward.currency, mReward.pledge_amount);
        }
        itemHolder.rewardAmount.setText(pledgeAmount);

        String quantityText = (mReward.quantity == 0) ? mContext.getResources().getString(R.string.quantity_unlimited) : mContext.getResources().getString(R.string.quantity_value, mReward.quantity);
        itemHolder.rewardQuantity.setText(quantityText);
        itemHolder.estimation.setText(mContext.getResources().getString(R.string.estimated_delivery_date, mReward.delivery_date));

        if (mReward.form != null && mReward.isSelected()) {
            itemHolder.selectRegion.setVisibility(View.VISIBLE);
            if (mReward.selectedRegionName != null && !mReward.selectedRegionName.isEmpty()) {
                itemHolder.selectRegion.setText(mReward.selectedRegionName);
            }
            itemHolder.selectRegion.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    showSortingDialog(holder.getAdapterPosition());
                }

            });
        } else {
            itemHolder.selectRegion.setVisibility(View.GONE);
        }
    }

    @Override
    public View getRootView() {
        return null;
    }

    @Override
    public Context getContext() {
        return mContext;
    }

    @Override
    public void setViews() {

    }

    @Override
    public void onSuccessRequest(JSONObject response) {

    }

    @Override
    public void onFailedRequest(String errorMessage, boolean isRetryOption, Map<String, String> notifyParam) {
        int itemPosition = Integer.parseInt(notifyParam.get("position"));
        Project project = (Project) mItemList.get(itemPosition);
        project.isFavourite = !project.isFavourite;
        notifyItemChanged(itemPosition);
        SnackbarUtils.displaySnackbar(((Activity) mContext).findViewById(android.R.id.content), errorMessage);

    }

    @Override
    public void setNoProjectErrorTip() {

    }

    @Override
    public void notifyProjectView(List<?> itemList, int itemCount, Map<String, String> categoryList, Map<String, String> subCategoryList) {

    }

    @Override
    public void setCategoryBasedFilter() {

    }

    @Override
    public String getPseudoName() {
        return "project_adaptor";
    }

    @Override
    public boolean isSetCache() {
        return false;
    }

    @Override
    public boolean isActivityFinishing() {
        return false;
    }

    public void showBottomSheet(boolean isNormalDialog, View view) {
        if (isNormalDialog) {
            mShippingMethodDialog = new BottomSheetDialog(mContext);
            mShippingMethodDialog.setContentView(view);
            mShippingMethodDialog.show();
        } else {
            mPaymentOptionDialog = new BottomSheetDialog(mContext);
            mPaymentOptionDialog.setContentView(view);
            mPaymentOptionDialog.show();
        }
    }

    public void showPaymentOptions(final Reward mReward) {
        if (mReward.form != null && mReward.selectedRegionId == null) {
            Toast.makeText(mContext, mContext.getResources().getString(R.string.please_select_region), Toast.LENGTH_SHORT).show();
            return;
        } else if (mReward.amount.isEmpty() || !(!mReward.amount.isEmpty() && (Integer.parseInt(mReward.amount) >= mReward.minBackAmount))) {
            Toast.makeText(mContext, mContext.getResources().getString(R.string.please_enter_back_amount), Toast.LENGTH_SHORT).show();
            return;
        }
        bottomSheet = BackThisProjectFragment.bottomSheet;
        behavior = BackThisProjectFragment.behavior;
        final NestedScrollView paymentMethodBlock = bottomSheet.findViewById(R.id.form_view);
        paymentMethodBlock.setVisibility(View.GONE);
        bottomSheet.setVisibility(View.VISIBLE);
        bottomSheet.findViewById(R.id.loading).setVisibility(View.VISIBLE);
        try {
            TimeUnit.MILLISECONDS.sleep(100);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        behavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        bottomSheet.bringToFront();

        mAppConst.getJsonResponseFromUrl(UrlUtil.CROWD_FUNDING_CHECKOUT_URL + mReward.project_id + "?shipping_amt=" + mReward.amount + "&reward_id=" + mReward.reward_id + "&region_id=" + mReward.selectedRegionId,
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                        paymentMethodBlock.removeAllViews();
                        paymentMethodBlock.setVisibility(View.VISIBLE);
                        paymentMethodBlock.setTag("pay");
                        final FormActivity formActivity = new FormActivity();
                        formActivity.setContext(mContext);
                        FormActivity.setFormObject(jsonObject);
                        paymentData = (jsonObject.optJSONObject("response") != null) ? jsonObject.optJSONObject("response").optString("data") : null;
                        paymentMethodBlock.addView(formActivity.generateForm(jsonObject, false, ConstantVariables.CROWD_FUNDING_MAIN_TITLE));
                        bottomSheet.findViewById(R.id.pay_now).setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                postParams = formActivity.save();
                                payNow(mReward.project_id);

                            }
                        });
                        bottomSheet.findViewById(R.id.loading).setVisibility(View.GONE);
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        behavior.setState(BottomSheetBehavior.STATE_HIDDEN);
                        Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
                    }
                });
    }

    public void payNow(int projectId) {
        if (postParams != null && postParams.get("payment_gateway") != null && postParams.get("payment_gateway").isEmpty()) {
            Toast.makeText(mContext, mContext.getResources().getString(R.string.please_select_payment_gateway_to_continue), Toast.LENGTH_SHORT).show();
            return;
        }

        final View view = ((Activity) mContext).getLayoutInflater().inflate(R.layout.bottom_sheet_view, null);
        final LinearLayout customBlock = (LinearLayout) view.findViewById(R.id.custom_fields_block);
        customBlock.removeAllViews();
        showBottomSheet(false, view);

        postParams.put("data", paymentData);

        mAppConst.postJsonResponseForUrl(UrlUtil.CROWD_FUNDING_PLACE_ORDER_URL + projectId, postParams,
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                        view.findViewById(R.id.progressBar).setVisibility(View.GONE);
                        mPaymentOptionDialog.dismiss();
                        behavior.setState(BottomSheetBehavior.STATE_HIDDEN);
                        behavior.setPeekHeight(0);
                        bottomSheet.setVisibility(View.GONE);
                        ((ViewManager) view.getParent()).removeView(view);
                        Intent intent = new Intent(mContext, WebViewActivity.class);
                        intent.putExtra("url", jsonObject.optString("payment_url"));
                        intent.putExtra(ConstantVariables.KEY_PAYMENT_REQUEST, true);
                        ((Activity) mContext).startActivityForResult(intent, ConstantVariables.WEB_VIEW_ACTIVITY_CODE);
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        mPaymentOptionDialog.dismiss();
                        Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
                    }
                });
    }

    public void showSortingDialog(int itemPosition) {
        Reward reward = (Reward) mItemList.get(itemPosition);
        Element region = reward.form.get(0);
        View bottomSheetView = mLayoutInflater.inflate(R.layout.bottom_sheet_view, null);
        LinearLayout customFieldBlock = (LinearLayout) bottomSheetView.findViewById(R.id.custom_fields_block);
        final RadioGroup radioGroup = new RadioGroup(mContext);
        radioGroup.setLayoutParams(new RadioGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));
        radioGroup.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_20dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.padding_20dp));
        Set<Map.Entry<String, String>> keys = region.multiOptions.entrySet();

        for (Map.Entry<String, String> me : keys) {
            LinearLayout subView = new LinearLayout(mContext);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            subView.setLayoutParams(params);
            subView.setOrientation(LinearLayout.HORIZONTAL);
            AppCompatTextView checkIcon = new AppCompatTextView(mContext);
            checkIcon.setCompoundDrawablesWithIntrinsicBounds(null, null, ContextCompat.getDrawable(mContext, R.drawable.ic_check_circle), null);
            checkIcon.setLayoutParams(params);
            checkIcon.setGravity(Gravity.RIGHT);
            checkIcon.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_15dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp));
            AppCompatRadioButton radioButton = new AppCompatRadioButton(mContext);
            radioButton.setButtonDrawable(android.R.color.transparent);
            String key = me.getKey();
            radioButton.setText(me.getValue());
            radioButton.setTextSize(mContext.getResources().getDimensionPixelSize(R.dimen.title_large_font_size));
            radioButton.setTag(key);
            radioButton.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp));
            radioButton.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton compoundButton, boolean isChecked) {

                    if (isChecked) {
                        Reward reward = (Reward) mItemList.get(selectedItem);
                        reward.selectedRegionId = compoundButton.getTag().toString();
                        reward.selectedRegionName = compoundButton.getText().toString();

                        String amount = reward.region_id.get(reward.selectedRegionId);
                        reward.minBackAmount = Integer.parseInt(amount);
                        mItemList.set(selectedItem, reward);
                        notifyItemChanged(selectedItem);
                    }
                    mBottomSheetDialog.dismiss();
                }
            });
            radioButton.setTextSize(TypedValue.COMPLEX_UNIT_PX,
                    mContext.getResources().getDimension(R.dimen.body_default_font_size));
            subView.addView(radioButton);
            if (reward.selectedRegionId != null && reward.selectedRegionId.equals(key)) {
                radioButton.setChecked(true);
                subView.addView(checkIcon);
            }

            radioGroup.addView(subView);
            radioButton.setGravity(GravityCompat.START | Gravity.CENTER_VERTICAL);

        }
        customFieldBlock.addView(radioGroup);
        bottomSheetView.findViewById(R.id.progressBar).setVisibility(View.GONE);
        customFieldBlock.setVisibility(View.VISIBLE);
        mBottomSheetDialog = new BottomSheetDialog(mContext);
        mBottomSheetDialog.setContentView(bottomSheetView);
        mBottomSheetDialog.show();

    }

    private void setInvoiceContent(final RecyclerView.ViewHolder holder, int position) {
        mInvoice = (Invoice) mItemList.get(position);
        final InvoiceViewHolder invoiceViewHolder = (InvoiceViewHolder) holder;
        invoiceViewHolder.tvBackerId.setText(mInvoice.backerId);
        invoiceViewHolder.tvBackingDate.setText(mInvoice.backingDate);

        String backedAmount = "0";
        if (mInvoice.backedAmount > 0) {
            backedAmount = CurrencyUtils.getCurrencyConvertedValue(mContext, mInvoice.currency, mInvoice.backedAmount);
        }
        invoiceViewHolder.tvBackedAmount.setText(backedAmount);

        invoiceViewHolder.tvRewards.setText(mInvoice.reward);
        invoiceViewHolder.tvDownload.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    invoiceViewHolder.tvDownload.setVisibility(View.GONE);
                    Bitmap bitmap = Bitmap.createBitmap(invoiceViewHolder.llReceiptView.getWidth(), invoiceViewHolder.llReceiptView.getHeight(), Bitmap.Config.ARGB_8888);
                    Canvas c = new Canvas(bitmap);
                    invoiceViewHolder.llReceiptView.draw(c);
                    try {
                        int n = 10000;
                        n = new Random().nextInt(n);
                        String fileName = mContext.getResources().getString(R.string.receipt_file_name, n);
                        String path = Environment.getExternalStorageDirectory() + "/" +mContext.getResources().getString(R.string.app_name) + "/ProjectInvoice";
                        File invoiceDirectory = new File(path);
                        if (!invoiceDirectory.isDirectory()) {
                            invoiceDirectory.mkdirs();
                        }
                        File file = new File(path , fileName);
                        file.createNewFile();
                        OutputStream os = new BufferedOutputStream(new FileOutputStream(file));
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, os);
                        os.close();
                    } catch (IOException e) {
                        invoiceViewHolder.tvDownload.setVisibility(View.VISIBLE);
                        e.printStackTrace();
                    }
                    invoiceViewHolder.tvDownload.setVisibility(View.VISIBLE);
                    ToastUtils.showToast(mContext, mContext.getResources().getString(R.string.invoice_printed_message));
                }
            }
        });
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

            mSlideShowLayout = (LinearLayout) itemView.findViewById(R.id.slide_show_header);
            mSlideShowPager = (ViewPager) itemView.findViewById(R.id.slide_show_pager);
            mCircleIndicator = (CircleIndicator) itemView.findViewById(R.id.circle_indicator);

        }
    }

    public class ProjectViewHolder extends RecyclerView.ViewHolder {
        View mainView, categoryLocationDivider;
        TextView titleView, favouriteView, categoryView, locationView, backers, backed, lifetime, tvFeatured, tvSponsored;
        TextView optionIcon, fundedRatioText;
        ImageView thumb;
        ProgressBar progressBarView;
        LinearLayout projectThumb;

        public ProjectViewHolder(View itemView) {
            super(itemView);
            mainView = itemView;
            titleView = (TextView) itemView.findViewById(R.id.project_title);
            projectThumb = (LinearLayout) itemView.findViewById(R.id.project_thumb);
            thumb = itemView.findViewById(R.id.thumb);
            categoryView = (TextView) itemView.findViewById(R.id.project_category);
            categoryView.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            locationView = (TextView) itemView.findViewById(R.id.project_location);
            locationView.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            progressBarView = (ProgressBar) itemView.findViewById(R.id.project_progress);
            backers = (TextView) itemView.findViewById(R.id.project_backers);
            backed = (TextView) itemView.findViewById(R.id.project_backed_amount);
            lifetime = (TextView) itemView.findViewById(R.id.project_lifetime);
            favouriteView = (TextView) itemView.findViewById(R.id.favourite);
            favouriteView.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            favouriteView.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_EMPTY_HEART));
            optionIcon = (TextView) itemView.findViewById(R.id.optionsIcon);
            optionIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            fundedRatioText = (TextView) itemView.findViewById(R.id.funded_ratio_text);
            categoryLocationDivider = itemView.findViewById(R.id.categoryLocationDivider);
            tvFeatured = itemView.findViewById(R.id.tvFeaturedLabel);
            tvSponsored = itemView.findViewById(R.id.tvSponsoredLabel);
        }
    }

    public class FAQViewHolder extends RecyclerView.ViewHolder {
        View mainView;
        TextView faqQuery, faqAnswer;

        public FAQViewHolder(View itemView) {
            super(itemView);
            mainView = itemView;
            faqQuery = (TextView) itemView.findViewById(R.id.faq_query);
            faqQuery.setActivated(true);

            faqAnswer = (TextView) itemView.findViewById(R.id.faq_answer);
        }
    }

    public class RewardItemViewHolder extends RecyclerView.ViewHolder {
        View mainView;
        TextView rewardTitle, rewardQuantity, rewardAmount, optionsIcon;
        ImageView rewardThumb;
        LinearLayout rewardFooter;
        RadioButton selectedReward;
        EditText backAmount;
        Button submit;
        TextView selectRegion, estimation;
        private SelectableTextView rewardDescription;

        public RewardItemViewHolder(View itemView) {
            super(itemView);
            mainView = itemView;
            rewardTitle = (TextView) itemView.findViewById(R.id.reward_title);
            rewardDescription = (SelectableTextView) itemView.findViewById(R.id.reward_description);
            rewardQuantity = (TextView) itemView.findViewById(R.id.reward_quantity);
            optionsIcon = (TextView) itemView.findViewById(R.id.optionsIcon);
            rewardThumb = (ImageView) itemView.findViewById(R.id.reward_thumb);
            rewardFooter = itemView.findViewById(R.id.reward_footer);
            selectedReward = itemView.findViewById(R.id.reward_selected);
            backAmount = itemView.findViewById(R.id.back_amount);
            submit = itemView.findViewById(R.id.submit);
            rewardAmount = itemView.findViewById(R.id.reward_amount);
            selectRegion = itemView.findViewById(R.id.select_region);
            estimation = itemView.findViewById(R.id.estimated_delivery);
        }
    }

    public class InvoiceViewHolder extends RecyclerView.ViewHolder {
        View mainView;
        TextView tvBackerId, tvBackingDate, tvBackedAmount, tvRewards, tvDownload;
        LinearLayout llReceiptView;

        public InvoiceViewHolder(View itemView) {
            super(itemView);
            mainView = itemView;
            tvBackerId = itemView.findViewById(R.id.backerId);
            tvBackingDate = itemView.findViewById(R.id.backingDate);
            tvBackedAmount = itemView.findViewById(R.id.backedAmount);
            tvRewards = itemView.findViewById(R.id.rewards);
            tvDownload = itemView.findViewById(R.id.download);
            llReceiptView = itemView.findViewById(R.id.receiptView);
        }
    }
}
