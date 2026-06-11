class OrderDetailModel {
  final int id;
  final int storeId;
  final int customerId;
  final String totalPrice;
  final String status;
  final String estimatedCompletion;
  final String createdAt;
  final String customerName;
  final String phoneNumber;
  final List<OrderDetailItem> items;

  OrderDetailModel({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.totalPrice,
    required this.status,
    required this.estimatedCompletion,
    required this.createdAt,
    required this.customerName,
    required this.phoneNumber,
    required this.items,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List? ?? [];
    return OrderDetailModel(
      id: json['id'] as int? ?? 0,
      storeId: json['store_id'] as int? ?? 0,
      customerId: json['customer_id'] as int? ?? 0,
      totalPrice: json['total_price'] as String? ?? '0',
      status: json['status'] as String? ?? '',
      estimatedCompletion: json['estimated_completion'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      items: list.map((item) => OrderDetailItem.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class OrderDetailItem {
  final int id;
  final int orderId;
  final int serviceId;
  final int quantity;
  final String price;
  final List<String> imageUrls;
  final String? aiStatus;
  final Map<String, dynamic>? aiReport;
  final String serviceName;

  OrderDetailItem({
    required this.id,
    required this.orderId,
    required this.serviceId,
    required this.quantity,
    required this.price,
    required this.imageUrls,
    this.aiStatus,
    this.aiReport,
    required this.serviceName,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    final urls = json['image_urls'] as List? ?? [];
    return OrderDetailItem(
      id: json['id'] as int? ?? 0,
      orderId: json['order_id'] as int? ?? 0,
      serviceId: json['service_id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      price: json['price'] as String? ?? '0',
      imageUrls: urls.map((e) => e.toString()).toList(),
      aiStatus: json['ai_status'] as String?,
      aiReport: json['ai_report'] as Map<String, dynamic>?,
      serviceName: json['service_name'] as String? ?? '',
    );
  }

  /// Extracts unique damage categories from the AI report
  List<String> getDamageTags() {
    if (aiReport == null) return [];
    try {
      final results = aiReport!['results'] as List? ?? [];
      final List<String> tags = [];
      for (final res in results) {
        final details = res['damage_details'] as List? ?? [];
        for (final detail in details) {
          final cat = detail['kategori_kerusakan'] as String?;
          if (cat != null && cat.isNotEmpty) {
            tags.add(cat);
          }
        }
      }
      return tags.toSet().toList();
    } catch (_) {
      return [];
    }
  }
}
