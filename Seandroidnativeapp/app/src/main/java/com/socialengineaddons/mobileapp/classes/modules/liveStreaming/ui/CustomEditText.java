/*
 *   Copyright (c) 2018 BigStep Technologies Private Limited.
 *
 *   You may not use this file except in compliance with the
 *   SocialEngineAddOns License Agreement.
 *   You may obtain a copy of the License at:
 *   https://www.socialengineaddons.com/android-app-license
 *   The full copyright and license information is also mentioned
 *   in the LICENSE file that was distributed with this
 *   source code.
 */

package com.socialengineaddons.mobileapp.classes.modules.liveStreaming.ui;

import android.content.Context;
import android.graphics.Rect;
import android.support.v7.widget.AppCompatEditText;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;

import com.socialengineaddons.mobileapp.classes.modules.liveStreaming.listener.KeyboardCloseListener;


public class CustomEditText extends AppCompatEditText {

    private KeyboardCloseListener keyboardCloseListener;


    public CustomEditText(Context context) {
        super(context, null);
    }

    public CustomEditText(Context context, AttributeSet attrs) {
        super(context, attrs);
        setTextIsSelectable(true);
    }

    public void setKeyboardCloseListener(KeyboardCloseListener keyboardCloseListener) {
        this.keyboardCloseListener = keyboardCloseListener;
    }

    @Override
    protected void onFocusChanged(boolean focused, int direction, Rect previouslyFocusedRect) {
        super.onFocusChanged(focused, direction, previouslyFocusedRect);
        post(new Runnable() {
            @Override
            public void run() {
                InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                if (imm != null) {
                    imm.showSoftInput(CustomEditText.this, InputMethodManager.SHOW_IMPLICIT);
                }
            }
        });
    }

    @Override
    public void onEditorAction(int actionCode) {
        super.onEditorAction(actionCode);
        if (actionCode == EditorInfo.IME_ACTION_DONE) {
            keyboardClose();
        }
    }

    @Override
    public boolean onKeyPreIme(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            keyboardClose();
        }
        return false;
    }

    private void keyboardClose() {
        // User has pressed Back key. So hide the keyboard
        InputMethodManager mgr = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (mgr != null) {
            mgr.hideSoftInputFromWindow(this.getWindowToken(), 0);
        }

        if (keyboardCloseListener != null) {
            keyboardCloseListener.onKeyboardClosed(getText().toString());
        }
    }
}
