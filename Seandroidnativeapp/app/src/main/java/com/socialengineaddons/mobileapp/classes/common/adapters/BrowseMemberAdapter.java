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

package com.socialengineaddons.mobileapp.classes.common.adapters;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.support.v4.app.ActivityOptionsCompat;
import android.support.v4.content.ContextCompat;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnMenuClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.CurrencyUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.GutterMenuUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.user.BrowseMemberFragment;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class BrowseMemberAdapter extends ArrayAdapter<BrowseListItems> implements OnMenuClickResponseListener {

    public static int sFriendId;
    private Context mContext;
    private int mLayoutResID;
    private List<BrowseListItems> mBrowseItemlist;
    private AppConstant mAppConst;
    private View mRootView;
    private BrowseListItems listItems;
    private Typeface fontIcon;
    private int mItemPosition;
    private boolean mIsMemberFriends, mIsMemberGrid;
    private ImageLoader mImageLoader;
    private BrowseMemberFragment mBrowseMemberFragment;
    private String mContentId;
    private GutterMenuUtils mGutterMenuUtils;


    public BrowseMemberAdapter(Context context, int layoutResourceID, List<BrowseListItems> listItem,
                               boolean isMemberFriends) {

        super(context, layoutResourceID, listItem);

        mContext = context;
        mLayoutResID = layoutResourceID;
        mBrowseItemlist = listItem;
        mAppConst = new AppConstant(context);

        mIsMemberFriends = isMemberFriends;
        fontIcon = GlobalFunctions.getFontIconTypeFace(mContext);
        mImageLoader = new ImageLoader(mContext);
        mGutterMenuUtils = new GutterMenuUtils(context);
        mGutterMenuUtils.setOnMenuClickResponseListener(this);
    }

    public BrowseMemberAdapter(Context context, int layoutResourceID, List<BrowseListItems> listItem,
                               boolean isMemberFriends, BrowseMemberFragment browseMemberFragment, String contentId, boolean isMemeberGrid) {

        super(context, layoutResourceID, listItem);

        mContext = context;
        mLayoutResID = layoutResourceID;
        mBrowseItemlist = listItem;
        mAppConst = new AppConstant(context);

        mIsMemberFriends = isMemberFriends;

        fontIcon = GlobalFunctions.getFontIconTypeFace(mContext);
        mImageLoader = new ImageLoader(mContext);
        mBrowseMemberFragment = browseMemberFragment;
        mIsMemberGrid = isMemeberGrid;
        mContentId = contentId;
        mGutterMenuUtils = new GutterMenuUtils(context);
        mGutterMenuUtils.setOnMenuClickResponseListener(this);
    }


    public View getView(final int position, final View convertView, ViewGroup parent) {

        mRootView = convertView;
        final ListItemHolder listItemHolder;
        listItems = this.mBrowseItemlist.get(position);

        if (mRootView == null) {
            LayoutInflater inflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            listItemHolder = new ListItemHolder();
            mRootView = inflater.inflate(mLayoutResID, parent, false);
            if (mIsMemberGrid) {
                listItemHolder.mOwnerName = mRootView.findViewById(R.id.ownerTitle);
                listItemHolder.mAddFriend = mRootView.findViewById(R.id.addFriend);
                listItemHolder.mListImage = mRootView.findViewById(R.id.ownerImage);
                listItemHolder.mLocation = (TextView) mRootView.findViewById(R.id.location);
                listItemHolder.mMutualFriendCount = (TextView) mRootView.findViewById(R.id.mutualFriendCount);
                listItemHolder.mMemberOnlineIcon = (ImageView) mRootView.findViewById(R.id.online_icon);

                mRootView.setTag(listItemHolder);

            } else {
                listItemHolder.mOwnerName = (TextView) mRootView.findViewById(R.id.ownerTitle);
                listItemHolder.mMemberOptions = (TextView) mRootView.findViewById(R.id.memberOption);
                listItemHolder.mMemberOptions.setTypeface(fontIcon);
                listItemHolder.mMemberOptions.setMovementMethod(LinkMovementMethod.getInstance());
                listItemHolder.mListImage = (ImageView) mRootView.findViewById(R.id.ownerImage);
                listItemHolder.mAge = (TextView) mRootView.findViewById(R.id.age);
                listItemHolder.mLocation = (TextView) mRootView.findViewById(R.id.location);
                listItemHolder.mMutualFriendCount = (TextView) mRootView.findViewById(R.id.mutualFriendCount);
                listItemHolder.mMemberOnlineIcon = (ImageView) mRootView.findViewById(R.id.online_icon);
                listItemHolder.ivMessage = mRootView.findViewById(R.id.message_icon);
                listItemHolder.processingRequest = mRootView.findViewById(R.id.processing_request_pbr);
                listItemHolder.menuOption = mRootView.findViewById(R.id.option_icon_layout);
                listItemHolder.menuOption.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp),
                        mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp),
                        mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp),
                        mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp));
                mRootView.setTag(listItemHolder);
                listItemHolder.manageMember = (TextView) mRootView.findViewById(R.id.manage_member);
                Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_indeterminate_check_box);
                drawable.setColorFilter(ContextCompat.getColor(mContext, R.color.colorPrimary), PorterDuff.Mode.SRC_ATOP);
                listItemHolder.manageMember.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
                listItemHolder.manageMember.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        manageMember(UrlUtil.CROWD_FUNDING_REMOVE_LEADER_URL + mContentId, String.valueOf(listItemHolder.mUserId),
                                mContext.getResources().getString(R.string.remove_leader_alert_message),
                                mContext.getResources().getString(R.string.removed_leader_success_message));
                    }
                });
                if (!listItems.isManageView) {
                    listItemHolder.manageMember.setVisibility(View.GONE);
                } else {
                    listItemHolder.manageMember.setVisibility(View.VISIBLE);
                }
            }
        } else {
            listItemHolder = (ListItemHolder) mRootView.getTag();
        }

        if (!mIsMemberGrid) {
            listItemHolder.mMemberOptions.setGravity(Gravity.CENTER_VERTICAL);
            listItemHolder.mMemberOptions.setTag(position);
            listItemHolder.menuOption.setTag(position);
            listItemHolder.ivMessage.setTag(position);
        }


        listItemHolder.mUserId = listItems.getmUserId();
        listItemHolder.profileImage = listItems.getmBrowseImgUrl();

        /*
        Set Data in the List View Items
         */
        mImageLoader.setImageForUserProfile(listItems.getmBrowseImgUrl(), listItemHolder.mListImage);

        listItemHolder.mListImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                redirectToUserProfilePage(listItemHolder.mUserId, view, listItemHolder.profileImage);
            }
        });

        listItemHolder.mOwnerName.setText(listItems.getmBrowseListOwnerTitle());
        listItemHolder.mOwnerName.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                redirectToUserProfilePage(listItemHolder.mUserId, listItemHolder.mListImage, listItemHolder.profileImage);
            }
        });

        // Adding verification icon.
        if (listItems.getIsMemberVerified() == 1) {
            listItemHolder.mMemberOnlineIcon.setVisibility(View.VISIBLE);
        } else {
            listItemHolder.mMemberOnlineIcon.setVisibility(View.GONE);
        }

        if (mIsMemberGrid) {

            listItemHolder.mAddFriend.setTag(position);
            // Checking condition for AdvancedMember and show data accordingly.
            if (listItems.getmIsSiteMember() == 1) {

                //Showing location if exists
                if (listItems.getmLocation() != null && !listItems.getmLocation().isEmpty()) {
                    listItemHolder.mLocation.setVisibility(View.VISIBLE);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        listItemHolder.mLocation.setText(Html.fromHtml(listItems.getmLocation(), Html.FROM_HTML_MODE_LEGACY));
                    } else {
                        listItemHolder.mLocation.setText(Html.fromHtml(listItems.getmLocation()));
                    }
                } else {
                    listItemHolder.mLocation.setVisibility(View.GONE);
                }

                // Showing mutual friend count of the member if exists.
                if (listItems.getmMutualFriendCount() >= 1) {
                    listItemHolder.mMutualFriendCount.setVisibility(View.VISIBLE);
                    listItemHolder.mMutualFriendCount.setText(mContext.getResources().
                            getQuantityString(R.plurals.mutual_friend_text,
                                    listItems.getmMutualFriendCount(),
                                    listItems.getmMutualFriendCount()));
                } else {
                    listItemHolder.mMutualFriendCount.setVisibility(View.GONE);
                }

                //Showing online icon if the member is online.
                if (listItems.getmIsMemberOnline() == 1) {
                    Drawable onlineDrawable = ContextCompat.getDrawable(mContext, R.drawable.bg_dot);
                    onlineDrawable.setColorFilter(ContextCompat.getColor(mContext, R.color.light_green),
                            PorterDuff.Mode.SRC_ATOP);
                    onlineDrawable.setBounds(0, 0, mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp),
                            mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp));
                    listItemHolder.mOwnerName.setCompoundDrawables(null, null, onlineDrawable, null);

                } else {
                    listItemHolder.mOwnerName.setCompoundDrawables(null, null, null, null);
                }

            } else {
                listItemHolder.mLocation.setVisibility(View.GONE);
                listItemHolder.mMutualFriendCount.setVisibility(View.GONE);
            }

            listItemHolder.menuJsonArray = listItems.getmMemberMenus();

            if (listItemHolder.menuJsonArray == null) {
                listItemHolder.mAddFriend.setVisibility(View.INVISIBLE);
            } else {
                listItemHolder.mAddFriend.setVisibility(View.VISIBLE);
                String menuName = listItemHolder.menuJsonArray.optString("name");
                if (menuName != null) {
                    switch (menuName) {
                        case "add_friend":
                        case "accept_request":
                        case "member_follow":
                            listItemHolder.mAddFriend.setText(mContext.getResources().getString(R.string.add_friend_button));
                            break;
                        case "remove_friend":
                        case "member_unfollow":
                            listItemHolder.mAddFriend.setText(mContext.getResources().getString(R.string.remove_friend_button));
                            break;
                        case "cancel_request":
                        case "cancel_follow":
                            listItemHolder.mAddFriend.setText(mContext.getResources().getString(R.string.cancel_request_button));
                            break;
                    }
                }
            }

            listItemHolder.mAddFriend.setOnClickListener(new View.OnClickListener() {

                @Override
                public void onClick(View v) {
                    /**
                     * Apply animation on member option icon
                     */
                    Animation zoomInAnimation = AnimationUtils.loadAnimation(mContext, R.anim.bubble);
                    zoomInAnimation.setDuration(400);
                    listItemHolder.mAddFriend.startAnimation(zoomInAnimation);
                    if (mIsMemberFriends)
                        listItemHolder.mAddFriend.setText(mContext.getResources().getString(R.string.remove_friend_button));
                    mItemPosition = (int) v.getTag();
                    performLinkAction(mItemPosition);
                }
            });

        } else {

            listItemHolder.menuJsonArray = listItems.getmMemberMenus();

            if (listItemHolder.menuJsonArray == null) {
                listItemHolder.mMemberOptions.setVisibility(View.GONE);
                listItemHolder.menuOption.setVisibility(View.GONE);
                listItemHolder.ivMessage.setVisibility(View.GONE);

            } else if (listItems.getMenuArray() != null && listItems.getMenuArray().length() > 0) {
                listItemHolder.mMemberOptions.setVisibility(View.GONE);
                listItemHolder.menuOption.setVisibility(View.VISIBLE);

                if (listItems.getmFriendShipType().equals("remove_friend")
                        || listItems.getmFriendShipType().equals("member_unfollow")) {
                    Drawable icon;
                    if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                        listItemHolder.ivMessage.setPadding(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp),
                                mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp),
                                mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp),
                                mContext.getResources().getDimensionPixelSize(R.dimen.dimen_5dp));
                        icon = ContextCompat.getDrawable(mContext, R.drawable.ic_prime_messenger);
                    } else {
                        icon = ContextCompat.getDrawable(mContext, R.drawable.ic_message);
                    }
                    icon.mutate();
                    listItemHolder.ivMessage.setImageDrawable(icon);
                    listItemHolder.ivMessage.setColorFilter(ContextCompat.getColor(mContext, R.color.dark_gray),
                            PorterDuff.Mode.SRC_ATOP);
                    GradientDrawable drawable = (GradientDrawable) listItemHolder.ivMessage.getBackground();
                    drawable.mutate();
                    drawable.setStroke(mContext.getResources().getDimensionPixelSize(R.dimen.dimen_1dp),
                            ContextCompat.getColor(mContext, R.color.dark_gray));

                    listItemHolder.ivMessage.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            BrowseListItems browseListItems = mBrowseItemlist.get((int) view.getTag());
                            GlobalFunctions.messageOwner(mContext, ConstantVariables.USER_MENU_TITLE,
                                    browseListItems);
                        }
                    });

                } else {
                    listItemHolder.ivMessage.setVisibility(View.GONE);
                }

                listItemHolder.menuOption.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        BrowseListItems browseListItems = mBrowseItemlist.get((int) view.getTag());
                        List<Object> list = new ArrayList<>();
                        list.addAll(mBrowseItemlist);
                        mGutterMenuUtils.showPopup(view, browseListItems.getMenuArray(),
                                (int) view.getTag(), list, ConstantVariables.USER_MENU_TITLE);
                    }
                });

            } else {
                listItemHolder.mMemberOptions.setVisibility(View.VISIBLE);
                listItemHolder.menuOption.setVisibility(View.GONE);
                listItemHolder.ivMessage.setVisibility(View.GONE);
                String menuName = listItemHolder.menuJsonArray.optString("name");
                String defaultText = listItemHolder.menuJsonArray.optString("default", "default");

                /* Used in crowdfunding project backer list */
                if (listItemHolder.menuJsonArray.has("currency")) {
                    listItemHolder.mMemberOptions.setTypeface(listItemHolder.mMemberOptions.getTypeface(), Typeface.NORMAL);
                    listItemHolder.mMemberOptions.setTextSize(TypedValue.COMPLEX_UNIT_PX, mContext.getResources().getDimension(R.dimen.body_medium_font_size));
                    String amount = "0";
                    double defaultAmount = listItemHolder.menuJsonArray.optDouble("default");
                    if (defaultAmount > 0) {
                        defaultText = CurrencyUtils.getCurrencyConvertedValue(mContext, listItemHolder.menuJsonArray.optString("currency"), defaultAmount);
                    }
                }

                Drawable addIconDrawable = null;
                if (menuName != null) {
                    switch (menuName) {
                        case "add_friend":
                        case "accept_request":
                        case "member_follow":
                            addIconDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_friends_icon_add);
                            break;
                        case "remove_friend":
                        case "member_unfollow":
                            addIconDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_friends_icon_tick);
                            break;
                        case "cancel_request":
                        case "cancel_follow":
                            addIconDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_friends_cancel_filled);
                            break;
                        default:
                            listItemHolder.mMemberOptions.setText(defaultText);

                    }
                    if (addIconDrawable != null) {
                        addIconDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor),
                                PorterDuff.Mode.SRC_ATOP));
                        listItemHolder.mMemberOptions.setCompoundDrawablesWithIntrinsicBounds(addIconDrawable, null, null, null);
                    }
                }

                if (defaultText.equals("default")) {
                    listItemHolder.mMemberOptions.setOnClickListener(new View.OnClickListener() {

                        @Override
                        public void onClick(View v) {
                            /**
                             * Apply animation on member option icon
                             */
                            Animation zoomInAnimation = AnimationUtils.loadAnimation(mContext, R.anim.button_click);
                            listItemHolder.mMemberOptions.startAnimation(zoomInAnimation);
                            if (mIsMemberFriends) {
                                Drawable iconDrawable = ContextCompat.getDrawable(mContext, R.drawable.ic_friends_cancel_filled);
                                iconDrawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor),
                                        PorterDuff.Mode.SRC_ATOP));
                                listItemHolder.mMemberOptions.setCompoundDrawablesWithIntrinsicBounds(iconDrawable, null, null, null);
                            }
                            mItemPosition = (int) v.getTag();
                            performLinkAction(mItemPosition);
                        }
                    });
                }
            }

            // Checking condition for AdvancedMember and show data accordingly.
            if (listItems.getmIsSiteMember() == 1) {

                //Showing location if exists
                if (listItems.getmLocation() != null && !listItems.getmLocation().isEmpty()) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        listItemHolder.mLocation.setText(Html.fromHtml(listItems.getmLocation(), Html.FROM_HTML_MODE_LEGACY));
                    } else {
                        listItemHolder.mLocation.setText(Html.fromHtml(listItems.getmLocation()));
                    }
                    listItemHolder.mLocation.setVisibility(View.VISIBLE);
                } else {
                    listItemHolder.mLocation.setVisibility(View.GONE);
                }

                // Showing mutual friend count of the member if exists.
                if (listItems.getmMutualFriendCount() >= 1) {
                    listItemHolder.mMutualFriendCount.setText(mContext.getResources().
                            getQuantityString(R.plurals.mutual_friend_text,
                                    listItems.getmMutualFriendCount(),
                                    listItems.getmMutualFriendCount()));
                    listItemHolder.mMutualFriendCount.setVisibility(View.VISIBLE);
                } else {
                    listItemHolder.mMutualFriendCount.setVisibility(View.GONE);
                }

                //Showing online icon if the member is online.
                if (listItems.getmIsMemberOnline() == 1) {
                    Drawable onlineDrawable = ContextCompat.getDrawable(mContext, R.drawable.bg_dot);
                    onlineDrawable.setColorFilter(ContextCompat.getColor(mContext, R.color.light_green),
                            PorterDuff.Mode.SRC_ATOP);
                    onlineDrawable.setBounds(0, 0, mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp),
                            mContext.getResources().getDimensionPixelSize(R.dimen.margin_10dp));
                    listItemHolder.mOwnerName.setCompoundDrawables(null, null, onlineDrawable, null);

                } else {
                    listItemHolder.mOwnerName.setCompoundDrawables(null, null, null, null);
                }

            } else {
                listItemHolder.mLocation.setVisibility(View.GONE);
                listItemHolder.mMutualFriendCount.setVisibility(View.GONE);
            }
        }

        return mRootView;
    }

    private void redirectToUserProfilePage(int mUserId, View view, String profileImage) {
        if (mAppConst.isLoggedOutUser()){
            SnackbarUtils.displaySnackbar(mRootView,mContext.getResources().
                    getString(R.string.user_does_not_have_access_resources));
        }
        else {
            Intent userProfileIntent = new Intent(mContext, userProfile.class);
            userProfileIntent.putExtra("user_id", mUserId);
            userProfileIntent.putExtra(ConstantVariables.PROFILE_IMAGE_URL, profileImage);

            if (mBrowseMemberFragment != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    ActivityOptionsCompat options = ActivityOptionsCompat.makeSceneTransitionAnimation(
                            ((Activity) mContext),
                            view, mContext.getResources().getString(R.string.transition_name));
                    mBrowseMemberFragment.startActivityForResult(userProfileIntent, ConstantVariables.
                            USER_PROFILE_CODE, options.toBundle());
                } else {
                    mBrowseMemberFragment.startActivityForResult(userProfileIntent, ConstantVariables.
                            USER_PROFILE_CODE);
                    ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                }
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    ActivityOptionsCompat options = ActivityOptionsCompat.makeSceneTransitionAnimation(
                            ((Activity) mContext),
                            view, mContext.getResources().getString(R.string.transition_name));
                    ((Activity) mContext).startActivityForResult(userProfileIntent, ConstantVariables.
                            USER_PROFILE_CODE, options.toBundle());
                } else {
                    ((Activity) mContext).startActivityForResult(userProfileIntent, ConstantVariables.USER_PROFILE_CODE);
                    ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                }

            }
            ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }
    }

    @Override
    public void onItemDelete(int position) {

    }

    @Override
    public void onItemActionSuccess(int position, Object itemList, String menuName) {
        BrowseListItems listItems = (BrowseListItems) itemList;
        mBrowseItemlist.set(position, listItems);
        notifyDataSetChanged();
    }

    public void performLinkAction(int itemPosition) {
        JSONObject mPreviousMenuArray, menuArray, urlParamsJsonObject = null;
        String menuName = null;
        String url = null;
        String dialogueMessage = null, dialogueTitle = null, buttonTitle = null, successMessage = null;
        String changedMenuName = null, changedMenuUrl = null;
        final Map<String, String> postParams = new HashMap<>();
        final BrowseListItems memberList = mBrowseItemlist.get(itemPosition);
        mPreviousMenuArray = menuArray = memberList.getmMemberMenus();
        if (menuArray != null) {

            menuName = menuArray.optString("name");
            url = AppConstant.DEFAULT_URL + menuArray.optString("url");
            urlParamsJsonObject = menuArray.optJSONObject("urlParams");
        }


        if (urlParamsJsonObject != null && urlParamsJsonObject.length() != 0) {
            JSONArray urlParamsNames = urlParamsJsonObject.names();
            for (int i = 0; i < urlParamsJsonObject.length(); i++) {

                String name = urlParamsNames.optString(i);
                String value = urlParamsJsonObject.optString(name);
                postParams.put(name, value);
            }
        }

        assert menuName != null;
        switch (menuName) {
            case "add_friend":
                dialogueMessage = mContext.getResources().getString(R.string.add_friend_message);
                dialogueTitle = mContext.getResources().getString(R.string.add_friend_title);
                buttonTitle = mContext.getResources().getString(R.string.add_friend_button);
                successMessage = mContext.getResources().getString(R.string.add_friend_success_message);
                if (memberList.getIsFriendshipVerified() == 1) {
                    changedMenuUrl = "user/cancel";
                    changedMenuName = "cancel_request";
                } else {
                    changedMenuUrl = "user/remove";
                    changedMenuName = "remove_friend";
                }
                break;
            case "member_follow":
                dialogueMessage = mContext.getResources().getString(R.string.add_friend_message);
                dialogueTitle = mContext.getResources().getString(R.string.add_friend_title);
                buttonTitle = mContext.getResources().getString(R.string.add_friend_button);
                successMessage = mContext.getResources().getString(R.string.add_friend_success_message);
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
                changedMenuName = "remove_friend";
                changedMenuUrl = "user/remove";
                break;
            case "remove_friend":
            case "member_unfollow":
                dialogueMessage = mContext.getResources().getString(R.string.remove_friend_message);
                dialogueTitle = mContext.getResources().getString(R.string.remove_friend_title);
                buttonTitle = mContext.getResources().getString(R.string.remove_friend_button);
                successMessage = mContext.getResources().getString(R.string.remove_friend_success_message);
                changedMenuUrl = "user/add";
                if (menuName.equals("member_unfollow")) {
                    changedMenuName = "member_follow";
                } else {
                    changedMenuName = "add_friend";
                }
                break;
            case "cancel_request":
            case "cancel_follow":
                dialogueMessage = mContext.getResources().getString(R.string.cancel_friend_request_message);
                dialogueTitle = mContext.getResources().getString(R.string.cancel_friend_request_title);
                buttonTitle = mContext.getResources().getString(R.string.cancel_friend_request_button);
                successMessage = mContext.getResources().getString(R.string.cancel_friend_request_success_message);
                changedMenuUrl = "user/add";
                if (menuName.equals("cancel_follow")) {
                    changedMenuName = "member_follow";
                } else {
                    changedMenuName = "add_friend";
                }
                break;
        }

        AlertDialog.Builder alertBuilder = new AlertDialog.Builder(mContext);

        alertBuilder.setMessage(dialogueMessage);
        alertBuilder.setTitle(dialogueTitle);

        final String finalSuccessMessage = successMessage;
        final String finalChangedMenuName = changedMenuName;
        final String finalChangedMenuUrl = changedMenuUrl;
        processRequest(menuArray, finalChangedMenuName, finalChangedMenuUrl, memberList, url, postParams, mPreviousMenuArray);
        //TODO If want to show confirmation alert dialog
//        alertBuilder.setPositiveButton(buttonTitle, new DialogInterface.OnClickListener() {
//            public void onClick(DialogInterface dialog, int which) {
//                processRequest(menuArray, finalChangedMenuName, finalChangedMenuUrl, memberList, url, postParams, mPreviousMenuArray);
//            }});
//        alertBuilder.setNegativeButton(mContext.getResources().getString(R.string.cancel),
//                new DialogInterface.OnClickListener() {
//            public void onClick(DialogInterface dialog, int which) {
//                try {
//                    menuArray.put("name", menuName);
//                    memberList.setmMemberMenus(menuArray);
//                    memberList.setRequestProcessing(false);
//                    notifyDataSetChanged();
//                } catch (JSONException e) {
//                    e.printStackTrace();
//                }
//                dialog.cancel();
//            }
//        });
//        alertBuilder.create().show();

    }

    private void processRequest(JSONObject menuArray, String finalChangedMenuName, String finalChangedMenuUrl, final BrowseListItems memberList, String url, Map<String, String> postParams, final JSONObject mPreviousMenuArray) {
        try {
            menuArray.put("name", finalChangedMenuName);
            menuArray.put("url", finalChangedMenuUrl);
            memberList.setmMemberMenus(menuArray);
            memberList.setCanAddToList(0);
            memberList.setRequestProcessing(true);
            notifyDataSetChanged();

        } catch (JSONException e) {
            e.printStackTrace();
        }
        mAppConst.postJsonResponseForUrl(url, postParams, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                memberList.setRequestProcessing(false);
                notifyDataSetChanged();
                //TO DO If want to show confirmation message
                //View view = ((Activity)mContext).getCurrentFocus();
                //SnackbarUtils.displaySnackbar(view, finalSuccessMessage);

            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                View view = ((Activity) mContext).getCurrentFocus();
                SnackbarUtils.displaySnackbar(view, message);
                memberList.setmMemberMenus(mPreviousMenuArray);
                memberList.setCanAddToList(0);
                memberList.setRequestProcessing(false);
                notifyDataSetChanged();
            }
        });
    }

    private void manageMember(final String url, final String memberId, String alertMessage, final String successMessage) {

        AlertDialogWithAction dialog = new AlertDialogWithAction(mContext);
        dialog.showAlertDialogWithAction(alertMessage,
                mContext.getResources().getString(R.string.yes_label),
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        Map<String, String> postParams = new HashMap<>();
                        postParams.put("user_id", memberId);
                        mAppConst.postJsonResponseForUrl(url, postParams, new OnResponseListener() {
                            @Override
                            public void onTaskCompleted(JSONObject jsonObject) {
                                if (mBrowseMemberFragment != null) {
                                    mBrowseMemberFragment.makeRequest();
                                }
                                SnackbarUtils.displaySnackbar(((Activity) mContext).findViewById(android.R.id.content), successMessage);
                            }

                            @Override
                            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                SnackbarUtils.displaySnackbar(((Activity) mContext).findViewById(android.R.id.content), message);
                            }
                        });
                    }
                });


    }

    private static class ListItemHolder {
        ImageView mListImage, mMemberOnlineIcon, ivMessage;
        TextView mOwnerName, mMemberOptions, mAge, mLocation, mMutualFriendCount, mAddFriend, manageMember;
        JSONObject menuJsonArray;
        ProgressBar processingRequest;
        View menuOption;
        int mUserId;
        String profileImage;
    }
}
