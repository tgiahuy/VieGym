/// Calculates time-based Vietnamese greeting according to VieGym schedule:
/// - 04:31 to 10:30: "Chào buổi sáng"
/// - 10:31 to 18:00: "Chào buổi chiều"
/// - 18:01 to 04:30: "Chào buổi tối"
String getTimeBasedGreeting([DateTime? time]) {
  final now = time ?? DateTime.now();
  final totalMinutes = now.hour * 60 + now.minute;

  if (totalMinutes >= 271 && totalMinutes <= 630) {
    // 04:31 -> 10:30
    return 'Chào buổi sáng';
  } else if (totalMinutes >= 631 && totalMinutes <= 1080) {
    // 10:31 -> 18:00
    return 'Chào buổi chiều';
  } else {
    // 18:01 -> 04:30
    return 'Chào buổi tối';
  }
}
