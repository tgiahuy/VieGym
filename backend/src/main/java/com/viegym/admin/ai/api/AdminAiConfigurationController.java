package com.viegym.admin.ai.api;

import com.viegym.admin.ai.api.AdminAiDtos.AiMetrics;
import com.viegym.admin.ai.api.AdminAiDtos.CreatePromptRequest;
import com.viegym.admin.ai.api.AdminAiDtos.PromptTemplate;
import com.viegym.admin.ai.api.AdminAiDtos.PublishRequest;
import com.viegym.admin.ai.api.AdminAiDtos.SafetyRule;
import com.viegym.admin.ai.api.AdminAiDtos.SaveDraftRequest;
import com.viegym.admin.ai.api.AdminAiDtos.UpdateSafetyRuleRequest;
import com.viegym.admin.ai.application.AdminAiConfigurationService;
import com.viegym.common.api.ApiResponse;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/ai-config")
public class AdminAiConfigurationController {
    private final AdminAiConfigurationService service;

    public AdminAiConfigurationController(AdminAiConfigurationService service) {
        this.service = service;
    }

    @GetMapping("/prompts")
    public ApiResponse<List<PromptTemplate>> prompts() {
        return ApiResponse.success(service.prompts());
    }

    @PostMapping("/prompts")
    public ApiResponse<PromptTemplate> create(
            @AuthenticationPrincipal Jwt jwt, @RequestBody CreatePromptRequest request) {
        return ApiResponse.success(service.create(adminId(jwt), request));
    }

    @PutMapping("/prompts/{id}/draft")
    public ApiResponse<PromptTemplate> saveDraft(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long id,
            @RequestBody SaveDraftRequest request) {
        return ApiResponse.success(
                service.saveDraft(adminId(jwt), id, request.content(), request.expectedRevision()));
    }

    @PostMapping("/prompts/{id}/publish")
    @PreAuthorize("hasRole('ADMIN') and hasAuthority('AUD_ADMIN_WEB')")
    public ApiResponse<PromptTemplate> publish(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long id,
            @RequestBody PublishRequest request) {
        return ApiResponse.success(service.publish(adminId(jwt), id, request.expectedRevision()));
    }

    @GetMapping("/safety-rules")
    public ApiResponse<List<SafetyRule>> safetyRules() {
        return ApiResponse.success(service.safetyRules());
    }

    @PatchMapping("/safety-rules/{id}")
    @PreAuthorize("hasRole('ADMIN') and hasAuthority('AUD_ADMIN_WEB')")
    public ApiResponse<SafetyRule> updateSafetyRule(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long id,
            @RequestBody UpdateSafetyRuleRequest request) {
        return ApiResponse.success(
                service.updateSafetyRule(
                        adminId(jwt), id, request.active(), request.expectedVersion()));
    }

    @GetMapping("/metrics")
    public ApiResponse<AiMetrics> metrics() {
        return ApiResponse.success(service.metrics());
    }

    private static long adminId(Jwt jwt) {
        return Long.parseLong(jwt.getSubject());
    }
}
