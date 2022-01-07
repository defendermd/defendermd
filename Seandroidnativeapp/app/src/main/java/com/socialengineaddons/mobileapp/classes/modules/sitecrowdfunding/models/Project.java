package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import org.json.JSONArray;

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
public class Project {
    public int project_id, fundedRatio, owner_id, is_gateway_configured, category_id, featured, sponsored;
    public String title, image, category_name, location;
    public String backer_count, lifetime, state, currency;
    public String description, content_url;
    public String owner_title, owner_image_normal, owner_image, owner_image_profile;
    public List<ProfileTab> profile_tabs;
    public List<GutterMenu> menu;
    public boolean isFavourite, isLike, hasReward, backable;
    public String funded_ratio_title;
    public List<GutterMenu> profilePhotoMenu;
    public Biography biography;
    public double backed_amount, funded_amount, goal_amount;

}
