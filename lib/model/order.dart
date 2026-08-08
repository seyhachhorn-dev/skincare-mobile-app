class Order {
  final String orderNumber;
  final String date;
  final int itemCount;
  final int total;
  final String status;

  Order({
    required this.orderNumber,
    required this.date,
    required this.itemCount,
    required this.total,
    required this.status,
  });
}
