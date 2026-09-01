package com.viegym.health.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.health.application.HealthProfileService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/health/profile")
public class HealthProfileController {

    private final HealthProfileService healthProfiles;

    public HealthProfileController(HealthProfileService healthProfiles) {
        this.healthProfiles = healthProfiles;
    }

    @GetMapping
    ResponseEntity<ApiResponse<HealthProfileResponse>> get(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(healthProfiles.get(Long.valueOf(jwt.getSubject()))));
    }

    @PostMapping
    ResponseEntity<ApiResponse<HealthProfileResponse>> create(
            @Valid @RequestBody CreateHealthProfileRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                healthProfiles.create(Long.valueOf(jwt.getSubject()), request)));
    }

    @PutMapping
    ResponseEntity<ApiResponse<HealthProfileResponse>> update(
            @Valid @RequestBody UpdateHealthProfileRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        healthProfiles.update(Long.valueOf(jwt.getSubject()), request)));
    }
}
