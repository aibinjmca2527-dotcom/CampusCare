package com.campuscare.util;

import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public final class SimpleSmtpMail {

    private SimpleSmtpMail() {
    }

    public static void send(MailConfig config, String to, String subject, String body)
            throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.host", config.getHost());
        props.put("mail.smtp.port", String.valueOf(config.getPort()));
        // Use SSL (smtps) instead of STARTTLS to avoid Geronimo/Tomcat compatibility issues
        props.put("mail.smtp.ssl.enable", "true");
        props.put("mail.smtp.ssl.trust", config.getHost());
        props.put("mail.smtp.socketFactory.port", String.valueOf(config.getPort()));
        props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        props.put("mail.smtp.socketFactory.fallback", "false");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(config.getUsername(), config.getPassword());
            }
        });

        Message message = new MimeMessage(session);
        InternetAddress[] fromAddr = InternetAddress.parse(config.getFrom(), false);
        message.setFrom(fromAddr[0]);
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        message.setText(body);
        Transport.send(message);
    }
}
