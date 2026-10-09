package com.viegym.nutrition.api;

import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import com.viegym.nutrition.application.NutritionService;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class NutritionController {
    private final NutritionService service;

    public NutritionController(NutritionService service) {
        this.service = service;
    }

    @GetMapping("/foods")
    public ResponseEntity<ApiResponse<PageResponse<NutritionDtos.Food>>> foods(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "name,asc") String sort) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        service.searchFoods(
                                q,
                                category,
                                PageRequest.of(
                                        Math.max(0, page),
                                        Math.min(Math.max(1, size), 100),
                                        parseSort(sort)))));
    }

    @GetMapping("/foods/{id}")
    public ResponseEntity<ApiResponse<NutritionDtos.Food>> food(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(service.getFood(id)));
    }

    @GetMapping("/favorite-foods")
    public ResponseEntity<ApiResponse<PageResponse<NutritionDtos.Food>>> favorites(
            @RequestParam(required = false) String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        service.listFavorites(
                                userId(jwt),
                                q,
                                PageRequest.of(
                                        Math.max(0, page), Math.min(Math.max(1, size), 100)))));
    }

    @PutMapping("/favorite-foods/{foodId}")
    public ResponseEntity<ApiResponse<Void>> addFavorite(
            @PathVariable Long foodId, @AuthenticationPrincipal Jwt jwt) {
        service.addFavorite(userId(jwt), foodId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @DeleteMapping("/favorite-foods/{foodId}")
    public ResponseEntity<ApiResponse<Void>> removeFavorite(
            @PathVariable Long foodId, @AuthenticationPrincipal Jwt jwt) {
        service.removeFavorite(userId(jwt), foodId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/meal-plans")
    public ResponseEntity<ApiResponse<NutritionDtos.MealPlan>> mealPlan(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(ApiResponse.success(service.getMealPlan(userId(jwt), date)));
    }

    @GetMapping("/meal-plans/history")
    public ResponseEntity<ApiResponse<PageResponse<NutritionDtos.MealPlan>>> mealHistory(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "30") int size,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        service.listMealHistory(
                                userId(jwt),
                                PageRequest.of(
                                        Math.max(0, page), Math.min(Math.max(1, size), 100)))));
    }

    @PostMapping("/meal-plans/{planDate}/entries")
    public ResponseEntity<ApiResponse<NutritionDtos.MealPlan>> addEntry(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate planDate,
            @Valid @RequestBody MealEntryRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(service.addEntry(userId(jwt), planDate, request)));
    }

    @PutMapping("/meal-plans/{planDate}/entries/{entryId}")
    public ResponseEntity<ApiResponse<NutritionDtos.MealPlan>> updateEntry(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate planDate,
            @PathVariable Long entryId,
            @Valid @RequestBody MealEntryRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(service.updateEntry(userId(jwt), planDate, entryId, request)));
    }

    @DeleteMapping("/meal-plans/{planDate}/entries/{entryId}")
    public ResponseEntity<Void> deleteEntry(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate planDate,
            @PathVariable Long entryId,
            @AuthenticationPrincipal Jwt jwt) {
        service.deleteEntry(userId(jwt), planDate, entryId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/meal-templates")
    public ResponseEntity<ApiResponse<List<NutritionDtos.MealTemplate>>> templates(
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(ApiResponse.success(service.listTemplates(userId(jwt))));
    }

    @PostMapping("/meal-templates")
    public ResponseEntity<ApiResponse<NutritionDtos.MealTemplate>> createTemplate(
            @Valid @RequestBody CreateMealTemplateRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(service.createTemplate(userId(jwt), request)));
    }

    @GetMapping("/meal-templates/{id}")
    public ResponseEntity<ApiResponse<NutritionDtos.MealTemplate>> template(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(ApiResponse.success(service.getTemplate(userId(jwt), id)));
    }

    @PutMapping("/meal-templates/{id}")
    public ResponseEntity<ApiResponse<NutritionDtos.MealTemplate>> updateTemplate(
            @PathVariable Long id,
            @Valid @RequestBody CreateMealTemplateRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(service.updateTemplate(userId(jwt), id, request)));
    }

    @DeleteMapping("/meal-templates/{id}")
    public ResponseEntity<Void> deleteTemplate(
            @PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        service.deleteTemplate(userId(jwt), id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/meal-templates/{id}/apply")
    public ResponseEntity<ApiResponse<NutritionDtos.ApplyTemplateResult>> applyTemplate(
            @PathVariable Long id,
            @Valid @RequestBody ApplyMealTemplateRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(
                ApiResponse.success(service.applyTemplate(userId(jwt), id, request)));
    }

    private static Long userId(Jwt jwt) {
        return jwt == null ? null : Long.valueOf(jwt.getSubject());
    }

    private static Sort parseSort(String value) {
        String[] parts = value == null ? new String[0] : value.split(",");
        String field = parts.length == 0 || parts[0].isBlank() ? "name" : parts[0].trim();
        Sort.Direction direction =
                parts.length > 1 && "desc".equalsIgnoreCase(parts[1].trim())
                        ? Sort.Direction.DESC
                        : Sort.Direction.ASC;
        return Sort.by(direction, field);
    }
}
