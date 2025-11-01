import 'dart:math' show pi;

import 'package:akbulut_admin/app/data/models/employee.dart';
import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceChartView extends StatelessWidget {
  final List<Employee> employees;
  final bool isSingleDay; // Accept the flag

  const AttendanceChartView({
    super.key,
    required this.employees,
    required this.isSingleDay, // Require the flag
  });

  @override
  Widget build(BuildContext context) {
    final sortedEmployees = List<Employee>.from(employees);
    sortedEmployees.sort((a, b) => b.totalWorkDuration.compareTo(a.totalWorkDuration));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'work_hours_graph'.tr,
          style: TextStyle(fontWeight: FontWeight.bold, color: ColorConstants.kPrimaryColor),
        ),
        backgroundColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _calculateMaxY(sortedEmployees),
              barTouchData: _buildBarTouchData(sortedEmployees),
              titlesData: _buildTitlesData(sortedEmployees),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(sortedEmployees),
              gridData: FlGridData(
                show: true,
                checkToShowHorizontalLine: (value) => value % _calculateInterval(sortedEmployees) == 0,
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateMaxY(List<Employee> sortedEmployees) {
    if (sortedEmployees.isEmpty) return 0;
    final maxDuration = sortedEmployees.first.totalWorkDuration;
    return (maxDuration.inHours.toDouble() * 1.2).ceilToDouble();
  }

  double _calculateInterval(List<Employee> sortedEmployees) {
    final maxY = _calculateMaxY(sortedEmployees);
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    return 20;
  }

  BarTouchData _buildBarTouchData(List<Employee> employees) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => ColorConstants.kPrimaryColor2.withOpacity(0.1),
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final employee = employees[group.x.toInt()];
          final hours = rod.toY.toInt();
          final minutes = ((rod.toY - hours) * 60).round();
          final rate = employee.successRate.toStringAsFixed(1);

          return BarTooltipItem(
            '${employee.name}\n${hours}h ${minutes}m\nSuccess: ${rate}%', // Name added
            const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<Employee> sortedEmployees) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,

          reservedSize: 60, // Space for 2 lines
          getTitlesWidget: (double value, TitleMeta meta) {
            final index = value.toInt();
            if (index >= 0 && index < sortedEmployees.length) {
              final name = sortedEmployees[index].name; // Already Title Cased
              final parts = name.split(' ');
              final String formattedName;
              if (parts.length > 1) {
                formattedName = '${parts.first}\n${parts.skip(1).join(' ')}';
              } else {
                formattedName = name;
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 10.0,
                child: Transform.rotate(
                  angle: pi / 0.6,
                  child: Text(
                    formattedName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (double value, TitleMeta meta) {
            if (value == 0) return const Text('');
            return Text('${value.toInt()}h', style: const TextStyle(fontSize: 10));
          },
          interval: _calculateInterval(sortedEmployees),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  // Re-add the color logic
  Color _getColorForSuccessRate(double rate) {
    if (rate >= 95) return Colors.blue.shade600;
    if (rate >= 80) return Colors.green.shade600;
    return Colors.amber.shade700;
  }

  List<BarChartGroupData> _buildBarGroups(List<Employee> sortedEmployees) {
    return List.generate(sortedEmployees.length, (index) {
      final employee = sortedEmployees[index];
      final totalHours = employee.totalWorkDuration.inMinutes / 60.0;

      // Conditional color logic
      final Color barColor = isSingleDay ? ColorConstants.kPrimaryColor2 : _getColorForSuccessRate(employee.successRate);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalHours,
            color: barColor, // Use the determined color
            width: 16,
            // No border radius
          ),
        ],
      );
    });
  }
}
