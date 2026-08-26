package com.viegym.profile.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.profile.application.UserProfileService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/me")
public class UserProfileController {

    private final UserProfileService userProfileService;

    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    @GetMapping
    ResponseEntity<ApiResponse<UserResponse>> get(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(ApiResponse.success(userProfileService.get(subject(jwt))));
    }

    @PutMapping
    ResponseEntity<ApiResponse<UserResponse>> update(
            @Valid @RequestBody UpdateUserRequest request, @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(userProfileService.update(subject(jwt), request)));
    }

    private static Long subject(Jwt jwt) {
        return Long.valueOf(jwt.getSubject());
    }
}
