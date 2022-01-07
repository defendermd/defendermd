package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.json.JSONException;

import java.io.IOException;
import java.util.ArrayList;
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

@JsonIgnoreProperties(ignoreUnknown=true)
public class ProjectDataHolder {
    @JsonProperty("response")
    public List<Project> mProjectList;
    public List<Project> getProjectList(String json) throws JSONException,IOException {
        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        ProjectDataHolder mProjectDataHolder = mapper.readValue(json,ProjectDataHolder.class);
        return mProjectDataHolder.mProjectList;
    }
    public List<Project> getProjectItem(String json) throws JSONException,IOException{
        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        Project mProject = mapper.readValue(json,Project.class);
        mProjectList = new ArrayList<>();
        mProjectList.add(mProject);
        return mProjectList;
    }
}
