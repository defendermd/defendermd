package com.socialengineaddons.mobileapp.classes.modules.qrscanner;

import com.journeyapps.barcodescanner.CaptureActivity;
import com.socialengineaddons.mobileapp.classes.core.ConstantVariables;

public class ScannerActivity extends CaptureActivity {
    @Override
    public void onBackPressed() {

        setResult(ConstantVariables.CANCELED_QR_SCAN);
        super.onBackPressed();
    }
}
