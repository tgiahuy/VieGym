package com.viegym.workout.log.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import com.viegym.workout.log.application.WorkoutHistoryService;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/personal-records")
public class PersonalRecordController {

    private final WorkoutHistoryService service;

    public PersonalRecordController(WorkoutHistoryService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<PersonalRecordDto>>> listPersonalRecords(
            @RequestParam(required = false) Long exerciseId,
            @RequestParam(required = false) String type,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        int safePage = Math.max(0, page);
        int safeSize = Math.min(Math.max(1, size), 100);
        PageResponse<PersonalRecordDto> response =
                service.listPersonalRecords(
                        userId, exerciseId, type, PageRequest.of(safePage, safeSize));
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
