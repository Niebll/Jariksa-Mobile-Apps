class CustomerModel {
  final int id;
  final int storeId;
  final String name;
  final String phoneNumber;
  final String loyaltyStatus;
  final String createdAt;

  const CustomerModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.phoneNumber,
    required this.loyaltyStatus,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      loyaltyStatus: json['loyalty_status'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}
