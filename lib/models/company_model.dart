import 'package:flutter/material.dart';

class Company {
  final String id;
  final String name;
  final String mono;
  final Color tint;
  String location;
  final int since;
  double rating;
  final int reviews;
  String about;
  List<String> tags;
  final bool isVerified;

  Company({
    required this.id,
    required this.name,
    required this.mono,
    required this.tint,
    required this.location,
    required this.since,
    required this.rating,
    required this.reviews,
    required this.about,
    required this.tags,
    this.isVerified = true,
  });
}
