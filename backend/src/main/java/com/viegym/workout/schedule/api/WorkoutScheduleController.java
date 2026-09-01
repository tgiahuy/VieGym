package com.viegym.workout.schedule.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import com.viegym.workout.schedule.application.WorkoutScheduleService;
import java.time.LocalDate;
import org.springframework.data.domain.PageRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/workout-schedules")
public class WorkoutScheduleController {

    private final WorkoutScheduleService service;

    public WorkoutScheduleController(WorkoutScheduleService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<WorkoutScheduleResponse>>> listSchedules(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
                    LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
                    LocalDate to,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        int safePage = Math.max(0, page);
        int safeSize = Math.min(Math.max(1, size), 100);
        PageResponse<WorkoutScheduleResponse> response =
                service.listSchedules(userId, from, to, status, PageRequest.of(safePage, safeSize));
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<WorkoutScheduleResponse>> createSchedule(
            @RequestBody WorkoutScheduleRequest request, @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        WorkoutScheduleResponse response = service.createSchedule(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<WorkoutScheduleResponse>> getSchedule(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        WorkoutScheduleResponse response = service.getSchedule(userId, id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<WorkoutScheduleResponse>> updateSchedule(
            @PathVariable Long id,
            @RequestBody WorkoutScheduleRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        WorkoutScheduleResponse response = service.updateSchedule(userId, id, request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> cancelSchedule(
            @PathVariable Long id,
            @RequestParam(required = false) String cancelReason,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        service.cancelSchedule(userId, id, cancelReason);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
