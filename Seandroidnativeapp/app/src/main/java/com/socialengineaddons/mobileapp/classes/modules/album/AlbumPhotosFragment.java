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

package com.socialengineaddons.mobileapp.classes.modules.album;


import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.TextView;


import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.GridViewAdapter;
import com.socialengineaddons.mobileapp.classes.common.adapters.StaggeredGridAdapter;
import com.socialengineaddons.mobileapp.classes.common.fragments.BaseFragment;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnItemClickListener;
import com.socialengineaddons.mobileapp.classes.common.ui.CustomViews;
import com.socialengineaddons.mobileapp.classes.common.ui.GridViewWithHeaderAndFooter;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.ui.SelectableTextView;
import com.socialengineaddons.mobileapp.classes.common.utils.GridSpacingItemDecorationUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoLightBoxActivity;
import com.socialengineaddons.mobileapp.classes.modules.photoLightBox.PhotoListDetails;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link AlbumPhotosFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class AlbumPhotosFragment extends BaseFragment implements SwipeRefreshLayout.OnRefreshListener,
        AbsListView.OnScrollListener, AdapterView.OnItemClickListener {


    private Context mContext;
    private AppConstant mAppConst;
    private JSONArray mDataResponseArray;
    private JSONObject mBody;
    private String mBrowseAlbumPhotosUrl, mSubjectType;
    private String title, ownerTitle, normalImgUrl;
    private boolean isLoading = false,isVisibleToUser = false;
    private int pageNumber = 1, mLoadingPageNo = 1, mTotalItemCount = 0, mActualPhotoCount = 0, canEdit = 0;
    private ArrayList<PhotoListDetails> mPhotoDetails;
    private View rootView;
    private RecyclerView mRecyclerView;
    private SwipeRefreshLayout swipeRefreshLayout;
    private StaggeredGridLayoutManager mStaggeredLayoutManager;
    private StaggeredGridAdapter staggeredGridAdapter;
    Snackbar snackbar;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.

     * @return A new instance of fragment AlbumPhotosFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static AlbumPhotosFragment newInstance(Bundle bundle) {
        AlbumPhotosFragment fragment = new AlbumPhotosFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    public AlbumPhotosFragment() {
        // Required empty public constructor
    }

    @Override
    public void setNestedScrollingEnabled(boolean enabled) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mRecyclerView.setNestedScrollingEnabled(enabled);
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext =getActivity();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        mAppConst = new AppConstant(mContext);
        mPhotoDetails = new ArrayList<>();

        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.album_photos, null);

        mRecyclerView = rootView.findViewById(R.id.recyclerView);
        // set a StaggeredGridLayoutManager with 2 number of columns and vertical orientation
        mStaggeredLayoutManager = new StaggeredGridLayoutManager(2, LinearLayoutManager.VERTICAL);
        mRecyclerView.setLayoutManager(mStaggeredLayoutManager);
        mRecyclerView.setItemAnimator(null);
        mRecyclerView.addItemDecoration(new GridSpacingItemDecorationUtil(mContext,
                R.dimen.padding_7dp, mRecyclerView, true));

        swipeRefreshLayout = (SwipeRefreshLayout) rootView.findViewById(R.id.swipe_refresh_layout);
        swipeRefreshLayout.setOnRefreshListener(this);
        swipeRefreshLayout.setColorSchemeResources(R.color.colorAccent);

        //Editing the url for browse album
        mBrowseAlbumPhotosUrl = AppConstant.DEFAULT_URL + "albums/photo/list?order=order%20DESC&limit="
                + AppConstant.LIMIT;
        if (getArguments() != null){
            Bundle args = getArguments();
            mBrowseAlbumPhotosUrl = args.containsKey(ConstantVariables.URL_STRING) ? args.getString(ConstantVariables.URL_STRING) : mBrowseAlbumPhotosUrl;
            mSubjectType = args.getString(ConstantVariables.SUBJECT_TYPE);
        }

        staggeredGridAdapter = new StaggeredGridAdapter(getActivity(), mPhotoDetails, true, new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                // on selecting grid view image
                // launch full screen activity
                Bundle bundle = new Bundle();
                bundle.putSerializable(PhotoLightBoxActivity.EXTRA_IMAGE_URL_LIST, mPhotoDetails);
                Intent i = new Intent(getActivity(), PhotoLightBoxActivity.class);
                i.putExtra(ConstantVariables.ITEM_POSITION, position);
                i.putExtra(ConstantVariables.CAN_EDIT, canEdit);
                i.putExtra(ConstantVariables.TOTAL_ITEM_COUNT, mTotalItemCount);
                i.putExtra(ConstantVariables.PHOTO_REQUEST_URL, mBrowseAlbumPhotosUrl);
                i.putExtra(ConstantVariables.SHOW_ALBUM_BUTTON, true);
                i.putExtra(ConstantVariables.IS_ALBUM_VIEW, true);
                i.putExtra(ConstantVariables.ALBUM_ID, mPhotoDetails.get(position).geAlbumId());
                i.putExtras(bundle);
                startActivityForResult(i, ConstantVariables.VIEW_LIGHT_BOX);
            }
        });

        mRecyclerView.setAdapter(staggeredGridAdapter);

        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
            }

            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                int visibleItemCount = mStaggeredLayoutManager.getChildCount();
                int totalItemCount = mStaggeredLayoutManager.getItemCount();
                int pastVisibleItems = 0;
                int[] firstVisibleItems = null;
                firstVisibleItems = mStaggeredLayoutManager.findFirstVisibleItemPositions(firstVisibleItems);
                if(firstVisibleItems != null && firstVisibleItems.length > 0) {
                    pastVisibleItems = firstVisibleItems[0];
                }
                int limit = visibleItemCount + pastVisibleItems;
                if(limit == totalItemCount && !isLoading) {
                    if(limit >= mActualPhotoCount && (AppConstant.LIMIT * mLoadingPageNo)  < mTotalItemCount){
                        mPhotoDetails.add(null);
                        staggeredGridAdapter.notifyItemInserted(mPhotoDetails.size() - 1);
                        mLoadingPageNo = mLoadingPageNo + 1;
                        String url = mBrowseAlbumPhotosUrl + "&page="+ mLoadingPageNo;
                        isLoading = true;
                        loadMoreData(url);
                    }
                }
            }
        });
        if (mSubjectType != null) {
            makeRequest();
        }
        return rootView;
    }

    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (visible && !isVisibleToUser) {
            makeRequest();
        } else {
            if(snackbar != null && snackbar.isShown())
                snackbar.dismiss();
        }
    }

    public void makeRequest(){

        String url = mBrowseAlbumPhotosUrl + "&page=" + pageNumber;
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) {
                mPhotoDetails.clear();
                rootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                if(snackbar != null && snackbar.isShown()) {
                    snackbar.dismiss();
                }

                addPhotosToList(jsonObject);
                isVisibleToUser = true;
                if (swipeRefreshLayout.isRefreshing()) {
                    swipeRefreshLayout.setRefreshing(false);
                }

            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                rootView.findViewById(R.id.progressBar).setVisibility(View.GONE);
                if (swipeRefreshLayout.isRefreshing()) {
                    swipeRefreshLayout.setRefreshing(false);
                }
                if (isRetryOption) {
                    snackbar = SnackbarUtils.displaySnackbarWithAction(getActivity(), rootView, message,
                            new SnackbarUtils.OnSnackbarActionClickListener() {
                                @Override
                                public void onSnackbarActionClick() {
                                    rootView.findViewById(R.id.progressBar).setVisibility(View.VISIBLE);
                                    makeRequest();
                                }
                            });
                } else {
                    SnackbarUtils.displaySnackbar(rootView, message);
                }
            }
        });
    }

    public void loadMoreData(String url){


            mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
                @Override
                public void onTaskCompleted(JSONObject jsonObject) {
                    mPhotoDetails.remove(mPhotoDetails.size() - 1);
                    staggeredGridAdapter.notifyItemRemoved(mPhotoDetails.size());
                    addPhotosToList(jsonObject);
                    isLoading = false;

                }

                @Override
                public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                    SnackbarUtils.displaySnackbar(rootView, message);
                }
            });

    }
    public void addPhotosToList(JSONObject jsonObject){
        mBody = jsonObject;
        mDataResponseArray = mBody.optJSONArray("photos");
        // TODO Discussion_API
        mDataResponseArray = (mDataResponseArray == null) ? mBody.optJSONArray("response") : mDataResponseArray;
        mTotalItemCount = mBody.optInt("totalPhotoCount") == 0 ? mBody.optInt("totalItemCount") : mBody.optInt("totalPhotoCount");
        mActualPhotoCount = mBody.optInt("actual_count");

        if (mDataResponseArray != null && mDataResponseArray.length() > 0) {
            rootView.findViewById(R.id.message_layout).setVisibility(View.GONE);
            for (int i = 0; i < mDataResponseArray.length(); i++) {
                JSONObject imageUrlsObj = mDataResponseArray.optJSONObject(i);
                String menuArray = imageUrlsObj.optString("menu");
                title = imageUrlsObj.optString("album_title");
                ownerTitle = imageUrlsObj.optString("owner_title");
                normalImgUrl = imageUrlsObj.optString("image");
                String image_title = imageUrlsObj.optString("title");
                String image_desc = imageUrlsObj.optString("description");
                int photo_id = imageUrlsObj.optInt("photo_id");
                int likeCount = imageUrlsObj.optInt("like_count");
                int commentCount = imageUrlsObj.optInt("comment_count");
                boolean isLiked = imageUrlsObj.optBoolean("is_like");
                String reactions = imageUrlsObj.optString("reactions");
                String mUserTagArray = imageUrlsObj.optString("tags");
                String contentUrl = imageUrlsObj.optString("content_url");
                int albumId = imageUrlsObj.optInt("album_id");

                    mPhotoDetails.add(new PhotoListDetails(title, ownerTitle,
                            image_title, image_desc, photo_id, normalImgUrl, likeCount, commentCount,
                            isLiked, menuArray, reactions, mUserTagArray, contentUrl, mSubjectType, albumId));


            }
        } else if (mLoadingPageNo == 1) {
            rootView.findViewById(R.id.message_layout).setVisibility(View.VISIBLE);
            TextView errorIcon = (TextView) rootView.findViewById(R.id.error_icon);
            SelectableTextView errorMessage = (SelectableTextView) rootView.findViewById(R.id.error_message);
            errorIcon.setTypeface(GlobalFunctions.getFontIconTypeFace(mContext));
            errorIcon.setText("\uf03e");
            errorMessage.setText(mContext.getResources().getString(R.string.no_photos));
        }

        staggeredGridAdapter.notifyItemInserted(mPhotoDetails.size() - 1);

    }

    public void onRefresh() {
    /**
     * Showing Swipe Refresh animation on activity create
     * As animation won't start on onCreate, post runnable is used
     */
        swipeRefreshLayout.post(new Runnable() {
            @Override
            public void run() {
                swipeRefreshLayout.setRefreshing(true);
                makeRequest();
            }
        });
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mContext = context;
        if(mRecyclerView != null){
            mRecyclerView.smoothScrollToPosition(0);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode){
            case ConstantVariables.ALBUM_VIEW_PAGE:
                makeRequest();
                break;

            case ConstantVariables.VIEW_LIGHT_BOX:
                if (resultCode == ConstantVariables.LIGHT_BOX_EDIT) {
                    if (data != null) {
                        PhotoListDetails photoListDetails = mPhotoDetails.get(data.getIntExtra(ConstantVariables.ITEM_POSITION, 0));
                        photoListDetails.setImageLikeCount(data.getIntExtra(ConstantVariables.PHOTO_LIKE_COUNT, 0));
                        photoListDetails.setmImageCommentCount(data.getIntExtra(ConstantVariables.PHOTO_COMMENT_COUNT, 0));
                    }
                }
                break;
        }

    }

    @Override
    public void onScrollStateChanged(AbsListView view, int scrollState) {

    }

    @Override
    public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
        int limit=firstVisibleItem+visibleItemCount;
        if(limit==totalItemCount && !isLoading) {
            if(limit >= mActualPhotoCount && (AppConstant.LIMIT * mLoadingPageNo)  < mTotalItemCount){
                mLoadingPageNo = mLoadingPageNo + 1;
                String url = mBrowseAlbumPhotosUrl + "&page="+ mLoadingPageNo;
                isLoading = true;
                loadMoreData(url);
            }
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

    }
}
