import 'package:hive/hive.dart';

part 'wallet_model.g.dart';

// ============================================================
// Wallet Model - Cash, Bank, UPI, Credit Card
// ============================================================

@HiveType(typeId: 2)
class WalletModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon; // icon name string

  @HiveField(3)
  late double balance;

  WalletModel({
    required this.id,
    required this.name,
    required this.icon,
    this.balance = 0.0,
  });

  /// Convert to JSON for backup
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'balance': balance,
  };

  /// Create from JSON for restore
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
