package com.campuscare.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import javax.servlet.ServletContext;

public final class MailConfig {

    private final boolean enabled;
    private final String host;
    private final int port;
    private final String username;
    private final String password;
    private final String from;
    private final boolean startTls;

    private MailConfig(boolean enabled, String host, int port, String username,
                       String password, String from, boolean startTls) {
        this.enabled = enabled;
        this.host = host;
        this.port = port;
        this.username = username;
        this.password = password;
        this.from = from;
        this.startTls = startTls;
    }

    public static MailConfig load(ServletContext context) {
        Properties props = new Properties();
        InputStream in = null;
        try {
            String path = context.getRealPath("/WEB-INF/email.properties");
            if (path != null) {
                File file = new File(path);
                if (file.isFile()) {
                    in = new FileInputStream(file);
                    props.load(in);
                }
            }
            if (props.isEmpty()) {
                in = context.getResourceAsStream("/WEB-INF/email.properties");
                if (in != null) {
                    props.load(in);
                }
            }
        } catch (IOException ignored) {
        } finally {
            if (in != null) {
                try {
                    in.close();
                } catch (IOException ignored) {
                }
            }
        }

        boolean enabled = Boolean.parseBoolean(props.getProperty("mail.enabled", "false"));
        String host = props.getProperty("mail.smtp.host", "smtp.gmail.com");
        int port = Integer.parseInt(props.getProperty("mail.smtp.port", "587"));
        String username = props.getProperty("mail.smtp.username", "");
        String password = props.getProperty("mail.smtp.password", "");
        String from = props.getProperty("mail.from", username);
        boolean startTls = Boolean.parseBoolean(props.getProperty("mail.smtp.starttls", "true"));
        return new MailConfig(enabled, host, port, username, password, from, startTls);
    }

    public boolean isEnabled() {
        return enabled && host != null && !host.isEmpty() && from != null && !from.isEmpty();
    }

    public String getHost() { return host; }
    public int getPort() { return port; }
    public String getUsername() { return username; }
    public String getPassword() { return password; }
    public String getFrom() { return from; }
    public boolean isStartTls() { return startTls; }
}
