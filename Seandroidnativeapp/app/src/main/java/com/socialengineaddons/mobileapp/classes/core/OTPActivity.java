package com.socialengineaddons.mobileapp.classes.core;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.text.Editable;
import android.text.InputFilter;
import android.text.InputType;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.receiver.SMSReceiver;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SocialLoginUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.modules.user.settings.MemberSettingsActivity;
import com.socialengineaddons.mobileapp.classes.modules.user.signup.SignupPhotoActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class OTPActivity extends AppCompatActivity implements View.OnClickListener, OnUploadResponseListener {

    private CountDownTimer countTimer = null;
    private Context mContext;
    private AppConstant mAppConst;
    private StringBuilder otpCode;
    private Button otpVerifyButton;
    private TextView resendOtp, otpTimer, tvBackButton, tvError;
    private String userPhoneNo, countryCode;
    private Bundle bundle;
    private String intentAction, intentType;
    private String userLoginEmail, userLoginPass;
    private int loginWithOtp = 0, otpDuration = 0;
    private String mPackageId, mVerificationCode, emailAddress, password, sentTime,
            loginType;
    private Bundle mFbTwitterBundle;
    private AlertDialogWithAction mAlertDialogWithAction;
    private Map<String, String> mPostParams;
    private HashMap<String, String> mAccountFormValues, mSignupParams;
    private boolean isPhotoStep = false, mHasProfileFields = true, isForgotPassword = false,
            isEnableOtp = false, isEditPhoneno = false, isEnableTwoFactor = false;
    private LinearLayout llVerificationWrapper;
    private int otpLength, keyboardType;

    public static String getCurrentDateTime() {
        //for getting current date and time
        DateFormat dfDate = new SimpleDateFormat("yyyy-MM-dd");
        String date = dfDate.format(Calendar.getInstance().getTime());
        DateFormat dfTime = new SimpleDateFormat("HH:mm:ss");
        String time = dfTime.format(Calendar.getInstance().getTime());
        return date + " " + time;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_otp);

        mContext = this;
        mAppConst = new AppConstant(this);
        otpCode = new StringBuilder();
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);

        bundle = getIntent().getExtras().getBundle("mBundle");

        if (bundle != null) {
            intentAction = getIntent().getAction();
            intentType = getIntent().getType();
        }

        userPhoneNo = getIntent().getStringExtra("user_phoneno");
        countryCode = getIntent().getStringExtra("country_code");
        userLoginEmail = getIntent().getStringExtra("user_login_email");
        userLoginPass = getIntent().getStringExtra("user_login_pass");
        otpLength = getIntent().getIntExtra("otpLength", 6);
        keyboardType = getIntent().getIntExtra("keyboardType", 1);

        if (PreferencesUtils.getOtpEnabledOption(mContext) != null
                && PreferencesUtils.getOtpEnabledOption(mContext).equals("both")) {
            loginWithOtp = 1;
        }

        //for signup otp process
        mPackageId = getIntent().getStringExtra("package_id");
        isPhotoStep = getIntent().getBooleanExtra("isPhotoStep", false);
        isEnableOtp = getIntent().getBooleanExtra("isEnableOtp", false);
        mHasProfileFields = getIntent().getBooleanExtra("mHasProfileFields", true);
        mFbTwitterBundle = getIntent().getBundleExtra("fb_twitter_info");
        mVerificationCode = getIntent().getStringExtra("otp_code");
        otpDuration = getIntent().getIntExtra("otp_duration", 0);
        sentTime = getIntent().getStringExtra("sent_time");

        mAccountFormValues = (HashMap<String, String>) getIntent().getSerializableExtra("account_form_values");
        mSignupParams = (HashMap<String, String>) getIntent().getSerializableExtra("field_form_values");

        isEditPhoneno = getIntent().getBooleanExtra("isEditPhoneno", false);
        isEnableTwoFactor = getIntent().getBooleanExtra("isEnableTwoFactor", false);
        isForgotPassword = getIntent().getBooleanExtra("isForgotPassword", false);

        if (mAccountFormValues != null) {
            emailAddress = mAccountFormValues.get("email");
            password = mAccountFormValues.get("password");
        }
        if (mFbTwitterBundle != null) {
            loginType = mFbTwitterBundle.getString("loginType");
        }

        otpVerifyButton = findViewById(R.id.otp_verify_button);
        resendOtp = findViewById(R.id.resend_otp);
        otpTimer = findViewById(R.id.otp_timer);
        tvBackButton = findViewById(R.id.tvBackButton);
        Drawable arrowBack = ContextCompat.getDrawable(mContext, R.drawable.ic_arrow_back);
        arrowBack.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor),
                PorterDuff.Mode.SRC_ATOP));
        tvBackButton.setCompoundDrawablesWithIntrinsicBounds(arrowBack, null, null, null);
        tvBackButton.setOnClickListener(this);
        tvError = findViewById(R.id.tvError);
        llVerificationWrapper = findViewById(R.id.verification_code_layout);

        otpVerifyButton.setOnClickListener(this);
        resendOtp.setOnClickListener(this);
        if(!mAppConst.checkManifestPermission(Manifest.permission.RECEIVE_SMS)){
            mAppConst.requestForManifestPermission(Manifest.permission.RECEIVE_SMS,
                    ConstantVariables.RECEIVE_SMS);
        }
        showOtpTimer(otpDuration);
        generateEditBoxes(otpLength);

        SMSReceiver.bindListener(null, verificationCode -> {
            if (verificationCode.contains(mVerificationCode)) {
                for (int i = 0; i < mVerificationCode.length(); ++i) {
                    EditText etBox = llVerificationWrapper.findViewWithTag(i);
                    if (etBox != null) {
                        etBox.setText(String.valueOf(mVerificationCode.charAt(i)));
                    }
                }
            }

        });
    }

    private void generateEditBoxes(int boxCount) {
        for (int i = 0; i < boxCount; ++i) {
            EditText etCode = new EditText(mContext);
            etCode.setTag(i);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_45dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_50dp));
            layoutParams.setMargins(mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.margin_5dp));
            etCode.setLayoutParams(layoutParams);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                etCode.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
            }
            etCode.setFilters(new InputFilter[]{
                    new InputFilter.LengthFilter(1)
            });
            if (keyboardType == 0) {
                etCode.setInputType(InputType.TYPE_CLASS_PHONE);
            }
            etCode.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                }

                @Override
                public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                    if (charSequence != null && !charSequence.toString().trim().isEmpty() && charSequence.toString().length() >= 1) {
                        int currentIndex = Integer.parseInt(etCode.getTag().toString());
                        if (currentIndex == (otpLength - 1)) {
                            mAppConst.hideKeyboard();
                        } else {
                            setCurrentFocus(currentIndex + 1, false);
                        }
                    }
                }

                @Override
                public void afterTextChanged(Editable editable) {

                }
            });

            etCode.setOnKeyListener((v, keyCode, event) -> {
                if(keyCode == KeyEvent.KEYCODE_DEL) {
                    int currentIndex = Integer.parseInt(v.getTag().toString());
                    if (currentIndex > 0) {
                        setCurrentFocus(currentIndex, true);
                    }
                }
                return false;
            });

            etCode.setBackgroundColor(mContext.getResources().getColor(R.color.fragment_background));
            llVerificationWrapper.addView(etCode);
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }

    public void showOtpTimer(int otpDuration) {
        if (otpDuration != 0) {
            resendOtp.setVisibility(View.GONE);
            otpTimer.setVisibility(View.VISIBLE);
            countTimer = new CountDownTimer(otpDuration * 1000, 1000) {

                public void onTick(long millisUntilFinished) {

                    long minDifference = millisUntilFinished / 1000 / 60;
                    long secDifference = (millisUntilFinished - minDifference * 60000) / 1000;
                    otpTimer.setText(mContext.getResources().getString(R.string.resent_otp_in_time) + " " + minDifference + " : " + ((secDifference < 10) ? "0" + secDifference : secDifference));
                }

                public void onFinish() {
                    otpTimer.setText(getResources().getString(R.string.otp_timer_done_msg));
                    resendOtp.setVisibility(View.VISIBLE);
                    otpTimer.setVisibility(View.GONE);
                }

            }.start();
        }

    }


    private void setCurrentFocus(int boxIndex, boolean isRemove) {

        if (isRemove) {
            EditText clearBox = llVerificationWrapper.findViewWithTag(boxIndex);
            if (clearBox != null) {
                clearBox.setText("");
            }
            boxIndex--;
        }

        EditText etBox = llVerificationWrapper.findViewWithTag(boxIndex);
        if (etBox != null) {
            etBox.requestFocus();
        }
    }

    public void verifyClicked() {
        int boxCount = otpLength;
        otpCode = new StringBuilder();
        for (int i = 0; i < boxCount; ++i) {
            EditText etBox = llVerificationWrapper.findViewWithTag(i);
            if (etBox != null) {
                otpCode.append(etBox.getText());
            }
        }

        if (otpCode.toString().isEmpty() || otpCode.toString().length() < boxCount) {
            tvError.setText(getResources().getString(R.string.otp_validation_error));
            tvError.setVisibility(View.VISIBLE);
        } else {
            mAppConst.showProgressDialog();
            tvError.setVisibility(View.GONE);

            if (isEnableOtp) {
                verifySignupOTP(otpCode.toString());

            } else if (isEnableTwoFactor) {
                verifyTwoFactorOTP(otpCode.toString());

            } else if (isForgotPassword) {
                verifyForgotPasswordOTP(otpCode.toString());

            } else {

                Map<String, String> params = new HashMap<>();
                params.put("code", otpCode.toString());
                params.put("email", userLoginEmail);
                params.put("password", userLoginPass);
                params.put("loginWithOtp", String.valueOf(loginWithOtp));
                params.put("ip", GlobalFunctions.getLocalIpAddress());

                mAppConst.postLoginSignUpRequest(UrlUtil.LOGIN_URL, params, new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                        mAppConst.hideProgressDialog();
                        mAppConst.proceedToUserLogin(mContext, bundle, intentAction, intentType,
                                userLoginEmail, userLoginPass, jsonObject);
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main), message);
                        mAppConst.hideProgressDialog();
                    }
                });
            }
        }
    }

    public void verifySignupOTP(String otpCode) {

        String currentTime = getCurrentDateTime();
        int otpEnteredDuration = GlobalFunctions.secondsDifferenceFromEndDate(sentTime, currentTime);

        if (otpCode.equals(mVerificationCode)) {

            if (otpEnteredDuration <= otpDuration) {

                if (isPhotoStep) {
                    Intent photoIntent = new Intent(mContext, SignupPhotoActivity.class);

                    /* facebook and send details to SignUpPhotoActivity */
                    if (mFbTwitterBundle != null && !mFbTwitterBundle.isEmpty()) {
                        photoIntent.putExtra("fb_twitter_info", mFbTwitterBundle);
                    }
                    photoIntent.putExtra("package_id", mPackageId);
                    photoIntent.putExtra("account_form_values", mAccountFormValues);
                    photoIntent.putExtra("field_form_values", mSignupParams);
                    finish();
                    if (mHasProfileFields) {
                        startActivity(photoIntent);
                    } else {
                        mAppConst.hideProgressDialog();
                        startActivityForResult(photoIntent, ConstantVariables.SIGN_UP_CODE);
                    }
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

                } else {
                    postSignupForm();
                }

            } else {
                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main),
                        getResources().getString(R.string.otp_expires_msg));
                mAppConst.hideProgressDialog();
            }
        } else {
            tvError.setText(getResources().getString(R.string.otp_invalid_error_msg));
            tvError.setVisibility(View.VISIBLE);
            mAppConst.hideProgressDialog();
        }

    }

    public void verifyTwoFactorOTP(String otpCode) {

        String type = null;
        if (isEditPhoneno) {
            type = "edit";
        } else {
            type = "add";
        }
        mAppConst.showProgressDialog();
        Map<String, String> params = new HashMap<>();
        params.put("code", otpCode);
        params.put("type", type);

        mAppConst.postJsonResponseForUrl(UrlUtil.TWO_FACTOR_OTP_VERIFICATION_URL, params, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                mAppConst.hideProgressDialog();

                if (jsonObject != null) {
                    setResult(ConstantVariables.TWO_FACTOR_VIEW_PAGE);
                    finish();
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mAppConst.hideProgressDialog();
                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main), message);
            }
        });

    }

    public void verifyForgotPasswordOTP(final String otpCode) {

        Map<String, String> params = new HashMap<>();
        params.put("email", userPhoneNo);
        params.put("code", otpCode);

        mAppConst.postJsonResponseForUrl(UrlUtil.FORGOT_PASSWORD_OTP_VERIFY_URL, params, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                mAppConst.hideProgressDialog();

                if (jsonObject != null) {

                    Intent resetPassword = new Intent(mContext, MemberSettingsActivity.class);
                    resetPassword.putExtra("selected_option", "reset_password");
                    resetPassword.putExtra("title", getResources().getString(R.string.reset_password_title));
                    resetPassword.putExtra("url", UrlUtil.FORGOT_PASSWORD_RESET_URL);
                    resetPassword.putExtra("emailValue", jsonObject.optJSONObject("response").optString("email"));
                    resetPassword.putExtra("code", otpCode);
                    finish();
                    startActivity(resetPassword);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mAppConst.hideProgressDialog();
                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main), message);
            }
        });

    }

    public void resendOTP() {

        mAppConst.showProgressDialog();
        final Map<String, String> params = new HashMap<>();

        if (isEnableOtp) {
            params.put("country_code", countryCode);
            params.put("phoneno", userPhoneNo);

            mAppConst.postLoginSignUpRequest(UrlUtil.SIGNUP_OTP_SEND_URL, params, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mAppConst.hideProgressDialog();

                    if (jsonObject != null) {
                        mVerificationCode = jsonObject.optJSONObject("response").optString("code");
                        sentTime = getCurrentDateTime();
                        SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main),
                                getResources().getString(R.string.otp_resend_success_msg));
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main), message);
                }
            });

        } else if (isEnableTwoFactor) {
            params.put("country_code", countryCode);
            params.put("mobileno", userPhoneNo);

            mAppConst.postJsonResponseForUrl(UrlUtil.TWO_FACTOR_EDIT_MOBILE_URL, params, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mAppConst.hideProgressDialog();

                    if (jsonObject != null) {
                        SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main),
                                getResources().getString(R.string.otp_resend_success_msg));
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mAppConst.hideProgressDialog();
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main), message);
                }
            });

        } else if (isForgotPassword) {
            params.put("email", userPhoneNo);

            mAppConst.postJsonResponseForUrl(UrlUtil.FORGOT_PASSWORD_OTP_URL, params, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mAppConst.hideProgressDialog();

                    if (jsonObject != null) {
                        SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main),
                                getResources().getString(R.string.otp_resend_success_msg));
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mAppConst.hideProgressDialog();
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main), message);
                }
            });

        } else {
            params.put("email", userLoginEmail);
            params.put("password", userLoginPass);
            params.put("ip", GlobalFunctions.getLocalIpAddress());

            mAppConst.postLoginSignUpRequest(UrlUtil.LOGIN_OTP_URL, params, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mAppConst.hideProgressDialog();
                    if (jsonObject != null) {
                        SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main),
                                getResources().getString(R.string.otp_resend_success_msg));
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mAppConst.hideProgressDialog();
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main), message);
                }
            });
        }

        countTimer.cancel();
        showOtpTimer(otpDuration);
    }

    public void postSignupForm() {
        mAppConst.showProgressDialog();
        mPostParams = new HashMap<>();

        if (mPackageId != null) {
            mPostParams.put("package_id", mPackageId);
        }
        if (mAccountFormValues != null) {
            Set<String> keySet = mAccountFormValues.keySet();

            for (String key : keySet) {
                String value = mAccountFormValues.get(key);
                mPostParams.put(key, value);
            }
        }
        if (mSignupParams != null) {

            Set<String> keySet = mSignupParams.keySet();

            for (String key : keySet) {
                String value = mSignupParams.get(key);
                mPostParams.put(key, value);
            }
        }
        mPostParams.put("ip", GlobalFunctions.getLocalIpAddress());
        String postSignupUrl = AppConstant.DEFAULT_URL + "signup?subscriptionForm=1";
        if (mPostParams.containsKey(ConstantVariables.URL_STRING)) {
            postSignupUrl = mPostParams.get(ConstantVariables.URL_STRING);
        }
        if (mPostParams.containsKey(ConstantVariables.PHOTO_REQUEST_URL)) {
            ArrayList<String> photo = new ArrayList<>();
            photo.add(mPostParams.get(ConstantVariables.PHOTO_REQUEST_URL));
            new UploadFileToServerUtils(mContext, postSignupUrl, photo, mPostParams, "").execute();
            return;
        }
        if (loginType != null && !loginType.isEmpty()) {
            postSignupUrl = mAppConst.buildQueryString(postSignupUrl,
                    SocialLoginUtil.getFacebookTwitterParams());
        }

        mAppConst.postLoginSignUpRequest(postSignupUrl, mPostParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                mAppConst.hideProgressDialog();
                mAppConst.proceedToUserSignup(mContext, mFbTwitterBundle, emailAddress,
                        password, jsonObject.optString("body"), jsonObject);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mAppConst.hideProgressDialog();

                switch (message) {
                    case "email_not_verified":
                    case "not_approved":
                    case "unauthorized":
                        SocialLoginUtil.clearFbTwitterInstances(mContext, loginType);
                        mAlertDialogWithAction.showAlertDialogForSignUpError(message);
                        break;

                    default:
                        SnackbarUtils.displaySnackbar(findViewById(R.id.otp_main), message);
                        break;
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.otp_verify_button:
                if (GlobalFunctions.isNetworkAvailable(mContext)) {
                    mAppConst.hideKeyboard();
                    verifyClicked();
                } else {
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main),
                            getResources().getString(R.string.network_connectivity_error));
                }
                break;

            case R.id.resend_otp:
                if (GlobalFunctions.isNetworkAvailable(mContext)) {
                    mAppConst.hideKeyboard();
                    resendOTP();
                } else {
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.otp_main),
                            getResources().getString(R.string.network_connectivity_error));
                }
                break;
            case R.id.tvBackButton:
                onBackPressed();
                break;
        }
    }

    @Override
    public void onUploadResponse(JSONObject jsonObject, boolean isRequestSuccessful) {

        if (isRequestSuccessful) {
            mAppConst.proceedToUserSignup(mContext, mFbTwitterBundle, emailAddress,
                    password, jsonObject.optJSONObject("body") == null ? jsonObject.optString("body") : null,
                    jsonObject.optJSONObject("body"));

        } else {
            SnackbarUtils.displaySnackbar(findViewById(android.R.id.content),
                    jsonObject.optString("message"));
        }
    }
}
