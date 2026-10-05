import '../core/database/database_helper.dart';
import '../models/user_model.dart';

class UserService {
  final _db = DatabaseHelper.instance;

  Future<UserModel?> getUser() async {
    final rows = await _db.query('users', orderBy: 'id ASC');
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  /// The seeded demo account from older installs. A real registration replaces it.
  bool isPlaceholder(UserModel user) =>
      user.username == 'admin' &&
      user.password == 'admin123' &&
      user.email == 'admin@anbar.com';

  Future<bool> needsRegistration() async {
    final user = await getUser();
    return user == null || isPlaceholder(user);
  }

  /// Checks the typed password against the account stored in the database.
  /// The demo account is never accepted.
  Future<UserModel?> login(String username, String password) async {
    final user = await getUser();
    if (user == null || isPlaceholder(user)) return null;
    final nameMatches =
        user.username.trim().toLowerCase() == username.trim().toLowerCase();
    if (!nameMatches || user.password != password) return null;
    return user;
  }

  /// Creates the shop account, or replaces the unused demo account.
  Future<UserModel> register({
    required String username,
    required String password,
    String? email,
  }) async {
    final existing = await getUser();
    final row = {
      'username': username.trim(),
      'password': password,
      'email': (email == null || email.trim().isEmpty) ? null : email.trim(),
    };
    if (existing?.id != null) {
      await _db.update('users', row, 'id = ?', [existing!.id]);
    } else {
      await _db.insert('users', {
        ...row,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return (await getUser())!;
  }

  Future<int> updateUsername(int id, String username) async {
    return await _db.update('users', {'username': username}, 'id = ?', [id]);
  }

  Future<bool> changePassword(
    int id,
    String currentPassword,
    String newPassword,
  ) async {
    final rows = await _db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [id, currentPassword],
    );
    if (rows.isEmpty) return false;
    await _db.update('users', {'password': newPassword}, 'id = ?', [id]);
    return true;
  }

  Future<String?> getSetting(String key) async {
    final rows = await _db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    await _db.insert('app_settings', {'key': key, 'value': value});
  }
}
