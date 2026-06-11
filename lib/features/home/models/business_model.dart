class BusinessModel {
  final int id;
  final String storeName;
  final String email;
  final String profilePicture;
  final String createdAt;
  final int totalOmzet;
  final int totalOrder;

  BusinessModel({
    required this.id,
    required this.storeName,
    required this.email,
    required this.profilePicture,
    required this.createdAt,
    required this.totalOmzet,
    required this.totalOrder,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as int? ?? 0,
      storeName: json['store_name'] as String? ?? 'Nama Toko',
      email: json['email'] as String? ?? '',
      profilePicture: json['profile_picture'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      totalOmzet: json['total_omzet'] as int? ?? 0,
      totalOrder: json['total_order'] as int? ?? 0,
    );
  }
}
