package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;
import java.util.Map;

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
public class Reward {
    public String title, description, image, image_profile, image_icon, amount, delivery_date;
    public int project_id, reward_id, quantity, minBackAmount, shipping_amt;
    public List<GutterMenu> menu;
    public List<Element> form;
    private boolean isSelected = false;
    public double pledge_amount;
    public String currency, selectedRegionId, selectedRegionName;
    public Map<String, String> region_id;
    public boolean isSelected(){
        return isSelected;
    }

    public void setSelected(boolean isSelected){
        this.isSelected = isSelected;
    }
}
