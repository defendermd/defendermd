package com.socialengineaddons.mobileapp.classes.common.receiver;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.SmsMessage;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SMSReceiver extends BroadcastReceiver {
    private static SMSListener mListener;
    private static String rgxPattern;

    public static void bindListener(String rxPattern, SMSListener listener) {
        rgxPattern = rxPattern;
        mListener = listener;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (isNull()) {
            return;
        }
        Bundle data = intent.getExtras();
        Object[] pdus = (Object[]) data.get("pdus");
        for (int i = 0; i < pdus.length; i++) {
            SmsMessage smsMessage = SmsMessage.createFromPdu((byte[]) pdus[i]);
            //TODO, Need To Add Message Host Verification Work
            String messageBody = smsMessage.getMessageBody();
            if (rgxPattern != null) {
                Pattern pattern = Pattern.compile(rgxPattern);
                Matcher matcher = pattern.matcher(messageBody);
                mListener.onMessageReceived(matcher.group(1));
            } else {
                mListener.onMessageReceived(messageBody);
            }
            mListener = null;
            rgxPattern = null;
        }
    }

    public interface SMSListener {
        void onMessageReceived(String messageText);
    }
    private boolean isNull() {
        return (mListener == null);
    }
}
