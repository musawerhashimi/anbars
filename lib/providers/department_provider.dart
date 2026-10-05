import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department_model.dart';
import '../services/department_service.dart';

final departmentServiceProvider = Provider<DepartmentService>((ref) => DepartmentService());

final departmentsProvider = AsyncNotifierProvider<DepartmentsNotifier, List<DepartmentModel>>(
  DepartmentsNotifier.new,
);

class DepartmentsNotifier extends AsyncNotifier<List<DepartmentModel>> {
  @override
  Future<List<DepartmentModel>> build() => ref.read(departmentServiceProvider).getAll();

  Future<void> add(String name) async {
    await ref.read(departmentServiceProvider).create(name);
    ref.invalidateSelf();
  }

  Future<void> edit(DepartmentModel dept) async {
    await ref.read(departmentServiceProvider).update(dept);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(departmentServiceProvider).delete(id);
    ref.invalidateSelf();
  }
}
