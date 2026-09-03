package com.viegym.otp;

import com.viegym.identity.OtpPurpose;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

/** Delivers one-time codes through the configured SMTP server. */
@Component
@ConditionalOnProperty(name = "otp.provider", havingValue = "email")
public class EmailOtpSender implements OtpSender {

    private final JavaMailSender mailSender;
    private final String fromAddress;

    public EmailOtpSender(
            JavaMailSender mailSender,
            @Value("${MAIL_FROM_ADDRESS:${MAIL_USERNAME:no-reply@localhost}}") String fromAddress) {
        this.mailSender = mailSender;
        this.fromAddress = fromAddress;
    }

    @Override
    public void send(String destination, OtpPurpose purpose, String plainCode) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(destination);
        message.setSubject(subjectFor(purpose));
        message.setText(bodyFor(purpose, plainCode));
        mailSender.send(message);
    }

    private static String subjectFor(OtpPurpose purpose) {
        return purpose == OtpPurpose.PASSWORD_RESET
                ? "Mã xác thực đặt lại mật khẩu VieGym"
                : "Mã xác thực tài khoản VieGym";
    }

    private static String bodyFor(OtpPurpose purpose, String plainCode) {
        String action =
                purpose == OtpPurpose.PASSWORD_RESET
                        ? "đặt lại mật khẩu"
                        : "hoàn tất đăng ký tài khoản";
        return "Mã OTP để "
                + action
                + " VieGym của bạn là: "
                + plainCode
                + "\n\nMã có hiệu lực trong 10 phút. Không chia sẻ mã này với bất kỳ ai."
                + "\nNếu bạn không yêu cầu, hãy bỏ qua email này.";
    }
}
