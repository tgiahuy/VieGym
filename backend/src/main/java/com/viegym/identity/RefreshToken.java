package com.viegym.identity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;

@Entity
@Table(name = "refresh_tokens")
public class RefreshToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "token_hash", nullable = false, length = 255, unique = true)
    private String tokenHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TokenStatus status;

    @Column(name = "expires_at", nullable = false)
    private OffsetDateTime expiresAt;

    @Column(name = "revoked_at")
    private OffsetDateTime revokedAt;

    @Column(name = "replaced_by_token_id")
    private Long replacedByTokenId;

    @Column(name = "device_info", length = 255)
    private String deviceInfo;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    protected RefreshToken() {}

    public RefreshToken(
            User user,
            String tokenHash,
            String deviceInfo,
            OffsetDateTime expiresAt,
            OffsetDateTime createdAt) {
        this.user = user;
        this.tokenHash = tokenHash;
        this.status = TokenStatus.ACTIVE;
        this.deviceInfo = deviceInfo;
        this.expiresAt = expiresAt;
        this.createdAt = createdAt;
    }

    public Long id() {
        return id;
    }

    public User user() {
        return user;
    }

    public String tokenHash() {
        return tokenHash;
    }

    public TokenStatus status() {
        return status;
    }

    public OffsetDateTime expiresAt() {
        return expiresAt;
    }

    public Long replacedByTokenId() {
        return replacedByTokenId;
    }

    public void rotateTo(RefreshToken replacement, OffsetDateTime now) {
        this.status = TokenStatus.REVOKED;
        this.revokedAt = now;
        this.replacedByTokenId = replacement.id();
    }

    public void revoke(OffsetDateTime now) {
        if (this.status == TokenStatus.ACTIVE) {
            this.status = TokenStatus.REVOKED;
            this.revokedAt = now;
        }
    }

    public void expire() {
        if (this.status == TokenStatus.ACTIVE) {
            this.status = TokenStatus.EXPIRED;
        }
    }
}
