package com.viegym.workout.session.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.workout.session.application.WorkoutSessionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/workout-sessions")
public class WorkoutSessionController {

    private final WorkoutSessionService service;

    public WorkoutSessionController(WorkoutSessionService service) {
        this.service = service;
    }

    @PostMapping("/{scheduleId}/start")
    public ResponseEntity<ApiResponse<StartSessionResponse>> startSession(
            @PathVariable Long scheduleId, @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        StartSessionResponse response = service.startSession(userId, scheduleId);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
    }

    @PostMapping("/{id}/pause")
    public ResponseEntity<ApiResponse<PauseSessionResponse>> pauseSession(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        PauseSessionResponse response = service.pauseSession(userId, id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/{id}/resume")
    public ResponseEntity<ApiResponse<ResumeSessionResponse>> resumeSession(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        ResumeSessionResponse response = service.resumeSession(userId, id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/{id}/finish")
    public ResponseEntity<ApiResponse<FinishSessionResponse>> finishSession(
            @PathVariable Long id,
            @RequestBody FinishSessionRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        FinishSessionResponse response = service.finishSession(userId, id, request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/{id}/discard")
    public ResponseEntity<ApiResponse<Void>> discardSession(
            @PathVariable Long id,
            @RequestBody(required = false) DiscardSessionRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        service.discardSession(userId, id, request != null ? request.reason() : null);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
