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

package com.socialengineaddons.mobileapp.classes.modules.user;


import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatTextView;
import android.text.SpannableStringBuilder;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.shimmer.ShimmerFrameLayout;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.ClusterManager;
import com.google.maps.android.clustering.view.DefaultClusterRenderer;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.MapActivity;
import com.socialengineaddons.mobileapp.classes.common.adapters.BrowseMemberAdapter;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.BaseButton;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.GridViewWithHeaderAndFooter;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;
import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static android.app.Activity.RESULT_OK;
import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.PRIVACY_POLICY_MENU_TITLE;
import static com.socialengineaddons.mobileapp.classes.core.ConstantVariables.TERMS_OF_SERVICE_MENU_TITLE;

/**
 * A simple {@link android.support.v4.app.Fragment} subclass.
 */
public class BrowseMemberFragment extends BaseFragment implements AbsListView.OnScrollListener,
        AdapterView.OnItemClickListener, View.OnClickListener {

    private String mBrowseMemberUrl;
    private View mRootView, footerView, footerViewGrid;
    private Context mContext;
    private int MAP_VIEW = 0, LIST_VIEW = 1;
    private int mLoadingPageNo = 1, mLoadingMapPageNo = 1, canAddToList = 0, isSiteMember;
    private AppConstant mAppConst;
    private ListView mMemeresListView;
    private SelectableTextView mMembersCountInfo;
    private TextView tvListViewType, tvMapViewType, tvViewMoreMembers, tvMatrixViewType;
    private View mSeparator, mMapView;
    private LinearLayout llContactInfoView;
    private float mCurrentZoom;
    private GoogleMap mMap;
    private JSONObject mBody;
    private JSONArray mResponseArray;
    private int mTotalMembers, mTotalMapMembers;
    private BrowseMemberAdapter mBrowseMemberAdapter, mMapMemberAdapter, mMatrixMemberAdapter;
    private List<BrowseListItems> mBrowseListItems, mMapBrowseListItems, mMapListItems;
    private boolean isMemberFriends = false, isContactTab = false, isSearchTab = false,
            isOutGoingTab = false, isFindFriends = false, isVisibleToUser = false,
            isMemberFollowers = false, isMemberFollowing = false, isStoryViewer = false, isFirstTab = false, isManageView, isProfileRequest;
    private int mUserId, mStoryId;
    private boolean isLoading = false;
    private HashMap<String, String> searchParams = new HashMap<>();
    private Map<String, String> mPostParams = new HashMap<>();
    private AlertDialogWithAction mAlertDialogWithAction;
    private String userTitle, mUrl, mContentId;
    private AppCompatActivity mActivity;
    private ClusterManager<MemberClusterItems> mClusterManager;
    private BitmapDescriptor bitmapDescriptor = null;
    private boolean isLocationSet = false;
    private LatLng currentLatLng = null;
    private int i = 0, itemPosition = -1;
    private Dialog quickInfoDialog;
    private FloatingActionButton myLocationButton;
    private View mapMyLocationButton, mapZoomControl;
    private int itemClickedPosition, mMemberViewType;
    private String locationTitle = "";
    private static boolean isGpsRequestDisplayed = false;
    private GridViewWithHeaderAndFooter mMemberGridView;
    private ShimmerFrameLayout mShimmerViewContainer;

    private boolean isAgreed;
    private BaseButton contactAddButton;
    private boolean inviteIntent = false;

    public BrowseMemberFragment() {
        // Required empty public constructor
    }

    @Override
    public void setNestedScrollingEnabled(boolean enabled) {

    }

    public static BrowseMemberFragment newInstance(Bundle bundle) {
        BrowseMemberFragment fragment = new BrowseMemberFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onPrepareOptionsMenu(final Menu menu) {
        super.onPrepareOptionsMenu(menu);
        MenuItem toggle = menu.findItem(R.id.viewToggle);
        if (toggle != null) {
            toggle.setVisible(false);
        }
    }

    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (visible && !isVisibleToUser && mContext != null) {
            makeRequest();
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        mContext = getContext();
        mActivity = (AppCompatActivity) getActivity();
        mAppConst = new AppConstant(mContext);
        mAlertDialogWithAction = new AlertDialogWithAction(mContext);

        mBrowseListItems = new ArrayList<>();
        mMapBrowseListItems = new ArrayList<>();
        mMapListItems = new ArrayList<>();

        Bundle bundle = getArguments();
        if (bundle != null) {
            isMemberFriends = bundle.getBoolean("isMemberFriends");
            mUserId = bundle.getInt("user_id");
            mStoryId = bundle.getInt("story_id");
            userTitle = bundle.getString(ConstantVariables.CONTENT_TITLE);
            isContactTab = bundle.getBoolean("contact_tab");
            isSearchTab = bundle.getBoolean("search_tab");
            isOutGoingTab = bundle.getBoolean("outgoing_tab");
            isFindFriends = bundle.getBoolean("isFindFriends");
            isStoryViewer = bundle.getBoolean("isStoryViewer");
            isMemberFollowers = bundle.getBoolean("isMemberFollowers");
            isMemberFollowing = bundle.getBoolean("isMemberFollowing");
            isFirstTab = getArguments().getBoolean(ConstantVariables.IS_FIRST_TAB_REQUEST);
            mUrl = bundle.getString(ConstantVariables.URL_STRING);
            try {
                mContentId = bundle.getString(ConstantVariables.CONTENT_ID, null);
            } catch (ClassCastException e) {
                mContentId = String.valueOf(bundle.getInt(ConstantVariables.CONTENT_ID, 0));
            }
            isManageView = bundle.getBoolean(ConstantVariables.IS_MANAGE_VIEW, false);
            isProfileRequest = bundle.getBoolean(ConstantVariables.IS_PROFILE_PAGE_REQUEST, false);
        }

        mBrowseMemberUrl = getMembersListUrl() + "&page=" + mLoadingPageNo;

        // Inflate the layout for this fragment
        mRootView = inflater.inflate(R.layout.fragment_browse_member, container, false);


        mShimmerViewContainer = mRootView.findViewById(R.id.shimmer_view_container);
        mRootView.findViewById(R.id.progressBar).setVisibility(View.GONE);

        footerView = CustomViews.getFooterView(inflater);
        footerViewGrid = CustomViews.getFooterView(inflater);
        mMemeresListView = (ListView) mRootView.findViewById(R.id.membersList);
        mMemberGridView = mRootView.findViewById(R.id.member_grid_View);
        tvListViewType = (TextView) mRootView.findViewById(R.id.list_view_type);
        tvMapViewType = (TextView) mRootView.findViewById(R.id.map_view_type);
        tvMatrixViewType = mRootView.findViewById(R.id.matrix_view_type);
        tvViewMoreMembers = (TextView) mRootView.findViewById(R.id.view_more);
        mMembersCountInfo = (SelectableTextView) mRootView.findViewById(R.id.memberCountInfo);
        mSeparator = mRootView.findViewById(R.id.saperator);
        mMapView = mRootView.findViewById(R.id.map_layout);
        mapMyLocationButton = ((View) mMapView.findViewById(Integer.parseInt("1")).getParent()).findViewById(Integer.parseInt("2"));
        myLocationButton = (FloatingActionButton) mRootView.findViewById(R.id.my_location_button);
        setDrawableColor(myLocationButton);
        myLocationButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mapMyLocationButton.callOnClick();
            }
        });
        tvMatrixViewType.setTag(2);
        tvListViewType.setTag(1);
        tvMapViewType.setTag(0);
        tvMatrixViewType.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        tvListViewType.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        tvMapViewType.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        tvMatrixViewType.setText("\uf0db");
        tvListViewType.setText("\uf0ca");
        tvMapViewType.setText("\uf041");

        mBrowseMemberAdapter = new BrowseMemberAdapter(mContext, R.layout.list_members,
                mBrowseListItems, isMemberFriends, BrowseMemberFragment.this, mContentId, false);


        mMatrixMemberAdapter = new BrowseMemberAdapter(mContext, R.layout.list_members_grid,
                mBrowseListItems, isMemberFriends, BrowseMemberFragment.this, null, true);


        mMapMemberAdapter = new BrowseMemberAdapter(mContext, R.layout.list_members,
                mMapBrowseListItems, isMemberFriends);

        mMemberGridView.addFooterView(footerViewGrid);
        footerViewGrid.setVisibility(View.GONE);

        CustomViews.initializeGridLayout(mContext, 2, mMemberGridView);
        ViewCompat.setNestedScrollingEnabled(mMemberGridView, true);

        // Setting horizontal and vertical padding of grid view
        mMemberGridView.setHorizontalSpacing((int) mContext.getResources().getDimension(R.dimen.padding_4dp));
        mMemberGridView.setVerticalSpacing((int) mContext.getResources().getDimension(R.dimen.padding_4dp));

        mMemeresListView.setAdapter(mBrowseMemberAdapter);
        mMemberGridView.setAdapter(mMatrixMemberAdapter);

        mMemeresListView.setOnItemClickListener(this);
        mMemeresListView.setOnScrollListener(this);
        mMemberGridView.setOnScrollListener(this);
        tvListViewType.setOnClickListener(this);
        tvMapViewType.setOnClickListener(this);
        tvViewMoreMembers.setOnClickListener(this);
        tvMatrixViewType.setOnClickListener(this);
        ViewCompat.setNestedScrollingEnabled(mMemeresListView, true);


        /**
         * isMemberFriends will be true when Friends tab will be loaded from user profile page.
         * Searching members will not be working when Friends tab will be clicked from user profile page.
         */
        if (!isMemberFriends && !isContactTab && !isSearchTab && !isOutGoingTab && !isMemberFollowers
                && !isMemberFollowing && !isStoryViewer) {
            if (getArguments() != null) {

                Bundle args = getArguments();
                Set<String> searchArgumentSet = args.keySet();
                args.remove(ConstantVariables.IS_MANAGE_VIEW);
                args.remove(ConstantVariables.IS_PROFILE_PAGE_REQUEST);
                for (String key : searchArgumentSet) {
                    String value = getArguments().getString(key);

                    if (value != null && !value.isEmpty()) {
                        searchParams.put(key, value);
                    }
                }

                if (searchParams != null && searchParams.size() != 0) {
                    mBrowseMemberUrl = mAppConst.buildQueryString(mBrowseMemberUrl, searchParams);
                }
            }
        }

        if (searchParams != null && searchParams.size() == 0) {
            setHasOptionsMenu(true);
        }
        // If it is browser member request then send the request immediately.
        if ((!isOutGoingTab && !isSearchTab && !isContactTab && !isMemberFriends
                && !isMemberFollowers && !isMemberFollowing) || isFirstTab || isFindFriends) {
            makeRequest(mBrowseMemberUrl);
        }
        return mRootView;
    }

    public void makeRequest() {
        if (isOutGoingTab) {
            loadOutGoingMember(mBrowseMemberUrl, false);
        } else {
            makeRequest(mBrowseMemberUrl);
        }
    }

    private void makeRequest(String url) {

        mLoadingPageNo = 1;
        mShimmerViewContainer.setVisibility(View.VISIBLE);
        mShimmerViewContainer.startShimmer();

        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mShimmerViewContainer.setVisibility(View.GONE);
                mShimmerViewContainer.stopShimmer();

                isVisibleToUser = true;
                mAppConst.hideProgressDialog();
                if (jsonObject != null && jsonObject.length() != 0) {
                    try {
                        mBody = jsonObject;
                        if (mMemberViewType == 0) {
                            mTotalMapMembers = mBody.optInt("totalItemCount");
                        } else {
                            mBrowseListItems.clear();
                            mTotalMembers = mBody.optInt("totalItemCount");
                        }
                        isSiteMember = mBody.optInt("isSitemember");

                        if (isMemberFriends) {
                            canAddToList = mBody.optInt("canAddToList");
                            mResponseArray = mBody.optJSONArray("friends");
                            if (!isFindFriends && userTitle != null) {
                                if (mTotalMembers != 0) {
                                    mActivity.getSupportActionBar().setTitle(
                                            String.format("%s (%d): %s", getResources().getString(
                                                    R.string.action_bar_title_friend), mTotalMembers, userTitle));
                                } else {
                                    mActivity.getSupportActionBar().setTitle(String.format("%s: %s", getResources().getString(R.string.
                                            action_bar_title_friend), userTitle));
                                }
                            }
                        } else {
                            mResponseArray = mBody.optJSONArray("response");
                        }

                        if (mMemberViewType == 0) {
                            addDataToMap(mResponseArray);
                        } else {
                            addDataToList(mResponseArray);
                        }

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mShimmerViewContainer.stopShimmer();
                SnackbarUtils.displaySnackbar(mRootView, message);
                mAppConst.hideProgressDialog();
            }
        });

    }

    /**
     * Method to add data to the list view.
     *
     * @param mResponseArray Response array
     */
    public void addDataToList(JSONArray mResponseArray) {

        isVisibleToUser = true;
        if (mResponseArray != null && mResponseArray.length() > 0) {
            setMembersCount(mTotalMembers);
            if (!isManageView) {
                mSeparator.setVisibility(View.VISIBLE);
            }
            for (int i = 0; i < mResponseArray.length(); i++) {

                JSONObject memberInfoObject = mResponseArray.optJSONObject(i);
                String displayName = memberInfoObject.optString("displayname");
                String imageUrl = memberInfoObject.optString("image_profile");
                JSONObject menusObject = memberInfoObject.optJSONObject("menus");

                int userId = memberInfoObject.optInt("user_id");
                int isVerified = memberInfoObject.optInt("isVerified");
                int isMemberVerified = memberInfoObject.optInt("is_member_verified");
                boolean isManage = memberInfoObject.has(ConstantVariables.IS_OWNER);
                boolean isOwner = memberInfoObject.optBoolean(ConstantVariables.IS_OWNER, false);
                isManage = (!isOwner && isManage);
                String friendshipType = memberInfoObject.optString("friendship_type");
                boolean isFollow = memberInfoObject.optBoolean("isFollow");
                JSONArray menusArray = new JSONArray();
                if (menusObject != null) {
                    try {
                        if (canAddToList == 1) {
                            JSONObject friendshipObject = new JSONObject();
                            friendshipObject.put("name", "friendship_type");
                            menusArray.put(friendshipObject);

                            JSONObject addToListObject = new JSONObject();
                            addToListObject.put("name", "add_to_list");
                            addToListObject.put("label", mContext.getResources().getString(R.string.add_to_list_text));
                            menusArray.put(addToListObject);

                            if (isVerified == 1) {
                                JSONObject followObject = memberInfoObject.optJSONObject("follow_unfollow_menu");
                                menusArray.put(followObject);
                            }
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                BrowseListItems browseListItems;
                if (isSiteMember == 1) {
                    int mutualFriendCount = memberInfoObject.optInt("mutualFriendCount");
                    int age = memberInfoObject.optInt("age");
                    int isMemberOnline = memberInfoObject.optInt("memberStatus");

                    String location = memberInfoObject.optString("location");

                    String city = memberInfoObject.optString("city");
                    String state = memberInfoObject.optString("state");
                    String country = memberInfoObject.optString("country");

                    if (city != null && !city.isEmpty() && state != null && !state.isEmpty() && country != null
                            && !country.isEmpty()) {

                        if (!city.equals(state)) {
                            location = city + ", " + state;
                        } else {
                            location = city;
                        }
                        location = location + ", " + country;
                    }
                    browseListItems = new BrowseListItems(isSiteMember, userId, imageUrl, displayName,
                            menusObject, mutualFriendCount, age, isMemberVerified, location, isMemberOnline,
                            canAddToList, memberInfoObject, isVerified, null, friendshipType, menusArray, isManage);
                } else {
                    browseListItems = new BrowseListItems(isSiteMember, userId, imageUrl, displayName,
                            menusObject, 0, 0, isMemberVerified, null, 0,
                            canAddToList, memberInfoObject, isVerified, null, friendshipType, menusArray, isManage);

                }
                browseListItems.setFollowingMember(isFollow);

                // Used for message.
                browseListItems.setUserId(userId);
                browseListItems.setUserDisplayName(displayName);
                browseListItems.setUserProfileImageUrl(imageUrl);
                mBrowseListItems.add(browseListItems);
            }

            if (!isOutGoingTab && !isSearchTab && !isContactTab && !isMemberFriends &&
                    !isMemberFollowers && !isMemberFollowing) {
                setBrowseType();
            }
        } else {
            showError();
        }
        mBrowseMemberAdapter.notifyDataSetChanged();
        mMatrixMemberAdapter.notifyDataSetChanged();
    }

    private void setMembersCount(int membersCount) {
        if (mContentId != null) {
            return;
        }
        mMembersCountInfo.setVisibility(View.VISIBLE);
        String membersText = mContext.getResources().getQuantityString(R.plurals.member_text,
                membersCount);
        mMembersCountInfo.setText(String.format(
                mContext.getResources().getString(R.string.browse_member_count_text_format), membersCount,
                membersText, mContext.getResources().getString(R.string.browse_member_count_text)
        ));
    }


    /**
     * Method to add data to the map view.
     *
     * @param mResponseArray Response array
     */
    public void addDataToMap(JSONArray mResponseArray) {

        if (mResponseArray != null && mResponseArray.length() > 0) {
            setMembersCount(mTotalMapMembers);
            mSeparator.setVisibility(View.VISIBLE);
            for (int i = 0; i < mResponseArray.length(); i++) {

                JSONObject memberInfoObject = mResponseArray.optJSONObject(i);
                String displayName = memberInfoObject.optString("displayname");
                String imageUrl = memberInfoObject.optString("image_profile");
                JSONObject menusObject = memberInfoObject.optJSONObject("menus");
                int userId = memberInfoObject.optInt("user_id");
                int isVerified = memberInfoObject.optInt("isVerified");
                int isMemberVerified = memberInfoObject.optInt("is_member_verified");
                JSONObject mapData = memberInfoObject.optJSONObject("mapData");
                boolean isManage = memberInfoObject.has(ConstantVariables.IS_OWNER);
                boolean isOwner = memberInfoObject.optBoolean(ConstantVariables.IS_OWNER, false);
                isManage = (!isOwner && isManage);
                String friendshipType = memberInfoObject.optString("friendship_type");
                boolean isFollow = memberInfoObject.optBoolean("isFollow");
                JSONArray menusArray = new JSONArray();
                if (menusObject != null) {
                    try {
                        if (canAddToList == 1) {
                            JSONObject friendshipObject = new JSONObject();
                            friendshipObject.put("name", "friendship_type");
                            menusArray.put(friendshipObject);

                            JSONObject addToListObject = new JSONObject();
                            addToListObject.put("name", "add_to_list");
                            addToListObject.put("label", mContext.getResources().getString(R.string.add_to_list_text));
                            menusArray.put(addToListObject);
                            if (isVerified == 1) {
                                JSONObject followObject = memberInfoObject.optJSONObject("follow_unfollow_menu");
                                menusArray.put(followObject);
                            }
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                BrowseListItems browseListItems;
                if (isSiteMember == 1) {
                    int mutualFriendCount = memberInfoObject.optInt("mutualFriendCount");
                    int age = memberInfoObject.optInt("age");
                    int isMemberOnline = memberInfoObject.optInt("memberStatus");
                    String location = memberInfoObject.optString("location");
                    browseListItems = new BrowseListItems(isSiteMember, userId, imageUrl, displayName,
                            menusObject, mutualFriendCount, age, isMemberVerified, location, isMemberOnline,
                            canAddToList, memberInfoObject, isVerified, mapData, friendshipType, menusArray, isManage);
                } else {
                    browseListItems = new BrowseListItems(isSiteMember, userId, imageUrl, displayName,
                            menusObject, 0, 0, isMemberVerified, null, 0, canAddToList, memberInfoObject,
                            isVerified, mapData, friendshipType, menusArray, isManage);
                }
                browseListItems.setFollowingMember(isFollow);

                // Used for message.
                browseListItems.setUserId(userId);
                browseListItems.setUserDisplayName(displayName);
                browseListItems.setUserProfileImageUrl(imageUrl);
                mMapListItems.add(browseListItems);
            }

            if (!isOutGoingTab && !isSearchTab && !isContactTab && !isMemberFriends &&
                    !isMemberFollowers && !isMemberFollowing) {
                if (mMap == null && mClusterManager == null) {
                    setBrowseType();
                } else {
                    setMarkersAtMemberLocations();
                }
            }
            tvViewMoreMembers.setVisibility(View.VISIBLE);
        } else {
            if (mMap == null && mClusterManager == null) {
                setBrowseType();
                setMembersCount(0);
                mSeparator.setVisibility(View.VISIBLE);
            }
            tvViewMoreMembers.setVisibility(View.GONE);
            SnackbarUtils.displaySnackbar(mRootView, mContext.getResources().getString(R.string.no_member_to_display));
        }
    }

    /**
     * Method to show error.
     */
    public void showError() {
        mRootView.findViewById(R.id.message_layout).setVisibility(View.VISIBLE);
        TextView errorIcon = (TextView) mRootView.findViewById(R.id.error_icon);
        SelectableTextView errorMessage = (SelectableTextView) mRootView.findViewById
                (R.id.error_message);
        errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        errorIcon.setText("\uf007");
        if (isOutGoingTab) {
            errorMessage.setText(mContext.getResources().getString(R.string.no_outgoing_request));
        } else if (isStoryViewer) {
            errorMessage.setText(mContext.getResources().getString(R.string.no_story_viewer));
        } else {
            errorMessage.setText(mContext.getResources().getString(R.string.no_member_to_display));
        }
    }

    @Override
    public void onScrollStateChanged(AbsListView absListView, int i) {

    }

    @Override
    public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {

        int limit = firstVisibleItem + visibleItemCount;
        String url;

        if (limit == totalItemCount && !isLoading) {

            if (limit >= AppConstant.LIMIT && (AppConstant.LIMIT * mLoadingPageNo) <
                    mTotalMembers) {
                if (mMemberViewType == 2) {
                    footerViewGrid.setVisibility(View.VISIBLE);
                } else {
                    CustomViews.addFooterView(mMemeresListView, footerView);
                }
                mLoadingPageNo += 1;

                url = getMembersListUrl() + "&page=" + mLoadingPageNo;

                isLoading = true;

                if (isOutGoingTab) {
                    loadOutGoingMember(url, true);
                } else {
                    loadMoreMembers(url, false);
                }
            }

        }
    }

    public void loadMoreMembers(String url, final boolean isRequestFromMap) {

        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mBody = jsonObject;
                if (isRequestFromMap) {
                    mAppConst.hideProgressDialog();
                }
                if (mMemberViewType == 2) {
                    footerViewGrid.setVisibility(View.GONE);
                } else {
                    CustomViews.removeFooterView(mMemeresListView, footerView);
                }
                try {
                    if (isMemberFriends)
                        mResponseArray = mBody.getJSONArray("friends");
                    else
                        mResponseArray = mBody.getJSONArray("response");
                    if (mMemberViewType == 0) {
                        addDataToMap(mResponseArray);
                    } else {
                        addDataToList(mResponseArray);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    Toast.makeText(mContext.getApplicationContext(),
                            mContext.getResources().getString(R.string.no_data_available),
                            Toast.LENGTH_LONG).show();
                }
                isLoading = false;
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                if (isRequestFromMap) {
                    mAppConst.hideProgressDialog();
                }
                SnackbarUtils.displaySnackbar(mRootView, message);
            }
        });
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mContext = context;
        if (mMemeresListView != null) {
            mMemeresListView.smoothScrollToPosition(0);
        }
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
        BrowseListItems clickedMember = mBrowseListItems.get(i);
        int userId = clickedMember.getmUserId();
        goToProfile(userId);
    }

    /**
     * Method to send out going member request on server then load the data into list.
     */
    public void loadOutGoingMember(String url, final boolean isLoadMoreRequest) {
        mPostParams.clear();
        mPostParams.put("membershipType", "cancel_request");

        // Showing shimmer effect when it is loading outgoing member request.
        if (!isLoadMoreRequest) {
            mLoadingPageNo = 1;
            mShimmerViewContainer.setVisibility(View.VISIBLE);
            mShimmerViewContainer.startShimmer();

        }
        mAppConst.postJsonResponseForUrl(url, mPostParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                // Hiding footer view when it is load more member request.
                if (isLoadMoreRequest) {
                    isLoading = false;
                    if (mMemberViewType == 2) {
                        footerViewGrid.setVisibility(View.GONE);
                    } else {
                        CustomViews.removeFooterView(mMemeresListView, footerView);
                    }
                } else {
                    mBrowseListItems.clear();
                    mShimmerViewContainer.setVisibility(View.GONE);
                    mShimmerViewContainer.stopShimmer();
                }
                mTotalMembers = jsonObject.optInt("totalItemCount");
                mResponseArray = jsonObject.optJSONArray("users");
                addDataToList(mResponseArray);
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mShimmerViewContainer.setVisibility(View.GONE);
                mShimmerViewContainer.stopShimmer();
                SnackbarUtils.displaySnackbar(mRootView, message);
            }
        });
    }

    private String getMembersListUrl() {

        String url;
        if (mUrl != null && !mUrl.isEmpty()) {
            url = mUrl + "?limit=" + AppConstant.LIMIT;
        } else if (isMemberFollowing) {
            mMemberViewType = LIST_VIEW;
            url = UrlUtil.MEMBER_FOLLOWING_URL + "resource_type=user&resource_id=" + mUserId + "&limit=" + AppConstant.LIMIT;
        } else if (isMemberFollowers) {
            url = UrlUtil.MEMBER_FOLLOWERS_URL + "resource_type=user&resource_id=" + mUserId + "&limit=" + AppConstant.LIMIT;
        } else if (isMemberFriends) {
            url = AppConstant.DEFAULT_URL + "user/get-friend-list?user_id=" + mUserId + "&limit=" + AppConstant.LIMIT;
        } else if (isOutGoingTab) {
            url = UrlUtil.MEMBERSHIP_DEFAULT_URL + "?limit=" + AppConstant.LIMIT;
        } else if (isStoryViewer) {
            url = AppConstant.DEFAULT_URL + "advancedactivity/story/get-viewer/" + mStoryId
                    + "?limit=" + AppConstant.LIMIT;
            mMemberViewType = LIST_VIEW;
        } else {
            url = AppConstant.DEFAULT_URL + "members?limit=" + AppConstant.LIMIT;
            mMemberViewType = PreferencesUtils.getMemberViewType(mContext);
        }

        // Adding Search Params in the scrolling url
        if (searchParams != null && searchParams.size() != 0) {
            url = mAppConst.buildQueryString(url, searchParams);
        }

        if (mMemberViewType == MAP_VIEW) {
            url += "&viewType=1";
        }
        if (isManageView || isProfileRequest || isMemberFriends) {
            mMemberViewType = LIST_VIEW;
        }
        return url;
    }

    private void setBrowseType() {
        if (isSiteMember == 1 && searchParams.size() == 0) {
            tvListViewType.setVisibility(View.VISIBLE);
            tvMapViewType.setVisibility(View.VISIBLE);
            tvMatrixViewType.setVisibility(View.VISIBLE);
        } else {
            tvListViewType.setVisibility(View.GONE);
            tvMapViewType.setVisibility(View.GONE);
            tvMatrixViewType.setVisibility(View.GONE);
        }
        if (mMemberViewType == 0) {
            mMapView.setVisibility(View.VISIBLE);
            mMemeresListView.setVisibility(View.GONE);
            mMemberGridView.setVisibility(View.GONE);
            setSelectedViewTypeHighlight(tvMapViewType, tvListViewType, tvMatrixViewType);
            // Do a null check to confirm that map is already instantiated or not.
            if (mMap == null) {
                // Try to obtain the map from the SupportMapFragment.
                ((SupportMapFragment) getChildFragmentManager().findFragmentById(R.id.map))
                        .getMapAsync(new OnMapReadyCallback() {
                            @Override
                            public void onMapReady(GoogleMap googleMap) {
                                mMap = googleMap;
                                // Check if successful obtained the map.
                                if (mMap != null) {
                                    setUpMap();
                                }
                            }
                        });

            } else {
                setUpMap();
            }
        } else if (mMemberViewType == 2) {
            setSelectedViewTypeHighlight(tvMatrixViewType, tvListViewType, tvMapViewType);
            mMemberGridView.setVisibility(View.VISIBLE);
            mMemeresListView.setVisibility(View.GONE);
            mMapView.setVisibility(View.GONE);
            mMatrixMemberAdapter.notifyDataSetChanged();

        } else {
            mMemeresListView.setVisibility(View.VISIBLE);
            setSelectedViewTypeHighlight(tvListViewType, tvMapViewType, tvMatrixViewType);
            mMapView.setVisibility(View.GONE);
            mMemberGridView.setVisibility(View.GONE);
            mBrowseMemberAdapter.notifyDataSetChanged();
        }
    }

    /**
     * Method to set selected view type highlighted.
     *
     * @param tvSelected     TextView which needs to be show highlighted.
     * @param tvNormalFirst  TextView which is not selected right now.
     * @param tvNormalSecond TextView which is not selected right now.
     */
    private void setSelectedViewTypeHighlight(TextView tvSelected, TextView tvNormalFirst, TextView tvNormalSecond) {
        tvSelected.setTextColor(ContextCompat.getColor(mContext, R.color.themeButtonColor));
        tvNormalFirst.setTextColor(ContextCompat.getColor(mContext, R.color.body_text_2));
        tvNormalSecond.setTextColor(ContextCompat.getColor(mContext, R.color.body_text_2));
    }

    /**
     * Method to set up the map by checking the required permission.
     */
    private void setUpMap() {
        mMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
        // Initialize the manager with the context and the map.
        mClusterManager = new ClusterManager<>(mContext, mMap);

        // Setting up the ClusterManager as onMarkerClickListener to make the the cluster item clickable.
        mMap.setOnMarkerClickListener(mClusterManager);
        mMap.setOnCameraIdleListener(mClusterManager);
        mMap.setOnCameraIdleListener(new GoogleMap.OnCameraIdleListener() {
            @Override
            public void onCameraIdle() {
                mClusterManager.onCameraIdle();
                mCurrentZoom = mMap.getCameraPosition().zoom;
            }
        });

        // Setting up the renderer for the cluster manager.
        mClusterManager.setRenderer(new DefaultClusterRenderer<MemberClusterItems>(mContext, mMap, mClusterManager) {
            @Override
            protected boolean shouldRenderAsCluster(Cluster cluster) {
                return cluster.getSize() > 1 && mCurrentZoom < 19;
            }

            @Override
            protected void onBeforeClusterItemRendered(MemberClusterItems item, MarkerOptions markerOptions) {
                markerOptions.icon(item.getBitmapDescriptor());
            }
        });

        // Applying the click listener on the each item of the Cluster. (Each marker clickable)
        mClusterManager.setOnClusterItemClickListener(new ClusterManager.OnClusterItemClickListener<MemberClusterItems>() {
            @Override
            public boolean onClusterItemClick(MemberClusterItems memberClusterItems) {
                if (memberClusterItems.getResponseObject() != null) {
                    BrowseListItems listItem = memberClusterItems.getBrowseListItem();
                    showQuickInfo(listItem);
                    mMapBrowseListItems.clear();
                    mMapBrowseListItems.add(memberClusterItems.getBrowseListItem());

                }
                return true;
            }
        });

        setMarkersAtMemberLocations();
        if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        mMap.setMyLocationEnabled(true);
        mMap.getUiSettings().setMyLocationButtonEnabled(true);
        mapMyLocationButton.setVisibility(View.GONE);
        setZoomControlUI();
    }

    /**
     * Method to set members as marker at the specified locations.
     */
    private void setMarkersAtMemberLocations() {

        mMap.clear();
        mClusterManager.clearItems();
        try {
            JSONObject userDetail = (PreferencesUtils.getUserDetail(mContext) != null) ? new JSONObject(PreferencesUtils.getUserDetail(mContext)) : null;

            /* Check the double value is valid or not before generating Lat Lng */
            if (userDetail != null && !Double.isNaN(userDetail.optDouble(PreferencesUtils.USER_LOCATION_LATITUDE))
                    && !Double.isNaN(userDetail.optDouble(PreferencesUtils.USER_LOCATION_LONGITUDE))
                    && userDetail.optDouble(PreferencesUtils.USER_LOCATION_LATITUDE) != 0
                    && userDetail.optDouble(PreferencesUtils.USER_LOCATION_LONGITUDE) != 0) {
                currentLatLng = new LatLng(userDetail.optDouble(PreferencesUtils.USER_LOCATION_LATITUDE),
                        userDetail.optDouble(PreferencesUtils.USER_LOCATION_LONGITUDE));

                locationTitle = PreferencesUtils.getDefaultLocation(mContext);

            }

            /* Display my location button if user already set device location
                or Enabled device gps*/
            if (GlobalFunctions.isLocationEnabled(mContext)) {
                myLocationButton.setVisibility(View.VISIBLE);
            } else if (locationTitle != null && locationTitle.isEmpty()) {
                if (!isGpsRequestDisplayed && AppConstant.mLocationType != null && AppConstant.mLocationType.equals("notspecific")
                        && AppConstant.isDeviceLocationEnable == 1) {
                    if (!mAppConst.checkManifestPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
                        if (!PreferencesUtils.isLocationPermissionDisplayedOnMap(mContext)) {
                            PreferencesUtils.setLocationPermissionDisplayedOnMap(mContext);
                            mAppConst.requestForManifestPermission(Manifest.permission.ACCESS_FINE_LOCATION,
                                    ConstantVariables.ACCESS_FINE_LOCATION);
                        }
                    } else {
                        isGpsRequestDisplayed = true;
                        GlobalFunctions.requestForDeviceLocation(mContext);
                    }
                }
                myLocationButton.setVisibility(View.GONE);
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }

        if (mMapListItems != null && mMapListItems.size() > 0) {
            for (i = 0; i < mMapListItems.size(); i++) {
                final BrowseListItems browseListItems = mMapListItems.get(i);
                final JSONObject memberInfoObject = browseListItems.getResponseObject();

                if (memberInfoObject.has("latitude") && memberInfoObject.has("longitude")) {
                    double lat = memberInfoObject.optDouble("latitude");
                    double lng = memberInfoObject.optDouble("longitude");
                    double offset = i / 60000d;
                    lat = lat + offset;
                    lng = lng + offset;

                    LatLng itemLatLng = new LatLng(lat, lng);
                    itemLatLng = (currentLatLng != null && !isSearchTab) ? currentLatLng : itemLatLng;

                    if (!isLocationSet && itemLatLng != null) {
                        if (currentLatLng != null) {
                            mMap.addMarker(new MarkerOptions().position(currentLatLng).title(locationTitle));
                        }
                        mMap.moveCamera(CameraUpdateFactory.newLatLng(itemLatLng));
                        isLocationSet = true;
                    }

                    // Showing color of the marker as it is coming from the api response.
                    try {
                        final ImageView img = new ImageView(mContext);
                        final double finalLat = lat;
                        final double finalLng = lng;
                        Picasso.get().load(browseListItems.getmBrowseImgUrl()).resize(90, 90).
                                into(img, new Callback() {
                                    @Override
                                    public void onSuccess() {
                                        img.setDrawingCacheEnabled(false);
                                        BitmapDrawable drawable = (BitmapDrawable) img.getDrawable();
                                        Bitmap bitmap = drawable.getBitmap();
                                        bitmapDescriptor = BitmapDescriptorFactory.fromBitmap(getCircularBitmap(bitmap));
                                        // Adding the members position into Cluster item.
                                        MemberClusterItems memberClusterItems = new MemberClusterItems(finalLat, finalLng, bitmapDescriptor, memberInfoObject, browseListItems);
                                        mClusterManager.addItem(memberClusterItems);
                                        mClusterManager.cluster();
                                    }

                                    @Override
                                    public void onError(Exception e) {

                                    }
                                }
                    );
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }

        if (!isLocationSet && currentLatLng != null && !isSearchTab) {
            mMap.addMarker(new MarkerOptions().position(currentLatLng).title(locationTitle));
            mMap.moveCamera(CameraUpdateFactory.newLatLng(currentLatLng));
            isLocationSet = true;
        }

        // Zoom in the Google Map
        mMap.animateCamera(CameraUpdateFactory.zoomTo(6));
        mClusterManager.cluster();
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.list_view_type:
            case R.id.map_view_type:
                if (mMemberViewType != (int) v.getTag()) {
                    PreferencesUtils.updateMemberViewType(mContext, (int) v.getTag());
                    mMemberViewType = PreferencesUtils.getMemberViewType(mContext);
                    isLocationSet = false;

                    if (mMemberViewType == 0 && (mMapListItems != null && mMapListItems.size() == 0) ||
                            (mBrowseListItems != null && mBrowseListItems.size() == 0)) {
                        mAppConst.showProgressDialog();
                        makeRequest(getMembersListUrl());
                    } else {
                        setBrowseType();
                    }
                }
                if (mMemberViewType == 0) {
                    setMembersCount(mTotalMapMembers);
                } else {
                    setMembersCount(mTotalMembers);
                }
                break;
            case R.id.matrix_view_type:
                mMemberViewType = (int) v.getTag();
                PreferencesUtils.updateMemberViewType(mContext, (int) v.getTag());
                if (mBrowseListItems != null && mBrowseListItems.size() == 0) {
                    mAppConst.showProgressDialog();
                    makeRequest(getMembersListUrl());
                } else {
                    setBrowseType();
                }
                setMembersCount(mTotalMembers);
                break;
            case R.id.profile_image:
            case R.id.user_title:
                goToProfile(Integer.parseInt(String.valueOf(v.getTag())));
                break;
            case R.id.view_more:
                readyToViewMore(mTotalMapMembers);
                break;
            case R.id.friendship_action:
            case R.id.friendship_text:
                performLinkAction(itemPosition);
                break;
            case R.id.user_location:
                openInMap(itemPosition);
                break;
            default:
                if ((AppConstant.LIMIT * mLoadingPageNo) < mTotalMembers) {
                    if (mMemberViewType == 2) {
                        footerViewGrid.setVisibility(View.VISIBLE);
                    } else {
                        CustomViews.addFooterView(mMemeresListView, footerView);
                    }
                    mLoadingPageNo += 1;

                    String url = getMembersListUrl() + "&page=" + mLoadingPageNo;

                    isLoading = true;

                    mAppConst.showProgressDialog();
                    loadMoreMembers(url, true);
                } else {
                    SnackbarUtils.displaySnackbar(mRootView, mContext.getResources().getString(R.string.no_more_member_to_display));
                }
                break;
        }
    }

    private void openInMap(int itemPosition) {
        BrowseListItems listItem = mMapListItems.get(itemPosition);
        if (GlobalFunctions.isMapAppEnabled(mContext)) {
            Uri mapUri = Uri.parse("geo:0,0?q=" + Uri.encode(listItem.getmLocation()));
            Intent mapIntent = new Intent(Intent.ACTION_VIEW, mapUri);
            mapIntent.setPackage("com.google.android.apps.maps");
            startActivity(mapIntent);
        } else {
            Intent mapIntent = new Intent(mContext, MapActivity.class);
            mapIntent.putExtra("location", listItem.getmLocation());
            startActivity(mapIntent);
            ((Activity) mContext).overridePendingTransition(R.anim.slide_up_in, R.anim.push_up_out);

        }
    }

    private void readyToViewMore(int mTotal) {
        if ((AppConstant.LIMIT * mLoadingMapPageNo) < mTotal) {

            CustomViews.addFooterView(mMemeresListView, footerView);
            mLoadingMapPageNo += 1;

            String url = getMembersListUrl() + "&page=" + mLoadingMapPageNo;

            isLoading = true;

            mAppConst.showProgressDialog();
            loadMoreMembers(url, true);
        } else {
            SnackbarUtils.displaySnackbar(mRootView, mContext.getResources().getString(R.string.no_more_member_to_display));
        }
    }

    public void showQuickInfo(BrowseListItems listItem) {
        TextView txtclose, userTitle, userLocation;
        TextView rv_count, rv_text, af_count, af_text, ff_count, ff_text;
        ImageView userThumb;
        quickInfoDialog = new Dialog(mContext);
        quickInfoDialog.setContentView(R.layout.user_quick_info_view);
        itemPosition = mMapListItems.indexOf(listItem);
        txtclose = (TextView) quickInfoDialog.findViewById(R.id.txtclose);
        txtclose.setText("x");
        userTitle = (TextView) quickInfoDialog.findViewById(R.id.user_title);
        userTitle.setTag(listItem.getmUserId());
        userTitle.setOnClickListener(this);
        userLocation = (TextView) quickInfoDialog.findViewById(R.id.user_location);
        userThumb = (ImageView) quickInfoDialog.findViewById(R.id.profile_image);
        userThumb.setTag(listItem.getmUserId());
        userTitle.setText(listItem.getmBrowseListOwnerTitle());
        if (listItem.getIsMemberVerified() == 0) {
            userTitle.setCompoundDrawablesWithIntrinsicBounds(0, 0, R.drawable.ic_verification, 0);
        }
        userLocation.setOnClickListener(this);
        userLocation.setText(listItem.getmLocation());
        userThumb.setOnClickListener(this);
        Picasso.get()
                .load(listItem.getmBrowseImgUrl())
                .into(userThumb);
        txtclose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                quickInfoDialog.dismiss();
            }
        });
        JSONObject mapData = listItem.mMapData;
        if (mapData != null) {
            rv_count = (TextView) quickInfoDialog.findViewById(R.id.rv_count);
            rv_count.setText(mapData.optString("rv_count"));
            LinearLayout friendshipView = quickInfoDialog.findViewById(R.id.friendship_view);
            af_count = (TextView) quickInfoDialog.findViewById(R.id.friendship_action);
            af_text = (TextView) quickInfoDialog.findViewById(R.id.friendship_text);
            af_count.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            final JSONObject menuArray = listItem.getmMemberMenus();
            if (!mAppConst.isLoggedOutUser() && menuArray != null) {
                friendshipView.setVisibility(View.VISIBLE);
                setMenuName(af_count, menuArray);
                af_count.setOnClickListener(this);
                af_text.setOnClickListener(this);
                af_text.setText(menuArray.optString("label"));
            } else {
                friendshipView.setVisibility(View.GONE);
            }
            ff_count = (TextView) quickInfoDialog.findViewById(R.id.ff_count);
            ff_count.setText(mapData.optString("ff_count"));
            rv_text = (TextView) quickInfoDialog.findViewById(R.id.rv_text);
            rv_text.setText(mapData.optString("rv_text"));
            ff_text = (TextView) quickInfoDialog.findViewById(R.id.ff_text);
            ff_text.setText(mapData.optString("ff_text"));
        }
        Window window = quickInfoDialog.getWindow();
        WindowManager.LayoutParams wlp = window.getAttributes();

        wlp.gravity = Gravity.BOTTOM;
        wlp.flags &= ~WindowManager.LayoutParams.FLAG_DIM_BEHIND;
        window.getAttributes().windowAnimations = R.style.DialogSlideAnimation;
        window.setAttributes(wlp);
        window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        quickInfoDialog.show();
    }

    private void setMenuName(TextView af_count, @NonNull JSONObject menuArray) {
        String menuName = menuArray.optString("name");
        if (menuName != null) {
            switch (menuName) {
                case "add_friend":
                case "accept_request":
                case "member_follow":
                case "follow":
                    af_count.setCompoundDrawablesWithIntrinsicBounds(mContext.getResources().getDrawable(R.drawable.ic_friend_request), null, null, null);
                    break;
                case "remove_friend":
                case "member_unfollow":
                case "unfollow":
                case "following":
                    af_count.setCompoundDrawablesWithIntrinsicBounds(mContext.getResources().getDrawable(R.drawable.ic_user_remove), null, null, null);
                    break;
                case "cancel_request":
                case "cancel_follow":
                    af_count.setCompoundDrawablesWithIntrinsicBounds(mContext.getResources().getDrawable(R.drawable.ic_user_cancel), null, null, null);
                    break;
            }
        }
    }

    private Bitmap getCircularBitmap(Bitmap bitmap) {
        Bitmap output;

        if (bitmap.getWidth() > bitmap.getHeight()) {
            output = Bitmap.createBitmap(bitmap.getHeight(), bitmap.getHeight(), Bitmap.Config.ARGB_8888);
        } else {
            output = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getWidth(), Bitmap.Config.ARGB_8888);
        }

        Canvas canvas = new Canvas(output);

        final int color = mContext.getResources().getColor(R.color.grey_dark);
        final Paint paint = new Paint();
        final Rect rect = new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight());

        float r = 0;

        if (bitmap.getWidth() > bitmap.getHeight()) {
            r = bitmap.getHeight() / 2;
        } else {
            r = bitmap.getWidth() / 2;
        }

        paint.setAntiAlias(true);
        canvas.drawARGB(0, 0, 0, 0);
        paint.setColor(color);
        canvas.drawCircle(r, r, r, paint);
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(bitmap, rect, rect, paint);
        return output;
    }


    public void goToProfile(int userId) {

        if (mAppConst.isLoggedOutUser()){
            Log.v("clickLogs","logged out user token: "+PreferencesUtils.
                    getUserPreferences(mContext).getString("oauth_token", null));
            SnackbarUtils.displaySnackbarLongTime(mRootView,getResources().getString(R.string.user_does_not_have_access_resources));
        }
        else {
            Log.v("clickLogs","token: "+PreferencesUtils.
                    getUserPreferences(mContext).getString("oauth_token", null));
            Intent userIntent = new Intent(mContext, userProfile.class);
            userIntent.putExtra("user_id", userId);
            ((Activity) mContext).startActivityForResult(userIntent, ConstantVariables.USER_PROFILE_CODE);
            ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }

    }

    public void performLinkAction(final int itemPosition) {

        String dialogueMessage = null, dialogueTitle = null, buttonTitle = null, successMessage = null;
        String changedMenuName = null, changedMenuUrl = null, changedMenuLabel = null;
        final Map<String, String> postParams = new HashMap<>();
        final BrowseListItems memberList = mMapListItems.get(itemPosition);
        final JSONObject menuArray = memberList.getmMemberMenus();

        if (menuArray != null) {
            final String menuName = menuArray.optString("name");

            final String url = AppConstant.DEFAULT_URL + menuArray.optString("url");
            JSONObject urlParamsJsonObject = menuArray.optJSONObject("urlParams");
            if (urlParamsJsonObject != null && urlParamsJsonObject.length() != 0) {
                JSONArray urlParamsNames = urlParamsJsonObject.names();
                for (int i = 0; i < urlParamsJsonObject.length(); i++) {

                    String name = urlParamsNames.optString(i);
                    String value = urlParamsJsonObject.optString(name);
                    postParams.put(name, value);
                }
            }

            switch (menuName) {
                case "add_friend":
                    dialogueMessage = mContext.getResources().getString(R.string.add_friend_message);
                    dialogueTitle = mContext.getResources().getString(R.string.add_friend_title);
                    buttonTitle = mContext.getResources().getString(R.string.add_friend_button);
                    successMessage = mContext.getResources().getString(R.string.add_friend_success_message);
                    if (memberList.getIsFriendshipVerified() == 1) {
                        changedMenuUrl = "user/cancel";
                        changedMenuName = "cancel_request";
                        changedMenuLabel = mContext.getResources().getString(R.string.cancel_request_button);
                    } else {
                        changedMenuUrl = "user/remove";
                        changedMenuName = "remove_friend";
                        changedMenuLabel = mContext.getResources().getString(R.string.remove_friend_button);
                    }
                    break;
                case "member_follow":
                case "follow":
                    dialogueMessage = mContext.getResources().getString(R.string.add_friend_message);
                    dialogueTitle = mContext.getResources().getString(R.string.add_friend_title);
                    buttonTitle = mContext.getResources().getString(R.string.add_friend_button);
                    successMessage = mContext.getResources().getString(R.string.add_friend_success_message);
                    changedMenuLabel = mContext.getResources().getString(R.string.unfollow);
                    if (memberList.getIsFriendshipVerified() == 1) {
                        changedMenuUrl = "user/cancel";
                        changedMenuName = "cancel_follow";
                    } else {
                        changedMenuUrl = "user/remove";
                        changedMenuName = "member_unfollow";
                    }
                    break;
                case "accept_request":
                    dialogueMessage = mContext.getResources().getString(R.string.accept_friend_request_message);
                    dialogueTitle = mContext.getResources().getString(R.string.accept_friend_request_title);
                    buttonTitle = mContext.getResources().getString(R.string.accept_friend_request_button);
                    successMessage = mContext.getResources().getString(R.string.accept_friend_request_success_message);
                    changedMenuLabel = mContext.getResources().getString(R.string.remove_friend_button);
                    changedMenuName = "remove_friend";
                    changedMenuUrl = "user/remove";
                    break;
                case "remove_friend":
                case "member_unfollow":
                case "unfollow":
                case "following":
                    dialogueMessage = mContext.getResources().getString(R.string.remove_friend_message);
                    dialogueTitle = mContext.getResources().getString(R.string.remove_friend_title);
                    buttonTitle = mContext.getResources().getString(R.string.remove_friend_button);
                    successMessage = mContext.getResources().getString(R.string.remove_friend_success_message);
                    changedMenuUrl = "user/add";
                    if (menuName.equals("member_unfollow")) {
                        changedMenuName = "member_follow";
                        changedMenuLabel = mContext.getResources().getString(R.string.follow);
                    } else {
                        changedMenuName = "add_friend";
                        changedMenuLabel = mContext.getResources().getString(R.string.add_friend_button);
                    }
                    break;
                case "cancel_request":
                case "cancel_follow":
                    dialogueMessage = mContext.getResources().getString(R.string.cancel_friend_request_message);
                    dialogueTitle = mContext.getResources().getString(R.string.cancel_friend_request_title);
                    buttonTitle = mContext.getResources().getString(R.string.cancel_request_button);
                    successMessage = mContext.getResources().getString(R.string.cancel_friend_request_success_message);
                    changedMenuUrl = "user/add";
                    if (menuName.equals("cancel_follow")) {
                        changedMenuName = "member_follow";
                        changedMenuLabel = mContext.getResources().getString(R.string.follow);
                    } else {
                        changedMenuName = "add_friend";
                        changedMenuLabel = mContext.getResources().getString(R.string.add_friend_button);
                    }
                    break;
            }

            AlertDialog.Builder alertBuilder = new AlertDialog.Builder(mContext);

            alertBuilder.setMessage(dialogueMessage);
            alertBuilder.setTitle(dialogueTitle);

            final String finalSuccessMessage = successMessage;
            final String finalChangedMenuName = changedMenuName;
            final String finalChangedMenuUrl = changedMenuUrl;
            final String finalChangedMenuLabel = changedMenuLabel;
            alertBuilder.setPositiveButton(buttonTitle, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    mAppConst.showProgressDialog();
                    mAppConst.postJsonResponseForUrl(url, postParams, new OnResponseListener() {
                        @Override
                        public void onTaskCompleted(JSONObject jsonObject) {

                            View view = ((Activity) mContext).getCurrentFocus();
                            try {
                                menuArray.put("name", finalChangedMenuName);
                                menuArray.put("url", finalChangedMenuUrl);
                                menuArray.put("label", finalChangedMenuLabel);
                                memberList.setmMemberMenus(menuArray);
                                memberList.setCanAddToList(0);
                                mMapListItems.set(itemPosition, memberList);
                                mAppConst.hideProgressDialog();
                                quickInfoDialog.dismiss();
                                showQuickInfo(memberList);
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                            View view = ((Activity) mContext).getCurrentFocus();
                            SnackbarUtils.displaySnackbar(view, message);
                            mAppConst.hideProgressDialog();
                        }
                    });
                }
            });
            alertBuilder.setNegativeButton(mContext.getResources().getString(R.string.cancel),
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            try {
                                menuArray.put("name", menuName);
                                memberList.setmMemberMenus(menuArray);
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            dialog.cancel();
                        }
                    });
            alertBuilder.create().show();
        }

    }

    public void setZoomControlUI() {
        mMap.getUiSettings().setZoomControlsEnabled(true);
        // Find map fragment
        SupportMapFragment mapFragment = ((SupportMapFragment) getChildFragmentManager().findFragmentById(R.id.map));

        // Find ZoomControl view
        View zoomControls = mapFragment.getView().findViewById(0x1);

        if (zoomControls != null && zoomControls.getLayoutParams() instanceof RelativeLayout.LayoutParams) {
            // ZoomControl is inside of RelativeLayout
            RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) zoomControls.getLayoutParams();

            // Align it to - parent top|left
            params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
            params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);

            // Update margins, set to 10dp
            final int margin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10,
                    getResources().getDisplayMetrics());
            params.setMargins(margin, margin, margin, margin);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == ConstantVariables.USER_PROFILE_CODE) {
            if (resultCode != RESULT_OK) {
                makeRequest();
            }
        }
    }

    private void setDrawableColor(FloatingActionButton actionButton) {
        //get the drawable
        Drawable buttonSrc = mContext.getResources().getDrawable(R.drawable.ic_gps_fixed_24dp);
        //copy it in a new one
        Drawable drawable = buttonSrc.getConstantState().newDrawable();
        //set the color filter, you can use also Mode.SRC_ATOP
        drawable.mutate().setColorFilter(mContext.getResources().getColor(R.color.colorPrimary), PorterDuff.Mode.MULTIPLY);
        //set it to your fab button initialized before
        actionButton.setImageDrawable(drawable);
    }
}
