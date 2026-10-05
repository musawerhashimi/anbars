import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static const _fileName = 'anbar_inventory.db';

  Future<String> get databasePath async =>
      join(await getDatabasesPath(), _fileName);

  /// Closes the database and copies its file to [target] so the backup is a
  /// consistent snapshot. The database reopens lazily on next use.
  Future<File> exportTo(String target) async {
    await closeDatabase();
    return File(await databasePath).copy(target);
  }

  /// Replaces the live database with [backup] after checking that it is an
  /// Anbar database, then reopens it (running migrations for older backups).
  Future<void> importFrom(File backup) async {
    if (!await _isAnbarDatabase(backup)) {
      throw const FormatException('Not an Anbar backup');
    }
    await closeDatabase();
    final path = await databasePath;
    for (final suffix in const ['-wal', '-shm', '-journal']) {
      final f = File('$path$suffix');
      if (await f.exists()) await f.delete();
    }
    await backup.copy(path);
    await database;
  }

  Future<bool> _isAnbarDatabase(File file) async {
    final header = await file
        .openRead(0, 16)
        .fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
    if (String.fromCharCodes(header.take(15)) != 'SQLite format 3') {
      return false;
    }
    final db = await openDatabase(file.path, readOnly: true);
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name IN ('products', 'sales', 'app_settings')",
      );
      return tables.length == 3;
    } finally {
      await db.close();
    }
  }

  Future<Database> _initDatabase() async {
    final path = await databasePath;

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  // Enable foreign key enforcement
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          'ALTER TABLE products ADD COLUMN initial_quantity INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute('UPDATE products SET initial_quantity = quantity');
      } catch (_) {
        // Column already exists on fresh installs — safe to ignore
      }
    }
    if (oldVersion < 3) {
      await _translateSeedToDari(db);
    }
  }

  Future<void> _createTables(Database db) async {
    // users table — for Settings > User Profile
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // app_settings table — for dark/light mode & other preferences
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // units table
    await db.execute('''
      CREATE TABLE units (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // departments table
    await db.execute('''
      CREATE TABLE departments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // vendors table
    await db.execute('''
      CREATE TABLE vendors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        contact_info TEXT
      )
    ''');

    // products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        initial_quantity INTEGER NOT NULL DEFAULT 0,
        price REAL NOT NULL DEFAULT 0.0,
        unit_id INTEGER,
        category_id INTEGER,
        department_id INTEGER,
        vendor_id INTEGER,
        description TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE SET NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
        FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
        FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL
      )
    ''');

    // sales table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_amount REAL NOT NULL DEFAULT 0.0,
        note TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // sale_items table
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX idx_products_category ON products(category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_products_department ON products(department_id)',
    );
    await db.execute('CREATE INDEX idx_products_vendor ON products(vendor_id)');
    await db.execute('CREATE INDEX idx_products_unit ON products(unit_id)');
    await db.execute('CREATE INDEX idx_sale_items_sale ON sale_items(sale_id)');
    await db.execute(
      'CREATE INDEX idx_sale_items_product ON sale_items(product_id)',
    );
    await db.execute('CREATE INDEX idx_sales_created_at ON sales(created_at)');
  }

  Future<void> _seedData(Database db) async {
    // Default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'email': 'admin@anbar.com',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Default app settings
    await db.insert('app_settings', {'key': 'theme_mode', 'value': 'light'});
    await db.insert('app_settings', {'key': 'language', 'value': 'fa'});

    // Seed units
    final units = ['دانه', 'جعبه', 'کیلو', 'لیتر', 'متر', 'درجن', 'کارتن'];
    for (final u in units) {
      await db.insert('units', {'name': u});
    }

    // Seed categories
    final categories = [
      'الکترونیک',
      'لباس',
      'خوراک و نوشیدنی',
      'قرطاسیه',
      'سامان آلات',
      'فرنیچر',
    ];
    for (final c in categories) {
      await db.insert('categories', {'name': c});
    }

    // Seed departments
    final departments = [
      'گدام الف',
      'گدام ب',
      'سردخانه',
      'نمایشگاه',
      'برگشتی‌ها',
    ];
    for (final d in departments) {
      await db.insert('departments', {'name': d});
    }

    // Seed vendors
    final vendors = [
      {'name': 'شرکت تک‌سپلای', 'contact_info': '۰۷۰۰۱۲۳۴۵۶'},
      {'name': 'تاجران جهانی', 'contact_info': '۰۷۸۸۱۲۳۴۵۶'},
      {'name': 'فست‌شیپ لمیتد', 'contact_info': '۰۷۹۹۱۲۳۴۵۶'},
      {'name': 'پرایم سورس', 'contact_info': '۰۷۷۷۱۲۳۴۵۶'},
    ];
    for (final v in vendors) {
      await db.insert('vendors', v);
    }

    // Seed sample products
    final now = DateTime.now().toIso8601String();
    final sampleProducts = [
      {
        'name': 'کیبورد بی‌سیم',
        'quantity': 50,
        'initial_quantity': 50,
        'price': 29.99,
        'unit_id': 1,
        'category_id': 1,
        'department_id': 1,
        'vendor_id': 1,
        'description': 'کیبورد کوچک بی‌سیم با ریسور USB',
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'کابل USB-C',
        'quantity': 5,
        'initial_quantity': 5,
        'price': 9.99,
        'unit_id': 1,
        'category_id': 1,
        'department_id': 1,
        'vendor_id': 1,
        'description': 'کابل بافته‌شده USB-C به طول ۲ متر',
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'چوکی دفتر',
        'quantity': 12,
        'initial_quantity': 12,
        'price': 149.99,
        'unit_id': 1,
        'category_id': 6,
        'department_id': 4,
        'vendor_id': 2,
        'description': 'چوکی راحت مش برای دفتر',
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'بسته کاغذ A4',
        'quantity': 200,
        'initial_quantity': 200,
        'price': 5.49,
        'unit_id': 2,
        'category_id': 4,
        'department_id': 2,
        'vendor_id': 3,
        'description': '۵۰۰ برگ در هر بسته، ۸۰ گرام',
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'آب معدنی',
        'quantity': 3,
        'initial_quantity': 3,
        'price': 0.99,
        'unit_id': 6,
        'category_id': 3,
        'department_id': 3,
        'vendor_id': 4,
        'description': 'بوتل ۵۰۰ میلی‌لیتر، بسته درجن',
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final p in sampleProducts) {
      await db.insert('products', p);
    }
  }

  Future<void> _translateSeedToDari(Database db) async {
    const maps = <String, Map<String, String>>{
      'units': {
        'Piece': 'دانه',
        'Box': 'جعبه',
        'Kg': 'کیلو',
        'Liter': 'لیتر',
        'Meter': 'متر',
        'Dozen': 'درجن',
        'Carton': 'کارتن',
      },
      'categories': {
        'Electronics': 'الکترونیک',
        'Clothing': 'لباس',
        'Food & Beverage': 'خوراک و نوشیدنی',
        'Stationery': 'قرطاسیه',
        'Hardware': 'سامان آلات',
        'Furniture': 'فرنیچر',
      },
      'departments': {
        'Warehouse A': 'گدام الف',
        'Warehouse B': 'گدام ب',
        'Cold Storage': 'سردخانه',
        'Showroom': 'نمایشگاه',
        'Returns': 'برگشتی‌ها',
      },
    };

    for (final entry in maps.entries) {
      for (final pair in entry.value.entries) {
        await db.update(
          entry.key,
          {'name': pair.value},
          where: 'name = ?',
          whereArgs: [pair.key],
        );
      }
    }

    const vendors = {
      'TechSupply Co.': 'شرکت تک‌سپلای',
      'Global Traders': 'تاجران جهانی',
      'FastShip Ltd.': 'فست‌شیپ لمیتد',
      'PrimeSources': 'پرایم سورس',
    };
    for (final pair in vendors.entries) {
      await db.update(
        'vendors',
        {'name': pair.value},
        where: 'name = ?',
        whereArgs: [pair.key],
      );
    }

    const products = {
      'Wireless Keyboard': (
        name: 'کیبورد بی‌سیم',
        description: 'کیبورد کوچک بی‌سیم با ریسور USB',
      ),
      'USB-C Cable': (
        name: 'کابل USB-C',
        description: 'کابل بافته‌شده USB-C به طول ۲ متر',
      ),
      'Office Chair': (
        name: 'چوکی دفتر',
        description: 'چوکی راحت مش برای دفتر',
      ),
      'A4 Paper Ream': (
        name: 'بسته کاغذ A4',
        description: '۵۰۰ برگ در هر بسته، ۸۰ گرام',
      ),
      'Mineral Water': (
        name: 'آب معدنی',
        description: 'بوتل ۵۰۰ میلی‌لیتر، بسته درجن',
      ),
    };
    for (final pair in products.entries) {
      await db.update(
        'products',
        {'name': pair.value.name, 'description': pair.value.description},
        where: 'name = ?',
        whereArgs: [pair.key],
      );
    }
  }

  // ─── Generic helpers ────────────────────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(
      table,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
