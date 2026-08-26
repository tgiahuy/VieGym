package com.viegym.auth.api;

import com.viegym.identity.OtpPurpose;

public record OtpVerifyRequest(String challengeId, OtpPurpose purpose, String code) {}
