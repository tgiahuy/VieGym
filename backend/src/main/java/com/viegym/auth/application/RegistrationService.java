package com.viegym.auth.application;

import com.viegym.auth.api.RegisterChallengeResponse;
import com.viegym.auth.api.RegisterRequest;
import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.identity.User;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.identity.UserRepository;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RegistrationService {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final String DUPLICATE_EMAIL_MESSAGE =
            "Verification instructions have been sent if the address is eligible";

    private final UserRepository users;
    private final UserProfileRepository profiles;
    private final PasswordEncoder passwordEncoder;
    private final RegistrationChallengeIssuer challengeIssuer;

    public RegistrationService(
            UserRepository users,
            UserProfileRepository profiles,
            PasswordEncoder passwordEncoder,
            RegistrationChallengeIssuer challengeIssuer) {
        this.users = users;
        this.profiles = profiles;
        this.passwordEncoder = passwordEncoder;
        this.challengeIssuer = challengeIssuer;
    }

    @Transactional
    public RegisterChallengeResponse register(RegisterRequest request) {
        NormalizedRegistration normalized = normalizeAndValidate(request);
        if (users.existsByEmail(normalized.email())) {
            throw new ApiException(ApiErrorCode.EMAIL_ALREADY_EXISTS, DUPLICATE_EMAIL_MESSAGE);
        }

        try {
            User user =
                    users.save(
                            new User(
                                    normalized.email(),
                                    passwordEncoder.encode(normalized.password())));
            profiles.save(new UserProfile(user, normalized.displayName()));
            return challengeIssuer.issue(user);
        } catch (DataIntegrityViolationException exception) {
            throw new ApiException(ApiErrorCode.EMAIL_ALREADY_EXISTS, DUPLICATE_EMAIL_MESSAGE);
        }
    }

    private NormalizedRegistration normalizeAndValidate(RegisterRequest request) {
        String displayName = trim(request == null ? null : request.displayName());
        String email = normalizeEmail(request == null ? null : request.email());
        String password = request == null ? null : request.password();
        List<FieldViolation> violations = new ArrayList<>();

        if (displayName == null || displayName.isBlank()) {
            violations.add(
                    new FieldViolation("displayName", "REQUIRED", "displayName is required"));
        } else if (displayName.length() > 120) {
            violations.add(
                    new FieldViolation(
                            "displayName", "SIZE", "displayName must be at most 120 characters"));
        }

        if (email == null || email.isBlank()) {
            violations.add(new FieldViolation("email", "REQUIRED", "email is required"));
        } else if (email.length() > 255) {
            violations.add(
                    new FieldViolation("email", "SIZE", "email must be at most 255 characters"));
        } else if (!EMAIL_PATTERN.matcher(email).matches()) {
            violations.add(new FieldViolation("email", "EMAIL", "email must be valid"));
        }

        if (password == null || password.isBlank()) {
            violations.add(new FieldViolation("password", "REQUIRED", "password is required"));
        } else {
            if (password.length() < 8) {
                violations.add(
                        new FieldViolation(
                                "password", "SIZE", "password must be at least 8 characters"));
            }
            if (password.length() > 72) {
                violations.add(
                        new FieldViolation(
                                "password", "SIZE", "password must be at most 72 characters"));
            }
            if (!password.chars().anyMatch(Character::isLetter)
                    || !password.chars().anyMatch(Character::isDigit)) {
                violations.add(
                        new FieldViolation(
                                "password",
                                "PATTERN",
                                "password must contain a letter and a digit"));
            }
        }

        if (!violations.isEmpty()) {
            throw new ApiValidationException(violations);
        }

        return new NormalizedRegistration(displayName, email, password);
    }

    private String normalizeEmail(String value) {
        String trimmed = trim(value);
        return trimmed == null ? null : trimmed.toLowerCase(Locale.ROOT);
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private record NormalizedRegistration(String displayName, String email, String password) {}
}
