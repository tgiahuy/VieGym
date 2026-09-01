package com.viegym.health.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import com.viegym.health.application.WeightLogService;
import jakarta.validation.Valid;
import java.time.LocalDate;
import org.springframework.data.domain.PageRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/weight-logs")
public class WeightLogController {

    private final WeightLogService weightLogs;

    public WeightLogController(WeightLogService weightLogs) {
        this.weightLogs = weightLogs;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<WeightLogDto>>> list(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
                    LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
                    LocalDate to,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        int safePage = Math.max(0, page);
        int safeSize = Math.min(Math.max(1, size), 100);
        PageRequest pageRequest = PageRequest.of(safePage, safeSize);
        return ResponseEntity.ok(
                ApiResponse.success(weightLogs.list(userId, from, to, pageRequest)));
    }

    @PutMapping("/{loggedDate}")
    public ResponseEntity<ApiResponse<UpsertWeightLogResponse>> upsert(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate loggedDate,
            @Valid @RequestBody UpsertWeightLogRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        UpsertResult<UpsertWeightLogResponse> result =
                weightLogs.upsert(userId, loggedDate, request);
        HttpStatus status = result.created() ? HttpStatus.CREATED : HttpStatus.OK;
        return ResponseEntity.status(status).body(ApiResponse.success(result.data()));
    }

    @GetMapping("/trend")
    public ResponseEntity<ApiResponse<WeightTrendResponse>> trend(
            @RequestParam(required = false, defaultValue = "30") Integer days,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.valueOf(jwt.getSubject());
        return ResponseEntity.ok(ApiResponse.success(weightLogs.getTrend(userId, days)));
    }
}
