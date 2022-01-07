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

package com.socialengineaddons.mobileapp.classes.core;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentSender;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.TextInputLayout;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatCheckBox;
import android.text.Editable;
import android.text.TextWatcher;
import android.text.method.HideReturnsTransformationMethod;
import android.text.method.PasswordTransformationMethod;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.CallbackManager;
import com.facebook.login.widget.LoginButton;
import com.google.android.gms.auth.api.credentials.Credential;
import com.google.android.gms.auth.api.credentials.CredentialPickerConfig;
import com.google.android.gms.auth.api.credentials.CredentialRequest;
import com.google.android.gms.auth.api.credentials.CredentialRequestResponse;
import com.google.android.gms.auth.api.credentials.Credentials;
import com.google.android.gms.auth.api.credentials.CredentialsClient;
import com.google.android.gms.auth.api.credentials.CredentialsOptions;
import com.google.android.gms.auth.api.credentials.HintRequest;
import com.google.android.gms.auth.api.credentials.IdentityProviders;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SocialLoginUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.modules.user.signup.QuickSignUpActivity;
import com.socialengineaddons.mobileapp.classes.modules.user.signup.SubscriptionActivity;
import com.twitter.sdk.android.core.identity.TwitterLoginButton;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import static com.google.android.gms.common.api.CommonStatusCodes.SIGN_IN_REQUIRED;
import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.PRIVACY_POLICY_MENU_TITLE;
import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.TERMS_OF_SERVICE_MENU_TITLE;


public class NewLoginActivity extends AppCompatActivity implements View.OnClickListener,
        SocialLoginUtil.OnSocialLoginSuccessListener {


    private final int RC_READ = 1212, RC_HINT = 1213, RC_SAVE = 1214;
    private RelativeLayout mMainView;
    private Button loginButton;
    private String emailValue = "", passwordValue = "";
    private boolean isValidatingData = false;
    private boolean isError = false;
    private boolean isShowFacebookButton;
    private boolean isNormalLogin = true;
    private Context mContext;
    private AppConstant mAppConst;
    private Bundle bundle;
    private String intentAction, intentType;
    private TextView errorView, mBrowseAsGuest, mChooseLanguage, showPassword, mForgotPassword;
    private LoginButton facebookLoginButton;
    private TwitterLoginButton twitterLoginButton;
    private EditText eEmailField, ePasswordField;
    private boolean isPasswordShow = false;
    private CallbackManager callbackManager;
    private JSONObject joSignUpForm, loginResponse;
    private CredentialsClient mCredentialsClient;
    private CredentialRequest mCredentialRequest;
    private AppCompatCheckBox cbRememberMe;
    private TextInputLayout tilPasswordWrapper;


    boolean isKeyboardShowing = false;
    private LinearLayout bottomLinksLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        /* Initialize Facebook SDK, we need to initialize before using it ---- */
        SocialLoginUtil.initializeFacebookSDK(NewLoginActivity.this);

        SocialLoginUtil.setSocialLoginListener(this);

        setContentView(R.layout.activity_login_new);

        mContext = this;
        mAppConst = new AppConstant(this);

        mCredentialsClient = Credentials.getClient(this);
        mCredentialRequest = new CredentialRequest.Builder()
                .setPasswordLoginSupported(true)
                .build();

        mCredentialsClient.request(mCredentialRequest).addOnCompleteListener(
                new OnCompleteListener<CredentialRequestResponse>() {
                    @Override
                    public void onComplete(@NonNull Task<CredentialRequestResponse> task) {

                        if (task.isSuccessful()) {
                            // See "Handle successful credential requests"
                            onCredentialRetrieved(task.getResult().getCredential());
                            return;

                        }

                        Exception e = task.getException();
                        if (e instanceof ResolvableApiException) {
                            // This is most likely the case where the user has multiple saved
                            // credentials and needs to pick one. This requires showing UI to
                            // resolve the read request.
                            ResolvableApiException rae = (ResolvableApiException) e;
                            resolveResult(rae, RC_READ);
                        } else if (e instanceof ApiException) {
                            // The user must create an account or sign in manually.
                            ApiException ae = (ApiException) e;
                            int code = ae.getStatusCode();

                            if (code == SIGN_IN_REQUIRED) {
                                displayHint();
                            }

                            // ...
                        }

                    }
                });

        if (getIntent() != null) {
            bundle = getIntent().getExtras();
            intentAction = getIntent().getAction();
            intentType = getIntent().getType();
        }

        mMainView = findViewById(R.id.scrollView);
        loginButton = findViewById(R.id.login_button);
        loginButton.setOnClickListener(this);
        bottomLinksLayout = findViewById(R.id.bottom_links_layout);
        TextInputLayout usernameWrapper = (TextInputLayout) findViewById(R.id.usernameWrapper);
        eEmailField = findViewById(R.id.email_field);
        ePasswordField = findViewById(R.id.password_field);
        tilPasswordWrapper = findViewById(R.id.passwordWrapper);
        cbRememberMe = findViewById(R.id.remember_me);

        mForgotPassword = findViewById(R.id.forgot_password);
        mForgotPassword.setOnClickListener(this);

        usernameWrapper.setHint(getResources().getString(R.string.lbl_enter_email));

        errorView = findViewById(R.id.error_view);

        TextView fbButton = findViewById(R.id.fb_button);
        twitterLoginButton = findViewById(R.id.twitter_login_button);
        TextView twButton = findViewById(R.id.tw_button);

        if (!getResources().getString(R.string.facebook_app_id).isEmpty()) {
            facebookLoginButton = new LoginButton(mContext);
        }

        showPassword = findViewById(R.id.show_password_icon);
        showPassword.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        showPassword.setText("\uf06e");
        showPassword.setOnClickListener(this);

        TextView registerText = findViewById(R.id.register_text);
        registerText.setOnClickListener(this);

        mBrowseAsGuest = findViewById(R.id.browse_as_guest);
        mBrowseAsGuest.setTypeface(GlobalFunctions.getFontIconTypeFace(this));
        mBrowseAsGuest.setOnClickListener(this);

        mChooseLanguage = findViewById(R.id.choose_language);
        mChooseLanguage.setTypeface(GlobalFunctions.getFontIconTypeFace(this));
        mChooseLanguage.setOnClickListener(this);

        Drawable ivEmailIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_email_white_24dp);
        ivEmailIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.grey_light), PorterDuff.Mode.SRC_IN);
        eEmailField.setCompoundDrawablesWithIntrinsicBounds(ivEmailIcon, null, null, null);
        int drawablePadding = mContext.getResources().getDimensionPixelSize(R.dimen.padding_6dp);
        eEmailField.setCompoundDrawablePadding(drawablePadding);


        Drawable ivPasswordIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_lock_white_24dp);
        ivPasswordIcon.setColorFilter(ContextCompat.getColor(mContext, R.color.grey_light), PorterDuff.Mode.SRC_IN);
        ePasswordField.setCompoundDrawablesWithIntrinsicBounds(ivPasswordIcon, null, null, null);
        ePasswordField.setCompoundDrawablePadding(drawablePadding);

        if (PreferencesUtils.getOtpEnabledOption(mContext) != null &&
                !PreferencesUtils.getOtpEnabledOption(mContext).isEmpty()) {
            if (PreferencesUtils.getOtpEnabledOption(mContext).equals("both")) {
                tilPasswordWrapper.setVisibility(View.GONE);
                showPassword.setVisibility(View.GONE);
                mForgotPassword.setVisibility(View.GONE);
                setViewHideShow();

            } else {
                tilPasswordWrapper.setVisibility(View.VISIBLE);
                mForgotPassword.setVisibility(View.VISIBLE);
            }
            usernameWrapper.setHint(getResources().getString(R.string.lbl_enter_email_phone));
        }
        LogUtils.LOGD(NewLoginActivity.class.getSimpleName(), "OtpEnabledOption->" + PreferencesUtils.getOtpEnabledOption(mContext));


        /* Set ui configuration of facebook and twitter login button */

        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);

        // Hide Facebook button when facebook_app_id is null or Empty.
        if (!getResources().getString(R.string.facebook_app_id).isEmpty()) {
            fbButton.setVisibility(View.VISIBLE);
            isShowFacebookButton = true;
        } else {
            fbButton.setVisibility(View.GONE);
            isShowFacebookButton = false;
        }

        // Hide twitter button when twitter_key or twitter_secret is null or Empty.
        boolean isShowTwitterButton;
        if (!getResources().getString(R.string.twitter_key).isEmpty() &&
                !getResources().getString(R.string.twitter_secret).isEmpty()) {

            isShowTwitterButton = true;
            String twitterLoginText;

            if (isShowFacebookButton) {
                twitterLoginText = mContext.getResources().getString(R.string.twitter);
            } else {
                twitterLoginText = mContext.getResources().getString(R.string.twitter_login_text);
                twButton.setLayoutParams(layoutParams);
            }

            twButton.setVisibility(View.VISIBLE);
            twButton.setText(twitterLoginText);
        } else {
            twButton.setVisibility(View.GONE);
            isShowTwitterButton = false;
        }

        if (!isShowTwitterButton && isShowFacebookButton) {
            fbButton.setLayoutParams(layoutParams);
            fbButton.setText(mContext.getResources().getString(R.string.com_facebook_loginview_log_in_button_long));
        }

        if (isShowFacebookButton) {
            fbButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    facebookLoginButton.performClick();
                }
            });
        }

        twButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                twitterLoginButton.performClick();
            }
        });

        if (isShowFacebookButton) {
            callbackManager = CallbackManager.Factory.create();
            facebookLoginButton.setReadPermissions(Arrays.asList("public_profile, email"));

            //Facebook login authentication process
            SocialLoginUtil.registerFacebookLoginCallback(NewLoginActivity.this, mMainView, callbackManager, false);

        }

        //Twitter login authentication process
        SocialLoginUtil.registerTwitterLoginCallback(NewLoginActivity.this, mMainView, twitterLoginButton, false);

        setBrowseGuestAndLanguageOptions();
        getSignUpForm();

        mMainView.getViewTreeObserver().addOnGlobalLayoutListener(
                new ViewTreeObserver.OnGlobalLayoutListener() {
                    @Override
                    public void onGlobalLayout() {

                        Rect r = new Rect();
                        mMainView.getWindowVisibleDisplayFrame(r);
                        int screenHeight = mMainView.getRootView().getHeight();

                        // r.bottom is the position above soft keypad or device button.
                        // if keypad is shown, the r.bottom is smaller than that before.
                        int keypadHeight = screenHeight - r.bottom;

                        Log.v("keyboardLogs", "keypadHeight = " + keypadHeight);

                        if (keypadHeight > screenHeight * 0.15) { // 0.15 ratio is perhaps enough to determine keypad height.
                            // keyboard is opened
                            if (!isKeyboardShowing) {
                                isKeyboardShowing = true;
                                onKeyboardVisibilityChanged(true);
                            }
                        } else {
                            // keyboard is closed
                            if (isKeyboardShowing) {
                                isKeyboardShowing = false;
                                onKeyboardVisibilityChanged(false);
                            }
                        }
                    }
                });

    }


    /* Display login suggestions/email to user from Google accounts */
    private void displayHint() {

        HintRequest hintRequest = new HintRequest.Builder()
                .setHintPickerConfig(new CredentialPickerConfig.Builder()
                        .setShowCancelButton(true)
                        .build())
                .setEmailAddressIdentifierSupported(true)
                .setAccountTypes(IdentityProviders.GOOGLE)
                .build();

        PendingIntent intent = mCredentialsClient.getHintPickerIntent(hintRequest);
        try {
            startIntentSenderForResult(intent.getIntentSender(), RC_HINT, null, 0, 0, 0);
        } catch (IntentSender.SendIntentException e) {
            e.printStackTrace();
        }
    }


    private void resolveResult(ResolvableApiException rae, int requestCode) {
        try {
            rae.startResolutionForResult(NewLoginActivity.this, requestCode);
        } catch (IntentSender.SendIntentException e) {
            e.printStackTrace();
        }
    }


    private void onCredentialRetrieved(Credential credential) {
        String accountType = credential.getAccountType();

        if (accountType == null) {
            // Sign the user in with information from the Credential.
            signInWithPassword(credential.getId(), credential.getPassword());

        }

        /* TODO come into the use when Google sign work will be done in app
        else if (accountType.equals(IdentityProviders.GOOGLE)) {
            // The user has previously signed in with Google Sign-In. Silently
            // sign in the user with the same ID.
            // See https://developers.google.com/identity/sign-in/android/
            GoogleSignInOptions gso =
                    new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                            .requestEmail()
                            .build();

            GoogleSignInClient signInClient = GoogleSignIn.getClient(this, gso);
            Task<GoogleSignInAccount> task = signInClient.silentSignIn();
            // ...

        }
        */

    }


    /* Set email and password in login fields */
    private void signInWithPassword(String id, String password) {
        eEmailField.setText(id);
        ePasswordField.setText(password);

        if (password != null)
            cbRememberMe.setChecked(true);
    }


    public void setViewHideShow() {
        eEmailField.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                if (charSequence.toString().matches("-?\\d+(.\\d+)?")) {
                    isNormalLogin = false;
                    mForgotPassword.setVisibility(View.GONE);
                    tilPasswordWrapper.setVisibility(View.GONE);
                    showPassword.setVisibility(View.GONE);
                    loginButton.setText(getResources().getString(R.string.otp_login_btn_name));
                    cbRememberMe.setVisibility(View.GONE);

                } else {
                    isNormalLogin = true;
                    loginButton.setText(getResources().getString(R.string.login_btn_name));
                    if (charSequence.length() != 0) {
                        cbRememberMe.setVisibility(View.VISIBLE);
                        tilPasswordWrapper.setVisibility(View.VISIBLE);
                        showPassword.setVisibility(View.VISIBLE);
                        mForgotPassword.setVisibility(View.VISIBLE);
                    } else {
                        cbRememberMe.setVisibility(View.GONE);
                        tilPasswordWrapper.setVisibility(View.GONE);
                        showPassword.setVisibility(View.GONE);
                        mForgotPassword.setVisibility(View.GONE);
                    }
                }

            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });
    }

    public void LoginClicked() {

        emailValue = eEmailField.getText().toString();

        passwordValue = ePasswordField.getText().toString();

        if (emailValue.isEmpty()) {
            isValidatingData = false;
            loginButton.setText(getResources().getString(R.string.login_btn_name));
            eEmailField.setError(getResources().getString(R.string.email_address_message));

        } else if (!ePasswordField.isShown()) {
            tilPasswordWrapper.setVisibility(View.VISIBLE);
            showPassword.setVisibility(View.VISIBLE);
            eEmailField.setError(null);
            isValidatingData = false;
            loginButton.setText(getResources().getString(R.string.login_btn_name));

        } else if (passwordValue.isEmpty()) {
            isValidatingData = false;
            loginButton.setText(getResources().getString(R.string.login_btn_name));
            ePasswordField.setError(getResources().getString(R.string.password_message));
            ePasswordField.requestFocus();

        } else {
            if (!cbRememberMe.isChecked()) {
                deleteCredentials();
            }

            mAppConst.showProgressDialog();

            Map<String, String> params = new HashMap<>();
            params.put("email", emailValue);
            params.put("password", passwordValue);
            params.put("ip", GlobalFunctions.getLocalIpAddress());

            mAppConst.postLoginSignUpRequest(UrlUtil.LOGIN_URL, params, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) {
                    mAppConst.hideProgressDialog();
                    loginResponse = jsonObject;

                    if (cbRememberMe.isChecked()) {
                        displaySaveCredentialPopup();
                    } else {
                        redirectUserForLogin();
                    }
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    displayError(message);
                    mAppConst.hideProgressDialog();
                }
            });
        }
    }

    private void redirectUserForLogin() {
        mAppConst.proceedToUserLogin(mContext, bundle, intentAction, intentType,
                emailValue, passwordValue, loginResponse);
    }


    /* Delete user credential and removed from google smart lock */
    private void deleteCredentials() {
        Credential credential = new Credential.Builder(emailValue)
                .setPassword(passwordValue)
                .build();
        CredentialsClient mCredentialsClient = Credentials.getClient(this);
        mCredentialsClient.delete(credential).addOnCompleteListener(
                new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        if (task.isSuccessful()) {
                            return;
                        }

                        //TODO
//                        Exception e = task.getException();
                    }
                });
    }


    /* Display save credential popup to user */
    private void displaySaveCredentialPopup() {
        Credential credential = new Credential.Builder(emailValue)
                .setPassword(passwordValue)
                .build();
        CredentialsOptions options = new CredentialsOptions.Builder()
                .forceEnableSaveDialog()
                .build();

        CredentialsClient mCredentialsClient = Credentials.getClient(this, options);

        mCredentialsClient.save(credential).addOnCompleteListener(
                new OnCompleteListener() {
                    @Override
                    public void onComplete(@NonNull Task task) {
                        if (task.isSuccessful()) {
                            redirectUserForLogin();
                            return;
                        }

                        Exception e = task.getException();
                        e.printStackTrace();

                        if (e instanceof ResolvableApiException) {
                            // Try to resolve the save request. This will prompt the user if
                            // the credential is new.
                            ResolvableApiException rae = (ResolvableApiException) e;
                            try {
                                rae.startResolutionForResult(NewLoginActivity.this, RC_SAVE);

                            } catch (IntentSender.SendIntentException ea) {
                                // Could not resolve the request
                                redirectUserForLogin();
                            }
                        } else {
                            // Request has no resolution
                            redirectUserForLogin();
                        }
                    }
                });
    }

    public void otpLoginClicked() {

        emailValue = eEmailField.getText().toString();
        passwordValue = ePasswordField.getText().toString();

        if (emailValue.isEmpty()) {
            isValidatingData = false;
            eEmailField.setError(getResources().getString(R.string.email_address_phoneno_msg));

        } else if (passwordValue.isEmpty() && PreferencesUtils.getOtpEnabledOption(mContext).equals("otp")) {
            eEmailField.setError(null);
            isValidatingData = false;
            loginButton.setText(getResources().getString(R.string.login_btn_name));
            ePasswordField.setError(getResources().getString(R.string.password_message));

        } else {
            mAppConst.showProgressDialog();
            eEmailField.setError(null);
            ePasswordField.setError(null);

            final Map<String, String> params = new HashMap<>();
            params.put("email", emailValue);
            params.put("password", passwordValue);
            params.put("ip", GlobalFunctions.getLocalIpAddress());

            LogUtils.LOGD(LoginActivity.class.getSimpleName(), "otp_login_params->" + params);
            mAppConst.postLoginSignUpRequest(UrlUtil.LOGIN_OTP_URL, params, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    mAppConst.hideProgressDialog();
                    sendToOtp(jsonObject);
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    displayError(message);
                    mAppConst.hideProgressDialog();
                }
            });
        }
    }

    public void sendToOtp(JSONObject jsonObject) {

        if (jsonObject != null) {
            if (!jsonObject.has("oauth_token") || jsonObject.has("phoneno")) {

                LogUtils.LOGD(LoginActivity.class.getSimpleName(), "otp_jsonObject->" + jsonObject);
                String country_code = jsonObject.optString("country_code");
                String phoneno = jsonObject.optString("phoneno");
                int otpDuration = jsonObject.optInt("duration");

                Intent otpIntent = new Intent(mContext, OTPActivity.class);
                otpIntent.putExtra("user_phoneno", phoneno);
                otpIntent.putExtra("country_code", country_code);
                otpIntent.putExtra("otp_duration", otpDuration);
                otpIntent.putExtra("user_login_email", emailValue);
                otpIntent.putExtra("user_login_pass", passwordValue);
                otpIntent.putExtra("otp_code", jsonObject.optInt("code") + "");
                otpIntent.putExtra("otpLength", jsonObject.optInt("length", 6));
                otpIntent.putExtra("keyboardType", jsonObject.optInt("type"));
                otpIntent.putExtra("mBundle", bundle);
                startActivity(otpIntent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                isValidatingData = false;
            } else {
                mAppConst.proceedToUserLogin(mContext, bundle, intentAction, intentType,
                        emailValue, passwordValue, jsonObject);
            }
        }
    }

    /**
     * Method to set the browse as a guest text view and choose language option text view.
     */
    private void setBrowseGuestAndLanguageOptions() {

        // Checking browse as a guest option.
        if (!PreferencesUtils.isGuestUserEnabled(this)) {
            mBrowseAsGuest.setVisibility(View.GONE);
        } else {
            mBrowseAsGuest.setVisibility(View.VISIBLE);
        }

        // Checking multiple language option.
        String languages = PreferencesUtils.getLanguages(this);
        if (languages != null) {
            try {
                JSONObject languageObject = new JSONObject(languages);
                if (languageObject.length() > 1) {
                    mChooseLanguage.setVisibility(View.VISIBLE);
                } else {
                    mChooseLanguage.setVisibility(View.GONE);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        } else {
            mChooseLanguage.setVisibility(View.GONE);
        }
    }

    /**
     * Method to show login errors
     *
     * @param message Message which needs to show on email or password field.
     */
    public void displayError(String message) {
        if (GlobalFunctions.isValidJson(message)) {
            try {
                JSONObject jsonObject = new JSONObject(message);
                String emailError = jsonObject.optString("email");
                String passError = jsonObject.optString("password");

                if (emailError != null && !emailError.isEmpty() && passError != null && !passError.isEmpty()) {
                    eEmailField.setError(emailError);
                    eEmailField.requestFocus();
                    ePasswordField.setError(passError);

                } else if (emailError != null && !emailError.isEmpty()) {
                    eEmailField.setError(emailError);
                    eEmailField.requestFocus();

                } else if (passError != null && !passError.isEmpty()) {
                    ePasswordField.setError(passError);
                    ePasswordField.requestFocus();
                }

            } catch (JSONException e) {
                e.printStackTrace();
            }
        } else {
            if (message != null) {
                switch (message) {
                    case "email_not_verified":
                        message = mContext.getResources().getString(R.string.email_not_verified);
                        break;

                    case "not_approved":
                        message = mContext.getResources().getString(R.string.signup_admin_approval);
                        break;

                    case "subscription_fail":
                        mContext.getResources().getString(R.string.subscription_unsuccessful_message);
                        break;
                }
            }
            errorView.setText(message);
            errorView.setVisibility(View.VISIBLE);
            isError = true;
        }

        isValidatingData = false;
        loginButton.setText(getResources().getString(R.string.login_btn_name));
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.login_button:
                if (!isValidatingData) {
                    if (GlobalFunctions.isNetworkAvailable(mContext)) {
                        if (isError) {
                            errorView.setVisibility(View.GONE);
                        }
                        mAppConst.hideKeyboard();
                        isValidatingData = true;

                        if (PreferencesUtils.getOtpEnabledOption(mContext) != null
                                && (PreferencesUtils.getOtpEnabledOption(mContext).equals("otp")
                                || PreferencesUtils.getOtpEnabledOption(mContext).equals("both"))) {
                            if (isNormalLogin)
                                LoginClicked();
                            else
                                otpLoginClicked();

                        } else {
                            loginButton.setText(getResources().getString(R.string.login_validation_msg) + "……");
                            LoginClicked();
                        }
                    } else {
                        SnackbarUtils.displaySnackbarLongTime(mMainView,
                                getResources().getString(R.string.network_connectivity_error));
                    }
                }
                break;

            case R.id.forgot_password:
                forgotPassword();
                break;

            case R.id.register_text:
                JSONObject quickSignUp = PreferencesUtils.getModuleSettings(NewLoginActivity.this, "sitequicksignup");
                Intent signUpIntent;
                if (quickSignUp != null && quickSignUp.optBoolean("isQuickSignUp", false)) {
                    signUpIntent = new Intent(NewLoginActivity.this, QuickSignUpActivity.class);
                    if (joSignUpForm != null) {
                        signUpIntent.putExtra("signUpForm", joSignUpForm.toString());
                    }
                } else {
                    signUpIntent = new Intent(NewLoginActivity.this, SubscriptionActivity.class);
                }
                startActivity(signUpIntent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.browse_as_guest:

                mBrowseAsGuest.setText("\uf110");
                // Updating default language as current language.
                PreferencesUtils.updateDashBoardData(NewLoginActivity.this,
                        PreferencesUtils.CURRENT_LANGUAGE,
                        PreferencesUtils.getDefaultLanguage(NewLoginActivity.this));
                Intent intent = new Intent(NewLoginActivity.this, MainActivity.class);
                startActivity(intent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.show_password_icon:
                if (isPasswordShow) {
                    showPassword.setText("\uf06e");
                    ePasswordField.setTransformationMethod(PasswordTransformationMethod.getInstance());
                } else {
                    ePasswordField.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
                    showPassword.setText("\uf070");
                }
                isPasswordShow = !isPasswordShow;

                // Set cursor to end of password
                if (ePasswordField.getText() != null && !ePasswordField.getText().toString().isEmpty()) {
                    ePasswordField.setSelection(ePasswordField.length());
                }

                break;

            case R.id.choose_language:
                mAppConst.changeLanguage(this, "home");
                break;
        }

    }

    //Forgot Password
    private void forgotPassword() {

        AlertDialog.Builder alertBuilder = new AlertDialog.Builder(mContext);

        alertBuilder.setTitle(getResources().getString(R.string.forgot_password_popup_title));

        final LinearLayout inputLayout = new LinearLayout(mContext);
        final EditText input = new EditText(this);
        inputLayout.setOrientation(LinearLayout.VERTICAL);

        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
        inputLayout.setLayoutParams(layoutParams);

        inputLayout.setFocusable(true);
        inputLayout.setFocusableInTouchMode(true);
        int padding20 = (int) mContext.getResources().getDimension(R.dimen.padding_20dp);
        inputLayout.setPadding(padding20, padding20 / 2, padding20, padding20 / 2);

        if (PreferencesUtils.isOTPPluginEnabled(mContext)) {
            alertBuilder.setMessage(getResources().getString(R.string.forgot_password_popup_message_otp));
            input.setHint(getResources().getString(R.string.lbl_enter_email_phone));

        } else {
            alertBuilder.setMessage(getResources().getString(R.string.forgot_password_popup_message));
            input.setHint(getResources().getString(R.string.lbl_enter_email));
        }
        input.setFocusableInTouchMode(true);

        inputLayout.addView(input);
        alertBuilder.setView(inputLayout);

        alertBuilder.setPositiveButton(getResources().getString(R.string.forgot_password_popup_button),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {

                    }
                });


        alertBuilder.setNegativeButton(getResources().getString(R.string.cancel), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                mAppConst.hideKeyboardInDialog(input);
                dialog.cancel();
            }
        });

        final AlertDialog alertDialog = alertBuilder.create();
        alertDialog.show();

        // used to prevent the dialog from closing when ok button is clicked (For email condition)
        Button alertDialogPositiveButton = alertDialog.getButton(AlertDialog.BUTTON_POSITIVE);
        if (PreferencesUtils.isOTPPluginEnabled(mContext)) {
            alertDialogPositiveButton.setText(getResources().getString(R.string.forgot_password_popup_button_otp));
        }
        alertDialogPositiveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mAppConst.showProgressDialog();

                final String emailAddress = input.getText().toString();

                if (emailAddress.length() > 0 && !emailAddress.trim().isEmpty()) {
                    mAppConst.hideKeyboardInDialog(v);

                    if (PreferencesUtils.isOTPPluginEnabled(mContext)) {

                        HashMap<String, String> params = new HashMap<>();
                        params.put("email", emailAddress);

                        mAppConst.showProgressDialog();
                        alertDialog.dismiss();
                        mAppConst.postJsonResponseForUrl(UrlUtil.FORGOT_PASSWORD_OTP_URL, params, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                                mAppConst.hideProgressDialog();

                                if (jsonObject != null) {
                                    JSONObject response = jsonObject.optJSONObject("response");
                                    if (response.optInt("isEmail") == 1) {
                                        SnackbarUtils.displaySnackbarLongTime(mMainView,
                                                getResources().getString(R.string.forgot_password_success_message));

                                    } else {
                                        Intent otpIntent = new Intent(mContext, OTPActivity.class);
                                        otpIntent.putExtra("user_phoneno", response.optString("phoneno"));
                                        otpIntent.putExtra("country_code", response.optString("country_code"));
                                        otpIntent.putExtra("otp_duration", response.optInt("duration"));
                                        otpIntent.putExtra("isForgotPassword", true);
                                        otpIntent.putExtra("otp_code", response.optInt("code"));
                                        otpIntent.putExtra("otpLength", response.optInt("length", 6));
                                        otpIntent.putExtra("keyboardType", response.optInt("type"));
                                        startActivity(otpIntent);
                                        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                                    }
                                }
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                mAppConst.hideProgressDialog();
                                SnackbarUtils.displaySnackbarLongTime(mMainView, message);
                            }
                        });

                        mAppConst.hideProgressDialog();

                    } else {
                        alertDialog.dismiss();
                        HashMap<String, String> emailParams = new HashMap<>();
                        emailParams.put("email", emailAddress);

                        mAppConst.postJsonResponseForUrl(UrlUtil.FORGOT_PASSWORD_URL, emailParams, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) {
                                mAppConst.hideProgressDialog();
                                SnackbarUtils.displaySnackbarLongTime(mMainView,
                                        getResources().getString(R.string.forgot_password_success_message));
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                mAppConst.hideProgressDialog();
                                /* Show Message */
                                SnackbarUtils.displaySnackbarLongTime(mMainView, message);
                            }
                        });
                    }

                } else {
                    mAppConst.hideProgressDialog();
                    if (PreferencesUtils.isOTPPluginEnabled(mContext)) {
                        input.setError(getResources().getString(R.string.forgot_password_empty_email_phone_error_message));
                    } else {
                        input.setError(getResources().getString(R.string.forgot_password_empty_email_error_message));
                    }
                }

            }
        });

    }

    @Override
    public void onSuccess(String loginType) {

    }

    @Override
    public void onResume() {
        super.onResume();
        mBrowseAsGuest.setText(mContext.getResources().getString(R.string.browse_as_guest_skip));
        setBrowseGuestAndLanguageOptions();
    }

    @Override
    public void onError(String loginType, String errorMessage) {
        SocialLoginUtil.clearFbTwitterInstances(this, loginType);
        switch (errorMessage) {
            case "email_not_verified":
                SnackbarUtils.displaySnackbar(mMainView, getResources().getString(R.string.email_not_verified));
                break;
            case "not_approved":
                SnackbarUtils.displaySnackbar(mMainView, getResources().getString(R.string.signup_admin_approval));
                break;
            default:
                SnackbarUtils.displaySnackbar(mMainView, errorMessage);
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case RC_READ:
                if (resultCode == RESULT_OK) {
                    Credential credential = data.getParcelableExtra(Credential.EXTRA_KEY);
                    onCredentialRetrieved(credential);
                }
                break;

            case RC_HINT:
                if (resultCode == RESULT_OK) {
                    Credential credential = data.getParcelableExtra(Credential.EXTRA_KEY);
                    eEmailField.setText(credential.getId());
                }
                break;

            case RC_SAVE:
                redirectUserForLogin();
                break;
        }

        if (isShowFacebookButton) {
            callbackManager.onActivityResult(requestCode, resultCode, data);
        }
        twitterLoginButton.onActivityResult(requestCode, resultCode, data);
    }

    /**
     * Setting quick signUp form response pre-loaded if it is enabled.
     */
    private void getSignUpForm() {
        AppConstant mAppConst = new AppConstant(mContext);
        JSONObject quickSignUp = PreferencesUtils.getModuleSettings(NewLoginActivity.this, "sitequicksignup");
        if (quickSignUp != null && quickSignUp.optBoolean("isQuickSignUp", false)) {
            String mSignUpUrl = AppConstant.DEFAULT_URL + "sitequicks/index?subscriptionForm=1";
            mSignUpUrl = mAppConst.buildQueryString(mSignUpUrl, mAppConst.getAuthenticationParams());

            mAppConst.getJsonResponseFromUrl(mSignUpUrl, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                    joSignUpForm = jsonObject;
                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                }
            });
        }

    }

    public void redirectToTerms(View view) {
        Bundle termsBundle = new Bundle();
        termsBundle.putString(ConstantVariables.FRAGMENT_NAME, TERMS_OF_SERVICE_MENU_TITLE);
        termsBundle.putString(ConstantVariables.CONTENT_TITLE, getResources().getString(R.string.action_bar_title_terms_of_service));
        Intent intent = new Intent(mContext, FragmentLoadActivity.class);
        intent.putExtras(termsBundle);
        startActivity(intent);
    }

    public void redirectToPrivacy(View view) {
        Bundle privacyBundle = new Bundle();
        privacyBundle.putString(ConstantVariables.FRAGMENT_NAME, PRIVACY_POLICY_MENU_TITLE);
        privacyBundle.putString(ConstantVariables.CONTENT_TITLE, mContext.getResources().getString(R.string.privacy_policy_text));
        Intent intent = new Intent(mContext, FragmentLoadActivity.class);
        intent.putExtras(privacyBundle);
        mContext.startActivity(intent);
        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }


    void onKeyboardVisibilityChanged(boolean opened) {
        Log.v("keyboardLogs", "isOpened: " + opened);
        if (opened) {
            bottomLinksLayout.setVisibility(View.GONE);
        } else {
            bottomLinksLayout.setVisibility(View.VISIBLE);
        }
    }


}
