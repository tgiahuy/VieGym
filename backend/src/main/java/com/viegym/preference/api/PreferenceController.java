package com.viegym.preference.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.preference.application.PreferenceService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/preferences")
public class PreferenceController {

    private final PreferenceService preferences;

    public PreferenceController(PreferenceService preferences) {
        this.preferences = preferences;
    }

    @GetMapping
    ResponseEntity<ApiResponse<PreferenceResponse>> get(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(ApiResponse.success(preferences.get(subject(jwt))));
    }

    @PutMapping
    ResponseEntity<ApiResponse<PreferenceResponse>> put(
            @RequestBody PreferenceRequest request, @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(ApiResponse.success(preferences.replace(subject(jwt), request)));
    }

    @GetMapping("/equipment")
    ResponseEntity<ApiResponse<EquipmentPreferenceResponse>> getEquipment(
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(ApiResponse.success(preferences.getEquipment(subject(jwt))));
    }

    @PutMapping("/equipment")
    ResponseEntity<ApiResponse<EquipmentPreferenceResponse>> putEquipment(
            @RequestBody EquipmentPreferenceRequest request, @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(preferences.replaceEquipment(subject(jwt), request)));
    }

    private static Long subject(Jwt jwt) {
        return Long.valueOf(jwt.getSubject());
    }
}
