package com.viegym.admin.user.application;

import com.viegym.admin.audit.application.AdminAuditService;
import com.viegym.admin.user.api.AdminUserDtos.InviteUserRequest;
import com.viegym.admin.user.api.AdminUserDtos.UserSummary;
import com.viegym.common.api.PageResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.identity.AccountStatus;
import com.viegym.identity.User;
import com.viegym.identity.UserProfile;
import com.viegym.identity.UserProfileRepository;
import com.viegym.identity.UserRepository;
import com.viegym.identity.UserRole;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminUserService {

    private final JdbcTemplate jdbc;
    private final UserRepository userRepository;
    private final UserProfileRepository profileRepository;
    private final AdminAuditService auditService;
    private final PasswordEncoder passwordEncoder;

    public AdminUserService(
            JdbcTemplate jdbc,
            UserRepository userRepository,
            UserProfileRepository profileRepository,
            AdminAuditService auditService,
            PasswordEncoder passwordEncoder) {
        this.jdbc = jdbc;
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.auditService = auditService;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public PageResponse<UserSummary> list(String q, String role, String status, Pageable pageable) {
        StringBuilder where = new StringBuilder("where u.deleted_at is null ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            where.append(
                    "and (lower(u.email) like ? or lower(coalesce(p.display_name, '')) like ?) ");
            String searchPattern = "%" + q.trim().toLowerCase(Locale.ROOT) + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (role != null && !role.isBlank() && !"ALL".equalsIgnoreCase(role)) {
            where.append("and u.role = ? ");
            params.add(role.trim().toUpperCase(Locale.ROOT));
        }

        if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
            where.append("and u.status = ? ");
            params.add(status.trim().toUpperCase(Locale.ROOT));
        }

        long total =
                jdbc.queryForObject(
                        "select count(*) from users u left join user_profiles p on p.user_id = u.id "
                                + where,
                        Long.class,
                        params.toArray());

        params.add(pageable.getPageSize());
        params.add(pageable.getOffset());

        List<UserSummary> list =
                jdbc.query(
                        "select u.id, u.email, coalesce(p.display_name, split_part(u.email, '@', 1)) as display_name, "
                                + "u.role, u.status, u.auth_provider, u.last_login_at, u.created_at, u.updated_at "
                                + "from users u left join user_profiles p on p.user_id = u.id "
                                + where
                                + "order by u.id desc limit ? offset ?",
                        this::mapSummary,
                        params.toArray());

        return PageResponse.from(new PageImpl<>(list, pageable, total));
    }

    @Transactional(readOnly = true)
    public UserSummary get(long id) {
        List<UserSummary> rows =
                jdbc.query(
                        "select u.id, u.email, coalesce(p.display_name, split_part(u.email, '@', 1)) as display_name, "
                                + "u.role, u.status, u.auth_provider, u.last_login_at, u.created_at, u.updated_at "
                                + "from users u left join user_profiles p on p.user_id = u.id "
                                + "where u.id = ? and u.deleted_at is null",
                        this::mapSummary,
                        id);
        if (rows.isEmpty()) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Không tìm thấy người dùng");
        }
        return rows.getFirst();
    }

    @Transactional
    public UserSummary updateStatus(
            long adminId, long targetUserId, String newStatus, String reason) {
        User user =
                userRepository
                        .findById(targetUserId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND,
                                                "Không tìm thấy người dùng"));

        AccountStatus parsedStatus;
        try {
            parsedStatus = AccountStatus.valueOf(newStatus.trim().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException e) {
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Trạng thái không hợp lệ");
        }

        if (parsedStatus == AccountStatus.LOCKED) {
            user.lock();
        } else if (parsedStatus == AccountStatus.ACTIVE) {
            user.activate(OffsetDateTime.now());
        }

        userRepository.save(user);

        auditService.record(
                adminId,
                "ROLE_ADMIN",
                parsedStatus == AccountStatus.LOCKED ? "LOCK" : "UPDATE",
                "USER",
                targetUserId,
                "SUCCESS",
                Map.of("newStatus", parsedStatus.name(), "reason", reason != null ? reason : ""));

        return get(targetUserId);
    }

    @Transactional
    public UserSummary invite(long adminId, InviteUserRequest req) {
        if (req.email() == null || req.email().isBlank()) {
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Email không được để trống");
        }

        String normalizedEmail = req.email().trim().toLowerCase(Locale.ROOT);
        if (userRepository.existsByEmail(normalizedEmail)) {
            throw new ApiException(
                    ApiErrorCode.EMAIL_ALREADY_EXISTS, "Email đã tồn tại trong hệ thống");
        }

        UserRole role = UserRole.ADMIN;
        if ("TRAINER".equalsIgnoreCase(req.role())) {
            role = UserRole.USER;
        }

        OffsetDateTime now = OffsetDateTime.now();
        String tempHash = passwordEncoder.encode(cryptoRandomHex());
        User user = User.localAdmin(normalizedEmail, tempHash, now);
        user = userRepository.save(user);

        String displayName =
                (req.fullName() != null && !req.fullName().isBlank())
                        ? req.fullName().trim()
                        : normalizedEmail;
        UserProfile profile = new UserProfile(user, displayName);
        profileRepository.save(profile);

        auditService.record(
                adminId,
                "ROLE_ADMIN",
                "INVITE",
                "USER",
                user.id(),
                "SUCCESS",
                Map.of(
                        "email",
                        normalizedEmail,
                        "role",
                        role.name(),
                        "notes",
                        req.notes() != null ? req.notes() : ""));

        return get(user.id());
    }

    private UserSummary mapSummary(ResultSet rs, int rowNum) throws SQLException {
        return new UserSummary(
                rs.getLong("id"),
                rs.getString("email"),
                rs.getString("display_name"),
                rs.getString("role"),
                rs.getString("status"),
                rs.getString("auth_provider"),
                rs.getObject("last_login_at", OffsetDateTime.class),
                rs.getObject("created_at", OffsetDateTime.class),
                rs.getObject("updated_at", OffsetDateTime.class));
    }

    private String cryptoRandomHex() {
        return java.util.UUID.randomUUID().toString().replace("-", "");
    }
}
