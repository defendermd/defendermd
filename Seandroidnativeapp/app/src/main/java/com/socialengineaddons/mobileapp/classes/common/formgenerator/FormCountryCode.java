package com.socialengineaddons.mobileapp.classes.common.formgenerator;
/*
 *   Copyright (c) 2019 BigStep Technologies Private Limited.
 *
 *   You may not use this file except in compliance with the
 *   SocialEngineAddOns License Agreement.
 *   You may obtain a copy of the License at:
 *   https://www.socialengineaddons.com/android-app-license
 *   The full copyright and license information is also mentioned
 *   in the LICENSE file that was distributed with this
 *   source code.
 */


import android.app.Activity;
import android.content.Context;
import android.graphics.Typeface;
import android.view.View;
import android.widget.TextView;

import com.hbb20.CountryCodePicker;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

import org.json.JSONObject;

/**
 * This widget can be used for rendering country name list, country phone code and phone number with country code
 * with country flags {@link CountryCodePicker Library}.
 */
public class FormCountryCode extends FormWidget {

    private CountryCodePicker ccpElement;

    /**
     * Public constructor to initiate the widget
     *
     * @param context
     * @param property
     * @param hasValidator
     * @param joProperty
     */
    public FormCountryCode(Context context, String property, boolean hasValidator, JSONObject joProperty) {
        super(context, property, hasValidator);

        // Inflate the field view layout.
        View inflateView;
        if (ConstantVariables.FORM_LAYOUT_TYPE == 1) {
            inflateView = ((Activity) context).getLayoutInflater().inflate(R.layout.layout_form_country_code_1, null);
        } else {
            inflateView = ((Activity) context).getLayoutInflater().inflate(R.layout.layout_form_country_code, null);
        }

        getViews(inflateView, joProperty);
        inflateView.setTag(property);
        _layout.addView(inflateView);
        ccpElement.setDefaultCountryUsingPhoneCode(joProperty.optInt("value", 0));
        ccpElement.resetToDefaultCountry();

    }

    private void getViews(View configFieldView, final JSONObject joProperty) {

        ccpElement = configFieldView.findViewById(R.id.ccpElement);
        if (ConstantVariables.FORM_LAYOUT_TYPE != 1) {
            TextView tvLabel = configFieldView.findViewById(R.id.view_label);
            String mLabel = joProperty.optString("label", getDisplayText());
            tvLabel.setText(mLabel);
            tvLabel.setTypeface(Typeface.DEFAULT_BOLD);
            tvLabel.setVisibility(View.VISIBLE);
        }

    }

    @Override
    public String getValue() {
        return ccpElement.getSelectedCountryCode();
    }

    @Override
    public void setValue(String value) {
        if (value != null && !value.isEmpty()) {
            ccpElement.setCountryForNameCode(value);
        }
    }

}
