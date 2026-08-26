package com.viegym.profile.api;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.LinkedHashSet;
import java.util.Set;

public class UpdateUserRequest {

    @NotBlank(message = "displayName is required")
    @Size(max = 120, message = "displayName must be at most 120 characters")
    private String displayName;

    private Long avatarMediaId;

    @NotBlank(message = "timezone is required")
    @Size(max = 64, message = "timezone must be at most 64 characters")
    private String timezone;

    @NotBlank(message = "locale is required")
    @Size(max = 10, message = "locale must be at most 10 characters")
    private String locale;

    private final Set<String> unknownFields = new LinkedHashSet<>();

    public String displayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public Long avatarMediaId() {
        return avatarMediaId;
    }

    public void setAvatarMediaId(Long avatarMediaId) {
        this.avatarMediaId = avatarMediaId;
    }

    public String timezone() {
        return timezone;
    }

    public void setTimezone(String timezone) {
        this.timezone = timezone;
    }

    public String locale() {
        return locale;
    }

    public void setLocale(String locale) {
        this.locale = locale;
    }

    public Set<String> unknownFields() {
        return Set.copyOf(unknownFields);
    }

    @JsonAnySetter
    void rejectUnknownField(String field, Object ignored) {
        unknownFields.add(field);
    }
}
