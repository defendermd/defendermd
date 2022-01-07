package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

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

@JsonIgnoreProperties(ignoreUnknown = true)
public class Biography {
    public List<Project> projects;
    public int totalItemCount;
    public ProjectOwnerInfo projectOwnerInfo;
    public class ProjectOwnerInfo {
        public ProjectOwnerInfo() {

        }
        public String biography;
        public String facebook_profile_url, instagram_profile_url, twitter_profile_url, youtube_profile_url, vimeo_profile_url, website_url;
        public int user_id;

    }
}
