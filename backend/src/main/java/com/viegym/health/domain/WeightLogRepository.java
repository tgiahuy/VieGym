package com.viegym.health.domain;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WeightLogRepository extends JpaRepository<WeightLog, Long> {

    Optional<WeightLog> findByUserIdAndLoggedDate(Long userId, LocalDate loggedDate);

    Optional<WeightLog> findFirstByUserIdOrderByLoggedDateDescUpdatedAtDesc(Long userId);

    List<WeightLog> findByUserIdAndLoggedDateBetweenOrderByLoggedDateAsc(
            Long userId, LocalDate from, LocalDate to);

    Page<WeightLog> findByUserIdOrderByLoggedDateDescUpdatedAtDesc(Long userId, Pageable pageable);

    Page<WeightLog> findByUserIdAndLoggedDateBetweenOrderByLoggedDateDescUpdatedAtDesc(
            Long userId, LocalDate from, LocalDate to, Pageable pageable);

    Page<WeightLog> findByUserIdAndLoggedDateGreaterThanEqualOrderByLoggedDateDescUpdatedAtDesc(
            Long userId, LocalDate from, Pageable pageable);

    Page<WeightLog> findByUserIdAndLoggedDateLessThanEqualOrderByLoggedDateDescUpdatedAtDesc(
            Long userId, LocalDate to, Pageable pageable);
}
