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

import android.graphics.drawable.Drawable;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;

import org.json.JSONArray;

import java.util.ArrayList;
import java.util.List;

public class BaseFragmentAdapter extends FragmentStatePagerAdapter {
    private final List<BaseFragment> mFragments = new ArrayList<>();
    private final List<String> mFragmentTitles = new ArrayList<>();
    private final List<Drawable> mFragmentIcons = new ArrayList<>();

    public BaseFragmentAdapter(FragmentManager fm) {
        super(fm);
    }

    public BaseFragmentAdapter(FragmentManager fm, JSONArray tabsArray) {
        super(fm);
    }

    public void addFragment(BaseFragment fragment, String title) {
        mFragments.add(fragment);
        mFragmentTitles.add(title);
    }

    public void addFragmentWithIcon(BaseFragment fragment, Drawable icon, String title) {
        mFragments.add(fragment);
        mFragmentIcons.add(icon);
        mFragmentTitles.add(title);
    }

    @Override
    public BaseFragment getItem(int position) {
        return mFragments.get(position);
    }

    @Override
    public int getCount() {
        return mFragments.size();
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return mFragmentTitles.get(position);
    }

    public Drawable getIcon(int position) {
        return mFragmentIcons.get(position);
    }

}
