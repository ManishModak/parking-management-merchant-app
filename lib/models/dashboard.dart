import 'package:flutter/foundation.dart' show listEquals;

class DashboardStats {
  final int? totalPlazas;
  final String? frequency;
  final int? totalParkingSlots;
  final int? occupiedSlots;
  final int? availableSlots;
  final int? totalBookings;
  final int? reservedBookings;
  final int? cancelledBookings;
  final int? noShowBookings;
  final double? percentageChange;
  final List<Plaza>? plazas;

  DashboardStats({
    this.totalPlazas,
    this.frequency,
    this.totalParkingSlots,
    this.occupiedSlots,
    this.availableSlots,
    this.totalBookings,
    this.reservedBookings,
    this.cancelledBookings,
    this.noShowBookings,
    this.percentageChange,
    this.plazas,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    final plazasJson = json['plazas'] as List<dynamic>? ?? json['data'] as List<dynamic>?;
    final totalStats = json['totalStats'] as Map<String, dynamic>?;

    return DashboardStats(
      totalPlazas: tryParseInt(json['totalPlazas']),
      frequency: json['frequency'] as String? ?? 'daily',
      totalParkingSlots: tryParseInt(json['totalParkingSlots']),
      occupiedSlots: tryParseInt(json['totalOccupiedSlots']),
      availableSlots: tryParseInt(json['totalAvailableSlots']),
      totalBookings: tryParseInt(totalStats?['totalBookings']),
      reservedBookings: tryParseInt(totalStats?['totalReserved']),
      cancelledBookings: tryParseInt(totalStats?['totalCancelled']),
      noShowBookings: tryParseInt(totalStats?['totalNoShow']),
      percentageChange: tryParseDouble(json['percentageChanges']?['totalBookings']),
      plazas: plazasJson?.map((p) => Plaza.fromJson(p as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPlazas': totalPlazas,
      'frequency': frequency,
      'totalParkingSlots': totalParkingSlots,
      'totalOccupiedSlots': occupiedSlots,
      'totalAvailableSlots': availableSlots,
      'totalBookings': totalBookings,
      'reservedBookings': reservedBookings,
      'cancelledBookings': cancelledBookings,
      'noShowBookings': noShowBookings,
      'percentageChange': percentageChange,
      'plazas': plazas?.map((p) => p.toJson()).toList(),
    };
  }

  static const List<String> validFrequencies = ['daily', 'weekly', 'monthly', 'quarterly'];

  String? validate() {
    if (frequency != null && !validFrequencies.contains(frequency!.toLowerCase())) {
      return 'Invalid frequency. Must be one of: ${validFrequencies.join(", ")}';
    }
    if (totalPlazas != null && totalPlazas! < 0) {
      return 'Total plazas cannot be negative.';
    }
    if (totalParkingSlots != null && totalParkingSlots! < 0) {
      return 'Total parking slots cannot be negative.';
    }
    if (occupiedSlots != null && occupiedSlots! < 0) {
      return 'Occupied slots cannot be negative.';
    }
    if (availableSlots != null && availableSlots! < 0) {
      return 'Available slots cannot be negative.';
    }
    if (totalBookings != null && totalBookings! < 0) {
      return 'Total bookings cannot be negative.';
    }
    if (reservedBookings != null && reservedBookings! < 0) {
      return 'Reserved bookings cannot be negative.';
    }
    if (cancelledBookings != null && cancelledBookings! < 0) {
      return 'Cancelled bookings cannot be negative.';
    }
    if (noShowBookings != null && noShowBookings! < 0) {
      return 'No-show bookings cannot be negative.';
    }
    if (totalParkingSlots != null && occupiedSlots != null && availableSlots != null) {
      final slotSum = occupiedSlots! + availableSlots!;
      if (slotSum != totalParkingSlots) {
        return 'Sum of occupied and available slots ($slotSum) does not match total slots ($totalParkingSlots).';
      }
    }
    if (totalBookings != null &&
        reservedBookings != null &&
        cancelledBookings != null &&
        noShowBookings != null) {
      final sum = reservedBookings! + cancelledBookings! + noShowBookings!;
      if (sum != totalBookings) {
        return 'Sum of reserved, cancelled, and no-show bookings ($sum) does not match total bookings ($totalBookings).';
      }
    }
    if (plazas != null) {
      for (var plaza in plazas!) {
        final error = plaza.validate();
        if (error != null) return error;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStats &&
        other.totalPlazas == totalPlazas &&
        other.frequency == frequency &&
        other.totalParkingSlots == totalParkingSlots &&
        other.occupiedSlots == occupiedSlots &&
        other.availableSlots == availableSlots &&
        other.totalBookings == totalBookings &&
        other.reservedBookings == reservedBookings &&
        other.cancelledBookings == cancelledBookings &&
        other.noShowBookings == noShowBookings &&
        other.percentageChange == percentageChange &&
        listEquals(other.plazas, plazas);
  }

  @override
  int get hashCode => Object.hash(
    totalPlazas,
    frequency,
    totalParkingSlots,
    occupiedSlots,
    availableSlots,
    totalBookings,
    reservedBookings,
    cancelledBookings,
    noShowBookings,
    percentageChange,
    plazas,
  );

  @override
  String toString() {
    return 'DashboardStats(totalPlazas: $totalPlazas, frequency: $frequency, '
        'totalParkingSlots: $totalParkingSlots, occupiedSlots: $occupiedSlots, '
        'availableSlots: $availableSlots, totalBookings: $totalBookings, '
        'reservedBookings: $reservedBookings, cancelledBookings: $cancelledBookings, '
        'noShowBookings: $noShowBookings, percentageChange: $percentageChange, '
        'plazas: $plazas)';
  }
}

class Plaza {
  final int? plazaId;
  final String? plazaName;
  final int? totalSlots;
  final int? occupiedSlots;
  final int? availableSlots;
  final int? totalBookings;
  final int? reservedBookings;
  final int? cancelledBookings;
  final int? noShowBookings;

  Plaza({
    this.plazaId,
    this.plazaName,
    this.totalSlots,
    this.occupiedSlots,
    this.availableSlots,
    this.totalBookings,
    this.reservedBookings,
    this.cancelledBookings,
    this.noShowBookings,
  });

  factory Plaza.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    return Plaza(
      plazaId: tryParseInt(json['plazaId']),
      plazaName: json['plazaName'] as String? ?? 'Unknown',
      totalSlots: tryParseInt(json['totalSlots']),
      occupiedSlots: tryParseInt(json['occupiedSlots']),
      availableSlots: tryParseInt(json['availableSlots']),
      totalBookings: tryParseInt(json['totalBookings']),
      reservedBookings: tryParseInt(json['reservedBookings']),
      cancelledBookings: tryParseInt(json['cancelledBookings']),
      noShowBookings: tryParseInt(json['noShowBookings']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plazaId': plazaId,
      'plazaName': plazaName,
      'totalSlots': totalSlots,
      'occupiedSlots': occupiedSlots,
      'availableSlots': availableSlots,
      'totalBookings': totalBookings,
      'reservedBookings': reservedBookings,
      'cancelledBookings': cancelledBookings,
      'noShowBookings': noShowBookings,
    };
  }

  String? validate() {
    if (plazaName == null || plazaName!.isEmpty || plazaName == 'Unknown') {
      return 'Plaza name cannot be empty.';
    }
    if (plazaId != null && plazaId! <= 0) {
      return 'Plaza ID must be positive.';
    }
    if (totalSlots != null && totalSlots! < 0) {
      return 'Total slots cannot be negative.';
    }
    if (occupiedSlots != null && occupiedSlots! < 0) {
      return 'Occupied slots cannot be negative.';
    }
    if (availableSlots != null && availableSlots! < 0) {
      return 'Available slots cannot be negative.';
    }
    if (totalBookings != null && totalBookings! < 0) {
      return 'Total bookings cannot be negative.';
    }
    if (reservedBookings != null && reservedBookings! < 0) {
      return 'Reserved bookings cannot be negative.';
    }
    if (cancelledBookings != null && cancelledBookings! < 0) {
      return 'Cancelled bookings cannot be negative.';
    }
    if (noShowBookings != null && noShowBookings! < 0) {
      return 'No-show bookings cannot be negative.';
    }
    if (totalSlots != null && occupiedSlots != null && availableSlots != null) {
      final slotSum = occupiedSlots! + availableSlots!;
      if (slotSum != totalSlots) {
        return 'Sum of occupied and available slots ($slotSum) does not match total slots ($totalSlots).';
      }
    }
    if (totalBookings != null &&
        reservedBookings != null &&
        cancelledBookings != null &&
        noShowBookings != null) {
      final sum = reservedBookings! + cancelledBookings! + noShowBookings!;
      if (sum != totalBookings) {
        return 'Sum of reserved, cancelled, and no-show bookings ($sum) does not match total bookings ($totalBookings).';
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plaza &&
        other.plazaId == plazaId &&
        other.plazaName == plazaName &&
        other.totalSlots == totalSlots &&
        other.occupiedSlots == occupiedSlots &&
        other.availableSlots == availableSlots &&
        other.totalBookings == totalBookings &&
        other.reservedBookings == reservedBookings &&
        other.cancelledBookings == cancelledBookings &&
        other.noShowBookings == noShowBookings;
  }

  @override
  int get hashCode => Object.hash(
    plazaId,
    plazaName,
    totalSlots,
    occupiedSlots,
    availableSlots,
    totalBookings,
    reservedBookings,
    cancelledBookings,
    noShowBookings,
  );

  @override
  String toString() {
    return 'Plaza(plazaId: $plazaId, plazaName: $plazaName, '
        'totalSlots: $totalSlots, occupiedSlots: $occupiedSlots, '
        'availableSlots: $availableSlots, totalBookings: $totalBookings, '
        'reservedBookings: $reservedBookings, cancelledBookings: $cancelledBookings, '
        'noShowBookings: $noShowBookings)';
  }
}

class TicketStats {
  final int? totalTickets;
  final double? totalCollection;
  final List<PlazaTicket>? plazas;

  TicketStats({
    this.totalTickets,
    this.totalCollection,
    this.plazas,
  });

  factory TicketStats.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    final dataJson = json['data'] as List<dynamic>?;
    final totalStats = json['totalStats'] as Map<String, dynamic>?;

    return TicketStats(
      totalTickets: tryParseInt(totalStats?['totalTickets']),
      totalCollection: tryParseDouble(totalStats?['totalCollection']),
      plazas: dataJson?.map((p) => PlazaTicket.fromJson(p as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTickets': totalTickets,
      'totalCollection': totalCollection,
      'plazas': plazas?.map((p) => p.toJson()).toList(),
    };
  }

  String? validate() {
    if (totalTickets != null && totalTickets! < 0) {
      return 'Total tickets cannot be negative.';
    }
    if (totalCollection != null && totalCollection! < 0) {
      return 'Total collection cannot be negative.';
    }
    if (plazas != null) {
      for (var plaza in plazas!) {
        final error = plaza.validate();
        if (error != null) return error;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketStats &&
        other.totalTickets == totalTickets &&
        other.totalCollection == totalCollection &&
        listEquals(other.plazas, plazas);
  }

  @override
  int get hashCode => Object.hash(totalTickets, totalCollection, plazas);

  @override
  String toString() {
    return 'TicketStats(totalTickets: $totalTickets, totalCollection: $totalCollection, plazas: $plazas)';
  }
}

class PlazaTicket {
  final int? plazaId;
  final String? plazaName;
  final int? totalTickets;
  final double? totalCollection;

  PlazaTicket({
    this.plazaId,
    this.plazaName,
    this.totalTickets,
    this.totalCollection,
  });

  factory PlazaTicket.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return PlazaTicket(
      plazaId: tryParseInt(json['plazaId']),
      plazaName: json['plazaName'] as String? ?? 'Unknown',
      totalTickets: tryParseInt(json['totalTickets']),
      totalCollection: tryParseDouble(json['totalCollection']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plazaId': plazaId,
      'plazaName': plazaName,
      'totalTickets': totalTickets,
      'totalCollection': totalCollection,
    };
  }

  String? validate() {
    if (plazaName == null || plazaName!.isEmpty || plazaName == 'Unknown') {
      return 'Plaza name cannot be empty.';
    }
    if (plazaId != null && plazaId! <= 0) {
      return 'Plaza ID must be positive.';
    }
    if (totalTickets != null && totalTickets! < 0) {
      return 'Total tickets cannot be negative.';
    }
    if (totalCollection != null && totalCollection! < 0) {
      return 'Total collection cannot be negative.';
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlazaTicket &&
        other.plazaId == plazaId &&
        other.plazaName == plazaName &&
        other.totalTickets == totalTickets &&
        other.totalCollection == totalCollection;
  }

  @override
  int get hashCode => Object.hash(plazaId, plazaName, totalTickets, totalCollection);

  @override
  String toString() {
    return 'PlazaTicket(plazaId: $plazaId, plazaName: $plazaName, '
        'totalTickets: $totalTickets, totalCollection: $totalCollection)';
  }
}

class PlazaTicketOverview {
  final int? plazaId;
  final String? plazaName;
  final int? totalTickets;
  final int? pendingCount;
  final int? successCount;
  final int? failureCount;

  PlazaTicketOverview({
    this.plazaId,
    this.plazaName,
    this.totalTickets,
    this.pendingCount,
    this.successCount,
    this.failureCount,
  });

  factory PlazaTicketOverview.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    return PlazaTicketOverview(
      plazaId: tryParseInt(json['plazaId']),
      plazaName: json['plazaName'] ?? 'Unknown',
      totalTickets: tryParseInt(json['totalTickets']),
      pendingCount: tryParseInt(json['pendingCount']),
      successCount: tryParseInt(json['successCount']),
      failureCount: tryParseInt(json['failureCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plazaId': plazaId,
      'plazaName': plazaName,
      'totalTickets': totalTickets,
      'pendingCount': pendingCount,
      'successCount': successCount,
      'failureCount': failureCount,
    };
  }

  String? validate() {
    if (plazaName == null || plazaName!.isEmpty || plazaName == 'Unknown') {
      return 'Plaza name cannot be empty.';
    }
    if (plazaId != null && plazaId! <= 0) {
      return 'Plaza ID must be positive.';
    }
    if (totalTickets != null && totalTickets! < 0) {
      return 'Total tickets cannot be negative.';
    }
    if (pendingCount != null && pendingCount! < 0) {
      return 'Pending count cannot be negative.';
    }
    if (successCount != null && successCount! < 0) {
      return 'Success count cannot be negative.';
    }
    if (failureCount != null && failureCount! < 0) {
      return 'Failure count cannot be negative.';
    }
    if (totalTickets != null &&
        pendingCount != null &&
        successCount != null &&
        failureCount != null) {
      final sum = pendingCount! + successCount! + failureCount!;
      if (sum != totalTickets!) {
        return 'Sum of pending, success, and failure counts ($sum) does not match total tickets ($totalTickets).';
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlazaTicketOverview &&
        other.plazaId == plazaId &&
        other.plazaName == plazaName &&
        other.totalTickets == totalTickets &&
        other.pendingCount == pendingCount &&
        other.successCount == successCount &&
        other.failureCount == failureCount;
  }

  @override
  int get hashCode =>
      Object.hash(plazaId, plazaName, totalTickets, pendingCount, successCount, failureCount);

  @override
  String toString() {
    return 'PlazaTicketOverview(plazaId: $plazaId, plazaName: $plazaName, '
        'totalTickets: $totalTickets, pendingCount: $pendingCount, '
        'successCount: $successCount, failureCount: $failureCount)';
  }
}

class TicketOverview {
  final int? totalTickets;
  final int? openTickets;
  final int? completedTickets;
  final int? rejectedTickets; // Added to match backend's rejectedTickets
  final List<PlazaTicketOverview>? plazas;

  TicketOverview({
    this.totalTickets,
    this.openTickets,
    this.completedTickets,
    this.rejectedTickets,
    this.plazas,
  });

  factory TicketOverview.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    return TicketOverview(
      totalTickets: tryParseInt(json['totalTickets']),
      openTickets: tryParseInt(json['openTickets']),
      completedTickets: tryParseInt(json['completedTickets']),
      rejectedTickets: tryParseInt(json['rejectedTickets']),
      plazas: null, // Will be set in getTicketOverview
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTickets': totalTickets,
      'openTickets': openTickets,
      'completedTickets': completedTickets,
      'rejectedTickets': rejectedTickets,
      'plazas': plazas?.map((p) => p.toJson()).toList(),
    };
  }

  String? validate() {
    if (totalTickets != null && totalTickets! < 0) {
      return 'Total tickets cannot be negative.';
    }
    if (openTickets != null && openTickets! < 0) {
      return 'Open tickets cannot be negative.';
    }
    if (completedTickets != null && completedTickets! < 0) {
      return 'Completed tickets cannot be negative.';
    }
    if (rejectedTickets != null && rejectedTickets! < 0) {
      return 'Rejected tickets cannot be negative.';
    }
    if (totalTickets != null &&
        openTickets != null &&
        completedTickets != null &&
        rejectedTickets != null) {
      final sum = openTickets! + completedTickets! + rejectedTickets!;
      if (sum > totalTickets!) {
        return 'Sum of open, completed, and rejected tickets ($sum) cannot exceed total tickets ($totalTickets).';
      }
    }
    if (plazas != null) {
      for (var plaza in plazas!) {
        final error = plaza.validate();
        if (error != null) return error;
      }
    }
    return null;
  }

  TicketOverview copyWith({
    int? totalTickets,
    int? openTickets,
    int? completedTickets,
    int? rejectedTickets,
    List<PlazaTicketOverview>? plazas,
  }) {
    return TicketOverview(
      totalTickets: totalTickets ?? this.totalTickets,
      openTickets: openTickets ?? this.openTickets,
      completedTickets: completedTickets ?? this.completedTickets,
      rejectedTickets: rejectedTickets ?? this.rejectedTickets,
      plazas: plazas ?? this.plazas,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketOverview &&
        other.totalTickets == totalTickets &&
        other.openTickets == openTickets &&
        other.completedTickets == completedTickets &&
        other.rejectedTickets == rejectedTickets &&
        listEquals(other.plazas, plazas);
  }

  @override
  int get hashCode => Object.hash(
      totalTickets, openTickets, completedTickets, rejectedTickets, plazas);

  @override
  String toString() {
    return 'TicketOverview(totalTickets: $totalTickets, openTickets: $openTickets, '
        'completedTickets: $completedTickets, rejectedTickets: $rejectedTickets, plazas: $plazas)';
  }
}

class DisputeSummary {
  final int? totalDisputes;
  final double? totalAmount;
  final int? openDisputes;
  final double? openAmount;
  final int? settledDisputes;
  final double? settledAmount;
  final int? rejectedDisputes;
  final double? rejectedAmount;
  final List<PlazaDispute>? plazas;

  DisputeSummary({
    this.totalDisputes,
    this.totalAmount,
    this.openDisputes,
    this.openAmount,
    this.settledDisputes,
    this.settledAmount,
    this.rejectedDisputes,
    this.rejectedAmount,
    this.plazas,
  });

  factory DisputeSummary.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final plazasJson = json['plazaWiseDisputeSummary'] as List<dynamic>?;

    return DisputeSummary(
      totalDisputes: tryParseInt(summaryJson?['totalDisputeCount']),
      totalAmount: tryParseDouble(summaryJson?['totalDisputeAmount']),
      openDisputes: tryParseInt(summaryJson?['totalOpenCount']),
      openAmount: tryParseDouble(summaryJson?['totalOpenAmount']),
      settledDisputes: tryParseInt(summaryJson?['totalSettledCount']),
      settledAmount: tryParseDouble(summaryJson?['totalSettledAmount']),
      rejectedDisputes: tryParseInt(summaryJson?['totalRejectedCount']),
      rejectedAmount: tryParseDouble(summaryJson?['totalRejectedAmount']),
      plazas: plazasJson?.map((p) => PlazaDispute.fromJson(p as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDisputeCount': totalDisputes,
      'totalDisputeAmount': totalAmount,
      'totalOpenCount': openDisputes,
      'totalOpenAmount': openAmount,
      'totalSettledCount': settledDisputes,
      'totalSettledAmount': settledAmount,
      'totalRejectedCount': rejectedDisputes,
      'totalRejectedAmount': rejectedAmount,
      'plazaWiseDisputeSummary': plazas?.map((p) => p.toJson()).toList(),
    };
  }

  String? validate() {
    if (totalDisputes != null && totalDisputes! < 0) {
      return 'Total disputes cannot be negative.';
    }
    if (totalAmount != null && totalAmount! < 0) {
      return 'Total amount cannot be negative.';
    }
    if (openDisputes != null && openDisputes! < 0) {
      return 'Open disputes cannot be negative.';
    }
    if (openAmount != null && openAmount! < 0) {
      return 'Open amount cannot be negative.';
    }
    if (settledDisputes != null && settledDisputes! < 0) {
      return 'Settled disputes cannot be negative.';
    }
    if (settledAmount != null && settledAmount! < 0) {
      return 'Settled amount cannot be negative.';
    }
    if (rejectedDisputes != null && rejectedDisputes! < 0) {
      return 'Rejected disputes cannot be negative.';
    }
    if (rejectedAmount != null && rejectedAmount! < 0) {
      return 'Rejected amount cannot be negative.';
    }
    if (totalDisputes != null &&
        openDisputes != null &&
        settledDisputes != null &&
        rejectedDisputes != null) {
      final disputeSum = openDisputes! + settledDisputes! + rejectedDisputes!;
      if (disputeSum != totalDisputes) {
        return 'Sum of open, settled, and rejected disputes ($disputeSum) does not match total disputes ($totalDisputes).';
      }
    }
    if (plazas != null) {
      for (var plaza in plazas!) {
        final error = plaza.validate();
        if (error != null) return error;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DisputeSummary &&
        other.totalDisputes == totalDisputes &&
        other.totalAmount == totalAmount &&
        other.openDisputes == openDisputes &&
        other.openAmount == openAmount &&
        other.settledDisputes == settledDisputes &&
        other.settledAmount == settledAmount &&
        other.rejectedDisputes == rejectedDisputes &&
        other.rejectedAmount == rejectedAmount &&
        listEquals(other.plazas, plazas);
  }

  @override
  int get hashCode => Object.hash(
    totalDisputes,
    totalAmount,
    openDisputes,
    openAmount,
    settledDisputes,
    settledAmount,
    rejectedDisputes,
    rejectedAmount,
    plazas,
  );

  @override
  String toString() {
    return 'DisputeSummary(totalDisputes: $totalDisputes, totalAmount: $totalAmount, '
        'openDisputes: $openDisputes, openAmount: $openAmount, '
        'settledDisputes: $settledDisputes, settledAmount: $settledAmount, '
        'rejectedDisputes: $rejectedDisputes, rejectedAmount: $rejectedAmount, '
        'plazas: $plazas)';
  }
}

class PlazaDispute {
  final int? plazaId;
  final String? plazaName;
  final int? disputeCount;
  final double? disputeAmount;
  final int? openCount;
  final double? openAmount;
  final int? settledCount;
  final double? settledAmount;
  final int? rejectedCount;
  final double? rejectedAmount;

  PlazaDispute({
    this.plazaId,
    this.plazaName,
    this.disputeCount,
    this.disputeAmount,
    this.openCount,
    this.openAmount,
    this.settledCount,
    this.settledAmount,
    this.rejectedCount,
    this.rejectedAmount,
  });

  factory PlazaDispute.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return PlazaDispute(
      plazaId: tryParseInt(json['plazaId']),
      plazaName: json['plazaName'] as String? ?? 'Unknown',
      disputeCount: tryParseInt(json['disputeCount']),
      disputeAmount: tryParseDouble(json['disputeAmount']),
      openCount: tryParseInt(json['openCount']),
      openAmount: tryParseDouble(json['openAmount']),
      settledCount: tryParseInt(json['settledCount']),
      settledAmount: tryParseDouble(json['settledAmount']),
      rejectedCount: tryParseInt(json['rejectedCount']),
      rejectedAmount: tryParseDouble(json['rejectedAmount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plazaId': plazaId,
      'plazaName': plazaName,
      'disputeCount': disputeCount,
      'disputeAmount': disputeAmount,
      'openCount': openCount,
      'openAmount': openAmount,
      'settledCount': settledCount,
      'settledAmount': settledAmount,
      'rejectedCount': rejectedCount,
      'rejectedAmount': rejectedAmount,
    };
  }

  String? validate() {
    if (plazaName == null || plazaName!.isEmpty || plazaName == 'Unknown') {
      return 'Plaza name cannot be empty.';
    }
    if (plazaId != null && plazaId! <= 0) {
      return 'Plaza ID must be positive.';
    }
    if (disputeCount != null && disputeCount! < 0) {
      return 'Dispute count cannot be negative.';
    }
    if (disputeAmount != null && disputeAmount! < 0) {
      return 'Dispute amount cannot be negative.';
    }
    if (openCount != null && openCount! < 0) {
      return 'Open count cannot be negative.';
    }
    if (openAmount != null && openAmount! < 0) {
      return 'Open amount cannot be negative.';
    }
    if (settledCount != null && settledCount! < 0) {
      return 'Settled count cannot be negative.';
    }
    if (settledAmount != null && settledAmount! < 0) {
      return 'Settled amount cannot be negative.';
    }
    if (rejectedCount != null && rejectedCount! < 0) {
      return 'Rejected count cannot be negative.';
    }
    if (rejectedAmount != null && rejectedAmount! < 0) {
      return 'Rejected amount cannot be negative.';
    }
    if (disputeCount != null &&
        openCount != null &&
        settledCount != null &&
        rejectedCount != null) {
      final sum = openCount! + settledCount! + rejectedCount!;
      if (sum != disputeCount) {
        return 'Sum of open, settled, and rejected counts ($sum) does not match dispute count ($disputeCount).';
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlazaDispute &&
        other.plazaId == plazaId &&
        other.plazaName == plazaName &&
        other.disputeCount == disputeCount &&
        other.disputeAmount == disputeAmount &&
        other.openCount == openCount &&
        other.openAmount == openAmount &&
        other.settledCount == settledCount &&
        other.settledAmount == settledAmount &&
        other.rejectedCount == rejectedCount &&
        other.rejectedAmount == rejectedAmount;
  }

  @override
  int get hashCode => Object.hash(
    plazaId,
    plazaName,
    disputeCount,
    disputeAmount,
    openCount,
    openAmount,
    settledCount,
    settledAmount,
    rejectedCount,
    rejectedAmount,
  );

  @override
  String toString() {
    return 'PlazaDispute(plazaId: $plazaId, plazaName: $plazaName, '
        'disputeCount: $disputeCount, disputeAmount: $disputeAmount, '
        'openCount: $openCount, openAmount: $openAmount, '
        'settledCount: $settledCount, settledAmount: $settledAmount, '
        'rejectedCount: $rejectedCount, rejectedAmount: $rejectedAmount)';
  }
}

class PaymentMethodAnalysis {
  final int? totalTransactions;
  final double? totalAmount;
  final List<PaymentMethod>? chartData;
  final List<PlazaPayment>? plazas;

  PaymentMethodAnalysis({
    this.totalTransactions,
    this.totalAmount,
    this.chartData,
    this.plazas,
  });

  factory PaymentMethodAnalysis.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final chartDataJson = json['chartData'] as List<dynamic>?;
    final plazasJson = json['plazaWiseBreakdown'] as List<dynamic>?;

    return PaymentMethodAnalysis(
      totalTransactions: tryParseInt(summaryJson?['totalTransactionCount']),
      totalAmount: tryParseDouble(summaryJson?['totalTransactionAmount']),
      chartData: chartDataJson?.map((c) => PaymentMethod.fromJson(c as Map<String, dynamic>)).toList(),
      plazas: plazasJson?.map((p) => PlazaPayment.fromJson(p as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTransactionCount': totalTransactions,
      'totalTransactionAmount': totalAmount,
      'chartData': chartData?.map((c) => c.toJson()).toList(),
      'plazaWiseBreakdown': plazas?.map((p) => p.toJson()).toList(),
    };
  }

  String? validate() {
    if (totalTransactions != null && totalTransactions! < 0) {
      return 'Total transactions cannot be negative.';
    }
    if (totalAmount != null && totalAmount! < 0) {
      return 'Total amount cannot be negative.';
    }
    if (chartData != null) {
      for (var method in chartData!) {
        final error = method.validate();
        if (error != null) return error;
      }
    }
    if (plazas != null) {
      for (var plaza in plazas!) {
        final error = plaza.validate();
        if (error != null) return error;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethodAnalysis &&
        other.totalTransactions == totalTransactions &&
        other.totalAmount == totalAmount &&
        listEquals(other.chartData, chartData) &&
        listEquals(other.plazas, plazas);
  }

  @override
  int get hashCode => Object.hash(totalTransactions, totalAmount, chartData, plazas);

  @override
  String toString() {
    return 'PaymentMethodAnalysis(totalTransactions: $totalTransactions, totalAmount: $totalAmount, '
        'chartData: $chartData, plazas: $plazas)';
  }
}

class PaymentMethod {
  final String? method;
  final int? count;
  final double? amount;
  final double? percentage;

  PaymentMethod({
    this.method,
    this.count,
    this.amount,
    this.percentage,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return PaymentMethod(
      method: json['method'] as String? ?? 'Unknown',
      count: tryParseInt(json['count']),
      amount: tryParseDouble(json['amount']),
      percentage: tryParseDouble(json['percentage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'count': count,
      'amount': amount,
      'percentage': percentage,
    };
  }

  String? validate() {
    if (method == null || method!.isEmpty || method == 'Unknown') {
      return 'Payment method cannot be empty.';
    }
    if (count != null && count! < 0) {
      return 'Payment count cannot be negative.';
    }
    if (amount != null && amount! < 0) {
      return 'Payment amount cannot be negative.';
    }
    if (percentage != null && (percentage! < 0 || percentage! > 100)) {
      return 'Percentage must be between 0 and 100.';
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod &&
        other.method == method &&
        other.count == count &&
        other.amount == amount &&
        other.percentage == percentage;
  }

  @override
  int get hashCode => Object.hash(method, count, amount, percentage);

  @override
  String toString() {
    return 'PaymentMethod(method: $method, count: $count, amount: $amount, percentage: $percentage)';
  }
}

class PlazaPayment {
  final int? plazaId;
  final String? plazaName;
  final int? totalTransactions;
  final double? totalAmount;
  final List<PaymentMethod>? paymentMethods;

  PlazaPayment({
    this.plazaId,
    this.plazaName,
    this.totalTransactions,
    this.totalAmount,
    this.paymentMethods,
  });

  factory PlazaPayment.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    final methodsJson = json['paymentMethods'] as List<dynamic>?;

    return PlazaPayment(
      plazaId: tryParseInt(json['plazaId']),
      plazaName: json['plazaName'] as String? ?? 'Unknown',
      totalTransactions: tryParseInt(json['totalTransactions']),
      totalAmount: tryParseDouble(json['totalAmount']),
      paymentMethods: methodsJson?.map((m) => PaymentMethod.fromJson(m as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plazaId': plazaId,
      'plazaName': plazaName,
      'totalTransactions': totalTransactions,
      'totalAmount': totalAmount,
      'paymentMethods': paymentMethods?.map((m) => m.toJson()).toList(),
    };
  }

  String? validate() {
    if (plazaName == null || plazaName!.isEmpty || plazaName == 'Unknown') {
      return 'Plaza name cannot be empty.';
    }
    if (plazaId != null && plazaId! <= 0) {
      return 'Plaza ID must be positive.';
    }
    if (totalTransactions != null && totalTransactions! < 0) {
      return 'Total transactions cannot be negative.';
    }
    if (totalAmount != null && totalAmount! < 0) {
      return 'Total amount cannot be negative.';
    }
    if (paymentMethods != null) {
      for (var method in paymentMethods!) {
        final error = method.validate();
        if (error != null) return error;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlazaPayment &&
        other.plazaId == plazaId &&
        other.plazaName == plazaName &&
        other.totalTransactions == totalTransactions &&
        other.totalAmount == totalAmount &&
        listEquals(other.paymentMethods, paymentMethods);
  }

  @override
  int get hashCode => Object.hash(plazaId, plazaName, totalTransactions, totalAmount, paymentMethods);

  @override
  String toString() {
    return 'PlazaPayment(plazaId: $plazaId, plazaName: $plazaName, '
        'totalTransactions: $totalTransactions, totalAmount: $totalAmount, '
        'paymentMethods: $paymentMethods)';
  }
}

class BookingStats {
  final int totalBookings;
  final int reserved;
  final int cancelled;
  final int noShow;
  final double percentageChange;

  BookingStats({
    required this.totalBookings,
    required this.reserved,
    required this.cancelled,
    required this.noShow,
    required this.percentageChange,
  });

  factory BookingStats.fromJson(Map<String, dynamic> json) {
    int tryParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    double tryParseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return BookingStats(
      totalBookings: tryParseInt(json['totalBookings']),
      reserved: tryParseInt(json['reserved'] ?? json['totalReserved']),
      cancelled: tryParseInt(json['cancelled'] ?? json['totalCancelled']),
      noShow: tryParseInt(json['noShow'] ?? json['totalNoShow']),
      percentageChange: tryParseDouble(json['percentageChange']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'reserved': reserved,
      'cancelled': cancelled,
      'noShow': noShow,
      'percentageChange': percentageChange,
    };
  }

  String? validate() {
    if (totalBookings < 0) {
      return 'Total bookings cannot be negative.';
    }
    if (reserved < 0) {
      return 'Reserved bookings cannot be negative.';
    }
    if (cancelled < 0) {
      return 'Cancelled bookings cannot be negative.';
    }
    if (noShow < 0) {
      return 'No-show bookings cannot be negative.';
    }
    final sum = reserved + cancelled + noShow;
    if (sum != totalBookings) {
      return 'Sum of reserved, cancelled, and no-show bookings ($sum) does not match total bookings ($totalBookings).';
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingStats &&
        other.totalBookings == totalBookings &&
        other.reserved == reserved &&
        other.cancelled == cancelled &&
        other.noShow == noShow &&
        other.percentageChange == percentageChange;
  }

  @override
  int get hashCode => Object.hash(totalBookings, reserved, cancelled, noShow, percentageChange);

  @override
  String toString() {
    return 'BookingStats(totalBookings: $totalBookings, reserved: $reserved, '
        'cancelled: $cancelled, noShow: $noShow, percentageChange: $percentageChange)';
  }
}