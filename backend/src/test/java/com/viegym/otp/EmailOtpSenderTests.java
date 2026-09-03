package com.viegym.otp;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import com.viegym.identity.OtpPurpose;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

class EmailOtpSenderTests {

    @Test
    void sendsRegistrationOtpWithoutLeakingItIntoTheSubject() {
        JavaMailSender mailSender = mock(JavaMailSender.class);
        EmailOtpSender sender = new EmailOtpSender(mailSender, "noreply@viegym.vn");

        sender.send("athlete@gmail.com", OtpPurpose.REGISTER, "123456");

        ArgumentCaptor<SimpleMailMessage> captor = ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mailSender).send(captor.capture());
        SimpleMailMessage message = captor.getValue();
        assertThat(message.getFrom()).isEqualTo("noreply@viegym.vn");
        assertThat(message.getTo()).containsExactly("athlete@gmail.com");
        assertThat(message.getSubject()).contains("VieGym").doesNotContain("123456");
        assertThat(message.getText()).contains("123456", "10 phút");
    }

    @Test
    void usesPasswordResetCopyForPasswordResetOtp() {
        JavaMailSender mailSender = mock(JavaMailSender.class);
        EmailOtpSender sender = new EmailOtpSender(mailSender, "noreply@viegym.vn");

        sender.send("athlete@gmail.com", OtpPurpose.PASSWORD_RESET, "654321");

        ArgumentCaptor<SimpleMailMessage> captor = ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mailSender).send(captor.capture());
        assertThat(captor.getValue().getSubject()).contains("đặt lại mật khẩu");
        assertThat(captor.getValue().getText()).contains("654321");
    }
}
