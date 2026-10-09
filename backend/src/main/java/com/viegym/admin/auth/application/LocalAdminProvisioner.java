package com.viegym.admin.auth.application;

import com.viegym.identity.AccountStatus;
import com.viegym.identity.AuthProvider;
import com.viegym.identity.User;
import com.viegym.identity.UserRepository;
import com.viegym.identity.UserRole;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.Locale;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@Profile("local")
@ConditionalOnProperty(name = "admin.bootstrap.enabled", havingValue = "true")
public class LocalAdminProvisioner implements ApplicationRunner {

    private final UserRepository users;
    private final PasswordEncoder passwordEncoder;
    private final Clock clock;
    private final String email;
    private final String password;

    public LocalAdminProvisioner(
            UserRepository users,
            PasswordEncoder passwordEncoder,
            Clock clock,
            @Value("${admin.bootstrap.email:}") String email,
            @Value("${admin.bootstrap.password:}") String password) {
        this.users = users;
        this.passwordEncoder = passwordEncoder;
        this.clock = clock;
        this.email = email == null ? "" : email.trim().toLowerCase(Locale.ROOT);
        this.password = password == null ? "" : password;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (email.isBlank() || password.length() < 12) {
            throw new IllegalStateException(
                    "Local admin bootstrap requires an email and a password of at least 12 characters");
        }

        users.findByEmail(email)
                .ifPresentOrElse(
                        this::verifyExistingAdmin,
                        () ->
                                users.save(
                                        User.localAdmin(
                                                email,
                                                passwordEncoder.encode(password),
                                                OffsetDateTime.now(clock))));
    }

    private void verifyExistingAdmin(User user) {
        if (user.authProvider() != AuthProvider.LOCAL
                || user.role() != UserRole.ADMIN
                || user.status() != AccountStatus.ACTIVE) {
            throw new IllegalStateException(
                    "Admin bootstrap email already belongs to a non-active-admin account");
        }
    }
}
