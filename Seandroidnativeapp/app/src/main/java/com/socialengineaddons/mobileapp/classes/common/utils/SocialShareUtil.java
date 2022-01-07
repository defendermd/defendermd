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

package com.socialengineaddons.mobileapp.classes.common.utils;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.support.v4.content.FileProvider;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.PopupMenu;

import com.facebook.FacebookSdk;
import com.facebook.share.widget.ShareDialog;
import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.activities.ShareEntry;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.messagingMiddleware.MessageCoreUtils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;


public class SocialShareUtil {

    private Context mContext;
    ShareDialog shareDialog;
    private AppConstant mAppConstant;

    public SocialShareUtil(Context context) {
        mContext = context;
        if (!context.getResources().getString(R.string.facebook_app_id).isEmpty()) {
            FacebookSdk.setApplicationId(context.getResources().getString(R.string.facebook_app_id));
            FacebookSdk.sdkInitialize(mContext.getApplicationContext());
            shareDialog = new ShareDialog((Activity) mContext);
        }
        mAppConstant = new AppConstant(mContext);
    }

    public void sharePost(View view, final String title, final String image, final String url
            , final String type, final String linkUrl) {

        LogUtils.LOGD(SocialShareUtil.class.getSimpleName(), "linkUrl: "+linkUrl);

        if (view != null) {
            PopupMenu popup = new PopupMenu(mContext, view);
            popup.getMenu().add(Menu.NONE, 0, Menu.NONE, mContext.getResources().getString(R.string.share_on_your_wall)
                    + " " + mContext.getResources().getString(R.string.app_name));
            popup.getMenu().add(Menu.NONE, 1, Menu.NONE, mContext.getResources().getString(R.string.social_share));
            if (PreferencesUtils.isPrimeMessengerEnabled(mContext)) {
                popup.getMenu().add(Menu.NONE, 2, Menu.NONE, mContext.getResources().getString(R.string.prime_messenger_share));
            }

            popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                @Override
                public boolean onMenuItemClick(MenuItem item) {
                    int id = item.getItemId();
                    if (id == 0) {
                        Intent intent = new Intent(mContext, ShareEntry.class);
                        intent.putExtra("URL", url);
                        intent.putExtra("title", title);

                        if (image != null) {
                            intent.putExtra("image", image);
                        }

                        if (type != null && type.equals("music_playlist")) {
                            intent.putExtra("music_url", linkUrl);
                        }

                        mContext.startActivity(intent);

                    } else if (id == 1) {
                        if (type != null && type.equals(ConstantVariables.KEY_SHARE_TYPE_MEDIA)) {
                            shareMedia(mContext, image);
                        } else {
                            shareContent(title, linkUrl);
                        }
                    } else {
                        MessageCoreUtils.shareContentInChannelize(mContext, linkUrl);
                    }
                    return true;
                }
            });
            popup.show();
        }

    }

    public void shareContent(String title, String linkUrl) {
        shareExcludingOwnApp(null, title, linkUrl, false);
    }

    public void shareMedia(Context context, String image) {
        mAppConstant.showProgressDialog();
        new SaveImageAsync(context, image).execute();
    }

    public class SaveImageAsync extends AsyncTask<Void, Bitmap, Bitmap> {

        String imgUrl;
        Context context;

        public SaveImageAsync(Context context, String url) {
            this.context = context;
            imgUrl = url;
        }

        @Override
        protected Bitmap doInBackground(Void... params) {
            try {
                URL url = new URL(imgUrl);
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setDoInput(true);
                connection.connect();
                InputStream input = connection.getInputStream();
                Bitmap imageBitmap = BitmapFactory.decodeStream(input);
                ByteArrayOutputStream bytes = new ByteArrayOutputStream();
                imageBitmap.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
                return imageBitmap;

            } catch (IOException e) {
                // Log exception

            }
            return null;
        }

        @Override
        protected void onPostExecute(Bitmap result) {
            mAppConstant.hideProgressDialog();
            if (result != null) {
                shareExcludingOwnApp(result, null, null, true);
            }
        }

    }

    /**
     * Method to remove own app from sharing app list.
     *
     * @param mediaResult         Media result in case of image sharing.
     * @param title               Title of the sharing content.
     * @param linkUrl             Link url of the sharing content.
     * @param isMediaShareRequest True if the request is for media sharing.
     */
    public void shareExcludingOwnApp(Bitmap mediaResult, String title, String linkUrl,
                                     boolean isMediaShareRequest) {

        Intent intent = new Intent(Intent.ACTION_SEND);

        // Check for share type and set intent params accordingly.
        if (isMediaShareRequest && mediaResult != null) {
            try {
                File cachePath = new File(mContext.getCacheDir(), "images");
                cachePath.mkdirs(); // don't forget to make the directory
                FileOutputStream stream = new FileOutputStream(cachePath + "/image.png"); // overwrites this image every time
                mediaResult.compress(Bitmap.CompressFormat.PNG, 100, stream);
                stream.close();

            } catch (IOException e) {
                e.printStackTrace();
            }

            File imagePath = new File(mContext.getCacheDir(), "images");
            File newFile = new File(imagePath, "image.png");
            Uri contentUri = FileProvider.getUriForFile(mContext, mContext.getPackageName() + ".provider", newFile);
            intent.setType("image/*");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.putExtra(Intent.EXTRA_STREAM, contentUri);
            intent.setDataAndType(contentUri, mContext.getContentResolver().getType(contentUri));

        } else {
            intent.setType("text/plain");
            intent.putExtra(Intent.EXTRA_SUBJECT, title);
            intent.putExtra(Intent.EXTRA_TEXT, linkUrl);
        }
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

        List<ResolveInfo> resInfo = mContext.getPackageManager().queryIntentActivities(intent, 0);

        // Check apps are available or not for accept action from intent.
        if (resInfo.size() > 0) {
            Intent chooserIntent = Intent.createChooser(intent,
                    mContext.getString(R.string.share_via) + "…");
            ((Activity) mContext).startActivityForResult(chooserIntent, ConstantVariables.OUTSIDE_SHARING_CODE);
        }
    }

}
