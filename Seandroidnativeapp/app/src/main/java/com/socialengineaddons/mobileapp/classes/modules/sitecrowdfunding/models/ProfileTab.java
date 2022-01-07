package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

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
public class ProfileTab {
    public String name,label,url;
    public int totalItemCount;
    public UrlParams urlParams;
    public String uploadUrl;
    public boolean canUpload;
    public class UrlParams {
        public String tab_info, subject_type, subject_id;
        public String entity, entity_id, type, id;
        public UrlParams(){

        }
    }
}
