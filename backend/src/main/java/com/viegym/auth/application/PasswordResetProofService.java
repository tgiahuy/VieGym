package com.viegym.auth.application;

import com.viegym.identity.PasswordResetProof;
import com.viegym.identity.PasswordResetProofRepository;
import com.viegym.identity.User;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.Base64;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class PasswordResetProofService {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private final PasswordResetProofRepository proofs;
    private final Clock clock;
    private final Duration ttl;

    public PasswordResetProofService(
            PasswordResetProofRepository proofs,
            Clock clock,
            @Value("${PASSWORD_RESET_PROOF_TTL:PT10M}") Duration ttl) {
        this.proofs = proofs;
        this.clock = clock;
        this.ttl = ttl;
    }

    public String issue(User user) {
        byte[] bytes = new byte[32];
        SECURE_RANDOM.nextBytes(bytes);
        String plain = "rp_once_" + Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        OffsetDateTime now = OffsetDateTime.now(clock);
        proofs.save(
                new PasswordResetProof(user, OtpIssueHelper.sha256Hex(plain), now.plus(ttl), now));
        return plain;
    }
}
