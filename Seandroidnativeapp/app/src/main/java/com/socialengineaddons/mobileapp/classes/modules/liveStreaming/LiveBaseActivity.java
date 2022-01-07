package com.socialengineaddons.mobileapp.classes.modules.liveStreaming;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.Window;


import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import com.socialengineaddons.mobileapp.classes.core.AppConstant;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.model.EngineConfig;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.model.MyEngineEventHandler;
import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.model.WorkerThread;

import java.util.Arrays;

import io.agora.rtc.RtcEngine;


public abstract class LiveBaseActivity extends AppCompatActivity {

    private AppConstant mAppConst;
    private LiveStreamUtils liveStreamUtils = LiveStreamUtils.getInstance();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mAppConst = new AppConstant(LiveBaseActivity.this);
        liveStreamUtils.setContext(LiveBaseActivity.this);

        final View layout = findViewById(Window.ID_ANDROID_CONTENT);
        ViewTreeObserver vto = layout.getViewTreeObserver();
        vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                    layout.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                } else {
                    layout.getViewTreeObserver().removeGlobalOnLayoutListener(this);
                }
                LogUtils.LOGD(LiveBaseActivity.class.getSimpleName(), "onGlobalLayout");
                if (hasPermissions()) {
                    liveStreamUtils.initWorkerThread();
                }
                initUIEvent();
                checkSelfPermission();
            }
        });
    }

    protected abstract void initUIEvent();

    protected abstract void performAfterPermission();

    protected abstract void destroyUIEvent();

    protected void onPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {

    }

    @Override
    protected void onDestroy() {
        destroyUIEvent();
        super.onDestroy();
    }

    public void checkSelfPermission() {
        if (hasPermissions()) {
            liveStreamUtils.initWorkerThread();
            performAfterPermission();
        }  else if (!mAppConst.checkManifestPermission(Manifest.permission.CAMERA)) {
            mAppConst.requestForManifestPermission(Manifest.permission.CAMERA, ConstantVariables.PERMISSION_CAMERA);
        } else if (!mAppConst.checkManifestPermission(Manifest.permission.RECORD_AUDIO)) {
            mAppConst.requestForManifestPermission(Manifest.permission.RECORD_AUDIO, ConstantVariables.PERMISSION_RECORD_AUDIO);
        } else {
            mAppConst.requestForManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE, ConstantVariables.WRITE_EXTERNAL_STORAGE);
        }
    }

    protected boolean hasPermissions() {
        return mAppConst.checkManifestPermission(Manifest.permission.RECORD_AUDIO)
                && mAppConst.checkManifestPermission(Manifest.permission.CAMERA)
                && mAppConst.checkManifestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE);
    }

    protected RtcEngine rtcEngine() {
        return liveStreamUtils.getWorkerThread().getRtcEngine();
    }

    protected final WorkerThread worker() {
        return liveStreamUtils.getWorkerThread();
    }

    protected final EngineConfig config() {
        return liveStreamUtils.getWorkerThread().getEngineConfig();
    }

    protected final MyEngineEventHandler event() {
        return liveStreamUtils.getWorkerThread().eventHandler();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        LogUtils.LOGD(LiveBaseActivity.class.getSimpleName(), "onRequestPermissionsResult " + requestCode + ", " + Arrays.toString(permissions) + ", " + Arrays.toString(grantResults));
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        onPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case ConstantVariables.PERMISSION_RECORD_AUDIO:
            case ConstantVariables.PERMISSION_CAMERA:
            case ConstantVariables.WRITE_EXTERNAL_STORAGE:
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    checkSelfPermission();
                } else {
                    finish();
                }
                break;
        }
    }
}
