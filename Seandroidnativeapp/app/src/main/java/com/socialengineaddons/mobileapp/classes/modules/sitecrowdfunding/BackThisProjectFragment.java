package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding;


import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.BottomSheetBehavior;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.app.DialogFragment;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.TextViewCompat;
import android.support.v7.widget.AppCompatTextView;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.WebViewActivity;
import com.socialengineaddons.mobileapp.classes.common.formgenerator.FormActivity;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ObservableScrollView;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ObservableScrollViewCallbacks;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ScrollState;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

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

public class BackThisProjectFragment extends DialogFragment implements View.OnClickListener, ObservableScrollViewCallbacks {
    private Context mContext;
    private AppConstant mAppConst;
    private TextView backWithoutReward, backWithReward;
    private EditText backAmount;
    private View mRootView, browseRewardsView, withRewardLayout;
    private LinearLayout rewardFooter;
    private BottomSheetDialog mPaymentOptionDialog;
    private String projectId, paymentData, mCurrency;
    private Map<String, String> postParams;
    private BaseFragment mFragment;
    private int actionBarSize, statusBarHeight, headerLayoutHeight;
    private LinearLayout headerLayout;
    private boolean hasReward;
    public  static View bottomSheet;
    public static BottomSheetBehavior<View> behavior;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mRootView = inflater.inflate(R.layout.back_this_project, container, false);
        mContext = getActivity();
        mAppConst = new AppConstant(mContext);
        if (getArguments() != null) {
            projectId = getArguments().getString(ConstantVariables.CONTENT_ID);
            String strProjectTitle = getArguments().getString(ConstantVariables.CONTENT_TITLE);
            hasReward = getArguments().getBoolean("hasReward", false);
            mCurrency = getArguments().getString("currency");
            TextView tvHeaderTitle = mRootView.findViewById(R.id.tvHeaderTitle);
            tvHeaderTitle.setText(mContext.getResources().getString(R.string.back_to_project) +" " + strProjectTitle);
            tvHeaderTitle.setSelected(true);
            tvHeaderTitle.setEllipsize(TextUtils.TruncateAt.MARQUEE);
            tvHeaderTitle.setMarqueeRepeatLimit(-1);
            tvHeaderTitle.setSingleLine(true);
            TextViewCompat.setTextAppearance(tvHeaderTitle, R.style.TextAppearance);
            tvHeaderTitle.setTextColor(ContextCompat.getColor(mContext, R.color.textColorPrimary));
        }
        setViews();

        return mRootView;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.getWindow().getAttributes().windowAnimations = R.style.MyCustomThemeWithAnimation;
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        return dialog;
    }

    private void setViews() {
        rewardFooter = mRootView.findViewById(R.id.reward_footer);
        backAmount = mRootView.findViewById(R.id.back_amount);
        backAmount.setHint(mContext.getResources().getString(R.string.back_amount) + "(" + mCurrency + ")");
        Button submit = mRootView.findViewById(R.id.submit);
        submit.setOnClickListener(this);
        backWithoutReward = mRootView.findViewById(R.id.back_without_reward_option);
        backWithoutReward.setOnClickListener(this);

        backWithReward = mRootView.findViewById(R.id.back_with_reward_option);
        backWithReward.setOnClickListener(this);
        View closePopup = mRootView.findViewById(R.id.button_close);
        closePopup.setOnClickListener(this);
        browseRewardsView = mRootView.findViewById(R.id.rewards_frame);

        ObservableScrollView mScrollView = mRootView.findViewById(R.id.scroll);
        mScrollView.setScrollViewCallbacks(this);
        withRewardLayout = mRootView.findViewById(R.id.back_with_rewards);
        if (!hasReward) {
            withRewardLayout.setVisibility(View.GONE);
        }
        headerLayout = mRootView.findViewById(R.id.header);

        headerLayout.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                headerLayout.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                headerLayoutHeight = headerLayout.getHeight(); //height is ready
                statusBarHeight = (int) Math.ceil(25 * mContext.getResources().getDisplayMetrics().density);
                ViewGroup.LayoutParams layoutParams = browseRewardsView.getLayoutParams();
                layoutParams.height = mAppConst.getScreenHeight() - ( 2 * headerLayoutHeight + statusBarHeight );
            }
        });
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.pay_now:
                payNow();
                break;
            case R.id.back_without_reward_option:
                if (backWithoutReward.isActivated()) {
                    backWithoutReward.setActivated(false);
                    rewardFooter.setVisibility(View.VISIBLE);
                } else {
                    backWithoutReward.setActivated(true);
                    rewardFooter.setVisibility(View.GONE);
                }
                break;
            case R.id.back_with_reward_option:
                if (backWithReward.isActivated()) {
                    backWithReward.setActivated(false);
                    browseRewardsView.setVisibility(View.VISIBLE);
                } else {
                    backWithReward.setActivated(true);
                    browseRewardsView.setVisibility(View.GONE);
                }
                break;
            case R.id.submit:
                showPaymentOptions(backAmount.getText().toString());
                break;
            case R.id.button_close:
                mAppConst.hideKeyboard();
                getActivity().onBackPressed();
                dismiss();
                break;


        }
    }

    public void showBottomSheet(boolean isNormalDialog, View view) {
        if (isNormalDialog) {
            BottomSheetDialog mShippingMethodDialog = new BottomSheetDialog(mContext);
            mShippingMethodDialog.setContentView(view);
            mShippingMethodDialog.show();
        } else {
            mPaymentOptionDialog = new BottomSheetDialog(mContext);
            mPaymentOptionDialog.setContentView(view);
            mPaymentOptionDialog.show();
        }
    }

    public void showPaymentOptions(String amount) {
        if (Double.valueOf(amount) == 0) {
            Toast.makeText(mContext, mContext.getResources().getString(R.string.please_enter_back_amount), Toast.LENGTH_SHORT).show();
            return;
        }
        final View view = getActivity().getLayoutInflater().inflate(R.layout.bottom_sheet_view, null);
        final LinearLayout paymentMethodBlock = (LinearLayout) view.findViewById(R.id.custom_fields_block);
        showBottomSheet(false, view);

        mAppConst.getJsonResponseFromUrl(UrlUtil.CROWD_FUNDING_CHECKOUT_URL + projectId + "?shipping_amt=" + amount,
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                        view.findViewById(R.id.progressBar).setVisibility(View.GONE);
                        paymentMethodBlock.setVisibility(View.VISIBLE);
                        paymentMethodBlock.setTag("pay");
                        paymentData = (jsonObject.optJSONObject("response") != null) ? jsonObject.optJSONObject("response").optString("data") : null;
                        final FormActivity formActivity = new FormActivity();
                        formActivity.setContext(mContext);
                        FormActivity.setFormObject(jsonObject);
                        paymentMethodBlock.addView(formActivity.generateForm(jsonObject, false, ConstantVariables.CROWD_FUNDING_MAIN_TITLE));
                        AppCompatTextView continueButton = new AppCompatTextView(mContext);
                        continueButton.setBackgroundColor(ContextCompat.getColor(mContext, R.color.colorPrimary));
                        continueButton.setLayoutParams(paymentMethodBlock.getLayoutParams());
                        continueButton.setHeight(mContext.getResources().getDimensionPixelSize(R.dimen.home_icon_tab_height));
                        continueButton.setGravity(Gravity.CENTER);
                        continueButton.setTypeface(continueButton.getTypeface(), Typeface.BOLD);
                        continueButton.setTextColor(ContextCompat.getColor(mContext, R.color.white));
                        continueButton.setTextSize(TypedValue.COMPLEX_UNIT_PX,
                                mContext.getResources().getDimension(R.dimen.body_default_font_size));
                        continueButton.setText(mContext.getResources().getString(R.string.pay_now_text));
                        continueButton.setTag(paymentMethodBlock);
                        continueButton.setId(R.id.pay_now);
                        continueButton.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                postParams = formActivity.save();
                                payNow();
                            }
                        });
                        paymentMethodBlock.addView(continueButton);
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        mPaymentOptionDialog.dismiss();
                        Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
                    }
                });
    }

    public void payNow() {
        if (postParams != null && postParams.get("payment_gateway") != null && postParams.get("payment_gateway").isEmpty()) {
            Toast.makeText(mContext, mContext.getResources().getString(R.string.please_select_payment_gateway_to_continue), Toast.LENGTH_SHORT).show();
            return;
        }
        if (mPaymentOptionDialog != null) {
            mPaymentOptionDialog.dismiss();
        }
        final View view = getActivity().getLayoutInflater().inflate(R.layout.bottom_sheet_view, null);
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
                        Intent intent = new Intent(mContext, WebViewActivity.class);
                        intent.putExtra("url", jsonObject.optString("payment_url"));
                        intent.putExtra(ConstantVariables.KEY_PAYMENT_REQUEST, true);
                        startActivityForResult(intent, ConstantVariables.WEB_VIEW_ACTIVITY_CODE);
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        mPaymentOptionDialog.dismiss();
                        Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
                    }
                });
    }


    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Bundle args = new Bundle();
        args.putString(ConstantVariables.URL_STRING, UrlUtil.CROWD_FUNDING_REWARD_SELECT_URL);
        args.putInt(ConstantVariables.VIEW_PAGE_ID, Integer.parseInt(projectId));
        args.putString(ConstantVariables.KEY_PSEUDO_NAME, "select_reward");
        mFragment = BrowseRewardsFragment.newInstance(args);
        this.getChildFragmentManager().beginTransaction().add(R.id.rewards_frame, mFragment)
                .commit();
        _initBottomSheet();
    }

    @Override
    public void onScrollChanged(int scrollY, boolean firstScroll, boolean dragging) {
        int[] iRewardLayoutLocation = new int[2];
        withRewardLayout.getLocationOnScreen(iRewardLayoutLocation);
        int position = headerLayout.getHeight() + statusBarHeight;
        int margin = (int ) mContext.getResources().getDimension(R.dimen.dimen_5dp);
        LogUtils.LOGD(" postions ", "position = " + position + ", location1 = " + iRewardLayoutLocation[1] + "  <<>>  " + (position >= iRewardLayoutLocation[1]));
        if ((position + margin) >= iRewardLayoutLocation[1]) {
            mFragment.setNestedScrollingEnabled(true);
        } else {
            mFragment.setNestedScrollingEnabled(false);
        }
    }

    @Override
    public void onDownMotionEvent() {

    }

    @Override
    public void onUpOrCancelMotionEvent(ScrollState scrollState) {

    }

    private void _initBottomSheet() {
        if (bottomSheet == null) {
            bottomSheet = mRootView.findViewById(R.id.bottom_sheet);
            behavior = BottomSheetBehavior.from(bottomSheet);
            behavior.setHideable(true);
            behavior.setSkipCollapsed(true);
            behavior.setState(BottomSheetBehavior.STATE_HIDDEN);
            bottomSheet.findViewById(R.id.cancel_backing).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    behavior.setState(BottomSheetBehavior.STATE_HIDDEN);
                }
            });
        } else {
            behavior.setState(BottomSheetBehavior.STATE_HIDDEN);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        bottomSheet = null;
        behavior = null;
    }
}
