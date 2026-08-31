package com.viegym.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.viegym.auth.api.FacebookLoginRequest;
import com.viegym.auth.api.SessionResponse;
import com.viegym.auth.application.DefaultFacebookIdentityVerifier;
import com.viegym.auth.application.FacebookIdentity;
import com.viegym.auth.application.FacebookIdentityVerifier;
import com.viegym.auth.application.FacebookLoginService;
import com.viegym.auth.application.SessionIssuer;
import com.viegym.common.error.ApiException;
import com.viegym.identity.AuthProvider;
import com.viegym.identity.User;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.identity.UserRepository;
import java.time.Clock;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class FacebookLoginServiceTests {

    private FacebookIdentityVerifier verifier;
    private UserRepository users;
    private UserProfileRepository profiles;
    private SessionIssuer sessions;
    private Clock clock;
    private FacebookLoginService service;

    @BeforeEach
    void setUp() {
        verifier = mock(FacebookIdentityVerifier.class);
        users = mock(UserRepository.class);
        profiles = mock(UserProfileRepository.class);
        sessions = mock(SessionIssuer.class);
        clock = Clock.fixed(Instant.parse("2026-08-31T10:00:00Z"), ZoneOffset.UTC);
        service = new FacebookLoginService(verifier, users, profiles, sessions, clock);
    }

    @Test
    @DisplayName(
            "Successfully creates new user and profile when Facebook user logs in for the first time")
    void loginCreatesNewUser() {
        String token = "valid-fb-token";
        FacebookIdentity identity =
                new FacebookIdentity("fb-123456", "athlete@viegym.vn", "Nguyen Van A");
        when(verifier.verify(token)).thenReturn(identity);
        when(users.findByAuthProviderAndProviderSubject(AuthProvider.FACEBOOK, "fb-123456"))
                .thenReturn(Optional.empty());
        when(users.findByEmail("athlete@viegym.vn")).thenReturn(Optional.empty());

        User createdUser =
                User.facebook("athlete@viegym.vn", "fb-123456", OffsetDateTime.now(clock));
        when(users.save(any(User.class))).thenReturn(createdUser);
        SessionResponse expectedSession =
                SessionResponse.session("jwt.access.token", "jwt.refresh.token", 3600L);
        when(sessions.issue(any(User.class), any())).thenReturn(expectedSession);

        SessionResponse response = service.login(new FacebookLoginRequest(token, "Pixel 8"));

        assertThat(response).isNotNull();
        assertThat(response.accessToken()).isEqualTo("jwt.access.token");
        verify(users).save(any(User.class));
        verify(profiles).save(any(UserProfile.class));
    }

    @Test
    @DisplayName("Logs in existing Facebook user without creating duplicate record")
    void loginExistingFacebookUser() {
        String token = "valid-fb-token";
        FacebookIdentity identity =
                new FacebookIdentity("fb-123456", "athlete@viegym.vn", "Nguyen Van A");
        when(verifier.verify(token)).thenReturn(identity);

        User existingUser =
                User.facebook("athlete@viegym.vn", "fb-123456", OffsetDateTime.now(clock));
        when(users.findByAuthProviderAndProviderSubject(AuthProvider.FACEBOOK, "fb-123456"))
                .thenReturn(Optional.of(existingUser));

        SessionResponse expectedSession =
                SessionResponse.session("jwt.access.token", "jwt.refresh.token", 3600L);
        when(sessions.issue(any(User.class), any())).thenReturn(expectedSession);

        SessionResponse response = service.login(new FacebookLoginRequest(token, "iPhone 15"));

        assertThat(response).isNotNull();
        verify(users, never()).save(any(User.class));
        verify(profiles, never()).save(any(UserProfile.class));
    }

    @Test
    @DisplayName("Rejects login when Facebook does not provide an email address")
    void loginRejectsMissingEmail() {
        String token = "fb-token-no-email";
        FacebookIdentity identity = new FacebookIdentity("fb-123456", null, "No Email User");
        when(verifier.verify(token)).thenReturn(identity);
        when(users.findByAuthProviderAndProviderSubject(AuthProvider.FACEBOOK, "fb-123456"))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.login(new FacebookLoginRequest(token, "Device")))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Facebook account must have an associated email");
    }

    @Test
    @DisplayName(
            "Rejects login and prevents auto-link when email already exists under a different auth provider")
    void loginRejectsAccountConflict() {
        String token = "fb-token";
        FacebookIdentity identity =
                new FacebookIdentity("fb-999999", "existing@viegym.vn", "Conflict User");
        when(verifier.verify(token)).thenReturn(identity);
        when(users.findByAuthProviderAndProviderSubject(AuthProvider.FACEBOOK, "fb-999999"))
                .thenReturn(Optional.empty());

        // Account with same email exists under LOCAL / GOOGLE
        User localUser = new User("existing@viegym.vn", "hash");
        when(users.findByEmail("existing@viegym.vn")).thenReturn(Optional.of(localUser));

        assertThatThrownBy(() -> service.login(new FacebookLoginRequest(token, "Device")))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("An account with this email already exists");

        verify(users, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Rejects login when user account is locked or disabled")
    void loginRejectsLockedAccount() {
        String token = "valid-fb-token";
        FacebookIdentity identity =
                new FacebookIdentity("fb-123456", "athlete@viegym.vn", "Nguyen Van A");
        when(verifier.verify(token)).thenReturn(identity);

        User lockedUser =
                User.facebook("athlete@viegym.vn", "fb-123456", OffsetDateTime.now(clock));
        lockedUser.lock();
        when(users.findByAuthProviderAndProviderSubject(AuthProvider.FACEBOOK, "fb-123456"))
                .thenReturn(Optional.of(lockedUser));

        assertThatThrownBy(() -> service.login(new FacebookLoginRequest(token, "Device")))
                .isInstanceOf(ApiException.class);
    }

    @Test
    @DisplayName("DefaultFacebookIdentityVerifier rejects blank or null tokens")
    void verifierRejectsBlankTokens() {
        DefaultFacebookIdentityVerifier verifier = new DefaultFacebookIdentityVerifier("123456");
        assertThatThrownBy(() -> verifier.verify(null))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Invalid Facebook credential");

        assertThatThrownBy(() -> verifier.verify("   "))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Invalid Facebook credential");
    }
}
