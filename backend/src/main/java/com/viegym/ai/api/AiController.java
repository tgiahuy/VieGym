package com.viegym.ai.api;

import com.viegym.ai.application.AiCoachService;
import com.viegym.common.api.ApiResponse;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/ai")
public class AiController {
    private final AiCoachService service;

    public AiController(AiCoachService service) {
        this.service = service;
    }

    @GetMapping("/consent")
    ApiResponse<AiDtos.Consent> consent(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.getConsent(userId(jwt)));
    }

    @PutMapping("/consent")
    ApiResponse<AiDtos.Consent> updateConsent(
            @Valid @RequestBody AiDtos.UpdateConsent request, @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.updateConsent(userId(jwt), request));
    }

    @PostMapping("/conversations")
    ResponseEntity<ApiResponse<AiDtos.Conversation>> createConversation(
            @Valid @RequestBody AiDtos.CreateConversation request,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(service.createConversation(userId(jwt), request)));
    }

    @GetMapping("/conversations")
    ApiResponse<List<AiDtos.Conversation>> conversations(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.listConversations(userId(jwt)));
    }

    @GetMapping("/conversations/{id}")
    ApiResponse<AiDtos.Conversation> conversation(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.getConversation(userId(jwt), id));
    }

    @PostMapping("/conversations/{id}/messages")
    ApiResponse<AiDtos.MessageExchange> send(
            @PathVariable Long id,
            @Valid @RequestBody AiDtos.SendMessage request,
            @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.sendMessage(userId(jwt), id, request));
    }

    @GetMapping("/recommendations/daily")
    ApiResponse<AiDtos.DailyRecommendations> daily(
            @RequestParam(required = false) LocalDate date, @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.getDaily(userId(jwt), date));
    }

    @PostMapping("/recommendations/daily/generations")
    ResponseEntity<ApiResponse<AiDtos.DailyRecommendations>> generate(
            @RequestHeader("Idempotency-Key") String idempotencyKey,
            @RequestBody(required = false) AiDtos.GenerateDaily request,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                service.generateDaily(userId(jwt), request, idempotencyKey)));
    }

    @PostMapping("/recommendations/{id}/apply")
    ApiResponse<AiDtos.RecommendationAction> apply(
            @PathVariable Long id,
            @RequestHeader("Idempotency-Key") String idempotencyKey,
            @Valid @RequestBody AiDtos.ApplyRecommendation request,
            @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.apply(userId(jwt), id, request, idempotencyKey));
    }

    @PostMapping("/recommendations/{id}/dismiss")
    ApiResponse<AiDtos.RecommendationAction> dismiss(
            @PathVariable Long id,
            @RequestHeader("Idempotency-Key") String idempotencyKey,
            @Valid @RequestBody AiDtos.DismissRecommendation request,
            @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.dismiss(userId(jwt), id, request, idempotencyKey));
    }

    private static Long userId(Jwt jwt) {
        return Long.valueOf(jwt.getSubject());
    }
}
