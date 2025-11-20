import 'package:akbulut_admin/app/data/models/daily_status.dart';
import 'package:akbulut_admin/app/data/models/employee.dart';
import 'package:akbulut_admin/app/modules/attendance_view/controllers/attendance_controller.dart';
import 'package:akbulut_admin/app/modules/attendance_view/views/attendance_chart_view.dart';
import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:akbulut_admin/app/product/widgets/search_widget.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final AttendanceController controller = Get.put(AttendanceController());
  @override
  void initState() {
    super.initState();
    controller.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'attendance_control'.tr,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: ColorConstants.kPrimaryColor),
        ),
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        backgroundColor: ColorConstants.kPrimaryColor2.withOpacity(0.05),
        elevation: 0,
        actions: [
          _buildDateFilterMenu(),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(HugeIcons.strokeRoundedChart02, size: 18),
            label: Text(
              'view_graph'.tr,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ), // Assuming 'view_graph' is a translation key
            onPressed: () {
              final isSingleDay =
                  controller.selectedDateRange.value.duration.inDays == 0;
              Get.to(() => AttendanceChartView(
                    employees: controller.filteredEmployees,
                    isSingleDay: isSingleDay,
                  ));
            },
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
              backgroundColor: ColorConstants.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(HugeIcons.strokeRoundedDoc02, size: 18),
            label: Text(
              'export_to_excel'.tr,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onPressed: () {
              controller.exportToExcel();
            },
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          SearchWidget(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            onClear: () {
              controller.onSearchChanged('');
              controller.searchController.clear();
            },
          ),
          _buildLocationFilter(),
          Expanded(child: _buildEmployeeList()),
          _buildStatistics()
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.black26,
      )),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                'total_employees'.tr,
                controller.totalEmployeesCount.value.toString(),
                Colors.blue.shade800),
            _buildStatItem(
                'at_work'.tr,
                controller.employeesAtWorkCount.value.toString(),
                Colors.green.shade800),
            _buildStatItem(
                'not_at_work'.tr,
                controller.employeesNotAtWorkCount.value.toString(),
                Colors.red.shade800),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    final locations = [
      {'id': 'dostluk_akbulut', 'name': 'Dostluk Akbulut'},
      {'id': 'dostluk_tm_gips', 'name': 'Dostluk TM - Gips'},
      {'id': 'merkez', 'name': 'Merkez'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16.0 : 4.0, right: 4.0),
            child: Obx(() {
              final isSelected =
                  controller.selectedLocation.value == location['id'];

              return ChoiceChip(
                label: Text(location['name']!),
                selected: isSelected,
                onSelected: (_) => controller.selectLocation(location['id']!),
                selectedColor: ColorConstants.kPrimaryColor2,
                backgroundColor: ColorConstants.whiteColor,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                labelStyle: TextStyle(
                  color: isSelected
                      ? ColorConstants.whiteColor
                      : ColorConstants.greyColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : ColorConstants.greyColor.withOpacity(0.4),
                  width: 1.5,
                ),
                showCheckmark: false,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildDateFilterMenu() {
    return Obx(() {
      String text;
      final filter = controller.selectedFilterName.value;
      if (filter == 'custom') {
        final range = controller.selectedDateRange.value;
        text =
            "${DateFormat('dd/MM').format(range.start)} - ${DateFormat('dd/MM/yy').format(range.end)}";
      } else {
        text = filter.tr;
      }

      return PopupMenuButton<String>(
        onSelected: controller.onDateFilterSelected,
        tooltip: 'select_period'.tr,
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: Colors.black87),
            ],
          ),
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
              value: 'today',
              child: Text('today'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          PopupMenuItem<String>(
              value: 'this_week',
              child: Text('this_week'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          PopupMenuItem<String>(
              value: 'this_month',
              child: Text('this_month'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          PopupMenuItem<String>(
              value: 'custom',
              child: Text('custom_range'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      );
    });
  }

  Widget _buildEmployeeList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredEmployees.isEmpty) {
        return Center(child: Text('no_records_found'.tr));
      }

      final isSingleDay =
          controller.selectedDateRange.value.duration.inDays == 0;

      return ListView.builder(
        itemCount: controller.filteredEmployees.length,
        itemBuilder: (context, index) {
          final employee = controller.filteredEmployees[index];
          if (isSingleDay) {
            return _buildSingleDayCard(employee);
          } else {
            return _buildMultiDayCard(context, employee);
          }
        },
      );
    });
  }

  Widget _buildSingleDayCard(Employee employee) {
    final status = employee.dailyStatuses.first;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 0,
      color: Colors.white54.withOpacity(0.05),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: ColorConstants.kPrimaryColor2.withOpacity(0.1))),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
          backgroundImage: employee.imageUrl != null
              ? NetworkImage(employee.imageUrl!)
              : null,
          child: employee.imageUrl == null
              ? Icon(HugeIcons.strokeRoundedUser03, color: Colors.black)
              : null,
        ),
        title: Row(
          children: [
            Text(employee.name.toTitleCase(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (controller.shouldShowLiveStatus)
              employee.isCurrentlyAtWork
                  ? _buildAtWorkIndicator()
                  : _buildNotAtWorkIndicator(),
          ],
        ),
        subtitle: _getStatusWidget(status),
      ),
    );
  }

  Widget _buildMultiDayCard(BuildContext context, Employee employee) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 0,
      color: Colors.white54.withOpacity(0.05),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: ColorConstants.kPrimaryColor2.withOpacity(0.1))),
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
            backgroundImage: employee.imageUrl != null
                ? NetworkImage(employee.imageUrl!)
                : null,
            child: employee.imageUrl == null
                ? Icon(HugeIcons.strokeRoundedUser03, color: Colors.black)
                : null,
          ),
          title: Row(
            children: [
              Text(employee.name.toTitleCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              if (controller.shouldShowLiveStatus) ...[
                employee.isCurrentlyAtWork
                    ? _buildAtWorkIndicator()
                    : _buildNotAtWorkIndicator(),
                const SizedBox(width: 8),
              ],
              _buildSuccessRateIndicator(employee.successRate),
            ],
          ),
          subtitle: Text(
              "ID: ${employee.userId} | ${'total_work_duration'.tr}: ${employee.totalWorkDuration.inHours}h ${employee.totalWorkDuration.inMinutes.remainder(60)}m"),
          children: employee.dailyStatuses.map((status) {
            var locale = Get.locale?.languageCode;
            if (locale == 'tk') {
              locale = 'ru';
            }
            return ListTile(
              title: Text(
                DateFormat('dd/MM/yyyy (EEEE)', locale).format(status.date),
                style: TextStyle(
                    color: status.isWeekend
                        ? Colors.purple.shade700
                        : Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
              trailing: _getStatusWidget(status),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAtWorkIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.green.shade700, size: 8),
          const SizedBox(width: 4),
          Text(
            'at_work'.tr, // Add this key to your translation files
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotAtWorkIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: 8),
          const SizedBox(width: 4),
          Text(
            'not_at_work'.tr, // Add this key to your translation files
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateIndicator(double rate) {
    Color color;
    if (rate >= 95) {
      color = Colors.blue.shade700;
    } else if (rate >= 80) {
      color = Colors.orange.shade700;
    } else {
      color = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(HugeIcons.strokeRoundedAward04, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            '${rate.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusWidget(DailyStatus status) {
    String text;
    Color color;
    FontWeight fontWeight = FontWeight.normal;

    switch (status.type) {
      case DailyStatusType.present:
        final duration = status.workDuration;
        String durationText = '';
        if (duration != null) {
          final hours = duration.inHours;
          final minutes = duration.inMinutes.remainder(60);
          durationText = ' (${hours}h ${minutes}m)';
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final isToday = status.date.year == today.year &&
            status.date.month == today.month &&
            status.date.day == today.day;

        String departureText;
        if (status.departureTime != null) {
          departureText = DateFormat('HH:mm').format(status.departureTime!);
        } else {
          if (isToday) {
            departureText = "-";
          } else {
            if (status.date.weekday >= 1 && status.date.weekday <= 5) {
              // Weekday
              departureText = "18:00";
            } else {
              // Weekend
              departureText = "13:00";
            }
          }
        }

        text =
            '${'arrival'.tr}: ${DateFormat('HH:mm').format(status.arrivalTime!)} - ${'departure'.tr}: $departureText$durationText';
        color = Colors.green.shade800;
        break;
      case DailyStatusType.absent:
        text = 'absent'.tr;
        color = Colors.red.shade700;
        fontWeight = FontWeight.bold;
        break;
      case DailyStatusType.weekend:
        text = 'weekend'.tr;
        color = Colors.grey.shade600;
        fontWeight = FontWeight.bold;
        break;
    }
    return Text(text,
        style: TextStyle(color: color, fontWeight: fontWeight, fontSize: 12));
  }
}
