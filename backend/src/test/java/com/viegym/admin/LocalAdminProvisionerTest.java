package com.viegym.admin;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.viegym.admin.auth.application.LocalAdminProvisioner;
import com.viegym.identity.User;
import com.viegym.identity.UserRepository;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.DefaultApplicationArguments;
import org.springframework.security.crypto.password.PasswordEncoder;

class LocalAdminProvisionerTest {

    private UserRepository users;
    private PasswordEncoder passwordEncoder;
    private Clock clock;

    @BeforeEach
    void setUp() {
        users = mock(UserRepository.class);
        passwordEncoder = mock(PasswordEncoder.class);
        clock = Clock.fixed(Instant.parse("2026-10-03T10:00:00Z"), ZoneOffset.UTC);
    }

    @Test
    void provisionsNewAdminWhenNotPresent() {
        when(users.findByEmail("admin@viegym.test")).thenReturn(Optional.empty());
        when(passwordEncoder.encode("StrongAdminPassword123!")).thenReturn("hashed_pass");

        LocalAdminProvisioner provisioner =
                new LocalAdminProvisioner(
                        users,
                        passwordEncoder,
                        clock,
                        "admin@viegym.test",
                        "StrongAdminPassword123!");

        provisioner.run(new DefaultApplicationArguments(new String[0]));

        verify(users).save(any(User.class));
    }

    @Test
    void rejectsExistingUserWithNonAdminRole() {
        User regular = new User("admin@viegym.test", "hash");
        when(users.findByEmail("admin@viegym.test")).thenReturn(Optional.of(regular));

        LocalAdminProvisioner provisioner =
                new LocalAdminProvisioner(
                        users,
                        passwordEncoder,
                        clock,
                        "admin@viegym.test",
                        "StrongAdminPassword123!");

        assertThatThrownBy(() -> provisioner.run(new DefaultApplicationArguments(new String[0])))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("non-active-admin account");
    }

    @Test
    void rejectsShortPassword() {
        LocalAdminProvisioner provisioner =
                new LocalAdminProvisioner(
                        users, passwordEncoder, clock, "admin@viegym.test", "short");

        assertThatThrownBy(() -> provisioner.run(new DefaultApplicationArguments(new String[0])))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("at least 12 characters");
    }
}
