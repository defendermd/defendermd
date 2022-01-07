package com.socialengineaddons.mobileapp.classes.modules.qrscanner;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.AdvModulesManageDataAdapter;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnCommunityAdsLoadedListener;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.GridViewWithHeaderAndFooter;
import com.socialengineaddons.mobileapp.classes.common.utils.BrowseListItems;
import com.socialengineaddons.mobileapp.classes.common.utils.CommunityAdsList;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.core.MainActivity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class QRScannerFragment extends Fragment implements OnCommunityAdsLoadedListener {

    private View rootView, footerView;
    private Context mContext;
    private AppConstant mAppConst;
    private GridViewWithHeaderAndFooter mGridView;
    private List<Object> mBrowseItemList;
    private BrowseListItems mBrowseList;
    private AdvModulesManageDataAdapter mManageDataAdapter;
    private JSONArray mDataResponse, mAdvertisementsArray;
    private SwipeRefreshLayout refreshLayout;
    private TextView tvAdsHeadline, tvThanksGiving;
    private android.support.v7.app.AlertDialog.Builder mDialogBuilder;
    private boolean isShowPopup = true, isNoAds;
    private String mSubjectType = null, mSubjectId = null;

    public QRScannerFragment() {

    }

    public static QRScannerFragment newInstance(Bundle bundle) {
        QRScannerFragment fragment = new QRScannerFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void setMenuVisibility(boolean menuVisible) {
        if (rootView != null) {
            rootView.setVisibility(View.GONE);
        }
        if (menuVisible) {
            _initScan();
        }
        super.setMenuVisibility(menuVisible);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        mBrowseItemList = new ArrayList<>();
        mBrowseList = new BrowseListItems();
        mContext = getContext();
        mAppConst = new AppConstant(mContext);
        mAppConst.setOnCommunityAdsLoadedListener(this);

        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.qr_scanner_view, null);
        footerView = CustomViews.getFooterView(inflater);

        tvAdsHeadline = rootView.findViewById(R.id.tvAdsHeadline);
        tvThanksGiving = rootView.findViewById(R.id.tvThanksGiving);
        refreshLayout = rootView.findViewById(R.id.swipe_refresh_layout);
        refreshLayout.setOnRefreshListener(null);
        refreshLayout.setEnabled(false);
        refreshLayout.setRefreshing(false);
        mGridView = (GridViewWithHeaderAndFooter) rootView.findViewById(R.id.gridView);

        mGridView.addFooterView(footerView);
        footerView.setVisibility(View.GONE);
        CustomViews.initializeGridLayout(mContext, AppConstant.getNumOfColumns(mContext), mGridView);
        ViewCompat.setNestedScrollingEnabled(mGridView, true);
        mManageDataAdapter = new AdvModulesManageDataAdapter(getActivity(), R.layout.list_advanced_event_info,
                mBrowseItemList, "manage_siteevent", QRScannerFragment.this);
        mGridView.setAdapter(mManageDataAdapter);

        return rootView;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        IntentResult result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
        if (result != null) {
            if (result.getContents() != null) {
                getCommunityAds(result.getContents());
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }

    private void _initScan() {
        IntentIntegrator integrator = new IntentIntegrator(getActivity());
        integrator.setPrompt("Scan A QRCode");
        integrator.setDesiredBarcodeFormats(integrator.ALL_CODE_TYPES);
        integrator.setOrientationLocked(false);
        integrator.setCaptureActivity(ScannerActivity.class);
        integrator.initiateScan();
        isShowPopup = true;
    }

    @Override
    public void onCommunityAdsLoaded(JSONArray advertisementsArray) {

    }

    private void getCommunityAds(String queryString) {
        mAppConst.showProgressDialog();
        String communityAdsUrl = AppConstant.DEFAULT_URL + "communityads/page-ads?";
        Map<String, String> params = new HashMap<>();
        params.put("qr_key", queryString);
        communityAdsUrl = mAppConst.buildQueryString(communityAdsUrl, params);
        mAppConst.getJsonResponseFromUrl(communityAdsUrl, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mAppConst.hideProgressDialog();
                mBrowseItemList.clear();
                if (jsonObject != null) {
                    String pageTitle = mContext.getResources().getString(R.string.thanks_for_visiting);
                    String pageName = "";
                    if (jsonObject.optString("title", "default") != null && !jsonObject.optString("title", "default").equals("default")) {
                        pageName = jsonObject.optString("title");
                        pageTitle = pageTitle + "(" + pageName + ")";
                    }
                    mSubjectType = jsonObject.optString("subjectType");
                    mSubjectId = jsonObject.optString("subjectId");
                    tvThanksGiving.setText(pageTitle);
                    rootView.setVisibility(View.VISIBLE);
                    mAdvertisementsArray = jsonObject.optJSONArray("advertisments");
                    if (mAdvertisementsArray != null) {
                        rootView.findViewById(R.id.message_layout).setVisibility(View.GONE);
                        refreshLayout.setVisibility(View.VISIBLE);
                        tvAdsHeadline.setVisibility(View.VISIBLE);
                        for (int i = 0; i < mAdvertisementsArray.length(); i++) {
                            mBrowseItemList.add(i, addCommunityAddsToList(i));
                        }
                        mManageDataAdapter.notifyDataSetChanged();
                    } else {
                        isNoAds = true;
                        showNoOffer();
                    }
                    if (isShowPopup && !mSubjectId.isEmpty() && !mSubjectType.isEmpty()) {
                        showConfirmationCheckIn(queryString, pageName);
                    }
                } else {
                    showNoOffer();
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                SnackbarUtils.displaySnackbar(rootView, message);
                mAppConst.hideProgressDialog();
                redirectToHomePage();
            }
        });
    }

    private void showNoOffer() {
        refreshLayout.setVisibility(View.GONE);
        tvAdsHeadline.setVisibility(View.GONE);
        if (mSubjectType != null && !mSubjectType.contains("group")) {
            rootView.findViewById(R.id.message_layout).setVisibility(View.VISIBLE);
            TextView errorIcon = (TextView) rootView.findViewById(R.id.error_icon);
            TextView errorMessage = (TextView) rootView.findViewById(R.id.error_message);
            errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            errorIcon.setText("\uf06b");
            errorMessage.setText(getActivity().getResources().getString(R.string.currently_no_offer_available));
        }
    }

    private CommunityAdsList addCommunityAddsToList(int j) {

        JSONObject singleAdObject = mAdvertisementsArray.optJSONObject(j);
        if (singleAdObject == null) {
            return null;
        }
        int adId = singleAdObject.optInt("userad_id");
        String ad_type = singleAdObject.optString("ad_type");
        String cads_title = singleAdObject.optString("cads_title");
        String cads_body = singleAdObject.optString("cads_body");
        String cads_url = singleAdObject.optString("cads_url");
        String image = singleAdObject.optString("image");
        return new CommunityAdsList(adId, ad_type, cads_title, cads_body,
                cads_url, image);
    }

    private void checkIn(String queryString, String checkInText) {

        final String contentId = queryString.substring(queryString.lastIndexOf("_") + 1);

        String checkInUrl = UrlUtil.SITE_TAG_CHECK_IN_MENU_URL + "subject_type="+ mSubjectType + "&subject_id=" + contentId;
        Map<String, String> params = new HashMap<>();
        params.put("qr_key", queryString);
        params.put("body", checkInText);
        Calendar newCalendar = Calendar.getInstance();
        String year = String.valueOf(newCalendar.get(Calendar.YEAR));
        String month = String.valueOf(newCalendar.get(Calendar.MONTH) + 1);
        String day = String.valueOf(newCalendar.get(Calendar.DAY_OF_MONTH));

        params.put("day", day);
        params.put("month", month);
        params.put("year", year);
        params.put("auth_view", "everyone");
        mAppConst.showProgressDialog();

        mAppConst.postJsonResponseForUrl(checkInUrl, params, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                mAppConst.hideProgressDialog();
                if (isNoAds && mSubjectType != null && mSubjectType.contains("group")) {
                    redirectToGroup();
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mAppConst.hideProgressDialog();
                SnackbarUtils.displaySnackbar(rootView, message);
                if (isNoAds && mSubjectType != null && mSubjectType.contains("group")) {
                    redirectToGroup();
                }
            }
        });
    }

    private void redirectToGroup() {
        Intent intent = GlobalFunctions.getIntentForModule(mContext, Integer.parseInt(mSubjectId), mSubjectType, null);
        if (intent != null) {
            intent.putExtra("isQRScanner", true);
            ((Activity) mContext).startActivityForResult(intent, ConstantVariables.CANCELED_QR_SCAN);
            ((Activity) mContext).overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }
    }

    private void redirectToHomePage() {
        MainActivity mainActivity = (MainActivity) mContext;
        mainActivity.selectItem("home", mContext.getResources().getString(R.string.app_name), null, null, 0);
    }

    private void showConfirmationCheckIn(String queryString, String pageTitle) {
        if (queryString.lastIndexOf("_") < 1){
            return;
        }
        queryString = queryString.replace("_" + mSubjectType, "");
        String checkInText = queryString.substring(0, queryString.lastIndexOf("_"));
        mDialogBuilder = new android.support.v7.app.AlertDialog.Builder(mContext);
        mDialogBuilder.setCancelable(false);
        mDialogBuilder.setTitle("Check-In on " + pageTitle);
        final EditText optionalText = new EditText(mContext);
        LinearLayout parentLayout = new LinearLayout(mContext);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT);
        optionalText.setHint(mContext.getResources().getString(R.string.type_something));
        optionalText.setText(checkInText);
        optionalText.setGravity(Gravity.CENTER);

        int margin = (int) (30 * Resources.getSystem().getDisplayMetrics().density);
        int marginBottom = (int) (5 * Resources.getSystem().getDisplayMetrics().density);
        lp.setMargins(margin, margin, margin, marginBottom);
        optionalText.setLayoutParams(lp);
        parentLayout.addView(optionalText);
        mDialogBuilder.setView(parentLayout);

        String finalQueryString = queryString;
        mDialogBuilder.setPositiveButton(mContext.getResources().getString(R.string.done),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        checkIn(finalQueryString, optionalText.getText().toString());
                    }
                });

        mDialogBuilder.setNegativeButton(mContext.getResources().getString(R.string.cancel_dialogue_message),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                        if (isNoAds && mSubjectType != null && mSubjectType.contains("group")) {
                            redirectToGroup();
                        }
                    }
                });
        mDialogBuilder.create().show();
        isShowPopup = false;
    }
}
