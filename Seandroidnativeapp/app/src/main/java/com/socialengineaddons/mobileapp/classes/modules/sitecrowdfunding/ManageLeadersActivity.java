package com.socialengineaddons.mobileapp.classes.modules.sitecrowdfunding;

import android.content.Context;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.adapters.AddPeopleAdapter;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnResponseListener;
import com.socialengineaddons.mobileapp.classes.common.ui.BaseButton;
import com.socialengineaddons.mobileapp.classes.common.utils.AddPeopleList;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.user.BrowseMemberFragment;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

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

public class ManageLeadersActivity extends AppCompatActivity implements AdapterView.OnItemClickListener {

    public Fragment leadersFragment;
    protected EditText etSearchBox;
    private Toolbar mToolbar;
    private Bundle bundle;
    private Context mContext;
    private ListView lvMembers;
    private BaseButton makeLeader;
    private AddPeopleAdapter mAddPeopleAdapter;
    private List<AddPeopleList> mAddPeopleList;
    private AppConstant mAppConst;
    private JSONArray jaMemberResponse;
    private View leadersFrame;
    private int userId;
    private String contentId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_manage_leaders);

        contentId = getIntent().getStringExtra(ConstantVariables.CONTENT_ID);
        loadLeadersFragment();

        leadersFrame = findViewById(R.id.main_content);
        makeLeader = findViewById(R.id.make_leader);
        makeLeader.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (userId > 0) {
                    etSearchBox.setText("");
                    etSearchBox.requestFocus();
                    mAppConst.hideKeyboard();
                    Map<String, String> params = new HashMap<>();
                    params.put(ConstantVariables.USER_ID, String.valueOf(userId));
                    leadersFrame.setVisibility(View.GONE);
                    lvMembers.setVisibility(View.GONE);
                    mAppConst.showProgressDialog();
                    mAppConst.postJsonResponseForUrl(UrlUtil.CROWD_FUNDING_ADD_LEADER_URL + contentId, params, new OnResponseListener() {
                        @Override
                        public void onTaskCompleted(JSONObject jsonObject) throws JSONException {
                            mAppConst.hideProgressDialog();
                            loadLeadersFragment();
                            SnackbarUtils.displaySnackbar(findViewById(android.R.id.content), getResources().getString(R.string.added_leader_success_message));
                        }

                        @Override
                        public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                            SnackbarUtils.displaySnackbar(findViewById(android.R.id.content), message);
                        }
                    });
                }
            }
        });
        mAddPeopleList = new ArrayList<>();
        lvMembers = (ListView) findViewById(R.id.listView);
        mAddPeopleAdapter = new AddPeopleAdapter(this, R.layout.list_friends, mAddPeopleList);
        lvMembers.setAdapter(mAddPeopleAdapter);
        lvMembers.setOnItemClickListener(this);

        mAppConst = new AppConstant(this);
        etSearchBox = (EditText) findViewById(R.id.search_member);
        etSearchBox.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s != null && !s.toString().isEmpty()) {
                    getFriendList(UrlUtil.CROWD_FUNDING_SUGGEST_LEADER_URL + contentId + "?search=" + s);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(mToolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("Manage Leaders");
        }
    }

    private void loadLeadersFragment() {
        Bundle args = new Bundle();
        args.putString(ConstantVariables.URL_STRING, UrlUtil.CROWD_FUNDING_MANAGE_LEADER_URL + contentId);
        args.putString(ConstantVariables.CONTENT_ID, contentId);
        args.putBoolean(ConstantVariables.IS_MANAGE_VIEW, true);

        leadersFragment = BrowseMemberFragment.newInstance(args);
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction ft = fragmentManager.beginTransaction();
        ft.replace(R.id.main_content, leadersFragment);
        if (!isFinishing()) {
            ft.commit();
        }
        if (leadersFrame != null) {
            leadersFrame.setVisibility(View.VISIBLE);
        }
    }

    public void getFriendList(String url) {

        findViewById(R.id.loadingBar).setVisibility(View.VISIBLE);
        leadersFrame.setVisibility(View.GONE);
        mAppConst.getJsonResponseFromUrl(url, new OnResponseListener() {
            @Override
            public void onTaskCompleted(JSONObject body) {
                if (body != null && body.length() != 0) {
                    mAddPeopleList.clear();
                    findViewById(R.id.loadingBar).setVisibility(View.GONE);
                    jaMemberResponse = body.optJSONArray("response");
                    for (int i = 0; i < jaMemberResponse.length(); i++) {
                        JSONObject friendObject = jaMemberResponse.optJSONObject(i);
                        String username = friendObject.optString("label");
                        int userId = friendObject.optInt("user_id");
                        String userImage = friendObject.optString("photo");

                        try {
                            mAddPeopleList.add(new AddPeopleList(userId, username, userImage));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                    }
                    lvMembers.setVisibility(View.VISIBLE);
                    mAddPeopleAdapter.notifyDataSetChanged();
                }

            }

            @Override
            public void onErrorInExecutingTask(String message, boolean isRetryOption) {
                findViewById(R.id.loadingBar).setVisibility(View.GONE);
                SnackbarUtils.displaySnackbar(findViewById(android.R.id.content), message);
            }
        });

    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        AddPeopleList addPeopleList = mAddPeopleList.get(position);
        String label = addPeopleList.getmUserLabel();
        userId = addPeopleList.getmUserId();
        etSearchBox.setText(label);
        lvMembers.setVisibility(View.GONE);
        leadersFrame.setVisibility(View.VISIBLE);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                onBackPressed();
                break;
        }
        return super.onOptionsItemSelected(item);
    }
}
