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


package com.socialengineaddons.mobileapp.classes.common.utils.okhttp;

import java.io.IOException;

import okhttp3.Response;

public abstract class StringCallback extends OkHttpCallBack<String>
{
    @Override
    public String parseNetworkResponse(Response response, Object tag) throws IOException
    {
        return response.body().string();
    }
}
