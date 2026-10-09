package com.viegym.notification;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.viegym.notification.application.NotificationService;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalTime;
import java.time.ZoneOffset;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

class NotificationServiceTests {
    private final JdbcTemplate jdbc = mock(JdbcTemplate.class);
    private final NotificationService service =
            new NotificationService(
                    jdbc, Clock.fixed(Instant.parse("2026-10-05T15:30:00Z"), ZoneOffset.UTC));

    @Test
    void disabledPreferencePreventsReminder() {
        when(jdbc.query(anyString(), any(org.springframework.jdbc.core.RowMapper.class), eq(7L)))
                .thenReturn(
                        List.of(
                                new NotificationService.Preference(
                                        7L,
                                        false,
                                        true,
                                        true,
                                        false,
                                        false,
                                        null,
                                        null,
                                        "Asia/Ho_Chi_Minh")));

        boolean created =
                service.schedule(
                        7L,
                        "WORKOUT_REMINDER",
                        "Workout",
                        "Time to train",
                        null,
                        "WORKOUT",
                        "10",
                        "/workout",
                        "workout:10");

        assertThat(created).isFalse();
    }

    @Test
    void readMutationIsScopedByOwner() {
        when(jdbc.update(anyString(), eq(44L), eq(7L))).thenReturn(0);
        try {
            service.read(7L, 44L);
        } catch (RuntimeException ignored) {
            // Expected: a foreign/missing notification is indistinguishable from not found.
        }
        verify(jdbc).update(anyString(), eq(44L), eq(7L));
    }

    @Test
    void validatesIanaTimezoneAndPairedQuietHours() {
        var request =
                new NotificationService.PreferenceRequest(
                        true,
                        true,
                        true,
                        false,
                        false,
                        LocalTime.of(22, 0),
                        LocalTime.of(7, 0),
                        "Asia/Ho_Chi_Minh");
        when(jdbc.queryForObject(anyString(), eq(Integer.class), eq(7L))).thenReturn(1);
        when(jdbc.update(anyString(), any(Object[].class))).thenReturn(1);
        when(jdbc.query(anyString(), any(org.springframework.jdbc.core.RowMapper.class), eq(7L)))
                .thenReturn(List.of());
        service.updatePreference(7L, request);
        verify(jdbc).update(anyString(), any(Object[].class));
    }
}
