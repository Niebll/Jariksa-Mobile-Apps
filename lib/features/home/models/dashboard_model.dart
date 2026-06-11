/// Model data untuk response API /dashboard.
class DashboardModel {
  final IncomeModel income;
  final OperationalStatusModel operationalStatus;
  final LateOrdersModel lateOrders;
  final List<RecentActivityModel> recentActivities;

  DashboardModel({
    required this.income,
    required this.operationalStatus,
    required this.lateOrders,
    required this.recentActivities,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      income: IncomeModel.fromJson(json['income'] ?? {}),
      operationalStatus: OperationalStatusModel.fromJson(json['operational_status'] ?? {}),
      lateOrders: LateOrdersModel.fromJson(json['late_orders'] ?? {}),
      recentActivities: (json['recent_activities'] as List?)
              ?.map((e) => RecentActivityModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class IncomeModel {
  final int today;
  final int trendPercentage;
  final bool isUp;

  IncomeModel({
    required this.today,
    required this.trendPercentage,
    required this.isUp,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      today: json['today'] ?? 0,
      trendPercentage: json['trend_percentage'] ?? 0,
      isUp: json['is_up'] ?? true,
    );
  }
}

class OperationalStatusModel {
  final int masuk;
  final int diproses;
  final int selesai;

  OperationalStatusModel({
    required this.masuk,
    required this.diproses,
    required this.selesai,
  });

  factory OperationalStatusModel.fromJson(Map<String, dynamic> json) {
    return OperationalStatusModel(
      masuk: json['masuk'] ?? 0,
      diproses: json['diproses'] ?? 0,
      selesai: json['selesai'] ?? 0,
    );
  }
}

class LateOrdersModel {
  final int count;
  final bool hasLate;
  final String message;

  LateOrdersModel({
    required this.count,
    required this.hasLate,
    required this.message,
  });

  factory LateOrdersModel.fromJson(Map<String, dynamic> json) {
    return LateOrdersModel(
      count: json['count'] ?? 0,
      hasLate: json['has_late'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class RecentActivityModel {
  final int id;
  final String status;
  final String createdAt;
  final String customerName;
  final String mainService;

  RecentActivityModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.mainService,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      customerName: json['customer_name'] ?? '',
      mainService: json['main_service'] ?? '',
    );
  }
}
