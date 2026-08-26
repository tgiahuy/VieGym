package com.viegym.identity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;

@Entity
@Table(name = "password_reset_proofs")
public class PasswordResetProof {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "proof_hash", nullable = false, length = 128, unique = true)
    private String proofHash;

    @Column(name = "expires_at", nullable = false)
    private OffsetDateTime expiresAt;

    @Column(name = "consumed_at")
    private OffsetDateTime consumedAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    protected PasswordResetProof() {}

    public PasswordResetProof(
            User user, String proofHash, OffsetDateTime expiresAt, OffsetDateTime createdAt) {
        this.user = user;
        this.proofHash = proofHash;
        this.expiresAt = expiresAt;
        this.createdAt = createdAt;
    }

    public User user() {
        return user;
    }

    public OffsetDateTime expiresAt() {
        return expiresAt;
    }

    public OffsetDateTime consumedAt() {
        return consumedAt;
    }

    public void consume(OffsetDateTime now) {
        this.consumedAt = now;
    }
}
