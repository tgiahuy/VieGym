package com.viegym.otp;

import com.viegym.identity.OtpPurpose;

/**
 * Port for sending a one-time code to a destination (email, SMS, …). Implementations are selected
 * via {@code otp.provider} configuration.
 */
public interface OtpSender {

    /**
     * Sends {@code plainCode} to {@code destination} for the given {@code purpose}.
     *
     * @param destination email address or phone number to send the code to
     * @param purpose business reason the OTP was issued
     * @param plainCode the raw (un-hashed) code to deliver
     */
    void send(String destination, OtpPurpose purpose, String plainCode);
}
