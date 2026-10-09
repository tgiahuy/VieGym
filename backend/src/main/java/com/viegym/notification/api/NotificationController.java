package com.viegym.notification.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import com.viegym.notification.application.NotificationService;
import com.viegym.notification.application.NotificationService.NotificationItem;
import com.viegym.notification.application.NotificationService.Preference;
import com.viegym.notification.application.NotificationService.PreferenceRequest;
import com.viegym.notification.application.NotificationService.ReadAllResult;
import org.springframework.data.domain.PageRequest;
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
@RequestMapping("/api/v1/notifications")
public class NotificationController {
    private final NotificationService service;

    public NotificationController(NotificationService service) {
        this.service = service;
    }

    @GetMapping
    ApiResponse<PageResponse<NotificationItem>> list(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String type,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(
                service.list(
                        id(jwt),
                        status,
                        type,
                        PageRequest.of(Math.max(0, page), Math.min(50, Math.max(1, size)))));
    }

    @GetMapping("/unread-count")
    ApiResponse<Long> count(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.unreadCount(id(jwt)));
    }

    @PostMapping("/{notificationId}/read")
    ApiResponse<NotificationItem> read(
            @PathVariable long notificationId, @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.read(id(jwt), notificationId));
    }

    @PostMapping("/read-all")
    ApiResponse<ReadAllResult> readAll(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.readAll(id(jwt)));
    }

    @DeleteMapping("/{notificationId}")
    ApiResponse<Void> delete(@PathVariable long notificationId, @AuthenticationPrincipal Jwt jwt) {
        service.delete(id(jwt), notificationId);
        return ApiResponse.success(null);
    }

    @GetMapping("/preferences")
    ApiResponse<Preference> preference(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.preference(id(jwt)));
    }

    @PutMapping("/preferences")
    ApiResponse<Preference> preference(
            @RequestBody PreferenceRequest request, @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.updatePreference(id(jwt), request));
    }

    private static long id(Jwt jwt) {
        return Long.parseLong(jwt.getSubject());
    }
}
