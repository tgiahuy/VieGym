package com.viegym.workout.program.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import com.viegym.workout.program.application.WorkoutProgramService;
import org.springframework.data.domain.PageRequest;
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
@RequestMapping("/api/v1/workout-programs")
public class WorkoutProgramController {

    private final WorkoutProgramService service;

    public WorkoutProgramController(WorkoutProgramService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<WorkoutProgramSummaryResponse>>> listPrograms(
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        int safePage = Math.max(0, page);
        int safeSize = Math.min(Math.max(1, size), 100);
        PageResponse<WorkoutProgramSummaryResponse> response =
                service.listPrograms(userId, status, PageRequest.of(safePage, safeSize));
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<WorkoutProgramResponse>> createProgram(
            @RequestBody WorkoutProgramRequest request, @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        WorkoutProgramResponse response = service.createProgram(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<WorkoutProgramResponse>> getProgram(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        WorkoutProgramResponse response = service.getProgram(userId, id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<WorkoutProgramResponse>> updateProgram(
            @PathVariable Long id,
            @RequestBody WorkoutProgramRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        WorkoutProgramResponse response = service.updateProgram(userId, id, request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> archiveProgram(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        service.archiveProgram(userId, id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
