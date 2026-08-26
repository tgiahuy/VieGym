package com.viegym.auth.api;

import com.viegym.identity.OtpPurpose;
import java.time.OffsetDateTime;

public record RegisterChallengeResponse(
        String challengeId,
        String maskedDestination,
        OtpPurpose purpose,
        OffsetDateTime expiresAt,
        OffsetDateTime resendAvailableAt) {}
