package com.socialengineaddons.mobileapp.classes.common.models;
/*
 *   Copyright (c) 2019 BigStep Technologies Private Limited.
 *
 *   You may not use this file except in compliance with the
 *   SocialEngineAddOns License Agreement.
 *   You may obtain a copy of the License at:
 *   https://www.socialengineaddons.com/android-app-license
 *   The full copyright and license information is also mentioned
 *   in the LICENSE file that was distributed with this
 *   source code.
 */

/**
 * @GridItemModel is a generic model for handling data of grid item.
 */
public class GridItemModel {
    private String strItemPhoto, strItemTitle, strItemSubTitle;
    private int iItemIdentity;

    /**
     * Default constructor for placeholder
     */
    public GridItemModel() {

    }
    /**
     * Initiate when you have only item photo.
     * @param strItemPhoto
     */
    public GridItemModel(String strItemPhoto) {
        this.strItemPhoto = strItemPhoto;
    }

    /**
     * Initiate when you want to item title, thumb, etc.
     * @param strItemPhoto
     * @param strItemTitle
     * @param strItemSubTitle
     * @param iItemIdentity
     */
    public GridItemModel(String strItemPhoto, String strItemTitle, String strItemSubTitle, int iItemIdentity) {
        this.strItemPhoto = strItemPhoto;
        this.strItemTitle = strItemTitle;
        this.strItemSubTitle = strItemSubTitle;
        this.iItemIdentity = iItemIdentity;
    }

    public String getStrItemPhoto() {
        return strItemPhoto;
    }


    public String getStrItemTitle() {
        return strItemTitle;
    }


    public String getStrItemSubTitle() {
        return strItemSubTitle;
    }


    public int getItemIdentity() {
        return iItemIdentity;
    }
}
