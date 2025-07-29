import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_application_neoflex/models/shop_item.dart';
import 'package:flutter_application_neoflex/models/accelerator.dart';
import 'package:flutter_application_neoflex/models/accelerator_application.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  static const _databaseVersion = 5; 

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'neoflex_quest.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createShopTables(db);
    await _createAcceleratorTables(db);
    await _populateInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE user_items ADD COLUMN is_claimed INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE user_items ADD COLUMN qr_data TEXT');
      await db.execute('ALTER TABLE user_items ADD COLUMN status TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE shop_items ADD COLUMN qr_data TEXT');
      await db.execute('ALTER TABLE shop_items ADD COLUMN status TEXT');
      await db.execute("UPDATE shop_items SET status = 'pending'");
      await db.execute(
        "UPDATE shop_items SET qr_data = 'item_' || id || '_' || CAST(ABS(RANDOM()) AS TEXT)",
      );
    }
    if (oldVersion < 5) {
      await _createAcceleratorTables(db);
    }
  }

  Future<void> _createShopTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS shop_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price INTEGER NOT NULL,
        imagePath TEXT NOT NULL,
        qr_data TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT NOT NULL,
        purchase_date TEXT NOT NULL,
        is_claimed INTEGER DEFAULT 0,
        qr_data TEXT,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (item_id) REFERENCES shop_items (id)
      )
    ''');
  }

  Future<void> _createAcceleratorTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS accelerators (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        duration TEXT NOT NULL,
        reward TEXT NOT NULL,
        image_path TEXT NOT NULL,
        start_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS applications (
        id TEXT PRIMARY KEY,
        accelerator_id TEXT NOT NULL,
        application_date TEXT NOT NULL,
        status TEXT NOT NULL,
        message TEXT,
        FOREIGN KEY (accelerator_id) REFERENCES accelerators (id)
      )
    ''');
  }

  Future<void> _populateInitialData(Database db) async {

    final shopItems = [
      ShopItem(
        id: '1',
        name: 'Стикеры Neoflex',
        description: 'Стильные стикеры для записей',
        price: 2,
        imagePath: 'assets/images/стик.jpg',
        qrData: 'item1_${DateTime.now().millisecondsSinceEpoch}',
        status: 'pending',
      ),
      ShopItem(
        id: '2',
        name: 'Колонка Neoflex',
        description: 'Колонка с логотипом',
        price: 8,
        imagePath: 'assets/images/kolonka.jpg',
        qrData: 'item2_${DateTime.now().millisecondsSinceEpoch + 1}',
        status: 'pending',
      ),
      ShopItem(
        id: '3',
        name: 'Блокнот Neoflex',
        description: 'Стильный блокнот для записей',
        price: 3,
        imagePath: 'assets/images/bloknot.jpg',
        qrData: 'item3_${DateTime.now().millisecondsSinceEpoch + 2}',
        status: 'pending',
      ),
      ShopItem(
        id: '4',
        name: 'Бутылка Neoflex',
        description: 'Стильная бутылка для спорта',
        price: 5,
        imagePath: 'assets/images/bootle.jpg',
        qrData: 'item4_${DateTime.now().millisecondsSinceEpoch + 3}',
        status: 'pending',
      ),
      ShopItem(
        id: '5',
        name: 'Powerbank Neoflex',
        description: 'Премиальный powerbank с фирменным дизайном',
        price: 10,
        imagePath: 'assets/images/pover.jpg',
        qrData: 'item5_${DateTime.now().millisecondsSinceEpoch + 4}',
        status: 'pending',
      ),
    ];

    for (final item in shopItems) {
      await db.insert('shop_items', item.toMap());
    }

   
    final accelerators = [
      {
        'id': '1',
        'title': 'NeoStart',
        'description': 'Базовый курс для новых разработчиков',
        'duration': '3 месяца',
        'reward': 'Сертификат + стажировка',
        'image_path': 'assets/accelerators/neo_start.png',
        'start_date': DateTime.now().add(Duration(days: 10)).toIso8601String(),
      },
      {
        'id': '2',
        'title': 'NeoPro',
        'description': 'Продвинутая программа',
        'duration': '6 месяцев',
        'reward': 'Повышение грейда',
        'image_path': 'assets/accelerators/neo_pro.png',
        'start_date': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      },
      {
        'id': '3',
        'title': 'NeoArchitect',
        'description': 'Экспертный курс',
        'duration': '12 месяцев',
        'reward': 'Должность архитектора',
        'image_path': 'assets/accelerators/neo_architect.png',
        'start_date': DateTime.now().add(Duration(days: 60)).toIso8601String(),
      },
    ];

    for (final accel in accelerators) {
      await db.insert('accelerators', accel);
    }
  }

  Future<List<ShopItem>> getAllShopItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('shop_items');
    return List.generate(maps.length, (i) => ShopItem.fromMap(maps[i]));
  }

  Future<void> purchaseItem(String itemId, String qrData) async {
    final db = await database;
    await db.insert('user_items', {
      'item_id': itemId,
      'purchase_date': DateTime.now().toIso8601String(),
      'is_claimed': 0,
      'qr_data': qrData,
      'status': 'pending',
    });
  }

  Future<List<ShopItem>> getUserPurchasedItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT shop_items.*, user_items.status as user_status 
      FROM user_items
      JOIN shop_items ON user_items.item_id = shop_items.id
      ORDER BY user_items.purchase_date DESC
    ''');
    return List.generate(maps.length, (i) => ShopItem.fromMap(maps[i]));
  }

  // Future<void> markItemAsIssued(String qrData) async {
  //   final db = await database;
  //   await db.update(
  //     'user_items',
  //     {'status': 'issued'},
  //     where: 'qr_data = ?',
  //     whereArgs: [qrData],
  //   );
  // }

  
  Future<List<Accelerator>> getAllAccelerators() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('accelerators');
    return List.generate(maps.length, (i) => Accelerator.fromMap(maps[i]));
  }

  Future<void> applyForAccelerator(String acceleratorId) async {
    final db = await database;
    await db.insert('applications', {
      'id': 'app_${DateTime.now().millisecondsSinceEpoch}',
      'accelerator_id': acceleratorId,
      'application_date': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
  }

  Future<List<AcceleratorApplication>> getUserApplications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('applications');
    return List.generate(
      maps.length,
      (i) => AcceleratorApplication.fromMap(maps[i]),
    );
  }

  
  Future<List<Accelerator>> getAcceleratorsWithStatus() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      accelerators.*, 
      applications.status as application_status,
      applications.application_date
    FROM accelerators
    LEFT JOIN applications ON accelerators.id = applications.accelerator_id
  ''');

    return maps.map((map) => Accelerator.fromMap(map)).toList();
  }

  Future<void> deleteDatabase() async {
    final path = join(await getDatabasesPath(), 'neoflex_quest.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
