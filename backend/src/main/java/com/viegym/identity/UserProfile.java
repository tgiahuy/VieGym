package com.viegym.identity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;

@Entity
@Table(name = "user_profiles")
public class UserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "display_name", nullable = false, length = 120)
    private String displayName;

    @Column(name = "avatar_media_id")
    private Long avatarMediaId;

    @Column(nullable = false, length = 64)
    private String timezone;

    @Column(nullable = false, length = 10)
    private String locale;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    protected UserProfile() {}

    public UserProfile(User user, String displayName) {
        this.user = user;
        this.displayName = displayName;
        this.timezone = "Asia/Ho_Chi_Minh";
        this.locale = "vi-VN";
        this.createdAt = OffsetDateTime.now();
        this.updatedAt = this.createdAt;
    }

    public Long id() {
        return id;
    }

    public User user() {
        return user;
    }

    public String displayName() {
        return displayName;
    }

    public Long avatarMediaId() {
        return avatarMediaId;
    }

    public String timezone() {
        return timezone;
    }

    public String locale() {
        return locale;
    }

    public void update(String displayName, String timezone, String locale, OffsetDateTime now) {
        this.displayName = displayName;
        this.timezone = timezone;
        this.locale = locale;
        this.updatedAt = now;
    }
}
