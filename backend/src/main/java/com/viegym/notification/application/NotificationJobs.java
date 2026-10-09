package com.viegym.notification.application;

import java.time.Clock;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class NotificationJobs {
    private final JdbcTemplate jdbc;
    private final NotificationService notifications;
    private final Clock clock;

    public NotificationJobs(JdbcTemplate jdbc, NotificationService notifications, Clock clock) {
        this.jdbc = jdbc;
        this.notifications = notifications;
        this.clock = clock;
    }

    @Scheduled(fixedDelayString = "${notification.dispatch-interval-ms:60000}")
    public void dispatch() {
        notifications.dispatchDue();
    }

    @Scheduled(fixedDelayString = "${notification.reminder-scan-interval-ms:300000}")
    public void workoutReminders() {
        OffsetDateTime now = OffsetDateTime.now(clock);
        OffsetDateTime horizon = now.plusMinutes(30);
        List<Row> rows =
                jdbc.query(
                        "select id,user_id,scheduled_date,scheduled_time from workout_schedules where status='PLANNED' and scheduled_time is not null and (scheduled_date + scheduled_time) between ? and ?",
                        (rs, row) ->
                                new Row(
                                        rs.getLong(1),
                                        rs.getLong(2),
                                        rs.getDate(3)
                                                .toLocalDate()
                                                .atTime(rs.getTime(4).toLocalTime())
                                                .atOffset(ZoneOffset.UTC)),
                        java.sql.Timestamp.from(now.toInstant()),
                        java.sql.Timestamp.from(horizon.toInstant()));
        rows.forEach(
                item ->
                        notifications.schedule(
                                item.userId(),
                                "WORKOUT_REMINDER",
                                "Sắp đến giờ tập",
                                "Buổi tập của bạn sẽ bắt đầu trong ít phút.",
                                item.when().minusMinutes(15),
                                "WORKOUT_SCHEDULE",
                                String.valueOf(item.id()),
                                "/workout",
                                "workout:" + item.id() + ":" + item.when().toLocalDate()));
    }

    @Scheduled(fixedDelayString = "${notification.daily-scan-interval-ms:900000}")
    public void mealAndWeightReminders() {
        List<UserZone> users =
                jdbc.query(
                        "select u.id, coalesce(p.timezone, 'Asia/Ho_Chi_Minh') timezone from users u left join notification_preferences p on p.user_id=u.id where u.role='USER' and u.status='ACTIVE' and u.deleted_at is null",
                        (rs, row) -> new UserZone(rs.getLong(1), rs.getString(2)));
        for (UserZone user : users) {
            var local = OffsetDateTime.now(clock).atZoneSameInstant(ZoneId.of(user.timezone()));
            if (local.getHour() == 11) {
                notifications.schedule(
                        user.id(),
                        "MEAL_REMINDER",
                        "Nhắc ghi nhận bữa ăn",
                        "Đừng quên cập nhật bữa ăn để theo dõi dinh dưỡng hôm nay.",
                        OffsetDateTime.now(clock),
                        "DAILY_MEAL",
                        local.toLocalDate().toString(),
                        "/meal",
                        "meal:" + local.toLocalDate());
            }
            if (local.getDayOfWeek() == java.time.DayOfWeek.MONDAY && local.getHour() == 8) {
                notifications.schedule(
                        user.id(),
                        "WEIGHT_REMINDER",
                        "Nhắc cập nhật cân nặng",
                        "Cập nhật cân nặng tuần này để theo dõi xu hướng chính xác hơn.",
                        OffsetDateTime.now(clock),
                        "WEEKLY_WEIGHT",
                        local.toLocalDate().toString(),
                        "/progress",
                        "weight:" + local.toLocalDate());
            }
        }
    }

    private record Row(long id, long userId, OffsetDateTime when) {}

    private record UserZone(long id, String timezone) {}
}
