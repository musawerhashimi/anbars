import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() => ref.read(userServiceProvider).getUser();

  Future<bool> updateUsername(String username) async {
    final user = state.valueOrNull;
    if (user == null) return false;
    await ref.read(userServiceProvider).updateUsername(user.id!, username);
    ref.invalidateSelf();
    return true;
  }

  Future<UserModel> register({
    required String username,
    required String password,
    String? email,
  }) async {
    final user = await ref
        .read(userServiceProvider)
        .register(username: username, password: password, email: email);
    state = AsyncData(user);
    return user;
  }

  Future<bool> login(String username, String password) async {
    final user = await ref.read(userServiceProvider).login(username, password);
    if (user == null) return false;
    state = AsyncData(user);
    return true;
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = state.valueOrNull;
    if (user == null) return false;
    final success = await ref
        .read(userServiceProvider)
        .changePassword(user.id!, currentPassword, newPassword);
    return success;
  }
}
