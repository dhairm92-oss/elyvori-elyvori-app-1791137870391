import 'package:equatable/equatable.dart';

class RecordItem extends Equatable {
  const RecordItem({required this.id, required this.createdAt, required this.values, this.synced = false});

  final String id;
  final DateTime createdAt;
  final Map<String, Object?> values;
  final bool synced;

  RecordItem copyWith({Map<String, Object?>? values, bool? synced}) => RecordItem(
        id: id,
        createdAt: createdAt,
        values: values ?? this.values,
        synced: synced ?? this.synced,
      );

  @override
  List<Object?> get props => [id, createdAt, values, synced];
}
