package com.socialengineaddons.mobileapp.classes.modules.store.utils;

import org.json.JSONObject;

/**
 * Created by root on 29/8/16.
 */
public class SheetItemModel {
    private String name, key, icon, layoutType = "0";
    private JSONObject keyObject;
    int id;

    public SheetItemModel(String name, String key) {
        this.name = name;
        this.key = key;
    }

    public SheetItemModel(String name, String key, String icon) {
        this.name = name;
        this.key = key;
        this.icon = icon;
    }


    public SheetItemModel(String name, String key, int id, String icon) {
        this.name = name;
        this.key = key;
        this.icon = icon;
        this.id = id;
    }

    public SheetItemModel(JSONObject name, String key, String layoutType) {
        this.keyObject = name;
        this.key = key;
        this.layoutType = layoutType;
        this.name = name.optString("label");
    }

    public JSONObject getKeyObject() {
        return keyObject;
    }

    public String getName() {
        return name;
    }

    public String getKey() {
        return key;
    }

    public int getId() {
        return id;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getIcon() {
        return icon;
    }
    public String getLayoutType() {
        return layoutType;
    }

}
