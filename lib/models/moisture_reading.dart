class MoistureReading {
  const MoistureReading({
    required this.soilStatus,
    this.recommendationOverride,
  });

  final String soilStatus;
  final String? recommendationOverride;

  String get statusLabel {
    final normalized = soilStatus.trim().toUpperCase().replaceAll(' ', '_');
    if (normalized == 'DRY') {
      return 'DRY';
    }
    if (normalized == 'NOT_DRY' || normalized == 'OK') {
      return 'NOT_DRY';
    }
    return 'NOT_DRY';
  }

  String get displayStatus =>
      statusLabel == 'NOT_DRY' ? 'NOT DRY' : statusLabel;

  String get recommendation {
    if (recommendationOverride != null && recommendationOverride!.isNotEmpty) {
      return recommendationOverride!;
    }
    return statusLabel == 'DRY'
        ? 'Soil is dry, irrigation is required.'
        : 'Soil moisture is sufficient.';
  }
}
