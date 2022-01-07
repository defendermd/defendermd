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

package com.socialengineaddons.mobileapp.classes.common.utils;

import android.content.Context;
import android.graphics.Rect;
import android.support.annotation.DimenRes;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.socialengineaddons.mobileapp.R;

public class GridSpacingItemDecorationUtil extends RecyclerView.ItemDecoration {

    private int mCommonItemOffset;
    // Specific item offset for left, top, right, bottom at specific pattern
    private int iItemLeftOffset, iItemRightOffset, iItemTopOffset, iItemBottomOffset, iPattern;
    private boolean mIsTablet;

    public GridSpacingItemDecorationUtil(int itemOffset, boolean isTablet) {
        mCommonItemOffset = itemOffset;
        mIsTablet = isTablet;
    }

    /**
     * Public constructor used to specify the specific offset at each side at particular position
     * of given pattern which has modules zero.
     * @param iItemLeftOffset
     * @param iItemRightOffset
     * @param iItemTopOffset
     * @param iItemBottomOffset
     * @param iPattern
     */
    public GridSpacingItemDecorationUtil(int iItemLeftOffset, int iItemRightOffset, int iItemTopOffset, int iItemBottomOffset, int iPattern) {
        this.iItemLeftOffset = iItemLeftOffset;
        this.iItemRightOffset = iItemRightOffset;
        this.iItemTopOffset = iItemTopOffset;
        this.iItemBottomOffset = iItemBottomOffset;
        this.iPattern = iPattern;
    }

    public GridSpacingItemDecorationUtil(@NonNull Context context, @DimenRes int itemOffsetId, RecyclerView recyclerView, boolean isTablet) {
        this(context.getResources().getDimensionPixelSize(itemOffsetId), isTablet);
        recyclerView.setClipToPadding(false);
        if (isTablet) {
            recyclerView.setPadding(context.getResources().getDimensionPixelSize(itemOffsetId),
                    context.getResources().getDimensionPixelSize(itemOffsetId),
                    context.getResources().getDimensionPixelSize(itemOffsetId),
                    context.getResources().getDimensionPixelSize(R.dimen.padding_64dp));
        } else {
            recyclerView.setPadding(0, context.getResources().getDimensionPixelSize(itemOffsetId),
                    0, context.getResources().getDimensionPixelSize(R.dimen.padding_64dp));
        }

    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent,
                               RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);
        int itemPosition = ((RecyclerView.LayoutParams)view.getLayoutParams()).getViewLayoutPosition();
        if (mCommonItemOffset > 0 ) {
            if (mIsTablet) {
                outRect.set(mCommonItemOffset, mCommonItemOffset, mCommonItemOffset, mCommonItemOffset);
            } else {
                outRect.set(0, mCommonItemOffset, 0, mCommonItemOffset);
            }
        } else if ((itemPosition % iPattern) != 0){
            outRect.set(iItemLeftOffset, iItemTopOffset, iItemRightOffset, iItemBottomOffset);
        }
    }
}
