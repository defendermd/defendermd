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
 *
 */

package com.socialengineaddons.mobileapp.classes.modules.autoplayvideo;

import android.app.Activity;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.os.Build;
import android.util.AttributeSet;
import android.view.Surface;
import android.view.TextureView;

import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.Timeline;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
import com.socialengineaddons.mobileapp.classes.common.interfaces.OnVideoCompletionListener;
import com.socialengineaddons.mobileapp.classes.common.utils.LogUtils;
import java.util.concurrent.Callable;


public class CustomExoVideoView extends TextureView implements TextureView.SurfaceTextureListener {
    private SimpleExoPlayer mMediaPlayer;
    private boolean isLooping = false, isPaused = false;
    private Callable<Integer> myFuncIn = null;
    private Callable<Integer> showThumb = null;
    private Activity mActivity;
    private String mSourceUrl;
    private OnVideoCompletionListener onVideoCompletionListener;

    public void setShowThumb(Callable<Integer> showThumb) {
        this.showThumb = showThumb;
    }

    public CustomExoVideoView(Context context) {
        this(context, null, 0);
    }

    public CustomExoVideoView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CustomExoVideoView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    public void setPaused(boolean paused) {
        isPaused = paused;
    }

    public void setSource(String url) {
        mSourceUrl = url;
    }


    public String getSource() {
        return mSourceUrl;
    }

    public void setActivityInstance(Activity _act) {
        this.mActivity = _act;
    }

    public void setMyFuncIn(Callable<Integer> myFuncIn) {
        this.myFuncIn = myFuncIn;
    }

    public void setOnVideoCompletionListener(OnVideoCompletionListener onVideoCompletionListener){
        this.onVideoCompletionListener = onVideoCompletionListener;
    }

    public void startVideo() {
        if (!isPaused && mSourceUrl != null) {
            setSurfaceTextureListener(this);

            if (this.getSurfaceTexture() != null) {
                setExoPlayerData();
            }
        }
    }

    /* Create ExoPlayer and SurfaceView and play the video */
    private void setExoPlayerData() {
        if (mMediaPlayer != null) {
            mMediaPlayer.setPlayWhenReady(true);
            mMediaPlayer.getPlaybackState();
            try {
                myFuncIn.call();
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            Surface surface = new Surface(this.getSurfaceTexture());
            try {
                mMediaPlayer = ExoPlayerFactory.newSimpleInstance(getContext());
                /* Default sound is off */
                muteVideo();
                mMediaPlayer.setPlayWhenReady(true);

                MediaSource mediaSource = Utils.buildMediaSource(getContext(), mSourceUrl);
                mMediaPlayer.prepare(mediaSource);

                mMediaPlayer.setVideoSurface(surface);
                mMediaPlayer.addListener(new Player.EventListener() {
                    @Override
                    public void onTimelineChanged(Timeline timeline, Object manifest, int reason) {

                    }

                    @Override
                    public void onTracksChanged(TrackGroupArray trackGroups, TrackSelectionArray trackSelections) {

                    }

                    @Override
                    public void onLoadingChanged(boolean isLoading) {

                    }

                    @Override
                    public void onPlayerStateChanged(boolean playWhenReady, int playbackState) {
                        switch (playbackState) {
                            case Player.STATE_READY:
                                mActivity.runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        try {
                                            myFuncIn.call();
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                        }
                                    }
                                });
                                break;

                            case Player.STATE_BUFFERING:
                                onVideoCompletionListener.onVideoBuffering();
                                break;

                            case Player.STATE_ENDED:
                                onVideoCompletionListener.onVideoComplete();
                                mMediaPlayer.seekTo(0);
                                mMediaPlayer.setPlayWhenReady(false);
                                break;
                        }
                    }

                    @Override
                    public void onRepeatModeChanged(int repeatMode) {

                    }

                    @Override
                    public void onShuffleModeEnabledChanged(boolean shuffleModeEnabled) {

                    }

                    @Override
                    public void onPlayerError(ExoPlaybackException error) {

                    }

                    @Override
                    public void onPositionDiscontinuity(int reason) {

                    }

                    @Override
                    public void onPlaybackParametersChanged(PlaybackParameters playbackParameters) {

                    }

                    @Override
                    public void onSeekProcessed() {

                    }
                });

            } catch (IllegalArgumentException e) {
                e.printStackTrace();
            } catch (SecurityException e) {
                e.printStackTrace();
            } catch (IllegalStateException e) {
                e.printStackTrace();
            }
        }
    }

    /* Set looping true if want to play video in loop */
    public void setLooping(boolean looping) {
        isLooping = looping;
    }

    @Override
    protected void onDetachedFromWindow() {
        // release resources on detach
        if (mMediaPlayer != null) {
            mMediaPlayer.release();
            mMediaPlayer = null;
        }
        try {
            if (showThumb != null) showThumb.call();
        } catch (Exception e) {
            //e.printStackTrace();
        }
        super.onDetachedFromWindow();
    }


    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int width, int height) {
        LogUtils.LOGD("CustomExoVideoView ", "startVideo: " + mMediaPlayer + " - " + isPaused + " - " + mSourceUrl + " - " + this.getSurfaceTexture() );
        if (!isPaused) {
            setExoPlayerData();
        }
    }


    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
        LogUtils.LOGD(CustomExoVideoView.class.getSimpleName(), " onSurfaceTextureDestroyed: ");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            //pre lollipop needs SurfaceTexture it owns before calling onDetachedFromWindow super
            surface.release();
        }
        if (mMediaPlayer != null) {
            mMediaPlayer.release();
            mMediaPlayer = null;
        }

        try {
            showThumb.call();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return true;
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surface) {
    }

    /* Clear ExoPlayer and SurfaceView instance */
    public void clearAll() {
        if (getSurfaceTexture() != null)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                //pre lollipop needs SurfaceTexture it owns before calling onDetachedFromWindow super
                getSurfaceTexture().release();
            }
        clearVideo();
        setSurfaceTextureListener(null);
    }

    /* Clear ExoPlayer instance */
    public void clearVideo() {
        if (mMediaPlayer != null) {
            mMediaPlayer.release();
            mMediaPlayer = null;
        }
    }

    public void pauseVideo() {
        if (mMediaPlayer != null) {
            mMediaPlayer.setPlayWhenReady(false);
            mMediaPlayer.getPlaybackState();
        }
    }

    /* To check video is playing or not */
    public boolean isPlaying() {
        if (mMediaPlayer != null) {
            mMediaPlayer.getPlaybackState();
            if (mMediaPlayer.getPlaybackState() == Player.STATE_BUFFERING
                    || mMediaPlayer.getPlaybackState() == Player.STATE_READY) {
                return true;
            }
        }
        return false;
    }

    public void muteVideo() {
        if (mMediaPlayer != null)
            mMediaPlayer.setVolume(0f);
    }

    public void unmuteVideo() {
        if (mMediaPlayer != null)
            mMediaPlayer.setVolume(1f);
    }

    public int getResumeWindowState(){
        if (mMediaPlayer != null) {
            return mMediaPlayer.getCurrentWindowIndex();
        }
        return 0;
    }

    public long getPlaybackPosition() {
        if (mMediaPlayer != null) {
            return Math.max(0, mMediaPlayer.getContentPosition());
        }
        return 0;
    }

    public void resumeVideoFromPlaybackState(int resumeWindow, long playBackPosition) {
        isPaused = false;
        if (mMediaPlayer != null) {
            mMediaPlayer.seekTo(resumeWindow, playBackPosition);
            mMediaPlayer.setPlayWhenReady(true);
        }
    }

    public void seekToVideo(int resumeWindow, long playBackPosition) {
        if (mMediaPlayer != null) {
            mMediaPlayer.seekTo(resumeWindow, playBackPosition);
        }
    }
}
