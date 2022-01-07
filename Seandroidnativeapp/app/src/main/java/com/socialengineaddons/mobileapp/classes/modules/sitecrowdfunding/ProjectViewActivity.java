package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding;


import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.design.widget.TabLayout;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.EditEntry;
import com.socialengineaddons.mobileapp.classes.common.activities.FragmentLoadActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.MapActivity;
import com.socialengineaddons.mobileapp.classes.common.activities.PhotoUploadingActivity;
import com.socialengineaddons.mobileapp.classes.common.adapters.BaseFragmentAdapter;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnMenuClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnOptionItemClickResponseListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ObservableScrollView;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ObservableScrollViewCallbacks;
import com.socialengineaddons.mobileapp.classes.common.ui.scrollview.ScrollState;
import com.socialengineaddons.mobileapp.classes.common.utils.CurrencyUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SocialShareUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.core.MainActivity;
import com.socialengineaddons.mobileapp.classes.modules.messages.CreateNewMessage;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoLightBoxActivity;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.GutterMenu;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.ProfileTab;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.Project;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.models.ProjectModelImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenter;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.presenters.ProjectPresenterImpl;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.utils.CoreUtil;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.utils.MenuUtils;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.views.ProjectView;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.userProfile;

import org.json.JSONObject;

import java.lang.reflect.Field;
import java.util.ArrayList;
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

public class ProjectViewActivity extends AppCompatActivity implements ProjectView, ViewPager.OnPageChangeListener, OnMenuClickResponseListener, OnOptionItemClickResponseListener, View.OnClickListener, OnUploadResponseListener
        , ObservableScrollViewCallbacks {
    public static Project mProject;
    ImageView ownerThumb, projectThumb;
    private TextView uploadProfile, likeProject, favourite, projectCategory, projectLocation, tvFeatured, tvSponsored;
    private TextView backers, backed, lifetime, ownerInfo, ownerName, currentGoal, backThisProject, contactOwner, shareProject;
    private Button fullBio, contact;
    private SelectableTextView description;
    private Context mContext;
    private ProjectPresenter mProjectPresenter;
    private String mProjectId, mProjectViewURL, mLikeUnlikeURL, successMessage;
    private Snackbar snackbar;
    private LinearLayout ownerInfoBlock, backerInfoBlock, projectOwnerInfo, backProjectLayout;
    private TabLayout mTabLayout;
    private BaseFragmentAdapter mPagerAdapter;
    private ViewPager mPager;
    private Toolbar mToolbar;
    private ProgressBar mProgressBar, mProjectProgress;
    private MenuUtils mGutterMenuUtils;
    private List<GutterMenu> mGutterMenus;
    private Map<String, String> postParams, menuData;
    private List<Project> mProjectList;
    private AppConstant mAppConst;
    private ArrayList<Object> mProfileImageDetails;
    private boolean resetMenu, isProjectEdited, isShowBio;
    private ImageLoader mImageLoader;
    private ObservableScrollView mScrollView;
    private int statusBarHeight;
    private boolean isLoaded;
    private BackThisProjectFragment mBackThisProject;
    private SocialShareUtil mSocialShareUtil;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        mAppConst = new AppConstant(mContext);
        mImageLoader = new ImageLoader(mContext);
        mSocialShareUtil = new SocialShareUtil(mContext);
        setViews();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            ViewCompat.setTransitionName(projectThumb, "project_thumb");
        }
        mScrollView = findViewById(R.id.scroll);
        mScrollView.setScrollViewCallbacks(this);
        mScrollView.setEnableScrolling(false);
        mScrollView.requestDisallowInterceptTouchEvent(true);
        mProjectPresenter = new ProjectPresenterImpl(this, new ProjectModelImpl(this));
        mProjectId = getIntent().getStringExtra("project_id");
        mProjectViewURL = UrlUtil.CROWD_FUNDING_PROJECT_VIEW_URL + mProjectId;
        if (BrowseProjectsFragments.mProjectInfo != null && BrowseProjectsFragments.mProjectInfo.project_id == Integer.parseInt(mProjectId)) {
            mProjectList.add(BrowseProjectsFragments.mProjectInfo);
            notifyProjectView(mProjectList, 1, null, null);
        }
        mProjectPresenter.doRequest(mProjectViewURL);
        PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
        statusBarHeight = (int) Math.ceil(25 * mContext.getResources().getDisplayMetrics().density);
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {

    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }

    @Override
    public View getRootView() {
        return null;
    }

    @Override
    public Context getContext() {
        return mContext;
    }

    @Override
    public void setViews() {
        setContentView(R.layout.activity_project_view);
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mToolbar.setBackgroundColor(getResources().getColor(R.color.colorPrimary));
        setSupportActionBar(mToolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(getResources().getString(R.string.blank_string));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
        CustomViews.createMarqueeTitle(mContext, mToolbar);
        mProgressBar = (ProgressBar) findViewById(R.id.progressBar);
        mProjectProgress = (ProgressBar) findViewById(R.id.project_progress);
        currentGoal = (TextView) findViewById(R.id.current_goal);

        uploadProfile = (TextView) findViewById(R.id.upload_profile);
        uploadProfile.setOnClickListener(this);
        uploadProfile.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        uploadProfile.setText("\uf030");

        likeProject = (TextView) findViewById(R.id.like_profile);
        likeProject.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        likeProject.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_EMPTY_THUMBS_UP));
        likeProject.setOnClickListener(this);

        favourite = (TextView) findViewById(R.id.favourite);
        favourite.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        favourite.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_SOLID_HEART));
        favourite.setOnClickListener(this);

        projectCategory = (TextView) findViewById(R.id.project_category);
        projectCategory.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));

        projectLocation = (TextView) findViewById(R.id.project_location);
        projectLocation.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));

        backers = (TextView) findViewById(R.id.project_backers);
        backed = (TextView) findViewById(R.id.project_backed_amount);
        lifetime = (TextView) findViewById(R.id.project_lifetime);

        ownerInfo = (TextView) findViewById(R.id.owner_info);
        ownerInfo.setActivated(true);
        ownerInfo.setOnClickListener(this);

        description = (SelectableTextView) findViewById(R.id.description);
        ownerInfoBlock = (LinearLayout) findViewById(R.id.owner_info_block);
        backerInfoBlock = (LinearLayout) findViewById(R.id.backer_info_block);
        projectOwnerInfo = (LinearLayout) findViewById(R.id.project_owner_info);

        projectThumb = findViewById(R.id.thumb);
        projectThumb.setOnClickListener(this);
        ownerThumb = (ImageView) findViewById(R.id.owner_thumb);
        ownerThumb.setOnClickListener(this);
        ownerName = (TextView) findViewById(R.id.owner_name);
        ownerName.setOnClickListener(this);

        mTabLayout = findViewById(R.id.tabs);
        mPagerAdapter = new BaseFragmentAdapter(getSupportFragmentManager());
        mPager = (ViewPager) findViewById(R.id.pager);
        mPager.setAdapter(mPagerAdapter);
        final ViewGroup.LayoutParams layoutParams = mPager.getLayoutParams();
        mToolbar.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                mToolbar.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                final int toolbarHeight = mToolbar.getHeight(); //height is ready
                Log.d(MainActivity.class.getSimpleName(), "toolbarHeight: " + toolbarHeight);
                mTabLayout.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
                    @Override
                    public void onGlobalLayout() {
                        mTabLayout.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                        int tabHeight = mTabLayout.getHeight(); //height is ready
                        int dividerHeight = GlobalFunctions.convertDpToPx(mContext, mContext.getResources().getDimensionPixelSize(R.dimen.dimen_7dp));
                        int finalHeight = mAppConst.getScreenHeight() - (toolbarHeight + tabHeight + dividerHeight);
                        layoutParams.height = finalHeight - 30;
                    }
                });
            }
        });

        mGutterMenuUtils = new MenuUtils(mContext);
        mGutterMenuUtils.setOnMenuClickResponseListener(this);
        mGutterMenuUtils.setOnOptionItemClickResponseListener(this);

        postParams = new HashMap<>();
        menuData = new HashMap<>();
        mProjectList = new ArrayList<>();
        mProfileImageDetails = new ArrayList<>();

        backProjectLayout = findViewById(R.id.back_project_layout);

        backThisProject = findViewById(R.id.back_this_project);
        backThisProject.setOnClickListener(this);

        fullBio = (Button) findViewById(R.id.full_bio);
        fullBio.setOnClickListener(this);
        fullBio.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        fullBio.setText("\uf007 " + getResources().getString(R.string.full_bio));

        contact = (Button) findViewById(R.id.contact);
        contact.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
        contact.setText("\uf095 " + getResources().getString(R.string.contact));
        contact.setOnClickListener(this);

        contactOwner = findViewById(R.id.contact_owner);
        contactOwner.setOnClickListener(this);
        Drawable drawable = ContextCompat.getDrawable(mContext, R.drawable.ic_message).mutate();
        drawable.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                PorterDuff.Mode.SRC_ATOP));
        contactOwner.setCompoundDrawablesWithIntrinsicBounds(null, drawable, null, null);

        shareProject = findViewById(R.id.share_project);
        shareProject.setOnClickListener(this);
        Drawable shareIcon = ContextCompat.getDrawable(mContext, R.drawable.ic_share_white).mutate();
        shareIcon.setColorFilter(new PorterDuffColorFilter(ContextCompat.getColor(mContext, R.color.gray_stroke_color),
                PorterDuff.Mode.SRC_ATOP));
        shareProject.setCompoundDrawablesWithIntrinsicBounds(null, shareIcon, null, null);
        tvFeatured = findViewById(R.id.tvFeaturedLabel);
        tvSponsored = findViewById(R.id.tvSponsoredLabel);
    }

    @Override
    public void onSuccessRequest(JSONObject response) {
        if (snackbar != null && snackbar.isShown()) {
            snackbar.dismiss();
        }
        mProgressBar.setVisibility(View.GONE);
        if (!isLoaded) {
            mScrollView.setEnableScrolling(true);
            mScrollView.requestDisallowInterceptTouchEvent(false);
            isLoaded = true;
        }
    }

    @Override
    public void onFailedRequest(String errorMessage, boolean isRetryOption, Map<String, String> notifyParam) {
        mProgressBar.setVisibility(View.GONE);
    }

    @Override
    public void setNoProjectErrorTip() {
        mProgressBar.setVisibility(View.GONE);
    }

    @Override
    public void notifyProjectView(List<?> projectList, int itemCount, Map<String, String> categoryList, Map<String, String> subCategoryList) {
        mProject = (Project) projectList.get(0);
        BrowseProjectsFragments.mProjectInfo = mProject;
        mToolbar.setTitle(mProject.title);
        setMarqueeToolBar();
        projectCategory.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_TAG) + "  " + mProject.category_name);
        projectCategory.setOnClickListener(this);
        if (mProject.location != null && !mProject.location.isEmpty()) {
            projectLocation.setVisibility(View.VISIBLE);
            projectLocation.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_MAP_MARKER) + "  " + mProject.location);
            findViewById(R.id.categoryLocationDivider).setVisibility(View.VISIBLE);
            projectLocation.setOnClickListener(this);
        } else {
            projectLocation.setVisibility(View.GONE);
            findViewById(R.id.categoryLocationDivider).setVisibility(View.GONE);
        }
        backers.setText(mProject.backer_count);

        String strBackedAmount = "0";
        if (mProject.backed_amount > 0) {
            strBackedAmount = CurrencyUtils.getCurrencyConvertedValue(mContext, mProject.currency, mProject.backed_amount);
        }

        backed.setText(strBackedAmount + " " + mContext.getResources().getString(R.string.backed).toLowerCase());

        lifetime.setText(mProject.state);
        description.setText(mProject.description);
        if (mProject.description != null && mProject.description.length() > 100) {
            description.makeTextViewResizable(description, 4, mContext.getResources().getString(R.string.more_dot), true);
        }
        projectThumb.setVisibility(View.VISIBLE);

        mProfileImageDetails.clear();
        mProfileImageDetails.add(new PhotoListDetails(mProject.image));

        mImageLoader.setResizeImageUrl(mProject.image, mContext.getResources().getDimensionPixelSize(R.dimen.dimen_250dp), mAppConst.getScreenWidth(), projectThumb);
        mImageLoader.setImageUrl(mProject.owner_image_normal, ownerThumb);
        ownerName.setText(mProject.owner_title);
        setProfileTabs(mProject.profile_tabs);
        if (mProject.isFavourite) {
            favourite.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_SOLID_HEART));
            favourite.setTextColor(getResources().getColor(R.color.red));
        }
        mGutterMenus = mProject.menu;
        postParams.put(ConstantVariables.SUBJECT_TYPE, ConstantVariables.CROWD_FUNDING_PROJECT_SUBJECT_TYPE);
        postParams.put(ConstantVariables.SUBJECT_ID, String.valueOf(mProject.project_id));
        mProjectProgress.setProgress(mProject.fundedRatio);

        /* Currency conversion and formatting */
        String strFundedAmount = CurrencyUtils.getCurrencyConvertedValue(mContext, mProject.currency, mProject.funded_amount);
        String strGoalAmount = CurrencyUtils.getCurrencyConvertedValue(mContext, mProject.currency, mProject.goal_amount);

        try {
            String fundedRatioString = mProject.funded_ratio_title.replaceFirst(String.valueOf((int) mProject.funded_amount), strFundedAmount);
            fundedRatioString = fundedRatioString.replace(String.valueOf((int) mProject.goal_amount), strGoalAmount);

            currentGoal.setText(fundedRatioString);
        } catch (ArrayIndexOutOfBoundsException e) {
            e.printStackTrace();
        }


        mProjectProgress.setVisibility(View.VISIBLE);
        backerInfoBlock.setVisibility(View.VISIBLE);
        projectOwnerInfo.setVisibility(View.VISIBLE);
        mTabLayout.setVisibility(View.VISIBLE);
        if (mProject.isLike) {
            likeProject.setTextColor(getResources().getColor(R.color.colorPrimary));
        } else {
            likeProject.setTextColor(getResources().getColor(R.color.white));
        }
        invalidateOptionsMenu();
        if (this.hasOwnerInfo() && GlobalFunctions.isViewer(mContext, mProject.owner_id)) {
            contact.setVisibility(View.GONE);
            contactOwner.setAlpha(0.5f);
            contactOwner.setOnClickListener(null);
        }
        if (mProject.backable) {
            backProjectLayout.setVisibility(View.VISIBLE);
            mPager.setPadding(0, 0, 0, mContext.getResources().getDimensionPixelOffset(R.dimen.padding_64dp));
        } else {
            backProjectLayout.setVisibility(View.GONE);
            mPager.setPadding(0, 0, 0, 0);
        }
        if (mProject.profilePhotoMenu != null) {
            uploadProfile.setVisibility(View.VISIBLE);
        } else {
            uploadProfile.setVisibility(View.GONE);
        }
        menuData.put(ConstantVariables.CONTENT_ID, mProjectId);
        menuData.put(ConstantVariables.IMAGE, mProject.image);
        menuData.put(ConstantVariables.CONTENT_URL, mProject.content_url);
        if (mProject.featured == 1) {
            tvFeatured.setVisibility(View.VISIBLE);
        } else {
            tvFeatured.setVisibility(View.GONE);
        }
        if (mProject.sponsored == 1) {
            tvSponsored.setVisibility(View.VISIBLE);
        } else {
            tvSponsored.setVisibility(View.GONE);
        }
        if (!isShowBio && getIntent().getBooleanExtra("isJustCreated", false)) {
            addBioPopUp();
        }
        if (isShowBio) {
            renderBiography();
        }
    }

    @Override
    public void setCategoryBasedFilter() {

    }

    @Override
    public String getPseudoName() {
        return ProjectViewActivity.class.getName();
    }

    @Override
    public boolean isSetCache() {
        return false;
    }

    @Override
    public boolean isActivityFinishing() {
        return isFinishing();
    }

    public void setProfileTabs(List<ProfileTab> mProfileTabs) {
        try {

            if (mProfileTabs == null) {
                mTabLayout.setVisibility(View.GONE);
                return;
            }
            mPagerAdapter = new BaseFragmentAdapter(getSupportFragmentManager());
            mPager = (ViewPager) findViewById(R.id.pager);
            mPager.setAdapter(mPagerAdapter);
            for (int i = 0; i < mProfileTabs.size(); i++) {
                ProfileTab tab = mProfileTabs.get(i);
                if (tab != null) {
                    BaseFragment fragment = CoreUtil.getTabFragment(tab, mProjectId, mContext);
                    if (fragment != null) {
                        if (tab.totalItemCount != 0) {
                            mPagerAdapter.addFragment(fragment, tab.label
                                    + " (" + tab.totalItemCount + ") ");
                        } else {
                            mPagerAdapter.addFragment(fragment, tab.label);
                        }
                    }
                }
                mPagerAdapter.notifyDataSetChanged();
                mTabLayout.setupWithViewPager(mPager);
            }
            mPager.setOffscreenPageLimit(mPagerAdapter.getCount() + 1);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        switch (item.getItemId()) {
            case android.R.id.home:
                onBackPressed();
                break;
            default:
                if (mGutterMenus != null) {
                    mGutterMenuUtils.onMenuItemSelected(findViewById(item.getItemId()), item.getItemId(), mGutterMenus, menuData);
                }
                if (MenuUtils.selectedMenu != null) {
                    String menuName = MenuUtils.selectedMenu.name;
                    switch (menuName) {
                        case "Reward":

                            Bundle bundle = new Bundle();
                            bundle.putString(ConstantVariables.FRAGMENT_NAME, "rewards");
                            bundle.putString(ConstantVariables.CONTENT_TITLE, mContext.getResources().getString(R.string.manage_rewards));
                            bundle.putInt(ConstantVariables.VIEW_PAGE_ID, mProject.project_id);
                            FragmentLoadActivity.loadFragment = BrowseRewardsFragment.newInstance(bundle);
                            Intent intent = new Intent(mContext, FragmentLoadActivity.class);
                            intent.putExtras(bundle);
                            startActivityForResult(intent, ConstantVariables.REWARD_BROWSE_PAGE);
                            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                            break;

                        case "manage_leader":
                            Intent leaderActivity = new Intent(mContext, ManageLeadersActivity.class);
                            leaderActivity.putExtra(ConstantVariables.CONTENT_ID, mProjectId);
                            startActivity(leaderActivity);
                            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                            break;
                    }
                }
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onItemDelete(int position) {
        SnackbarUtils.displaySnackbarLongTime(findViewById(android.R.id.content),
                getResources().getString(R.string.project_deleted_successfully));
        isProjectEdited = true;
        onBackPressed();
        LogUtils.LOGD(" Data ", " OnItemDelete " + position);
    }

    @Override
    public void onItemActionSuccess(int position, Object itemList, String menuName) {
        LogUtils.LOGD("onItemActionSuccess: ", "onItemActionSuccess :: menuName | " + menuName);
        switch (menuName) {
            case "remove_photo":
                reloadProfile(getResources().getString(R.string.removed_profile_photo));
                break;
        }
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        menu.clear();
        if (mGutterMenus != null && mGutterMenus.size() > 0) {
            mGutterMenuUtils.showOptionMenus(menu, mGutterMenus, menuData);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.default_menu_item, menu);
        return true;
    }

    @Override
    public void onItemDelete(String successMessage) {

    }

    @Override
    public void onOptionItemActionSuccess(Object itemList, String menuName) {
        switch (menuName) {
            case "view_profile_photo":
                openLightBox();
                break;

            case "upload_photo":
                if (!mAppConst.checkManifestPermission(Manifest.permission.READ_EXTERNAL_STORAGE)) {
                    mAppConst.requestForManifestPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                            ConstantVariables.READ_EXTERNAL_STORAGE);
                } else {
                    uploadImage();
                }
                break;

            case "choose_from_album":
                Bundle bundle = new Bundle();
                bundle.putString(ConstantVariables.FRAGMENT_NAME, "photos");
                bundle.putString(ConstantVariables.CONTENT_TITLE, mContext.getResources().getString(R.string.choose_from_photos));
                bundle.putString(ConstantVariables.URL_STRING, UrlUtil.VIEW_PHOTOS_URL);
                bundle.putInt(ConstantVariables.SUBJECT_ID, Integer.parseInt(mProjectId));
                bundle.putString(ConstantVariables.SUBJECT_TYPE, "sitecrowdfunding_project");
                bundle.putBoolean("isCoverRequest", false);
                bundle.putBoolean("isCoverChange", true);
                Intent newIntent = new Intent(mContext, FragmentLoadActivity.class);
                newIntent.putExtras(bundle);
                startActivityForResult(newIntent, ConstantVariables.FILE_UPLOAD_REQUEST);
                ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;
            case "remove_photo":

                break;

        }
    }

    public void doFavouriteAction() {
        mProject.isFavourite = !mProject.isFavourite;
        if (mProject != null && mProject.isFavourite) {
            favourite.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_SOLID_HEART));
            favourite.setTextColor(getResources().getColor(R.color.red));
            postParams.put("value", "1");
        } else {
            favourite.setText(GlobalFunctions.getItemIcon(ConstantVariables.ICON_SOLID_HEART));
            favourite.setTextColor(getResources().getColor(R.color.white));
            postParams.put("value", "0");
        }
    }

    public void doLikeUnlikeAction() {
        mProject.isLike = !mProject.isLike;
        if (mProject.isLike) {
            likeProject.setTextColor(getResources().getColor(R.color.colorPrimary));
            mLikeUnlikeURL = UrlUtil.ITEM_LIKE_URL;
        } else {
            likeProject.setTextColor(getResources().getColor(R.color.white));
            mLikeUnlikeURL = UrlUtil.ITEM_UNLIKE_URL;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (resultCode) {
            case ConstantVariables.VIEW_PAGE_EDIT_CODE:
            case ConstantVariables.PAGE_EDIT_CODE:
                if (requestCode == ConstantVariables.FILE_UPLOAD_REQUEST && data != null) {
                    ArrayList<String> resultList = data.getStringArrayListExtra(ConstantVariables.PHOTO_LIST);
                    String postUrl = UrlUtil.UPLOAD_COVER_PHOTO_URL + "&special=profile&subject_type=sitecrowdfunding_project" +
                            "&subject_id=" + mProjectId;
                    successMessage = mContext.getResources().getString(R.string.profile_photo_updated);
                    new UploadFileToServerUtils(mContext, postUrl, resultList, this).execute();
                } else {
                    mProjectPresenter.doRequest(mProjectViewURL);
                    mProgressBar.setVisibility(View.VISIBLE);
                    isProjectEdited = true;
                    if (requestCode == ConstantVariables.PROJECT_EDIT_BIO_REQUEST_CODE) {
                        isShowBio = true;
                    }
                }

                break;
            case RESULT_OK:
                if (!(data != null && data.getIntExtra(ConstantVariables.KEY_PAYMENT_REQUEST, 0) == ConstantVariables.PAYMENT_SUCCESS_ACTIVITY_CODE)) {
                    break;
                }
            case ConstantVariables.PAYMENT_SUCCESS_ACTIVITY_CODE:
                if (mBackThisProject != null) {
                    mBackThisProject.dismiss();
                    onBackPressed();
                }
                mProjectPresenter.doRequest(mProjectViewURL);
                mProgressBar.setVisibility(View.VISIBLE);
                isProjectEdited = true;
                break;
            case 0:
                if (BrowseRewardsFragment.isEditedReward()) {
                    BrowseRewardsFragment.setEditedReward(false);
                    mProjectPresenter.doRequest(mProjectViewURL);
                    mProgressBar.setVisibility(View.VISIBLE);
                }
                break;

        }
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.upload_profile:
                mGutterMenuUtils.showPopup(uploadProfile, 0, menuData, null, mProject.profilePhotoMenu);
                break;
            case R.id.like_profile:
                doLikeUnlikeAction();
                mProjectPresenter.doPostRequest(mLikeUnlikeURL, postParams);
                isProjectEdited = true;
                break;
            case R.id.favourite:
                mProjectPresenter.doPostRequest(UrlUtil.CROWD_FUNDING_PROJECT_FAVOURITE_URL + mProject.project_id, postParams);
                doFavouriteAction();
                isProjectEdited = true;
                break;
            case R.id.owner_info:
                if (ownerInfo.isActivated()) {
                    ownerInfo.setActivated(false);
                    ownerInfoBlock.setVisibility(View.VISIBLE);
                } else {
                    ownerInfo.setActivated(true);
                    ownerInfoBlock.setVisibility(View.GONE);
                }
                break;
            case R.id.back_this_project:
                FragmentManager sFragmentManager = getSupportFragmentManager();
                mBackThisProject = new BackThisProjectFragment();
                Bundle args = new Bundle();
                args.putString(ConstantVariables.CONTENT_ID, mProjectId);
                args.putString(ConstantVariables.CONTENT_TITLE, mProject.title);
                args.putBoolean("hasReward", mProject.hasReward);
                args.putString("currency",  mProject.currency);
                mBackThisProject.setArguments(args);
                FragmentTransaction fragmentTransaction = sFragmentManager.beginTransaction();
                fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
                fragmentTransaction.add(android.R.id.content, mBackThisProject).addToBackStack(null).commit();
                break;

            case R.id.full_bio:
                renderBiography();
                break;
            case R.id.contact:
            case R.id.contact_owner:
                doOwnerMessage();
                break;
            case R.id.project_location:
                openInMap();
                break;
            case R.id.project_category:
                browseByCategory();
                break;
            case R.id.project_thumb:
            case R.id.thumb:
                openLightBox();
                break;
            case R.id.owner_name:
            case R.id.owner_thumb:
                Intent ownerProfile = new Intent(mContext, userProfile.class);
                ownerProfile.putExtra(ConstantVariables.USER_ID, mProject.owner_id);
                startActivity(ownerProfile);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;
            case R.id.share_project:
                mSocialShareUtil.sharePost(view, getResources().getString(R.string.share), mProject.image, mProject.content_url, null, mProject.content_url);
                break;
        }
    }

    private void uploadImage() {
        Intent intent = new Intent(mContext, PhotoUploadingActivity.class);
        intent.putExtra("selection_mode", true);
        intent.putExtra(ConstantVariables.IS_PHOTO_UPLOADED, true);
        startActivityForResult(intent, ConstantVariables.FILE_UPLOAD_REQUEST);
    }

    public void openLightBox() {

        Bundle bundle = new Bundle();
        bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mProfileImageDetails);
        Intent i = new Intent(mContext, PhotoLightBoxActivity.class);
        i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, 1);
        i.putExtra(ConstantVariables.SHOW_OPTIONS, false);
        i.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
        i.putExtras(bundle);
        startActivityForResult(i, ConstantVariables.VIEW_LIGHT_BOX);
    }

    @Override
    public void onUploadResponse(JSONObject jsonObject, boolean isRequestSuccessful) {
        if (isRequestSuccessful) {
            reloadProfile(successMessage);
            isProjectEdited = true;
        } else {
            SnackbarUtils.displaySnackbarLongTime(findViewById(android.R.id.content), jsonObject.optString("message"));
        }
    }

    private void reloadProfile(String message) {
        SnackbarUtils.displaySnackbarLongTime(findViewById(android.R.id.content), message);
        mProgressBar.setVisibility(View.VISIBLE);
        mProgressBar.bringToFront();
        mProjectPresenter.doRequest(mProjectViewURL);
        isProjectEdited = true;
    }

    private void doOwnerMessage() {
        if (!this.hasOwnerInfo()) {
            return;
        }
        Intent intent = new Intent(mContext, CreateNewMessage.class);
        intent.putExtra(ConstantVariables.USER_ID, mProject.owner_id);
        intent.putExtra(ConstantVariables.CONTENT_TITLE, mProject.owner_title);
        intent.putExtra("isSendMessageRequest", true);
        mContext.startActivity(intent);
        ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

    }

    private boolean hasOwnerInfo() {
        if (mProject.biography != null && mProject.biography.projectOwnerInfo != null) {
            return true;
        } else {
            return false;
        }
    }

    @Override
    public void onPanelClosed(int featureId, Menu menu) {
        super.onPanelClosed(featureId, menu);
        if (resetMenu) {
            MenuUtils.selectedSubMenuAt = -1;
            resetMenu = false;
        }
    }

    @Override
    public boolean onMenuOpened(int featureId, Menu menu) {
        if (MenuUtils.selectedSubMenuAt > 0) {
            resetMenu = true;
        }
        return super.onMenuOpened(featureId, menu);
    }

    @Override
    public void onBackPressed() {
        if (isProjectEdited) {
            setResult(ConstantVariables.PAGE_EDIT_CODE);
        }
        super.onBackPressed();
    }

    @Override
    public void onScrollChanged(int scrollY, boolean firstScroll, boolean dragging) {
        if (!isLoaded) {
            return;
        }
        int[] location = new int[2];
        mTabLayout.getLocationOnScreen(location);
        int position = mToolbar.getHeight() + (int) mToolbar.getY() + statusBarHeight;
        BaseFragment baseFragment = mPagerAdapter.getItem(mPager.getCurrentItem());
        int margin = (int ) mContext.getResources().getDimension(R.dimen.dimen_5dp);
        if (position >= (location[1] - margin)) {
            baseFragment.setNestedScrollingEnabled(true);
        } else {
            baseFragment.setNestedScrollingEnabled(false);
        }

    }

    @Override
    public void onDownMotionEvent() {

    }

    @Override
    public void onUpOrCancelMotionEvent(ScrollState scrollState) {
        if (scrollState == ScrollState.STOP && isLoaded) {
            BaseFragment baseFragment = mPagerAdapter.getItem(mPager.getCurrentItem());
            baseFragment.setNestedScrollingEnabled(true);
        }
    }

    private void openInMap() {
        if (GlobalFunctions.isMapAppEnabled(mContext)) {
            Uri mapUri = Uri.parse("geo:0,0?q=" + Uri.encode(mProject.location));
            Intent mapIntent = new Intent(Intent.ACTION_VIEW, mapUri);
            mapIntent.setPackage("com.google.android.apps.maps");
            startActivity(mapIntent);
        } else {
            Intent mapIntent = new Intent(mContext, MapActivity.class);
            mapIntent.putExtra("location", mProject.location);
            startActivity(mapIntent);
            ((Activity) mContext).overridePendingTransition(R.anim.slide_up_in, R.anim.push_up_out);

        }
    }

    private void browseByCategory() {
        Bundle bundle = new Bundle();
        bundle.putString(ConstantVariables.URL_STRING, UrlUtil.CROWD_FUNDING_CATEGORY_URL);
        bundle.putString(ConstantVariables.FRAGMENT_NAME, ConstantVariables.CROWD_FUNDING_MAIN_TITLE);
        bundle.putString(ConstantVariables.CONTENT_TITLE, mProject.category_name);
        bundle.putInt(ConstantVariables.VIEW_PAGE_ID, mProject.category_id);
        bundle.putBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, true);
        Intent intent = new Intent(mContext, FragmentLoadActivity.class);
        intent.putExtras(bundle);
        startActivity(intent);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case ConstantVariables.READ_EXTERNAL_STORAGE:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    uploadImage();
                }
        }
    }

    public void setMarqueeToolBar(){
        TextView titleTextView = null;

        try {
            Field f = mToolbar.getClass().getDeclaredField("mTitleTextView");
            f.setAccessible(true);
            titleTextView = (TextView) f.get(mToolbar);

            titleTextView.setEllipsize(TextUtils.TruncateAt.MARQUEE);
            titleTextView.setFocusable(true);
            titleTextView.setFocusableInTouchMode(true);
            titleTextView.requestFocus();
            titleTextView.setSingleLine(true);
            titleTextView.setSelected(true);
            titleTextView.setMarqueeRepeatLimit(-1);

        } catch (NoSuchFieldException e) {
        } catch (IllegalAccessException e) {
        }
    }

    private void addBioPopUp() {
        AlertDialog.Builder mDialogBuilder = new AlertDialog.Builder(mContext);
        mDialogBuilder.setTitle(mContext.getResources().getString(R.string.manage_bio));
        mDialogBuilder.setCancelable(false);
        mDialogBuilder.setMessage(mContext.getResources().getString(R.string.add_bio_popup_description));
        mDialogBuilder.setPositiveButton(mContext.getResources().getString(R.string.manage), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                Intent editBio = new Intent(mContext, EditEntry.class);
                editBio.putExtra(ConstantVariables.URL_STRING, UrlUtil.CROWD_FUNDING_PROJECT_ADD_BIO_URL + mProject.project_id);
                editBio.putExtra(ConstantVariables.KEY_TOOLBAR_TITLE, mContext.getResources().getString(R.string.about_you));
                editBio.putExtra(ConstantVariables.KEY_SUCCESS_MESSAGE, mContext.getResources().getString(R.string.information_edited_successfully));
                startActivityForResult(editBio, ConstantVariables.PROJECT_EDIT_BIO_REQUEST_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            }
        });
        mDialogBuilder.setNegativeButton(mContext.getResources().getString(R.string.later), null);
        AlertDialog alertDialog = mDialogBuilder.create();
        alertDialog.getWindow().getAttributes().windowAnimations = R.style.customDialogAnimation;
        alertDialog.show();
    }

    private void renderBiography() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        OwnerBiographyFragment ownerBiography = new OwnerBiographyFragment();
        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        transaction.add(android.R.id.content, ownerBiography).addToBackStack(null).commit();
    }
}
