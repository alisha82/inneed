import 'package:flutter/material.dart';
class HospitalModel {
  final String id;
  final String name;
  final String address;
  final double distance;
  final double rating;
  final bool isAvailable;
  final String phoneNumber;
  final double latitude;
  final double longitude;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.isAvailable,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
  });

}