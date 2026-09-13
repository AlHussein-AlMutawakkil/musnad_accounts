import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// كلاس إدارة قاعدة بيانات SQLite المركزية (musnad.db)
/// يطبق نمط Singleton لإدارة الاتصال وضمان سلامة البيانات والمعاملات الذرية
class DatabaseHelper {
  // نمط Singleton
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  static const String _databaseName = 'musnad.db';
  static const int _databaseVersion = 2;

  // أسماء الجداول
  static const String tableCurrencies = 'currencies';
  static const String tableCategories = 'categories';
  static const String tableAccounts = 'accounts';
  static const String tableTransfers = 'transfers';
  static const String tableTransactions = 'transactions';

  /// الحصول على كائن الاتصال بقاعدة البيانات
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// تهيئة وفتح قاعدة البيانات
  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// ترقية قاعدة البيانات عند إضافة أعمدة أو فهارس جديدة
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableTransactions ADD COLUMN category_id TEXT REFERENCES $tableCategories (id) ON DELETE SET NULL;',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON $tableTransactions (category_id);',
      );
    }
  }

  /// تفعيل القيود الصريحة للمفاتيح الأجنبية
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  /// إنشاء الجداول والفهارس وبذور البيانات الأولية
  Future<void> _onCreate(Database db, int version) async {
    // 1. جدول العملات (currencies)
    await db.execute('''
      CREATE TABLE $tableCurrencies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // 2. جدول التصنيفات (categories)
    await db.execute('''
      CREATE TABLE $tableCategories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_hex TEXT,
        icon_name TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // 3. جدول الحسابات (accounts)
    await db.execute('''
      CREATE TABLE $tableAccounts (
        id TEXT PRIMARY KEY,
        category_id TEXT,
        name TEXT NOT NULL,
        phone TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES $tableCategories (id) ON DELETE SET NULL
      );
    ''');

    // 4. جدول عمليات التحويل والمصارفة (transfers)
    await db.execute('''
      CREATE TABLE $tableTransfers (
        id TEXT PRIMARY KEY,
        from_account_id TEXT NOT NULL,
        to_account_id TEXT NOT NULL,
        from_currency_id TEXT NOT NULL,
        to_currency_id TEXT NOT NULL,
        from_amount REAL NOT NULL,
        to_amount REAL NOT NULL,
        exchange_rate REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (from_account_id) REFERENCES $tableAccounts (id) ON DELETE RESTRICT,
        FOREIGN KEY (to_account_id) REFERENCES $tableAccounts (id) ON DELETE RESTRICT,
        FOREIGN KEY (from_currency_id) REFERENCES $tableCurrencies (id) ON DELETE RESTRICT,
        FOREIGN KEY (to_currency_id) REFERENCES $tableCurrencies (id) ON DELETE RESTRICT
      );
    ''');

    // 5. جدول الحركات والقيود (transactions)
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id TEXT PRIMARY KEY,
        account_id TEXT NOT NULL,
        currency_id TEXT NOT NULL,
        category_id TEXT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        details TEXT,
        date TEXT NOT NULL,
        transfer_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (account_id) REFERENCES $tableAccounts (id) ON DELETE RESTRICT,
        FOREIGN KEY (currency_id) REFERENCES $tableCurrencies (id) ON DELETE RESTRICT,
        FOREIGN KEY (category_id) REFERENCES $tableCategories (id) ON DELETE SET NULL,
        FOREIGN KEY (transfer_id) REFERENCES $tableTransfers (id) ON DELETE SET NULL
      );
    ''');

    // إنشاء الفهارس لتسريع الاستعلامات والتقارير
    await db.execute('''
      CREATE INDEX idx_transactions_account_currency 
      ON $tableTransactions (account_id, currency_id);
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_category_id 
      ON $tableTransactions (category_id);
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_date 
      ON $tableTransactions (date);
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_transfer_id 
      ON $tableTransactions (transfer_id);
    ''');

    await db.execute('''
      CREATE INDEX idx_accounts_category_id 
      ON $tableAccounts (category_id);
    ''');

    await db.execute('''
      CREATE INDEX idx_accounts_deleted_at 
      ON $tableAccounts (deleted_at);
    ''');

    await db.execute('''
      CREATE INDEX idx_categories_deleted_at 
      ON $tableCategories (deleted_at);
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_deleted_at 
      ON $tableTransactions (deleted_at);
    ''');

    // إدراج بذور البيانات الافتراضية (Seed Data)
    await _insertDefaultCurrencies(db);
    await _insertDefaultCategories(db);
  }

  /// إدراج التصنيفات الافتراضية للحسابات
  Future<void> _insertDefaultCategories(Database db) async {
    const Uuid uuid = Uuid();
    final String nowUtc = DateTime.now().toUtc().toIso8601String();

    final Batch batch = db.batch();

    final List<Map<String, dynamic>> defaultCategories = [
      {'name': 'عملاء', 'color_hex': '#1B365D', 'icon_name': 'person'},
      {'name': 'موردين', 'color_hex': '#1B873F', 'icon_name': 'local_shipping'},
      {'name': 'شخصي', 'color_hex': '#E37400', 'icon_name': 'account_circle'},
    ];

    for (final cat in defaultCategories) {
      batch.insert(tableCategories, {
        'id': uuid.v4(),
        'name': cat['name'],
        'color_hex': cat['color_hex'],
        'icon_name': cat['icon_name'],
        'created_at': nowUtc,
        'updated_at': nowUtc,
        'deleted_at': null,
        'is_synced': 0,
      });
    }

    await batch.commit(noResult: true);
  }

  /// إدراج العملات الافتراضية: الريال اليمني (افتراضي) والدولار الأمريكي
  Future<void> _insertDefaultCurrencies(Database db) async {
    const Uuid uuid = Uuid();
    final String nowUtc = DateTime.now().toUtc().toIso8601String();

    final Batch batch = db.batch();

    // الريال اليمني (العملة الافتراضية)
    batch.insert(tableCurrencies, {
      'id': uuid.v4(),
      'name': 'ريال يمني',
      'symbol': 'ر.ي',
      'code': 'YER',
      'is_default': 1,
      'created_at': nowUtc,
      'updated_at': nowUtc,
      'deleted_at': null,
      'is_synced': 0,
    });

    // الدولار الأمريكي
    batch.insert(tableCurrencies, {
      'id': uuid.v4(),
      'name': 'دولار أمريكي',
      'symbol': r'$',
      'code': 'USD',
      'is_default': 0,
      'created_at': nowUtc,
      'updated_at': nowUtc,
      'deleted_at': null,
      'is_synced': 0,
    });

    await batch.commit(noResult: true);
  }

  /// تنفيذ معاملة ذرية تضمن سلامة العمليات المحاسبية المزدوجة
  Future<T> runTransaction<T>(Future<T> Function(Transaction txn) action) async {
    final Database db = await database;
    return await db.transaction<T>(action);
  }

  /// إغلاق اتصال قاعدة البيانات
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// حذف ملف قاعدة البيانات (مفيد للاختبارات وإعادة التهيئة)
  Future<void> deleteDatabaseFile() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);
    await close();
    await deleteDatabase(path);
  }
}
