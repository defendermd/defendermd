package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding;


import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v4.content.ContextCompat;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.EditEntry;
import com.socialengineaddons.mobileapp.classes.common.activities.WebViewActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.BezelImageView;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.CustomTabUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Biography;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.FAQ;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Project;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Reward;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.utils.CoreUtil;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.views.ProjectView;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;
import com.squareup.picasso.Picasso;

import org.json.JSONObject;

import java.util.HashMap;
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

public class OwnerBiographyFragment extends DialogFragment implements ProjectView, View.OnClickListener {
    private TextView ownerTitle, biography, addBio, addBioText;
    private Context mContext;
    private Project mProject;
    private BezelImageView ownerThumb;
    private View mRootView, closeIcon;
    private LinearLayout ownerProjects;
    private ImageView facebook, twitter, instagram, youtube, vimeo, website;
    private Map<String, Boolean> visibleSocialIcons;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mRootView = inflater.inflate(R.layout.owner_biography, container, false);

        mContext = getActivity().getApplicationContext();
        closeIcon = mRootView.findViewById(R.id.button_close);
        closeIcon.setOnClickListener(this);
        ownerThumb = mRootView.findViewById(R.id.owner_thumb);
        ownerThumb.setOnClickListener(this);
        ownerTitle = mRootView.findViewById(R.id.owner_title);
        ownerTitle.setOnClickListener(this);
        biography = mRootView.findViewById(R.id.biography);
        facebook = mRootView.findViewById(R.id.facebook);
        twitter = mRootView.findViewById(R.id.twitter);
        instagram = mRootView.findViewById(R.id.instagram);
        youtube = mRootView.findViewById(R.id.youtube);
        vimeo = mRootView.findViewById(R.id.vimeo);
        website = mRootView.findViewById(R.id.website);
        website.setOnClickListener(this);
        addBio = mRootView.findViewById(R.id.add_bio);
        addBio.setOnClickListener(this);
        addBioText = mRootView.findViewById(R.id.add_bio_text);
        ownerProjects = mRootView.findViewById(R.id.owner_projects);
        if (ProjectViewActivity.mProject != null && ProjectViewActivity.mProject.biography != null) {
            mProject = ProjectViewActivity.mProject;
            setDialogContent();
        }
        return mRootView;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.getWindow().getAttributes().windowAnimations = R.style.MyAnimation_Window;
        dialog.setCancelable(false);
        dialog.requestWindowFeature(Window.FEATURE_ACTIVITY_TRANSITIONS);
        return dialog;
    }

    @Override
    public int getTheme() {
        return R.style.MyCustomTheme;
    }

    @Override
    public View getRootView() {
        return mRootView;
    }

    @Override
    public void setViews() {

    }

    @Override
    public void onSuccessRequest(JSONObject response) {

    }

    @Override
    public void onFailedRequest(String errorMessage, boolean isRetryOption, Map<String, String> notifyParam) {

    }

    @Override
    public void setNoProjectErrorTip() {

    }

    @Override
    public void notifyProjectView(List<?> itemList, int itemCount, Map<String, String> categoryList, Map<String, String> subCategoryList) {

    }

    @Override
    public void setCategoryBasedFilter() {

    }

    @Override
    public String getPseudoName() {
        return null;
    }

    @Override
    public boolean isSetCache() {
        return false;
    }

    @Override
    public boolean isActivityFinishing() {
        return false;
    }

    public void setDialogContent() {
        Picasso.get().load(mProject.owner_image_profile).into(ownerThumb);
        visibleSocialIcons = new HashMap<>();
        ownerTitle.setText(mProject.owner_title);
        Biography.ProjectOwnerInfo ownerInfo = mProject.biography.projectOwnerInfo;
        if (ownerInfo.biography != null && !ownerInfo.biography.isEmpty()) {
            biography.setText(ownerInfo.biography);
            addBio.setVisibility(View.GONE);
        } else if (GlobalFunctions.isViewer(mContext, mProject.owner_id)){
            addBio.setVisibility(View.VISIBLE);
            addBioText.setVisibility(View.VISIBLE);
            biography.setVisibility(View.GONE);
        } else {
            addBio.setVisibility(View.GONE);
            biography.setVisibility(View.GONE);
        }
        if (ownerInfo.facebook_profile_url != null && !ownerInfo.facebook_profile_url.isEmpty()) {
            setSocialIcon(facebook, ownerInfo.facebook_profile_url);
            facebook.setAlpha(1.0f);
            visibleSocialIcons.put("facebook", true);
        } else {
            facebook.setAlpha(0.1f);
            facebook.setTag("disabled");
        }
        facebook.setOnClickListener(this);
        if (ownerInfo.twitter_profile_url != null && !ownerInfo.twitter_profile_url.isEmpty()) {
            setSocialIcon(twitter, ownerInfo.twitter_profile_url);
            twitter.setAlpha(1.0f);
            visibleSocialIcons.put("twitter", true);
        } else {
            twitter.setAlpha(0.1f);
            twitter.setTag("disabled");
        }
        twitter.setOnClickListener(this);
        if (ownerInfo.instagram_profile_url != null && !ownerInfo.instagram_profile_url.isEmpty()) {
            setSocialIcon(instagram, ownerInfo.instagram_profile_url);
            instagram.setAlpha(1.0f);
            visibleSocialIcons.put("instagram", true);
        } else {
            instagram.setAlpha(0.1f);
            instagram.setTag("disabled");
        }
        instagram.setOnClickListener(this);
        if (ownerInfo.youtube_profile_url != null && !ownerInfo.youtube_profile_url.isEmpty()) {
            setSocialIcon(youtube, ownerInfo.youtube_profile_url);
            visibleSocialIcons.put("youtube", true);
            youtube.setAlpha(1.0f);
        } else {
            youtube.setAlpha(0.1f);
            youtube.setTag("disabled");
        }
        youtube.setOnClickListener(this);

        if (ownerInfo.vimeo_profile_url != null && !ownerInfo.vimeo_profile_url.isEmpty()) {
            setSocialIcon(vimeo, ownerInfo.vimeo_profile_url);
            visibleSocialIcons.put("vimeo", true);
            vimeo.setAlpha(1.0f);
        } else {
            vimeo.setAlpha(0.1f);
            vimeo.setTag("disabled");
        }
        vimeo.setOnClickListener(this);

        if (ownerInfo.website_url != null && !ownerInfo.website_url.isEmpty()) {
            setSocialIcon(website, ownerInfo.website_url);
            visibleSocialIcons.put("website", true);
            website.setAlpha(1.0f);
        } else {
            website.setAlpha(0.1f);
            website.setTag("disabled");
        }
        website.setOnClickListener(this);
        if (visibleSocialIcons.size() < 3) {
            String iconNames[] = {"facebook", "twitter", "instagram"};
            for (String icon : iconNames) {
                if (!visibleSocialIcons.containsKey(icon) && visibleSocialIcons.size() < 3) {
                    switch (icon) {
                        case "facebook":
                            setSocialIcon(facebook, ownerInfo.facebook_profile_url);
                            visibleSocialIcons.put("facebook", true);
                            break;
                        case "twitter":
                            setSocialIcon(twitter, ownerInfo.twitter_profile_url);
                            visibleSocialIcons.put("twitter", true);
                            break;
                        case "instagram":
                            setSocialIcon(instagram, ownerInfo.instagram_profile_url);
                            visibleSocialIcons.put("instagram", true);
                            break;
                    }
                }
            }
        }
        List<Project> projects = mProject.biography.projects;
        if (projects != null && projects.size() > 0) {
            for (int i = 0; i < projects.size(); i++) {
                Project project = projects.get(i);
                TextView projectTitle = new TextView(mContext);
                projectTitle.setTextColor(ContextCompat.getColor(mContext, R.color.colorPrimary));
                projectTitle.setLayoutParams(CustomViews.getFullWidthLayoutParams());
                projectTitle.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
                projectTitle.setTextSize(TypedValue.COMPLEX_UNIT_PX, mContext.getResources().getDimension(R.dimen.size_16sp));
                projectTitle.setText("\uf105 " + project.title);
                projectTitle.setPadding(mContext.getResources().getDimensionPixelOffset(R.dimen.padding_30dp),
                        mContext.getResources().getDimensionPixelOffset(R.dimen.padding_5dp),
                        mContext.getResources().getDimensionPixelOffset(R.dimen.padding_10dp),
                        mContext.getResources().getDimensionPixelOffset(R.dimen.padding_5dp));
                projectTitle.setOnClickListener(this);
                projectTitle.setId(R.id.title_view);
                projectTitle.setTag(project.project_id);
                ownerProjects.addView(projectTitle);
            }
        } else {
            ownerProjects.setVisibility(View.GONE);
        }

    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.facebook:
            case R.id.twitter:
            case R.id.instagram:
            case R.id.youtube:
            case R.id.vimeo:
            case R.id.website:
                if (view.getTag() != null && view.getTag().toString().equals("disabled")) {
                    SnackbarUtils.displaySnackbar(getActivity().findViewById(android.R.id.content),
                            getResources().getString(R.string.information_not_added));
                } else {
                    CustomTabUtil.launchCustomTab(getActivity(), GlobalFunctions.getWebViewUrl(view.getTag().toString(), mContext));
                }
                break;
            case R.id.title_view:
                startActivity(CoreUtil.getProjectViewPageIntent(mContext, view.getTag().toString()));
                break;
            case R.id.owner_title:
            case R.id.owner_thumb:
                Intent ownerProfile = new Intent(mContext, userProfile.class);
                ownerProfile.putExtra(ConstantVariables.USER_ID, mProject.owner_id);
                startActivity(ownerProfile);
                break;
            case R.id.add_bio:
                //TODO onBackPress Work
                Intent editBio = new Intent(mContext, EditEntry.class);
                editBio.putExtra(ConstantVariables.URL_STRING, UrlUtil.CROWD_FUNDING_PROJECT_ADD_BIO_URL + mProject.project_id);
                editBio.putExtra(ConstantVariables.KEY_TOOLBAR_TITLE, mContext.getResources().getString(R.string.about_you));
                editBio.putExtra(ConstantVariables.KEY_SUCCESS_MESSAGE, mContext.getResources().getString(R.string.information_edited_successfully));
                startActivityForResult(editBio, ConstantVariables.PAGE_EDIT_CODE);
                getActivity().overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                dismiss();
            case R.id.button_close:
                getActivity().onBackPressed();
                dismiss();
                break;
        }
    }

    public void setSocialIcon(ImageView imageView, String url) {
        imageView.setVisibility(View.VISIBLE);
        if (url != null && !url.isEmpty()) {
            imageView.setTag(url);
        } else {
            //TODO Disabled Icon Work
            imageView.setTag("disabled");
        }
    }
}
