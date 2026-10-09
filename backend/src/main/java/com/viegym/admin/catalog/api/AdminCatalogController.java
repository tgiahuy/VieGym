package com.viegym.admin.catalog.api;

import com.viegym.admin.catalog.api.AdminCatalogDtos.Exercise;
import com.viegym.admin.catalog.api.AdminCatalogDtos.ExerciseRequest;
import com.viegym.admin.catalog.api.AdminCatalogDtos.Food;
import com.viegym.admin.catalog.api.AdminCatalogDtos.FoodRequest;
import com.viegym.admin.catalog.api.AdminCatalogDtos.VisibilityRequest;
import com.viegym.admin.catalog.application.AdminCatalogService;
import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin")
public class AdminCatalogController {
    private final AdminCatalogService service;

    public AdminCatalogController(AdminCatalogService service) {
        this.service = service;
    }

    @GetMapping("/exercises")
    ApiResponse<PageResponse<Exercise>> exercises(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String difficulty,
            @RequestParam(required = false) String visibility,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(
                service.listExercises(q, difficulty, visibility, page(page, size)));
    }

    @GetMapping("/exercises/{id}")
    ApiResponse<Exercise> exercise(@PathVariable long id) {
        return ApiResponse.success(service.getExercise(id));
    }

    @PostMapping("/exercises")
    ApiResponse<Exercise> createExercise(
            @RequestBody ExerciseRequest request, @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.createExercise(id(jwt), request));
    }

    @PutMapping("/exercises/{id}")
    ApiResponse<Exercise> updateExercise(
            @PathVariable long id,
            @RequestBody ExerciseRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.updateExercise(id(jwt), id, request));
    }

    @PatchMapping("/exercises/{id}/visibility")
    ApiResponse<Exercise> exerciseVisibility(
            @PathVariable long id,
            @RequestBody VisibilityRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(
                service.setExerciseVisibility(
                        id(jwt), id, request.visibility(), request.version()));
    }

    @DeleteMapping("/exercises/{id}")
    ApiResponse<Void> deleteExercise(@PathVariable long id, @AuthenticationPrincipal Jwt jwt) {
        service.deleteExercise(id(jwt), id);
        return ApiResponse.success(null);
    }

    @GetMapping("/foods")
    ApiResponse<PageResponse<Food>> foods(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String visibility,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(service.listFoods(q, category, visibility, page(page, size)));
    }

    @GetMapping("/foods/{id}")
    ApiResponse<Food> food(@PathVariable long id) {
        return ApiResponse.success(service.getFood(id));
    }

    @PostMapping("/foods")
    ApiResponse<Food> createFood(
            @RequestBody FoodRequest request, @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.createFood(id(jwt), request));
    }

    @PutMapping("/foods/{id}")
    ApiResponse<Food> updateFood(
            @PathVariable long id,
            @RequestBody FoodRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.updateFood(id(jwt), id, request));
    }

    @PatchMapping("/foods/{id}/visibility")
    ApiResponse<Food> foodVisibility(
            @PathVariable long id,
            @RequestBody VisibilityRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(
                service.setFoodVisibility(id(jwt), id, request.visibility(), request.version()));
    }

    @DeleteMapping("/foods/{id}")
    ApiResponse<Void> deleteFood(@PathVariable long id, @AuthenticationPrincipal Jwt jwt) {
        service.deleteFood(id(jwt), id);
        return ApiResponse.success(null);
    }

    private static long id(Jwt jwt) {
        return Long.parseLong(jwt.getSubject());
    }

    private static PageRequest page(int page, int size) {
        return PageRequest.of(Math.max(0, page), Math.min(500, Math.max(1, size)));
    }
}
