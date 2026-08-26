package com.viegym.identity;

import jakarta.persistence.LockModeType;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface OtpCodeRepository extends JpaRepository<OtpCode, Long> {

    /**
     * Loads an {@link OtpCode} by ID and acquires a pessimistic write lock, preventing concurrent
     * verification attempts from racing on the same record.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT o FROM OtpCode o WHERE o.id = :id")
    Optional<OtpCode> findByIdForUpdate(@Param("id") Long id);
}
