class DashboardStats {
  String? plazaId;
  String? plazaName;
  int? totalBookings;
  int? cancelledBookings;
  int? reservedBookings;
  int? totalSlots;
  int? occupiedSlots;
  int? availableSlots;
  int? totalPlazas;
  String? frequency;

  DashboardStats({
    this.plazaId,
    this.plazaName,
    this.totalBookings,
    this.cancelledBookings,
    this.reservedBookings,
    this.totalSlots,
    this.occupiedSlots,
    this.availableSlots,
    this.totalPlazas,
    this.frequency,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    return DashboardStats(
      plazaId: json['plazaId'] as String?,
      plazaName: json['plazaName'] as String? ?? 'Unknown',
      totalBookings: tryParseInt(json['totalBookings']),
      cancelledBookings: tryParseInt(json['cancelledBookings']),
      reservedBookings: tryParseInt(json['reservedBookings']),
      totalSlots: tryParseInt(json['totalSlots']),
      occupiedSlots: tryParseInt(json['occupiedSlots']),
      availableSlots: tryParseInt(json['availableSlots']),
      totalPlazas: tryParseInt(json['totalPlazas']),
      frequency: json['frequency'] as String? ?? 'daily',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'plazaId': plazaId,
      'plazaName': plazaName,
      'totalBookings': totalBookings,
      'cancelledBookings': cancelledBookings,
      'reservedBookings': reservedBookings,
      'totalSlots': totalSlots,
      'occupiedSlots': occupiedSlots,
      'availableSlots': availableSlots,
      'totalPlazas': totalPlazas,
      'frequency': frequency,
    };
    return json;
  }

  static const List<String> validFrequencies = ['daily', 'weekly', 'monthly', 'quarterly'];

  String? validate() {
    if (plazaId != null && plazaId!.isEmpty) {
      return 'Plaza ID cannot be empty if provided.';
    }
    if (plazaName == null || plazaName!.isEmpty || plazaName == 'Unknown') {
      return 'Plaza name cannot be empty.';
    }
    if (frequency != null && !validFrequencies.contains(frequency!.toLowerCase())) {
      return 'Invalid frequency. Must be one of: ${validFrequencies.join(", ")}';
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStats &&
        other.plazaId == plazaId &&
        other.plazaName == plazaName &&
        other.totalBookings == totalBookings &&
        other.cancelledBookings == cancelledBookings &&
        other.reservedBookings == reservedBookings &&
        other.totalSlots == totalSlots &&
        other.occupiedSlots == occupiedSlots &&
        other.availableSlots == availableSlots &&
        other.totalPlazas == totalPlazas &&
        other.frequency == frequency;
  }

  @override
  int get hashCode => Object.hash(
    plazaId,
    plazaName,
    totalBookings,
    cancelledBookings,
    reservedBookings,
    totalSlots,
    occupiedSlots,
    availableSlots,
    totalPlazas,
    frequency,
  );

  @override
  String toString() {
    return 'DashboardStats(plazaId: $plazaId, plazaName: $plazaName, totalBookings: $totalBookings, cancelledBookings: $cancelledBookings, reservedBookings: $reservedBookings, totalSlots: $totalSlots, occupiedSlots: $occupiedSlots, availableSlots: $availableSlots, totalPlazas: $totalPlazas, frequency: $frequency)';
  }
}