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


import android.content.Context;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SlideShowListItems;

import org.json.JSONObject;

import java.util.List;

public class CurrencyAdapter extends ArrayAdapter<SlideShowListItems> {

    private Context mContext;
    private final String COUNTRY_FLAG = "countryFlag", CURRENCY_SYMBOL = "currencySymbol";
    private SlideShowListItems mListItem;
    private List<SlideShowListItems> mBrowseItemList;
    private ImageLoader imageLoader;
    private int selectedPosition;
    private String currencyFormat;

    public CurrencyAdapter(Context context, int resource, List<SlideShowListItems> listItem,
                           int position) {
        super(context, resource, listItem);

        this.mContext = context;
        this.mBrowseItemList = listItem;
        imageLoader = new ImageLoader(mContext);
        selectedPosition = position;
        currencyFormat = PreferencesUtils.getCurrencyFormat(mContext);
    }

    @NonNull
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        // Check if an existing view is being reused, otherwise inflate the view
        ViewHolder viewHolder;
        if (convertView == null) {
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.currency_item, parent, false);

            viewHolder.currencyIcon = convertView.findViewById(R.id.currency_icon);
            viewHolder.currencyTitle = convertView.findViewById(R.id.currency_name);
            viewHolder.checkIcon = convertView.findViewById(R.id.check_icon);

            convertView.setTag(viewHolder); // view lookup cache stored in tag

        } else {
            viewHolder = (ViewHolder) convertView.getTag();
        }

        mListItem = mBrowseItemList.get(position);
        JSONObject mObject = mListItem.getmObject();

        /* Check currency format and display options as per format
         * If format is enabled with country flag then display flag icon with currency name
         * Else display currency code with name */
        String label, currencyName;
        if (currencyFormat.equals(COUNTRY_FLAG)){
            currencyName = label = mObject.optString("currency_name");
            viewHolder.currencyIcon.setVisibility(View.VISIBLE);
            imageLoader.setAlbumPhoto(mObject.optString("symbol"), viewHolder.currencyIcon);
        } else {
            label = mObject.optString("code") + mObject.optString("currency_name").replaceAll("\\s","");
            viewHolder.currencyIcon.setVisibility(View.GONE);
            currencyName = mObject.optString("code");
        }

        viewHolder.currencyTitle.setText(label);

        if (currencyName.equals(PreferencesUtils.getSelectedCurrency(mContext))) {
            viewHolder.checkIcon.setVisibility(View.VISIBLE);
            Drawable drawable = viewHolder.checkIcon.getDrawable();
            drawable.setColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor), PorterDuff.Mode.SRC_ATOP);

        } else if (PreferencesUtils.getSelectedCurrency(mContext).isEmpty() && selectedPosition == position) {
            viewHolder.checkIcon.setVisibility(View.VISIBLE);
            Drawable drawable = viewHolder.checkIcon.getDrawable();
            drawable.setColorFilter(ContextCompat.getColor(mContext, R.color.themeButtonColor), PorterDuff.Mode.SRC_ATOP);
        } else {
            viewHolder.checkIcon.setVisibility(View.GONE);
        }

        return convertView;
    }


    private static class ViewHolder {
        ImageView currencyIcon, checkIcon;
        TextView currencyTitle;
    }
}
