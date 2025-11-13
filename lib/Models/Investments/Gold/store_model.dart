// 📝 File: StoreSelectionModel.dart
import 'dart:convert';

class StoreSelectionModel {
  final String id;
  final String shopName;
  final String logo;
  final String address;
  final String phoneNumber;

  StoreSelectionModel({
    required this.id,
    required this.shopName,
    required this.logo,
    required this.address,
    required this.phoneNumber,
  });

  // Factory constructor to create an instance from a JSON map
  factory StoreSelectionModel.fromJson(Map<String, dynamic> json) {
    return StoreSelectionModel(
      id: json['id'] as String,
      shopName: json['shopName'] as String,
      logo: json['logo'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'logo': logo,
      'address': address,
      'phoneNumber': phoneNumber,
    };
  }

  // Optional: For easier debugging/logging
  @override
  String toString() {
    return 'StoreSelectionModel(id: $id, shopName: $shopName, address: $address)';
  }
}