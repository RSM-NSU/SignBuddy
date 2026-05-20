import 'dart:convert';
import 'package:flutter/services.dart';

class LabelEncoderService {
  final Map<int, String> _indexToLabel = {};

  /// Load labels from assets/models/labels.json
  /// JSON format: { "0": "A", "1": "B", ... }
  Future<void> loadFromIndexMap() async {
    final raw  = await rootBundle.loadString('assets/models/labels.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    json.forEach((k, v) => _indexToLabel[int.parse(k)] = v.toString());
  }

  /// Load labels directly from a Dart List (for word model)
  /// e.g. ["AXE1", "BACKPACK1", ...]
  void loadFromList(List<String> labels) {
    _indexToLabel.clear();
    for (int i = 0; i < labels.length; i++) {
      _indexToLabel[i] = labels[i];
    }
  }

  /// Decode an index to its label string
  String decode(int index) => _indexToLabel[index] ?? 'UNKNOWN';

  /// Total number of labels loaded
  int get count => _indexToLabel.length;
}