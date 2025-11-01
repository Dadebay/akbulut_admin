import 'package:akbulut_admin/app/modules/sales/controller/sales_controller.dart';
import 'package:akbulut_admin/app/product/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

class SalesView extends StatelessWidget {
  final SalesController controller = Get.put(SalesController());

  SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.greyColorwithOpacity,
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildOrderListSection(),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Text(
        'sales_view'.tr,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: ColorConstants.blackColor),
      ),
      shadowColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      backgroundColor: ColorConstants.kPrimaryColor2.withOpacity(0.05),
      elevation: 0,
      actions: [
        ElevatedButton.icon(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedAddCircle, size: 18, color: Colors.black),
          label: Text('Create New Order'.tr, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.white,
            overlayColor: Colors.white,
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
          ),
        ),
        SizedBox(width: 10)
      ],
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      childAspectRatio: 3.4,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          title: 'total_orders_today'.tr,
          value: '300',
          percentage: '+29',
          percentageColor: Color(0xFF00C853),
          chartColor: Color(0xFF00C853),
        ),
        _buildSummaryCard(
          title: 'order_completed'.tr,
          value: '200',
          percentage: '+30',
          percentageColor: Color(0xFF00C853),
          chartColor: Color(0xFF00C853),
        ),
        _buildSummaryCard(
          title: 'pending_orders'.tr,
          value: '75',
          percentage: '+15',
          percentageColor: Color(0xFF00C853),
          chartColor: Color(0xFF00C853),
        ),
        _buildSummaryCard(
          title: 'cancel_orders'.tr,
          value: '25',
          percentage: '-10',
          percentageColor: Color(0xFFDD2C00),
          chartColor: Color(0xFFDD2C00),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String percentage,
    required Color percentageColor,
    required Color chartColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ColorConstants.greyColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.blackColor,
                  ),
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: percentageColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterAndSearch(),
          const SizedBox(height: 20),
          _buildOrderTable(),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Row(
            children: [
              _buildFilterButton('${'total'.tr} (${controller.orders.length})', null, isSelected: controller.selectedFilter.value == null),
              _buildFilterButton('${'completed'.tr} (${controller.orders.where((o) => o.status == OrderStatus.completed).length})', OrderStatus.completed,
                  isSelected: controller.selectedFilter.value == OrderStatus.completed),
              _buildFilterButton('${'pending'.tr} (${controller.orders.where((o) => o.status == OrderStatus.pending).length})', OrderStatus.pending,
                  isSelected: controller.selectedFilter.value == OrderStatus.pending),
              _buildFilterButton('${'cancelled'.tr} (${controller.orders.where((o) => o.status == OrderStatus.canceled).length})', OrderStatus.canceled,
                  isSelected: controller.selectedFilter.value == OrderStatus.canceled),
            ],
          ),
        ),
        SizedBox(
          width: 300,
          child: TextField(
            onChanged: (value) => controller.searchOrders(value),
            style: const TextStyle(fontFamily: 'Gilroy', fontSize: 15),
            decoration: InputDecoration(
              hintText: 'search'.tr,
              hintStyle: const TextStyle(color: ColorConstants.greyColor, fontFamily: 'Gilroy', fontWeight: FontWeight.w500),
              prefixIcon: const Icon(IconlyLight.search, color: ColorConstants.greyColor, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(IconlyLight.calendar, color: ColorConstants.greyColor, size: 20),
                onPressed: () {},
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: ColorConstants.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: ColorConstants.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorConstants.kPrimaryColor2.withOpacity(0.6), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String text, OrderStatus? status, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: TextButton(
        onPressed: () => controller.filterOrders(status),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? ColorConstants.kPrimaryColor2 : ColorConstants.greyColorwithOpacity,
          foregroundColor: isSelected ? Colors.white : ColorConstants.greyColor,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTable() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(0.8),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: ColorConstants.lightGrey)),
                ),
                children: [
                  _buildTableHeader('order_id'.tr),
                  _buildTableHeader('customer'.tr),
                  _buildTableHeader('status'.tr),
                  _buildTableHeader('total_amount'.tr),
                  _buildTableHeader('date'.tr),
                  _buildTableHeader('actions'.tr),
                ],
              ),
              ...controller.filteredOrders.map((order) {
                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: ColorConstants.lightGrey)),
                  ),
                  children: [
                    _buildTableCell(Text(order.id, style: _tableTextStyle)),
                    _buildTableCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage(order.customerImageUrl),
                            backgroundColor: ColorConstants.lightGrey,
                          ),
                          const SizedBox(width: 10),
                          Text(order.customerName, style: _tableTextStyle),
                        ],
                      ),
                    ),
                    _buildTableCell(_buildStatusChip(order.status)),
                    _buildTableCell(Text('\$${order.totalAmount.toStringAsFixed(2)}', style: _tableTextStyle)),
                    _buildTableCell(Text(order.date, style: _tableTextStyle)),
                    _buildTableCell(
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          print('Selected action for ${order.id}: $value');
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'view',
                            height: 40,
                            child: Row(
                              children: [
                                Icon(IconlyLight.document, size: 20, color: ColorConstants.greyColor),
                                SizedBox(width: 10),
                                Text('view_order_details'.tr, style: _popupMenuItemTextStyle),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'invoice',
                            height: 40,
                            child: Row(
                              children: [
                                Icon(IconlyLight.send, size: 20, color: ColorConstants.greyColor),
                                SizedBox(width: 10),
                                Text('send_invoice'.tr, style: _popupMenuItemTextStyle),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            height: 40,
                            child: Row(
                              children: [
                                Icon(IconlyLight.delete, size: 20, color: ColorConstants.redColor),
                                SizedBox(width: 10),
                                Text('delete_client_profile'.tr, style: _popupMenuRedTextStyle),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(IconlyLight.moreSquare, color: ColorConstants.greyColor, size: 22),
                        offset: const Offset(0, 40),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: ColorConstants.greyColor,
        ),
      ),
    );
  }

  Widget _buildTableCell(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  static const TextStyle _tableTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: ColorConstants.blackColor,
  );

  static const TextStyle _popupMenuItemTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: ColorConstants.blackColor,
  );

  static const TextStyle _popupMenuRedTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: ColorConstants.redColor,
  );

  Widget _buildStatusChip(OrderStatus status) {
    Color chipBackgroundColor;
    Color chipTextColor;
    String text;

    switch (status) {
      case OrderStatus.completed:
        chipBackgroundColor = ColorConstants.greenColorwithOpacity2;
        chipTextColor = ColorConstants.greenColor;
        text = 'completed'.tr;
        break;
      case OrderStatus.pending:
        chipBackgroundColor = ColorConstants.yellowColorwithOpacity.withOpacity(0.2);
        chipTextColor = const Color(0xFFFFA500);
        text = 'pending'.tr;
        break;
      case OrderStatus.canceled:
        chipBackgroundColor = ColorConstants.redColorwithOpacity;
        chipTextColor = ColorConstants.redColor;
        text = 'cancelled'.tr;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Gilroy',
          color: chipTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
