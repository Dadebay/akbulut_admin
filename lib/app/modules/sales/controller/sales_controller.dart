import 'package:get/get.dart';

class SalesController extends GetxController {
  final orders = <Order>[
    Order(
        id: '#5678',
        customerName: 'Jerome Bell',
        status: OrderStatus.completed,
        totalAmount: 320.00,
        date: '01 Mar 2025',
        customerImageUrl: 'assets/image/avatar_jerome.png'), // Örnek resim yolu
    Order(
        id: '#5679',
        customerName: 'Bessie Cooper',
        status: OrderStatus.completed,
        totalAmount: 440.00,
        date: '01 Mar 2025',
        customerImageUrl: 'assets/image/avatar_bessie.png'),
    Order(
        id: '#5680',
        customerName: 'Darrell Steward',
        status: OrderStatus.canceled,
        totalAmount: 220.00,
        date: '02 Mar 2025',
        customerImageUrl: 'assets/image/avatar_darrell.png'),
    Order(
        id: '#5681',
        customerName: 'Cameron Williamson',
        status: OrderStatus.pending,
        totalAmount: 810.00,
        date: '03 Mar 2025',
        customerImageUrl: 'assets/image/avatar_cameron.png'),
    Order(
        id: '#5682',
        customerName: 'Floyd Miles',
        status: OrderStatus.canceled,
        totalAmount: 600.00,
        date: '04 Mar 2025',
        customerImageUrl: 'assets/image/avatar_floyd.png'),
    Order(
        id: '#5683',
        customerName: 'Esther Howard',
        status: OrderStatus.pending,
        totalAmount: 360.00,
        date: '04 Mar 2025',
        customerImageUrl: 'assets/image/avatar_esther.png'),
    Order(
        id: '#5684',
        customerName: 'Leslie Alexander',
        status: OrderStatus.pending,
        totalAmount: 420.00,
        date: '05 Mar 2025',
        customerImageUrl: 'assets/image/avatar_leslie.png'),
    Order(
        id: '#5685',
        customerName: 'Arlene McCoy',
        status: OrderStatus.completed,
        totalAmount: 115.00,
        date: '06 Mar 2025',
        customerImageUrl: 'assets/image/avatar_arlene.png'),
    Order(
        id: '#5686',
        customerName: 'Darlene Robertson',
        status: OrderStatus.completed,
        totalAmount: 720.00,
        date: '07 Mar 2025',
        customerImageUrl: 'assets/image/avatar_darlene.png'),
  ].obs;

  var filteredOrders = <Order>[].obs;
  var selectedFilter = Rxn<OrderStatus>(); // Seçili filtreyi tutmak için

  @override
  void onInit() {
    super.onInit();
    filteredOrders.assignAll(orders);
  }

  void filterOrders(OrderStatus? status) {
    selectedFilter.value = status; // Seçili filtreyi güncelle
    if (status == null) {
      filteredOrders.assignAll(orders);
    } else {
      filteredOrders.assignAll(
          orders.where((order) => order.status == status).toList());
    }
  }

  void searchOrders(String query) {
    if (query.isEmpty) {
      filteredOrders.assignAll(orders);
    } else {
      filteredOrders.assignAll(orders
          .where((order) =>
              order.customerName.toLowerCase().contains(query.toLowerCase()) ||
              order.id.toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
  }
}

enum OrderStatus { completed, pending, canceled }

class Order {
  final String id;
  final String customerName;
  final OrderStatus status;
  final double totalAmount;
  final String date;
  final String customerImageUrl; // Müşteri resmi için eklendi

  Order({
    required this.id,
    required this.customerName,
    required this.status,
    required this.totalAmount,
    required this.date,
    required this.customerImageUrl,
  });
}