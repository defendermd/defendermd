package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.utils;

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

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.PopupMenu;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.CreateNewEntry;
import com.socialengineaddons.mobileapp.classes.common.activities.EditEntry;
import com.socialengineaddons.mobileapp.classes.common.activities.Invite;
import com.socialengineaddons.mobileapp.classes.common.activities.InviteGuest;
import com.socialengineaddons.mobileapp.classes.common.activities.WebViewActivity;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnMenuClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnOptionItemClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnPopUpDismissListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SocialShareUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.packages.SelectPackage;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.ProjectInvoiceFragment;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.GutterMenu;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class MenuUtils {

    public GutterMenu mGutterMenu;
    public static GutterMenu selectedMenu;
    // Member variables
    private View mMainView;
    private Context mContext;
    private AppConstant mAppConst;
    private String mRedirectUrl, mMenuName,
            mDialogueMessage, mDialogueTitle, mDialogueButton, mSuccessMessage,
            mMenuLabel;
    private int mPosition;
    private boolean isNeedToDismiss = true, isActionPerformed = false;
    private Map<String, String> mPostParams;
    private JSONObject mMenuJsonObject, mUrlParams;
    private OnPopUpDismissListener mOnPopUpDismissListener;
    private OnMenuClickResponseListener mOnMenuClickResponseListener;
    private OnOptionItemClickResponseListener mOnOptionItemClickResponseListener;
    private BrowseListItems mBrowseListItems = new BrowseListItems();
    private Fragment mCallingFragment;
    private Menu mMenu;
    private Intent mIntent;
    public static int selectedSubMenuAt = -1;
    private SocialShareUtil mSocialShareUtil;
    private String callBackActions[] = {"create", "edit"};
    private Map<String, String> mMenuData;


    /**
     * Public constructor of MenuUtils.
     *
     * @param context context of calling class.
     */
    public MenuUtils(Context context) {
        mContext = context;
        mPostParams = new HashMap<>();
        mAppConst = new AppConstant(mContext);
        mSocialShareUtil = new SocialShareUtil(mContext);
    }

    /**
     * Method to set OnPopUpDismissListener on popup click.
     *
     * @param onPopUpDismissListener OnPopUpDismissListener context from calling class.
     */
    public void setOnPopUpDismissListener(OnPopUpDismissListener onPopUpDismissListener) {
        this.mOnPopUpDismissListener = onPopUpDismissListener;
    }


    /**
     * Method to set onMenuClickResponseListener on popup click.
     *
     * @param onMenuClickResponseListener onMenuClickResponseListener context from calling class.
     */
    public void setOnMenuClickResponseListener(OnMenuClickResponseListener onMenuClickResponseListener) {
        this.mOnMenuClickResponseListener = onMenuClickResponseListener;
    }


    /**
     * Method to set onOptionItemClickResponseListener on popup click.
     *
     * @param onOptionItemClickResponseListener onOptionItemClickResponseListener context from calling class.
     */
    public void setOnOptionItemClickResponseListener(OnOptionItemClickResponseListener onOptionItemClickResponseListener) {
        this.mOnOptionItemClickResponseListener = onOptionItemClickResponseListener;
    }


    /**
     * Main Method to show pop up on optionIcon click.
     *
     * @param view            View on which pop is shown.
     * @param position        position of current selected item.
     * @param data            Menu Data.
     * @param callingFragment Fragment of calling class.
     */
    public void showPopup(final View view, final int position,
                          final Map<String, String> data,
                          final Fragment callingFragment, final List<GutterMenu> gutterMenus) {

        mPosition = position;
        mCallingFragment = callingFragment;
        mMenuData = data;
        PopupMenu popup = new PopupMenu(mContext, view);

        if (gutterMenus != null && gutterMenus.size() > 0) {
            for (int i = 0; i < gutterMenus.size(); i++) {
                mGutterMenu = gutterMenus.get(i);
                switch (mGutterMenu.name) {
                    case "back_project":
                        break;
                    default:
                        popup.getMenu().add(Menu.NONE, i, Menu.NONE, mGutterMenu.label);
                }

            }
        }
        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {

                int id = item.getItemId();
                onMenuItemSelected(view, id, gutterMenus, data);
                return true;
            }
        });
        popup.setOnDismissListener(new PopupMenu.OnDismissListener() {
            @Override
            public void onDismiss(PopupMenu menu) {
                if (mOnPopUpDismissListener != null && isNeedToDismiss) {
                    mOnPopUpDismissListener.onPopUpDismiss(true);
                }
            }
        });
        popup.show();

    }

    /***
     * Method to show OptionMenu items when click on option Icon.
     *
     * @param menu                  menu which contains all the items.
     */
    public void showOptionMenus(Menu menu, List<GutterMenu> gutterMenus, final Map<String, String> data) {
        this.mMenu = menu;
        if (gutterMenus != null && gutterMenus.size() > 0) {
            for (int i = 0; i < gutterMenus.size(); i++) {
                mGutterMenu = gutterMenus.get(i);
                List<GutterMenu> mSubMenus = mGutterMenu.subMenu;
                if (mSubMenus != null && mSubMenus.size() > 0) {
                    SubMenu subMenuItem = menu.addSubMenu(Menu.NONE, i, Menu.NONE, mGutterMenu.label.trim());
                    for (int j = 0; j < mGutterMenu.subMenu.size(); j++) {
                        GutterMenu mSubMenu = mSubMenus.get(j);
                        switch (mSubMenu.name) {
                            case "back_project":
                                break;
                            default:
                                    subMenuItem.add(Menu.NONE, j, Menu.NONE, mSubMenu.label.trim());
                        }
                    }
                } else {
                    switch (mGutterMenu.name) {
                        case "share":
                            menu.add(Menu.NONE, i, Menu.FIRST, mGutterMenu.label.trim())
                                    .setIcon(R.drawable.ic_share_white)
                                    .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
                            break;
                        case "back_project":
                            break;
                        default:
                            menu.add(Menu.NONE, i, Menu.NONE, mGutterMenu.label.trim());
                    }

                }
            }

        }
    }


    /**
     * Method to perform action on option item selection.
     *
     * @param view       optionIcon View.
     * @param id         id of selected item.
     * @param gutterMenu gutterMenu list which contains all the option data.
     */
    public void onMenuItemSelected(View view, int id, List<GutterMenu> gutterMenu, Map<String, String> data) {

        try {
            mMenuData = data;
            if (selectedSubMenuAt == -1) {
                mGutterMenu = gutterMenu.get(id);
                selectedMenu = mGutterMenu;
                selectedSubMenuAt = (mGutterMenu.subMenu != null) ? id : -1;
            } else {
                mGutterMenu = gutterMenu.get(selectedSubMenuAt);
                gutterMenu = mGutterMenu.subMenu;
                mGutterMenu = gutterMenu.get(id);
                selectedMenu = mGutterMenu;
                selectedSubMenuAt = -1;
            }
            mPostParams.clear();
            mMenuName = mGutterMenu.name;
            mMenuLabel = mGutterMenu.label;

            mDialogueButton = mGutterMenu.dialogueButton;
            mDialogueMessage = mGutterMenu.dialogueMessage;
            mDialogueTitle = mGutterMenu.dialogueTitle;
            mSuccessMessage = mGutterMenu.successMessage;

            mRedirectUrl = AppConstant.DEFAULT_URL + mGutterMenu.url;
            Set<String> paramsKeySet = (mGutterMenu.urlParams != null) ? mGutterMenu.urlParams.keySet() : null;
            if (paramsKeySet != null && paramsKeySet.size() != 0) {
                List<String> params = new ArrayList<>(paramsKeySet);
                for (int j = 0; j < mGutterMenu.urlParams.size(); j++) {
                    String name = params.get(j);
                    String value = mGutterMenu.urlParams.get(params.get(j));
                    mPostParams.put(name, value);
                }
                mRedirectUrl = mAppConst.buildQueryString(mRedirectUrl, mPostParams);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        mGutterMenu.actionType = (mGutterMenu.actionType.equals("default")) ? mGutterMenu.name : mGutterMenu.actionType;
        switch (mGutterMenu.actionType) {
            case "processDialog":
                performActionWithoutDialog();
                break;
            case "alertDialog":
                performAction();
                break;
            case "share":
                if (data != null) {
                    mSocialShareUtil.sharePost(view, mGutterMenu.label, data.get(ConstantVariables.IMAGE), mRedirectUrl, null, data.get(ConstantVariables.CONTENT_URL));
                }
                break;
            case "manage":
            case "upload_cover_photo":
            case "upload_photo":
            case "view_profile_photo":
            case "view_cover_photo":
            case "choose_from_album":
            case "info":
                if (mOnOptionItemClickResponseListener != null) {
                    mBrowseListItems.setmRedirectUrl(mRedirectUrl);
                    mOnOptionItemClickResponseListener.onOptionItemActionSuccess(mBrowseListItems, mGutterMenu.name);
                }
                break;

            default:
                doAction(mGutterMenu.actionType);
                break;
        }

    }


    /**
     * Method to perform action by showing an alert dialog with ok/cancel button.
     */
    public void performAction() {
        isNeedToDismiss = false;
        try {

            if (mMainView == null) {
                mMainView = ((AppCompatActivity) mContext).getCurrentFocus();
            }

            AlertDialog.Builder alertBuilder = new AlertDialog.Builder(mContext);
            alertBuilder.setMessage(mDialogueMessage);
            alertBuilder.setTitle(mDialogueTitle);

            alertBuilder.setPositiveButton(mDialogueButton, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    mAppConst.showProgressDialog();

                    switch (mMenuName) {

                        case "delete":
                            isActionPerformed = true;
                            mAppConst.deleteResponseForUrl(mRedirectUrl, mPostParams, new OnResponseListener() {
                                @Override
                                public void onTaskCompleted(JSONObject jsonObject) {
                                    mAppConst.hideProgressDialog();
                                    isActionPerformed = false;
                                    isNeedToDismiss = true;
                                    if (mSuccessMessage != null && !mSuccessMessage.isEmpty()) {
                                        SnackbarUtils.displaySnackbar(mMainView, mSuccessMessage);
                                    }
                                    if (mOnMenuClickResponseListener != null && mMenuName.equals("delete")) {
                                        mOnMenuClickResponseListener.onItemDelete(mPosition);
                                    }
                                    if (mOnOptionItemClickResponseListener != null) {
                                        mOnOptionItemClickResponseListener.onOptionItemActionSuccess(mBrowseListItems, mMenuName);
                                    }
                                }

                                @Override
                                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                    mAppConst.hideProgressDialog();
                                    isActionPerformed = false;
                                    isNeedToDismiss = true;
                                    SnackbarUtils.displaySnackbar(mMainView, message);
                                }
                            });
                            break;

                        default:
                            mAppConst.postJsonResponseForUrl(mRedirectUrl, mPostParams, new OnResponseListener() {
                                @Override
                                public void onTaskCompleted(JSONObject jsonObject) {
                                    mAppConst.hideProgressDialog();
                                    SnackbarUtils.displaySnackbar(mMainView, mSuccessMessage);

                                    if (mOnOptionItemClickResponseListener != null) {
                                        mOnOptionItemClickResponseListener.onOptionItemActionSuccess(
                                                mBrowseListItems, mMenuName);
                                    }
                                }

                                @Override
                                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                                    mAppConst.hideProgressDialog();
                                    SnackbarUtils.displaySnackbar(mMainView, message);
                                }
                            });
                            break;
                    }
                }
            });

            alertBuilder.setNegativeButton(mContext.getResources().
                            getString(R.string.delete_account_cancel_button_text),
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.cancel();
                        }
                    });
            alertBuilder.setOnDismissListener(new DialogInterface.OnDismissListener() {
                @Override
                public void onDismiss(DialogInterface dialog) {
                    if (mOnPopUpDismissListener != null && !isActionPerformed) {
                        isNeedToDismiss = true;
                        mOnPopUpDismissListener.onPopUpDismiss(true);
                    }
                }
            });
            alertBuilder.create().show();
        } catch (NullPointerException e) {
            e.printStackTrace();
        }

    }


    /**
     * Method to perform action without showing any alert dialog.
     */
    public void performActionWithoutDialog() {

        if (mMainView == null) {
            mMainView = ((AppCompatActivity) mContext).getCurrentFocus();
        }

        mAppConst.showProgressDialog();
        mAppConst.postJsonResponseForUrl(mRedirectUrl, mPostParams, new OnResponseListener() {

            @Override
            public void onTaskCompleted(JSONObject jsonObject) {

                if (mOnMenuClickResponseListener != null) {
                    mOnMenuClickResponseListener.onItemActionSuccess(mPosition, mBrowseListItems,
                            mMenuName);
                }
                mAppConst.hideProgressDialog();
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mAppConst.hideProgressDialog();
                SnackbarUtils.displaySnackbar(mMainView, message);
            }
        });
    }

    public void doAction(String actionType) {
        mIntent = null;
        switch (actionType) {
            case "edit":
                mIntent = new Intent(mContext, EditEntry.class);
                mIntent.putExtra(ConstantVariables.URL_STRING, mRedirectUrl);
                mIntent.putExtra(ConstantVariables.KEY_TOOLBAR_TITLE, mGutterMenu.dialogueTitle);
                mIntent.putExtra(ConstantVariables.KEY_SUCCESS_MESSAGE, mGutterMenu.successMessage);
                if (mGutterMenu.label.contains("Payment")) {
                    mIntent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.PAYMENT_METHOD_CONFIG);
                    mIntent.putExtra(ConstantVariables.FORM_TYPE, ConstantVariables.PAYMENT_METHOD_CONFIG);
                    if (mMenuData != null) {
                        mIntent.putExtra(ConstantVariables.EDIT_URL_STRING, UrlUtil.CROWD_FUNDING_PAYMENT_METHOD_CONFIG_URL + mMenuData.get(ConstantVariables.CONTENT_ID));
                    }
                }
                break;
            case "create":
                mIntent = new Intent(mContext, CreateNewEntry.class);
                mIntent.putExtra(ConstantVariables.URL_STRING, mRedirectUrl);
                mIntent.putExtra(ConstantVariables.KEY_TOOLBAR_TITLE, mGutterMenu.dialogueTitle);
                mIntent.putExtra(ConstantVariables.KEY_SUCCESS_MESSAGE, mGutterMenu.successMessage);
                break;
            case "upgrade_package":
                mIntent = new Intent(mContext, SelectPackage.class);
                mIntent.putExtra(ConstantVariables.CREATE_URL, mRedirectUrl);
                break;
            case "web":
                mIntent = new Intent(mContext, WebViewActivity.class);
                mIntent.putExtra("url", mGutterMenu.url);
                mIntent.putExtra("headerText", mGutterMenu.label);
                break;
            case "suggest_to_friend":
                mIntent = new Intent(mContext, InviteGuest.class);
                mIntent.putExtra(ConstantVariables.CONTENT_TITLE, mGutterMenu.label);
                mIntent.putExtra(ConstantVariables.URL_STRING, mRedirectUrl);
                mIntent.putExtra(ConstantVariables.SCHEMA_KEY_SEND_INVITES, "friends_id");
                mIntent.putExtra(ConstantVariables.KEY_TOOLBAR_TITLE, mContext.getResources().getString(R.string.suggest_to_friends));
                mIntent.putExtra(ConstantVariables.KEY_DEFAULT_MESSAGE, mContext.getResources().getString(R.string.invite_no_friend_message));
                mIntent.putExtra(ConstantVariables.KEY_SUCCESS_MESSAGE, mContext.getResources().getString(R.string.suggestion_success_message));
                break;

        }
        if (mIntent == null) return;
        if (Arrays.asList(callBackActions).contains(actionType)) {
            ((Activity) mContext).startActivityForResult(mIntent, ConstantVariables.PAGE_EDIT_CODE);
        } else {
            mContext.startActivity(mIntent);
        }
        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }
}
