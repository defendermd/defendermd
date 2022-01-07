package com.socialengineaddons.mobileapp.classes.modules.user.settings;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.CountryCodeUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.core.OTPActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

public class MobileInfoSetting extends AppCompatActivity implements View.OnClickListener {

    private Toolbar mToolbar;
    private Context mContext;
    private AppConstant mAppConst;
    private String actionBarTitle;
    private LinearLayout mobileInfoLayoutContainer, enablePhonenoLayout, addPhonenoLayout;
    private EditText userPhoneno, countryCode, phoneno;
    private TextView tvPhoneno, twoFactorTitle, tvBackButton, tvPageDescription, tvHeaderTitle, tvError;
    private Switch statusSwitch;
    private Button btnVerifyInfo, btnEditPhoneno, btnDeletePhoneno;
    private AlertDialogWithAction alertDialogWithAction;
    private boolean isEditPhoneno = false, isFormVisible = false, isIpAPIExecuted, isRequested;
    private String userPhoneNumber;
    private int enableVerification, otpLength, keyboardType;
    private ImageView ivPageIcon;
    private String countryPhoneCode;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mobile_info_setting);

        mContext = this;
        mAppConst = new AppConstant(this);
        mAppConst.showProgressDialog();
        alertDialogWithAction = new AlertDialogWithAction(mContext);

        if (getIntent() != null) {
            actionBarTitle = getIntent().getStringExtra("title");
            otpLength = getIntent().getIntExtra("otpLength", 6);
            keyboardType = getIntent().getIntExtra("keyboardType", 1);
        }


        mobileInfoLayoutContainer = (LinearLayout) findViewById(R.id.mobile_info_layout_container);
        enablePhonenoLayout = (LinearLayout) findViewById(R.id.enable_phoneno_layout);
        addPhonenoLayout = (LinearLayout) findViewById(R.id.add_phoneno_layout);

        userPhoneno = (EditText) findViewById(R.id.user_phone_no);
        countryCode = (EditText) findViewById(R.id.country_code);
        phoneno = (EditText) findViewById(R.id.phoneno);
        tvPhoneno = (TextView) findViewById(R.id.tv_phoneno);
        twoFactorTitle = (TextView) findViewById(R.id.two_factor_title);
        statusSwitch = (Switch) findViewById(R.id.status_switch);
        btnVerifyInfo = (Button) findViewById(R.id.btn_verify_info);
        btnEditPhoneno = (Button) findViewById(R.id.btn_edit_phoneno);
        btnDeletePhoneno = (Button) findViewById(R.id.btn_delete_phoneno);
        btnVerifyInfo.setOnClickListener(this);
        btnEditPhoneno.setOnClickListener(this);
        btnDeletePhoneno.setOnClickListener(this);
        statusSwitch.setOnClickListener(this);
        tvPageDescription = findViewById(R.id.tvPageDescription);
        ivPageIcon = findViewById(R.id.ivPageIcon);
        tvError = findViewById(R.id.tvError);
        tvHeaderTitle = findViewById(R.id.tvHeaderTitle);
        if (actionBarTitle != null) {
            tvHeaderTitle.setText(actionBarTitle);
        }
        tvBackButton = findViewById(R.id.tvBackButton);
        Drawable arrowBack = ContextCompat.getDrawable(mContext, R.drawable.ic_arrow_back);
        arrowBack.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor),
                PorterDuff.Mode.SRC_ATOP));
        tvBackButton.setCompoundDrawablesWithIntrinsicBounds(arrowBack, null, null, null);
        tvBackButton.setOnClickListener(this);
        Drawable icLockIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_lock_outline);
        icLockIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.black), PorterDuff.Mode.SRC_IN);
        twoFactorTitle.setCompoundDrawablesWithIntrinsicBounds(icLockIcon, null, null, null);
        int drawablePadding = mContext.getResources().getDimensionPixelSize(R.dimen.padding_6dp);
        twoFactorTitle.setCompoundDrawablePadding(drawablePadding);

        Drawable icPhone = ContextCompat.getDrawable(mContext, R.drawable.ic_phone_android);
        icPhone.setColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor), PorterDuff.Mode.SRC_IN);
        userPhoneno.setCompoundDrawablesWithIntrinsicBounds(icPhone, null, null, null);
        userPhoneno.setCompoundDrawablePadding(drawablePadding);

        new IpApi().execute();
        makeRequest();

    }

    private void makeRequest() {

        mAppConst.getJsonResponseFromUrl(UrlUtil.TWO_FACTOR_GET_VERIFICATION_URL, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                if (jsonObject != null) {

                    if (jsonObject.has("form")) {

                        isFormVisible = true;
                        mobileInfoLayoutContainer.setVisibility(View.VISIBLE);
                        enablePhonenoLayout.setVisibility(View.GONE);
                        tvPageDescription.setVisibility(View.GONE);
                        ivPageIcon.setVisibility(View.GONE);
                        tvHeaderTitle.setVisibility(View.GONE);
                        addPhonenoLayout.setVisibility(View.VISIBLE);
                        btnVerifyInfo.setVisibility(View.VISIBLE);
                        countryCode.setText(null);
                        countryCode.setHint(getResources().getString(R.string.two_factor_country_code_hint));
                        phoneno.setHint(getResources().getString(R.string.phone_number_format_hint));
                        if (countryPhoneCode != null) {
                            phoneno.setText(countryPhoneCode + "-");
                            phoneno.setSelection(countryPhoneCode.length() + 1);
                        }
                    } else if (jsonObject.has("response")) {

                        JSONObject resultObject = jsonObject.optJSONObject("response");
                        String userPhone = resultObject.optString("phoneno");
                        String uCountryCode = resultObject.optString("country_code");
                        int enableTwoFactor = resultObject.optInt("enable_verification");

                        if (uCountryCode != null && !uCountryCode.isEmpty() &&
                                userPhone != null && !userPhone.isEmpty()) {
                            userPhoneNumber = "+" + uCountryCode + "-" + userPhone;
                            userPhoneno.setText(userPhoneNumber);
                            tvPhoneno.setText(userPhoneNumber);
                            countryCode.setText(uCountryCode);
                            phoneno.setText(userPhoneNumber);
                            phoneno.setSelection(userPhoneNumber.length());
                        }

                        if (userPhoneno != null) {
                            userPhoneno.setEnabled(false);
                        }

                        if (enableTwoFactor == 1) {
                            statusSwitch.setChecked(true);
                        }

                        mobileInfoLayoutContainer.setVisibility(View.VISIBLE);
                        enablePhonenoLayout.setVisibility(View.VISIBLE);
                        tvPageDescription.setVisibility(View.VISIBLE);
                        ivPageIcon.setVisibility(View.VISIBLE);
                        tvHeaderTitle.setVisibility(View.VISIBLE);
                        addPhonenoLayout.setVisibility(View.GONE);
                        btnVerifyInfo.setVisibility(View.GONE);
                        LogUtils.LOGD(MobileInfoSetting.class.getSimpleName(), "uCountryCode-userPhone-enableTwoFactor-> "
                                + uCountryCode + "-" + userPhone + "-" + enableTwoFactor);
                    }
                }
                if (isIpAPIExecuted) {
                    mAppConst.hideProgressDialog();
                }
                isRequested = true;
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mAppConst.hideProgressDialog();
                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.mobile_info_layout_container), message);
            }
        });
    }

    public void verifyClicked() {

        String text = phoneno.getText().toString();
        if (text.indexOf("-") < 1) {
            tvError.setText(getResources().getString(R.string.phone_number_valid_format));
            tvError.setVisibility(View.VISIBLE);
            return;
        }
        String userPhoneNumber = text.substring(text.indexOf("-") + 1);
        String userCountryCode = text.substring(0, text.indexOf("-"));
        String url = null;

        if (userCountryCode.isEmpty()) {
            tvError.setText(getResources().getString(R.string.two_factor_country_code_msg));

        } else if (userPhoneNumber.isEmpty()) {
            tvError.setError(getResources().getString(R.string.two_factor_phoneno_msg));

        } else {
            mAppConst.showProgressDialog();
            tvError.setVisibility(View.GONE);

            Map<String, String> params = new HashMap<>();
            params.put("country_code", userCountryCode);
            params.put("mobileno", userPhoneNumber);

            if (isEditPhoneno) {
                url = UrlUtil.TWO_FACTOR_EDIT_MOBILE_URL;
            } else {
                url = UrlUtil.TWO_FACTOR_ADD_MOBILE_URL;
            }

            mAppConst.postJsonResponseForUrl(url, params, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mAppConst.hideProgressDialog();
                    LogUtils.LOGD(MobileInfoSetting.class.getSimpleName(), "jsonObject-> " + jsonObject);

                    if (jsonObject != null) {
                        JSONObject resultJson = jsonObject.optJSONObject("response");
                        String country_code = resultJson.optString("country_code");
                        String otpCode = resultJson.optString("code");
                        String phoneno = resultJson.optString("phoneno");
                        int otpDuration = resultJson.optInt("duration");

                        Intent otpIntent = new Intent(mContext, OTPActivity.class);
                        otpIntent.putExtra("user_phoneno", phoneno);
                        otpIntent.putExtra("country_code", country_code);
                        otpIntent.putExtra("otp_duration", otpDuration);
                        otpIntent.putExtra("isEnableTwoFactor", true);
                        otpIntent.putExtra("isEditPhoneno", isEditPhoneno);
                        otpIntent.putExtra("otpLength", otpLength);
                        otpIntent.putExtra("keyboardType", keyboardType);
                        otpIntent.putExtra("otp_code", otpCode);
                        startActivityForResult(otpIntent, ConstantVariables.TWO_FACTOR_ACTIVITY_CODE);
                        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mAppConst.hideProgressDialog();
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.mobile_info_layout_container), message);
                }
            });
        }
    }

    @Override
    public void onBackPressed() {

        if (!(enablePhonenoLayout.getVisibility() == View.VISIBLE) && !isFormVisible) {
            enablePhonenoLayout.setVisibility(View.VISIBLE);
            tvPageDescription.setVisibility(View.VISIBLE);
            ivPageIcon.setVisibility(View.VISIBLE);
            tvHeaderTitle.setVisibility(View.VISIBLE);
            addPhonenoLayout.setVisibility(View.GONE);
            btnVerifyInfo.setVisibility(View.GONE);

        } else {
            super.onBackPressed();
            overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {

            case R.id.btn_edit_phoneno:
                enablePhonenoLayout.setVisibility(View.GONE);
                tvPageDescription.setVisibility(View.GONE);
                ivPageIcon.setVisibility(View.GONE);
                tvHeaderTitle.setVisibility(View.GONE);
                addPhonenoLayout.setVisibility(View.VISIBLE);
                btnVerifyInfo.setVisibility(View.VISIBLE);
                phoneno.setText(userPhoneNumber);
                phoneno.setSelection(userPhoneNumber.length());
                isEditPhoneno = true;
                break;

            case R.id.btn_delete_phoneno:
                showAlertPopup();
                break;

            case R.id.status_switch:
                if (statusSwitch.isChecked()) {
                    enableVerification = 1;
                } else {
                    enableVerification = 0;
                }
                enableDisableTwoFactor(enableVerification);
                break;

            case R.id.btn_verify_info:
                if (GlobalFunctions.isNetworkAvailable(mContext)) {
                    mAppConst.hideKeyboard();
                    verifyClicked();
                } else {
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.mobile_info_layout_container),
                            getResources().getString(R.string.network_connectivity_error));
                }
                break;
            case R.id.tvBackButton:
                onBackPressed();
                break;
        }
    }

    public void showAlertPopup() {
        alertDialogWithAction.showAlertDialogWithAction(mContext.getResources().getString(R.string.two_factor_delete_popup_title),
                mContext.getResources().getString(R.string.two_factor_delete_popup_msg),
                mContext.getResources().getString(R.string.two_factor_popup_delete_btn),
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        mAppConst.showProgressDialog();

                        mAppConst.deleteResponseForUrl(UrlUtil.TWO_FACTOR_DELETE_MOBILE_URL, null, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                                if (jsonObject != null) {
                                    makeRequest();
                                }
                                mAppConst.hideProgressDialog();
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.mobile_info_layout_container), message);
                                mAppConst.hideProgressDialog();
                            }
                        });
                    }
                });
    }

    public void enableDisableTwoFactor(int enableVerification) {

        mAppConst.showProgressDialog();
        Map<String, String> params = new HashMap<>();
        params.put("enable_verification", String.valueOf(enableVerification));

        final int finalSuccessMsg = enableVerification;
        mAppConst.postJsonResponseForUrl(UrlUtil.TWO_FACTOR_ENABLE_DISABLE_URL, params, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {

                mAppConst.hideProgressDialog();
                if (jsonObject != null) {
                    if (finalSuccessMsg == 1) {
                        SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.mobile_info_layout_container),
                                getResources().getString(R.string.two_factor_verification_enabled_msg));

                    } else if (finalSuccessMsg == 0) {
                        SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.mobile_info_layout_container),
                                getResources().getString(R.string.two_factor_verification_disabled_msg));
                    }
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.mobile_info_layout_container), message);
                mAppConst.hideProgressDialog();
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == ConstantVariables.TWO_FACTOR_ACTIVITY_CODE &&
                resultCode == ConstantVariables.TWO_FACTOR_VIEW_PAGE) {
            mAppConst.showProgressDialog();
            makeRequest();
        }
    }

    class IpApi extends AsyncTask<Void, Void, String> {

        @Override
        protected String doInBackground(Void... voids) {
            HttpURLConnection urlConnection = null;
            BufferedReader reader = null;

            String countryInfo = null;

            try {
                String ipInfoUrl = "http://ip-api.com/json";
                URL url = new URL(ipInfoUrl);
                urlConnection = (HttpURLConnection) url.openConnection();
                urlConnection.setRequestMethod("GET");
                urlConnection.connect();

                InputStream inputStream = urlConnection.getInputStream();
                StringBuffer buffer = new StringBuffer();
                if (inputStream == null) {
                    return null;
                }
                reader = new BufferedReader(new InputStreamReader(inputStream));

                String line;
                while ((line = reader.readLine()) != null) {
                    buffer.append(line + "\n");
                }

                if (buffer.length() == 0) {
                    return null;
                }
                countryInfo = buffer.toString();
                return countryInfo;
            } catch (IOException e) {
                return null;
            } finally {
                if (urlConnection != null) {
                    urlConnection.disconnect();
                }
                if (reader != null) {
                    try {
                        reader.close();
                    } catch (final IOException e) {
                    }
                }
            }

        }

        @Override
        protected void onPostExecute(String s) {
            super.onPostExecute(s);
            try {
                if (isRequested) {
                    mAppConst.hideProgressDialog();
                }
                isIpAPIExecuted = true;
                JSONObject jsonObject = new JSONObject(s);
                CountryCodeUtil countryUtil = new CountryCodeUtil();
                countryPhoneCode = countryUtil.getDialerCodeByCountry(jsonObject.optString("countryCode"));
                if (countryPhoneCode != null) {
                    phoneno.setText(countryPhoneCode + "-");
                    phoneno.setSelection(countryPhoneCode.length() + 1);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }
}
