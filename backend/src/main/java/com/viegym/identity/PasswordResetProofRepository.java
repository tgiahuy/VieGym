package com.viegym.identity;

import jakarta.persistence.LockModeType;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PasswordResetProofRepository extends JpaRepository<PasswordResetProof, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT p FROM PasswordResetProof p JOIN FETCH p.user WHERE p.proofHash = :proofHash")
    Optional<PasswordResetProof> findByProofHashForUpdate(@Param("proofHash") String proofHash);
}
