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

package com.socialengineaddons.mobileapp.classes.common.fragments;


import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.dialogs.AlertDialogWithAction;
import com.socialengineaddons.mobileapp.classes.common.utils.SnackbarUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.UrlUtil;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;

import static com.socialengineaddons.mobileapp.R.id.map;

/**
 * A simple {@link Fragment} subclass.
 */
public class MapViewFragment extends BaseFragment implements OnMapReadyCallback {

    private GoogleMap mMap;
    private LatLng latLng;
    private double latitude, longitude;
    private String location, placeId;
    private AppConstant mAppConst;
    private Context mContext;
    private View mRootView;
    private boolean isLoadMapView = false;

    public MapViewFragment() {
        // Required empty public constructor
    }

    @Override
    public void setNestedScrollingEnabled(boolean enabled) {

    }

    public static MapViewFragment newInstance(Bundle bundle){
        MapViewFragment mapViewFragment = new MapViewFragment();
        mapViewFragment.setArguments(bundle);
        return mapViewFragment;
    }

    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (visible && isLoadMapView) {
            if(mAppConst.checkManifestPermission(Manifest.permission.ACCESS_COARSE_LOCATION)){
                loadMapView();
            } else {
                mAppConst.requestForManifestPermission(Manifest.permission.ACCESS_FINE_LOCATION,
                        ConstantVariables.ACCESS_FINE_LOCATION);
            }
            isLoadMapView = false;
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mRootView = inflater.inflate(R.layout.map_fragment, container, false);
        mContext = getActivity();
        mAppConst = new AppConstant(mContext);
        if (getArguments() != null){
            location = getArguments().getString("location");
            latitude = getArguments().getDouble("latitude", 0);
            longitude = getArguments().getDouble("longitude", 0);
            placeId = getArguments().getString("place_id");

        }

        isLoadMapView = true;

        // Inflate the layout for this fragment
        return mRootView;
    }


    private void loadMapView() {
        SupportMapFragment mapFrag = (SupportMapFragment) getChildFragmentManager().findFragmentById(map);
        mapFrag.getMapAsync(this);

        if(latitude != 0 && longitude != 0){
            latLng = new LatLng(latitude, longitude );
        } else if(placeId != null){
            try {
                PlacesTask placesTask = new PlacesTask();
                StringBuilder placeApiUrl = new StringBuilder(UrlUtil.PLACES_API_BASE + "/details/json");
                placeApiUrl.append("?placeid=").append(URLEncoder.encode(placeId, "utf8"));
                placeApiUrl.append("&key=" + getResources().getString(R.string.places_api_key));

                placesTask.execute(placeApiUrl.toString());
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        }else {
            latLng = getLatLngFromLocation(location);
        }
    }

    /** A class, to download Details of a place using it's place_id */
    private class PlacesTask extends AsyncTask<String, Integer, LatLng> {

        // Invoked by execute() method of this object
        @Override
        protected LatLng doInBackground(String... url) {
            try {
                latLng = getLatLngFromPlaceId(url[0]);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return latLng;
        }

        @Override
        protected void onPostExecute(LatLng latLng) {
            if(latLng != null) {
                mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, 15));
                onMapReady(mMap);
            }
            super.onPostExecute(latLng);
        }
    }
    private LatLng getLatLngFromPlaceId(String placesUrl){

        LatLng latLng = null;

        HttpURLConnection conn = null;
        StringBuilder jsonResults = new StringBuilder();
        try {
            URL url = new URL(placesUrl);
            conn = (HttpURLConnection) url.openConnection();
            InputStreamReader in = new InputStreamReader(conn.getInputStream());

            // Load the results into a StringBuilder
            int read;
            char[] buff = new char[1024];
            while ((read = in.read(buff)) != -1) {
                jsonResults.append(buff, 0, read);

            }
        } catch ( IOException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }

        try {
            // Create a JSON object hierarchy from the results
            JSONObject jsonObj = new JSONObject(jsonResults.toString());
            JSONObject result = jsonObj.getJSONObject("result").getJSONObject("geometry").
                    getJSONObject("location");
            Double longitude  = result.getDouble("lng");
            Double latitude =  result.getDouble("lat");
            latLng = new LatLng(latitude, longitude);

        } catch (JSONException e) {
            e.printStackTrace();
        }

        return latLng;
    }
    public LatLng getLatLngFromLocation(String strAddress) {

        Geocoder coder = new Geocoder(mContext);
        List<Address> address;
        LatLng latLng = null;

        try {
            address = coder.getFromLocationName(strAddress, 5);
            if (address == null || address.isEmpty()) {
                return null;
            }
            Address location = address.get(0);
            location.getLatitude();
            location.getLongitude();

            latLng = new LatLng(location.getLatitude(), location.getLongitude() );
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return latLng;
    }
    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        googleMap.setMyLocationEnabled(true);
        googleMap.getUiSettings().setZoomControlsEnabled(true);
        googleMap.getUiSettings().setRotateGesturesEnabled(true);

        if(latLng != null){
            googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, 15));
            googleMap.addMarker(new MarkerOptions()
                    .position(latLng)
                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED))
                    .title(location));
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case ConstantVariables.ACCESS_FINE_LOCATION:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission granted, proceed to the normal flow
                    loadMapView();
                } else {
                    // If user press deny in the permission popup
                    if (shouldShowRequestPermissionRationale(Manifest.permission.ACCESS_FINE_LOCATION)) {

                        // Show an expanation to the user After the user
                        // sees the explanation, try again to request the permission.
                        AlertDialogWithAction mAlertDialogWithAction = new AlertDialogWithAction(mContext);
                        mAlertDialogWithAction.showDialogForAccessPermission(Manifest.permission.ACCESS_FINE_LOCATION,
                                ConstantVariables.ACCESS_FINE_LOCATION);

                    } else {
                        // If user pressed never ask again on permission popup
                        // Show Snackbar with setting activity button to open App Info
                        SnackbarUtils.displaySnackbarOnPermissionResult(mContext, mRootView,
                                ConstantVariables.ACCESS_FINE_LOCATION);

                    }
                }
                break;
        }
    }
}
