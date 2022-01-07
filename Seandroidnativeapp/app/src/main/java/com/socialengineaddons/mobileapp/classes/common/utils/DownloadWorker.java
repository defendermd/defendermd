package com.socialengineaddons.mobileapp.classes.common.utils;

import android.content.Context;
import android.content.ContextWrapper;
import android.support.annotation.NonNull;

import androidx.work.Worker;
import androidx.work.WorkerParameters;

import com.socialengineaddons.mobileapp.classes.modules.autoplayvideo.Utils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;

public class DownloadWorker extends Worker {

    /*
     * @Variable: usableSpace: MB available for use in device
     * @Variable: usedSpace: MB already used by downloaded videos  */

    private static final int USABLE_SPACE_iN_MB = 500;
    private static final int MAX_SPACE_iN_MB = 300;
    String url;


    /**
     * Unique job ID for this service.
     */
    static final int JOB_ID = 1000;

    public DownloadWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);


    }

    @NonNull
    @Override
    public Result doWork() {

        String url = getInputData().getString("url");
        downloadData(url);

        // Indicate success or failure with your return value:
        return Result.success();
    }

    private void downloadData(String requestUrl) {
        try {
            ContextWrapper cw = new ContextWrapper(getApplicationContext());
            File directory = cw.getDir("video", Context.MODE_PRIVATE);

            if (!directory.exists()) {
                directory.mkdir();
            } else {

                /* Calculate the space taken by video cache directory */
                long size = Utils.getFileFolderSize(directory);
                int usedSpace = (int)size/(1024 * 1024);

                /* Delete the directory and create it again if size is more then 300mb */
                if (usedSpace > MAX_SPACE_iN_MB) {
                    deleteFileData(directory);
                    downloadData(requestUrl);
                }

                /* Do not proceed next if usable space is available less then 500mb
                 and return the user back */
                int usableSpace = (int) (directory.getUsableSpace() / (1024 * 1024));
                if (usableSpace < USABLE_SPACE_iN_MB) {
                    return;
                }
            }


            File rootFile = new File(directory + File.separator + new Date().getTime() + ".mp4");
            try {
                if (!rootFile.exists()) {
                    rootFile.createNewFile();
                }
            } catch (IOException e) {
                e.printStackTrace();
                rootFile.createNewFile();
            }


            URL url = new URL(requestUrl);
            HttpURLConnection c = (HttpURLConnection) url.openConnection();
            c.setRequestMethod("GET");
            c.connect();
            FileOutputStream f = new FileOutputStream(rootFile);
            InputStream in = c.getInputStream();
            byte[] buffer = new byte[1024];
            int len1 = 0;
            while ((len1 = in.read(buffer)) > 0) {
                f.write(buffer, 0, len1);
            }
            f.close();
            Utils.saveString(getApplicationContext(), requestUrl, rootFile.getAbsolutePath());
        } catch (Exception e) {
            e.printStackTrace();

        }

    }

    /* Delete do*/
    private void deleteFileData(File dir) {
        if (dir.isDirectory()) {
            String[] children = dir.list();
            for (int i = 0; i < children.length; i++) {
                new File(dir, children[i]).delete();
            }
        }
    }
}
