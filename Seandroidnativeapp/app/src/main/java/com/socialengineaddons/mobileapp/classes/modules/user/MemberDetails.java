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


public class MemberDetails {

    // Member variables.
    private int userId, totalItemCount;
    private String displayName, description, profileImage;
    private boolean isLessTextShowing;


    public MemberDetails() {
    }

    public MemberDetails(int userId) {
        this.userId = userId;
    }

    public MemberDetails(int userId, String displayName, String profileImage, String description) {
        this.userId = userId;
        this.displayName = displayName;
        this.profileImage = profileImage;
        this.description = description;
    }

    public int getUserId() {
        return userId;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getProfileImage() {
        return profileImage;
    }

    public String getDescription() {
        return description;
    }

    public boolean isLessTextShowing() {
        return isLessTextShowing;
    }

    public void setLessTextShowing(boolean isLessTextShowing) {
        this.isLessTextShowing = isLessTextShowing;
    }

    public int getTotalItemCount() {
        return totalItemCount;
    }

    public void setTotalItemCount(int totalItemCount) {
        this.totalItemCount = totalItemCount;
    }

    @Override
    public boolean equals(Object object) {
        boolean result = false;
        if (object == null || object.getClass() != getClass()) {
            result = false;
        } else {
            MemberDetails memberDetails = (MemberDetails) object;
            if (this.userId != 0 && memberDetails.getUserId() != 0) {
                result = this.userId == memberDetails.getUserId();
            }
        }
        return result;
    }

    @Override
    public int hashCode() {
        int hash = 3;
        hash = 7 * hash + String.valueOf(this.userId).hashCode();
        return hash;
    }
}
