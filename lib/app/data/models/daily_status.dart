enum DailyStatusType { present, absent, weekend }

class DailyStatus {
  final DateTime date;
  final DailyStatusType type;
  final bool isWeekend;
  final DateTime? arrivalTime;
  final DateTime? departureTime;
  final Duration? workDuration;

  DailyStatus({
    required this.date,
    required this.type,
    this.isWeekend = false,
    this.arrivalTime,
    this.departureTime,
    this.workDuration,
  });
}
