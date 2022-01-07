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

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.PorterDuffColorFilter;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.graphics.PorterDuff;
import android.os.Handler;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.AppCompatTextView;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.text.method.HideReturnsTransformationMethod;
import android.text.method.PasswordTransformationMethod;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.hbb20.CountryCodePicker;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.adapters.AddPeopleAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.CheckInAdapter;
import com.socialengineaddons.mobileapp.classes.common.ui.BaseButton;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.NestedListView;
import com.socialengineaddons.mobileapp.classes.common.utils.AddPeopleList;
import com.socialengineaddons.mobileapp.classes.common.utils.CheckInList;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SelectedFriendList;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.editor.NewEditorActivity;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.modules.advancedEvents.AdvEventsInfoTabFragment;
import com.socialengineaddons.mobileapp.classes.modules.messages.SelectedFriendListAdapter;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static android.content.Context.LAYOUT_INFLATER_SERVICE;

/**
 * FormEditText is used to inflate the fields for the Edit text with the error view
 * and the other module specific views.
 */

public class FormEditText extends FormWidget implements TextWatcher, AdapterView.OnItemClickListener,
        View.OnClickListener {

    // Member Variables.
    private Context mContext;
    private EditText etFieldValue;
    private EditText tvLocationField;
    private BaseButton btnCheckUrl;
    private NestedListView mFriendNestedListView;
    private RecyclerView mAddedFriendRecyclerView;
    private ProgressBar pbLoadFriendList;
    private int mContentId, hostPosition;
    private boolean isSearchHost = false, isCreateForm;
    private String mCurrentSelectedOption, mFieldName;
    private JSONObject jsonObjectProperty;
    private List<SelectedFriendList> mSelectedFriendList;
    private List<AddPeopleList> mAddPeopleList;
    private Map<Integer, String> mShowNonSelectedFriend;
    private Map<String, String> mSelectedFriendsMap;
    private Map<String, String> mPostParams;
    private Map<String, FormWidget> mFormWidgetMap;
    private ArrayList<FormWidget> mFormWidgetList;
    private FormWidget mFormWidget;
    private FormActivity mFormActivity;
    private AppConstant mAppConst;
    private SelectedFriendListAdapter mSelectedFriendListAdapter;
    private AddPeopleAdapter mAddPeopleAdapter;
    private String mValue;
    private CheckInAdapter mCheckInAdapter;
    private ArrayList<CheckInList> mCheckInList;
    private String searchText = null;
    private StringBuilder mTextSearchUrl;
    private ListView locationsListView;
    public static PopupWindow popupWindow;
    private String locationSearchText = "";
    private double mLongitude, mLatitude;
    private TextView tvError, tvVisibility;
    private int mMinLength;

    /**
     * Public constructor to inflate form field For the edit text.
     *
     * @param context               Context of calling class.
     * @param property              Property of the field.
     * @param jsonObjectProperty    Json object of the selected property.
     * @param description           Description of the field.
     * @param hasValidator          True if the field has validation (Compulsory field).
     * @param type                  Type of the field.
     * @param inputType             Input Type of the field.
     * @param widgets               List of FormWidget.
     * @param map                   Map of field name and formWidget.
     * @param contentId             Content id.
     * @param createForm            True if the form is loaded for creation.
     * @param isNeedToHideView      True if need to hide the inflated view.
     * @param value                 Value of the field.
     * @param currentSelectedOption Current selected module.
     */
    public FormEditText(Context context, String property, JSONObject jsonObjectProperty,
                        String description, boolean hasValidator, String type, String inputType,
                        ArrayList<FormWidget> widgets, Map<String, FormWidget> map, int contentId,
                        boolean createForm, boolean isNeedToHideView, String value, String currentSelectedOption) {

        super(context, property, hasValidator);

        // Initialize member variables.
        mContext = context;
        mFieldName = property;
        this.jsonObjectProperty = jsonObjectProperty;
        mFormWidgetList = widgets;
        mFormWidgetMap = map;
        mContentId = contentId;
        isCreateForm = createForm;
        mCurrentSelectedOption = currentSelectedOption;

        mFormActivity = new FormActivity();
        mAppConst = new AppConstant(mContext);

        mValue = value;

        // Inflate the field view layout.
        View inflateView;
        if (ConstantVariables.FORM_LAYOUT_TYPE == 1) {
            inflateView = ((Activity) mContext).getLayoutInflater().inflate(R.layout.layout_form_text_block_1, null);
        } else {
            inflateView = ((Activity) mContext).getLayoutInflater().inflate(R.layout.layout_form_text_block, null);
        }

        getViews(inflateView, description);
        checkForTextArea(type, inputType);
        inflateView.setTag(mFieldName);

        // Adding view for the host.
        if (property.equals("host_title")) {
            int margin = (int) mContext.getResources().getDimension(R.dimen.margin_10dp);
            LinearLayout linearLayout = new LinearLayout(context);
            linearLayout.setOrientation(LinearLayout.HORIZONTAL);
            TextView tvHost = new TextView(context);
            tvHost.setText(mContext.getResources().getString(R.string.add_new_host_text));
            TextView tvCancel = new TextView(context);
            tvCancel.setPadding(margin, margin, margin, margin);
            tvCancel.setId(R.id.cancel);
            tvCancel.setTextColor(ContextCompat.getColor(mContext, R.color.themeButtonColor));
            tvCancel.setText(" [" + mContext.getResources().getString(R.string.cancel) + "]");

            linearLayout.addView(tvHost);
            linearLayout.addView(tvCancel);
            _layout.addView(linearLayout);
            tvCancel.setOnClickListener(this);

        } else if (property.equals("host_auto")) {
            isSearchHost = true;

        } else if (!FormActivity.sIsCreateDiaryDescription && (mCurrentSelectedOption.equals("add_to_diary")
                || mCurrentSelectedOption.equals("add_wishlist")
                || mCurrentSelectedOption.equals("add_to_friend_list"))) {

            AppCompatTextView createDiaryTextView = new AppCompatTextView(context);
            int padding = (int) mContext.getResources().getDimension(R.dimen.padding_6dp);
            createDiaryTextView.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp),
                    padding, mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0);
            createDiaryTextView.setText(FormActivity.createDiaryDescription);
            _layout.addView(createDiaryTextView);
            FormActivity.sIsCreateDiaryDescription = true;
        }

        _layout.addView(inflateView);

        if (isNeedToHideView) {
            _layout.setTag(mFieldName);
            _layout.setVisibility(View.GONE);
        }

    }

    /**
     * Method to get views from the form layout and set data in views..
     *
     * @param configFieldView View which is inflated.
     * @param description     Description of the field.
     */
    private void getViews(View configFieldView, String description) {

        // Getting label, description and field value views.
        TextView tvLabel = configFieldView.findViewById(R.id.view_label);
        tvLabel.setTypeface(Typeface.DEFAULT_BOLD);
        TextView tvDescription = configFieldView.findViewById(R.id.view_description);
        etFieldValue =  configFieldView.findViewById(R.id.field_value);
        tvLocationField = configFieldView.findViewById(R.id.location_field_value);
        btnCheckUrl = configFieldView.findViewById(R.id.btn_check_url);
        tvError = configFieldView.findViewById(R.id.error_view);
        tvVisibility = configFieldView.findViewById(R.id.tvVisibility);

        // Showing auto complete text view only for the location.
        if (mFieldName.contains("location")) {
            etFieldValue.setVisibility(View.GONE);
            if (ConstantVariables.FORM_LAYOUT_TYPE == 1) {
                configFieldView.findViewById(R.id.rlEditTextWrapper).setVisibility(View.GONE);
            }

            tvLocationField.setVisibility(View.VISIBLE);
            mCheckInList = new ArrayList<>();

            LayoutInflater inflater = (LayoutInflater) mContext.getSystemService(LAYOUT_INFLATER_SERVICE);

            // Inflate the custom layout/view
            View customView = inflater.inflate(R.layout.custom_dialog,null);

            popupWindow = new PopupWindow(customView, LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT);
            locationsListView = customView.findViewById(R.id.list);

            mCheckInAdapter = new CheckInAdapter(mContext, R.layout.checkin_list, mCheckInList);
            locationsListView.setAdapter(mCheckInAdapter);
            tvLocationField.addTextChangedListener(this);
            locationsListView.setOnItemClickListener(this);

        } else {
            etFieldValue.setVisibility(View.VISIBLE);
            etFieldValue.addTextChangedListener(this);
            tvLocationField.setVisibility(View.GONE);
        }

        // Showing check url option.
        if ((mCurrentSelectedOption.equals(ConstantVariables.ADV_GROUPS_MENU_TITLE)
                && mFieldName.equals("group_uri"))
                || (mCurrentSelectedOption.equals(ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE)
                && mFieldName.equals("channel_uri"))) {
            btnCheckUrl.setVisibility(View.VISIBLE);
            btnCheckUrl.setOnClickListener(this);

        } else if (mFieldName.equals("searchGuests") || mFieldName.equals("toValues")
                || mFieldName.equals("host_auto")) {
            mAddPeopleList = new ArrayList<>();
            mSelectedFriendList = new ArrayList<>();
            mSelectedFriendsMap = new HashMap<>();
            mShowNonSelectedFriend = new HashMap<>();

            pbLoadFriendList = configFieldView.findViewById(R.id.sentToLoadingProgressBar);
            mFriendNestedListView = configFieldView.findViewById(R.id.friendListView);
            mAddPeopleAdapter = new AddPeopleAdapter(mContext, R.layout.list_friends, mAddPeopleList);
            mFriendNestedListView.setAdapter(mAddPeopleAdapter);
            mFriendNestedListView.setVisibility(View.VISIBLE);

            mAddedFriendRecyclerView = configFieldView.findViewById(R.id.addedFriendList);
            LinearLayoutManager layoutManager = new LinearLayoutManager(mContext, LinearLayoutManager.HORIZONTAL, false);
            mAddedFriendRecyclerView.setLayoutManager(layoutManager);
            mSelectedFriendListAdapter = new SelectedFriendListAdapter(mSelectedFriendList,
                    mAddedFriendRecyclerView, mSelectedFriendsMap, mShowNonSelectedFriend, false);
            mAddedFriendRecyclerView.setAdapter(mSelectedFriendListAdapter);

            mFriendNestedListView.setOnItemClickListener(this);
        }

        // Setting up data in views.
        if (ConstantVariables.FORM_LAYOUT_TYPE != 1 && jsonObjectProperty.optString("label") != null && !jsonObjectProperty.optString("label").isEmpty()) {
            tvLabel.setVisibility(View.VISIBLE);
            etFieldValue.setPadding(0, mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp), 0, 0);
            if (jsonObjectProperty.optString("label").toLowerCase().contains(getDisplayText().toLowerCase())) {
                tvLabel.setText(getDisplayText());
            } else {
                tvLabel.setText(jsonObjectProperty.optString("label"));
            }
        } else {
            if (jsonObjectProperty.optString("textVisibility", "0").equals("1")) {
                tvVisibility.setVisibility(View.VISIBLE);
                etFieldValue.setTransformationMethod(PasswordTransformationMethod.getInstance());
                tvVisibility.setOnClickListener(this::onClick);
                tvVisibility.setTag("1");
                Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_app_icons_visible_eye_icon_outlined).mutate();
                tvVisibility.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
            }
            tvLabel.setVisibility(View.GONE);
        }
        if (jsonObjectProperty.has("value")) {
            setValue(jsonObjectProperty.optString("value"));
        }
        //TODO, Uncomment this when ever the description is needed.
        // Showing description field if it is coming in response.
//        if (description != null && !description.isEmpty()) {
//            tvDescription.setVisibility(View.VISIBLE);
//            tvDescription.setText(description);
//        } else {
//            tvDescription.setVisibility(View.GONE);
//        }
        //TODO, Remove Module Check Once Type TinyEMC
        // Setting up the click listener on the overview field to open the editor.
        if (mFieldName.equals("overview")) {
            configFieldView.findViewById(R.id.form_main_view).setOnClickListener(this);
            etFieldValue.setOnClickListener(this);
            etFieldValue.setFocusableInTouchMode(false);
            etFieldValue.setFocusable(false);
            etFieldValue.setKeyListener(null);
        } else if(mFieldName.equals("product_search")){
            etFieldValue.setTag("product_search");
            etFieldValue.setFocusableInTouchMode(false);
            etFieldValue.setFocusable(false);
            etFieldValue.setKeyListener(null);
            etFieldValue.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent  intent = new Intent(mContext, FragmentLoadActivity.class);
                    intent.putExtra(ConstantVariables.FRAGMENT_NAME,ConstantVariables.SELECT_PRODUCT);
                    intent.putExtra(ConstantVariables.CONTENT_TITLE,"Choose Product");
                    intent.putExtra("store_id",mContentId);
                    ((Activity)mContext).startActivityForResult(intent,ConstantVariables.SELECT_PRODUCT_RETURN_CODE);
                    ((Activity)mContext).overridePendingTransition(R.anim.slide_up_in, R.anim.push_up_out);
                }
            });
        } else if (mCurrentSelectedOption.equals(ConstantVariables.SIGN_UP_FIELDS) &&
                (mFieldName.contains("first_name") || mFieldName.contains("last_name"))) {
            setValue(mValue);
        }
        //TODO recheck it if need to implement this.
        // Setting up the max length on the edit text if it is coming in response.
//        if (jsonObjectProperty.has("maxlength") && jsonObjectProperty.optInt("maxlength") != 0) {
//            etFieldValue.setFilters(new InputFilter[] {
//                    new InputFilter.LengthFilter(jsonObjectProperty.optInt("maxlength")) {
//                        public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int dstart, int dend) {
//                            CharSequence res = super.filter(source, start, end, dest, dstart, dend);
//                            if (res != null) {
//                                etFieldValue.setError("Limit exceeded! Max number of "
//                                        + jsonObjectProperty.optInt("maxlength") +" characters allowed.");
//                            }
//                            return res;
//                        }
//                    }
//            });
//        }

        if (ConstantVariables.FORM_LAYOUT_TYPE == 1 ) {
            if (jsonObjectProperty.has(ConstantVariables.KEY_LEFT_DRAWABLE)) {
                Drawable drawable = GlobalFunctions.getDrawableByName(mContext,
                        jsonObjectProperty.optString(ConstantVariables.KEY_LEFT_DRAWABLE,
                                ConstantVariables.KEY_LEFT_DRAWABLE));
                etFieldValue.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
                tvLocationField.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
            }
            if (jsonObjectProperty.has(ConstantVariables.KEY_RIGHT_DRAWABLE)) {
                Drawable drawable = GlobalFunctions.getDrawableByName(mContext,
                        jsonObjectProperty.optString(ConstantVariables.KEY_RIGHT_DRAWABLE,
                                ConstantVariables.KEY_RIGHT_DRAWABLE));
                etFieldValue.setCompoundDrawablesWithIntrinsicBounds(null, null, drawable, null);
                tvLocationField.setCompoundDrawablesWithIntrinsicBounds(null, null, drawable, null);

            }
        }

    }

    /***
     * Method to check the text type and set the input type and max lines accordingly.
     *
     * @param type Type of the field.
     * @param inputType Input Type of the field.
     */
    private void checkForTextArea(String type, String inputType) {
        switch (type) {
            case FormActivity.SCHEMA_KEY_TextArea:
            case FormActivity.SCHEMA_KEY_TextArea_LOWER:
                etFieldValue.setHeight(mContext.getResources().getDimensionPixelSize(R.dimen.attachment_small_image_size));
                etFieldValue.setMaxHeight(mContext.getResources().getDimensionPixelSize(R.dimen.attachment_small_image_size));
                etFieldValue.setSingleLine(false);
                etFieldValue.setGravity(Gravity.START | Gravity.TOP);
                break;

            case FormActivity.SCHEMA_KEY_PASSWORD:
                etFieldValue.setInputType(InputType.TYPE_TEXT_VARIATION_PASSWORD);
                etFieldValue.setTransformationMethod(PasswordTransformationMethod.getInstance());
                break;

            default:
                etFieldValue.setGravity(Gravity.CENTER_VERTICAL);
                etFieldValue.setMaxLines(1);
                break;
        }

        // Setting input type to email address when the field name contains the email.
        if (mFieldName.toLowerCase().contains("email")) {
            etFieldValue.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        }

        // Setting input type to number if field is phone with type text
        if ((mCurrentSelectedOption.equals(ConstantVariables.CONTACT_INFO_MENU_TITLE)
                && mFieldName.toLowerCase().contains("phone"))
                || (mCurrentSelectedOption.equals(ConstantVariables.MLT_MENU_TITLE)
                && mFieldName.toLowerCase().contains("contact"))) {
            etFieldValue.setInputType(InputType.TYPE_CLASS_NUMBER);
        }

        // setting input type to number if field is for numeric value.
        if (inputType != null && inputType.equals("number")) {
            etFieldValue.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);
        }
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        if (handler != null)
          handler.removeCallbacks(input_finish_checker);
    }

    @Override
    public void onTextChanged(CharSequence searchText, int start, int before, int count) {

        etFieldValue.setError(null);
        tvLocationField.setError(null);
        if (tvError != null) {
            tvError.setVisibility(View.GONE);
        }
        // Showing the check url button.
        if ((mCurrentSelectedOption.equals(ConstantVariables.ADV_GROUPS_MENU_TITLE)
                && mFieldName.equals("group_uri"))
                || (mCurrentSelectedOption.equals(ConstantVariables.ADV_VIDEO_CHANNEL_MENU_TITLE)
                && mFieldName.equals("channel_uri"))) {
            etFieldValue.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0);
            btnCheckUrl.setText(mContext.getResources().getString(R.string.check_url));
            btnCheckUrl.setVisibility(View.VISIBLE);

        } else if (mFriendNestedListView != null && searchText != null
                && searchText.length() != 0) {

            // Getting friend list when user type a name in edit text.
            mPostParams = new HashMap<>();
            String getFriendsUrl = null, key;
            if (isSearchHost) {
                if (FormActivity.hostKey != null && !FormActivity.hostKey.isEmpty()) {
                    getFriendsUrl = AppConstant.DEFAULT_URL + "advancedevents/get-hosts?host_type_select="
                            + FormActivity.hostKey;
                }
                key = "host_auto";
            } else if (mContentId != 0) {
                getFriendsUrl = AppConstant.DEFAULT_URL + "advancedgroups/members/getusers/"
                        + mContentId + "?limit=10";
                key = "text";
            } else {
                getFriendsUrl = AppConstant.DEFAULT_URL + "advancedevents/member-suggest?limit=10"
                        + "&subject=" + AdvEventsInfoTabFragment.sGuid;
                key = "value";
            }
            if (getFriendsUrl != null && !getFriendsUrl.isEmpty()) {
                mPostParams.put(key, String.valueOf(searchText));
                getFriendListFromUrl(mAppConst.buildQueryString(getFriendsUrl, mPostParams));
            }
        }
    }

    @Override
    public void afterTextChanged(Editable editable) {
        if (mFieldName.contains("location")) {
            searchText = editable.toString();
            last_text_edit = System.currentTimeMillis();
            handler.postDelayed(input_finish_checker, delay);
        }
    }

    long delay = 1000; // 1 seconds after user stops typing
    long last_text_edit = 0;
    Handler handler = new Handler();

    private Runnable input_finish_checker = new Runnable() {
        public void run() {
            if (System.currentTimeMillis() > (last_text_edit + delay - 500)) {
                if(searchText != null && searchText.trim().length() > 2
                        && !locationSearchText.equals(searchText)) {
                    mTextSearchUrl = new StringBuilder(UrlUtil.PLACES_API_BASE
                            + "/textsearch" + "/json");
                    try {
                        mTextSearchUrl.append("?query=").append(URLEncoder.encode(searchText, "utf8"));
                    } catch (UnsupportedEncodingException e) {
                        e.printStackTrace();
                    }
                    try {
                        JSONObject userDetail = (!mAppConst.isLoggedOutUser()) ? new JSONObject(PreferencesUtils.getUserDetail(mContext)) : null;
                        if (userDetail != null){
                            mLatitude = userDetail.optDouble(PreferencesUtils.USER_LOCATION_LATITUDE);
                            mLongitude = userDetail.optDouble(PreferencesUtils.USER_LOCATION_LONGITUDE);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    mTextSearchUrl.append("&location=");
                    mTextSearchUrl.append(Double.toString(mLatitude));
                    mTextSearchUrl.append(",");
                    mTextSearchUrl.append(Double.toString(mLongitude));
                    mTextSearchUrl.append("&radius=50000");
                    mTextSearchUrl.append("&key=" + mContext.getResources().getString(R.string.places_api_key));

                    // Creating a new non-ui thread task to download json data
                    PlacesTask placesTask = new PlacesTask();

                    // Invokes the "doInBackground()" method of the class PlaceTask
                    placesTask.execute(mTextSearchUrl.toString());
                } else {
                    if (mCheckInAdapter != null) {
                        mCheckInAdapter.clear();
                    }
                }
            }
        }
    };

    /** A class, to download Google Places */
    private class PlacesTask extends AsyncTask<String, Integer, String> {

        String data = null;

        // Invoked by execute() method of this object
        @Override
        protected String doInBackground(String... url) {
            try {
                data = downloadUrl(url[0]);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return data;
        }

        // Executed after the complete execution of doInBackground() method
        @Override
        protected void onPostExecute(String result) {
            mCheckInList.clear();
            if (data != null) {
                try {
                    JSONObject jsonObject = new JSONObject(data);
                    if(jsonObject.has("error_message")){
                        SnackbarUtils.displaySnackbar(tvLocationField,
                                jsonObject.optString("error_message"));
                    }else{
                        if (mCheckInAdapter != null) {
                            mCheckInAdapter.clear();
                        }
                        if (jsonObject != null && jsonObject.length() != 0) {

                            JSONArray locationResults = jsonObject.getJSONArray("results");
                            for (int i = 0; i < locationResults.length(); i++) {

                                JSONObject placeObject = locationResults.getJSONObject(i);
                                JSONObject locationObject = placeObject.optJSONObject("geometry").optJSONObject(
                                        "location");
                                double latitude = locationObject.optDouble("lat");
                                double longitude = locationObject.optDouble("lng");
                                String formattedAddress = placeObject.optString("formatted_address");

                                String placeId = placeObject.getString("place_id");
                                String locationLabel = placeObject.getString("name");
                                String locationIcon = placeObject.getString("icon");
                                JSONArray typesArray = placeObject.optJSONArray("types");
                                String vicinity = placeObject.optString("vicinity", "");

                                if (vicinity != null && !vicinity.isEmpty()) {
                                    mCheckInList.add(new CheckInList(locationIcon, placeId, locationLabel,
                                            formattedAddress, latitude, longitude, vicinity, typesArray));
                                } else {
                                    mCheckInList.add(new CheckInList(locationIcon, placeId, locationLabel,
                                            formattedAddress, latitude, longitude, formattedAddress, typesArray));
                                }
                            }
                        }
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
                mCheckInAdapter.notifyDataSetChanged();
                if (popupWindow!=null && mContext!=null){
                    popupWindow.showAsDropDown(tvLocationField);
                }

            }
        }

    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

        if (mFieldName.contains("location")) {
            handler.removeCallbacks(input_finish_checker);
            popupWindow.dismiss();
            CheckInList checkInList = mCheckInList.get(position);
            locationSearchText = checkInList.getmLocationLabel();
            tvLocationField.setText(checkInList.getmLocationLabel());
            tvLocationField.setSelection(checkInList.getmLocationLabel().length());
            if (mCheckInAdapter != null) {
                mCheckInAdapter.clear();
            }

            FormActivity.locationObject = new JSONObject();
            try {
                FormActivity.locationObject.put("location", locationSearchText);
                FormActivity.locationObject.put("formatted_address", checkInList.getmFormattedAddress());
                FormActivity.locationObject.put("icon", checkInList.getmLocationIcon());
                FormActivity.locationObject.put("vicinity", checkInList.getmVicinity());
                FormActivity.locationObject.put("latitude", checkInList.getLatitude());
                FormActivity.locationObject.put("longitude", checkInList.getLongitude());
                FormActivity.locationObject.put("place_id", checkInList.getmPlaceId());

                String types = "";
                // Send Comma separated types
                JSONArray typesArray = checkInList.getmTypesArray();
                if(typesArray != null){
                    for(int j = 0; j < typesArray.length(); j++){
                        if (j < typesArray.length() - 1)
                            types += typesArray.getString(j) + ",";
                        else
                            types += typesArray.getString(j);
                    }
                }
                FormActivity.locationObject.put("types", types);

            } catch (JSONException e) {
                e.printStackTrace();
            }

        } else {
            AddPeopleList addPeopleList = mAddPeopleList.get(position);
            String label = addPeopleList.getmUserLabel();
            int userId = addPeopleList.getmUserId();

            if (mAddPeopleAdapter != null) {
                mAddPeopleAdapter.clear();
            }

            // Checking for the request is for host or others.
            if (!isSearchHost) {
                mAddedFriendRecyclerView.setVisibility(View.VISIBLE);
                if (!mSelectedFriendsMap.containsKey(Integer.toString(userId))) {
                    mSelectedFriendsMap.put(Integer.toString(userId), label);
                    FormActivity.selectedGuest = mSelectedFriendsMap;
                    mShowNonSelectedFriend.put(userId, label);
                    mSelectedFriendList.add(new SelectedFriendList(userId, label));
                    mSelectedFriendListAdapter.notifyDataSetChanged();
                }
            } else {

                for (int j = 0; j < mFormWidgetList.size(); j++) {
                    if (mFormWidgetList.get(j).getPropertyName().equals("host_type_select")) {
                        position = j;
                    }

                    if (mFormWidgetList.get(j).getPropertyName().contains("host")) {
                        mFormWidgetList.remove(j);
                        j--;
                    }
                }

                JSONObject jsonObject = addPeopleList.getmHostObject();
                String fieldName = FormHostChange.sEventHost;
                String fieldLabel = jsonObject.optString("host_title");

                mFormWidget = mFormActivity.getWidget(mContext, fieldName, jsonObject, fieldLabel, false, true,
                        null, mFormWidgetList, mFormWidgetMap, mCurrentSelectedOption, null,
                        null, null, null, null, null);

                if (jsonObject.has(FormActivity.SCHEMA_KEY_HINT))
                    mFormWidget.setHint(jsonObject.optString(FormActivity.SCHEMA_KEY_HINT));

                mFormWidgetList.add(position, mFormWidget);
                mFormWidgetMap.put(fieldName, mFormWidget);

                FormActivity._layout.removeAllViews();
                for (int k = 0; k < mFormWidgetList.size(); k++) {
                    FormActivity._layout.addView(mFormWidgetList.get(k).getView());
                }
            }
            etFieldValue.setText("");
        }
    }

    /** A method to download json data from url */
    private String downloadUrl(String strUrl) throws IOException {
        String data = "";
        InputStream iStream = null;
        HttpURLConnection urlConnection = null;

        try {
            URL url = new URL(strUrl);

            // Creating an http connection to communicate with url
            urlConnection = (HttpURLConnection) url.openConnection();

            // Connecting to url
            urlConnection.connect();

            // Reading data from url
            iStream = urlConnection.getInputStream();

            BufferedReader br = new BufferedReader(new InputStreamReader(iStream));

            StringBuffer sb = new StringBuffer();

            String line = "";
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }

            data = sb.toString();

            br.close();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            iStream.close();
            urlConnection.disconnect();
        }

        return data;
    }

    @Override
    public String getValue() {

        if (mFieldName.contains("location")) {
            return tvLocationField.getText().toString();
        } else {
            return etFieldValue.getText().toString();
        }
    }

    @Override
    public void setValue(String value) {
        if (value == null) {
            return;
        }
        if (mFieldName.contains("location")) {
            tvLocationField.setText(value);
            locationSearchText = value;
        } else if (mFieldName.equals("overview")){
            CustomViews.setEditText(etFieldValue, value);
        } else {
            etFieldValue.setText(value);
        }
    }

    @Override
    public void setHint(String value) {
        // Showing hint on the respective views..
        if (value != null) {
            if (mFieldName.contains("location")) {
                tvLocationField.setHint(value);

            } else if (mFieldName.equals("phoneno")) {
                if (! jsonObjectProperty.optBoolean("hasValidator")) {
                    etFieldValue.setHint(mContext.getResources().getString(R.string.phoneno_optional_hint));
                } else {
                    etFieldValue.setHint(value);
                }
                etFieldValue.setVisibility(View.VISIBLE);

            } else {
                etFieldValue.setHint(value);
            }
        }
    }

    @Override
    public void setErrorMessage(String errorMessage) {
        // Showing error message on error view.
        if (errorMessage != null) {
            if (mFieldName.contains("location")) {
                tvLocationField.requestFocus();
                tvLocationField.setError(errorMessage);
            } else if (ConstantVariables.FORM_LAYOUT_TYPE == 1){
                tvError.setText(errorMessage);
                tvError.setVisibility(View.VISIBLE);
            } else {
                etFieldValue.requestFocus();
                etFieldValue.setError(errorMessage);
            }
        }
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.btn_check_url:
                if (etFieldValue.getText() != null && !etFieldValue.getText().toString().trim().isEmpty()) {
                    checkUrlAvailability(etFieldValue.getText().toString());
                } else {
                    SnackbarUtils.displaySnackbar(_layout,
                            mContext.getResources().getString(R.string.empty_url_text));
                }
                break;

            case R.id.cancel:
                FormActivity.hostKey = null;
                if (FormHostChange.sIsEditHost) {
                    FormHostChange.sIsEditHost = false;
                    for (int k = 0; k < mFormWidgetList.size(); k++) {
                        if (mFormWidgetList.get(k).getPropertyName().equals(FormHostChange.sEventHost)) {
                            mFormWidgetList.get(k).getView().setVisibility(View.VISIBLE);
                        } else if (mFormWidgetList.get(k).getPropertyName().equals("host_title") ||
                                mFormWidgetList.get(k).getPropertyName().equals("host_description") ||
                                mFormWidgetList.get(k).getPropertyName().equals("host_photo") ||
                                mFormWidgetList.get(k).getPropertyName().equals("host_link") ||
                                mFormWidgetList.get(k).getPropertyName().equals("host_facebook") ||
                                mFormWidgetList.get(k).getPropertyName().equals("host_twitter") ||
                                mFormWidgetList.get(k).getPropertyName().equals("host_website")) {
                            mFormWidgetList.get(k).getView().setVisibility(View.GONE);

                        }

                    }

                } else if (FormHostChange.sIsAddNewHost) {
                    FormActivity.loadEditHostForm = 0;
                    FormHostChange.sIsAddNewHost = false;

                    for (int j = 0; j < mFormWidgetList.size(); j++) {
                        if (mFormWidgetList.get(j).getPropertyName().contains("host") &&
                                !mFormWidgetList.get(j).getPropertyName().equals(FormHostChange.sEventHost)) {
                            mFormWidgetList.remove(j);
                            j--;
                        }
                    }

                    for (int j = 0; j < mFormWidgetList.size(); j++) {

                        if (mFormWidgetList.get(j).getPropertyName().equals(FormHostChange.sEventHost)) {
                            hostPosition = j;
                        }
                    }

                    hostPosition++;

                    for (int i = 0; i < FormActivity.mHostSelectionForm.length(); i++) {

                        JSONObject jsonObject = FormActivity.mHostSelectionForm.optJSONObject(i);
                        String fieldName = jsonObject.optString("name");
                        String fieldLabel = jsonObject.optString("label");

                        mFormWidget = mFormActivity.getWidget(mContext, fieldName, jsonObject, fieldLabel, false, isCreateForm,
                                null, mFormWidgetList, mFormWidgetMap, mCurrentSelectedOption, null,
                                null, null, null, null, null);

                        if (mFormWidget == null) continue;

                        if (jsonObject.has(FormActivity.SCHEMA_KEY_HINT))
                            mFormWidget.setHint(jsonObject.optString(FormActivity.SCHEMA_KEY_HINT));

                        mFormWidgetList.add(hostPosition + i, mFormWidget);
                        mFormWidgetMap.put(fieldName, mFormWidget);

                    }

                    FormActivity._layout.removeAllViews();
                    for (int i = 0; i < mFormWidgetList.size(); i++) {
                        if (mFormWidgetList.get(i).getPropertyName().equals(FormHostChange.sEventHost)) {
                            mFormWidgetList.get(i).getView().setVisibility(View.GONE);
                        }

                        FormActivity._layout.addView(mFormWidgetList.get(i).getView());
                    }


                }
                break;

            case R.id.form_main_view:
            case R.id.field_value:
                Intent intent = new Intent(mContext, NewEditorActivity.class);
                Bundle bundle = new Bundle();
                bundle.putString(NewEditorActivity.TITLE_PARAM, "");
                bundle.putString(NewEditorActivity.CONTENT_PARAM, FormActivity.overviewText);
                bundle.putString(NewEditorActivity.TITLE_PLACEHOLDER_PARAM,
                        mContext.getResources().getString(R.string.example_post_title_placeholder));
                bundle.putString(NewEditorActivity.CONTENT_PLACEHOLDER_PARAM,
                        mContext.getResources().getString(R.string.post_content_placeholder) + "…");
                bundle.putInt(NewEditorActivity.EDITOR_PARAM, NewEditorActivity.USE_NEW_EDITOR);
                bundle.putInt("textColorPrimary", mContext.getResources().getColor(R.color.textColorPrimary));
                bundle.putString(ConstantVariables.EXTRA_MODULE_TYPE, mCurrentSelectedOption);
                bundle.putBoolean("isOverview", true);
                intent.putExtras(bundle);
                ((Activity) mContext).startActivityForResult(intent, ConstantVariables.OVERVIEW_REQUEST_CODE);
                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;
            case R.id.tvVisibility:
                int caretPosition = etFieldValue.getSelectionStart();
                Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_app_icons_visible_eye_icon_outlined).mutate();
                if (!tvVisibility.getTag().toString().equals("1")) {
                    tvVisibility.setTag("1");
                    etFieldValue.setTransformationMethod(PasswordTransformationMethod.getInstance());
                } else {
                    drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_app_icons_invisible_eye_icon_outlined).mutate();
                    etFieldValue.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
                    tvVisibility.setTag("0");
                }
                tvVisibility.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
                etFieldValue.setSelection(caretPosition);
                break;
        }
    }

    /***
     * Method to get friend list.
     *
     * @param url Calling url.
     */
    private void getFriendListFromUrl(String url) {

        pbLoadFriendList.setVisibility(View.VISIBLE);
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject body) {
                pbLoadFriendList.setVisibility(View.GONE);
                if (body != null && body.length() != 0) {
                    mAddPeopleList.clear();
                    JSONArray friendListResponse = body.optJSONArray("response");
                    if (friendListResponse != null && friendListResponse.length() > 0) {
                        for (int i = 0; i < friendListResponse.length(); i++) {
                            JSONObject friendObject = friendListResponse.optJSONObject(i);
                            if (!isSearchHost) {
                                String username = friendObject.optString("label");
                                int userId = friendObject.optInt("id");
                                String userImage = friendObject.optString("image_icon");

                                if (!mShowNonSelectedFriend.isEmpty()) {
                                    if (!mShowNonSelectedFriend.containsKey(userId)) {
                                        mAddPeopleList.add(new AddPeopleList(userId, username, userImage));
                                    }
                                } else {
                                    mAddPeopleList.add(new AddPeopleList(userId, username, userImage));
                                }
                            } else {
                                String username = friendObject.optString("host_title");
                                int userId = friendObject.optInt("host_id");
                                String userImage = friendObject.optString("image_icon");
                                mAddPeopleList.add(new AddPeopleList(userId, username, userImage, friendObject));
                            }
                        }
                        mAddPeopleAdapter.notifyDataSetChanged();
                    }
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                pbLoadFriendList.setVisibility(View.GONE);
                SnackbarUtils.displaySnackbar(_layout, message);
            }
        });

    }

    /**
     * Method to check Url availability.
     *
     * @param url Url which needs to be check.
     */
    private void checkUrlAvailability(String url) {

        btnCheckUrl.setClickable(false);
        btnCheckUrl.setText(mContext.getResources().getString(R.string.checking_url) + "...");
        mPostParams = new HashMap<>();

        String actionUrl;
        if (mCurrentSelectedOption.equals(ConstantVariables.ADV_GROUPS_MENU_TITLE)) {
            actionUrl = AppConstant.DEFAULT_URL + "advancedgroups/groupurlvalidation";
            mPostParams.put("group_uri", url);
        } else {
            actionUrl = AppConstant.DEFAULT_URL + "advancedvideos/channel/channelurl-validation";
            mPostParams.put("channel_uri", url);
        }

        mAppConst.getJsonResponseFromUrl(mAppConst.buildQueryString(actionUrl, mPostParams), new OnResponseListener() {
                    @Override
                    public void onTaskCompleted(JSONObject jsonObject) {
                        btnCheckUrl.setVisibility(View.GONE);
                        btnCheckUrl.setClickable(true);
                        setDrawableRight(R.drawable.ic_done_theme_color, R.color.light_green);
                        SnackbarUtils.displaySnackbarLongTime(_layout,
                                mContext.getResources().getString(R.string.url_available));
                    }

                    @Override
                    public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                        btnCheckUrl.setVisibility(View.GONE);
                        btnCheckUrl.setClickable(true);
                        setDrawableRight(R.drawable.ic_clear_white, R.color.red);
                        SnackbarUtils.displaySnackbarLongTime(_layout, message);
                    }
                }

        );
    }

    /**
     * Method to set Right Drawable on the edit text when the url is available or not.
     *
     * @param drawableRes Drawable resource id which need to be set.
     * @param colorRes    Color of the drawable.
     */
    private void setDrawableRight(int drawableRes, int colorRes) {
        Drawable drawable = ContextCompat.getDrawable(mContext, drawableRes);
        drawable = drawable.mutate();
        drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, colorRes),
                PorterDuff.Mode.SRC_ATOP));
        etFieldValue.setCompoundDrawablesWithIntrinsicBounds(null, null, drawable, null);
        etFieldValue.setCompoundDrawablePadding(mContext.getResources().getDimensionPixelSize(R.dimen.padding_5dp));
    }

}
