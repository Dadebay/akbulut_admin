import 'package:akbulut_admin/app/data/models/attendence_record.dart';
import 'package:akbulut_admin/app/data/services/dahua_service.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // --- SİZİN MEVCUT KODUNUZ (DOKUNULMADI) ---
  final DahuaService _dahuaService = DahuaService();
  var isLoading = true.obs;
  var totalEmployees = 0.obs; // Bu, "Total User" kartında kullanılacak
  var employeesAtWork = 0.obs;
  var attendanceHistory = <int>[].obs;

  // --- YENİ TASARIM İÇİN EKLENEN VERİLER ---
  // Diğer kartlar için örnek veriler
  final RxString totalOrder = "10,293".obs;
  final RxString totalSales = "\$89,000".obs;

  // Kartlardaki yüzde değişim verileri
  final RxString userChange = "+8.5%".obs;
  final RxString orderChange = "+1.3%".obs;
  final RxString salesChange = "-4.3%".obs;
  final RxString pendingChange = "+1.8%".obs;

  final RxString userChangeText = "Up from yesterday".obs;
  final RxString orderChangeText = "Up from past week".obs;
  final RxString salesChangeText = "Down from yesterday".obs;
  final RxString pendingChangeText = "Up from yesterday".obs;

  // Satış Detayları grafiği için örnek veri noktaları
  final List<FlSpot> salesSpots = [
    const FlSpot(5, 25),
    const FlSpot(10, 35),
    const FlSpot(12, 42),
    const FlSpot(15, 30),
    const FlSpot(18, 45),
    const FlSpot(22, 72),
    const FlSpot(25, 55),
    const FlSpot(30, 60),
    const FlSpot(35, 40),
    const FlSpot(40, 65),
    const FlSpot(45, 60),
    const FlSpot(50, 55),
    const FlSpot(55, 58),
    const FlSpot(60, 52),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceData(); // Sizin veri çekme fonksiyonunuz çağrılıyor
  }

  // --- SİZİN MEVCUT FONKSİYONUNUZ (DOKUNULMADI) ---
  Future<void> fetchAttendanceData() async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sevenDaysAgo = today.subtract(const Duration(days: 6));

      final records = await _dahuaService.fetchAttendanceRecords(sevenDaysAgo, now);
      final userRecords = groupBy(records, (AttendanceRecord r) => r.userId);

      totalEmployees.value = userRecords.keys.length;

      int atWorkCount = 0;
      final todayRecords = records.where((r) => r.createTime.isAfter(today)).toList();
      final todayUserRecords = groupBy(todayRecords, (AttendanceRecord r) => r.userId);

      todayUserRecords.forEach((userId, records) {
        if (records.isNotEmpty) {
          records.sort((a, b) => a.createTime.compareTo(b.createTime));
          if (records.length % 2 != 0) {
            atWorkCount++;
          }
        }
      });
      employeesAtWork.value = atWorkCount;

      final history = <int>[];
      for (int i = 0; i < 7; i++) {
        final date = sevenDaysAgo.add(Duration(days: i));
        final dayRecords = records.where((r) => r.createTime.year == date.year && r.createTime.month == date.month && r.createTime.day == date.day).toList();
        final dayUserRecords = groupBy(dayRecords, (AttendanceRecord r) => r.userId);
        history.add(dayUserRecords.keys.length);
      }
      attendanceHistory.value = history;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch attendance data');
    } finally {
      isLoading.value = false;
    }
  }
}
