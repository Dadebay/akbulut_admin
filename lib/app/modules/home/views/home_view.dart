import 'package:akbulut_admin/app/product/constants/color_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController()); // Controller'ı başlat

    return Scaffold(
      backgroundColor: const Color(0xfff2f5fc),
      body: Obx(() {
        // --- SİZİN YÜKLENİYOR KONTROLÜNÜZ ---
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // Veri yüklendikten sonra yeni tasarım gösterilir
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(), // Üst Bar (Yeni Tasarım)
              const SizedBox(height: 24),
              const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildMergedSummaryCards(), // Sizin ve yeni tasarımın verilerini birleştiren kartlar
              const SizedBox(height: 24),
              _buildSalesChart(), // Yeni tasarımdaki Line Chart
              const SizedBox(height: 24),
              // --- SİZİN OLUŞTURDUĞUNUZ GRAFİK WIDGET'I ---
              const Text('Attendance Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildYourCharts(), // Sizin BarChart'ınız
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, {bool isSelected = false}) {
    return Container(
      color: isSelected ? ColorConstants.kPrimaryColor2.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? ColorConstants.kPrimaryColor : ColorConstants.greyColor),
        title: Text(title, style: TextStyle(color: isSelected ? ColorConstants.kPrimaryColor : ColorConstants.blackColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        onTap: () {},
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: ColorConstants.whiteColor, borderRadius: BorderRadius.circular(12)),
            child: const TextField(decoration: InputDecoration(icon: Icon(Icons.search), hintText: 'Search here', border: InputBorder.none)),
          ),
        ),
        const SizedBox(width: 20),
        IconButton(onPressed: () {}, icon: const Icon(IconlyLight.notification, color: ColorConstants.greyColor)),
        IconButton(onPressed: () {}, icon: const Icon(IconlyLight.chat, color: ColorConstants.greyColor)),
        const SizedBox(width: 20),
        const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3')),
        const SizedBox(width: 8),
        const Text('Admin User'),
      ],
    );
  }

  // --- KARTLAR BİRLEŞTİRİLDİ ---
  Widget _buildMergedSummaryCards() {
    return Row(
      children: [
        // Sizin dinamik verinizi kullanan kart
        Expanded(
          child: _buildSummaryCard(
            title: 'total_employees'.tr,
            value: controller.totalEmployees.value.toString(),
            change: controller.userChange.value,
            changeText: controller.userChangeText.value,
            icon: IconlyBold.user2,
            iconBgColor: Colors.blue.shade100,
            iconColor: Colors.blue.shade800,
            isIncrease: true,
          ),
        ),
        const SizedBox(width: 16),
        // Sizin dinamik verinizi kullanan kart
        Expanded(
          child: _buildSummaryCard(
            title: 'at_work'.tr,
            value: controller.employeesAtWork.value.toString(),
            change: controller.orderChange.value,
            changeText: controller.orderChangeText.value,
            icon: IconlyBold.buy,
            iconBgColor: Colors.orange.shade100,
            iconColor: Colors.orange.shade800,
            isIncrease: true,
          ),
        ),
        const SizedBox(width: 16),
        // Tasarımdaki statik kart
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Sales',
            value: controller.totalSales.value,
            change: controller.salesChange.value,
            changeText: controller.salesChangeText.value,
            icon: Icons.bar_chart,
            iconBgColor: Colors.green.shade100,
            iconColor: Colors.green.shade800,
            isIncrease: false,
          ),
        ),
        const SizedBox(width: 16),
        // Sizin dinamik verinizi kullanan kart
        Expanded(
          child: _buildSummaryCard(
            title: 'not_at_work'.tr,
            value: (controller.totalEmployees.value - controller.employeesAtWork.value).toString(),
            change: controller.pendingChange.value,
            changeText: controller.pendingChangeText.value,
            icon: IconlyBold.timeCircle,
            iconBgColor: Colors.purple.shade100,
            iconColor: Colors.purple.shade800,
            isIncrease: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String change,
    required String changeText,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isIncrease,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: ColorConstants.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: const TextStyle(color: ColorConstants.greyColor, fontSize: 16)),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor)),
            ]),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(isIncrease ? Icons.arrow_upward : Icons.arrow_downward, color: isIncrease ? ColorConstants.greenColor : ColorConstants.redColor, size: 16),
              const SizedBox(width: 4),
              Text(change, style: TextStyle(color: isIncrease ? ColorConstants.greenColor : ColorConstants.redColor, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(changeText, style: const TextStyle(color: ColorConstants.greyColor)),
            ]),
          ],
        ),
      ),
    );
  }

  // Yeni Tasarımdaki Grafik
  Widget _buildSalesChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: ColorConstants.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Sales Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: ColorConstants.greyColor.withOpacity(0.5)), borderRadius: BorderRadius.circular(8)),
                child: DropdownButton<String>(
                  value: 'October',
                  underline: const SizedBox(),
                  icon: const Icon(IconlyLight.arrowDown2),
                  items: ['October', 'November', 'December'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: (_) {},
                ),
              ),
            ]),
            const SizedBox(height: 30),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: ColorConstants.greyColor.withOpacity(0.2), strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => _leftTitleWidgets(v, m))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => _bottomTitleWidgets(v, m))),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.salesSpots,
                      isCurved: true,
                      color: ColorConstants.kPrimaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                              colors: [ColorConstants.kPrimaryColor2.withOpacity(0.3), ColorConstants.kPrimaryColor2.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SİZİN GRAFİK WIDGET'INIZ BURAYA TAŞINDI ---
  Widget _buildYourCharts() {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: controller.totalEmployees.value.toDouble(),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: controller.employeesAtWork.value.toDouble(), color: Colors.green.shade600, width: 25)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: (controller.totalEmployees.value - controller.employeesAtWork.value).toDouble(), color: Colors.red.shade600, width: 25)]),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String text = '';
                          switch (value.toInt()) {
                            case 0:
                              text = 'at_work'.tr;
                              break;
                            case 1:
                              text = 'not_at_work'.tr;
                              break;
                          }
                          return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
                        })),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Grafik eksenleri için yardımcı fonksiyonlar
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: ColorConstants.greyColor, fontWeight: FontWeight.bold, fontSize: 14);
    String text;
    switch (value.toInt()) {
      case 10:
        text = '10k';
        break;
      case 20:
        text = '20k';
        break;
      case 30:
        text = '30k';
        break;
      case 40:
        text = '40k';
        break;
      case 50:
        text = '50k';
        break;
      case 60:
        text = '60k';
        break;
      default:
        return Container();
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: ColorConstants.greyColor, fontWeight: FontWeight.bold, fontSize: 14);
    String text;
    switch (value.toInt()) {
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      default:
        return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
