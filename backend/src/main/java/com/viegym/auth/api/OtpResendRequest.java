package com.viegym.auth.api;

import com.viegym.identity.OtpPurpose;

public record OtpResendRequest(String challengeId, OtpPurpose purpose) {}
