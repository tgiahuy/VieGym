package com.viegym.workout.planning.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.workout.planning.application.WorkoutSchedulePlanningService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/workout-schedule-proposals")
public class WorkoutSchedulePlanningController {

    private final WorkoutSchedulePlanningService service;

    public WorkoutSchedulePlanningController(WorkoutSchedulePlanningService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ScheduleProposalResponse>> create(
            @RequestBody CreateScheduleProposalRequest request, @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                service.createProposal(Long.valueOf(jwt.getSubject()), request)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ScheduleProposalResponse>> get(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(service.getProposal(Long.valueOf(jwt.getSubject()), id)));
    }

    @PostMapping("/{id}/apply")
    public ResponseEntity<ApiResponse<ApplyScheduleProposalResponse>> apply(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(service.apply(Long.valueOf(jwt.getSubject()), id)));
    }
}
