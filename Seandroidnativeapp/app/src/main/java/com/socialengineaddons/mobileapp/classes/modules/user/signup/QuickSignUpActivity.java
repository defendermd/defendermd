package com.socialengineaddons.mobileapp.classes.modules.user.signup;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.text.SpannableStringBuilder;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.google.firebase.iid.FirebaseInstanceId;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.PhotoUploadingActivity;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.formgenerator.FormActivity;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.BezelImageView;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ScrollUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.BitmapUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SocialLoginUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.core.OTPActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.PRIVACY_POLICY_MENU_TITLE;
import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.REQUEST_IMAGE;
import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.TERMS_OF_SERVICE_MENU_TITLE;

public class QuickSignUpActivity extends AppCompatActivity implements View.OnClickListener, OnUploadResponseListener {

    private ProgressBar mProgressBar;
    private JSONObject mFieldsJsonObject;
    private RelativeLayout mAccountFormView;
    private AppConstant mAppConst;
    private HashMap<String, String> mSignupParams;
    private Bundle mFbTwitterBundle;
    private Context mContext;
    private AlertDialogWithAction mAlertDialogWithAction;
    private String loginType, emailAddress, password, picture;
    private boolean isEnableOtp = false;
    private String countryPhoneCode, emailaddress;
    private OTPActivity otpActivity;
    private String mSignUpUrl = AppConstant.DEFAULT_URL + "sitequicks/index?subscriptionForm=1";
    private FormActivity mFormActivity;
    private BezelImageView bivUserPhoto;
    private ArrayList<String> mSelectPath;
    private int width;
    private Button btnSignUp;
    private View rlUserPhoto;
    private Snackbar snackbar;
    private ImageLoader mImageLoader;
    private ScrollView svFormWrapper;
    private String mRegistrationId, mPostSignupUrl;
    private boolean isRequestSent = false, isPermissionForFacebookImage = false;

    private LinearLayout checkBoxLayout;
    private CheckBox checkBox;
    private TextView termPrivacyText;
    private boolean isAgreed;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_quick_sign_up);

        mProgressBar = findViewById(R.id.progressBar);
        mContext = this;

        new Thread(mMessageSender).start();

        mAppConst = new AppConstant(this);
        mImageLoader = new ImageLoader(mContext);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);
        width = AppConstant.getDisplayMetricsWidth(QuickSignUpActivity.this);
        otpActivity = new OTPActivity();
        mFormActivity = new FormActivity();
        mFormActivity.setContext(mContext);
        if (getIntent().hasExtra("fb_twitter_info")) {
            mFbTwitterBundle = getIntent().getBundleExtra("fb_twitter_info");
        }
        mAccountFormView = findViewById(R.id.form_view);
        rlUserPhoto = findViewById(R.id.rlUserPhoto);
        bivUserPhoto = findViewById(R.id.bivProfileImage);
        bivUserPhoto.setOnClickListener(this::onClick);
        GradientDrawable borderDrawable = (GradientDrawable) ContextCompat.getDrawable(mContext, R.drawable.test_background).mutate();
        borderDrawable.setStroke(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_2dp),
                ContextCompat.getColor(this, R.color.grey_lightest));
        bivUserPhoto.setBorderDrawable(borderDrawable);

        BezelImageView bivUploadImage = findViewById(R.id.bivUploadImage);
        Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_file_upload_white).mutate();
        drawable.setColorFilter(new PorterDuffColorFilter(ScrollUtils.getColorWithAlpha(0.7f, ContextCompat.getColor(this, R.color.themeButtonColor)),
                PorterDuff.Mode.SRC_ATOP));
        bivUploadImage.setImageDrawable(drawable);
        GradientDrawable dUploadBackground = (GradientDrawable) ContextCompat.getDrawable(mContext, R.drawable.test_background).mutate();
        dUploadBackground.setStroke(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_1dp),
                ContextCompat.getColor(this, R.color.colorAccent));
        dUploadBackground.setColor(ContextCompat.getColor(this, R.color.white));
        bivUploadImage.setBackground(dUploadBackground);
        bivUploadImage.setOnClickListener(this::onClick);
        btnSignUp = findViewById(R.id.btnSignUp);
        btnSignUp.setOnClickListener(this::onClick);
        svFormWrapper = findViewById(R.id.svFormWrapper);
        checkBoxLayout = findViewById(R.id.checkbox_layout);
        checkBox = findViewById(R.id.checkbox_term_privacy);
        termPrivacyText = findViewById(R.id.textview_term_privacy);
        TextView tvBackButton = findViewById(R.id.tvBackButton);
        Drawable arrowBack = ContextCompat.getDrawable(mContext, R.drawable.ic_arrow_back).mutate();
        arrowBack.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(this, R.color.themeButtonColor),
                PorterDuff.Mode.SRC_ATOP));
        tvBackButton.setCompoundDrawablesWithIntrinsicBounds(arrowBack, null, null, null);
        tvBackButton.setOnClickListener(this::onClick);
        String signUpResponse = getIntent().getStringExtra("signUpForm");
        if (signUpResponse != null && !signUpResponse.isEmpty()) {
            try {
                mFieldsJsonObject = new JSONObject(signUpResponse);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        if (mFieldsJsonObject != null) {
            renderSignUpForm(mFieldsJsonObject);
        } else {
            getSignUpForm();
        }
    }

    private void getSignUpForm() {
        mSignUpUrl = AppConstant.DEFAULT_URL + "sitequicks/index?subscriptionForm=1";
        Map<String, String> params = new HashMap<>();
        if (mFbTwitterBundle != null) {
            picture = (mFbTwitterBundle.get("picture") != null) ? mFbTwitterBundle.get("picture").toString() : null;
            bivUserPhoto.setPadding(0, 0, 0, 0);
            mImageLoader.setImageUrl(picture, bivUserPhoto);
            for (String key : mFbTwitterBundle.keySet()) {
                if (mFbTwitterBundle.get(key) != null && key.contains("Name")) {
                    key.substring(0, key.indexOf("N"));
                    params.put(key.substring(0, key.indexOf("N")) + "_name", mFbTwitterBundle.get(key).toString());
                } else if (mFbTwitterBundle.get(key) != null) {
                    params.put(key, mFbTwitterBundle.get(key).toString());
                }
            }
            loginType = params.get("loginType");
        }

        if (loginType != null && !loginType.isEmpty()) {
            params.putAll(SocialLoginUtil.getFacebookTwitterParams());
        }
        params.putAll(mAppConst.getAuthenticationParams());

        mSignUpUrl = mAppConst.buildQueryString(mSignUpUrl, params);

        mAppConst.getJsonResponseFromUrl(mSignUpUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                renderSignUpForm(jsonObject);

            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                findViewById(R.id.progressBar).setVisibility(View.GONE);
                snackbar = SnackbarUtils.displaySnackbarWithAction(mContext, findViewById(android.R.id.content), message,
                        new SnackbarUtils.OnSnackbarActionClickListener() {
                            @Override
                            public void onSnackbarActionClick() {
                                findViewById(R.id.progressBar).setVisibility(View.VISIBLE);
                                getSignUpForm();
                            }
                        });
            }
        });
    }

    private void renderSignUpForm(JSONObject jsonObject) {
        FormActivity.setFormObject(jsonObject);
        mFieldsJsonObject = jsonObject;
        isEnableOtp = (mFieldsJsonObject.optInt("isOTPEnabled", 0) == 1);
        if (mFieldsJsonObject != null && mFieldsJsonObject.length() > 0) {
            rlUserPhoto.setVisibility(View.VISIBLE);
            Handler handler = new Handler(Looper.getMainLooper());

            handler.postDelayed(() -> {
                View view = mFormActivity.generateForm(mFieldsJsonObject, true, "sign_up");
                mAccountFormView.addView(view);
                mProgressBar.setVisibility(View.GONE);
                checkBoxLayout.setVisibility(View.VISIBLE);
                checkBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                    @Override
                    public void onCheckedChanged(CompoundButton compoundButton, boolean isChecked) {
                        isAgreed = isChecked;
                    }
                });
                btnSignUp.setVisibility(View.VISIBLE);
                createSpanText(termPrivacyText);
                setOnFocusChangeListener();
            }, 300);

        }

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        switch (id) {
            case android.R.id.home:
                onBackPressed();
                // Playing backSound effect when user tapped on back button from tool bar.
                if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
                    SoundUtil.playSoundEffectOnBackPressed(mContext);
                }
                break;
        }

        return super.onOptionsItemSelected(item);
    }


    @Override
    public void onBackPressed() {
        Intent intent = new Intent();
        intent.putExtra("accountFormValues", mSignupParams);
        setResult(ConstantVariables.SIGN_UP_CODE, intent);
        super.onBackPressed();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }


    private void checkOtpSteps() {
        if (isEnableOtp) {
            Map<String, String> params = new HashMap<>();
            params.put("country_code", countryPhoneCode);
            params.put("emailaddress", emailaddress);
            params.put("phoneno", emailaddress);


            mAppConst.postLoginSignUpRequest(UrlUtil.SIGNUP_OTP_SEND_URL, params, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mProgressBar.setVisibility(View.GONE);

                    if (jsonObject != null) {

                        JSONObject otpJsonObject = jsonObject.optJSONObject("response");
                        String userPhoneno = otpJsonObject.optString("phoneno");
                        String userCountryCode = otpJsonObject.optString("country_code");
                        boolean isOtpSend = otpJsonObject.optBoolean("isOtpSend");
                        String otpCode = otpJsonObject.optString("code");
                        int otpDuration = otpJsonObject.optInt("duration");
                        int otpLength = otpJsonObject.optInt("length", 6);
                        int keyboardType = otpJsonObject.optInt("type", 0);

                        if (isOtpSend) {
                            String sentTime = otpActivity.getCurrentDateTime();
                            mSignupParams.put("email", emailAddress);
                            mSignupParams.put(ConstantVariables.URL_STRING, mSignUpUrl);
                            Intent otpIntent = new Intent(mContext, OTPActivity.class);
                            otpIntent.putExtra("country_code", userCountryCode);
                            otpIntent.putExtra("user_phoneno", userPhoneno);
                            otpIntent.putExtra("otp_duration", otpDuration);
                            otpIntent.putExtra("otpLength", otpLength);
                            otpIntent.putExtra("keyboardType", keyboardType);
                            otpIntent.putExtra("isEnableOtp", isEnableOtp);
                            otpIntent.putExtra("otp_code", otpCode);
                            otpIntent.putExtra("sent_time", sentTime);          //sent current Date and Time
                            otpIntent.putExtra("package_id", mSignupParams.get("package_id"));
                            otpIntent.putExtra("account_form_values", mSignupParams);
                            startActivity(otpIntent);
                            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

                        } else {
                            postSignUpForm();
                        }
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mProgressBar.setVisibility(View.GONE);
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.form_view), message);
                }
            });

        } else {
            postSignUpForm();
        }
    }

    public void postSignUpForm() {

        mAppConst.hideKeyboard();
        mSignupParams = mFormActivity.save();
        if (mSignupParams == null) {
            focusOnView(mFormActivity.getErrorTag());
            return;
        }
        if (!validateSpecificElements()) {
            return;
        }
        if (mSignupParams.containsKey("emailaddress")) {
            emailaddress = emailAddress = mSignupParams.get("emailaddress");
        } else {
            emailaddress = emailAddress = mSignupParams.get("email");
        }
        password = mSignupParams.get("password");
        mPostSignupUrl = mSignUpUrl;
        if (isEnableOtp && emailaddress.matches("\\d+")) {
            mPostSignupUrl += "&validateOnly=1";
            countryPhoneCode = mSignupParams.get("country_code");
        }
        mSignupParams.put("ip", GlobalFunctions.getLocalIpAddress());

        if (!(isEnableOtp && emailaddress.matches("\\d+")) && (mSelectPath != null || (picture != null && !picture.isEmpty()))) {
            if (mRegistrationId != null) {
                uploadDataOnServer();
            } else {
                isRequestSent = true;
            }
        } else {
            mAppConst.showProgressDialog();

            mAppConst.postLoginSignUpRequest(mPostSignupUrl, mSignupParams, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) {
                    mAppConst.hideProgressDialog();
                    if (isEnableOtp && emailaddress.matches("\\d+")) {
                        checkOtpSteps();
                    } else {
                        mAppConst.proceedToUserSignup(mContext, mFbTwitterBundle, emailAddress,
                                password, jsonObject.optString("body"), jsonObject);
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    mAppConst.hideProgressDialog();
                    mProgressBar.setVisibility(View.GONE);

                    switch (message) {
                        case "email_not_verified":
                        case "not_approved":
                        case "subscription_fail":
                        case "unauthorized":
                            SocialLoginUtil.clearFbTwitterInstances(mContext, loginType);
                            mAlertDialogWithAction.showAlertDialogForSignUpError(message);
                            break;
                        default:

                            try {
                                JSONObject validationMessagesObject = new JSONObject(message);
                                mFormActivity.showValidations(validationMessagesObject);
                            } catch (JSONException e) {
                                e.printStackTrace();
                                snackbar = SnackbarUtils.displaySnackbarWithAction(mContext, findViewById(android.R.id.content), message,
                                        new SnackbarUtils.OnSnackbarActionClickListener() {
                                            @Override
                                            public void onSnackbarActionClick() {
                                                postSignUpForm();
                                            }
                                        });
                            }
                            break;
                    }
                }
            });
        }

    }

    private boolean validateSpecificElements() {
        boolean isValid = true;
        String emailFieldName = "email";
        if (mSignupParams.containsKey("emailaddress")) {
            emailaddress = emailAddress = mSignupParams.get("emailaddress");
            emailFieldName = "emailaddress";
        } else {
            emailaddress = emailAddress = mSignupParams.get("email");
        }
        String emailPattern = "[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]+";
        if (emailAddress != null && !emailAddress.matches(emailPattern)
                && !(isEnableOtp && emailaddress.matches("\\d+"))
                && mAccountFormView.findViewWithTag(emailFieldName) != null) {
            TextView tvEmail = mAccountFormView.findViewWithTag(emailFieldName).findViewById(R.id.error_view);
            tvEmail.setVisibility(View.VISIBLE);
            tvEmail.setText(mContext.getResources().getString(R.string.enter_valid_email));
            isValid = false;
        }

        String password = mSignupParams.get("password");
        if (password != null && password.length() < 6 && mAccountFormView.findViewWithTag("password") != null) {
            TextView tvPassword = mAccountFormView.findViewWithTag("password").findViewById(R.id.error_view);
            tvPassword.setVisibility(View.VISIBLE);
            tvPassword.setText(mContext.getResources().getString(R.string.password_validation_error));
            isValid = false;
        }
        String passconf = mSignupParams.get("passconf");
        if (passconf != null && mAccountFormView.findViewWithTag("passconf") != null) {
            TextView tvPasswordError = mAccountFormView.findViewWithTag("passconf").findViewById(R.id.error_view);
            tvPasswordError.setVisibility(View.VISIBLE);
            if (passconf.length() < 6) {
                tvPasswordError.setText(mContext.getResources().getString(R.string.password_validation_error));
                isValid = false;
            } else if (password != null && !password.equals(passconf)) {
                tvPasswordError.setText(mContext.getResources().getString(R.string.confirm_password_validation_error));
                isValid = false;
            } else {
                tvPasswordError.setVisibility(View.GONE);
            }
        }

        String username = mSignupParams.get("username");
        if (username != null && mAccountFormView.findViewWithTag("username") != null) {
            TextView tvUsername = mAccountFormView.findViewWithTag("username").findViewById(R.id.error_view);
            tvUsername.setVisibility(View.VISIBLE);
            if (username.length() < 4) {
                tvUsername.setText(mContext.getResources().getString(R.string.profile_address_validation_error));
                isValid = false;
            } else if (Character.isDigit(username.charAt(0))) {
                tvUsername.setText(mContext.getResources().getString(R.string.profile_address_start_with_validation_error));
                isValid = false;
            }
        }

        return isValid;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case REQUEST_IMAGE:
                if (resultCode == RESULT_OK) {
                    mSelectPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);
                    // clearing picture which is coming from facebook when the user select another image from media.
                    picture = null;
                    try {
                        // Getting Bitmap from its real path.
                        Bitmap selectedImageBitmap = BitmapUtils.decodeSampledBitmapFromFile(mContext, mSelectPath.get(0), width,
                                (int) getResources().getDimension(R.dimen.sing_up_image_width_height), false);
                        bivUserPhoto.setPadding(0, 0, 0, 0);
                        bivUserPhoto.setImageBitmap(selectedImageBitmap);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                } else if (resultCode != RESULT_CANCELED) {
                    // failed to capture image
                    SnackbarUtils.displaySnackbar(findViewById(android.R.id.content),
                            mContext.getResources().getString(R.string.image_capture_failed));
                }
                break;
            case ConstantVariables.SIGN_UP_WEBVIEW_CODE:
                /**
                 * Clear Twitter and Facebook instances if subscription
                 * payment is not completed
                 */
                SocialLoginUtil.clearFbTwitterInstances(this, loginType);

                mAlertDialogWithAction.showAlertDialogForSignUpError("payment_error");
                break;
            case ConstantVariables.SIGN_UP_CODE:
                onBackPressed();
                break;

        }
    }

    private void selectImage() {
        Intent intent = new Intent(mContext, PhotoUploadingActivity.class);
        intent.putExtra("selection_mode", true);
        startActivityForResult(intent, REQUEST_IMAGE);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // permission was granted, proceed to the normal flow
                    selectImage();
                } else {
                    // If user deny the permission popup
                    if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                        // Show an explanation to the user, After the user
                        // sees the explanation, try again to request the permission.
                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    } else {
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.
                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext,
                                findViewById(android.R.id.content), ConstantVariables.WRITE_EXTERNAL_STORAGE);
                    }
                }
                break;
        }
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        switch (id) {
            case R.id.bivProfileImage:
                if (mSelectPath != null && mSelectPath.size() > 0) {
                    break;
                }
            case R.id.bivUploadImage:
                /* Check if permission is granted or not */
                if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            ConstantVariables.WRITE_EXTERNAL_STORAGE);
                } else {
                    selectImage();
                }
                break;
            case R.id.btnSignUp:
                if (isAgreed)
                    postSignUpForm();
                else
                    SnackbarUtils.displaySnackbar(mAccountFormView, mContext.getResources().getString(R.string.checkbox_error));
                break;
            case R.id.tvBackButton:
                onBackPressed();
                break;
        }
    }

    @Override
    public void onUploadResponse(JSONObject jsonObject, boolean isRequestSuccessful) {
        String errorCode = jsonObject.optString("error_code");
        if (isRequestSuccessful) {
            mAppConst.proceedToUserSignup(mContext, mFbTwitterBundle, emailAddress,
                    password, jsonObject.optJSONObject("body") == null ? jsonObject.optString("body") : null,
                    jsonObject.optJSONObject("body"));

        } else if (errorCode != null) {
            showSignUpError(errorCode, jsonObject.optString("message"));
        } else {
            SnackbarUtils.displaySnackbar(findViewById(android.R.id.content),
                    jsonObject.optString("message"));
        }
    }

    /**
     * Method to show sign up error alert dialog according to error code.
     *
     * @param errorCode ErrorCode
     * @param message   Error Message.
     */
    public void showSignUpError(String errorCode, String message) {
        switch (errorCode) {
            case "email_not_verified":
            case "not_approved":
            case "unauthorized":
                SocialLoginUtil.clearFbTwitterInstances(this, loginType);
                mAlertDialogWithAction.showAlertDialogForSignUpError(errorCode);
                break;
            default:
                if (GlobalFunctions.isValidJson(message)) {
                    try {
                        JSONObject jsonObject = new JSONObject(message);
                        if (jsonObject.has("photo")) {
                            message = mContext.getResources().getString(R.string.sign_up_photo_error);
                        } else {
                            mFormActivity.showValidations(jsonObject);
                        }

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                SnackbarUtils.displaySnackbar(findViewById(android.R.id.content), message);
                break;
        }
    }


    private void focusOnView(String tagName) {
        View view = mAccountFormView.findViewWithTag(tagName);
        if (view == null) {
            return;
        }
        int[] location = new int[2];
        view.getLocationOnScreen(location);
        if (location[1] < 0) {
            svFormWrapper.post(() -> {
                svFormWrapper.smoothScrollTo(0, location[1]);
                view.requestFocus();
            });
        } else {
            view.requestFocus();
        }
        mFormActivity.setErrorTag(null);
    }

    private void setOnFocusChangeListener() {
        String[] specificFields = {"email", "emailaddress", "password", "passconf", "username"};
        for (String field : specificFields) {
            View widget = mAccountFormView.findViewWithTag(field);
            if (widget != null) {
                EditText element = widget.findViewById(R.id.field_value);
                element.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                    public void onFocusChange(View v, boolean hasFocus) {
                        mSignupParams = (mSignupParams == null) ? new HashMap<>() : mSignupParams;
                        if (!hasFocus) {
                            mSignupParams.put(field, element.getText().toString());
                            validateSpecificElements();
                        }
                    }
                });
            }
        }
    }

    private void uploadDataOnServer() {
        new UploadFileToServerUtils(mContext, mPostSignupUrl, mSelectPath, mSignupParams, mRegistrationId).execute();
    }


    /* Only send signup request from here if registration id is null
     * at the time when user click on submit button
     * */
    @SuppressLint("HandlerLeak")
    private final Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            Bundle bundle = msg.getData();
            mRegistrationId = bundle.getString("registration_id");
            if (isRequestSent) {
                uploadDataOnServer();
            }
        }
    };

    private final Runnable mMessageSender = new Runnable() {
        public void run() {
            try {
                String mRegistrationId = FirebaseInstanceId.getInstance().getToken(mContext.getResources().getString(R.string.gcm_defaultSenderId), "FCM");
                if (mRegistrationId != null) {
                    Message msg = mHandler.obtainMessage();
                    Bundle bundle = new Bundle();
                    bundle.putString("registration_id", mRegistrationId);
                    msg.setData(bundle);
                    mHandler.sendMessage(msg);
                }

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    };


    private void createSpanText(TextView checkBoxTv) {

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

}
