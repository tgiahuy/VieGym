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
@Table(name = "otp_codes")
public class OtpCode {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false, length = 255)
    private String destination;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private OtpPurpose purpose;

    @Column(name = "code_hash", nullable = false, length = 255)
    private String codeHash;

    @Column(name = "attempt_count", nullable = false)
    private short attemptCount;

    @Column(name = "max_attempts", nullable = false)
    private short maxAttempts;

    @Column(name = "expires_at", nullable = false)
    private OffsetDateTime expiresAt;

    @Column(name = "resend_available_at", nullable = false)
    private OffsetDateTime resendAvailableAt;

    @Column(name = "consumed_at")
    private OffsetDateTime consumedAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    protected OtpCode() {}

    public OtpCode(
            User user,
            String destination,
            OtpPurpose purpose,
            String codeHash,
            short maxAttempts,
            OffsetDateTime expiresAt,
            OffsetDateTime resendAvailableAt,
            OffsetDateTime createdAt) {
        this.user = user;
        this.destination = destination;
        this.purpose = purpose;
        this.codeHash = codeHash;
        this.attemptCount = 0;
        this.maxAttempts = maxAttempts;
        this.expiresAt = expiresAt;
        this.resendAvailableAt = resendAvailableAt;
        this.createdAt = createdAt;
    }

    public Long id() {
        return id;
    }

    public User user() {
        return user;
    }

    public String destination() {
        return destination;
    }

    public OtpPurpose purpose() {
        return purpose;
    }

    public String codeHash() {
        return codeHash;
    }

    public short attemptCount() {
        return attemptCount;
    }

    public short maxAttempts() {
        return maxAttempts;
    }

    public OffsetDateTime expiresAt() {
        return expiresAt;
    }

    public OffsetDateTime resendAvailableAt() {
        return resendAvailableAt;
    }

    public OffsetDateTime consumedAt() {
        return consumedAt;
    }

    public OffsetDateTime createdAt() {
        return createdAt;
    }

    // --- Mutation methods ---

    /** Increments the attempt counter by one. Changes are flushed when the transaction commits. */
    public void incrementAttemptCount() {
        this.attemptCount++;
    }

    /** Marks this OTP as consumed at {@code now}. */
    public void consume(OffsetDateTime now) {
        this.consumedAt = now;
    }
}
