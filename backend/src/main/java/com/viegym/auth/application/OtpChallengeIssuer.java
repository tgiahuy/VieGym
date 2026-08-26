package com.viegym.auth.application;

import com.viegym.auth.api.RegisterChallengeResponse;
import com.viegym.identity.OtpPurpose;
import com.viegym.identity.User;
import java.time.Clock;
import java.time.OffsetDateTime;
import org.springframework.stereotype.Component;

/**
 * Issues the initial REGISTER OTP challenge after a successful registration. Delegates all OTP
 * creation logic to {@link OtpIssueHelper}.
 */
@Component
class OtpChallengeIssuer implements RegistrationChallengeIssuer {

    private final OtpIssueHelper helper;
    private final Clock clock;

    OtpChallengeIssuer(OtpIssueHelper helper, Clock clock) {
        this.helper = helper;
        this.clock = clock;
    }

    @Override
    public RegisterChallengeResponse issue(User user) {
        return helper.createAndSend(user, OtpPurpose.REGISTER, OffsetDateTime.now(clock));
    }
}
