package com.viegym.profile.application;

import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.identity.User;
import com.viegym.identity.UserOnboardingRepository;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.identity.UserRepository;
import com.viegym.profile.api.UpdateUserRequest;
import com.viegym.profile.api.UserResponse;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.zone.ZoneRulesException;
import java.util.ArrayList;
import java.util.IllformedLocaleException;
import java.util.List;
import java.util.Locale;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserProfileService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserOnboardingRepository userOnboardingRepository;
    private final Clock clock;

    public UserProfileService(
            UserRepository userRepository,
            UserProfileRepository userProfileRepository,
            UserOnboardingRepository userOnboardingRepository,
            Clock clock) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.userOnboardingRepository = userOnboardingRepository;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public UserResponse get(Long authenticatedUserId) {
        User user = requireUser(authenticatedUserId);
        UserProfile profile = requireProfile(authenticatedUserId);
        return response(user, profile);
    }

    @Transactional
    public UserResponse update(Long authenticatedUserId, UpdateUserRequest request) {
        validate(request);
        User user = requireUser(authenticatedUserId);
        UserProfile profile = requireProfile(authenticatedUserId);
        profile.update(
                request.displayName().trim(),
                request.timezone(),
                request.locale(),
                OffsetDateTime.now(clock));
        return response(user, profile);
    }

    private void validate(UpdateUserRequest request) {
        List<FieldViolation> violations = new ArrayList<>();
        request.unknownFields().stream()
                .sorted()
                .map(field -> new FieldViolation(field, "UNKNOWN_FIELD", "Field is not allowed"))
                .forEach(violations::add);
        if (request.avatarMediaId() != null) {
            violations.add(
                    new FieldViolation(
                            "avatarMediaId",
                            "NOT_SUPPORTED",
                            "Profile avatar uploads are not supported yet"));
        }
        if (request.timezone() != null && request.timezone().length() <= 64) {
            try {
                ZoneId.of(request.timezone());
            } catch (ZoneRulesException exception) {
                violations.add(
                        new FieldViolation(
                                "timezone",
                                "INVALID_TIMEZONE",
                                "timezone must be a valid IANA ID"));
            }
        }
        if (request.locale() != null && request.locale().length() <= 10) {
            try {
                new Locale.Builder().setLanguageTag(request.locale()).build();
            } catch (IllformedLocaleException exception) {
                violations.add(
                        new FieldViolation(
                                "locale", "INVALID_LOCALE", "locale must be a valid language tag"));
            }
        }
        if (!violations.isEmpty()) {
            throw new ApiValidationException(violations);
        }
    }

    private User requireUser(Long userId) {
        return userRepository
                .findById(userId)
                .orElseThrow(
                        () ->
                                new ApiException(
                                        ApiErrorCode.RESOURCE_NOT_FOUND, "User profile not found"));
    }

    private UserProfile requireProfile(Long userId) {
        return userProfileRepository
                .findByUserId(userId)
                .orElseThrow(
                        () ->
                                new ApiException(
                                        ApiErrorCode.RESOURCE_NOT_FOUND, "User profile not found"));
    }

    private UserResponse response(User user, UserProfile profile) {
        UserResponse.AvatarResponse avatar =
                profile.avatarMediaId() == null
                        ? null
                        : new UserResponse.AvatarResponse(profile.avatarMediaId(), null, null);
        return new UserResponse(
                user.id(),
                user.email(),
                profile.displayName(),
                avatar,
                profile.timezone(),
                profile.locale(),
                user.role().name(),
                user.authProvider().name(),
                new UserResponse.OnboardingResponse(
                        userOnboardingRepository.healthProfileCompleted(user.id()),
                        userOnboardingRepository.equipmentCompleted(user.id())));
    }
}
