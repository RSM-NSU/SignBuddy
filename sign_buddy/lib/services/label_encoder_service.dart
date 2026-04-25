import 'dart:convert';
import 'package:flutter/services.dart';

class LabelEncoderService {
  final Map<int,String> _indexToLabel = {};
  Future<void> loadFromIndexMap() async {
    final raw = await rootBundle.loadString('assets/models/labels.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    json.forEach((k, v) => _indexToLabel[int.parse(k)] = v.toString());
  }

  String decode(int index) => _indexToLabel[index] ?? 'UNKNOWN';
}
