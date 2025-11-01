import 'package:akbulut_admin/app/data/models/attendence_record.dart';
import 'package:akbulut_admin/app/data/models/daily_status.dart';
import 'package:collection/collection.dart';

class Employee {
  final String userId;
  final String name;
  final String? imageUrl;
  final List<DailyStatus> dailyStatuses;
  final Duration totalWorkDuration;
  bool isCurrentlyAtWork;
  final double successRate;

  Employee({
    required this.userId,
    required this.name,
    this.imageUrl,
    required this.dailyStatuses,
    required this.totalWorkDuration,
    this.isCurrentlyAtWork = false,
    required this.successRate,
  });
}
