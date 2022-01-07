package com.socialengineaddons.mobileapp.classes.modules.liveStreaming;

import android.content.Context;
import android.provider.Settings;

import com.socialengineaddons.mobileapp.R;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.common.utils.PreferencesUtils;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.listener.OnAgoraSignalingInterface;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.listener.OnAppCloseListener;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.model.EngineConfig;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.model.MyEngineEventHandler;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.model.WorkerThread;

import org.json.JSONException;
import org.json.JSONObject;


import io.agora.AgoraAPI;
import io.agora.AgoraAPIOnlySignal;
import io.agora.rtc.RtcEngine;


public class LiveStreamUtils {

    // Member variables.
    private Context mContext;
    private String selfUid = "";
    private WorkerThread mWorkerThread;
    private AgoraAPIOnlySignal agoraAPISignal;
    private OnAgoraSignalingInterface mOnAgoraSignalingInterface;
    private OnAppCloseListener mOnAppCloseListener;


    private static final LiveStreamUtils ourInstance = new LiveStreamUtils();

    public static LiveStreamUtils getInstance() {
        return ourInstance;
    }

    private LiveStreamUtils() {
    }

    public void setContext(Context context) {
        mContext = context;
        if (PreferencesUtils.getUserDetail(mContext) != null) {
            try {
                JSONObject userDetail = new JSONObject(PreferencesUtils.getUserDetail(mContext));
                selfUid = userDetail.optString("user_id");
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        initializeAgoraEngine();
    }

    public void setOnAgoraSignalingInterface(OnAgoraSignalingInterface mOnAgoraSignalingInterface) {
        this.mOnAgoraSignalingInterface = mOnAgoraSignalingInterface;
    }

    public void setOnAppCloseListener(OnAppCloseListener mOnAppCloseListener) {
        this.mOnAppCloseListener = mOnAppCloseListener;
    }

    public void onAppClosed() {
        if (mOnAppCloseListener != null) {
            mOnAppCloseListener.onAppClosed();
        }
    }

    public void initializeAgoraEngine() {
        try {
            agoraAPISignal = AgoraAPIOnlySignal.getInstance(mContext,
                    mContext.getResources().getString(R.string.agora_app_id));
            loginAgoraSignalling();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public synchronized void initWorkerThread() {
        if (mWorkerThread == null) {
            mWorkerThread = new WorkerThread(mContext);
            mWorkerThread.start();

            mWorkerThread.waitForReady();
        }
    }

    public synchronized WorkerThread getWorkerThread() {
        return mWorkerThread;
    }

    public synchronized void deInitWorkerThread() {
        mWorkerThread.exit();
        try {
            mWorkerThread.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        mWorkerThread = null;
    }

    public RtcEngine rtcEngine() {
        return getWorkerThread().getRtcEngine();
    }

    public final WorkerThread worker() {
        return getWorkerThread();
    }

    public final EngineConfig config() {
        return getWorkerThread().getEngineConfig();
    }

    public final MyEngineEventHandler event() {
        return getWorkerThread().eventHandler();
    }

    public AgoraAPIOnlySignal getAgoraAPISignal() {
        if (agoraAPISignal == null) {
            initializeAgoraEngine();
            return agoraAPISignal;
        }
        return agoraAPISignal;
    }

    public void loginAgoraSignalling() {
        agoraAPISignal.login2(mContext.getResources().getString(R.string.agora_app_id),
                selfUid + Settings.Secure.getString(mContext.getContentResolver(),
                        Settings.Secure.ANDROID_ID),
                "_no_need_token", 0, "", 5, 5);

        agoraAPISignal.callbackSet(new AgoraAPI.CallBack() {

            @Override
            public void onLogout(int i) {

            }

            @Override
            public void onLoginFailed(int i) {
                loginAgoraSignalling();
            }

            @Override
            public void onMessageChannelReceive(String channelName, String account, int uid, String msg) {
                LogUtils.LOGD(LiveStreamUtils.class.getSimpleName(), "onMessageChannelReceive, channelName: " + channelName + ", account: " + account + ", uid: " + uid + ", msg: " + msg);
                if (mOnAgoraSignalingInterface != null) {
                    mOnAgoraSignalingInterface.onMessageChannelReceive(channelName, account, uid, msg);
                }
            }
        });
    }

}
