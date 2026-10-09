package com.viegym.workout.template.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.workout.template.application.WorkoutTemplateService;
import java.util.List;
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
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/workout-program-templates")
public class WorkoutTemplateController {

    private final WorkoutTemplateService service;

    public WorkoutTemplateController(WorkoutTemplateService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<WorkoutTemplateResponse>>> list() {
        return ResponseEntity.ok(ApiResponse.success(service.listPublished()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<WorkoutTemplateResponse>> get(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(service.getPublished(id)));
    }

    @RestController
    @RequestMapping("/api/v1/admin/workout-program-templates")
    static class AdminWorkoutTemplateController {

        private final WorkoutTemplateService service;

        AdminWorkoutTemplateController(WorkoutTemplateService service) {
            this.service = service;
        }

        @GetMapping
        ResponseEntity<ApiResponse<List<WorkoutTemplateResponse>>> list() {
            return ResponseEntity.ok(ApiResponse.success(service.listForAdmin()));
        }

        @PostMapping
        ResponseEntity<ApiResponse<WorkoutTemplateResponse>> create(
                @RequestBody WorkoutTemplateRequest request, @AuthenticationPrincipal Jwt jwt) {
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(
                            ApiResponse.success(
                                    service.create(Long.valueOf(jwt.getSubject()), request)));
        }

        @PutMapping("/{id}")
        ResponseEntity<ApiResponse<WorkoutTemplateResponse>> update(
                @PathVariable Long id, @RequestBody WorkoutTemplateRequest request) {
            return ResponseEntity.ok(ApiResponse.success(service.update(id, request)));
        }

        @DeleteMapping("/{id}")
        ResponseEntity<ApiResponse<Void>> archive(@PathVariable Long id) {
            service.archive(id);
            return ResponseEntity.ok(ApiResponse.success(null));
        }
    }
}
