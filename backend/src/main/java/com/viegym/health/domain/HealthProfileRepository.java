package com.viegym.health.domain;

import org.springframework.data.jpa.repository.JpaRepository;

public interface HealthProfileRepository extends JpaRepository<HealthProfile, Long> {
    boolean existsByUserId(Long userId);
}
