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
 *
 */

package com.socialengineaddons.mobileapp.classes.common.formgenerator;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.AppCompatTextView;
import android.text.SpannableStringBuilder;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.CallbackManager;
import com.facebook.login.widget.LoginButton;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.WebViewActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SocialLoginUtil;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.twitter.sdk.android.core.identity.TwitterLoginButton;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.PRIVACY_POLICY_MENU_TITLE;
import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.TERMS_OF_SERVICE_MENU_TITLE;

public class FormTextView extends FormWidget {

    protected SelectableTextView _label;
    protected View view;
    public static final LinearLayout.LayoutParams viewParams = CustomViews.
            getCustomWidthHeightLayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1);
    public static CallbackManager callbackManager;
    public static TwitterLoginButton twitterLoginButton;
    private ArrayList<FormWidget> widgets;
    private String currentSelectedModule, mFieldName;
    private ArrayList<FormWidget> mFormWidgetList;
    private int elementOrder = 0;
    private FormWidget mFormWidget;
    private FormActivity mFormActivity;
    private Map<String, FormWidget> mFormWidgetMap;
    private Context mContext;
    public static boolean isAgreed;

    public FormTextView(final Context context, final String property, boolean hasValidator, boolean isNeedToAddPadding,
                        String label, final JSONObject jsonObject, String currentSelectedOption, ArrayList<FormWidget> _widgets, Map<String, FormWidget> map) {
        super(context, property, hasValidator);

        mFormWidgetList = widgets = _widgets;
        mFormWidgetMap = map;
        currentSelectedModule = currentSelectedOption;
        mFieldName = _property = property;
        mFormActivity = new FormActivity();
        LinearLayout.LayoutParams layoutParams = CustomViews.getFullWidthLayoutParams();
        layoutParams.setMargins(context.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                0, context.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                context.getResources().getDimensionPixelSize(R.dimen.margin_12dp));
        layoutParams.gravity = Gravity.CENTER;
        if (currentSelectedOption != null && currentSelectedOption.equals(ConstantVariables.BUYER_FORM)) {
            isNeedToAddPadding = true;
        }
        mContext = context;
        // Adding bottom line divider.
        View dividerView = new View(context);
        dividerView.setBackgroundResource(R.color.colordevider);
        LinearLayout.LayoutParams dividerLayoutParams = CustomViews.getCustomWidthHeightLayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                context.getResources().getDimensionPixelSize(R.dimen.divider_line_view_height));
        dividerView.setLayoutParams(dividerLayoutParams);

        // Show terms of service link and make that clickable to open it in webview.
        if (property != null && property.equals("terms_url")) {
            LinearLayout checkBoxLayout = new LinearLayout(context);
            checkBoxLayout.setLayoutParams(new LinearLayout.LayoutParams
                    (LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            checkBoxLayout.setPadding(context.getResources().getDimensionPixelSize(R.dimen.margin_10dp), 0, 0, 0);
            checkBoxLayout.setOrientation(LinearLayout.HORIZONTAL);
            CheckBox cb = new CheckBox(context);
            cb.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

                                              @Override
                                              public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                                                  isAgreed = isChecked;
                                              }
                                          }
            );
            AppCompatTextView checkBoxTv = new AppCompatTextView(context);
            createSpanText(checkBoxTv);
            checkBoxTv.setPadding(0,
                    context.getResources().getDimensionPixelSize(R.dimen.margin_10dp),
                    context.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    context.getResources().getDimensionPixelSize(R.dimen.margin_15dp));
            checkBoxLayout.addView(cb);
            checkBoxLayout.addView(checkBoxTv);
            _layout.addView(checkBoxLayout);

        } else if (property != null && property.equals("facebook")
                && !context.getResources().getString(R.string.facebook_app_id).isEmpty()) {
            // Adding facebook/twitter button when its coming in response for the integration.

            /* Initialize Facebook SDK, we need to initialize before using it ---- */
            SocialLoginUtil.initializeFacebookSDK(context);
            SocialLoginUtil.clearFbTwitterInstances(context, "facebook");

            callbackManager = CallbackManager.Factory.create();
            LoginButton facebookLoginButton = new LoginButton(context);
            facebookLoginButton.setReadPermissions(Arrays.asList("public_profile, email"));
            facebookLoginButton.setPadding(context.getResources().getDimensionPixelSize(R.dimen.margin_15dp),
                    context.getResources().getDimensionPixelSize(R.dimen.login_button_top_bottom_padding),
                    0, context.getResources().getDimensionPixelSize(R.dimen.login_button_top_bottom_padding));
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                facebookLoginButton.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
            }
            facebookLoginButton.setGravity(Gravity.CENTER);
            facebookLoginButton.setTextSize(TypedValue.COMPLEX_UNIT_PX,
                    context.getResources().getDimensionPixelSize(R.dimen.body_default_font_size));
            layoutParams.setMargins(context.getResources().getDimensionPixelSize(R.dimen.margin_25dp), 0,
                    context.getResources().getDimensionPixelSize(R.dimen.margin_25dp),
                    context.getResources().getDimensionPixelSize(R.dimen.margin_12dp));
            facebookLoginButton.setLayoutParams(layoutParams);
            addView(context, label, true);
            _layout.addView(facebookLoginButton);
            _layout.addView(dividerView);

            //Facebook login authentication process
            SocialLoginUtil.registerFacebookLoginCallback(context, _layout, callbackManager, true);


        } else if (property != null && property.equals("twitter") && !context.getResources().getString(R.string.twitter_key).isEmpty()
                && !context.getResources().getString(R.string.twitter_secret).isEmpty()) {
            SocialLoginUtil.clearFbTwitterInstances(context, "twitter");
            twitterLoginButton = new TwitterLoginButton(context);

            layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    (int) context.getResources().getDimension(R.dimen.twitter_login_button_height));

            layoutParams.setMargins(context.getResources().getDimensionPixelSize(R.dimen.margin_25dp), 0,
                    context.getResources().getDimensionPixelSize(R.dimen.margin_25dp),
                    context.getResources().getDimensionPixelSize(R.dimen.margin_12dp));


            twitterLoginButton.setLayoutParams(layoutParams);

            twitterLoginButton.setGravity(Gravity.CENTER);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                twitterLoginButton.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
            }

            twitterLoginButton.setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(context,
                    R.drawable.ic_twitter_bird_icon), null, null, null);
            twitterLoginButton.setCompoundDrawablePadding((int) context.getResources().getDimension(R.dimen.padding_10dp));
            twitterLoginButton.setPadding((int) context.getResources().getDimension(R.dimen.padding_10dp), 0,
                    (int) context.getResources().getDimension(R.dimen.padding_30dp), 0);
            twitterLoginButton.setText(context.getResources().getString(R.string.twitter_login_text));
            twitterLoginButton.setTextSize(TypedValue.COMPLEX_UNIT_PX,
                    context.getResources().getDimensionPixelSize(R.dimen.body_default_font_size));

            addView(context, label, true);
            _layout.addView(twitterLoginButton);
            _layout.addView(dividerView);

            //Twitter login authentication process
            SocialLoginUtil.registerTwitterLoginCallback(context, _layout, twitterLoginButton, true);

        } else if (jsonObject != null && jsonObject.has("fieldType") && jsonObject.optString("fieldType") != null && jsonObject.optString("fieldType").equals("help")) {
            setElementIconWithLabel(context, label, jsonObject);
        } else if (jsonObject != null && jsonObject.has("subType") && jsonObject.optString("subType") != null && jsonObject.optString("subType").equals("payment_method")) {
            setAccordionView(context, label, jsonObject, currentSelectedOption);
        } else {
            addView(context, label, true);
        }
    }

    private void createSpanText(AppCompatTextView checkBoxTv) {

        String signUpPrivacyText = mContext.getResources().getString(R.string.signup_privacy_text) + " ";
        String signUpTermsAndConditionsText = mContext.getResources().getString(R.string.terms_and_conditions_text);
        String signUpPrivacyPolicyText = mContext.getResources().getString(R.string.privacy_policy_text);
        String and = " " + mContext.getResources().getString(R.string.and_text) + " ";
        SpannableStringBuilder spanTxt = new SpannableStringBuilder(
                signUpPrivacyText);
        spanTxt.append(signUpTermsAndConditionsText);
        spanTxt.setSpan(new ClickableSpan() {
            @Override
            public void onClick(View widget) {
                Bundle bundle = new Bundle();
                bundle.putString(ConstantVariables.FRAGMENT_NAME, TERMS_OF_SERVICE_MENU_TITLE);
                bundle.putString(ConstantVariables.CONTENT_TITLE, mContext.getResources().getString(R.string.action_bar_title_terms_of_service));
                Intent intent = new Intent(mContext, FragmentLoadActivity.class);
                intent.putExtras(bundle);
                mContext.startActivity(intent);
                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            }
        }, spanTxt.length() - signUpTermsAndConditionsText.length(), spanTxt.length(), 0);
        spanTxt.append(and);
//        spanTxt.setSpan( spanTxt.length() - signUpTermsAndConditionsText.length()
//                , spanTxt.length(), 0);
        spanTxt.append(signUpPrivacyPolicyText);
        spanTxt.setSpan(new ClickableSpan() {
            @Override
            public void onClick(View widget) {
                Bundle bundle = new Bundle();
                bundle.putString(ConstantVariables.FRAGMENT_NAME, PRIVACY_POLICY_MENU_TITLE);
                bundle.putString(ConstantVariables.CONTENT_TITLE, mContext.getResources().getString(R.string.privacy_policy_text));
                Intent intent = new Intent(mContext, FragmentLoadActivity.class);
                intent.putExtras(bundle);
                mContext.startActivity(intent);
                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            }
        }, spanTxt.length() - signUpPrivacyPolicyText.length(), spanTxt.length(), 0);
        checkBoxTv.setMovementMethod(LinkMovementMethod.getInstance());
        checkBoxTv.setText(spanTxt, TextView.BufferType.SPANNABLE);

    }

    private void setElementIconWithLabel(final Context context, String label, final JSONObject jsonObject) {
        LinearLayout subView = new LinearLayout(context);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        subView.setLayoutParams(params);
        subView.setOrientation(LinearLayout.HORIZONTAL);
        AppCompatTextView helpIcon = new AppCompatTextView(context);
        helpIcon.setCompoundDrawablesWithIntrinsicBounds(null, null, ContextCompat.getDrawable(context, R.drawable.ic_help_18dp), null);
        helpIcon.setLayoutParams(params);
        helpIcon.setGravity(Gravity.RIGHT);
        helpIcon.setPadding(context.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                context.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                context.getResources().getDimensionPixelSize(R.dimen.padding_15dp),
                context.getResources().getDimensionPixelSize(R.dimen.margin_5dp));
        AppCompatTextView termsTextView = new AppCompatTextView(context);
        termsTextView.setText(label);

        termsTextView.setPadding(context.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                context.getResources().getDimensionPixelSize(R.dimen.margin_10dp),
                context.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                context.getResources().getDimensionPixelSize(R.dimen.margin_15dp));

        helpIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent termsOfServiceIntent = new Intent(context, WebViewActivity.class);
                termsOfServiceIntent.putExtra("url", jsonObject.optString("url"));
                context.startActivity(termsOfServiceIntent);
                ((Activity) context).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

            }
        });

        subView.addView(termsTextView);
        subView.addView(helpIcon);
        _layout.addView(subView);
    }

    private void setAccordionView(final Context context, String label, final JSONObject jsonObject, final String currentSelectedModule) {
        LinearLayout subView = new LinearLayout(context);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        subView.setLayoutParams(params);
        subView.setOrientation(LinearLayout.HORIZONTAL);
        if (jsonObject.has("isActive")) {
            ImageView enabled = new ImageView(context);
            enabled.setImageDrawable(context.getResources().getDrawable(R.drawable.ic_check_white_24dp));
            enabled.setPadding(context.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                    context.getResources().getDimensionPixelSize(R.dimen.margin_10dp),
                    context.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    context.getResources().getDimensionPixelSize(R.dimen.margin_15dp));
            if (jsonObject.optInt("isActive", 0) == 1) {
                enabled.setColorFilter(context.getResources().getColor(R.color.green_blue));
            } else {
                enabled.setColorFilter(context.getResources().getColor(R.color.light_gray));
            }
            subView.addView(enabled);
        }
        AppCompatTextView heading = new AppCompatTextView(context);
        heading.setText(label);
        heading.setLayoutParams(params);
        heading.setPadding(context.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                context.getResources().getDimensionPixelSize(R.dimen.margin_10dp),
                context.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                context.getResources().getDimensionPixelSize(R.dimen.padding_10));
        heading.setCompoundDrawablesWithIntrinsicBounds(null, null, ContextCompat.getDrawable(context, R.drawable.ic_expend_drop_down), null);
        heading.setTypeface(null, Typeface.BOLD);
        heading.setTag(_property);
        heading.setActivated(true);
        heading.setTextAppearance(context, android.R.style.TextAppearance_Large);
        heading.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                checkModuleSpecificConditions(view, currentSelectedModule);
            }
        });

        subView.addView(heading);
        _layout.addView(subView);
        // Adding bottom line divider.
        View view = new View(context);
        view.setBackgroundResource(R.color.colordevider);
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                context.getResources().getDimensionPixelSize(R.dimen.divider_line_view_height));
        view.setLayoutParams(layoutParams);
        _layout.addView(view);
    }

    public void checkModuleSpecificConditions(View view, String currentSelectedModule) {
        if (currentSelectedModule != null && currentSelectedModule.equals(ConstantVariables.PAYMENT_METHOD_CONFIG) && FormActivity.getAttribByProperty(String.valueOf(view.getTag()), "subType", null).equals("payment_method")) {
            int visibility = -1;
            AppCompatTextView heading = (AppCompatTextView) view;
            for (int i = 0; i < widgets.size(); i++) {
                if (widgets.get(i).getPropertyName().equals(view.getTag())) {
                    visibility = heading.isActivated() ? View.VISIBLE : View.GONE;
                    heading.setActivated(!heading.isActivated());
                    continue;
                } else if (visibility != -1 && FormActivity.getAttribByProperty(widgets.get(i).getPropertyName(), "subType", null).equals("payment_method")) {
                    break;
                }
                if (visibility != -1) widgets.get(i).getView().setVisibility(visibility);
            }

        } else {
            AppCompatTextView heading = (AppCompatTextView) view;
            heading.setActivated(!heading.isActivated());
            inflateSubFormView(heading.isActivated() ? "0" : "1");
        }
    }

    /**
     * Method to add label view.
     *
     * @param context      Context of the class.
     * @param label        Label to be shown.
     * @param isAddPadding True if need to add padding.
     */
    public void addView(Context context, String label, boolean isAddPadding) {
        _label = new SelectableTextView(context);
        _label.setText(label);
        _label.setTypeface(null, Typeface.BOLD);
        _label.setLayoutParams(FormActivity.defaultLayoutParams);
        if (isAddPadding) {
            _label.setPadding(context.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                    context.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    context.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    context.getResources().getDimensionPixelSize(R.dimen.padding_5dp));
        }

        view = new View(context);
        view.setLayoutParams(viewParams);

        _layout.addView(_label);
        _layout.addView(view);
    }

    /**
     * Method to set the order of the selected parent element.
     */
    public void setElementOrder() {
        for (int i = 0; i < mFormWidgetList.size(); i++) {
            if (mFormWidgetList.get(i).getPropertyName().equals(mFieldName)) {
                elementOrder = i;
                break;
            }
        }
    }

    /**
     * Method to remove the child element of the selected parent element.
     *
     * @param parentName, name of the selected element.
     */
    private void removeChild(String parentName) {
        String append = FormActivity.getAttribByProperty(parentName, "append", null);
        int appendValue = (append != null && !append.isEmpty()) ? Integer.parseInt(append) : 1;
        JSONObject formObject = FormActivity.getFormObject().optJSONObject("fields");
        String child = FormActivity.getRegistryByProperty(parentName, "child");
        if (child != null && !child.trim().equals("") && formObject.optJSONArray(child) != null) {
            JSONArray subFormArray = formObject.optJSONArray(child);
            for (int i = subFormArray.length() - 1; i >= 0; --i) {
                if (subFormArray.optJSONObject(i) != null && subFormArray.optJSONObject(i).optBoolean("hasSubForm", false)) {
                    removeChild(subFormArray.optJSONObject(i).optString("name"));
                }
                try {
                    appendValue = (appendValue == 0) ? -1 : appendValue;
                    mFormWidgetList.remove(elementOrder + i + appendValue);
                } catch (IndexOutOfBoundsException e) {
                    LogUtils.LOGD("Exception Removing ", e.getMessage());
                }
            }
        }
    }

    /**
     * Method to inflate the subForm view from the option selection.
     *
     * @param key Key of the selected item.
     */
    private void inflateSubFormView(String key) {
        JSONObject formObject = FormActivity.getFormObject().optJSONObject("fields");
        if (formObject == null) {
            return;
        }
        setElementOrder();
        removeChild(mFieldName);
        setElementOrder();
        JSONArray subFormArray = formObject.optJSONArray(mFieldName + "_" + key);
        if (subFormArray != null) {
            String append = FormActivity.getAttribByProperty(mFieldName, "uppend", null);
            int appendValue = (append != null && !append.isEmpty()) ? Integer.parseInt(append) : 1;
            for (int i = 0; i < subFormArray.length(); ++i) {
                JSONObject fieldsObject = subFormArray.optJSONObject(i);
                if (fieldsObject != null) {
                    String name = fieldsObject.optString("name");
                    String label = fieldsObject.optString("label");
                    mFormWidget = mFormActivity.getWidget(mContext, name, fieldsObject, label, false, true, null, mFormWidgetList,
                            mFormWidgetMap, currentSelectedModule, null, null, null, null, null, null);
                    if (fieldsObject.has(FormActivity.SCHEMA_KEY_HINT))
                        mFormWidget.setHint(fieldsObject.optString(FormActivity.SCHEMA_KEY_HINT));
                    try {
                        mFormWidgetList.add(elementOrder + i + appendValue, mFormWidget);

                    } catch (IndexOutOfBoundsException e) {
                        LogUtils.LOGD("Exception  Adding", e.getMessage());
                    }
                    mFormWidgetMap.put(name, mFormWidget);
                }
            }
        }
        FormActivity._layout.removeAllViews();
        for (int i = 0; i < mFormWidgetList.size(); i++) {
            FormActivity._layout.addView(mFormWidgetList.get(i).getView());
        }
        FormActivity.setRegistryByProperty(mFieldName, FormActivity.getFormObject().optJSONObject(mFieldName), (!key.equals("")) ? mFieldName + "_" + key : null, "textView", 0);
    }

}
