package com.viegym.identity;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

public interface UserOnboardingRepository extends Repository<User, Long> {

    @Query(
            value = "select exists(select 1 from health_profiles where user_id = :userId)",
            nativeQuery = true)
    boolean healthProfileCompleted(@Param("userId") Long userId);

    @Query(
            value =
                    "select exists(select 1 from user_preferences where user_id = :userId "
                            + "and equipment_onboarding_completed_at is not null)",
            nativeQuery = true)
    boolean equipmentCompleted(@Param("userId") Long userId);
}
