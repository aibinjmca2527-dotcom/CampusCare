package com.campuscare.util;

import java.io.File;
import javax.servlet.ServletContext;

public final class UploadUtil {

    private static final String FALLBACK_DIR_NAME = "campuscare_uploads";

    private UploadUtil() {
    }

    public static File getUploadDirectory(ServletContext context) {
        String configured = context.getInitParameter("uploadDir");
        if (configured != null && !configured.trim().isEmpty()) {
            File dir = new File(configured.trim());
            ensureExists(dir);
            return dir;
        }

        String catalinaBase = System.getProperty("catalina.base");
        if (catalinaBase != null && !catalinaBase.isEmpty()) {
            File dir = new File(catalinaBase, FALLBACK_DIR_NAME);
            ensureExists(dir);
            return dir;
        }

        File dir = new File(System.getProperty("user.home"), FALLBACK_DIR_NAME);
        ensureExists(dir);
        return dir;
    }

    private static void ensureExists(File dir) {
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }
}
