class DailyAttendance {
  final DateTime date;
  final DateTime arrivalTime;
  final DateTime? departureTime;

  DailyAttendance({
    required this.date,
    required this.arrivalTime,
    this.departureTime,
  });
}
