package com.viegym.health.domain;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HealthProfileRepository extends JpaRepository<HealthProfile, Long> {
    boolean existsByUserId(Long userId);

    Optional<HealthProfile> findByUserId(Long userId);
}
