import 'dart:typed_data';

import 'package:akbulut_admin/app/data/models/daily_status.dart';
import 'package:akbulut_admin/app/data/models/employee.dart';
import 'package:akbulut_admin/app/data/services/dahua_service.dart';
import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:collection/collection.dart'; // For groupBy
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../../data/models/attendence_record.dart';

class AttendanceController extends GetxController {
  final DahuaService _dahuaService = DahuaService();

  var isLoading = true.obs;
  var allEmployees = <Employee>[].obs;
  var filteredEmployees = <Employee>[].obs;

  var totalEmployeesCount = 0.obs;
  var employeesAtWorkCount = 0.obs;
  var employeesNotAtWorkCount = 0.obs;

  var searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  var selectedYear = DateTime.now().year.obs;
  var yearList = List<int>.generate(5, (i) => DateTime.now().year - i).obs;

  var selectedDateRange = Rx<DateTimeRange>(
    DateTimeRange(
      start: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      end: DateTime.now(),
    ),
  );
  var selectedFilterName = 'today'.obs;

  // Location selection for different offices
  var selectedLocation = 'merkez'.obs;

  bool get shouldShowLiveStatus {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !selectedDateRange.value.end.isBefore(today);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    filterEmployees();
  }

  void changeYear(int year) {
    selectedYear.value = year;
    final now = DateTime.now();
    if (year == now.year) {
      selectedDateRange.value =
          DateTimeRange(start: DateTime(year, 1, 1), end: now);
    } else {
      selectedDateRange.value = DateTimeRange(
          start: DateTime(year, 1, 1), end: DateTime(year, 12, 31));
    }
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final range = selectedDateRange.value;

      // First, get last 30 days to build complete employee list
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));

      final masterRecords = await _dahuaService.fetchAttendanceRecords(
        thirtyDaysAgo,
        today.add(const Duration(days: 1)),
        location: selectedLocation.value,
      );

      // Extract all unique employees from last 30 days
      final Map<String, String> allEmployeeNames = {};
      for (var record in masterRecords) {
        if (!allEmployeeNames.containsKey(record.userId)) {
          allEmployeeNames[record.userId] = record.cardName;
        }
      }

      // Now fetch records for the selected date range
      final List<AttendanceRecord> allRecords = [];

      const maxDurationDays = 30;
      var currentStart = range.start;

      while (currentStart.isBefore(range.end)) {
        var currentEnd =
            currentStart.add(const Duration(days: maxDurationDays));
        if (currentEnd.isAfter(range.end)) {
          currentEnd = range.end;
        }

        final chunkRecords = await _dahuaService.fetchAttendanceRecords(
          currentStart,
          currentEnd,
          location: selectedLocation.value,
        );
        allRecords.addAll(chunkRecords);

        currentStart = currentEnd.add(const Duration(days: 1));
      }

      _processRecords(allRecords, range, allEmployeeNames);
      await _updateLiveStatus(); // Update live status separately
      filterEmployees();
    } catch (e) {
      Get.snackbar('error_title'.tr, 'error_message'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateLiveStatus() async {
    if (!shouldShowLiveStatus) {
      for (var employee in allEmployees) {
        employee.isCurrentlyAtWork = false;
      }
      return;
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayRecords = await _dahuaService.fetchAttendanceRecords(
      todayStart,
      todayEnd,
      location: selectedLocation.value,
    );
    final todayUserRecords =
        groupBy(todayRecords, (AttendanceRecord r) => r.userId);

    for (var employee in allEmployees) {
      final userTodayRecords = todayUserRecords[employee.userId];
      bool isAtWork = false;
      if (userTodayRecords != null && userTodayRecords.isNotEmpty) {
        userTodayRecords.sort((a, b) => a.createTime.compareTo(b.createTime));
        final timeSpan = userTodayRecords.last.createTime
            .difference(userTodayRecords.first.createTime);

        if (timeSpan.inMinutes < 40) {
          // Single event, assume arrival if before 2 PM
          if (userTodayRecords.first.createTime.hour < 14) {
            isAtWork = true;
          }
        } else {
          // Multiple events, check if last event is arrival
          // This simple logic assumes an odd number of records means they are still inside.
          // A more robust solution might be needed depending on device behavior.
          if (userTodayRecords.length % 2 != 0) {
            isAtWork = true;
          }
        }
      }
      employee.isCurrentlyAtWork = isAtWork;
    }
  }

  void _processRecords(
    List<AttendanceRecord> records,
    DateTimeRange range,
    Map<String, String> allEmployeeNames,
  ) {
    final userRecords = groupBy(records, (AttendanceRecord r) => r.userId);

    allEmployees.clear();

    // Process all employees from the master list
    allEmployeeNames.forEach((userId, employeeName) {
      final userSpecificRecords = userRecords[userId] ?? [];

      final dailyStatuses = <DailyStatus>[];
      final recordsByDay = userSpecificRecords.isNotEmpty
          ? groupBy(
              userSpecificRecords,
              (AttendanceRecord r) => DateTime(
                  r.createTime.year, r.createTime.month, r.createTime.day))
          : <DateTime, List<AttendanceRecord>>{};

      for (var i = 0; i <= range.duration.inDays; i++) {
        final date = range.start.add(Duration(days: i));
        final dayRecords = recordsByDay[date];
        final bool isWeekend = date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;

        DailyStatus status;
        if (dayRecords != null && dayRecords.isNotEmpty) {
          dayRecords.sort((a, b) => a.createTime.compareTo(b.createTime));

          DateTime? arrival;
          DateTime? departure;

          final timeSpan = dayRecords.last.createTime
              .difference(dayRecords.first.createTime);

          if (timeSpan.inMinutes < 40) {
            final singleEventTime = dayRecords.first.createTime;
            if (singleEventTime.hour < 14) {
              arrival = singleEventTime;
              departure = null;
            } else {
              departure = singleEventTime;
              arrival = DateTime(singleEventTime.year, singleEventTime.month,
                  singleEventTime.day, 9, 0);
            }
          } else {
            arrival = dayRecords.first.createTime;
            departure = dayRecords.last.createTime;
          }

          Duration? duration;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          if (departure != null) {
            duration = departure.difference(arrival);
          } else {
            if (date == today) {
              duration = now.difference(arrival);
            } else {
              DateTime defaultDeparture;
              if (date.weekday >= 1 && date.weekday <= 5) {
                defaultDeparture =
                    DateTime(date.year, date.month, date.day, 18, 0);
              } else {
                defaultDeparture =
                    DateTime(date.year, date.month, date.day, 13, 0);
              }
              duration = defaultDeparture.difference(arrival);
            }
          }

          status = DailyStatus(
            date: date,
            type: DailyStatusType.present,
            isWeekend: isWeekend,
            arrivalTime: arrival,
            departureTime: departure,
            workDuration: duration,
          );
        } else {
          status = DailyStatus(
            date: date,
            type: isWeekend ? DailyStatusType.weekend : DailyStatusType.absent,
            isWeekend: isWeekend,
          );
        }
        dailyStatuses.add(status);
      }
      dailyStatuses.sort((a, b) => a.date.compareTo(b.date));

      final totalWorkDuration = dailyStatuses.fold<Duration>(
        Duration.zero,
        (prev, status) => prev + (status.workDuration ?? Duration.zero),
      );

      Duration totalExpectedWorkDuration = Duration.zero;
      for (var i = 0; i <= range.duration.inDays; i++) {
        final date = range.start.add(Duration(days: i));
        final status = dailyStatuses.firstWhereOrNull((s) => s.date == date);

        if (status != null && status.type != DailyStatusType.weekend) {
          if (date.weekday >= 1 && date.weekday <= 5) {
            totalExpectedWorkDuration += Duration(hours: 8);
          } else {
            totalExpectedWorkDuration += Duration(hours: 5);
          }
        }
      }

      final successRate = (totalExpectedWorkDuration.inMinutes > 0)
          ? (totalWorkDuration.inMinutes /
                  totalExpectedWorkDuration.inMinutes) *
              100
          : 0.0;

      final employee = Employee(
        userId: userId,
        name: employeeName.toTitleCase(),
        dailyStatuses: dailyStatuses,
        totalWorkDuration: totalWorkDuration,
        successRate: successRate,
      );

      allEmployees.add(employee);
    });
  }

  void filterEmployees() {
    List<Employee> employees;
    if (searchQuery.value.isEmpty) {
      employees = List.from(allEmployees);
    } else {
      employees = allEmployees
          .where((employee) => employee.name
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    if (shouldShowLiveStatus) {
      totalEmployeesCount.value = employees.length;
      employeesAtWorkCount.value =
          employees.where((e) => e.isCurrentlyAtWork).length;
      employeesNotAtWorkCount.value =
          employees.where((e) => !e.isCurrentlyAtWork).length;
    } else {
      totalEmployeesCount.value = employees.length;
      employeesAtWorkCount.value = 0;
      employeesNotAtWorkCount.value = 0;
    }

    filteredEmployees.value = employees;
  }

  void onDateFilterSelected(String value) {
    final now = DateTime.now();
    selectedFilterName.value = value;

    switch (value) {
      case 'today':
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        selectedDateRange.value = DateTimeRange(start: start, end: end);
        break;
      case 'this_week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        selectedDateRange.value = DateTimeRange(start: start, end: end);
        break;
      case 'this_month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        selectedDateRange.value = DateTimeRange(start: startOfMonth, end: end);
        break;
      case 'custom':
        _pickCustomDateRange();
        return;
    }
    fetchData();
  }

  void selectLocation(String location) {
    selectedLocation.value = location;
    fetchData();
  }

  void _pickCustomDateRange() async {
    final List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: Get.context!,
      startInitialDate: selectedDateRange.value.start,
      endInitialDate: selectedDateRange.value.end,
      startFirstDate: DateTime(selectedYear.value, 1, 1),
      startLastDate: DateTime(selectedYear.value, 12, 31),
      endFirstDate: DateTime(selectedYear.value, 1, 1),
      endLastDate: DateTime(selectedYear.value, 12, 31),
      is24HourMode: true,
      isShowSeconds: false,
      type: OmniDateTimePickerType.date,
    );

    if (dateTimeList != null && dateTimeList.length == 2) {
      final start = dateTimeList[0];
      final end = dateTimeList[1];
      final correctedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
      selectedDateRange.value = DateTimeRange(start: start, end: correctedEnd);
      selectedFilterName.value = 'custom';
      fetchData();
    }
  }

  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final Sheet sheet = excel[excel.getDefaultSheet()!];
      final range = selectedDateRange.value;

      final CellStyle mainHeaderStyle = CellStyle(
          bold: true, horizontalAlign: HorizontalAlign.Center, fontSize: 14);
      final CellStyle subHeaderStyle =
          CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
      final CellStyle boldStyle = CellStyle(bold: true);
      final CellStyle centerStyle =
          CellStyle(horizontalAlign: HorizontalAlign.Center);
      final CellStyle weekendStyle =
          CellStyle(backgroundColorHex: ExcelColor.fromHexString("#FFF0F0F0"));
      final CellStyle totalLabelStyle =
          CellStyle(bold: true, horizontalAlign: HorizontalAlign.Right);
      final CellStyle totalValueStyle =
          CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);

      sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('F1'));
      sheet.cell(CellIndex.indexByString('A1'))
        ..value = TextCellValue('attendance_control'.tr)
        ..cellStyle = mainHeaderStyle;

      final dateFormat = DateFormat('dd/MM/yyyy');
      sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('F2'));
      sheet.cell(CellIndex.indexByString('A2'))
        ..value = TextCellValue(
            '${dateFormat.format(range.start)} - ${dateFormat.format(range.end)}')
        ..cellStyle = subHeaderStyle;

      for (final employee in filteredEmployees) {
        sheet.appendRow([]);

        sheet.appendRow([
          TextCellValue('employee_name'.tr),
          TextCellValue(employee.name),
          TextCellValue(''),
          TextCellValue('employee_id'.tr),
          TextCellValue(employee.userId),
        ]);
        var rowIdx = sheet.maxRows - 1;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
            .cellStyle = boldStyle;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx))
            .cellStyle = boldStyle;

        final List<CellValue> header = [
          TextCellValue('date'.tr),
          TextCellValue('period'.tr),
          TextCellValue('arrival'.tr),
          TextCellValue('departure'.tr),
          TextCellValue('norm_hours'.tr),
          TextCellValue('actual_hours'.tr),
        ];
        sheet.appendRow(header);
        rowIdx = sheet.maxRows - 1;
        for (var colIdx = 0; colIdx < header.length; colIdx++) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: colIdx, rowIndex: rowIdx))
              .cellStyle = boldStyle;
        }

        final statusMap = {for (var s in employee.dailyStatuses) s.date: s};
        double totalActualHours = 0.0;

        for (var i = 0; i <= range.duration.inDays; i++) {
          final date = range.start.add(Duration(days: i));
          final status = statusMap[date];

          String checkIn = "-", checkOut = "-", actualHours = "0";
          String validHours = (date.weekday == DateTime.saturday ||
                  date.weekday == DateTime.sunday)
              ? '5'
              : '8';

          if (status != null && status.type == DailyStatusType.present) {
            if (status.arrivalTime != null) {
              checkIn = DateFormat('HH:mm').format(status.arrivalTime!);
            }
            if (status.departureTime != null) {
              checkOut = DateFormat('HH:mm').format(status.departureTime!);
            }
            final duration = status.workDuration;
            if (duration != null && duration.inMinutes > 0) {
              actualHours = (duration.inMinutes / 60.0).toStringAsFixed(2);
            }
          }

          totalActualHours += double.tryParse(actualHours) ?? 0.0;

          sheet.appendRow([
            TextCellValue(DateFormat('dd/MM/yyyy').format(date)),
            TextCellValue('9.00'),
            TextCellValue(checkIn),
            TextCellValue(checkOut),
            TextCellValue(validHours),
            TextCellValue(actualHours),
          ]);

          final newRowIndex = sheet.maxRows - 1;
          if (date.weekday == DateTime.saturday ||
              date.weekday == DateTime.sunday) {
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 0, rowIndex: newRowIndex))
                .cellStyle = weekendStyle;
          }
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 2, rowIndex: newRowIndex))
              .cellStyle = centerStyle;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 3, rowIndex: newRowIndex))
              .cellStyle = centerStyle;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 4, rowIndex: newRowIndex))
              .cellStyle = centerStyle;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 5, rowIndex: newRowIndex))
              .cellStyle = centerStyle;
        }

        sheet.appendRow([
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue('total_worked_hours'.tr),
          TextCellValue(totalActualHours.toStringAsFixed(2)),
        ]);
        final totalRowIndex = sheet.maxRows - 1;
        sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRowIndex),
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: totalRowIndex),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: totalRowIndex))
            .cellStyle = totalLabelStyle;
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 5, rowIndex: totalRowIndex))
            .cellStyle = totalValueStyle;
      }

      for (var i = 0; i < 6; i++) {
        sheet.setColumnAutoFit(i);
      }

      final fileBytes = excel.save();
      if (fileBytes != null) {
        await FileSaver.instance.saveFile(
          name:
              'Attendance_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
          bytes: Uint8List.fromList(fileBytes),
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );
        Get.snackbar('success'.tr, 'report_generated_successfully'.tr);
      } else {
        throw Exception('excel_file_generation_failed'.tr);
      }
    } catch (e) {
      Get.snackbar('error_title'.tr, 'report_generation_failed_error'.tr);
    }
  }
}
