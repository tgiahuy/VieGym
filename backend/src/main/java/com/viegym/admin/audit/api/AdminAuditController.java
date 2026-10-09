package com.viegym.admin.audit.api;

import com.viegym.admin.audit.application.AdminAuditService;
import com.viegym.admin.audit.application.AdminAuditService.AuditEvent;
import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import java.time.OffsetDateTime;
import org.springframework.data.domain.PageRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/audit-logs")
public class AdminAuditController {
    private final AdminAuditService service;

    public AdminAuditController(AdminAuditService service) {
        this.service = service;
    }

    @GetMapping
    ApiResponse<PageResponse<AuditEvent>> list(
            @RequestParam(required = false) Long actorId,
            @RequestParam(required = false) String action,
            @RequestParam(required = false) String targetType,
            @RequestParam(required = false) String targetId,
            @RequestParam(required = false) String result,
            @RequestParam(required = false) String correlationId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
                    OffsetDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
                    OffsetDateTime to,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(
                service.list(
                        actorId,
                        action,
                        targetType,
                        targetId,
                        result,
                        correlationId,
                        from,
                        to,
                        PageRequest.of(Math.max(0, page), Math.min(50, Math.max(1, size)))));
    }

    @GetMapping("/{id}")
    ApiResponse<AuditEvent> get(@PathVariable long id) {
        return ApiResponse.success(service.get(id));
    }
}
