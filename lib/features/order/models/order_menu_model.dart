class MenuCategoryModel {
  final int categoryId;
  final String categoryName;
  final List<ServiceModel> services;

  const MenuCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.services,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    final servicesList = json['services'] as List? ?? [];
    return MenuCategoryModel(
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      services: servicesList
          .map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceModel {
  final int serviceId;
  final String serviceName;
  final String description;
  final int price;
  final String unit;
  final int durationHours;

  const ServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.description,
    required this.price,
    required this.unit,
    required this.durationHours,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['service_id'] as int,
      serviceName: json['service_name'] as String,
      description: json['description'] as String? ?? '',
      price: json['price'] as int,
      unit: json['unit'] as String? ?? 'kg',
      durationHours: json['duration_hours'] as int? ?? 0,
    );
  }
}
