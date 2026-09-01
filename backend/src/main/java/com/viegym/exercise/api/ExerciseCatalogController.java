package com.viegym.exercise.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import com.viegym.exercise.application.ExerciseCatalogService;
import java.util.List;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class ExerciseCatalogController {

    private final ExerciseCatalogService service;

    public ExerciseCatalogController(ExerciseCatalogService service) {
        this.service = service;
    }

    @GetMapping("/muscle-groups")
    public ResponseEntity<ApiResponse<List<MuscleGroupDto>>> listMuscleGroups() {
        return ResponseEntity.ok(ApiResponse.success(service.listMuscleGroups()));
    }

    @GetMapping("/equipment")
    public ResponseEntity<ApiResponse<List<EquipmentDto>>> listEquipment() {
        return ResponseEntity.ok(ApiResponse.success(service.listEquipment()));
    }

    @GetMapping("/exercises")
    public ResponseEntity<ApiResponse<PageResponse<ExerciseSummaryDto>>> searchExercises(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) Long muscleGroupId,
            @RequestParam(required = false) Long equipmentId,
            @RequestParam(required = false) String difficulty,
            @RequestParam(required = false) Boolean compatibleWithMyEquipment,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "name,asc") String sort,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = jwt != null ? Long.valueOf(jwt.getSubject()) : null;
        int safePage = Math.max(0, page);
        int safeSize = Math.min(Math.max(1, size), 200);

        Sort sorting = parseSort(sort);
        PageRequest pageRequest = PageRequest.of(safePage, safeSize, sorting);

        PageResponse<ExerciseSummaryDto> response =
                service.searchExercises(
                        userId,
                        q,
                        muscleGroupId,
                        equipmentId,
                        difficulty,
                        compatibleWithMyEquipment,
                        pageRequest);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/exercises/{id}")
    public ResponseEntity<ApiResponse<ExerciseDetailDto>> getExerciseDetail(@PathVariable Long id) {
        ExerciseDetailDto detail = service.getExerciseDetail(id);
        return ResponseEntity.ok(ApiResponse.success(detail));
    }

    @GetMapping("/exercises/{id}/alternatives")
    public ResponseEntity<ApiResponse<List<ExerciseSummaryDto>>> getExerciseAlternatives(
            @PathVariable Long id,
            @RequestParam(defaultValue = "5") int limit,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = jwt != null ? Long.valueOf(jwt.getSubject()) : null;
        List<ExerciseSummaryDto> alternatives = service.getExerciseAlternatives(userId, id, limit);
        return ResponseEntity.ok(ApiResponse.success(alternatives));
    }

    @GetMapping("/favorite-exercises")
    public ResponseEntity<ApiResponse<PageResponse<ExerciseSummaryDto>>> listFavoriteExercises(
            @RequestParam(required = false) String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = jwt != null ? Long.valueOf(jwt.getSubject()) : null;
        int safePage = Math.max(0, page);
        int safeSize = Math.min(Math.max(1, size), 100);
        PageRequest pageRequest = PageRequest.of(safePage, safeSize);

        PageResponse<ExerciseSummaryDto> response = service.listFavorites(userId, q, pageRequest);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/favorite-exercises/{exerciseId}")
    public ResponseEntity<ApiResponse<Void>> addFavorite(
            @PathVariable Long exerciseId, @AuthenticationPrincipal Jwt jwt) {
        Long userId = jwt != null ? Long.valueOf(jwt.getSubject()) : null;
        service.addFavorite(userId, exerciseId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @DeleteMapping("/favorite-exercises/{exerciseId}")
    public ResponseEntity<ApiResponse<Void>> removeFavorite(
            @PathVariable Long exerciseId, @AuthenticationPrincipal Jwt jwt) {
        Long userId = jwt != null ? Long.valueOf(jwt.getSubject()) : null;
        service.removeFavorite(userId, exerciseId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    private Sort parseSort(String sortParam) {
        if (sortParam == null || sortParam.isBlank()) {
            return Sort.by(Sort.Direction.ASC, "name");
        }
        String[] parts = sortParam.split(",");
        String property = parts[0].trim();
        Sort.Direction direction =
                parts.length > 1 && parts[1].trim().equalsIgnoreCase("desc")
                        ? Sort.Direction.DESC
                        : Sort.Direction.ASC;
        return Sort.by(direction, property);
    }
}
