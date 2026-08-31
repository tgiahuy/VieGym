package com.viegym.auth.application;

import com.viegym.auth.api.FacebookLoginRequest;
import com.viegym.auth.api.SessionResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.identity.AuthProvider;
import com.viegym.identity.User;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.identity.UserRepository;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.Locale;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FacebookLoginService {

    private final FacebookIdentityVerifier verifier;
    private final UserRepository users;
    private final UserProfileRepository profiles;
    private final SessionIssuer sessions;
    private final Clock clock;

    public FacebookLoginService(
            FacebookIdentityVerifier verifier,
            UserRepository users,
            UserProfileRepository profiles,
            SessionIssuer sessions,
            Clock clock) {
        this.verifier = verifier;
        this.users = users;
        this.profiles = profiles;
        this.sessions = sessions;
        this.clock = clock;
    }

    @Transactional
    public SessionResponse login(FacebookLoginRequest request) {
        FacebookIdentity identity = verifier.verify(request == null ? null : request.accessToken());
        OffsetDateTime now = OffsetDateTime.now(clock);
        User user =
                users.findByAuthProviderAndProviderSubject(
                                AuthProvider.FACEBOOK, identity.subject())
                        .orElseGet(() -> create(identity, now));
        LoginService.ensureActive(user.status());
        user.recordLogin(now);
        return sessions.issue(user, request.deviceInfo());
    }

    private User create(FacebookIdentity identity, OffsetDateTime now) {
        if (identity.email() == null || identity.email().isBlank()) {
            throw new ApiException(
                    ApiErrorCode.INVALID_CREDENTIALS,
                    "Facebook account must have an associated email");
        }
        String email = identity.email().trim().toLowerCase(Locale.ROOT);
        if (users.findByEmail(email).isPresent()) {
            throw new ApiException(
                    ApiErrorCode.INVALID_CREDENTIALS, "An account with this email already exists");
        }
        try {
            User user = users.save(User.facebook(email, identity.subject(), now));
            String name =
                    identity.displayName() == null || identity.displayName().isBlank()
                            ? email.substring(0, email.indexOf('@'))
                            : identity.displayName().trim();
            profiles.save(new UserProfile(user, name.substring(0, Math.min(name.length(), 120))));
            return user;
        } catch (DataIntegrityViolationException exception) {
            throw new ApiException(ApiErrorCode.INVALID_CREDENTIALS, "Invalid Facebook credential");
        }
    }
}
