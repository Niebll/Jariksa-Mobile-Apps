class InspectResultModel {
  final int scanId;
  final bool success;
  final List<InspectItemResult> results;

  InspectResultModel({
    required this.scanId,
    required this.success,
    required this.results,
  });

  factory InspectResultModel.fromJson(Map<String, dynamic> json) {
    final resultsList = json['results'] as List? ?? [];
    return InspectResultModel(
      scanId: json['scan_id'] as int? ?? 0,
      success: json['success'] as bool? ?? false,
      results: resultsList
          .map((r) => InspectItemResult.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InspectItemResult {
  final String originalName;
  final String publicUrl;
  final String itemStatus;
  final int totalDamagesDetected;
  final List<DamageDetail> damageDetails;
  final List<ContextLabel> contextLabels;

  InspectItemResult({
    required this.originalName,
    required this.publicUrl,
    required this.itemStatus,
    required this.totalDamagesDetected,
    required this.damageDetails,
    required this.contextLabels,
  });

  factory InspectItemResult.fromJson(Map<String, dynamic> json) {
    final damages = json['damage_details'] as List? ?? [];
    final contexts = json['context_labels'] as List? ?? [];
    return InspectItemResult(
      originalName: json['original_name'] as String? ?? '',
      publicUrl: json['public_url'] as String? ?? '',
      itemStatus: json['item_status'] as String? ?? 'SAFE',
      totalDamagesDetected: json['total_damages_detected'] as int? ?? 0,
      damageDetails: damages
          .map((d) => DamageDetail.fromJson(d as Map<String, dynamic>))
          .toList(),
      contextLabels: contexts
          .map((c) => ContextLabel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DamageDetail {
  final String label;
  final String confidence;
  final String kategoriKerusakan;

  DamageDetail({
    required this.label,
    required this.confidence,
    required this.kategoriKerusakan,
  });

  factory DamageDetail.fromJson(Map<String, dynamic> json) {
    return DamageDetail(
      label: json['label'] as String? ?? '',
      confidence: json['confidence'] as String? ?? '0%',
      kategoriKerusakan: json['kategori_kerusakan'] as String? ?? 'Kerusakan',
    );
  }
}

class ContextLabel {
  final String label;
  final String confidence;

  ContextLabel({
    required this.label,
    required this.confidence,
  });

  factory ContextLabel.fromJson(Map<String, dynamic> json) {
    return ContextLabel(
      label: json['label'] as String? ?? '',
      confidence: json['confidence'] as String? ?? '0%',
    );
  }
}
