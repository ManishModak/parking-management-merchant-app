class Bank {
  final String? id;
  final String plazaId;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String ifscCode;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Bank({
    this.id,
    required this.plazaId,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      // Convert id to String if it's an integer
      id: json['id']?.toString(),
      // Convert plazaId to String if it's an integer
      plazaId: json['plazaId']?.toString() ?? '',
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      ifscCode: json['IFSCcode'] ?? '',
      active: json['active'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      if (id != null) 'id': id,
      'plazaId': plazaId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'IFSCcode': ifscCode,
    };

    if (active != true) {
      data['active'] = active;
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt!.toIso8601String();
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt!.toIso8601String();
    }

    return data;
  }

  Bank copyWith({
    String? id,
    String? plazaId,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    String? ifscCode,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bank(
      id: id ?? this.id,
      plazaId: plazaId ?? this.plazaId,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      ifscCode: ifscCode ?? this.ifscCode,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Bank &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              plazaId == other.plazaId &&
              bankName == other.bankName &&
              accountNumber == other.accountNumber &&
              accountHolderName == other.accountHolderName &&
              ifscCode == other.ifscCode &&
              active == other.active;

  @override
  int get hashCode =>
      id.hashCode ^
      plazaId.hashCode ^
      bankName.hashCode ^
      accountNumber.hashCode ^
      accountHolderName.hashCode ^
      ifscCode.hashCode ^
      active.hashCode;

  @override
  String toString() {
    return 'Bank{id: $id, plazaId: $plazaId, bankName: $bankName, '
        'accountNumber: $accountNumber, accountHolderName: $accountHolderName, '
        'ifscCode: $ifscCode, active: $active}';
  }
}