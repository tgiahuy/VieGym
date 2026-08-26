package com.viegym.identity;

import java.time.OffsetDateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SecurityRateLimitEventRepository
        extends JpaRepository<SecurityRateLimitEvent, Long> {

    /**
     * Counts events for a given {@code scope} and hashed subject that occurred at or after {@code
     * since}, used to enforce sliding-window rate limits.
     */
    @Query(
            "SELECT COUNT(e) FROM SecurityRateLimitEvent e"
                    + " WHERE e.scope = :scope"
                    + " AND e.subjectKeyHash = :subjectKeyHash"
                    + " AND e.createdAt >= :since")
    long countByScopeAndSubjectKeyHashSince(
            @Param("scope") String scope,
            @Param("subjectKeyHash") String subjectKeyHash,
            @Param("since") OffsetDateTime since);
}
