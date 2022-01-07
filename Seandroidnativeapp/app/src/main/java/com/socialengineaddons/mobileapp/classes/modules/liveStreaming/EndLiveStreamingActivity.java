/*
 *   Copyright (c) 2018 BigStep Technologies Private Limited.
 *
 *   You may not use this file except in compliance with the
 *   SocialEngineAddOns License Agreement.
 *   You may obtain a copy of the License at:
 *   https://www.socialengineaddons.com/android-app-license
 *   The full copyright and license information is also mentioned
 *   in the LICENSE file that was distributed with this
 *   source code.
 */

package com.socialengineaddons.mobileapp.classes.modules.liveStreaming;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.PopupMenu;
import android.support.v7.widget.SwitchCompat;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.DrawableClickListener;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.listener.OnAppCloseListener;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.Status.NETWORK_LIST_ARRAY;
import static com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.Status.USER_LIST_ARRAY;


public class EndLiveStreamingActivity extends AppCompatActivity implements View.OnClickListener,
        CompoundButton.OnCheckedChangeListener, OnAppCloseListener {

    // Member variables.
    private Context mContext;
    private TextView tvViewersCount, tvShare;
    private LinearLayout llStory, llPost;
    private SwitchCompat scStory, scPost;
    private TextView tvStoryTitle, tvPostTitle, tvStoryDesc, tvPostDesc;
    private ProgressDialog progressDialog;

    // Custom classes.
    private AppConstant mAppConst;
    private LiveStreamUtils liveStreamUtils;

    // Class variables.
    private int viewersCount;
    private String mStoryPrivacy = "everyone", mPostPrivacy = "everyone", channelName, sid;
    private Map<String, String> postParams;
    private Map<String, String> mMultiSelectUserPrivacy;
    private ArrayList<String> popupMenuList = new ArrayList<>();
    private JSONObject mFeedPostMenus, mUserPrivacyObject, userDetails, mStoryPrivacyObject;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_end_live_streaming);

        // Initialize member variables.
        mContext = EndLiveStreamingActivity.this;
        postParams = new HashMap<>();
        mMultiSelectUserPrivacy = new HashMap<>();
        mAppConst = new AppConstant(mContext);
        liveStreamUtils = LiveStreamUtils.getInstance();
        liveStreamUtils.setContext(mContext);
        liveStreamUtils.setOnAppCloseListener(this);
        channelName = getIntent().getStringExtra(ConstantVariables.CHANNEL_NAME);
        sid = getIntent().getStringExtra(ConstantVariables.SID);
        if (getIntent().hasExtra(ConstantVariables.POST_PARAMS)) {
            postParams = (HashMap<String, String>) getIntent().getSerializableExtra(ConstantVariables.POST_PARAMS);
        }
        postParams.put("sid", sid);
        postParams.put("stream_name", channelName);

        try {
            userDetails = new JSONObject(PreferencesUtils.getUserDetail(mContext));
        } catch (JSONException e) {
            e.printStackTrace();
        }

        initializeViews();

        //Getting pref values.
        mPostPrivacy = PreferencesUtils.getStatusPrivacyKey(mContext);
        mStoryPrivacy = PreferencesUtils.getStoryPrivacyKey(mContext);

        if (PreferencesUtils.getStatusPostPrivacyOptions(mContext) != null
                && PreferencesUtils.getStoryPrivacy(mContext) != null) {
            setPrivacy();
        } else {
            getStoryAndPostPrivacy();
        }

    }

    /**
     * Method to initialize the views.
     */
    private void initializeViews() {
        tvShare = findViewById(R.id.share);
        tvViewersCount = findViewById(R.id.viewersCount);
        tvStoryTitle = findViewById(R.id.story_title);
        tvPostTitle = findViewById(R.id.post_title);
        tvStoryDesc = findViewById(R.id.story_desc);
        tvPostDesc = findViewById(R.id.post_desc);
        llStory = findViewById(R.id.story_layout);
        llPost = findViewById(R.id.post_layout);
        scStory = findViewById(R.id.select_story);
        scPost = findViewById(R.id.select_post);
        tvShare.setOnClickListener(this);
        scStory.setOnCheckedChangeListener(this);
        scPost.setOnCheckedChangeListener(this);

        GradientDrawable drawable = (GradientDrawable) tvShare.getBackground();
        drawable.mutate();
        drawable.setColor(ContextCompat.getColor(mContext, R.color.white));
        drawable.setStroke(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_0_2_dp),
                ContextCompat.getColor(mContext, R.color.gray_light));

        if (ConstantVariables.ENABLE_STORY == 1 && PreferencesUtils.getIsStoryEnabled(mContext)) {
            llStory.setVisibility(View.VISIBLE);
            scStory.setVisibility(View.VISIBLE);
        } else {
            llStory.setVisibility(View.GONE);
            scStory.setVisibility(View.GONE);
            scStory.setChecked(false);
        }

        progressDialog = new ProgressDialog(mContext);
        progressDialog.setMessage(mContext.getResources().getString(R.string.progress_dialog_wait) + "...");
        progressDialog.setCancelable(false);
        progressDialog.setCanceledOnTouchOutside(false);
    }

    /**
     * Method to set privacy.
     */
    private void setPrivacy() {
        try {
            mFeedPostMenus = new JSONObject(PreferencesUtils.getStatusPostPrivacyOptions(mContext));
            mStoryPrivacyObject = new JSONObject(PreferencesUtils.getStoryPrivacy(mContext));
            mUserPrivacyObject = mFeedPostMenus.optJSONObject("userprivacy");
            USER_LIST_ARRAY = mFeedPostMenus.optJSONArray("userlist");
            NETWORK_LIST_ARRAY = mFeedPostMenus.optJSONArray("multiple_networklist");


            // When the user selected custom network or friend list then putting the all options into map.
            if ((mPostPrivacy.equals("network_list_custom")
                    || mPostPrivacy.equals("friend_list_custom"))
                    && PreferencesUtils.getStatusPrivacyMultiOptions(mContext) != null) {
                List<String> multiOptionList = Arrays.asList(PreferencesUtils.
                        getStatusPrivacyMultiOptions(mContext).split("\\s*,\\s*"));
                if (!multiOptionList.isEmpty()) {
                    for (int i = 0; i < multiOptionList.size(); i++) {
                        mMultiSelectUserPrivacy.put(multiOptionList.get(i), "1");
                    }
                }
            }

            setPrivacyOption(false);
            setStoryPrivacyOption(false);

            // once all data setup showing data in views.
            setDataInView();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Method to set default privacy option when status page opened up.
     */
    private void setPrivacyOption(boolean isOptionChanged) {
        switch (mPostPrivacy) {
            case "network_list_custom":
            case "friend_list_custom":
                if (isOptionChanged) {
                    getPrivacyForm(mPostPrivacy.equals("friend_list_custom"), mPostPrivacy);
                    mPostPrivacy = !PreferencesUtils.getStatusPrivacyKey(mContext).equals("network_list_custom")
                            && !PreferencesUtils.getStatusPrivacyKey(mContext).equals("friend_list_custom")
                            ? PreferencesUtils.getStatusPrivacyKey(mContext) : null;
                } else {
                    setDescription(mUserPrivacyObject.optString(mPostPrivacy), false);
                    PreferencesUtils.setStatusPrivacyKey(mContext, mPostPrivacy);
                    mPostPrivacy = null;
                }
                break;

            default:
                setDescription(mUserPrivacyObject.optString(mPostPrivacy), false);
                break;
        }

        if (mPostPrivacy != null && !mPostPrivacy.equals("network_list_custom")
                && !mPostPrivacy.equals("friend_list_custom")) {
            PreferencesUtils.setStatusPrivacyKey(mContext, mPostPrivacy);
            if (mMultiSelectUserPrivacy != null) {
                mMultiSelectUserPrivacy.clear();
            }
        }
    }

    /**
     * Method to set default privacy key.
     */
    private void setDefaultPrivacyKey() {
        mPostPrivacy = !PreferencesUtils.getStatusPrivacyKey(mContext).equals("network_list_custom")
                && !PreferencesUtils.getStatusPrivacyKey(mContext).equals("friend_list_custom")
                ? PreferencesUtils.getStatusPrivacyKey(mContext) : "everyone";
        setDescription(mUserPrivacyObject.optString(mPostPrivacy), false);
    }

    /**
     * Method to set default story privacy when privacy change
     */
    private void setStoryPrivacyOption(boolean isOptionChanged) {
        if (mStoryPrivacy != null && !mStoryPrivacy.equals(PreferencesUtils.getStoryPrivacyKey(mContext))
                && isOptionChanged) {
            PreferencesUtils.setStoryPrivacyKey(mContext, mStoryPrivacy);
        }
        setDescription(mStoryPrivacyObject.optString(mStoryPrivacy), true);
    }

    /**
     * Method to get privacy options and store them in preferences.
     */
    private void getStoryAndPostPrivacy() {
        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/feeds/feed-post-menus",
                new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) {
                        if (jsonObject != null && jsonObject.optJSONObject("feed_post_menu") != null) {
                            PreferencesUtils.setStatusPrivacyOptions(mContext, jsonObject.optJSONObject("feed_post_menu"));
                        }
                        mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/stories/create",
                                new OnResponseListener() {
                                    @Override
                                    public void onTaskCompleted(JSONObject jsonObject) {
                                        if (jsonObject != null && jsonObject.optJSONArray("response") != null) {
                                            JSONObject privacy = jsonObject.optJSONArray("response").optJSONObject(0).optJSONObject("multiOptions");
                                            PreferencesUtils.setStoryPrivacy(mContext, privacy);
                                        }
                                        setPrivacy();
                                    }

                                    @Override
                                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                                    }
                                });
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                    }
                });
    }

    /**
     * Method to launch Form Creation activity for multiple friend/network list.
     *
     * @param isFriendList True if the form is to be load for friend list.
     * @param key          Key of the selected privacy option.
     */
    private void getPrivacyForm(boolean isFriendList, String key) {
        Intent intent = new Intent(mContext, CreateNewEntry.class);
        intent.putExtra("is_status_privacy", true);
        intent.putExtra("isFriendList", isFriendList);
        intent.putExtra("privacy_key", key);
        intent.putExtra("user_id", userDetails.optInt("user_id"));
        intent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.HOME_MENU_TITLE);
        intent.putExtra(ConstantVariables.CONTENT_TITLE, mUserPrivacyObject.optString(key));
        startActivityForResult(intent, ConstantVariables.USER_PRIVACY_REQUEST_CODE);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    /**
     * Method to set data in respective views.
     */
    private void setDataInView() {

        // Getting drawable for setting
        Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_settings_white_24dp);
        drawable.mutate();
        drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.white),
                PorterDuff.Mode.SRC_ATOP));
        drawable.setBounds(0, 0, mContext.getResources().getDimensionPixelSize(R.dimen.margin_15dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.margin_15dp));
        tvStoryTitle.setCompoundDrawables(null, null, drawable, null);
        tvPostTitle.setCompoundDrawables(null, null, drawable, null);

        tvStoryTitle.setOnTouchListener(new DrawableClickListener.RightDrawableClickListener(tvStoryTitle) {
            @Override
            public boolean onDrawableClick() {
                showPopup(tvStoryTitle, true);
                return true;
            }
        });

        tvPostTitle.setOnTouchListener(new DrawableClickListener.RightDrawableClickListener(tvPostTitle) {
            @Override
            public boolean onDrawableClick() {
                showPopup(tvPostTitle, false);
                return true;
            }
        });
        viewersCount = getIntent().getIntExtra(ConstantVariables.LIVE_STREAM_VIEWERS_COUNT, 0);
        tvViewersCount.setText(mContext.getResources().getQuantityString(R.plurals.viewers_count,
                viewersCount, viewersCount));

        setTitleTypeFace();
    }

    /**
     * Method to set title in bold format when the checkbox is selected.
     */
    private void setTitleTypeFace() {
        invalidateOptionsMenu();
        tvStoryTitle.setTypeface(scStory.isChecked() ? Typeface.DEFAULT_BOLD : null);
        tvPostTitle.setTypeface(scPost.isChecked() ? Typeface.DEFAULT_BOLD : null);
    }

    /**
     * Method to set description on story/post description view according to privacy.
     *
     * @param privacyTitle Privacy title of respected view.
     * @param isStory      True if it is for story.
     */
    private void setDescription(String privacyTitle, boolean isStory) {
        if (isStory) {
            tvStoryDesc.setText(mContext.getResources().getString(R.string.visible_in_story) + " "
                    + mContext.getResources().getString(R.string.to_text) + " " + privacyTitle + " "
                    + mContext.getResources().getQuantityString(R.plurals.for_days,
                    PreferencesUtils.getStoryDuration(mContext), PreferencesUtils.getStoryDuration(mContext)));
        } else {
            tvPostDesc.setText(mContext.getResources().getString(R.string.share_with) + " " + privacyTitle);
        }
    }

    /**
     * Method to show popup when the
     *
     * @param view    View on which popup need to be shown
     * @param isStory True if it is for story.
     */
    public void showPopup(View view, final boolean isStory) {

        PopupMenu popup = new PopupMenu(mContext, view);
        popupMenuList.clear();

        if (!isStory && mUserPrivacyObject != null && mUserPrivacyObject.length() != 0) {
            JSONArray mPrivacyKeys = mUserPrivacyObject.names();

            for (int i = 0; i < mUserPrivacyObject.length(); i++) {
                String key = mPrivacyKeys.optString(i);
                popupMenuList.add(key);
                String privacyLabel = mUserPrivacyObject.optString(key);
                if (mPostPrivacy != null && mPostPrivacy.equals(key)) {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(true).setChecked(true);
                } else if (mPostPrivacy == null && key.equals("everyone")
                        && (mMultiSelectUserPrivacy == null || mMultiSelectUserPrivacy.isEmpty())) {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(true).setChecked(true);
                } else {
                    boolean isSelected = (mMultiSelectUserPrivacy != null && mMultiSelectUserPrivacy.size() > 0)
                            && mMultiSelectUserPrivacy.get(key) != null && mMultiSelectUserPrivacy.get(key).equals("1");
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(isSelected).setChecked(isSelected);
                }
            }
        }

        if (isStory && mStoryPrivacyObject != null && mStoryPrivacyObject.length() != 0) {
            JSONArray mPrivacyKeys = mStoryPrivacyObject.names();

            for (int i = 0; i < mStoryPrivacyObject.length(); i++) {
                String key = mPrivacyKeys.optString(i);
                popupMenuList.add(key);
                String privacyLabel = mStoryPrivacyObject.optString(key);
                if (mStoryPrivacy != null && mStoryPrivacy.equals(key)) {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(true).setChecked(true);
                } else {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel);
                }
            }
        }

        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            public boolean onMenuItemClick(MenuItem item) {
                int id = item.getItemId();

                if (isStory) {
                    mStoryPrivacy = popupMenuList.get(id);
                    setStoryPrivacyOption(true);

                } else {
                    mPostPrivacy = popupMenuList.get(id);

                    // Clearing list when any other popup option(other than multiple friend/network list) is clicked.
                    if (!mPostPrivacy.equals("network_list_custom")
                            && !mPostPrivacy.equals("friend_list_custom")) {
                        mMultiSelectUserPrivacy.clear();
                    }
                    setPrivacyOption(true);
                }
                return true;
            }
        });
        popup.show();
    }

    /**
     * Method to share the live stream video on aaf/story according to selected choice.
     */
    private void shareLiveStreamVideo() {
        progressDialog.show();
        String endType = scStory.isChecked() && scPost.isChecked()
                ? "both" : scPost.isChecked() ? "feed" : "story";
        postParams.put("endType", endType);
        postParams.put("auth_view", mPostPrivacy);
        postParams.put("privacy", mStoryPrivacy);
        postParams.put("view_count", String.valueOf(viewersCount));

        mAppConst.postJsonResponseForUrl(AppConstant.DEFAULT_URL + "livestreamingvideo/" +
                "share-video", postParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                progressDialog.dismiss();
                String successMessage;
                Intent intent = new Intent();
                if (postParams.get("endType").equals("story")) {
                    successMessage = mContext.getResources().getString(R.string.story_video_will_update_soon);
                } else {
                    intent.putExtra(ConstantVariables.IS_LIVE_STREAM_SHARED_ON_FEED, true);
                    successMessage = mContext.getResources().getString(R.string.video_will_update_soon);
                }
                Toast.makeText(mContext, successMessage, Toast.LENGTH_SHORT).show();
                setResult(ConstantVariables.LIVE_VIDEO_REQUEST_CODE, intent);
                finish();
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                progressDialog.dismiss();
                if (message != null && message.equals(ConstantVariables.STREAM_NOT_EXIST)) {
                    Toast.makeText(mContext, mContext.getResources().getString(R.string.video_can_not_shared),
                            Toast.LENGTH_SHORT).show();
                    finish();
                } else {
                    SnackbarUtils.displaySnackbar(tvViewersCount, message);
                }
            }
        });

    }

    @Override
    public void onAppClosed() {
        mAppConst.postJsonRequest(AppConstant.DEFAULT_URL + "livestreamingvideo/" +
                "share-video?stream_name=" + channelName + "&endType=normal" +
                "&sid=" + sid);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.viewPrivacy:
                break;

            case R.id.share:
                if (GlobalFunctions.isNetworkAvailable(mContext)) {
                    if (!scStory.isChecked() && !scPost.isChecked()) {
                        mAppConst.postJsonRequest(AppConstant.DEFAULT_URL + "livestreamingvideo/" +
                                "share-video?stream_name=" + channelName + "&endType=normal" +
                                "&sid=" + sid);
                        Map<String, String> postParam = new HashMap<>();
                        postParam.put("sid", sid);
                        mAppConst.deleteLiveStreamJsonRequest(AppConstant.LIVE_STREAM_DEFAULT_URL + "discard", postParam, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) {
                                LogUtils.LOGD(EndLiveStreamingActivity.class.getSimpleName(), "discard video LiveStreamJsonRequest, jsonObject: " + jsonObject);

                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                LogUtils.LOGD(EndLiveStreamingActivity.class.getSimpleName(), "discard video LiveStreamJsonRequest, onErrorInExecutingTask: " + message);
                            }
                        });

                        finish();
                    } else {
                        shareLiveStreamVideo();
                    }
                } else {
                    Toast.makeText(mContext, mContext.getResources().getString(R.string.network_connectivity_error),
                            Toast.LENGTH_SHORT).show();
                }
                break;
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return keyCode != KeyEvent.KEYCODE_BACK && super.onKeyDown(keyCode, event);
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if (!scStory.isChecked() && !scPost.isChecked()) {
            tvShare.setText(mContext.getResources().getString(R.string.discard));
        } else {
            tvShare.setText(mContext.getResources().getString(R.string.share));
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        Bundle bundle = null;
        if (data != null) {
            bundle = data.getExtras();
        }

        if (bundle != null && requestCode == ConstantVariables.USER_PRIVACY_REQUEST_CODE
                && bundle.getSerializable("param") != null) {
            mMultiSelectUserPrivacy = (HashMap<String, String>) bundle.getSerializable("param");

            if (bundle.getString("feed_post_menu") != null
                    && bundle.getString("feed_post_menu").length() > 0
                    && bundle.getString("privacy_key").equals("friend_list_custom")) {
                try {
                    mFeedPostMenus = new JSONObject(bundle.getString("feed_post_menu"));
                    mUserPrivacyObject = mFeedPostMenus.optJSONObject("userprivacy");
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            if (mMultiSelectUserPrivacy != null && mMultiSelectUserPrivacy.size() > 0) {
                boolean isAnyOptionSelected = false;
                for (Map.Entry<String, String> entry : mMultiSelectUserPrivacy.entrySet()) {
                    if (entry.getValue().equals("1")) {
                        isAnyOptionSelected = true;
                        break;
                    }
                }

                // When there is any option is selected then showing the name of multi select list.
                if (isAnyOptionSelected) {
                    mPostPrivacy = null;
                    setDescription(mUserPrivacyObject.optString(bundle.getString("privacy_key")), false);
                    String multiOptions = null;
                    for (Map.Entry<String, String> entry : mMultiSelectUserPrivacy.entrySet()) {
                        if (entry.getValue().equals("1")) {
                            if (multiOptions != null) {
                                multiOptions += entry.getKey() + ",";
                            } else {
                                multiOptions = entry.getKey() + ",";
                            }
                        }
                    }
                    if (multiOptions != null) {
                        multiOptions = multiOptions.substring(0, multiOptions.lastIndexOf(","));
                        PreferencesUtils.setStatusPrivacyKey(mContext, bundle.getString("privacy_key"));
                        PreferencesUtils.setStatusPrivacyMultiOptions(mContext, multiOptions);
                    }
                } else {
                    mPostPrivacy = !PreferencesUtils.getStatusPrivacyKey(mContext).equals("network_list_custom")
                            && !PreferencesUtils.getStatusPrivacyKey(mContext).equals("friend_list_custom")
                            ? PreferencesUtils.getStatusPrivacyKey(mContext) : "everyone";
                    mMultiSelectUserPrivacy.clear();
                    PreferencesUtils.setStatusPrivacyKey(mContext, mPostPrivacy);
                    setDescription(mUserPrivacyObject.optString(mPostPrivacy), false);
                }
            } else {
                setDefaultPrivacyKey();
            }
        } else {
            mMultiSelectUserPrivacy.clear();
            setDefaultPrivacyKey();
        }
    }
}
