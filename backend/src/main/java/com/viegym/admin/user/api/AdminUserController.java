package com.viegym.admin.user.api;

import com.viegym.admin.user.api.AdminUserDtos.InviteUserRequest;
import com.viegym.admin.user.api.AdminUserDtos.UpdateUserStatusRequest;
import com.viegym.admin.user.api.AdminUserDtos.UserSummary;
import com.viegym.admin.user.application.AdminUserService;
import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/users")
public class AdminUserController {

    private final AdminUserService userService;

    public AdminUserController(AdminUserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public ApiResponse<PageResponse<UserSummary>> list(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        return ApiResponse.success(
                userService.list(
                        q,
                        role,
                        status,
                        PageRequest.of(Math.max(0, page), Math.min(200, Math.max(1, size)))));
    }

    @GetMapping("/{id}")
    public ApiResponse<UserSummary> get(@PathVariable long id) {
        return ApiResponse.success(userService.get(id));
    }

    @PatchMapping("/{id}/status")
    public ApiResponse<UserSummary> updateStatus(
            @PathVariable long id,
            @RequestBody UpdateUserStatusRequest req,
            @AuthenticationPrincipal Jwt jwt) {
        long adminId = Long.parseLong(jwt.getSubject());
        return ApiResponse.success(
                userService.updateStatus(adminId, id, req.status(), req.reason()));
    }

    @PostMapping("/invite")
    public ApiResponse<UserSummary> invite(
            @RequestBody InviteUserRequest req, @AuthenticationPrincipal Jwt jwt) {
        long adminId = Long.parseLong(jwt.getSubject());
        return ApiResponse.success(userService.invite(adminId, req));
    }
}
