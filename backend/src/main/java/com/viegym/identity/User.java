package com.viegym.identity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 255)
    private String email;

    @Column(name = "password_hash", length = 255)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "auth_provider", nullable = false, length = 20)
    private AuthProvider authProvider;

    @Column(name = "provider_subject", length = 255)
    private String providerSubject;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private UserRole role;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AccountStatus status;

    @Column(name = "email_verified_at")
    private OffsetDateTime emailVerifiedAt;

    @Column(name = "last_login_at")
    private OffsetDateTime lastLoginAt;

    @Column(name = "deleted_at")
    private OffsetDateTime deletedAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    protected User() {}

    public User(String email, String passwordHash) {
        this.email = email;
        this.passwordHash = passwordHash;
        this.authProvider = AuthProvider.LOCAL;
        this.role = UserRole.USER;
        this.status = AccountStatus.PENDING;
        this.createdAt = OffsetDateTime.now();
        this.updatedAt = this.createdAt;
    }

    public static User google(String email, String providerSubject, OffsetDateTime now) {
        User user = new User();
        user.email = email;
        user.authProvider = AuthProvider.GOOGLE;
        user.providerSubject = providerSubject;
        user.role = UserRole.USER;
        user.status = AccountStatus.ACTIVE;
        user.emailVerifiedAt = now;
        user.createdAt = now;
        user.updatedAt = now;
        return user;
    }

    public static User facebook(String email, String providerSubject, OffsetDateTime now) {
        User user = new User();
        user.email = email;
        user.authProvider = AuthProvider.FACEBOOK;
        user.providerSubject = providerSubject;
        user.role = UserRole.USER;
        user.status = AccountStatus.ACTIVE;
        user.emailVerifiedAt = now;
        user.createdAt = now;
        user.updatedAt = now;
        return user;
    }

    public Long id() {
        return id;
    }

    public String email() {
        return email;
    }

    public String passwordHash() {
        return passwordHash;
    }

    public AuthProvider authProvider() {
        return authProvider;
    }

    public UserRole role() {
        return role;
    }

    public AccountStatus status() {
        return status;
    }

    public OffsetDateTime emailVerifiedAt() {
        return emailVerifiedAt;
    }

    public String providerSubject() {
        return providerSubject;
    }

    public void recordLogin(OffsetDateTime now) {
        this.lastLoginAt = now;
        this.updatedAt = now;
    }

    public void changePassword(String passwordHash, OffsetDateTime now) {
        this.passwordHash = passwordHash;
        this.updatedAt = now;
    }

    /**
     * Activates this user: sets {@code email_verified_at}, changes status to {@code ACTIVE} and
     * updates {@code updated_at}. Call within an active transaction so JPA dirty-checks commit it.
     */
    public void activate(OffsetDateTime now) {
        this.emailVerifiedAt = now;
        this.status = AccountStatus.ACTIVE;
        this.updatedAt = now;
    }

    public void lock() {
        this.status = AccountStatus.LOCKED;
    }
}
