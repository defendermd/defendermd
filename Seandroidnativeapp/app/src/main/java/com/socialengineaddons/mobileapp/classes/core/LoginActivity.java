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

import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;

import android.content.IntentSender;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.TextInputLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatCheckBox;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

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
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.startscreens.HomeScreen;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import static com.google.android.gms.common.api.CommonStatusCodes.SIGN_IN_REQUIRED;


public class LoginActivity extends AppCompatActivity implements View.OnClickListener {


    private final int RC_READ = 1212, RC_HINT = 1213, RC_SAVE = 1214;
    private TextInputLayout usernameWrapper, passwordWrapper;
    private Button loginButton;
    private String emailValue = "";
    private String passwordValue = "";
    private boolean isValidatingData = false, isError = false,
            isNormalLogin = true;
    private Context mContext;
    private AppConstant mAppConst;
    private Toolbar mToolbar;
    private TextView mForgotPassword;
    private Bundle bundle;
    private String intentAction, intentType;
    private TextView errorView;
    private JSONObject loginResponse;
    private CredentialsClient mCredentialsClient;
    private CredentialRequest mCredentialRequest;
    private AppCompatCheckBox cbRememberMe;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        getWindow().setBackgroundDrawableResource(R.drawable.first);
        mContext = this;
        mAppConst = new AppConstant(this);

        mToolbar = (Toolbar) findViewById(R.id.my_toolbar);
        setSupportActionBar(mToolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        CustomViews.createMarqueeTitle(this, mToolbar);

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
                        }

                    }
                });

        if (getIntent() != null) {
            bundle = getIntent().getExtras();
            intentAction = getIntent().getAction();
            intentType = getIntent().getType();
        }

        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                // Playing backSound effect when user tapped on back button from tool bar.
                if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
                    SoundUtil.playSoundEffectOnBackPressed(mContext);
                }
            }
        });

        loginButton = (Button) findViewById(R.id.login_button);
        loginButton.setPadding(0, (int) getResources().getDimension(R.dimen.login_button_top_bottom_padding),
                0, (int) getResources().getDimension(R.dimen.login_button_top_bottom_padding));
        loginButton.setOnClickListener(this);
        usernameWrapper = (TextInputLayout) findViewById(R.id.usernameWrapper);
        passwordWrapper = (TextInputLayout) findViewById(R.id.passwordWrapper);
        cbRememberMe = findViewById(R.id.remember_me);
        mForgotPassword = (TextView) findViewById(R.id.forgot_password);
        mForgotPassword.setOnClickListener(this);
        usernameWrapper.setHint(getResources().getString(R.string.lbl_enter_email));
        passwordWrapper.setHint(getResources().getString(R.string.lbl_enter_password));
        errorView = (TextView) findViewById(R.id.error_view);

        if( PreferencesUtils.getOtpEnabledOption(mContext) != null &&
                !PreferencesUtils.getOtpEnabledOption(mContext).isEmpty()) {
            if (PreferencesUtils.getOtpEnabledOption(mContext).equals("both")) {
                passwordWrapper.setVisibility(View.GONE);
                mForgotPassword.setVisibility(View.GONE);
                setViewHideShow();

            } else {
                passwordWrapper.setVisibility(View.VISIBLE);
                mForgotPassword.setVisibility(View.VISIBLE);
            }
            usernameWrapper.setHint(getResources().getString(R.string.lbl_enter_email_phone));
        }
        LogUtils.LOGD(LoginActivity.class.getSimpleName(), "OtpEnabledOption->" + PreferencesUtils.getOtpEnabledOption(mContext));
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
            Log.e("", "Could not start hint picker Intent", e);
        }
    }


    private void resolveResult(ResolvableApiException rae, int requestCode) {
        try {
            rae.startResolutionForResult(LoginActivity.this, requestCode);

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
    public void signInWithPassword(String id, String password) {
        usernameWrapper.getEditText().setText(id);
        passwordWrapper.getEditText().setText(password);

        if (password != null)
            cbRememberMe.setChecked(true);
    }



    public void setViewHideShow() {
        usernameWrapper.getEditText().addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                if (charSequence.toString().matches("-?\\d+(.\\d+)?")) {
                    isNormalLogin = false;
                    mForgotPassword.setVisibility(View.GONE);
                    passwordWrapper.setVisibility(View.GONE);
                    cbRememberMe.setVisibility(View.GONE);
                    loginButton.setText(getResources().getString(R.string.otp_login_btn_name));

                } else {
                    isNormalLogin = true;
                    loginButton.setText(getResources().getString(R.string.login_btn_name));
                    if (charSequence.length() != 0) {
                        cbRememberMe.setVisibility(View.VISIBLE);
                        passwordWrapper.setVisibility(View.VISIBLE);
                        mForgotPassword.setVisibility(View.VISIBLE);
                    } else {
                        cbRememberMe.setVisibility(View.GONE);
                        passwordWrapper.setVisibility(View.GONE);
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

        emailValue = usernameWrapper.getEditText().getText().toString();

        passwordValue = passwordWrapper.getEditText().getText().toString();

        if (emailValue.isEmpty()) {
            isValidatingData = false;
            loginButton.setText(getResources().getString(R.string.login_btn_name));
            usernameWrapper.setError(getResources().getString(R.string.email_address_message));

        } else if (!passwordWrapper.isShown()) {
            passwordWrapper.setVisibility(View.VISIBLE);
            usernameWrapper.setErrorEnabled(false);
            isValidatingData = false;
            loginButton.setText(getResources().getString(R.string.login_btn_name));

        } else if (passwordValue.isEmpty()) {
            usernameWrapper.setErrorEnabled(false);
            isValidatingData = false;
            loginButton.setText(getResources().getString(R.string.login_btn_name));
            passwordWrapper.setError(getResources().getString(R.string.password_message));

        } else {

            if (!cbRememberMe.isChecked()) {
                deleteCredentials();
            }

            mAppConst.showProgressDialog();
            usernameWrapper.setErrorEnabled(false);
            passwordWrapper.setErrorEnabled(false);

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
                                rae.startResolutionForResult(LoginActivity.this, RC_SAVE);

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


    public void otpLoginClicked(){
        emailValue = usernameWrapper.getEditText().getText().toString();
        passwordValue = passwordWrapper.getEditText().getText().toString();

        if (emailValue.isEmpty()){
            isValidatingData = false;
            usernameWrapper.setError(getResources().getString(R.string.email_address_phoneno_msg));

        } else if (passwordValue.isEmpty() && PreferencesUtils.getOtpEnabledOption(mContext).equals("otp")) {
            usernameWrapper.setErrorEnabled(false);
            isValidatingData = false;
            loginButton.setText(getResources().getString(R.string.login_btn_name));
            passwordWrapper.setError(getResources().getString(R.string.password_message));

        } else {
            mAppConst.showProgressDialog();
            usernameWrapper.setErrorEnabled(false);
            passwordWrapper.setErrorEnabled(false);

            final Map<String, String> params = new HashMap<>();
            params.put("email", emailValue);
            params.put("password", passwordValue);
            params.put("ip", GlobalFunctions.getLocalIpAddress());

            LogUtils.LOGD(LoginActivity.class.getSimpleName(),"otp_login_params->" +params);
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

    public void sendToOtp(JSONObject jsonObject){

        if (jsonObject != null) {
            if (!jsonObject.has("oauth_token") || jsonObject.has("phoneno")) {

                LogUtils.LOGD(LoginActivity.class.getSimpleName(), "otp_jsonObject->" + jsonObject);
                String country_code = jsonObject.optString("country_code");
                String otpCode = jsonObject.optString("code");
                String phoneno = jsonObject.optString("phoneno");
                int otpDuration = jsonObject.optInt("duration");

                Intent otpIntent = new Intent(mContext, OTPActivity.class);
                otpIntent.putExtra("user_phoneno",  phoneno);
                otpIntent.putExtra("country_code",  country_code);
                otpIntent.putExtra("otp_duration", otpDuration);
                otpIntent.putExtra("otpLength", jsonObject.optInt("length", 6));
                otpIntent.putExtra("user_login_email", emailValue);
                otpIntent.putExtra("user_login_pass", passwordValue);
                otpIntent.putExtra("keyboardType", jsonObject.optInt("type"));
                otpIntent.putExtra("otp_code", otpCode);
                otpIntent.putExtra("mBundle", bundle);
                startActivity(otpIntent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

            } else {
                mAppConst.proceedToUserLogin(mContext, bundle, intentAction, intentType,
                        emailValue, passwordValue, jsonObject);
            }
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
                    usernameWrapper.setError(emailError);
                    passwordWrapper.setError(passError);

                } else if (emailError != null && !emailError.isEmpty()) {
                    usernameWrapper.setError(emailError);

                } else if (passError != null && !passError.isEmpty()) {
                    passwordWrapper.setError(passError);
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
        Intent loginActivity = new Intent(LoginActivity.this, HomeScreen.class);
        loginActivity.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(loginActivity);
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
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
                            loginButton.setText(getResources().getString(R.string.login_validation_msg) + "??????");
                            LoginClicked();
                        }
                    } else {
                        SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.login_main),
                                getResources().getString(R.string.network_connectivity_error));
                    }
                }
                break;

            case R.id.forgot_password:
                forgotPassword();
                break;
        }

    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data){
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
                    usernameWrapper.getEditText().setText(credential.getId());
                }
                break;

            case RC_SAVE:
                redirectUserForLogin();
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
        inputLayout.setPadding(padding20, padding20/2, padding20, padding20/2);

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
                mAppConst.hideKeyboard();
                mAppConst.showProgressDialog();

                final String emailAddress = input.getText().toString();

                if (emailAddress.length() > 0 && !emailAddress.trim().isEmpty()) {

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
                                        SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.login_main),
                                                getResources().getString(R.string.forgot_password_success_message));

                                    } else {
                                        Intent otpIntent = new Intent(mContext, OTPActivity.class);
                                        otpIntent.putExtra("user_phoneno", response.optString("phoneno"));
                                        otpIntent.putExtra("country_code", response.optString("country_code"));
                                        otpIntent.putExtra("otp_duration", response.optInt("duration"));
                                        otpIntent.putExtra("otp_code", response.optString("code"));
                                        otpIntent.putExtra("otpLength", response.optInt("length", 6));
                                        otpIntent.putExtra("keyboardType", response.optInt("type"));
                                        otpIntent.putExtra("isForgotPassword", true);
                                        startActivity(otpIntent);
                                        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                                    }
                                }
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                mAppConst.hideProgressDialog();
                                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.login_main), message);
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

                                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.login_main),
                                        getResources().getString(R.string.forgot_password_success_message));
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                mAppConst.hideProgressDialog();
                                /* Show Message */
                                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.login_main), message);
                                }
                            });
                        }

                } else {
                    mAppConst.hideProgressDialog();
                    if (PreferencesUtils.isOTPPluginEnabled(mContext)){
                        input.setError(getResources().getString(R.string.forgot_password_empty_email_phone_error_message));
                    } else {
                        input.setError(getResources().getString(R.string.forgot_password_empty_email_error_message));
                    }
                }

            }
        });

    }
}
