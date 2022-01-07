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

package com.socialengineaddons.mobileapp.classes.modules.likeNComment;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.utils.GlobalFunctions;
import com.socialengineaddons.mobileapp.classes.common.utils.ImageLoader;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.SoundUtil;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class EditComment extends AppCompatActivity implements View.OnClickListener{

    private Context mContext;
    private AppConstant mAppConst;
    private ImageView authorImage;
    private EditText commentText;
    private Button commentCancelBtn, commentUpdateBtn;
    private int mCommentId, mActionId, mSubjectId, mItemPosition;
    private String mAuthorPhoto, mCommentBody, mCommentType, mSubjectType;
    private ImageLoader mImageLoader;
    private Map<String, String> params;
    private String updateCommentUrl, mUpdateUrl;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_comment);
        mContext = this;
        mAppConst = new AppConstant(this);
        mImageLoader = new ImageLoader(mContext);

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(mContext.getResources().getString(R.string.title_edit_comment));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        if (getIntent() != null) {
            mItemPosition = getIntent().getIntExtra(ConstantVariables.ITEM_POSITION, 0);
            mActionId = getIntent().getIntExtra(ConstantVariables.ACTION_ID, 0);
            mCommentType = getIntent().getStringExtra(ConstantVariables.COMMENT_TYPE);
            mSubjectType = getIntent().getStringExtra(ConstantVariables.SUBJECT_TYPE);
            mSubjectId = getIntent().getIntExtra(ConstantVariables.SUBJECT_ID, 0);
            mUpdateUrl = getIntent().getStringExtra("updateUrl");
            mCommentId = getIntent().getIntExtra("commentId", 0);
            mAuthorPhoto = getIntent().getStringExtra("authorPhoto");
            mCommentBody = getIntent().getStringExtra("commentBody");
        }

        authorImage = findViewById(R.id.authorImage);
        commentText = findViewById(R.id.commentText);
        commentCancelBtn = findViewById(R.id.comment_cancel_btn);
        commentUpdateBtn = findViewById(R.id.comment_update_btn);

        commentCancelBtn.setOnClickListener(this);
        commentUpdateBtn.setOnClickListener(this);
        commentUpdateBtn.setClickable(false);

        if (mAuthorPhoto != null && !mAuthorPhoto.isEmpty()) {
            mImageLoader.setImageForUserProfile(mAuthorPhoto, authorImage);
        }
        if (mCommentBody != null && !mCommentBody.isEmpty()) {
            commentText.setText(mCommentBody);
        }

        commentText.requestFocus();
        if(commentText.requestFocus()) {
            getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
        }

        commentText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                if (charSequence.toString().length() > 0) {
                    commentUpdateBtn.setClickable(true);
                    commentUpdateBtn.setBackground(getResources().getDrawable(R.drawable.rounded_corner_theme));
                    commentUpdateBtn.setTextColor(getResources().getColor(R.color.white));
                } else {
                    commentUpdateBtn.setClickable(false);
                    commentUpdateBtn.setBackground(getResources().getDrawable(R.drawable.rounded_corner_grey));
                    commentUpdateBtn.setTextColor(getResources().getColor(R.color.dark_gray));
                }
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });

    }

    private void updateComment(){
        String commentBody = commentText.getText().toString().trim();

        mAppConst.showProgressDialog();
        mAppConst.hideKeyboard();

        params = new HashMap<>();
        params.put("action_id", String.valueOf(mActionId));
        params.put("subject_type", mSubjectType);
        params.put("subject_id", String.valueOf(mSubjectId));
        params.put("comment_id", String.valueOf(mCommentId));
        params.put("body", commentBody);

        updateCommentUrl = AppConstant.DEFAULT_URL + mUpdateUrl;

        mAppConst.postJsonResponseForUrl(updateCommentUrl, params, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                mAppConst.hideProgressDialog();

                if(jsonObject != null) {
                    Intent intent = new Intent();
                    intent.putExtra(ConstantVariables.ITEM_POSITION, mItemPosition);
                    intent.putExtra(ConstantVariables.COMMENT_OBJECT, String.valueOf(jsonObject));
                    setResult(ConstantVariables.VIEW_EDIT_COMMENT_PAGE, intent);
                    onBackPressed();
                }
            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                mAppConst.hideProgressDialog();
                SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.main_content), message);
            }
        });

    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        mAppConst.hideKeyboard();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here
        int id = item.getItemId();

        switch (id) {
            case android.R.id.home:
                onBackPressed();
                // Playing backSound effect when user tapped on back button from tool bar.
                if (PreferencesUtils.isSoundEffectEnabled(EditComment.this)) {
                    SoundUtil.playSoundEffectOnBackPressed(EditComment.this);
                }
                break;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {
            case R.id.comment_cancel_btn:
                onBackPressed();
                break;

            case R.id.comment_update_btn:
                if (GlobalFunctions.isNetworkAvailable(mContext)) {
                    updateComment();
                } else {
                    SnackbarUtils.displaySnackbarLongTime(findViewById(R.id.main_content),
                            getResources().getString(R.string.network_connectivity_error));
                }
                break;
        }
    }

}
