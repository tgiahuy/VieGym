package com.viegym.admin.media.application;

import com.viegym.admin.audit.application.AdminAuditService;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminMediaService {
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final Set<String> IMAGE_MIMES = Set.of("image/jpeg", "image/png", "image/webp");
    private static final long IMAGE_LIMIT = 5L * 1024 * 1024;
    private static final long VIDEO_LIMIT = 50L * 1024 * 1024;

    private final JdbcTemplate jdbc;
    private final AdminAuditService audit;
    private final Clock clock;
    private final String publicBaseUrl;

    public AdminMediaService(
            JdbcTemplate jdbc,
            AdminAuditService audit,
            Clock clock,
            @Value("${media.public-base-url:${MEDIA_PUBLIC_BASE_URL:http://localhost:8080}}")
                    String publicBaseUrl) {
        this.jdbc = jdbc;
        this.audit = audit;
        this.clock = clock;
        this.publicBaseUrl = publicBaseUrl.replaceAll("/$", "");
    }

    @Transactional
    public UploadInit init(long adminId, InitRequest request) {
        String ownerType = upper(request.ownerType());
        String mediaType = upper(request.mediaType());
        String role = upper(request.role());
        validateOwner(ownerType, request.ownerId());
        validateMetadata(
                ownerType,
                mediaType,
                role,
                request.fileName(),
                request.mimeType(),
                request.fileSizeBytes());
        String token = token();
        String objectKey =
                ownerType.toLowerCase(Locale.ROOT)
                        + "/"
                        + request.ownerId()
                        + "/"
                        + java.util.UUID.randomUUID()
                        + extension(request.fileName());
        OffsetDateTime expires = OffsetDateTime.now(clock).plusMinutes(10);
        var key = new GeneratedKeyHolder();
        jdbc.update(
                connection -> {
                    var ps =
                            connection.prepareStatement(
                                    "insert into media_objects (owner_type, owner_id, media_type, role, sort_order, object_key, original_file_name, declared_mime_type, expected_size_bytes, visibility, upload_token_hash, upload_expires_at, uploaded_by) values (?,?,?,?,?,?,?,?,?,?,?,?,?)",
                                    new String[] {"id"});
                    ps.setString(1, ownerType);
                    ps.setLong(2, request.ownerId());
                    ps.setString(3, mediaType);
                    ps.setString(4, role);
                    ps.setInt(5, Math.max(1, request.sortOrder()));
                    ps.setString(6, objectKey);
                    ps.setString(7, safeName(request.fileName()));
                    ps.setString(8, request.mimeType().toLowerCase(Locale.ROOT));
                    ps.setLong(9, request.fileSizeBytes());
                    ps.setString(10, "PUBLIC");
                    ps.setString(11, hash(token));
                    ps.setObject(12, expires);
                    ps.setLong(13, adminId);
                    return ps;
                },
                key);
        long id = key.getKey().longValue();
        audit.record(
                adminId,
                "ADMIN",
                "MEDIA_UPLOAD_INIT",
                ownerType,
                request.ownerId(),
                "SUCCESS",
                Map.of(
                        "mediaId",
                        id,
                        "mimeType",
                        request.mimeType(),
                        "size",
                        request.fileSizeBytes()));
        return new UploadInit(
                id,
                publicBaseUrl + "/api/v1/media-upload/" + id + "?uploadToken=" + token,
                expires,
                Map.of("Content-Type", request.mimeType()));
    }

    @Transactional
    public void receive(long id, String token, String contentType, byte[] payload) {
        MediaRow media = load(id);
        requirePendingToken(media, token);
        if (payload == null || payload.length != media.expectedSize())
            throw new ApiException(
                    ApiErrorCode.MEDIA_SIZE_EXCEEDED, "Uploaded size does not match init metadata");
        String actualMime = sniff(payload);
        if (actualMime == null || !actualMime.equals(media.declaredMime()))
            throw new ApiException(
                    ApiErrorCode.MEDIA_MIME_MISMATCH,
                    "File content does not match declared MIME type");
        if (contentType != null && !contentType.split(";")[0].trim().equalsIgnoreCase(actualMime))
            throw new ApiException(
                    ApiErrorCode.MEDIA_MIME_MISMATCH, "Content-Type does not match file content");
        jdbc.update(
                "insert into media_upload_payloads (media_id, payload) values (?, ?) on conflict (media_id) do update set payload=excluded.payload, received_at=current_timestamp",
                id,
                payload);
    }

    @Transactional
    public Media complete(long adminId, long id) {
        MediaRow media = load(id);
        if (media.status().equals("READY")) return toMedia(media);
        if (!media.status().equals("PENDING_UPLOAD"))
            throw new ApiException(ApiErrorCode.UPLOAD_NOT_COMPLETED, "Upload is not pending");
        List<byte[]> payloads =
                jdbc.query(
                        "select payload from media_upload_payloads where media_id=?",
                        (rs, row) -> rs.getBytes(1),
                        id);
        if (payloads.isEmpty())
            throw new ApiException(
                    ApiErrorCode.UPLOAD_NOT_COMPLETED, "Object has not been uploaded");
        byte[] bytes = payloads.getFirst();
        String actualMime = sniff(bytes);
        if (actualMime == null || !actualMime.equals(media.declaredMime()))
            throw new ApiException(
                    ApiErrorCode.MEDIA_MIME_MISMATCH, "Stored object MIME verification failed");
        jdbc.update(
                "update media_objects set mime_type=?, file_size_bytes=?, status='READY', verified_at=current_timestamp, updated_at=current_timestamp where id=?",
                actualMime,
                bytes.length,
                id);
        audit.record(
                adminId,
                "ADMIN",
                "MEDIA_UPLOAD_COMPLETE",
                media.ownerType(),
                media.ownerId(),
                "SUCCESS",
                Map.of("mediaId", id, "mimeType", actualMime, "size", bytes.length));
        return toMedia(load(id));
    }

    @Transactional(readOnly = true)
    public AccessUrl access(long id) {
        MediaRow row = load(id);
        if (!row.status().equals("READY"))
            throw new ApiException(ApiErrorCode.UPLOAD_NOT_COMPLETED, "Media is not ready");
        String token = token();
        // Access tokens are deliberately short-lived and statelessly bound to the current upload
        // secret.
        OffsetDateTime expires = OffsetDateTime.now(clock).plusMinutes(5);
        String signature = hash(id + ":" + expires.toEpochSecond() + ":" + row.tokenHash());
        return new AccessUrl(
                publicBaseUrl
                        + "/api/v1/media-content/"
                        + id
                        + "?expires="
                        + expires.toEpochSecond()
                        + "&signature="
                        + signature,
                expires);
    }

    @Transactional(readOnly = true)
    public Content content(long id, long expires, String signature) {
        MediaRow row = load(id);
        if (!row.status().equals("READY") || OffsetDateTime.now(clock).toEpochSecond() > expires)
            throw new ApiException(ApiErrorCode.UPLOAD_EXPIRED, "Media access URL expired");
        String expected = hash(id + ":" + expires + ":" + row.tokenHash());
        if (!constant(expected, signature))
            throw new ApiException(ApiErrorCode.ACCESS_DENIED, "Media signature is invalid");
        byte[] bytes =
                jdbc.queryForObject(
                        "select payload from media_upload_payloads where media_id=?",
                        byte[].class,
                        id);
        return new Content(bytes, row.actualMime(), row.fileName());
    }

    @Transactional(readOnly = true)
    public Content publicContent(long id) {
        MediaRow row = load(id);
        if (!row.status().equals("READY")) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Media not found");
        }
        Integer visible =
                jdbc.queryForObject(
                        "select count(*) from media_objects where id=? and visibility='PUBLIC' and status='READY' and deleted_at is null",
                        Integer.class,
                        id);
        if (visible == null || visible == 0) {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Media not found");
        }
        byte[] bytes =
                jdbc.queryForObject(
                        "select payload from media_upload_payloads where media_id=?",
                        byte[].class,
                        id);
        return new Content(bytes, row.actualMime(), row.fileName());
    }

    @Transactional
    public void delete(long adminId, long id) {
        MediaRow row = load(id);
        jdbc.update(
                "update media_objects set status='DELETED', deleted_at=current_timestamp, updated_at=current_timestamp where id=? and status<>'DELETED'",
                id);
        audit.record(
                adminId,
                "ADMIN",
                "MEDIA_DELETE",
                row.ownerType(),
                row.ownerId(),
                "SUCCESS",
                Map.of("mediaId", id));
    }

    private void validateOwner(String type, long id) {
        String table =
                switch (type) {
                    case "EXERCISE" -> "exercises";
                    case "FOOD" -> "foods";
                    case "USER_PROFILE" -> "users";
                    default ->
                            throw new ApiException(
                                    ApiErrorCode.VALIDATION_ERROR, "Owner type is invalid");
                };
        Integer count =
                jdbc.queryForObject(
                        "select count(*) from " + table + " where id=? and deleted_at is null",
                        Integer.class,
                        id);
        if (count == null || count == 0)
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Media owner not found");
    }

    private void validateMetadata(
            String ownerType, String mediaType, String role, String name, String mime, long size) {
        if (name == null || name.isBlank() || mime == null)
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Media metadata is required");
        String lowerMime = mime.toLowerCase(Locale.ROOT);
        String ext = extension(name);
        boolean image =
                IMAGE_MIMES.contains(lowerMime)
                        && Set.of(".jpg", ".jpeg", ".png", ".webp").contains(ext);
        boolean video = lowerMime.equals("video/mp4") && ext.equals(".mp4");
        if ((!image && !video)
                || (image && !mediaType.equals("IMAGE"))
                || (video && !mediaType.equals("VIDEO")))
            throw new ApiException(
                    ApiErrorCode.MEDIA_TYPE_NOT_SUPPORTED,
                    "Media type or extension is not supported");
        if (size <= 0 || size > (image ? IMAGE_LIMIT : VIDEO_LIMIT))
            throw new ApiException(
                    ApiErrorCode.MEDIA_SIZE_EXCEEDED, "Media exceeds configured size limit");
        if (ownerType.equals("FOOD") && video)
            throw new ApiException(
                    ApiErrorCode.MEDIA_TYPE_NOT_SUPPORTED, "Food accepts images only");
        if (!Set.of("THUMBNAIL", "PRIMARY_VIDEO", "GALLERY", "AVATAR").contains(role))
            throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "Media role is invalid");
    }

    private MediaRow load(long id) {
        List<MediaRow> rows =
                jdbc.query(
                        "select * from media_objects where id=? and deleted_at is null",
                        this::map,
                        id);
        if (rows.isEmpty())
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Media not found");
        return rows.getFirst();
    }

    private MediaRow map(ResultSet rs, int row) throws SQLException {
        return new MediaRow(
                rs.getLong("id"),
                rs.getString("owner_type"),
                rs.getLong("owner_id"),
                rs.getString("media_type"),
                rs.getString("role"),
                rs.getString("object_key"),
                rs.getString("original_file_name"),
                rs.getString("declared_mime_type"),
                rs.getString("mime_type"),
                rs.getLong("expected_size_bytes"),
                rs.getLong("file_size_bytes"),
                rs.getString("status"),
                rs.getString("upload_token_hash"),
                rs.getObject("upload_expires_at", OffsetDateTime.class),
                rs.getObject("verified_at", OffsetDateTime.class));
    }

    private void requirePendingToken(MediaRow row, String token) {
        if (!row.status().equals("PENDING_UPLOAD"))
            throw new ApiException(ApiErrorCode.UPLOAD_NOT_COMPLETED, "Upload is not pending");
        if (OffsetDateTime.now(clock).isAfter(row.expiresAt()))
            throw new ApiException(ApiErrorCode.UPLOAD_EXPIRED, "Upload URL expired");
        if (!constant(row.tokenHash(), hash(token)))
            throw new ApiException(ApiErrorCode.ACCESS_DENIED, "Upload token is invalid");
    }

    private Media toMedia(MediaRow r) {
        return new Media(
                r.id(),
                r.ownerType(),
                r.ownerId(),
                r.mediaType(),
                r.role(),
                r.fileName(),
                r.actualMime(),
                r.fileSize(),
                r.status(),
                r.verifiedAt());
    }

    private static String sniff(byte[] b) {
        if (b.length >= 3 && (b[0] & 255) == 0xff && (b[1] & 255) == 0xd8 && (b[2] & 255) == 0xff)
            return "image/jpeg";
        if (b.length >= 8 && b[0] == (byte) 0x89 && b[1] == 0x50 && b[2] == 0x4e && b[3] == 0x47)
            return "image/png";
        if (b.length >= 12
                && new String(b, 0, 4).equals("RIFF")
                && new String(b, 8, 4).equals("WEBP")) return "image/webp";
        if (b.length >= 12 && new String(b, 4, 4).equals("ftyp")) return "video/mp4";
        return null;
    }

    private static String safeName(String name) {
        return name.replaceAll("[\\r\\n\\\\/]", "_").substring(0, Math.min(255, name.length()));
    }

    private static String extension(String name) {
        if (name == null) return "";
        int index = name.lastIndexOf('.');
        return index < 0 ? "" : name.substring(index).toLowerCase(Locale.ROOT);
    }

    private static String upper(String s) {
        return s == null ? "" : s.trim().toUpperCase(Locale.ROOT);
    }

    private static String token() {
        byte[] b = new byte[32];
        RANDOM.nextBytes(b);
        return HexFormat.of().formatHex(b);
    }

    private static String hash(String s) {
        try {
            return HexFormat.of()
                    .formatHex(
                            MessageDigest.getInstance("SHA-256")
                                    .digest(
                                            (s == null ? "" : s)
                                                    .getBytes(
                                                            java.nio.charset.StandardCharsets
                                                                    .UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    private static boolean constant(String a, String b) {
        return a != null
                && b != null
                && MessageDigest.isEqual(
                        a.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                        b.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }

    public record InitRequest(
            String ownerType,
            long ownerId,
            String mediaType,
            String role,
            int sortOrder,
            String fileName,
            String mimeType,
            long fileSizeBytes) {}

    public record UploadInit(
            long mediaId,
            String uploadUrl,
            OffsetDateTime expiresAt,
            Map<String, String> requiredHeaders) {}

    public record Media(
            long id,
            String ownerType,
            long ownerId,
            String mediaType,
            String role,
            String fileName,
            String mimeType,
            long fileSizeBytes,
            String status,
            OffsetDateTime verifiedAt) {}

    public record AccessUrl(String url, OffsetDateTime expiresAt) {}

    public record Content(byte[] bytes, String mimeType, String fileName) {}

    private record MediaRow(
            long id,
            String ownerType,
            long ownerId,
            String mediaType,
            String role,
            String objectKey,
            String fileName,
            String declaredMime,
            String actualMime,
            long expectedSize,
            long fileSize,
            String status,
            String tokenHash,
            OffsetDateTime expiresAt,
            OffsetDateTime verifiedAt) {}
}
