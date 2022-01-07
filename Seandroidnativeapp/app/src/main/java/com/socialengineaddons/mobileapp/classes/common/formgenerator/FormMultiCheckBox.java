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
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.AppCompatCheckedTextView;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;

/**
 * FormMultiCheckBox is used to inflate the fields for the Multi-CheckBox with the label.
 */

public class FormMultiCheckBox extends FormWidget {

    protected JSONObject jsonObjectOptions;
    protected ArrayList<AppCompatCheckedTextView> mCheckedTextViewList = new ArrayList<>();
    // Member variables.
    private Context mContext;
    private SelectableTextView tvLabel;
    private ArrayAdapter<String> checkBoxAdapter;
    private ArrayList<FormWidget> mFormWidgetList;
    private Map<String, FormWidget> mFormWidgetMap;
    private int elementOrder = 0;
    private String mFieldName;
    private FormActivity mFormActivity;
    private FormWidget mFormWidget;
    private TextView tvError;

    /**
     * Public constructor to inflate form field For the multi checkbox items.
     *
     * @param context      Context of calling class.
     * @param property     Property of the field.
     * @param options      Object with multi options.
     * @param label        Label of the field.
     * @param hasValidator True if the field has validation (Compulsory field).
     * @param description  Description of the field.
     */
    public FormMultiCheckBox(Context context, String property, JSONObject options, String label,
                             boolean hasValidator, String description, ArrayList<FormWidget> widgets,
                             Map<String, FormWidget> map, JSONObject joProperty) {
        super(context, property, hasValidator);

        // Initializing member variables.
        mContext = context;
        jsonObjectOptions = options;
        tvLabel = new SelectableTextView(mContext);

        tvLabel.setText(label);
        tvLabel.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.padding_6dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0);
        if (joProperty.optBoolean("isDisable", false)) {
            tvLabel.setBackgroundColor(mContext.getResources().getColor(R.color.grey_light));
        }
        LinearLayout linearLayout = new LinearLayout(mContext);
        if (ConstantVariables.FORM_LAYOUT_TYPE == 1) {
            LinearLayout.LayoutParams lLayoutParams = CustomViews.getFullWidthLayoutParams();
            lLayoutParams.setMargins(mContext.getResources().getDimensionPixelSize(R.dimen.margin_20dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_20dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp));
            linearLayout.setLayoutParams(lLayoutParams);
            linearLayout.setOrientation(LinearLayout.VERTICAL);
            linearLayout.addView(tvLabel);
            linearLayout.setBackground(ContextCompat.getDrawable(mContext, R.drawable.rounded_widget));

        } else {
            tvLabel.setTypeface(Typeface.DEFAULT_BOLD);
            _layout.addView(tvLabel);
        }

        this.mFormWidgetList = widgets;
        this.mFormWidgetMap = map;
        this.mFieldName = property;
        mFormActivity = new FormActivity();

        //TODO, Uncomment this when ever the description is needed.
        // Showing description text view if description is not empty.
//        if (description != null && !description.isEmpty()) {
//            SelectableTextView tvDescription = new SelectableTextView(mContext);
//            tvDescription.setText(description);
//            tvDescription.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
//                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
//                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0);
//            _layout.addView(tvDescription);
//        }

        JSONArray propertyNames = options.names();
        String name, p;
        checkBoxAdapter = new ArrayAdapter<>(context, android.R.layout.simple_spinner_item);

        // Adding check boxes.
        int id = 0;
        try {
            for (int i = 0; i < options.length(); i++) {
                name = propertyNames.getString(i);
                p = options.getString(name);

                // Adding checked text view.
                if (!p.isEmpty()) {
                    AppCompatCheckedTextView checkedTextView = new AppCompatCheckedTextView(mContext);
                    checkedTextView.setText(p);
                    checkedTextView.setId(id);
                    checkedTextView.setGravity(Gravity.CENTER);
                    checkedTextView.setPadding(0, mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                            0, mContext.getResources().getDimensionPixelSize(R.dimen.padding_11dp));
                    checkedTextView.setCheckMarkDrawable(GlobalFunctions.getCheckMarkDrawable(mContext));
                    mCheckedTextViewList.add(checkedTextView);
                    checkBoxAdapter.add(name);
                    checkedTextView.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_20dp),
                            mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                            mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                            mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp));

                    // Adding bottom line divider.
                    View view = new View(mContext);
                    view.setBackgroundResource(R.color.colordevider);
                    ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                            mContext.getResources().getDimensionPixelSize(R.dimen.divider_line_view_height));
                    view.setLayoutParams(layoutParams);
                    if (ConstantVariables.FORM_LAYOUT_TYPE == 1) {
                        linearLayout.addView(checkedTextView);
                        if (i < (options.length() -1)) linearLayout.addView(view);
                    } else {
                        _layout.addView(checkedTextView);
                        _layout.addView(view);
                    }
                    id++;
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        if (ConstantVariables.FORM_LAYOUT_TYPE == 1) {
            _layout.addView(linearLayout);
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
                tvLabel.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
            }
            if (joProperty.has(ConstantVariables.KEY_RIGHT_DRAWABLE)) {
                Drawable drawable = GlobalFunctions.getDrawableByName(mContext,
                        joProperty.optString(ConstantVariables.KEY_RIGHT_DRAWABLE,
                                ConstantVariables.KEY_RIGHT_DRAWABLE));
                tvLabel.setCompoundDrawablesWithIntrinsicBounds(null, null, drawable, null);

            }
            tvLabel.setCompoundDrawablePadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp));
            tvLabel.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_10dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_6dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0);

        }
        // Listener to mark check box as checked/unchecked.
        if (mCheckedTextViewList != null && mCheckedTextViewList.size() > 0) {
            for (int i = 0; i < mCheckedTextViewList.size(); i++) {
                final int finalI = i;
                mCheckedTextViewList.get(i).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        tvLabel.setError(null);

                        try {
                            boolean checked = mCheckedTextViewList
                                    .get(finalI).isChecked();
                            inflateSubFormView(checkBoxAdapter.getItem(finalI), !checked);
                            mCheckedTextViewList.get(finalI).setChecked(!checked);
                        } catch (Exception e) {
                            e.printStackTrace();
                            mCheckedTextViewList.get(finalI).setChecked(!mCheckedTextViewList
                                    .get(finalI).isChecked());
                        }
                    }
                });
            }
        }
    }

    @Override
    public String getValue() {

        String returnValues = "";

        for (int i = 0; i < mCheckedTextViewList.size(); i++) {

            int arrayLength = (mCheckedTextViewList.size()) - 1;

            if (mCheckedTextViewList.get(i).isChecked()) {
                AppCompatCheckedTextView checkBox = mCheckedTextViewList.get(i);
                String value = checkBoxAdapter.getItem(checkBox.getId());
                if (i < arrayLength) {
                    returnValues += value + ",";
                } else {
                    returnValues += value;
                }
            }
        }

        return returnValues;
    }

    @Override
    public void setValue(String value) {
        try {
            if (value != null && !value.isEmpty()) {

                Object json = new JSONTokener(value).nextValue();
                /* If Values are coming in form of JsonObject */
                if (json instanceof JSONObject) {
                    JSONObject valuesObject = (JSONObject) json;
                    if (valuesObject != null && valuesObject.length() != 0) {
                        JSONArray valueIds = valuesObject.names();

                        for (int i = 0; i < valueIds.length(); i++) {

                            String checkBoxId = valueIds.optString(i);
                            String checkBoxName = valuesObject.optString(checkBoxId);
                            String item = jsonObjectOptions.optString(checkBoxName);

                            if (item != null && !item.isEmpty()) {
                                AppCompatCheckedTextView checkBox = mCheckedTextViewList.get(checkBoxAdapter.getPosition(checkBoxName));
                                checkBox.setChecked(true);
                            }
                        }
                    }
                }
                /* If Values are coming in form of JsonArray */
                else if (json instanceof JSONArray) {
                    JSONArray valuesArray = (JSONArray) json;
                    for (int i = 0; i < valuesArray.length(); i++) {

                        String checkBoxName = valuesArray.optString(i);
                        String item = jsonObjectOptions.optString(checkBoxName);

                        if (item != null && !item.isEmpty()) {
                            AppCompatCheckedTextView checkBox = mCheckedTextViewList.get(checkBoxAdapter.getPosition(checkBoxName));
                            checkBox.setChecked(true);
                        }
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void setErrorMessage(String errorMessage) {
        if (ConstantVariables.FORM_LAYOUT_TYPE == 1 && tvError != null) {
            tvError.setVisibility(View.VISIBLE);
            tvError.setText(errorMessage);
        } else {
            tvLabel.setError(errorMessage);
            tvLabel.setFocusable(true);
            tvLabel.requestFocus();
        }
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
    private void removeChild(String parentName, String keyName) {
        JSONObject multiChild = FormActivity.getRegistryByProperty(parentName, "multiChild", "multicheckbox");
        if (multiChild != null) {
            int order = multiChild.optInt(keyName, -1);
            if (order > 0) {
                mFormWidgetList.remove(order);
            }
            multiChild.remove(keyName);
            multiChild = FormActivity.updateMultiChild(multiChild, -1, order);
            FormActivity.setMultiChild(parentName, "multiChild", multiChild);
        }
    }

    /**
     * Method to inflate the subForm view from the option selection.
     *
     * @param key Key of the selected item.
     */
    private void inflateSubFormView(String key, boolean isChecked) {
        JSONObject formObject = FormActivity.getFormObject().optJSONObject("fields");
        setElementOrder();
        if (formObject == null) {
            return;
        }
        JSONArray subFormArray = formObject.optJSONArray(mFieldName + "_" + key);
        if (subFormArray != null && isChecked) {
            for (int i = 0; i < subFormArray.length(); ++i) {
                JSONObject fieldsObject = subFormArray.optJSONObject(i);
                if (fieldsObject != null) {
                    String name = fieldsObject.optString("name");
                    String label = fieldsObject.optString("label");
                    boolean hasValidator = fieldsObject.optBoolean("hasValidator", false);
                    mFormWidget = mFormActivity.getWidget(mContext, name, fieldsObject, label, hasValidator, true, null, mFormWidgetList,
                            mFormWidgetMap, "selected_module", null, null, null, null, null, null);
                    if (fieldsObject.has(FormActivity.SCHEMA_KEY_HINT))
                        mFormWidget.setHint(fieldsObject.optString(FormActivity.SCHEMA_KEY_HINT));
                    try {
                        mFormWidgetList.add(elementOrder + i + 1, mFormWidget);
                        FormActivity.setRegistryByProperty(mFieldName, FormActivity.getFormObject().optJSONObject(mFieldName), (!key.equals("")) ? mFieldName + "_" + key : null, "MultiCheckbox", elementOrder + i + 1);
                    } catch (IndexOutOfBoundsException e) {
                        LogUtils.LOGD("Exception  Adding", e.getMessage());
                    }
                    mFormWidgetMap.put(name, mFormWidget);
                }
            }
        } else {
            removeChild(mFieldName, mFieldName + "_" + key);
        }
        FormActivity._layout.removeAllViews();
        for (int i = 0; i < mFormWidgetList.size(); i++) {
            FormActivity._layout.addView(mFormWidgetList.get(i).getView());
        }

    }

}
