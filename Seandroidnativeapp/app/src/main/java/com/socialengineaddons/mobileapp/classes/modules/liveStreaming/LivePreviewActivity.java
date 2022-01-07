package com.socialengineaddons.mobileapp.classes.modules.liveStreaming;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.PopupMenu;
import android.support.v7.widget.RecyclerView;
import android.text.method.LinkMovementMethod;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.SurfaceView;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.dialogs.CheckInLocationDialog;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCheckInLocationResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnLocationAndTagClickListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.DrawableClickListener;
import com.socialengineaddons.mobileapp.classes.common.utils.EmojiUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.AddPeople;
import com.socialengineaddons.mobileapp.classes.modules.store.adapters.SimpleSheetAdapter;
import com.socialengineaddons.mobileapp.classes.modules.store.utils.SheetItemModel;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import github.ankushsachdeva.emojicon.EmojiconEditText;
import io.agora.rtc.Constants;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.video.VideoCanvas;


import static com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.Status.NETWORK_LIST_ARRAY;
import static com.socialengineaddons.mobileapp.classes.modules.advancedActivityFeeds.Status.USER_LIST_ARRAY;


public class LivePreviewActivity extends LiveBaseActivity implements View.OnClickListener,
        OnCheckInLocationResponseListener, OnLocationAndTagClickListener {

    // Member variables.
    private Context mContext;
    private View cameraFlip, moreOptions;
    private FrameLayout flVideoView;
    private TextView tvViewPrivacy, tvGoLive, tvEndLive, tvLocationAndTaggedFriends;
    private EmojiconEditText etDescription;
    private ProgressDialog progressDialog;

    // Custom classes and remote view.
    private LiveStreamUtils liveStreamUtils;
    public BottomSheetDialog bottomSheetDialog;
    public SimpleSheetAdapter mSheetAdapter;
    private AppConstant mAppConst;
    private CheckInLocationDialog checkInLocationDialog;

    // Class variables.
    private int subjectId;
    private String mPostPrivacy = "friends", subjectType, locationLabel;
    private Bundle mSelectedLocationBundle;
    private List<String> selectedFriendList;
    private Map<String, String> postParams, mMultiSelectUserPrivacy, selectedFriends, selectedLocation;
    private ArrayList<String> popupMenuList = new ArrayList<>();
    private JSONObject userDetails, mFeedPostMenus, mUserPrivacyObject, mSelectedLocationObject;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_preview);

        // Initialize member variables.
        mContext = LivePreviewActivity.this;
        postParams = new HashMap<>();
        mMultiSelectUserPrivacy = new HashMap<>();
        selectedFriends = new HashMap<>();
        selectedLocation = new HashMap<>();
        selectedFriendList = new ArrayList<>();
        liveStreamUtils = LiveStreamUtils.getInstance();
        liveStreamUtils.setContext(mContext);
        mAppConst = new AppConstant(mContext);

        try {
            userDetails = new JSONObject(PreferencesUtils.getUserDetail(mContext));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        subjectId = getIntent().getIntExtra(ConstantVariables.SUBJECT_ID, 0);
        subjectType = getIntent().getStringExtra(ConstantVariables.SUBJECT_TYPE);
    }

    @Override
    protected void initUIEvent() {
        initializeViews();
        checkPrivacyOptions();
        setUpBottomSheet();

        /* To create a Emoji popup with all emoticons of keyboard height */
        EmojiUtil.createEmojiPopup(this, findViewById(R.id.rootView), etDescription);
    }


    @Override
    protected void performAfterPermission() {

        worker().configEngine(Constants.CLIENT_ROLE_BROADCASTER, Constants.VIDEO_PROFILE_480P);

        SurfaceView surfaceV = RtcEngine.CreateRendererView(getApplicationContext());
        rtcEngine().setupLocalVideo(new VideoCanvas(surfaceV, VideoCanvas.RENDER_MODE_HIDDEN, 0));
        surfaceV.setZOrderOnTop(true);
        surfaceV.setZOrderMediaOverlay(true);
        flVideoView.removeAllViews();
        flVideoView.addView(surfaceV);
        worker().preview(true, surfaceV, 0);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (checkInLocationDialog != null && checkInLocationDialog.isShowing()) {
            checkInLocationDialog.onActivityResult(requestCode, resultCode, data);
            return;
        }

        Bundle bundle = null;
        if (data != null) {
            bundle = data.getExtras();
        }
        if (resultCode == ConstantVariables.ADD_PEOPLE_CODE) {
            Set<String> searchArgumentSet = bundle.keySet();
            selectedFriends.clear();
            selectedFriendList.clear();
            if (searchArgumentSet != null && searchArgumentSet.size() != 0) {
                for (String key : searchArgumentSet) {
                    String value = bundle.getString(key);
                    selectedFriends.put(key, value);
                    selectedFriendList.add(value);
                }
                showLocationAndTaggedFriends();
            }
            showLocationAndTaggedFriends();

        } else if (bundle != null && requestCode == ConstantVariables.USER_PRIVACY_REQUEST_CODE
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
                    setDescription(mUserPrivacyObject.optString(bundle.getString("privacy_key")));
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
                    setDescription(mUserPrivacyObject.optString(mPostPrivacy));
                }
            } else {
                setDefaultPrivacyKey();
            }
        } else if (requestCode == ConstantVariables.LIVE_VIDEO_REQUEST_CODE) {
            terminateLiveStreaming(bundle != null && bundle.getBoolean(ConstantVariables.IS_LIVE_STREAM_SHARED_ON_FEED));
        } else {
            mMultiSelectUserPrivacy.clear();
            setDefaultPrivacyKey();
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.cameraFlip:
                if (liveStreamUtils.rtcEngine() != null) {
                    liveStreamUtils.rtcEngine().switchCamera();
                }
                break;

            case R.id.end:
                terminateLiveStreaming(false);
                break;

            case R.id.moreOptions:
                // If friends list item is clicked.
                bottomSheetDialog.show();
                mSheetAdapter.setOnItemClickListener(new SimpleSheetAdapter.OnItemClickListener() {
                    @Override
                    public void onItemClick(SheetItemModel sheetItemModel, int position) {
                        bottomSheetDialog.hide();
                        if (position == 0) {
                            addFriends();
                        } else {
                            if (!mAppConst.checkManifestPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
                                mAppConst.requestForManifestPermission(Manifest.permission.ACCESS_FINE_LOCATION,
                                        ConstantVariables.ACCESS_FINE_LOCATION);
                            } else {
                                addLocation();
                            }
                        }
                    }
                });
                break;

            case R.id.goLive:
                postParams.clear();

                // Add Tagged Friends in post params
                if (selectedFriends != null && selectedFriends.size() != 0) {
                    String mToValues = "";
                    int j = 0;
                    Set<String> mKeySet = selectedFriends.keySet();
                    for (String key : mKeySet) {
                        j++;
                        if (j < selectedFriends.size()) {
                            mToValues += key + ",";
                        } else {
                            mToValues += key;
                        }
                    }
                    postParams.put("toValues", mToValues);
                }

                // Adding location params
                postParams.put("locationLibrary", "client");

                // Adding post privacy option.
                if (mMultiSelectUserPrivacy != null && !mMultiSelectUserPrivacy.isEmpty()) {
                    for (Map.Entry<String, String> entry : mMultiSelectUserPrivacy.entrySet()) {
                        if (entry.getValue().equals("1")) {
                            if (mPostPrivacy != null) {
                                mPostPrivacy += entry.getKey() + ",";
                            } else {
                                mPostPrivacy = entry.getKey() + ",";
                            }
                        }
                    }
                    mPostPrivacy = mPostPrivacy.substring(0, mPostPrivacy.lastIndexOf(","));

                } else if (mPostPrivacy == null) {
                    mPostPrivacy = "friends";
                }

                // Adding composer values.
                JSONObject composerObject = new JSONObject();

                // Adding check-in option in params
                if (selectedLocation != null && selectedLocation.size() != 0) {
                    try {
                        composerObject.put("checkin", mSelectedLocationObject);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                // Adding composer in param if there is any tag, check-in.
                if (composerObject.length() > 0) {
                    postParams.put("composer", composerObject.toString());
                }

                // TODO, in future if this work needs to be done for other modules.
//                if (subjectId != 0 && subjectType != null && !subjectType.isEmpty()) {
//                    postParams.put("subject_id", String.valueOf(subjectId));
//                    postParams.put("subject_type", subjectType);
//                }

                progressDialog.show();
                final String channelName = UUID.randomUUID().toString();
                String description = etDescription.getText() != null
                        ? etDescription.getText().toString()
                        : "";
                String startUrl = AppConstant.DEFAULT_URL + "livestreamingvideo/" +
                        "start-video-streaming?channel_id=1&stream_name=" + channelName + "&auth_view=" + mPostPrivacy;
                HashMap<String, String> param = new HashMap<>();
                param.put("description", description);
                startUrl = mAppConst.buildQueryString(startUrl, param);
                mAppConst.postJsonRequestWithoutParams(startUrl, new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) {
                        progressDialog.dismiss();
                        int videoId = jsonObject.optInt("video_id");
                        // video type means core video or site-video.
                        String videoType = jsonObject.optString("subject_type", "video");
                        Bundle bundle = getIntent().getExtras();
                        if (bundle == null) {
                            bundle = new Bundle();
                        }
                        bundle.putBoolean(ConstantVariables.IS_BROADCASTER, true);
                        bundle.putInt(ConstantVariables.VIDEO_ID, videoId);
                        bundle.putString(ConstantVariables.VIDEO_TYPE, videoType);
                        bundle.putString(ConstantVariables.CHANNEL_NAME, channelName);
                        bundle.putSerializable(ConstantVariables.POST_PARAMS, (Serializable) postParams);
                        Intent intent = new Intent(mContext, LiveRoomActivity.class);
                        intent.putExtras(bundle);
                        startActivityForResult(intent, ConstantVariables.LIVE_VIDEO_REQUEST_CODE);
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        progressDialog.dismiss();
                    }
                });

                break;
        }
    }

    @Override
    public void onCheckInLocationChanged(Bundle data) {
        selectedLocation.clear();
        locationLabel = null;
        if (data != null && !data.isEmpty()) {
            mSelectedLocationBundle = data;
            String locationId = data.getString("placeId");
            String locationLabel = data.getString("locationLabel");
            try {
                mSelectedLocationObject = new JSONObject(data.getString("locationObject"));
            } catch (JSONException e) {
                e.printStackTrace();
            }
            this.locationLabel = locationLabel;
            selectedLocation.put(locationId, locationLabel);
        }
        showLocationAndTaggedFriends();
    }

    @Override
    public void onTagFriendClicked() {
        tvLocationAndTaggedFriends.setSelected(false);
        addFriends();
    }

    @Override
    public void onLocationClicked() {
        tvLocationAndTaggedFriends.setSelected(false);
        tvLocationAndTaggedFriends.clearFocus();
        showLocationAndTaggedFriends();
        addLocation();
    }

    @Override
    protected void destroyUIEvent() {
        terminateLiveStreaming(false);
    }

    @Override
    protected void onPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == ConstantVariables.ACCESS_FINE_LOCATION) {
            addLocation();
        }
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_DOWN && etDescription != null) {
            Rect outRect = new Rect();
            etDescription.getGlobalVisibleRect(outRect);
            if (!outRect.contains((int) event.getRawX(), (int) event.getRawY())) {
                mAppConst.hideKeyboard();
            }
        }
        return super.dispatchTouchEvent(event);
    }

    /**
     * Method to initialize the views.
     */
    private void initializeViews() {
        flVideoView = findViewById(R.id.video_view_container);
        tvViewPrivacy = findViewById(R.id.viewPrivacy);
        tvGoLive = findViewById(R.id.goLive);
        cameraFlip = findViewById(R.id.cameraFlip);
        moreOptions = findViewById(R.id.moreOptions);
        etDescription = findViewById(R.id.liveDescription);
        tvEndLive = findViewById(R.id.end);
        tvLocationAndTaggedFriends = findViewById(R.id.locationAndTagFriends);
        tvLocationAndTaggedFriends.setMovementMethod(LinkMovementMethod.getInstance());
        tvLocationAndTaggedFriends.setTextIsSelectable(false);

        int marginTop = AppConstant.getDisplayMetricsHeight(mContext) / 3;
        int margin = mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp);
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) tvViewPrivacy.getLayoutParams();
        layoutParams.setMargins(margin, marginTop, margin, margin);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            layoutParams.setMarginStart(margin);
            layoutParams.setMarginEnd(margin);
        }
        tvViewPrivacy.setLayoutParams(layoutParams);
        tvViewPrivacy.setOnTouchListener(new DrawableClickListener.RightDrawableClickListener(tvViewPrivacy) {
            @Override
            public boolean onDrawableClick() {
                showPopup(tvViewPrivacy);
                return true;
            }
        });

        Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_sticker_placeholder);
        drawable.mutate();
        drawable.setBounds(0, 0, mContext.getResources().getDimensionPixelSize(R.dimen.dimen_25dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.dimen_25dp));

        // TODO, In future if need to add emoticons compatibility with description.
//        etDescription.setCompoundDrawables(null, null, drawable, null);

//        etDescription.setOnTouchListener(new DrawableClickListener.RightDrawableClickListener(etDescription) {
//            @Override
//            public boolean onDrawableClick() {
//                /* To show Emoji Keyboard */
//                EmojiUtil.showEmojiKeyboard(mContext, etDescription);
//                return true;
//            }
//        });

        progressDialog = new ProgressDialog(mContext);
        progressDialog.setMessage(mContext.getResources().getString(R.string.going_live) + "...");
        progressDialog.setCancelable(false);
        progressDialog.setCanceledOnTouchOutside(false);

        tvGoLive.setOnClickListener(this);
        cameraFlip.setOnClickListener(this);
        moreOptions.setOnClickListener(this);
        tvEndLive.setOnClickListener(this);
        CustomViews.setOnLocationAndTagClickListener(this);
    }

    /**
     * Method to get privacy options.
     */
    private void checkPrivacyOptions() {
        if (PreferencesUtils.getStatusPostPrivacyOptions(mContext) != null
                && !PreferencesUtils.getStatusPostPrivacyOptions(mContext).isEmpty()
                && !PreferencesUtils.getStatusPostPrivacyOptions(mContext).equals("null")) {
            setPrivacy();
        } else {
            mAppConst.getJsonResponseFromUrl(AppConstant.DEFAULT_URL + "advancedactivity/feeds/feed-post-menus",
                    new OnResponseListener() {
                        @Override
                        public void onTaskCompleted(JSONObject jsonObject) {
                            if (jsonObject != null && jsonObject.optJSONObject("feed_post_menu") != null) {
                                PreferencesUtils.setStatusPrivacyOptions(mContext, jsonObject.optJSONObject("feed_post_menu"));
                            }
                            setPrivacy();
                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {

                        }
                    });
        }
    }

    /**
     * Method to set privacy.
     */
    private void setPrivacy() {
        try {
            mFeedPostMenus = new JSONObject(PreferencesUtils.getStatusPostPrivacyOptions(mContext));
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
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void setUpBottomSheet() {
        //Views for the tag friends and location in Bottom sheet dialog.
        List<SheetItemModel> list = new ArrayList<>();
        list.add(new SheetItemModel(mContext.getResources().getString(R.string.tag_friends), "tag", "f234"));
        list.add(new SheetItemModel(mContext.getResources().getString(R.string.location_label), "location", "f041"));
        mSheetAdapter = new SimpleSheetAdapter(mContext, list, true);
        View inflatedView = getLayoutInflater().inflate(R.layout.fragmen_cart, null);
        inflatedView.setBackgroundResource(R.color.white);
        RecyclerView recyclerView = inflatedView.findViewById(R.id.recycler_view);
        inflatedView.findViewById(R.id.cart_bottom).setVisibility(View.GONE);
        recyclerView.getLayoutParams().height = RecyclerView.LayoutParams.WRAP_CONTENT;
        recyclerView.setHasFixedSize(true);
        recyclerView.setLayoutManager(new LinearLayoutManager(mContext));
        recyclerView.setAdapter(mSheetAdapter);
        bottomSheetDialog = new BottomSheetDialog(mContext);
        bottomSheetDialog.setContentView(inflatedView);
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
                    setDescription(mUserPrivacyObject.optString(mPostPrivacy));
                    PreferencesUtils.setStatusPrivacyKey(mContext, mPostPrivacy);
                    mPostPrivacy = null;
                }
                break;

            default:
                setDescription(mUserPrivacyObject.optString(mPostPrivacy));
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
     * Method to show popup when the
     *
     * @param view View on which popup need to be shown
     */
    public void showPopup(View view) {

        PopupMenu popup = new PopupMenu(mContext, view);
        popupMenuList.clear();

        if (mUserPrivacyObject != null && mUserPrivacyObject.length() != 0) {
            JSONArray mPrivacyKeys = mUserPrivacyObject.names();

            for (int i = 0; i < mUserPrivacyObject.length(); i++) {
                String key = mPrivacyKeys.optString(i);
                popupMenuList.add(key);
                String privacyLabel = mUserPrivacyObject.optString(key);
                if (mPostPrivacy != null && mPostPrivacy.equals(key)) {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(true).setChecked(true);
                } else if (mPostPrivacy == null && key.equals("friends")
                        && (mMultiSelectUserPrivacy == null || mMultiSelectUserPrivacy.isEmpty())) {
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(true).setChecked(true);
                } else {
                    boolean isSelected = (mMultiSelectUserPrivacy != null && mMultiSelectUserPrivacy.size() > 0)
                            && mMultiSelectUserPrivacy.get(key) != null && mMultiSelectUserPrivacy.get(key).equals("1");
                    popup.getMenu().add(Menu.NONE, i, Menu.NONE, privacyLabel).setCheckable(isSelected).setChecked(isSelected);
                }
            }
        }

        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            public boolean onMenuItemClick(MenuItem item) {
                int id = item.getItemId();

                mPostPrivacy = popupMenuList.get(id);

                // Clearing list when any other popup option(other than multiple friend/network list) is clicked.
                if (!mPostPrivacy.equals("network_list_custom")
                        && !mPostPrivacy.equals("friend_list_custom")) {
                    mMultiSelectUserPrivacy.clear();
                }
                setPrivacyOption(true);
                return true;
            }
        });
        popup.show();
    }

    /**
     * Method to set default privacy key.
     */
    private void setDefaultPrivacyKey() {
        mPostPrivacy = !PreferencesUtils.getStatusPrivacyKey(mContext).equals("network_list_custom")
                && !PreferencesUtils.getStatusPrivacyKey(mContext).equals("friend_list_custom")
                ? PreferencesUtils.getStatusPrivacyKey(mContext) : "friends";
        setDescription(mUserPrivacyObject.optString(mPostPrivacy));
    }

    /**
     * Method to set description on post description view according to privacy.
     *
     * @param privacyTitle Privacy title.
     */
    private void setDescription(String privacyTitle) {
        tvViewPrivacy.setText(mContext.getResources().getString(R.string.live_with_text) + " " + privacyTitle);
    }

    /**
     * Method to launch class which will tag the friends.
     */
    private void addFriends() {
        Intent addPeopleIntent = new Intent(mContext, AddPeople.class);

        Set<String> keySet = selectedFriends.keySet();
        Bundle bundle = new Bundle();

        for (String key : keySet) {
            String value = selectedFriends.get(key);
            bundle.putString(key, value);
        }

        //TODO, in future if live option will be added in moduels.
//                            bundle.putInt(ConstantVariables.SUBJECT_ID, mSubjectId);
//                            bundle.putString(ConstantVariables.SUBJECT_TYPE, mSubjectType);
        addPeopleIntent.putExtras(bundle);
        startActivityForResult(addPeopleIntent, ConstantVariables.ADD_PEOPLE_CODE);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    /**
     * Method to show add location dialog.
     */
    private void addLocation() {
        Bundle bundle = new Bundle();
        if (selectedLocation != null && selectedLocation.size() != 0) {
            bundle.putBundle("locationsBundle", mSelectedLocationBundle);
            bundle.putBoolean(ConstantVariables.IS_SHOW_ADDED_LOCATION, true);
        }
        checkInLocationDialog = new CheckInLocationDialog(mContext, bundle);
        checkInLocationDialog.show();

    }

    /**
     * Method to show location and tagged friends.
     */
    private void showLocationAndTaggedFriends() {
        CustomViews.setViewForLocationAndTaggedFriends(mContext, tvLocationAndTaggedFriends, selectedFriendList,
                locationLabel);
    }

    private void terminateLiveStreaming(boolean isVideoSharedOnFeed) {
        if (bottomSheetDialog != null) {
            bottomSheetDialog.dismiss();
        }
        if (worker() != null) {
            worker().preview(false, null, 0);
        }

        if (isVideoSharedOnFeed) {
            Intent intent = new Intent();
            intent.putExtra(ConstantVariables.IS_LIVE_STREAM_SHARED_ON_FEED, true);
            setResult(ConstantVariables.LIVE_VIDEO_REQUEST_CODE, intent);
        }
        finish();
    }

}
