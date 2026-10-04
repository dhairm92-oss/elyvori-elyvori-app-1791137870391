import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../registry.dart';
import '../../data/datasources/records_local_data_source.dart';
import '../../data/repositories/records_repository_impl.dart';
import '../../domain/entities/record_item.dart';
import '../../domain/entities/resource_spec.dart';
import '../../domain/repositories/records_repository.dart';
import '../../domain/usecases/records_usecases.dart';

const _remoteSync = bool.fromEnvironment('RECORDS_SYNC');

final recordsRepositoryProvider = Provider<RecordsRepository>((ref) => RecordsRepositoryImpl(
      local: RecordsLocalDataSource(ref.watch(keyValueStoreProvider)),
      queue: ref.watch(syncQueueProvider),
      remoteSync: _remoteSync,
    ));

ResourceSpec specFor(String key) => appResources.firstWhere(
      (r) => r.key == key,
      orElse: () => throw ArgumentError('Unknown module "$key"'),
    );

/// Items of one module, keyed by the module key.
class RecordsNotifier extends FamilyAsyncNotifier<List<RecordItem>, String> {
  ResourceSpec get spec => specFor(arg);

  @override
  Future<List<RecordItem>> build(String arg) async {
    final result = await ref.read(recordsRepositoryProvider).list(specFor(arg));
    return result.when(success: (items) => items, failure: (f) => throw f);
  }

  /// Returns an error message, or null when saved.
  Future<String?> save(Map<String, String> input, {RecordItem? existing}) async {
    final result = await SaveRecord(ref.read(recordsRepositoryProvider))(spec, input, existing: existing);
    return result.when(
      success: (_) {
        ref.invalidateSelf();
        return null;
      },
      failure: (f) => f.message,
    );
  }

  Future<void> remove(String id) async {
    final previous = state.valueOrNull ?? const <RecordItem>[];
    state = AsyncData(previous.where((i) => i.id != id).toList()); // optimistic
    final result = await ref.read(recordsRepositoryProvider).delete(spec, id);
    if (!result.isSuccess) state = AsyncData(previous);
  }
}

final recordsProvider =
    AsyncNotifierProvider.family<RecordsNotifier, List<RecordItem>, String>(RecordsNotifier.new);
