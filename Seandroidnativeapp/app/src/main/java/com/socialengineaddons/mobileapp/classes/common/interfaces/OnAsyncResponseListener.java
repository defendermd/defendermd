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

package com.socialengineaddons.mobileapp.classes.common.interfaces;

import org.json.JSONObject;

// Interface to be implemented by calling activity
public interface OnAsyncResponseListener {
    /**
     * Method is called after getting response in onPostExecute() method.
     * @param response JsonObject of Server response.
     * @param isRequestSuccessful true if request is successfully completed.
     * @param isAttachFileRequest true if the request is for attaching attachment.
     */
    void onAsyncSuccessResponse(JSONObject response, boolean isRequestSuccessful, boolean isAttachFileRequest);
}
