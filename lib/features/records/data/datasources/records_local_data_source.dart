import 'dart:convert';

import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/record_item.dart';

class RecordsLocalDataSource {
  const RecordsLocalDataSource(this._store);

  final KeyValueStore _store;

  String _key(String resource) => 'records:$resource';

  List<RecordItem> read(String resource) {
    final raw = _store.read(_key(resource));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.whereType<Map<String, dynamic>>().map(_fromJson).toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> write(String resource, List<RecordItem> items) =>
      _store.write(_key(resource), jsonEncode(items.map(_toJson).toList()));

  static RecordItem _fromJson(Map<String, dynamic> json) => RecordItem(
        id: json['id'] as String,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        values: Map<String, Object?>.from((json['values'] as Map?) ?? const {}),
        synced: json['synced'] == true,
      );

  static Map<String, dynamic> _toJson(RecordItem item) => {
        'id': item.id,
        'createdAt': item.createdAt.toIso8601String(),
        'values': item.values,
        'synced': item.synced,
      };
}
