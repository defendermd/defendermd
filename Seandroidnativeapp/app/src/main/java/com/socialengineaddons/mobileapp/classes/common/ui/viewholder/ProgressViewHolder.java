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

package com.socialengineaddons.mobileapp.classes.common.ui.viewholder;

import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.core.MainActivity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class ProgressViewHolder extends RecyclerView.ViewHolder {

    public View progressView;

    public ProgressViewHolder(View view) {
        super(view);
        progressView = view;
    }

    /***
     * Method to Show Footer ProgressBar on Scrolling and Show End Of Result Text if there are no more results
     * @param context Context of calling class.
     * @param progressView Root View of progress layout.
     * @param listItem ListItem.
     */
    public static void inflateProgressView(Context context, View progressView, Object listItem) {

        ProgressBar progressBar = (ProgressBar) progressView.findViewById(R.id.progressBar);
        TextView footerText = (TextView) progressView.findViewById(R.id.footer_text);
        if (listItem == null) {
            progressBar.setVisibility(View.VISIBLE);
            progressBar.setIndeterminate(true);
            footerText.setVisibility(View.GONE);
        } else {
            footerText.setVisibility(View.VISIBLE);
            footerText.setText(context.getResources().getString(R.string.end_of_results));
            progressBar.setVisibility(View.GONE);
        }

    }

    /***
     * Method to Show Footer ProgressBar on Scrolling and Show End Of Result Add friends Block if there are no more results
     * @param context Context of calling class.
     * @param addFriendView Root View of progress layout.
     * @param listItem ListItem.
     */
    public static void inflateEndOfResultAddView(Context context, View addFriendView, Object listItem) {

        ProgressBar progressBar = addFriendView.findViewById(R.id.progressBar);
        LinearLayout endOfResultBlock = addFriendView.findViewById(R.id.add_friend_block);
        TextView addFriendBtn = addFriendView.findViewById(R.id.addfriend_btn);
        if (listItem == null) {
            progressBar.setVisibility(View.VISIBLE);
            addFriendView.setVisibility(View.VISIBLE);
            progressBar.setIndeterminate(true);
            endOfResultBlock.setVisibility(View.GONE);
        } else {

            progressBar.setVisibility(View.GONE);
            if (PreferencesUtils.getIsAddFriendWidgetEnable(context)) {
                if (PreferencesUtils.getIsAddFriendWidgetRemoved(context)) {
                    addFriendView.setVisibility(View.VISIBLE);
                    endOfResultBlock.setVisibility(View.VISIBLE);
                } else {
                    addFriendView.setVisibility(View.GONE);
                    endOfResultBlock.setVisibility(View.GONE);
                }

            } else {
                addFriendView.setVisibility(View.VISIBLE);
                endOfResultBlock.setVisibility(View.VISIBLE);
            }

            addFriendBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    MainActivity mainActivity = (MainActivity) context;
                    try {
                        JSONArray menuObject = new JSONArray(PreferencesUtils.getDashboardMenus(context));
                        if (menuObject != null && menuObject.length() > 0) {
                            for (int i = 0; i < menuObject.length(); i++) {
                                JSONObject mMenuJson = menuObject.optJSONObject(i);
                                String mMenuType = mMenuJson.optString("type");

                                if (mMenuType.equals("menu")) {
                                    String mChildMenuRegName = mMenuJson.getString("name");
                                    if (mChildMenuRegName.equals(ConstantVariables.USER_MENU_TITLE)) {
                                        mainActivity.selectItem(mChildMenuRegName, mMenuJson.optString("label"),
                                                mMenuJson.optString("headerLabel"), mMenuJson.getString("url"), 0);
                                    }
                                }
                            }
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            });
        }
    }

    /***
     * Method to Show Footer ProgressBar on Scrolling and Show "View All" Text if there are more results
     * @param context Context of calling class.
     * @param progressView Root View of progress layout.
     * @param listItem ListItem.
     * @param action Action to be performed on view all option.
     */
    public static void inflateFooterView(final Context context, View progressView, Object listItem, final String action) {

        ProgressBar progressBar = (ProgressBar) progressView.findViewById(R.id.progressBar);
        TextView footerText = (TextView) progressView.findViewById(R.id.footer_text);
        RelativeLayout footerView = (RelativeLayout) progressView.findViewById(R.id.footer_layout);

        if(listItem.equals(ConstantVariables.FOOTER_TYPE)){
            footerText.setVisibility(View.VISIBLE);
            progressBar.setVisibility(View.GONE);
            footerView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent in = new Intent();
                    in.setAction(action);
                    context.sendBroadcast(in);
                }
            });

        }else {
            footerText.setVisibility(View.GONE);
            progressBar.setVisibility(View.VISIBLE);
            progressBar.setIndeterminate(true);
        }
    }

    /***
     * Method to Show Footer ProgressBar on Scrolling.
     * @param progressView Root View of progress layout.
     */
    public static void inflateProgressBar(View progressView) {
        ProgressBar progressBar = (ProgressBar) progressView.findViewById(R.id.progressBar);
        progressBar.setIndeterminate(true);
    }

}
