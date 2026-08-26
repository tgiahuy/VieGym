package com.viegym.identity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;

/**
 * Records a security-sensitive event (OTP send, OTP verify, login) for rate-limit enforcement.
 *
 * <p>The {@code subject_key_hash} field stores a SHA-256 hex digest of the subject identifier (e.g.
 * email address) so that raw PII is never persisted in this table. {@code ip_address} (PostgreSQL
 * {@code INET}) is left unmapped; it can be populated by the DB or a future layer.
 */
@Entity
@Table(name = "security_rate_limit_events")
public class SecurityRateLimitEvent {

    /** Scope constants matching the DB {@code CHECK} constraint. */
    public static final String SCOPE_LOGIN = "LOGIN";

    public static final String SCOPE_OTP_SEND = "OTP_SEND";
    public static final String SCOPE_OTP_VERIFY = "OTP_VERIFY";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 30)
    private String scope;

    @Column(name = "subject_key_hash", nullable = false, length = 128)
    private String subjectKeyHash;

    @Column(nullable = false)
    private boolean succeeded;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    protected SecurityRateLimitEvent() {}

    public SecurityRateLimitEvent(
            String scope, String subjectKeyHash, boolean succeeded, OffsetDateTime createdAt) {
        this.scope = scope;
        this.subjectKeyHash = subjectKeyHash;
        this.succeeded = succeeded;
        this.createdAt = createdAt;
    }

    public Long id() {
        return id;
    }

    public String scope() {
        return scope;
    }

    public String subjectKeyHash() {
        return subjectKeyHash;
    }

    public boolean succeeded() {
        return succeeded;
    }

    public OffsetDateTime createdAt() {
        return createdAt;
    }
}
