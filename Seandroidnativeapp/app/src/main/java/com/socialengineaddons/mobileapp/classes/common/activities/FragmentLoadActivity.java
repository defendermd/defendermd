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

package com.socialengineaddons.mobileapp.classes.common.activities;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.support.design.widget.FloatingActionButton;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Toast;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.fragments.AdvReviewFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.MemberFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.ModulesHomeFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.PhotoFragment;
import com.socialengineaddons.mobileapp.classes.common.fragments.UserReviewFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnUploadResponseListener;
import com.socialengineaddons.mobileapp.classes.common.multimediaselector.MultiMediaSelectorActivity;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;

import com.socialengineaddons.mobileapp.classes.common.utils.UploadFileToServerUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.core.MainActivity;
import com.socialengineaddons.mobileapp.classes.modules.advancedEvents.AdvEventGuestDetailsFragment;
import com.socialengineaddons.mobileapp.classes.modules.advancedEvents.AdvEventsUtil;
import com.socialengineaddons.mobileapp.classes.modules.advancedGroups.AdvGroupUtil;
import com.socialengineaddons.mobileapp.classes.modules.advancedVideos.AdvVideoUtil;
import com.socialengineaddons.mobileapp.classes.modules.album.AlbumPhotosFragment;
import com.socialengineaddons.mobileapp.classes.modules.album.AlbumUtil;
import com.socialengineaddons.mobileapp.classes.modules.directoryPages.SitePageUtil;
import com.socialengineaddons.mobileapp.classes.modules.multipleListingType.MLTUtil;
import com.socialengineaddons.mobileapp.classes.modules.offers.BrowseOffersFragment;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.BrowseRewardsFragment;
import com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding.ProjectInvoiceFragment;
import com.socialengineaddons.mobileapp.classes.modules.store.fragments.BrowseProductFragment;
import com.socialengineaddons.mobileapp.classes.modules.store.utils.StoreUtil;
import com.socialengineaddons.mobileapp.classes.modules.user.BrowseMemberFragment;
import com.socialengineaddons.mobileapp.classes.modules.user.profile.MemberInfoFragment;
import com.socialengineaddons.mobileapp.classes.modules.user.staticpages.FooterMenusFragment;
import com.socialengineaddons.mobileapp.classes.modules.video.VideoUtil;

import org.json.JSONObject;

import java.util.ArrayList;

import static com.socialengineaddons.mobileapp.R.id.action_message;
import static com.socialengineaddons.mobileapp.R.id.search_occurrence;


public class FragmentLoadActivity extends AppCompatActivity implements View.OnClickListener, OnUploadResponseListener {

    public static Fragment loadFragment;
    private String mFragmentName;
    private int mTotalItemCount, listingId, listingTypeId, mCanUpload;
    private String mContentTitle, mTabLabel;
    private Toolbar mToolbar;
    private Context mContext;
    private Bundle bundle;
    private String currentSelectedOption = null, mPhotoUploadUrl;
    private FloatingActionButton fabAdd;
    private AppConstant mAppConst;
    private FloatingActionButton mFabCreate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_container);

        try {
            //Setting up the action bar
            mToolbar = (Toolbar) findViewById(R.id.toolbar);
            mFabCreate = (FloatingActionButton) findViewById(R.id.create_fab);
            mContext = this;
            bundle = getIntent().getExtras();

            mAppConst = new AppConstant(mContext);
            mFragmentName = bundle.getString(ConstantVariables.FRAGMENT_NAME);
            mContentTitle = bundle.getString(ConstantVariables.CONTENT_TITLE);
            mTotalItemCount = bundle.getInt(ConstantVariables.TOTAL_ITEM_COUNT, 0);
            mCanUpload = bundle.getInt(ConstantVariables.CAN_UPLOAD, 0);
            currentSelectedOption = bundle.getString(ConstantVariables.EXTRA_MODULE_TYPE);

            if (loadFragment == null) {
                Object object = GlobalFunctions.invokeMethod(mContext.getPackageName() + ".classes.modules.sitecrowdfunding.utils.CoreUtil","setLoadFragment", bundle);
                loadFragment = (object != null) ? (Fragment) object : null;
            }
            //Getting intent data from MLT.
            listingTypeId = bundle.getInt(ConstantVariables.LISTING_TYPE_ID, 0);
            listingId = bundle.getInt(ConstantVariables.LISTING_ID, 0);
            mTabLabel = getIntent().getStringExtra(ConstantVariables.TAB_LABEL);

            mFabCreate.hide();
            mFabCreate.setOnClickListener(this);

            switch (mFragmentName) {
                case "members":
                    switch (currentSelectedOption) {
                        case ConstantVariables.GROUP_MENU_TITLE:
                        case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                            mToolbar.setTitle(getResources().getString(R.string.action_bar_title_members)
                                    + " (" + mTotalItemCount + ")" + ": " + mContentTitle);
                            loadFragment = new MemberFragment();
                            break;
                        case ConstantVariables.EVENT_MENU_TITLE:
                            mToolbar.setTitle(getResources().getString(R.string.action_bar_title_guests)
                                    + " (" + mTotalItemCount + ")" + ": " + mContentTitle);
                            loadFragment = new MemberFragment();
                            break;

                        case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
                            mToolbar.setTitle(getResources().getString(R.string.action_bar_title_guests)
                                    + " (" + mTotalItemCount + ")" + ": " + mContentTitle);
                            loadFragment = new AdvEventGuestDetailsFragment();
                            break;

                    }
                    break;

                case "album":
                    if (bundle.containsKey("isCoverRequest")) {
                        mToolbar.setTitle(mContentTitle);
                    }
                    loadFragment = AlbumUtil.getBrowsePageInstance();
                    break;

                case "isMemberDiaries":
                    mToolbar.setTitle(mContentTitle);
                    loadFragment = AdvEventsUtil.getBrowseDiariesInstance();
                    bundle.putBoolean("isMemberDiaries", true);
                    break;

                case "waiting_member":
                    switch (currentSelectedOption) {
                        case ConstantVariables.GROUP_MENU_TITLE:
                        case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                            mToolbar.setTitle(getResources().getString(R.string.waiting_members_text));
                            break;

                        case ConstantVariables.EVENT_MENU_TITLE:
                        case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
                            mToolbar.setTitle(getResources().getString(R.string.waiting_guests_text));
                            break;
                    }
                    loadFragment = new MemberFragment();
                    bundle.putBoolean("isWatingMember", true);
                    break;

                case "announcement":
                    mToolbar.setTitle(mContentTitle + " (" + mTotalItemCount + ")");
                    loadFragment = new MemberInfoFragment();
                    bundle.putString(ConstantVariables.FORM_TYPE, "announcement");
                    break;

                case "search_by_date":
                    mToolbar.setTitle(getResources().getString(R.string.action_bar_title_event) + ": " + mContentTitle);
                    loadFragment = AdvEventsUtil.getBrowsePageInstance();
                    bundle.putString(AdvEventsUtil.EVENT_TYPE, AdvEventsUtil.SEARCH_BY_DATE);
                    break;

                case "group_categories":
                    mToolbar.setTitle(mContentTitle + ": " + mTotalItemCount);
                    loadFragment = AdvGroupUtil.getBrowsePageInstance();
                    bundle.putBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, true);
                    break;

                case "adv_events_categories":
                    mToolbar.setTitle(mContentTitle + ": " + mTotalItemCount);
                    loadFragment = AdvEventsUtil.getBrowsePageInstance();
                    bundle.putString(AdvEventsUtil.EVENT_TYPE, AdvEventsUtil.CATEGORY_FILTER);
                    break;

                case "site_page_categories":
                    mToolbar.setTitle(mContentTitle + ": " + mTotalItemCount);
                    loadFragment = SitePageUtil.getBrowsePageInstance();
                    bundle.putBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, true);
                    break;

                case "mlt_categories":
                    loadFragment = MLTUtil.getBrowsePageInstance();
                    //TODO
//                    if (MLTUtil.getSelectedViewType() == 4) {
//                        mToolbar.setTitle(mContentTitle);
//                    } else {
//                        mToolbar.setTitle(mContentTitle + ": " + mTotalItemCount);
//                    }
                    mToolbar.setTitle(mContentTitle + ": " + mTotalItemCount);
                    bundle.putBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, true);
                    break;

                case "store_product_categories":
                    mToolbar.setTitle(mContentTitle + ": " + mTotalItemCount);
                    loadFragment = StoreUtil.getProductsBrowsePageInstance();
                    bundle.putBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, true);
                    break;

                case "adv_videos_categories":
                    mToolbar.setTitle(mContentTitle + ": " + mTotalItemCount);
                    loadFragment = AdvVideoUtil.getBrowsePageInstance();
                    bundle.putBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, true);
                    break;

                case "adv_videos_channel_categories":
                    mToolbar.setTitle(mContentTitle + ": " + mTotalItemCount);
                    loadFragment = AdvVideoUtil.getChannelBrowsePageInstance();
                    bundle.putBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, true);
                    break;

                case "reviews":
                    switch (currentSelectedOption) {
                        case ConstantVariables.MLT_MENU_TITLE:
                        case ConstantVariables.ADVANCED_EVENT_MENU_TITLE:
                        case ConstantVariables.PRODUCT_MENU_TITLE:
                            if (mTabLabel == null || mTabLabel.isEmpty()) {
                                mTabLabel = getResources().getString(R.string.user_review);
                                bundle.putString(ConstantVariables.TAB_LABEL, mTabLabel);
                            }
                            mToolbar.setTitle(mTabLabel);
                            loadFragment = new UserReviewFragment();
                            break;

                        case ConstantVariables.ADV_GROUPS_MENU_TITLE:
                        case ConstantVariables.SITE_PAGE_MENU_TITLE:
                            mToolbar.setTitle(getResources().getString(R.string.user_review));
                            loadFragment = new AdvReviewFragment();
                            break;
                    }
                    break;

                case "offer":
                    mToolbar.setTitle(getResources().getString(R.string.action_bar_title_offers) + " (" + mTotalItemCount + ")" + ": " + mContentTitle);
                    loadFragment = new BrowseOffersFragment();
                    break;

                case "photos":
                    if (bundle.containsKey("isCoverRequest")) {
                        mToolbar.setTitle(mContentTitle);
                    } else {
                        mToolbar.setTitle(getResources().getString(R.string.action_bar_title_photos) +
                                " (" + mTotalItemCount + ")" + ": " + mContentTitle);
                    }
                    if (mCanUpload == 1) {
                        mFabCreate.show();
                        mPhotoUploadUrl = bundle.getString(ConstantVariables.PHOTO_REQUEST_URL);
                    } else {
                        mFabCreate.hide();
                    }
                    loadFragment = new PhotoFragment();
                    break;

                case "occurence_index":
                    mToolbar.setTitle(mContentTitle);
                    loadFragment = new AdvEventGuestDetailsFragment();
                    break;

                case "video":
                case "videos":
                    mToolbar.setTitle(mContentTitle + " (" + mTotalItemCount + ")");
                    loadFragment = VideoUtil.getBrowsePageInstance();
                    break;
                case "store_categories":
                    mToolbar.setTitle(mContentTitle + " (" + mTotalItemCount + ")");
                    bundle.putBoolean(ConstantVariables.IS_CATEGORY_BASED_RESULTS, true);
                    loadFragment = StoreUtil.getBrowseStoreInstance();
                    break;
                case ConstantVariables.SELECT_PRODUCT:
                    mToolbar.setTitle(mContentTitle);
                    bundle.putBoolean(ConstantVariables.SELECT_PRODUCT, true);
                    loadFragment = StoreUtil.getBrowseProductPageInstance();
                    break;
                case "story_viewer":
                    mToolbar.setTitle(mContentTitle);
                    loadFragment = new BrowseMemberFragment();
                    break;
                case ConstantVariables.CONTACT_US_MENU_TITLE:
                    mToolbar.setTitle(mContentTitle);
                    bundle.putString("currentOption", ConstantVariables.CONTACT_US_MENU_TITLE);
                    loadFragment = new FooterMenusFragment();
                    break;

                case ConstantVariables.TERMS_OF_SERVICE_MENU_TITLE:
                    mToolbar.setTitle(mContentTitle);
                    bundle.putString("currentOption", ConstantVariables.TERMS_OF_SERVICE_MENU_TITLE);
                    loadFragment = new FooterMenusFragment();
                    break;

                case ConstantVariables.PRIVACY_POLICY_MENU_TITLE:
                    mToolbar.setTitle(mContentTitle);
                    bundle.putString("currentOption",ConstantVariables.PRIVACY_POLICY_MENU_TITLE);
                    loadFragment=new FooterMenusFragment();
                    break;

                case "contact_info":
                    if (bundle.getInt(ConstantVariables.IS_OWNER) == 1) {
                        mFabCreate.show();
                    } else {
                        mFabCreate.hide();
                    }
                    mToolbar.setTitle(mContentTitle);
                    loadFragment = new MemberInfoFragment();
                    bundle.putBoolean("isContactInfo", true);
                    break;
                case ConstantVariables.NOTIFICATION_MENU_TITLE:
                    PreferencesUtils.updateCurrentModule(mContext, ConstantVariables.NOTIFICATION_MENU_TITLE);
                    loadFragment = new ModulesHomeFragment();
                    mToolbar.setTitle(mContentTitle);
                    break;
                case "invoice":
                    loadFragment = new ProjectInvoiceFragment();
                    mToolbar.setTitle(mContentTitle);
                    break;
                case "album_photos":
                    loadFragment = new AlbumPhotosFragment();
                    mToolbar.setTitle(mContentTitle);
                    break;
                default:
                    mToolbar.setTitle(mContentTitle);
                    break;
            }

            if (loadFragment != null) {
                loadFragment.setArguments(bundle);
                FragmentManager fragmentManager = getSupportFragmentManager();
                FragmentTransaction ft = fragmentManager.beginTransaction();
                ft.replace(R.id.main_content, loadFragment);
                ft.commit();
            }

            setSupportActionBar(mToolbar);
            if (getSupportActionBar() != null) {
                getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            }
            CustomViews.createMarqueeTitle(mContext, mToolbar);
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_fragment_load, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        switch (id) {
            case android.R.id.home:
                onBackPressed();
                // Playing backSound effect when user tapped on back button from tool bar.
                if (PreferencesUtils.isSoundEffectEnabled(mContext)) {
                    SoundUtil.playSoundEffectOnBackPressed(mContext);
                }
                return true;

            case R.id.add_entry:
                // TODO in future
                String redirectUrl = AppConstant.DEFAULT_URL + "listings/video/create/" + listingId +
                        "?listingtype_id=" + listingTypeId;
                Intent createEntry = new Intent(FragmentLoadActivity.this, CreateNewEntry.class);
                createEntry.putExtra(ConstantVariables.CREATE_URL, redirectUrl);
                createEntry.putExtra(ConstantVariables.FORM_TYPE, "add_video");
                createEntry.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.MLT_MENU_TITLE);
                startActivityForResult(createEntry, ConstantVariables.CREATE_REQUEST_CODE);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                break;

            case R.id.search_occurrence:
                return false;

            case R.id.action_message:
                return false;
            case R.id.submit:
                if (loadFragment != null && loadFragment instanceof BrowseProductFragment){
                    Intent intent = new Intent();
                    intent.putStringArrayListExtra(ConstantVariables.SELECT_PRODUCT,((BrowseProductFragment)loadFragment).getSelectedProducts());
                    setResult(ConstantVariables.SELECT_PRODUCT_RETURN_CODE, intent);
                }
                finish();
                overridePendingTransition(0, R.anim.push_down_out);
                break;

        }

        return super.onOptionsItemSelected(item);
    }

    /***
     * Called when invalidateOptionsMenu() is triggered
     */
    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {

        MenuItem addEntry = menu.findItem(R.id.add_entry);
        MenuItem searchOccurrence = menu.findItem(search_occurrence);
        MenuItem composeMessage = menu.findItem(action_message);
        MenuItem search = menu.findItem(R.id.action_search);
        MenuItem contact = menu.findItem(R.id.post_contact);
        MenuItem okMenu = menu.findItem(R.id.submit);
        if (okMenu != null) {
            Drawable drawable = okMenu.getIcon();
            drawable.setColorFilter(ContextCompat.getColor(this, R.color.textColorPrimary), PorterDuff.Mode.SRC_ATOP);
        }

        if (mFragmentName != null) {
            switch (mFragmentName) {
                case "members":
                case "wating_member":
                    addEntry.setVisible(false);
                    search.setVisible(true);
                    if (currentSelectedOption.equals("core_main_siteevent") && !PreferencesUtils.getMessagingType(mContext).equals("none")) {
                        composeMessage.setVisible(true);
                    }
                    break;
                case "occurence_index":
                    search.setVisible(false);
                    if (!PreferencesUtils.getMessagingType(mContext).equals("none")) {
                        composeMessage.setVisible(true);
                    }
                    searchOccurrence.setVisible(true);
                    break;
                case ConstantVariables.CONTACT_US_MENU_TITLE:
                    contact.setVisible(true);
                    break;
                case ConstantVariables.SELECT_PRODUCT:
                    okMenu.setVisible(true);
                    break;
            }

        }

        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        if (mFragmentName != null && mFragmentName.equals(ConstantVariables.CONTACT_US_MENU_TITLE)) {
            startActivity(new Intent(FragmentLoadActivity.this, MainActivity.class));
        }
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode,resultCode,data);
        switch(requestCode) {
            case ConstantVariables.REQUEST_IMAGE:
                switch (resultCode) {
                    case Activity.RESULT_OK:
                        ArrayList<String> mSelectPath = data.getStringArrayListExtra(MultiMediaSelectorActivity.EXTRA_RESULT);
                        // uploading the photos to server
                        new UploadFileToServerUtils(mContext, mPhotoUploadUrl, mSelectPath, this).execute();
                        break;

                    case Activity.RESULT_CANCELED:
                        break;

                    default:
                        // failed to capture image
                        Toast.makeText(mContext, getResources().getString(R.string.image_capturing_failed),
                                Toast.LENGTH_SHORT).show();
                        break;
                }
                break;
            case ConstantVariables.USER_PROFILE_CODE:
                PreferencesUtils.updateCurrentModule(mContext, currentSelectedOption);
                break;
            case ConstantVariables.PAGE_EDIT_CODE:
                if (resultCode == ConstantVariables.CONTACT_INFO_CODE) {
                    Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.main_content);
                    fragment.onActivityResult(requestCode, resultCode, data);
                } else if (loadFragment instanceof BrowseRewardsFragment){
                    loadFragment.onActivityResult(requestCode, resultCode, data);
                    return;
                }
                break;

        }
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {
            case R.id.create_fab:
                if (mFragmentName != null && mFragmentName.equals("contact_info")) {
                    int mPageId = bundle.getInt("page_id");
                    String contactUrl = UrlUtil.CONTACT_INFORMATION_URL + mPageId;
                    Intent intent = new Intent(mContext, EditEntry.class);
                    intent.putExtra(ConstantVariables.URL_STRING, contactUrl);
                    intent.putExtra(ConstantVariables.FORM_TYPE, "contact_info");
                    intent.putExtra(ConstantVariables.EXTRA_MODULE_TYPE, ConstantVariables.CONTACT_INFO_MENU_TITLE);
                    startActivityForResult(intent, ConstantVariables.PAGE_EDIT_CODE);
                    overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
                } else if (currentSelectedOption.equals(ConstantVariables.PRODUCT_MENU_TITLE)) {
                    checkPermission();
                }
                break;
        }
    }
    /**
     * Method to start photo uploading activity.
     */
    public void startPhotoUploading() {
        Intent intent = new Intent(mContext, PhotoUploadingActivity.class);
        startActivityForResult(intent, ConstantVariables.REQUEST_IMAGE);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    /**
     * Method to check permission for the photo access.
     */
    public void checkPermission() {
        if (!mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    ConstantVariables.WRITE_EXTERNAL_STORAGE);
        } else {
            startPhotoUploading();
        }

    }

    @Override
    public void onUploadResponse(JSONObject jsonObject, boolean isRequestSuccessful) {
        if(isRequestSuccessful) {
            int uploadedCount = jsonObject.optJSONObject("body") != null ? jsonObject.optJSONObject("body").optInt("photoCount",0) : mTotalItemCount;
            mToolbar.setTitle(getResources().getString(R.string.action_bar_title_photos) +
                    " (" + ( uploadedCount )+ ")" + ": " + mContentTitle);
            loadFragment = new PhotoFragment();
            loadFragment.setArguments(bundle);
            FragmentManager fragmentManager = getSupportFragmentManager();
            FragmentTransaction ft = fragmentManager.beginTransaction();
            ft.replace(R.id.main_content, loadFragment);
            ft.commit();
        }
    }

    @Override
    protected void onDestroy() {
        FragmentLoadActivity.loadFragment = null;
        super.onDestroy();
    }
}
