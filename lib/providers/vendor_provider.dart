import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vendor_model.dart';
import '../services/vendor_service.dart';

final vendorServiceProvider = Provider<VendorService>((ref) => VendorService());

final vendorsProvider = AsyncNotifierProvider<VendorsNotifier, List<VendorModel>>(
  VendorsNotifier.new,
);

class VendorsNotifier extends AsyncNotifier<List<VendorModel>> {
  @override
  Future<List<VendorModel>> build() => ref.read(vendorServiceProvider).getAll();

  Future<void> add(VendorModel vendor) async {
    await ref.read(vendorServiceProvider).create(vendor);
    ref.invalidateSelf();
  }

  Future<void> edit(VendorModel vendor) async {
    await ref.read(vendorServiceProvider).update(vendor);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(vendorServiceProvider).delete(id);
    ref.invalidateSelf();
  }
}
