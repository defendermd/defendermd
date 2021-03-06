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

package com.socialengineaddons.mobileapp.classes.common.activities;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.TimePicker;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.CustomImageAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.formgenerator.FormActivity;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCancelClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.BitmapUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageViewList;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.Status;
import com.socialengineaddons.mobileapp.classes.modules.editor.NewEditorActivity;
import com.socialengineaddons.mobileapp.classes.modules.forum.ForumUtil;
import com.socialengineaddons.mobileapp.classes.modules.store.ProductViewPage;
import com.socialengineaddons.mobileapp.classes.modules.store.QuickOptionsActivity;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.wordpress.android.util.SystemServiceFactory;
import org.wordpress.android.util.ToastUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;


public class CreateNewEntry extends FormActivity implements OnUploadResponseListener {

    private Intent intent;
    public Intent viewIntent;
    public static Context mContext;
    static CreateNewEntry createNewEntry;
    private String mCreateFormUrl, mCurrentSelectedModule, mFormType = "", mToolBarTitle = "", mSuccessMessage;
    private String formatHourString, hourString, minuteString, yearString, monthString, dateString, strDateTime,
            dateTag;
    private AppConstant mAppConst;
    private HashMap<String, String> postParams;
    private Context mFormActivityContext;
    private static ArrayList<String> mSelectedPath, mSelectedMusicFiles;
    private View mSelectFileInflatedView;
    private CustomImageAdapter mCustomImageAdapter, mMusicImageAdapter;
    private String mSelectedVideoPath;
    private ProgressBar mProgressBar;
    private int columnWidth, width, mChannelId;
    private Toolbar mToolbar;
    private RelativeLayout createFormView;
    private String subject_id, mOrderInfo, mBuyerInfo, mCouponInfo;
    private String placeOrderUrl;
    private String attachVideoMessage = null, mSelectedFilePath = null;
    private int mSelectMode, mListingTypeId, mContentId, mRequestCode;
    private boolean mShowCamera, createForm = false, isRequestCompleted = false, mIsFormLoaded = false,
            mIsAddVideoToNewChannel = false, mIsStatusUserPrivacy = false;
    private String mUploadingOption, property;
    private HashMap<String, ArrayList> mHashMap;
    public boolean mIsAAFVideoUpload = false;
    private JSONObject mJsonObject, feedPostObject;
    private AlertDialogWithAction mAlertDialogWithAction;
    private String mSelectedVideoThumbnail;
    private int mVideoDuration;

    private BottomSheetDialog mBottomSheetDialog;
    private Bundle mBundle;
    public static String mCreatedItemId;

    private boolean isTicketOrder;
    private int ticketBookedResultCode;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.form_creation_view);
        mAppConst = new AppConstant(this);
        mContext = this;
        width = AppConstant.getDisplayMetricsWidth(mContext);
        createNewEntry = this;
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);

        /* Create Back Button On Action Bar **/
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(mToolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        mSelectedPath = new ArrayList<>();
        mSelectedMusicFiles = new ArrayList<>();
        mHashMap = new HashMap<>();

        createFormView = (RelativeLayout) findViewById(R.id.form_view);
        mProgressBar = (ProgressBar) findViewById(R.id.progressBar);
        mIsAddVideoToNewChannel = getIntent().getBooleanExtra("add_to_new_channel", false);
        mChannelId = getIntent().getIntExtra("channel_id", 0);
        mCreateFormUrl = getIntent().getStringExtra(ConstantVariables.CREATE_URL);

        if (getIntent().hasExtra(ConstantVariables.FORM_TYPE)) {
            mFormType = getIntent().getStringExtra(ConstantVariables.FORM_TYPE);
        }
        attachVideoMessage = getIntent().getStringExtra(ConstantVariables.ATTACH_VIDEO);
        mContentId = getIntent().getIntExtra(ConstantVariables.CONTENT_ID, 0);
        mRequestCode = getIntent().getIntExtra(ConstantVariables.REQUEST_CODE, ConstantVariables.PAGE_EDIT_CODE);
        mIsStatusUserPrivacy = getIntent().getBooleanExtra("is_status_privacy", false);

        //Fetch Current Selected Module
        mCurrentSelectedModule = getIntent().getStringExtra(ConstantVariables.EXTRA_MODULE_TYPE);
        if (mCurrentSelectedModule == null || mCurrentSelectedModule.isEmpty()) {
            mCurrentSelectedModule = PreferencesUtils.getCurrentSelectedModule(mContext);
        }

        //Fetch Current Selected Module
        if (mCurrentSelectedModule.equals("core_main_siteevent") && mFormType != null && mFormType.equals("payment_method")) {
            placeOrderUrl = getIntent().getStringExtra(ConstantVariables.URL_STRING);
            subject_id = getIntent().getStringExtra(ConstantVariables.SUBJECT_ID);
            mOrderInfo = getIntent().getStringExtra(ConstantVariables.RESPONSE_OBJECT);
            mBuyerInfo = getIntent().getStringExtra("buyerInfoObject");

            if (getIntent().hasExtra("couponInfoObject")) {
                mCouponInfo = getIntent().getStringExtra("couponInfoObject");
            }
        }

        mContentId = getIntent().getIntExtra(ConstantVariables.CONTENT_ID, 0);
        mIsAAFVideoUpload = getIntent().getBooleanExtra(ConstantVariables.AAF_VIDEO, false);
        mBundle = getIntent().getExtras();
        if (mBundle != null) {
            mToolBarTitle = mBundle.getString(ConstantVariables.KEY_TOOLBAR_TITLE, getResources().getString(R.string.item_create));
            mSuccessMessage = mBundle.getString(ConstantVariables.KEY_SUCCESS_MESSAGE, getResources().getString(R.string.item_created_successfully));
        }


        // Set Title of the Action Bar
        switch (mCurrentSelectedModule) {

            case ConstantVariables.MLT_MENU_TITLE:
            case ConstantVariables.MLT_WISHLIST_MENU_TITLE:
                mListingTypeId = getIntent().getIntExtra(ConstantVariables.LISTING_TYPE_ID, 0);
            case ConstantVariables.FORUM_MENU_TITLE:
            case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
            case ConstantVariables.SITE_PAGE_MENU_TITLE:
            case ConstantVariables.ADV_GROUPS_MENU_TITLE:
            case ConstantVariables.PRODUCT_MENU_TITLE:
            case ConstantVariables.DIARY_MENU_TITLE:
            case ConstantVariables.ADV_VIDEO_MENU_TITLE:
            case ConstantVariables.PAYMENT_METHOD_CONFIG:
            case ConstantVariables.STORE_MENU_TITLE:

                if (mFormType != null) {

                    switch (mFormType) {
                        case "post_reply":
                        case "quote":
                            mToolBarTitle = getResources().getString(R.string.title_post_reply);
                            mSuccessMessage = getResources().getString(R.string.success_forum_create);
                            break;
                        case "create_topic":
                            mToolBarTitle = getResources().getString(R.string.title_create_topic);
                            mSuccessMessage = getResources().getString(R.string.success_forum_create);
                            break;
                        case "move_topic":
                            mToolBarTitle = getResources().getString(R.string.title_move_topic);
                            mSuccessMessage = getResources().getString(R.string.success_move_topic);
                            break;
                        case "add_video":
                            mToolBarTitle = getResources().getString(R.string.add_video_text);
                            mCurrentSelectedModule = "sitereview_video";
                            break;
                        case "create_review":
                            mSuccessMessage = getResources().getString(R.string.review_submit_success_message);
                            mToolBarTitle = getResources().getString(R.string.title_write_a_review);
                            break;
                        case "add_wishlist":
                            mSuccessMessage = getResources().getString(R.string.add_wishlist_success_message);
                            mToolBarTitle = getResources().getString(R.string.add_wishlist_text);
                            break;
                        case "message_owner":
                            mSuccessMessage = getResources().getString(R.string.message_send_to_owner_success_message);
                            mToolBarTitle = getIntent().getStringExtra(ConstantVariables.CONTENT_TITLE);
                            break;
                        case "create_new_diary":
                            mToolBarTitle = getResources().getString(R.string.title_create_diary);
                            break;
                        case "add_to_diary":
                            mToolBarTitle = getResources().getString(R.string.title_add_to_diary);
                            mSuccessMessage = getResources().getString(R.string.event_added_to_diary_success_message);
                            break;
                        case "tellafriend":
                            mToolBarTitle = getResources().getString(R.string.title_tell_a_friend);
                            mSuccessMessage = getResources().getString(R.string.tell_friend_success_message);
                            break;
                        case "notification_settings":
                            mToolBarTitle = getResources().getString(R.string.title_notification_and_email_settings);
                            mSuccessMessage = getResources().getString(R.string.notification_setting_success_message);
                            break;
                        case "compose_message":
                            mToolBarTitle = getResources().getString(R.string.title_compose_message);
                            mSuccessMessage = getResources().getString(R.string.compose_success_message);
                            break;
                        case "capacity_waitlist":
                            mToolBarTitle = getResources().getString(R.string.capacity_and_waitlist_title);
                            mSuccessMessage = getResources().getString(R.string.event_capacity_success_message);
                            break;
                        case "payment_method":
                            mToolBarTitle = getResources().getString(R.string.payment_method_text);
//                            mSuccessMessage="Ticket Booked Successfully";
                            break;
                        case "add_to_playlist":
                            mToolBarTitle = getResources().getString(R.string.add_to_playlist);
                            mSuccessMessage = getResources().getString(R.string.add_to_playlist_success_message);
                            break;
                        case ConstantVariables.PAYMENT_METHOD_CONFIG:
                            mToolBarTitle = getResources().getString(R.string.payment_methods_label);
                            mSuccessMessage = getResources().getString(R.string.payment_method_configuration_message);
                            break;
                        case "add_product":
                            mToolBarTitle = getResources().getString(R.string.add_product_label);
                            mSuccessMessage = getResources().getString(R.string.add_product_created_message);
                            break;
                        case ConstantVariables.SHIPPING_METHOD:
                            mToolBarTitle = getResources().getString(R.string.add_new_shipping_method_label);
                            mSuccessMessage = getResources().getString(R.string.add_new_shipping_method_created_message);
                            break;
                        case "main_file":
                        case "sample_file":
                            mToolBarTitle = getResources().getString(R.string.add_new_file);
                            mSuccessMessage = getResources().getString(R.string.new_file_created_message);
                            break;
                        case "store_create":
                            mToolBarTitle = getResources().getString(R.string.create_store_title);
                            mSuccessMessage = getResources().getString(R.string.create_store_success_message);
                            mFormType = null;
                            break;

                    }
                } else {
                    mToolBarTitle = GlobalFunctions.getLabelOfModule(mContext, mCurrentSelectedModule, true);
                    if (mCurrentSelectedModule.equals(ConstantVariables.ADVANCED_EVENT_MENU_TITLE)) {
                        createForm = true;
                    }
                }

                break;

            case ConstantVariables.VIDEO_MENU_TITLE:
                if (mFormType != null && mFormType.equals("add_video_siteevent")) {
                    mToolBarTitle = getResources().getString(R.string.add_video_text);
                    mSuccessMessage = getResources().getString(R.string.add_video_success_message);
                } else {
                    mToolBarTitle = GlobalFunctions.getLabelOfModule(mContext, mCurrentSelectedModule, true);
                }
                break;

            case "add_to_friend_list":
                mToolBarTitle = getResources().getString(R.string.add_to_list_text);
                break;

            case "add_video_sitestore":
            case "add_video_sitegroup":
            case "add_video_sitepage":
            case "add_video_siteevent":
                mToolBarTitle = getResources().getString(R.string.add_video_text);
                mSuccessMessage = getResources().getString(R.string.add_video_success_message);
                break;

            default:
                if (attachVideoMessage != null) {
                    mToolBarTitle = getResources().getString(R.string.add_video_text);
                } else if (getIntent().getStringExtra(ConstantVariables.CONTENT_TITLE) != null) {
                    mToolBarTitle = getIntent().getStringExtra(ConstantVariables.CONTENT_TITLE);
                } else if (mToolBarTitle == null) {
                    mToolBarTitle = GlobalFunctions.getLabelOfModule(mContext, mCurrentSelectedModule, true);
                }
                break;
        }
        getSupportActionBar().setTitle(mToolBarTitle);
        CustomViews.createMarqueeTitle(this, mToolbar);

        if (!mIsStatusUserPrivacy) {
            makeRequest();
        } else {
            showUserPrivacyOptions();
        }

    }

    /**
     * Method to show privacy form.
     */
    private void showUserPrivacyOptions() {
        try {
            mProgressBar.setVisibility(View.GONE);
            JSONObject jsonObject = new JSONObject();
            if (getIntent().getBooleanExtra("isFriendList", false)) {
                if (Status.USER_LIST_ARRAY != null && Status.USER_LIST_ARRAY.length() > 0) {
                    createFormView.setGravity(Gravity.NO_GRAVITY);
                    createFormView.addView(generateForm(jsonObject.put("userlist", Status.USER_LIST_ARRAY), true, "userlist"));
                } else {
                    View errorView = LayoutInflater.from(mContext).inflate(R.layout.error_view, null);
                    TextView tvErrorMessage = (TextView) errorView.findViewById(R.id.error_message);
                    TextView tvAction = (TextView) errorView.findViewById(R.id.action);
                    tvAction.setVisibility(View.VISIBLE);
                    errorView.findViewById(R.id.error_icon).setVisibility(View.GONE);
                    tvErrorMessage.setTextColor(ContextCompat.getColor(mContext, R.color.black));
                    tvErrorMessage.setText(mContext.getResources().getString(R.string.no_friend_list));
                    tvAction.setText(mContext.getResources().getString(R.string.manage_list));
                    tvAction.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            Intent intent = new Intent(mContext, userProfile.class);
                            intent.putExtra("isShowFriends", true);
                            intent.putExtra(ConstantVariables.USER_ID, getIntent().getIntExtra("user_id", 0));
                            startActivityForResult(intent, ConstantVariables.USER_PRIVACY_REQUEST_CODE);
                            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                        }
                    });
                    errorView.setVisibility(View.VISIBLE);
                    createFormView.setGravity(Gravity.CENTER);
                    createFormView.addView(errorView);
                }
            } else {
                createFormView.addView(generateForm(jsonObject.put("multiple_networklist", Status.NETWORK_LIST_ARRAY), true, "multiple_networklist"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void makeRequest() {
        /*
        Code to Send Request for Create Form
         */
        mProgressBar.setVisibility(View.VISIBLE);
        mAppConst.getJsonResponseFromUrl(mCreateFormUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mIsFormLoaded = true;
                mProgressBar.setVisibility(View.GONE);
                FormActivity.setFormObject(jsonObject);
                if (jsonObject.has("message") && jsonObject.has("url")) {
                    String packageMessage = mContext.getResources().getString(R.string.package_click_text) +
                            " [" + mContext.getResources().getString(R.string.package_redirection_info) + "]";
                    mAlertDialogWithAction.showSubscriptionDialog(packageMessage, jsonObject.optString("url"));

                } else {
                    switch (mCurrentSelectedModule) {

                        case ConstantVariables.BLOG_MENU_TITLE:
                        case ConstantVariables.CLASSIFIED_MENU_TITLE:
                        case ConstantVariables.FORUM_MENU_TITLE:
                            createFormView.addView(generateForm(jsonObject, true, mCurrentSelectedModule));
                            createFormView.findViewById(R.id.add_description).setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {
                                    openEditor();
                                }
                            });
                            break;

                        case ConstantVariables.MLT_MENU_TITLE:
                        case ConstantVariables.STORE_MENU_TITLE:
                        case ConstantVariables.PRODUCT_MENU_TITLE:
                            if (mFormType != null) {
                                switch (mFormType) {
                                    case "add_wishlist":
                                    case "main_file":
                                    case "sample_file":
                                    case ConstantVariables.SHIPPING_METHOD:
                                    case ConstantVariables.CREATE_REVIEW:
                                        createFormView.addView(generateForm(jsonObject, true, mFormType));
                                        break;
                                    case ConstantVariables.ADD_PRODUCT:
                                        createFormView.addView(generateForm(jsonObject, true, mFormType, mContentId));
                                        break;

                                    default:
                                        createFormView.addView(generateForm(jsonObject, true, mCurrentSelectedModule));
                                        break;

                                }
                            } else {
                                createFormView.addView(generateForm(jsonObject, true, mCurrentSelectedModule));
                            }
                            break;


                        case ConstantVariables.ADV_VIDEO_MENU_TITLE:
                            // When creating a video after a channel creation.
                            // then showing the created channel already selected.
                            if (mChannelId != 0) {
                                try {
                                    JSONArray jsonArray = jsonObject.optJSONArray("form");
                                    JSONObject channelObject = jsonArray.optJSONObject(0);
                                    channelObject.put("value", String.valueOf(mChannelId));
                                    jsonArray.put(0, channelObject);
                                    jsonObject.put("form", jsonArray);
                                } catch (NullPointerException | JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
                        case ConstantVariables.DIARY_MENU_TITLE:

                            if (mFormType != null) {
                                switch (mFormType) {
                                    case "create_new_diary":
                                    case "add_to_diary":
                                    case "create_review":
                                    case "tellafriend":
                                    case "message_owner":
                                    case "notification_settings":
                                    case "compose_message":
                                    case "add_video_siteevent":
                                    case "capacity_waitlist":
                                    case "payment_method":
                                    case "add_to_playlist":
                                        createFormView.addView(generateForm(jsonObject, true, mFormType));
                                        break;

                                    default:
                                        createFormView.addView(generateForm(jsonObject, true, mCurrentSelectedModule));
                                        break;
                                }

                            } else {
                                createFormView.addView(generateForm(jsonObject, true, mCurrentSelectedModule));
                            }
                            break;

                        case ConstantVariables.SITE_PAGE_MENU_TITLE:
                        case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                            if (mFormType != null) {
                                switch (mFormType) {
                                    case "create_review":
                                        createFormView.addView(generateForm(jsonObject, true, "create_review"));
                                        break;
                                    case "compose_message":
                                        createFormView.addView(generateForm(jsonObject, true, "compose_message",
                                                mContentId));
                                        break;
                                    default:
                                        createFormView.addView(generateForm(jsonObject, true, mCurrentSelectedModule));
                                        break;
                                }
                            } else {
                                createFormView.addView(generateForm(jsonObject, true, mCurrentSelectedModule));
                            }
                            break;

                        default:
                            createFormView.addView(generateForm(jsonObject, true, mCurrentSelectedModule));
                            break;
                    }
                    if (attachVideoMessage != null) {
                        mJsonObject = jsonObject;
                    }
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mIsFormLoaded = false;
                mProgressBar.setVisibility(View.GONE);
                SnackbarUtils.displaySnackbarLongWithListener(createFormView,
                        message, new SnackbarUtils.OnSnackbarDismissListener() {
                            @Override
                            public void onSnackbarDismissed() {
                                finish();
                            }
                        });
            }
        });
    }

    /* Start the editor if the description need to edited
     * Including it's parameters */
    public void openEditor() {

        postParams = save();
        if (postParams != null) {

            Intent intent = new Intent(CreateNewEntry.this, NewEditorActivity.class);
            Bundle bundle = new Bundle();
            bundle.putString(NewEditorActivity.POST_URL, mCreateFormUrl);
            bundle.putStringArrayList(NewEditorActivity.SELECTED_PATHS, mSelectedPath);
            bundle.putString(NewEditorActivity.TITLE_PARAM, "");
            bundle.putString(NewEditorActivity.CONTENT_PARAM, "");
            bundle.putSerializable(NewEditorActivity.POST_PARAM, postParams);
            bundle.putString(NewEditorActivity.TITLE_PLACEHOLDER_PARAM,
                    getString(R.string.example_post_title_placeholder));
            bundle.putString(NewEditorActivity.CONTENT_PLACEHOLDER_PARAM,
                    getString(R.string.post_content_placeholder) + "???");
            bundle.putInt(NewEditorActivity.EDITOR_PARAM, NewEditorActivity.USE_NEW_EDITOR);
            bundle.putInt("textColorPrimary", mContext.getResources().getColor(R.color.textColorPrimary));
            bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, mCurrentSelectedModule);
            bundle.putInt(NewEditorActivity.PAGE_DETAIL, NewEditorActivity.CREATE_PAGE);
            bundle.putString("forumType", mFormType);
            if (mFormType != null && mFormType.equals("quote")) {
                bundle.putString(NewEditorActivity.CONTENT_PARAM, getIntent().getStringExtra("quote_text"));
            }
            intent.putExtras(bundle);
            startActivityForResult(intent, ConstantVariables.EDITOR_REQUEST_CODE);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_with_action_icon, menu);
        menu.findItem(R.id.submit).setTitle(getResources().getString(R.string.create));
        return true;
    }

    /***
     * Called when invalidateOptionsMenu() is triggered
     */
    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        MenuItem submit = menu.findItem(R.id.submit);
        if (submit != null) {
            Drawable drawable = submit.getIcon();
            drawable.setColorFilter(ContextCompat.getColor(this, R.color.textColorPrimary), PorterDuff.Mode.SRC_ATOP);
        }
        switch (mCurrentSelectedModule) {
            case ConstantVariables.FORUM_MENU_TITLE:
                menu.findItem(R.id.submit).setVisible(mFormType.equals("move_topic"));
                break;

            case ConstantVariables.CLASSIFIED_MENU_TITLE:
            case ConstantVariables.BLOG_MENU_TITLE:
                menu.findItem(R.id.submit).setVisible(false);
                break;

            default:
                menu.findItem(R.id.submit).setVisible(true);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        switch (id) {
            case R.id.submit:
                if (mIsFormLoaded) {
                    createEntry();
                } else if (mIsStatusUserPrivacy) {
                    checkUserPrivacyValues();
                }
                break;
            case android.R.id.home:
                onBackPressed();
                // Playing backSound effect when user tapped on back button from tool bar.
                if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
                    SoundUtil.playSoundEffectOnBackPressed(mContext);
                }
                return true;
        }

        return super.onOptionsItemSelected(item);
    }

    /**
     * Method to send user post privacy options.
     */
    private void checkUserPrivacyValues() {
        postParams = new HashMap<>();
        postParams = save();
        if (postParams != null && postParams.size() > 0
                && findViewById(R.id.noFriendsMessage).getVisibility() == View.GONE) {
            Intent intent = new Intent();
            intent.putExtra("param", postParams);
            intent.putExtra("privacy_key", getIntent().getStringExtra("privacy_key"));
            intent.putExtra("feed_post_menu", feedPostObject != null ? feedPostObject.toString() : null);
            setResult(ConstantVariables.USER_PRIVACY_REQUEST_CODE, intent);
        }
        finish();
    }

    /* Sending request to the server if editor is not required  */
    public void createEntry() {

        mAppConst.hideKeyboard();

        postParams = new HashMap<>();
        postParams = save();

        if (mCurrentSelectedModule.equals("core_main_siteevent") && mFormType != null
                && mFormType.equals("payment_method") && postParams != null) {
            isTicketOrder = true;
            mCreateFormUrl = placeOrderUrl;
            postParams.put("event_id", subject_id);
            postParams.put("order_info", mOrderInfo);
            postParams.put("buyer_info", mBuyerInfo);

            if (mCouponInfo != null && !mCouponInfo.isEmpty()) {
                postParams.put("coupon_info", mCouponInfo);
            }
        } else if (mCurrentSelectedModule.equals(ConstantVariables.STORE_MENU_TITLE)
                && postParams != null && postParams.containsKey("product_type") && mFormType.equals("add_product")) {
            mCreateFormUrl += "&product_type=" + postParams.get("product_type");
            finish();
            Intent createIntent = new Intent(mContext, CreateNewEntry.class);
            createIntent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.PRODUCT_MENU_TITLE);
            createIntent.putExtra(ConstantVariables.CREATE_URL, mCreateFormUrl);
            createIntent.putExtra(ConstantVariables.CONTENT_ID, mContentId);
            createIntent.putExtra(ConstantVariables.FORM_TYPE, ConstantVariables.ADD_PRODUCT);
            startActivity(createIntent);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

            return;
        }
        if (FormActivity.selectedProducts != null && FormActivity.selectedProducts.size() > 0) {
            postParams.put("product_ids", android.text.TextUtils.join(",", FormActivity.selectedProducts));
        }

        Map<String, String> mVideoParams = new HashMap<>();
        if (mSelectedVideoPath != null) {
            postParams.put("duration", String.valueOf(mVideoDuration));
            mVideoParams.put("filedata", mSelectedVideoPath);
            mVideoParams.put("photo", mSelectedVideoThumbnail);
            postParams.put("type", "3");
        }

        if (postParams != null && !isRequestCompleted) {
            // uploading the file to server
            new UploadFileToServerUtils(mContext, mCreateFormUrl, mCurrentSelectedModule,
                    createForm, mSelectedPath, mSelectedMusicFiles, postParams, mHashMap,
                    mSelectedFilePath, mVideoParams).execute();
        }
    }

    @Override
    public void onBackPressed() {
        mAppConst.hideKeyboard();

        if (mFormType != null && ((mCurrentSelectedModule.equals("core_main_siteevent") && mFormType.equals("payment_method"))
                || (mCurrentSelectedModule.equals(ConstantVariables.STORE_MENU_TITLE) && mFormType.equals(ConstantVariables.SHIPPING_METHOD)))) {
            setResult(ConstantVariables.REQUEST_CANCLED);
            finish();
        }
        super.onBackPressed();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);


    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        FormActivity.overviewText = "";
        FormActivity.hostKey = null;
    }

    //Method for Checking WRITE_EXTERNAL_STORAGE permission
    public void checkPermission(Context context, int selectedMode, boolean showCamera, String uploadingOption,
                                String name, View configView) {

        mFormActivityContext = context;
        mSelectMode = selectedMode;
        mShowCamera = showCamera;
        mUploadingOption = uploadingOption;
        property = name;
        mSelectFileInflatedView = configView;

        /* Check if permission is granted or not */
        if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    ConstantVariables.WRITE_EXTERNAL_STORAGE);
        } else {
            switch (mUploadingOption) {
                case "photo":
                    startMultiImageSelectorActivity();
                    break;
                case "video":
                    startVideoUploading();
                    break;
                case "music":
                    GlobalFunctions.addMusicBlock(mFormActivityContext);
                    break;
                case "upload_product":
                    startFileUploading();
                    break;
            }
        }
    }

    private void startMultiImageSelectorActivity() {

        intent = new Intent(mFormActivityContext, MultiMediaSelectorActivity.class);
        // Selection type photo to display items in grid
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECTION_TYPE, MultiMediaSelectorActivity.SELECTION_PHOTO);
        // Whether photoShoot
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SHOW_CAMERA, mShowCamera);
        // The maximum number of selectable image
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_COUNT, ConstantVariables.FILE_UPLOAD_LIMIT);
        // Select mode
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_MODE, mSelectMode);
        // The default selection
        if (mSelectedPath != null && mSelectedPath.size() > 0) {
            intent.putExtra(MultiMediaSelectorActivity.EXTRA_DEFAULT_SELECTED_LIST, mSelectedPath);
        }
        ((Activity) mFormActivityContext).startActivityForResult(intent, ConstantVariables.REQUEST_IMAGE);
    }


    //Method for uploading videos
    public void startVideoUploading() {
        Intent intent = new Intent(mContext, MultiMediaSelectorActivity.class);
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SHOW_CAMERA, false);
        // Selection type video to display items in grid
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECTION_TYPE, MultiMediaSelectorActivity.SELECTION_VIDEO);
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_COUNT, ConstantVariables.STORY_POST_COUNT_LIMIT);

        // Select mode
        intent.putExtra(MultiMediaSelectorActivity.EXTRA_SELECT_MODE, MultiMediaSelectorActivity.MODE_SINGLE);
        startActivityForResult(intent, ConstantVariables.REQUEST_VIDEO_CODE);
    }

    private void startFileUploading() {
        intent = new Intent(Intent.ACTION_PICK, MediaStore.Video.Media.EXTERNAL_CONTENT_URI);
        intent.setType("*/*");
        ((Activity) mFormActivityContext).startActivityForResult(Intent.createChooser(intent, getResources().getString(R.string.select_a_file)), ConstantVariables.INPUT_FILE_REQUEST_CODE);

    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case ConstantVariables.REQUEST_IMAGE:
                if (resultCode == RESULT_OK) {
                    mSelectedPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);

                    if (property != null && property.equals("host_photo")) {
                        mHashMap.put("host_photo", mSelectedPath);
                    } else {
                        mHashMap.put("photo", mSelectedPath);
                    }

                    InitializeColumnWidth(4);
                    final List<ImageViewList> photoUrls = new ArrayList<>();
                    final RecyclerView resultRecyclerView = (RecyclerView) mSelectFileInflatedView.findViewById(R.id.recycler_view_list);
                    resultRecyclerView.setLayoutManager(new LinearLayoutManager(mContext,
                            LinearLayoutManager.HORIZONTAL, false));
                    mCustomImageAdapter = new CustomImageAdapter(CreateNewEntry.this, photoUrls, columnWidth, new OnCancelClickListener() {
                        @Override
                        public void onCancelButtonClicked(int removedImage) {
                            if (mSelectedPath != null && !mSelectedPath.isEmpty()) {
                                mSelectedPath.remove(removedImage);
                                photoUrls.remove(removedImage);
                                mCustomImageAdapter.notifyDataSetChanged();
                                if (mSelectedPath.isEmpty()) {
                                    resultRecyclerView.setVisibility(View.GONE);
                                }
                            }

                        }
                    });
                    resultRecyclerView.setAdapter(mCustomImageAdapter);

                    resultRecyclerView.setVisibility(View.VISIBLE);
                    for (int i = 0; i < mSelectedPath.size(); i++) {
                        photoUrls.add(new ImageViewList(BitmapUtils.decodeSampledBitmapFromFile(CreateNewEntry.this,
                                mSelectedPath.get(i), width,
                                (int) getResources().getDimension(R.dimen.feed_attachment_image_height), false)));
                        mCustomImageAdapter.notifyDataSetChanged();
                    }
                } else if (resultCode != RESULT_CANCELED) {

                    // failed to capture image
                    SnackbarUtils.displaySnackbar(createFormView,
                            getResources().getString(R.string.image_capturing_failed));

                }
                break;
            case ConstantVariables.REQUEST_VIDEO_CODE:
                if ((resultCode == RESULT_OK && data != null)
                        || (resultCode == RESULT_OK)) {
                    setAttachedVideo(data);

                } else if (resultCode != RESULT_CANCELED) {
                    // failed to capture image
                    SnackbarUtils.displaySnackbar(createFormView,
                            getResources().getString(R.string.video_capturing_failed));

                }
                break;
            case ConstantVariables.REQUEST_MUSIC:

                if (resultCode == RESULT_OK && data != null) {

                    Uri selectedMusicUri = data.getData();
                    if (selectedMusicUri != null) {
                        if (mSelectedMusicFiles.size() < 5) {
                            mSelectedMusicFiles.add(GlobalFunctions.getMusicFilePathFromURI(this, selectedMusicUri));

                            InitializeColumnWidth(12);
                            final List<ImageViewList> photoUrls = new ArrayList<>();
                            final RecyclerView resultRecyclerView = (RecyclerView) mSelectFileInflatedView.findViewById(R.id.recycler_view_list);
                            resultRecyclerView.setLayoutManager(new LinearLayoutManager(mContext));
                            mMusicImageAdapter = new CustomImageAdapter(CreateNewEntry.this, photoUrls, columnWidth,
                                    new OnCancelClickListener() {
                                        @Override
                                        public void onCancelButtonClicked(int removedSong) {
                                            if (mSelectedMusicFiles != null && !mSelectedMusicFiles.isEmpty()) {
                                                mSelectedMusicFiles.remove(removedSong);
                                                photoUrls.remove(removedSong);
                                                mMusicImageAdapter.notifyDataSetChanged();
                                                if (mSelectedMusicFiles.isEmpty()) {
                                                    resultRecyclerView.setVisibility(View.GONE);
                                                }
                                            }
                                        }
                                    });
                            resultRecyclerView.setAdapter(mMusicImageAdapter);
                            resultRecyclerView.setVisibility(View.VISIBLE);
                            for (int i = 0; i < mSelectedMusicFiles.size(); i++) {
                                photoUrls.add(new ImageViewList(ContextCompat.getDrawable(mContext,
                                        R.drawable.ic_empty_music2), mSelectedMusicFiles.get(i)
                                        .substring(mSelectedMusicFiles.get(i).lastIndexOf("/") + 1)));
                            }
                            mMusicImageAdapter.notifyDataSetChanged();
                        } else {
                            SnackbarUtils.displaySnackbar(createFormView,
                                    getResources().getString(R.string.music_upload_limit_msg));
                        }
                    }

                } else if (resultCode != RESULT_CANCELED) {
                    SnackbarUtils.displaySnackbar(createFormView,
                            getResources().getString(R.string.music_capturing_failed));

                }
                break;

            case ConstantVariables.EDITOR_REQUEST_CODE:
                if (resultCode == RESULT_OK) {
                    setResult(ConstantVariables.CREATE_REQUEST_CODE, data);
                    finish();
                }
                break;

            case ConstantVariables.VIEW_PAGE_CODE:
                if (resultCode != 0) {
                    setResult(ConstantVariables.VIEW_PAGE_CODE, data);
                }
                finish();
                break;

            // When uploading video from my device option from aaf video uploader.
            case ConstantVariables.CREATE_REQUEST_CODE:
                if (resultCode == ConstantVariables.CREATE_REQUEST_CODE) {
                    Intent intent = new Intent();
                    setResult(ConstantVariables.CREATE_REQUEST_CODE, intent);
                    finish();
                } else if (mJsonObject != null) {
                    // Again loading the for, when back pressed from create video page.
                    attachVideoMessage = ConstantVariables.ATTACH_VIDEO;
                    JSONArray jsonArray = mJsonObject.optJSONArray("response");
                    JSONObject jsonObject = jsonArray.optJSONObject(0);
                    try {
                        jsonObject.put("value", 3);
                        jsonArray.put(0, jsonObject);
                        mJsonObject.put("response", jsonArray);
                    } catch (NullPointerException | JSONException e) {
                        e.printStackTrace();
                    }
                    createFormView.removeAllViews();
                    createFormView.addView(generateForm(mJsonObject, true, mCurrentSelectedModule));
                }
                break;

            case ConstantVariables.OVERVIEW_REQUEST_CODE:
                if (resultCode == RESULT_OK) {
                    FormActivity.overviewText = data.getStringExtra(ConstantVariables.EXTRA_CREATE_RESPONSE);
                    if (FormActivity._layout != null) {
                        View overView = FormActivity._layout.findViewWithTag("overview");
                        EditText etOverView = (EditText) overView.findViewById(R.id.field_value);
                        CustomViews.setEditText(etOverView, FormActivity.overviewText);
                    }
                }
                break;

            case ConstantVariables.WEB_VIEW_ACTIVITY_CODE:
                String message = null;

                switch (resultCode) {
                    case ConstantVariables.PAYMENT_FAILED_ACTIVITY_CODE:
                        message = getResources().getString(R.string.payment_failed_message);
                        break;

                    case ConstantVariables.PAYMENT_SUCCESS_ACTIVITY_CODE:
                        message = getResources().getString(R.string.payment_success_message);
                        break;
                }

                SnackbarUtils.displaySnackbarLongWithListener(createFormView, message,
                        new SnackbarUtils.OnSnackbarDismissListener() {
                            @Override
                            public void onSnackbarDismissed() {
                                setResult(ConstantVariables.CREATE_REQUEST_CODE);
                                finish();
                            }
                        });
                break;

            case ConstantVariables.UPDATE_REQUEST_CODE:
                if (resultCode == ConstantVariables.CREATE_REQUEST_CODE && data != null) {
                    mChannelId = data.getIntExtra("channel_id", 0);
                }
                mCurrentSelectedModule = ConstantVariables.ADV_VIDEO_MENU_TITLE;
                mCreateFormUrl = AppConstant.DEFAULT_URL + "advancedvideos/create";
                FormActivity._layout.removeAllViews();
                createFormView.removeAllViews();
                createFormView.addView(mProgressBar);
                makeRequest();
                break;
            case ConstantVariables.SELECT_PRODUCT_RETURN_CODE:
                if (FormActivity._layout != null && resultCode == ConstantVariables.SELECT_PRODUCT_RETURN_CODE) {
                    FormActivity.selectedProducts = data.getStringArrayListExtra(ConstantVariables.SELECT_PRODUCT);
                    View overView = FormActivity._layout.findViewWithTag("product_search");
                    EditText etOverView = (EditText) overView.findViewById(R.id.field_value);
                    CustomViews.setEditText(etOverView, FormActivity.selectedProducts.size() + " " + getResources().getString(R.string.select_a_file));
                }
                break;

            case ConstantVariables.INPUT_FILE_REQUEST_CODE:
                if (resultCode == RESULT_OK && data != null) {
                    Uri selectedFileUri = data.getData();
                    if (selectedFileUri != null) {
                        mSelectedFilePath = GlobalFunctions.getFileRealPathFromUri(CreateNewEntry.this, selectedFileUri);
                        String fileDescription = "file";
                        if (mSelectedFilePath != null) {
                            fileDescription = mSelectedFilePath.substring(mSelectedFilePath.lastIndexOf("/") + 1);
                        }
                        fileDescription = "<b>" + fileDescription + "</b><br/>" + getResources().getString(R.string.file_uploading_message);
                        InitializeColumnWidth(10);
                        final List<ImageViewList> photoUrls = new ArrayList<>();
                        final RecyclerView resultRecyclerView = (RecyclerView) mSelectFileInflatedView.findViewById(R.id.recycler_view_list);
                        resultRecyclerView.setLayoutManager(new LinearLayoutManager(CreateNewEntry.this));
                        CustomImageAdapter customImageAdapter = new CustomImageAdapter(CreateNewEntry.this,
                                photoUrls, columnWidth, new OnCancelClickListener() {
                            @Override
                            public void onCancelButtonClicked(int userId) {
                                if (!photoUrls.isEmpty()) {
                                    photoUrls.remove(userId);
                                    mSelectedFilePath = null;
                                    resultRecyclerView.setVisibility(View.GONE);
                                }
                            }
                        });
                        resultRecyclerView.setAdapter(customImageAdapter);
                        resultRecyclerView.setVisibility(View.VISIBLE);
                        Drawable fileDrawable = ContextCompat.getDrawable(CreateNewEntry.this, R.drawable.ic_attachment_white_24dp);
                        fileDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(CreateNewEntry.this, R.color.dark_gray),
                                PorterDuff.Mode.SRC_ATOP));
                        photoUrls.add(new ImageViewList(fileDrawable, fileDescription));
                        customImageAdapter.notifyDataSetChanged();
                    }

                } else if (resultCode != RESULT_CANCELED) {
                    SnackbarUtils.displaySnackbar(createFormView, getResources().getString(R.string.file_uploading_failed));

                }
                break;
            case ConstantVariables.USER_PRIVACY_REQUEST_CODE:
                createFormView.removeAllViews();
                createFormView.addView(mProgressBar);
                mProgressBar.setVisibility(View.VISIBLE);
                mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/feeds/feed-post-menus",
                        new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) {
                                if (jsonObject != null && jsonObject.optJSONObject("feed_post_menu") != null) {
                                    feedPostObject = jsonObject.optJSONObject("feed_post_menu");
                                    Status.USER_LIST_ARRAY = feedPostObject.optJSONArray("userlist");
                                    showUserPrivacyOptions();
                                }
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                mProgressBar.setVisibility(View.GONE);
                                SnackbarUtils.displaySnackbarLongWithListener(createFormView,
                                        message, new SnackbarUtils.OnSnackbarDismissListener() {
                                            @Override
                                            public void onSnackbarDismissed() {
                                                finish();
                                            }
                                        });
                            }
                        });
                break;
        }
    }

    private void setAttachedVideo(Intent data) {
        mSelectedVideoPath = data.getStringExtra(MultiMediaSelectorActivity.VIDEO_RESULT);

        File file = new File(mSelectedVideoPath);
        long length = file.length();
        length = (int) length / (1024 * 1024);
        String message = ConstantVariables.VALID_FILE_SIZE;
        if ((message = GlobalFunctions.validateFileSize(length, mContext)).equals(ConstantVariables.VALID_FILE_SIZE)) {
            mVideoDuration = GlobalFunctions.getDurationFromVideoFile(mContext, file);
            new LoadVideoThumbAsync(mSelectedVideoPath).execute();

        } else {
            mSelectedVideoPath = null;
            mSelectedVideoThumbnail = null;
            SnackbarUtils.displayMultiLineSnackbarWithAction(mContext, createFormView, message, mContext.getResources().
                    getString(R.string.try_again), new SnackbarUtils.OnSnackbarActionClickListener() {

                @Override
                public void onSnackbarActionClick() {
                    startVideoUploading();
                }
            });
        }
    }

    private void InitializeColumnWidth(int numColumn) {
        Resources r = getResources();
        float padding = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                AppConstant.GRID_PADDING, r.getDisplayMetrics());

        // Column width
        columnWidth = (int) ((mAppConst.getScreenWidth() - ((10 + 1) * padding)) /
                numColumn);
    }

    @Override
    public void onUploadResponse(final JSONObject jsonObject, boolean isRequestSuccessful) {
        if (mCurrentSelectedModule.equals("core_main_siteevent")
                && jsonObject.has("body")) {
            JSONObject bodyJsonObj = jsonObject.optJSONObject("body");
            if (!isTicketOrder) {
                JSONArray jsonArray = bodyJsonObj.optJSONArray("gutterMenu");
                for (int i = 0; i < jsonArray.length() - 1; i++) {
                    JSONObject object = jsonArray.optJSONObject(i);
                    if (object.optString("name").equals("package_payment")) {
                        ToastUtils.showToast(CreateNewEntry.this, getResources().
                                getString(R.string.payment_needed_message), ToastUtils.Duration.LONG);
                    }
                }
            } else if (bodyJsonObj.has("order_id") && bodyJsonObj.has("webviewUrl")) {
                loadDefaultActivity(jsonObject);
            }

        }
        if (isRequestSuccessful) {
            isRequestCompleted = true;
            switch (mCurrentSelectedModule) {

                case ConstantVariables.FORUM_MENU_TITLE:
                    if (!mFormType.equals("move_topic")) {
                        ForumUtil.increaseViewTopicPageCounter();
                    }
                    ForumUtil.increaseProfilePageCounter();
                    SnackbarUtils.displaySnackbarShortWithListener(createFormView, mSuccessMessage,
                            new SnackbarUtils.OnSnackbarDismissListener() {
                                @Override
                                public void onSnackbarDismissed() {
                                    finish();
                                }
                            });
                    break;

                case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
                case ConstantVariables.SITE_PAGE_MENU_TITLE:
                case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                case ConstantVariables.MLT_MENU_TITLE:
                case ConstantVariables.MLT_WISHLIST_MENU_TITLE:
                case ConstantVariables.VIDEO_MENU_TITLE:
                case ConstantVariables.STORE_MENU_TITLE:
                case ConstantVariables.PRODUCT_MENU_TITLE:
                case ConstantVariables.DIARY_MENU_TITLE:
                case ConstantVariables.ADV_VIDEO_MENU_TITLE:
                    if (mFormType != null && !mFormType.isEmpty() && mSuccessMessage != null && !mFormType.equals(ConstantVariables.ADD_PRODUCT)) {

                        if (mCurrentSelectedModule.equals("core_main_siteevent") && mFormType != null
                                && mFormType.equals("payment_method") && isTicketOrder) {
                            mSuccessMessage = "Your Ticket has been booked";

                        }
                        SnackbarUtils.displaySnackbarShortWithListener(createFormView,
                                mSuccessMessage, new SnackbarUtils.OnSnackbarDismissListener() {
                                    @Override
                                    public void onSnackbarDismissed() {

                                        if (mCurrentSelectedModule.equals(ConstantVariables.PRODUCT_MENU_TITLE)
                                                && mFormType.equals("add_wishlist")) {
                                            Intent wishListIntent = new Intent();
                                            if (jsonObject.optJSONObject("body") != null) {
                                                wishListIntent.putExtra("wishlist",
                                                        jsonObject.optJSONObject("body").optInt("wishlistPresent"));
                                            }
                                            setResult(RESULT_OK, wishListIntent);
                                            finish();
                                        } else {
                                            setResult(mRequestCode);
                                            finish();
                                        }
                                    }
                                });


                    } else if (mIsAAFVideoUpload
                            && (mCurrentSelectedModule.equals(ConstantVariables.VIDEO_MENU_TITLE)
                            || mCurrentSelectedModule.equals(ConstantVariables.ADV_VIDEO_MENU_TITLE))) {
                        JSONObject body = jsonObject.optJSONObject("body");
                        JSONObject dataResponse = body.optJSONObject("response");

                        if (dataResponse == null) {
                            JSONArray mDataResponseArray = body.optJSONArray("response");
                            dataResponse = mAppConst.convertToJsonObject(mDataResponseArray);
                        }
                        if (dataResponse.optInt("type") == 3) {
                            mSuccessMessage = getResources().getString(R.string.my_device_video_upload_success);
                        } else {
                            mSuccessMessage = getResources().getString(R.string.add_video_success_message);
                        }
                        SnackbarUtils.displaySnackbarShortWithListener(createFormView, mSuccessMessage,
                                new SnackbarUtils.OnSnackbarDismissListener() {
                                    @Override
                                    public void onSnackbarDismissed() {
                                        Intent intent = new Intent();
                                        setResult(ConstantVariables.CREATE_REQUEST_CODE, intent);
                                        finish();
                                    }
                                });
                    } else {
                        loadDefaultActivity(jsonObject);
                    }
                    break;

                case "home":
                case "message":
                    if (attachVideoMessage != null) {
                        attachVideo(jsonObject);
                    } else {
                        loadDefaultActivity(jsonObject);
                    }
                    break;

                case "add_to_friend_list":
                    SnackbarUtils.displaySnackbarShortWithListener(createFormView,
                            getResources().getString(R.string.friend_added_list_success_message),
                            new SnackbarUtils.OnSnackbarDismissListener() {
                                @Override
                                public void onSnackbarDismissed() {
                                    finish();
                                }
                            });
                    break;

                case ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE:
                    SnackbarUtils.displaySnackbarShortWithListener(createFormView,
                            getResources().getString(R.string.new_channel_create_success),
                            new SnackbarUtils.OnSnackbarDismissListener() {
                                @Override
                                public void onSnackbarDismissed() {
                                    int channelId = 0;
                                    JSONObject body = jsonObject.optJSONObject("body");
                                    if (body != null) {
                                        JSONObject dataResponse = body.optJSONObject("response");
                                        if (dataResponse == null) {
                                            JSONArray dataResponseArray = body.optJSONArray("response");
                                            dataResponse = mAppConst.convertToJsonObject(dataResponseArray);
                                        }
                                        channelId = dataResponse.optInt("channel_id");
                                    }
                                    if (mIsAddVideoToNewChannel) {
                                        intent = new Intent();
                                        intent.putExtra("channel_id", channelId);
                                        setResult(ConstantVariables.CREATE_REQUEST_CODE, intent);
                                        finish();
                                    } else {
                                        intent = new Intent(mContext, CreateNewEntry.class);
                                        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                        intent.putExtra("channel_id", channelId);
                                        intent.putExtra(ConstantVariables.CREATE_URL, AppConstant.DEFAULT_URL + "advancedvideos/create");
                                        intent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.ADV_VIDEO_MENU_TITLE);
                                        startActivity(intent);
                                        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                                    }

                                }
                            });
                    break;

                case ConstantVariables.ADV_VIDEO_PLAYLIST_MENU_TITLE:
                    SnackbarUtils.displaySnackbarShortWithListener(createFormView,
                            getResources().getString(R.string.new_playlist_create_success),
                            new SnackbarUtils.OnSnackbarDismissListener() {
                                @Override
                                public void onSnackbarDismissed() {
                                    Intent intent = new Intent();
                                    setResult(ConstantVariables.CREATE_REQUEST_CODE, intent);
                                    finish();
                                }
                            });
                    break;

                default:
                    loadDefaultActivity(jsonObject);
                    break;
            }

        } else if (jsonObject.has("showValidation")) {

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    JSONObject validationMessages = jsonObject.optJSONObject("message");
                    if (validationMessages != null) {
                        showValidations(validationMessages);
                    } else {
                        SnackbarUtils.displaySnackbar(createFormView, jsonObject.optString("message"));
                    }
                }
            });

        } else {
            isRequestCompleted = true;
            SnackbarUtils.displaySnackbarLongWithListener(createFormView, jsonObject.optString("message"),
                    new SnackbarUtils.OnSnackbarDismissListener() {
                        @Override
                        public void onSnackbarDismissed() {
                            finish();
                        }
                    });
        }
    }

    /**
     * Method to send attached video info.
     *
     * @param jsonObject JsonObject which contains the video info.
     */
    public void attachVideo(JSONObject jsonObject) {
        JSONObject body = jsonObject.optJSONObject("body");
        JSONObject mDataResponse = body.optJSONObject("response");
        if (mDataResponse == null) {
            JSONArray mDataResponseArray = body.optJSONArray("response");
            mDataResponse = mAppConst.convertToJsonObject(mDataResponseArray);
        }
        int videoId = mDataResponse.optInt("video_id");
        String videoTitle = mDataResponse.optString("title");
        String description = mDataResponse.optString("description");
        String image = mDataResponse.optString("image");
        Intent intent = new Intent();
        intent.putExtra(ConstantVariables.CONTENT_ID, videoId);
        intent.putExtra(ConstantVariables.CONTENT_TITLE, videoTitle);
        intent.putExtra(ConstantVariables.DESCRIPTION, description);
        intent.putExtra(ConstantVariables.IMAGE, image);
        if (postParams.containsKey("url")) {
            intent.putExtra(ConstantVariables.VIDEO_URL, postParams.get("url"));
        }
        setResult(ConstantVariables.REQUEST_VIDEO, intent);
        finish();
    }

    /**
     * Method to load respective view page activity when a content is created.
     *
     * @param jsonObject JsonObject which contains the view page response.
     */
    public void loadDefaultActivity(JSONObject jsonObject) {
        int content_id;
        viewIntent = null;
        JSONObject body = jsonObject.optJSONObject("body");
        JSONObject mDataResponse = (body != null) ? body.optJSONObject("response") : null;

        if (mDataResponse == null && body != null) {
            JSONArray mDataResponseArray = body.optJSONArray("response");
            mDataResponse = mAppConst.convertToJsonObject(mDataResponseArray);
        }
        CreateNewEntry.mCreatedItemId = (mDataResponse != null) ? mDataResponse.optString(ConstantVariables.KEY_CONTENT_ID_NAME, "0") : "0";
        if ((mCurrentSelectedModule.equals(ConstantVariables.ADVANCED_EVENT_MENU_TITLE)
                || mCurrentSelectedModule.equals(ConstantVariables.DIARY_MENU_TITLE))
                && mFormType != null && !mFormType.isEmpty()) {

            switch (mFormType) {

                case "create_new_diary":
                    content_id = GlobalFunctions.getIdOfModule(mDataResponse, "adv_event_diary");
                    viewIntent = GlobalFunctions.getIntentForModule(mContext, content_id, "adv_event_diary", null);
                    viewIntent.putExtra(ConstantVariables.EXTRA_CREATE_RESPONSE, jsonObject.toString());
                    finish();
                    startActivityForResult(viewIntent, ConstantVariables.VIEW_PAGE_CODE);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                    break;

                case "payment_method":
                    String order_id = body.optString("order_id");
                    String method = body.optString("method");

                    if (method.equals("online")) {
                        String webViewUrl = body.optString("webviewUrl");
                        Intent webViewIntent = new Intent(mContext, WebViewActivity.class);
                        webViewIntent.putExtra("isTicketsPayment", true);
                        webViewIntent.putExtra("url", webViewUrl);
                        startActivityForResult(webViewIntent, ConstantVariables.WEB_VIEW_ACTIVITY_CODE);

                    } else if (method.equals("cheque")) {
                        SnackbarUtils.displaySnackbarLongWithListener(createFormView, getResources().getString(R.string.payment_success_order_message) + order_id,
                                new SnackbarUtils.OnSnackbarDismissListener() {
                                    @Override
                                    public void onSnackbarDismissed() {
                                        setResult(ConstantVariables.CREATE_REQUEST_CODE);
                                        finish();
                                    }
                                });

                    }
                    break;
            }

        } else if (mCurrentSelectedModule.equals(ConstantVariables.MLT_MENU_TITLE)) {

            content_id = GlobalFunctions.getIdOfModule(body, mCurrentSelectedModule);
            viewIntent = GlobalFunctions.getIntentForModule(mContext, content_id, mCurrentSelectedModule, null);
            viewIntent.putExtra(ConstantVariables.LISTING_TYPE_ID, mListingTypeId);
            viewIntent.putExtra(ConstantVariables.EXTRA_CREATE_RESPONSE, jsonObject.toString());
            startActivityForResult(viewIntent, ConstantVariables.VIEW_PAGE_CODE);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

        } else if (mCurrentSelectedModule.equals(ConstantVariables.STORE_MENU_TITLE)) {

            viewIntent = new Intent(mContext, QuickOptionsActivity.class);
            viewIntent.putExtra(ConstantVariables.EXTRA_CREATE_RESPONSE, jsonObject.toString());
            startActivityForResult(viewIntent, ConstantVariables.VIEW_PAGE_CODE);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

        } else if (mCurrentSelectedModule.equals(ConstantVariables.PRODUCT_MENU_TITLE)) {
            finish();
            viewIntent = new Intent(mContext, ProductViewPage.class);
            viewIntent.putExtra("store_id", mDataResponse.optInt("store_id", 0));
            viewIntent.putExtra("product_id", mDataResponse.optInt("product_id", 0));
            startActivity(viewIntent);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

        } else {
            if (mCurrentSelectedModule.equals(ConstantVariables.ALBUM_MENU_TITLE)) {
                content_id = GlobalFunctions.getIdOfModule(body.optJSONObject("album"), mCurrentSelectedModule);
            } else {
                content_id = GlobalFunctions.getIdOfModule(mDataResponse, mCurrentSelectedModule);
            }
            if (mFormType != null && !mFormType.equals("reward")) {
                viewIntent = GlobalFunctions.getIntentForModule(mContext, content_id, mCurrentSelectedModule, null);
            }

            if (mCurrentSelectedModule.equals(ConstantVariables.VIDEO_MENU_TITLE)
                    || mCurrentSelectedModule.equals(ConstantVariables.MLT_VIDEO_MENU_TITLE)
                    || mCurrentSelectedModule.equals(ConstantVariables.ADV_VIDEO_MENU_TITLE)
                    || mCurrentSelectedModule.equals(ConstantVariables.ADV_EVENT_ADD_VIDEO)
                    || mCurrentSelectedModule.equals(ConstantVariables.ADV_GROUPS_ADD_VIDEO)
                    || mCurrentSelectedModule.equals(ConstantVariables.SITE_PAGE_ADD_VIDEO)
                    || mCurrentSelectedModule.equals(ConstantVariables.SITE_STORE_ADD_VIDEO)) {
                viewIntent = GlobalFunctions.getIntentForModule(mContext, content_id, mCurrentSelectedModule, null);
                viewIntent.putExtra(ConstantVariables.VIEW_ID, content_id);
                viewIntent.putExtra(ConstantVariables.VIDEO_TYPE, mDataResponse.optInt("type"));
                viewIntent.putExtra(ConstantVariables.VIDEO_URL, mDataResponse.optString("video_url"));
                if (mCurrentSelectedModule.equals(ConstantVariables.MLT_VIDEO_MENU_TITLE)) {
                    viewIntent.putExtra(ConstantVariables.LISTING_TYPE_ID, mListingTypeId);
                    viewIntent.putExtra(ConstantVariables.LISTING_ID, mDataResponse.optInt("listing_id"));
                    viewIntent.putExtra("isMLTVideo", true);
                }
            }
            if (mCurrentSelectedModule.equals(ConstantVariables.MLT_WISHLIST_MENU_TITLE)) {
                viewIntent.putExtra(ConstantVariables.CONTENT_TITLE, mDataResponse.optString("title"));
            }

            if (viewIntent == null) {
                Object intentObject = GlobalFunctions.invokeMethod(mBundle.getString(ConstantVariables.KEY_PACKAGE_NAME), mBundle.getString(ConstantVariables.KEY_METHOD_NAME), mBundle);
                if (intentObject instanceof Intent) {
                    viewIntent = (Intent) intentObject;
                }
            }
            if (viewIntent != null) {
                viewIntent.putExtra(ConstantVariables.EXTRA_CREATE_RESPONSE, jsonObject.toString());
                startActivityForResult(viewIntent, ConstantVariables.VIEW_PAGE_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            } else {
                SnackbarUtils.displaySnackbarLongWithListener(createFormView, mSuccessMessage,
                        new SnackbarUtils.OnSnackbarDismissListener() {
                            @Override
                            public void onSnackbarDismissed() {
                                setResult(ConstantVariables.CREATE_REQUEST_CODE);
                                finish();
                            }
                        });
            }
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (event.getAction() == KeyEvent.ACTION_DOWN && keyCode == KeyEvent.KEYCODE_BACK) {
            onBackPressed();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * Method to show date time dialog
     *
     * @param context    Context of calling class.
     * @param tvDateTime TextView in which date/time is to be shown.
     * @param type       Type of dialog (date+time or only date picker)
     * @param minDate    Minimum date need to be set when the picker is opened.
     */
    public void showDateTimeDialogue(final Context context, TextView tvDateTime, final String type,
                                     long minDate) {

        mContext = context;

        Calendar newCalendar = Calendar.getInstance();
        DatePicker datePicker = new DatePicker(mContext);

        if (android.os.Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            datePicker.setCalendarViewShown(false);
        }

        // Showing the recently selected value in date picker if the user recently selected.
        if (yearString != null && !yearString.isEmpty() && monthString != null && !monthString.isEmpty()) {
            datePicker.init(Integer.parseInt(yearString), Integer.parseInt(monthString) - 1, Integer.parseInt(dateString), null);
        } else {
            datePicker.init(newCalendar.get(Calendar.YEAR), newCalendar.get(Calendar.MONTH), newCalendar.get(Calendar.DAY_OF_MONTH), null);
        }
        showDateTimePicker(context, type, tvDateTime, datePicker, null);
        if (minDate != 0L) {
            datePicker.setMinDate(minDate);
        }
    }


    /**
     * Method to show date or time picker according to response.
     *
     * @param context    context of calling class.
     * @param type       format type (whether it is date+time or only date).
     * @param tvDateTime TextView in which date/time is to be shown.
     * @param datePicker DatePicker.
     * @param timePicker TimePicker.
     */
    public void showDateTimePicker(Context context, final String type, final TextView tvDateTime,
                                   final DatePicker datePicker, final TimePicker timePicker) {

        mContext = context;
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);

        if (datePicker != null) {
            builder.setTitle(mContext.getResources().getString(R.string.date_dialogue_title));
            builder.setView(datePicker);
        } else if (timePicker != null) {
            builder.setTitle(mContext.getResources().getString(R.string.time_dialogue_title));
            builder.setView(timePicker);
        }

        builder.setPositiveButton(mContext.getResources().getString(R.string.date_time_dialogue_ok_button),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {

                        // Adding the date picker value in the text field.
                        if (datePicker != null) {
                            yearString = String.valueOf(datePicker.getYear());
                            int month = datePicker.getMonth() + 1;
                            int date = datePicker.getDayOfMonth();
                            if (month < 10) {
                                monthString = "0" + month;
                            } else {
                                monthString = "" + month;
                            }

                            if (date < 10) {
                                dateString = "0" + date;
                            } else {
                                dateString = "" + date;
                            }

                            strDateTime = yearString + "-" + monthString + "-" + dateString;
                            dateTag = strDateTime;
                        }

                        // Showing the time picker when the format is not of date type.
                        // and showing it only once.
                        if ((type == null || !type.equals("date")) && timePicker == null) {
                            TimePicker tmPicker = new TimePicker(mContext);

                            // Showing the recently selected value in time picker if the user recently selected.
                            if (hourString != null && !hourString.isEmpty() && minuteString != null && !minuteString.isEmpty()) {
                                tmPicker.setCurrentHour(Integer.valueOf(hourString));
                                tmPicker.setCurrentMinute(Integer.valueOf(minuteString));
                            }
                            showDateTimePicker(mContext, null, tvDateTime, null, tmPicker);
                        }

                        // Adding the time picker value in the text field if it selected.
                        if (timePicker != null) {

                            int hour = timePicker.getCurrentHour();
                            int minute = timePicker.getCurrentMinute();

                            if (hour < 10) {
                                hourString = "0" + hour;
                                formatHourString = "0" + hour;
                            } else if (hour > 12) {
                                formatHourString = "" + hour;
                                hour -= 12;
                                hourString = "" + hour;
                            } else {
                                hourString = "" + hour;
                                formatHourString = "" + hour;
                            }

                            if (minute < 10) {
                                minuteString = "0" + minute;
                            } else {
                                minuteString = "" + minute;
                            }

                            strDateTime += " " + hourString + ":" + minuteString + ":00";
                            dateTag += " " + formatHourString + ":" + minuteString;
                        }

                        tvDateTime.setText(strDateTime);
                        if (mOnDateSelectedListener != null) {
                            mOnDateSelectedListener.onDateSelected(strDateTime);
                        }
                    }
                });

        builder.setNegativeButton(mContext.getResources().getString(R.string.date_time_dialogue_cancel_button),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        strDateTime = null;
                        dialog.cancel();
                    }
                });
        builder.create().show();
    }

    // Create Interface and listener for set date on add destination form

    public interface OnDateSelectedListener {
        void onDateSelected(String date);
    }

    OnDateSelectedListener mOnDateSelectedListener;

    public void setOnDateSelectedListener(OnDateSelectedListener onDateSelectedListener) {
        mOnDateSelectedListener = onDateSelectedListener;
    }

    public static CreateNewEntry getInstance() {
        return createNewEntry;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {

        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        switch (requestCode) {
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, proceed to the normal flow.
                    switch (mUploadingOption) {
                        case "photo":
                            startMultiImageSelectorActivity();
                            break;
                        case "video":
                            startVideoUploading();
                            break;
                        case "music":
                            GlobalFunctions.addMusicBlock(mFormActivityContext);
                            break;
                    }
                } else {
                    // If user deny the permission popup
                    if (ActivityCompat.shouldShowRequestPermissionRationale((Activity) mContext,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE)) {

                        // Show an explanation to the user, After the user
                        // sees the explanation, try again to request the permission.
                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);
                    } else {
                        // If user pressed never ask again on permission popup
                        // show snackbar with open app info button
                        // user can revoke the permission from Permission section of App Info.
                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, createFormView,
                                ConstantVariables.WRITE_EXTERNAL_STORAGE);

                    }
                }
                break;
        }
    }

    /**
     * Class to load the video thumb in background thread
     * so that it will load the images in background and don't make the main thread slow.
     */
    public class LoadVideoThumbAsync extends AsyncTask<Void, String, Void> {
        private String videoPath;

        public LoadVideoThumbAsync(String videoPath) {
            this.videoPath = videoPath;
        }


        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }

        @Override
        protected Void doInBackground(Void... params) {
            try {
                Bitmap bitmap = ThumbnailUtils.createVideoThumbnail(videoPath,
                        MediaStore.Images.Thumbnails.MINI_KIND);
                if (bitmap != null) {
                    File outputDir = mContext.getCacheDir();
                    Random generator = new Random();
                    int n = 10000;
                    n = generator.nextInt(n);
                    String fileName = "Image-" + n;
                    File outputFile = File.createTempFile(fileName, ".png", outputDir);
                    FileOutputStream out = new FileOutputStream(outputFile);
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
                    out.flush();
                    out.close();
                    mSelectedVideoThumbnail = outputFile.getAbsolutePath();
                } else {
                    mSelectedVideoThumbnail = null;
                }
            } catch (Exception e) {
                e.printStackTrace();
                mSelectedVideoThumbnail = null;
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void param) {

            String fileDescription = GlobalFunctions.getFileNameFromPath(mSelectedVideoPath);
            RelativeLayout videoView = mSelectFileInflatedView.findViewById(R.id.video_view);
            videoView.setVisibility(View.VISIBLE);
            TextView title = videoView.findViewById(R.id.title);
            title.setText(fileDescription);
            ImageView imageView = videoView.findViewById(R.id.video_thumbnail);
            TextView remove = videoView.findViewById(R.id.remove);
            ImageLoader imageLoader = new ImageLoader(mContext);
            if (mSelectedVideoThumbnail != null) {
                imageLoader.setAlbumPhoto(mSelectedVideoThumbnail, imageView);
            }

            remove.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mSelectedVideoThumbnail = null;
                    mSelectedVideoPath = null;
                    videoView.setVisibility(View.GONE);
                }
            });
        }
    }

}
