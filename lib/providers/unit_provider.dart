import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/unit_model.dart';
import '../services/unit_service.dart';

final unitServiceProvider = Provider<UnitService>((ref) => UnitService());

final unitsProvider = AsyncNotifierProvider<UnitsNotifier, List<UnitModel>>(
  UnitsNotifier.new,
);

class UnitsNotifier extends AsyncNotifier<List<UnitModel>> {
  @override
  Future<List<UnitModel>> build() => ref.read(unitServiceProvider).getAll();

  Future<void> add(String name) async {
    await ref.read(unitServiceProvider).create(name);
    ref.invalidateSelf();
  }

  Future<void> edit(UnitModel unit) async {
    await ref.read(unitServiceProvider).update(unit);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(unitServiceProvider).delete(id);
    ref.invalidateSelf();
  }
}
