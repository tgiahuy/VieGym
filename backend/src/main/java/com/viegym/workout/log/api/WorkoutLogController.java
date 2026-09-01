package com.viegym.workout.log.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import com.viegym.workout.log.application.WorkoutHistoryService;
import java.time.LocalDate;
import org.springframework.data.domain.PageRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/workout-logs")
public class WorkoutLogController {

    private final WorkoutHistoryService service;

    public WorkoutLogController(WorkoutHistoryService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<WorkoutLogSummaryDto>>> listWorkoutLogs(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
                    LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
                    LocalDate to,
            @RequestParam(required = false) Long exerciseId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        int safePage = Math.max(0, page);
        int safeSize = Math.min(Math.max(1, size), 100);
        PageResponse<WorkoutLogSummaryDto> response =
                service.listWorkoutLogs(
                        userId, from, to, exerciseId, PageRequest.of(safePage, safeSize));
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<WorkoutLogDetailDto>> getWorkoutLogDetail(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        WorkoutLogDetailDto detail = service.getWorkoutLogDetail(userId, id);
        return ResponseEntity.ok(ApiResponse.success(detail));
    }
}
