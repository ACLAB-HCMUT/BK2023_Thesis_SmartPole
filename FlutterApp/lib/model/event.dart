import 'dart:core';
import 'package:flutter/material.dart';

class Event {
  final String name;
  final String description;
  final DateTime from;
  final DateTime to;
  final Color backgroundColor;
  final String recurrence = 'None';
  final String recurrence_times = 'None';
  final String recurrence_interval = 'None';

  const Event({
    required this.name,
    required this.description,
    required this.from,
    required this.to,
    this.backgroundColor = Colors.purpleAccent,
  });
}