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

import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.AppCompatCheckedTextView;
import android.support.v7.widget.AppCompatTextView;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.BrowseMemberAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

import org.json.JSONArray;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.Map;

/**
 * FormCheckBox is used to inflate the fields for the Check box.
 */

public class FormCheckBox extends FormWidget implements View.OnClickListener {

    // Member variables.
    private Context mContext;
    private AppCompatCheckedTextView checkedTextView;
    private AppConstant mAppConst;
    private ArrayList<FormWidget> widgets;
    private AlertDialogWithAction mAlertDialogWithAction;
    private TextView tvError;

    private ArrayList<FormWidget> mFormWidgetList;
    private Map<String, FormWidget> mFormWidgetMap;
    private int elementOrder = 0;
    private String mFieldName, mCurrentSelectedModule;
    private FormActivity mFormActivity;
    private FormWidget mFormWidget;

    /**
     * Public constructor to inflate form field For the checkbox items.
     *
     * @param context               Context of calling class.
     * @param joProperty            Property of the field.
     * @param _widget               List of FormWidget.
     * @param currentSelectedModule Current selected module.
     */
    public FormCheckBox(Context context, final JSONObject joProperty, ArrayList<FormWidget> _widget, String currentSelectedModule, Map<String, FormWidget> map) {
        super(context, joProperty.optString("name"), joProperty.optBoolean("hasValidator"));

        // Initializing member variables.
        mContext = context;
        mAppConst = new AppConstant(mContext);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        widgets = _widget;
        this.mFormWidgetList = _widget;
        this.mFormWidgetMap = map;
        this.mFieldName = joProperty.optString("name");
        this.mCurrentSelectedModule = currentSelectedModule;
        mFormActivity = new FormActivity();
        int defaultValue = joProperty.optInt("value", 0);
        // Added description when it is coming for these paritcular modules.
        if (!FormActivity.sIsAddToDiaryDescription
                && ((currentSelectedModule.equals(ConstantVariables.ADD_TO_DIARY) && (mFieldName.contains("diary") || mFieldName.contains("Diary")))
                || (currentSelectedModule.equals(ConstantVariables.ADD_TO_WISHLIST) && mFieldName.contains("wishlist"))
                || (currentSelectedModule.equals("add_to_friend_list"))
                || (currentSelectedModule.equals("add_to_playlist") && mFieldName.contains("inplaylist")))) {
            
            AppCompatTextView textView = new AppCompatTextView(context);
            int padding = (int) mContext.getResources().getDimension(R.dimen.padding_6dp);
            textView.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp), padding);
            textView.setText(FormActivity.addToDiaryDescription);
            _layout.addView(textView);
            FormActivity.sIsAddToDiaryDescription = true;
        }

        checkedTextView = new AppCompatCheckedTextView(mContext);
        checkedTextView.setText(joProperty.optString("label"));
        checkedTextView.setGravity(Gravity.CENTER);
        checkedTextView.setCheckMarkDrawable(GlobalFunctions.getCheckMarkDrawable(mContext));

        switch (mFieldName) {
            case "monthlyType":
                checkedTextView.setId(R.id.monthly_type);
                checkedTextView.setTag(mFieldName);
                checkedTextView.setChecked(defaultValue != 0);
                break;

            case "host_link":
                checkedTextView.setId(R.id.social_link);
                checkedTextView.setTag(R.id.social_link);
                break;

            case "isCopiedDetails":
                checkedTextView.setTag("copy_purchaser_info");
                break;

            default:
                checkedTextView.setId(R.id.form_checkbox);
                checkedTextView.setTag(mFieldName);
                break;
        }
        if (mFieldName.equals("host_link") && FormHostChange.sIsEditHost && defaultValue != 0) {
            checkedTextView.setChecked(true);
        } else {
            checkedTextView.setChecked(defaultValue != 0);
        }
        if (ConstantVariables.FORM_LAYOUT_TYPE == 1) {
            checkedTextView.setBackground(ContextCompat.getDrawable(mContext, R.drawable.rounded_widget));
            checkedTextView.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_15dp));
            RelativeLayout.LayoutParams layoutParams = CustomViews.getFullWidthRelativeLayoutParams();
            layoutParams.setMargins(mContext.getResources().getDimensionPixelSize(R.dimen.margin_20dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_20dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp));
            checkedTextView.setLayoutParams(layoutParams);
            checkedTextView.setTextColor(mContext.getResources().getColor(R.color.gray_text_color));

        } else {
            checkedTextView.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp));
        }
        /**
         * Add Cross icon on Add To List page to delete Lists (Add to List which comes on Friends tab of
         * member profile page).
         */
        if (currentSelectedModule.equals("add_to_friend_list")) {

            RelativeLayout listLayout = new RelativeLayout(context);
            listLayout.setId(R.id.property);

            RelativeLayout.LayoutParams layoutParams = CustomViews.getFullWidthRelativeLayoutParams();
            listLayout.setLayoutParams(layoutParams);
            listLayout.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0,
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0);

            TextView textView = new TextView(context);
            RelativeLayout.LayoutParams textViewParams = CustomViews.getFullWidthRelativeLayoutParams();

            textViewParams.addRule(RelativeLayout.ALIGN_PARENT_END, R.id.property);
            textViewParams.addRule(RelativeLayout.RIGHT_OF, R.id.form_checkbox);

            int paddingLeft = (int) mContext.getResources().getDimension(R.dimen.padding_5dp);
            int paddingRight = (int) mContext.getResources().getDimension(R.dimen.padding_30dp);

            textView.setPadding(paddingLeft, paddingLeft, paddingRight, paddingLeft);

            textView.setLayoutParams(textViewParams);
            textView.setTag(mFieldName);
            textView.setGravity(Gravity.END);
            textView.setOnClickListener(this);

            Typeface fontIcon = GlobalFunctions.getFontIconTypeFace(mContext);
            textView.setTypeface(fontIcon);
            textView.setText("\uf00d");

            listLayout.setTag(mFieldName);

            listLayout.addView(checkedTextView);
            listLayout.addView(textView);

            _layout.addView(listLayout);
            _layout.setTag(mFieldName);

        }  else {
            _layout.addView(checkedTextView);
        }

        // Adding bottom line divider.
        if (ConstantVariables.FORM_LAYOUT_TYPE != 1) {
            View view = new View(mContext);
            view.setBackgroundResource(R.color.colordevider);
            ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    mContext.getResources().getDimensionPixelSize(R.dimen.divider_line_view_height));
            view.setLayoutParams(layoutParams);
            _layout.addView(view);
        } else {
            tvError = new TextView(context);
            RelativeLayout.LayoutParams rlParams = CustomViews.getFullWidthRelativeLayoutParams();
            rlParams.addRule(RelativeLayout.CENTER_IN_PARENT, R.id.property);
            rlParams.addRule(RelativeLayout.BELOW, R.id.form_checkbox);
            tvError.setLayoutParams(rlParams);
            tvError.setTextColor(mContext.getResources().getColor(R.color.red_color_picker));
            tvError.setVisibility(View.GONE);
            tvError.setGravity(Gravity.CENTER                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           );
            _layout.addView(tvError);

            if (joProperty.has(ConstantVariables.KEY_LEFT_DRAWABLE)) {
                Drawable drawable = GlobalFunctions.getDrawableByName(mContext,
                        joProperty.optString(ConstantVariables.KEY_LEFT_DRAWABLE,
                                ConstantVariables.KEY_LEFT_DRAWABLE));
                checkedTextView.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
            }
            if (joProperty.has(ConstantVariables.KEY_RIGHT_DRAWABLE)) {
                Drawable drawable = GlobalFunctions.getDrawableByName(mContext,
                        joProperty.optString(ConstantVariables.KEY_RIGHT_DRAWABLE,
                                ConstantVariables.KEY_RIGHT_DRAWABLE));
                checkedTextView.setCompoundDrawablesWithIntrinsicBounds(null, null, drawable, null);

            }
            checkedTextView.setCompoundDrawablePadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp));
        }

        // Applying click listener on the check box to mark checkbox as checked/unchecked.
        checkedTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                checkedTextView.setError(null);
                if (tvError != null) tvError.setVisibility(View.GONE);

                if (joProperty.optBoolean("hasSubForm", false)) {
                    if (checkedTextView.isChecked()){
                        inflateSubFormView("0");
                    } else {
                        inflateSubFormView("1");
                    }
                }
                checkedTextView.setChecked(!checkedTextView.isChecked());
                checkModuleSpecificConditions(view);
            }
        });

    }

    /**
     * Method to check module specific conditions on the checkbox click.
     *
     * @param view Clicked check box view.
     */
    private void checkModuleSpecificConditions(View view) {

        if (view.getId() == R.id.social_link && FormActivity.loadEditHostForm > 0) {
            for (int i = 0; i < widgets.size(); i++) {
                if (widgets.get(i).getPropertyName().equals("host_facebook") ||
                        widgets.get(i).getPropertyName().equals("host_twitter") ||
                        widgets.get(i).getPropertyName().equals("host_website")) {
                    if (checkedTextView.isChecked()) {
                        widgets.get(i).getView().setVisibility(View.VISIBLE);
                    } else {
                        widgets.get(i).getView().setVisibility(View.GONE);
                    }

                }
            }
        } else if (view.getTag() != null && view.getTag().toString().equals("copy_purchaser_info")) {
            String fName = "", lName = "", email = "";
            for (int i = 0; i < widgets.size(); i++) {
                switch (widgets.get(i).getPropertyName()) {
                    case "fname":
                        fName = widgets.get(i).getValue();
                        break;
                    case "lname":
                        lName = widgets.get(i).getValue();
                        break;
                    case "email":
                        email = widgets.get(i).getValue();
                        break;
                }
                if (checkedTextView.isChecked()) {
                    if (widgets.get(i).getPropertyName().contains("fname_")) {
                        widgets.get(i).setValue(fName);
                    } else if (widgets.get(i).getPropertyName().contains("lname_")){
                        widgets.get(i).setValue(lName);
                    } else if (widgets.get(i).getPropertyName().contains("email_")) {
                        widgets.get(i).setValue(email);
                    }
                } else {
                    if (widgets.get(i).getPropertyName().contains("fname_") ||
                            widgets.get(i).getPropertyName().contains("lname_") ||
                            widgets.get(i).getPropertyName().contains("email_")) {
                        widgets.get(i).setValue("");
                    }
                }
            }
        }

    }

    @Override
    public String getValue() {
        return String.valueOf(checkedTextView.isChecked() ? "1" : "0");
    }

    @Override
    public void setValue(String value) {
        checkedTextView.setChecked(value.equals("1"));
        if (checkedTextView.getId() == R.id.monthly_type) {
            checkedTextView.setTag(value);
        }
    }

    @Override
    public void setErrorMessage(String errorMessage) {

        // Showing error message.
        if (!checkedTextView.isChecked() && errorMessage != null) {
            if (ConstantVariables.FORM_LAYOUT_TYPE == 1 && tvError != null) {
                tvError.setVisibility(View.VISIBLE);
                tvError.setText(errorMessage);
            } else {
                checkedTextView.setError(errorMessage);
                checkedTextView.setFocusable(true);
                checkedTextView.requestFocus();
            }
        }
    }

    @Override
    public void onClick(final View v) {

        /**
         * Work to delete the friends list on Add to List page.
         *
         */
        final String list_id = v.getTag().toString();

        final String actionUrl = AppConstant.DEFAULT_URL + "user/list-delete?list_id=" + list_id +
                "&friend_id=" + BrowseMemberAdapter.sFriendId;

        mAlertDialogWithAction.showAlertDialogWithAction(mContext.getResources().getString(R.string.delete_list_title),
                mContext.getResources().getString(R.string.delete_list_dialogue_message),
                mContext.getResources().getString(R.string.delete_list_title),
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {

                        mAppConst.showProgressDialog();
                        mAppConst.deleteResponseForUrl(actionUrl, null, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) {
                                mAppConst.hideProgressDialog();
                                /* Show Message */
                                SnackbarUtils.displaySnackbarLongTime(_layout,
                                        mContext.getResources().getString(R.string.successful_submit));
                                View view = _layout.findViewById(R.id.property);
                                _layout.removeView(view);

                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                mAppConst.hideProgressDialog();
                            }
                        });
                    }
                });
    }

    /**
     * Method to set the order of the selected parent element.
     */
    public void setElementOrder(){
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
    private void removeChild(String parentName){
        JSONObject formObject = FormActivity.getFormObject().optJSONObject("fields");
        String child = FormActivity.getRegistryByProperty(parentName,"child");
        if(child != null && !child.trim().equals("") && formObject.optJSONArray(child) != null){
            JSONArray subFormArray = formObject.optJSONArray(child);
            for (int i = subFormArray.length()-1; i >= 0 ; --i) {
                if(subFormArray.optJSONObject(i) != null && subFormArray.optJSONObject(i).optBoolean("hasSubForm",false)){
                    removeChild(subFormArray.optJSONObject(i).optString("name"));
                }
                try{
                    mFormWidgetList.remove(elementOrder + i + 1);
                }catch (IndexOutOfBoundsException e){
                    LogUtils.LOGD("Exception Removing ",e.getMessage());
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
        JSONArray subFormArray = formObject.optJSONArray(mFieldName+"_"+key);
        if(subFormArray != null) {
            for (int i = 0; i < subFormArray.length(); ++i) {
                JSONObject fieldsObject = subFormArray.optJSONObject(i);
                if (fieldsObject != null) {
                    String name = fieldsObject.optString("name");
                    String label = fieldsObject.optString("label");
                    boolean hasValidator = fieldsObject.optBoolean("hasValidator", false);
                    mFormWidget = mFormActivity.getWidget(mContext, name, fieldsObject, label, hasValidator, true, null, mFormWidgetList,
                            mFormWidgetMap, mCurrentSelectedModule, null, null, null, null, null, null);
                    if (fieldsObject.has(FormActivity.SCHEMA_KEY_HINT))
                        mFormWidget.setHint(fieldsObject.optString(FormActivity.SCHEMA_KEY_HINT));
                    try{
                        mFormWidgetList.add(elementOrder+i+1, mFormWidget);
                    }catch (IndexOutOfBoundsException e){
                        LogUtils.LOGD("Exception  Adding",e.getMessage());
                    }
                    mFormWidgetMap.put(name, mFormWidget);
                }
            }
        }
        FormActivity._layout.removeAllViews();
        for (int i = 0; i < mFormWidgetList.size(); i++) {
            FormActivity._layout.addView(mFormWidgetList.get(i).getView());
        }
        FormActivity.setRegistryByProperty(mFieldName,FormActivity.getFormObject().optJSONObject(mFieldName),(!key.equals("")) ? mFieldName+"_"+key : null, "Checkbox", 0);
    }

}
