package com.viegym.auth.application;

import com.viegym.auth.api.OtpResendRequest;
import com.viegym.auth.api.RegisterChallengeResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.identity.OtpCode;
import com.viegym.identity.OtpCodeRepository;
import com.viegym.identity.SecurityRateLimitEvent;
import com.viegym.identity.SecurityRateLimitEventRepository;
import com.viegym.identity.User;
import com.viegym.identity.UserRepository;
import java.time.Clock;
import java.time.Duration;
import java.time.OffsetDateTime;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Handles OTP resend requests for any purpose (REGISTER, PASSWORD_RESET, …).
 *
 * <h3>Checks performed (in order)</h3>
 *
 * <ol>
 *   <li>The challenge ID resolves to an existing {@code otp_codes} record.
 *   <li>The OTP has not already been consumed (used for successful verification).
 *   <li>The per-challenge cooldown ({@code resend_available_at}) has elapsed.
 *   <li>The sliding-window rate limit on {@code OTP_SEND} events for this destination has not been
 *       reached.
 * </ol>
 *
 * <p>On success the existing OTP is consumed (invalidated) atomically with the creation of the new
 * one, preventing replay of the old code after a resend.
 */
@Service
public class OtpResendService {

    private static final String OTP_PREFIX = "otp_";

    private final OtpCodeRepository otpCodes;
    private final UserRepository users;
    private final SecurityRateLimitEventRepository rateLimitEvents;
    private final OtpIssueHelper issueHelper;
    private final Clock clock;
    private final Duration rateLimitWindow;
    private final int rateLimitMax;

    public OtpResendService(
            OtpCodeRepository otpCodes,
            UserRepository users,
            SecurityRateLimitEventRepository rateLimitEvents,
            OtpIssueHelper issueHelper,
            Clock clock,
            @Value("${OTP_RESEND_RATE_LIMIT_WINDOW:PT1H}") Duration rateLimitWindow,
            @Value("${OTP_RESEND_RATE_LIMIT_MAX:5}") int rateLimitMax) {
        this.otpCodes = otpCodes;
        this.users = users;
        this.rateLimitEvents = rateLimitEvents;
        this.issueHelper = issueHelper;
        this.clock = clock;
        this.rateLimitWindow = rateLimitWindow;
        this.rateLimitMax = rateLimitMax;
    }

    /**
     * Validates the resend request, invalidates the existing OTP, and issues a fresh one.
     *
     * @param request contains the {@code challengeId} from the original registration response
     * @return a new challenge response with a fresh {@code challengeId} and updated timestamps
     */
    @Transactional
    public RegisterChallengeResponse resend(OtpResendRequest request) {
        Long otpId = parseChallengeId(request.challengeId());
        OffsetDateTime now = OffsetDateTime.now(clock);

        OtpCode otp =
                otpCodes.findById(otpId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.OTP_INVALID,
                                                "OTP not found or invalid"));

        // Guard 1: cannot resend an already-consumed OTP.
        if (otp.consumedAt() != null) {
            throw new ApiException(ApiErrorCode.OTP_INVALID, "OTP has already been used");
        }
        if (request.purpose() != null && request.purpose() != otp.purpose()) {
            throw new ApiException(ApiErrorCode.OTP_INVALID, "OTP purpose does not match");
        }

        // Guard 2: cooldown must have elapsed.
        if (now.isBefore(otp.resendAvailableAt())) {
            throw new ApiException(
                    ApiErrorCode.OTP_COOLDOWN, "Resend cooldown has not yet elapsed");
        }

        // Guard 3: sliding-window rate limit.
        String subjectKeyHash = OtpIssueHelper.sha256Hex(otp.destination());
        long sendCount =
                rateLimitEvents.countByScopeAndSubjectKeyHashSince(
                        SecurityRateLimitEvent.SCOPE_OTP_SEND,
                        subjectKeyHash,
                        now.minus(rateLimitWindow));
        if (sendCount >= rateLimitMax) {
            throw new ApiException(ApiErrorCode.RATE_LIMITED, "OTP resend rate limit exceeded");
        }

        // Invalidate the existing OTP atomically — prevents replay of the old code after resend.
        otp.consume(now);

        // Resolve the user and issue a fresh OTP.
        Long userId = otp.user().id();
        User user =
                users.findById(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND, "User not found"));

        return issueHelper.createAndSend(user, otp.purpose(), now);
    }

    private static Long parseChallengeId(String challengeId) {
        if (challengeId == null || !challengeId.startsWith(OTP_PREFIX)) {
            throw new ApiException(ApiErrorCode.OTP_INVALID, "Invalid challenge ID");
        }
        try {
            return Long.parseLong(challengeId.substring(OTP_PREFIX.length()));
        } catch (NumberFormatException e) {
            throw new ApiException(ApiErrorCode.OTP_INVALID, "Invalid challenge ID");
        }
    }
}
