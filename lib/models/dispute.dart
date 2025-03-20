class Dispute {
  final String disputeId;
  final String ticketId;
  final String plazaName;
  final String vehicleNumber;
  final String vehicleType;
  final String vehicleEntryTime;
  final String vehicleExitTime;
  final String parkingDuration;
  final String fareType;
  final String fareAmount;
  final String paymentAmount;
  final String paymentDate;
  final String disputeReason;
  final String disputeAmount;
  final String disputeExpiryDate;
  final String disputeStatus;
  final String disputeRemark;
  final String disputeRaisedDate;

  Dispute({
    required this.disputeId,
    required this.ticketId,
    required this.plazaName,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.vehicleEntryTime,
    required this.vehicleExitTime,
    required this.parkingDuration,
    required this.fareType,
    required this.fareAmount,
    required this.paymentAmount,
    required this.paymentDate,
    required this.disputeReason,
    required this.disputeAmount,
    required this.disputeExpiryDate,
    required this.disputeStatus,
    required this.disputeRemark,
    required this.disputeRaisedDate,
  });
}
