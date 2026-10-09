package com.viegym.admin.media.api;

import com.viegym.admin.media.application.AdminMediaService;
import com.viegym.admin.media.application.AdminMediaService.AccessUrl;
import com.viegym.admin.media.application.AdminMediaService.Content;
import com.viegym.admin.media.application.AdminMediaService.InitRequest;
import com.viegym.admin.media.application.AdminMediaService.Media;
import com.viegym.admin.media.application.AdminMediaService.UploadInit;
import com.viegym.common.api.ApiResponse;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AdminMediaController {
    private final AdminMediaService service;

    public AdminMediaController(AdminMediaService service) {
        this.service = service;
    }

    @PostMapping("/api/v1/admin/media/init-upload")
    ApiResponse<UploadInit> init(
            @RequestBody InitRequest request, @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.init(id(jwt), request));
    }

    @PutMapping(value = "/api/v1/media-upload/{id}", consumes = MediaType.ALL_VALUE)
    ResponseEntity<Void> upload(
            @PathVariable long id,
            @RequestParam String uploadToken,
            @RequestHeader(value = HttpHeaders.CONTENT_TYPE, required = false) String contentType,
            @RequestBody byte[] bytes) {
        service.receive(id, uploadToken, contentType, bytes);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/api/v1/admin/media/{id}/complete")
    ApiResponse<Media> complete(@PathVariable long id, @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.success(service.complete(id(jwt), id));
    }

    @GetMapping("/api/v1/admin/media/{id}/access-url")
    ApiResponse<AccessUrl> access(@PathVariable long id) {
        return ApiResponse.success(service.access(id));
    }

    @DeleteMapping("/api/v1/admin/media/{id}")
    ApiResponse<Void> delete(@PathVariable long id, @AuthenticationPrincipal Jwt jwt) {
        service.delete(id(jwt), id);
        return ApiResponse.success(null);
    }

    @GetMapping("/api/v1/media-content/{id}")
    ResponseEntity<byte[]> content(
            @PathVariable long id, @RequestParam long expires, @RequestParam String signature) {
        Content content = service.content(id, expires, signature);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(content.mimeType()))
                .header(
                        HttpHeaders.CONTENT_DISPOSITION,
                        ContentDisposition.inline().filename(content.fileName()).build().toString())
                .body(content.bytes());
    }

    @GetMapping("/api/v1/media-content/{id}/public")
    ResponseEntity<byte[]> publicContent(@PathVariable long id) {
        Content content = service.publicContent(id);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(content.mimeType()))
                .header(
                        HttpHeaders.CONTENT_DISPOSITION,
                        ContentDisposition.inline().filename(content.fileName()).build().toString())
                .body(content.bytes());
    }

    private static long id(Jwt jwt) {
        return Long.parseLong(jwt.getSubject());
    }
}
