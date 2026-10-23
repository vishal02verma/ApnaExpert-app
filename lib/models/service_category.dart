import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double basePrice;
  final bool isActive;

  ServiceCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.basePrice,
    this.isActive = true,
  });

  ServiceCategory copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    double? basePrice,
    bool? isActive,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      basePrice: basePrice ?? this.basePrice,
      isActive: isActive ?? this.isActive,
    );
  }
}
