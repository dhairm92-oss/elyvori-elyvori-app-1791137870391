import '../../../../core/result/result.dart';
import '../../../../core/storage/sync_queue.dart';
import '../../domain/entities/record_item.dart';
import '../../domain/entities/resource_spec.dart';
import '../../domain/repositories/records_repository.dart';
import '../datasources/records_local_data_source.dart';

/// Offline-first: every change is saved on the device immediately. When a
/// remote API is enabled (RECORDS_SYNC=true), changes are also queued and
/// replayed to `/records/<module>` whenever the device is online.
class RecordsRepositoryImpl implements RecordsRepository {
  RecordsRepositoryImpl({required this.local, required this.queue, required this.remoteSync});

  final RecordsLocalDataSource local;
  final SyncQueue queue;
  final bool remoteSync;

  @override
  Future<Result<List<RecordItem>>> list(ResourceSpec spec) => Result.guard(() async {
        final items = local.read(spec.key)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });

  @override
  Future<Result<RecordItem>> save(ResourceSpec spec, RecordItem item) => Result.guard(() async {
        final items = local.read(spec.key);
        final index = items.indexWhere((i) => i.id == item.id);
        if (index == -1) {
          items.add(item);
        } else {
          items[index] = item;
        }
        await local.write(spec.key, items);
        if (remoteSync) {
          await queue.enqueue(
            method: index == -1 ? 'POST' : 'PATCH',
            path: index == -1 ? '/records/${spec.key}' : '/records/${spec.key}/${item.id}',
            body: {'id': item.id, 'createdAt': item.createdAt.toIso8601String(), ...item.values},
          );
        }
        return item;
      });

  @override
  Future<Result<bool>> delete(ResourceSpec spec, String id) => Result.guard(() async {
        final items = local.read(spec.key)..removeWhere((i) => i.id == id);
        await local.write(spec.key, items);
        if (remoteSync) await queue.enqueue(method: 'DELETE', path: '/records/${spec.key}/$id');
        return true;
      });
}
