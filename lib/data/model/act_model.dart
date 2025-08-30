class ActModel {
  final String id;
  final String actNumber;
  final String actDate;
  final String accountNumber;
  final String address;
  final String sector;
  final String status;

  ActModel({
    required this.id,
    required this.actNumber,
    required this.actDate,
    required this.accountNumber,
    required this.address,
    required this.sector,
    required this.status,
  });

  factory ActModel.fromJson(Map<String, dynamic> json) {
    return ActModel(
      id: json['id'],
      actNumber: json['actNumber'],
      actDate: json['actDate'],
      accountNumber: json['accountNumber'],
      address: json['address'],
      sector: json['sector'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actNumber': actNumber,
      'actDate': actDate,
      'accountNumber': accountNumber,
      'address': address,
      'sector': sector,
      'status': status,
    };
  }
}
