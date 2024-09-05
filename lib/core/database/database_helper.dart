import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'pet_spa_001.db'),
      onCreate: _onCreate,
      version: 11,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE spa_category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE spa_service (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price DECIMAL NOT NULL,
        FOREIGN KEY (category_id) REFERENCES spa_category(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE spa_calendar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        service_id INTEGER NOT NULL,
        date DATE NOT NULL,
        time TIME NOT NULL,
        pet_name TEXT NOT NULL,
        pet_type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Pending',
        transportation TEXT NOT NULL,
        FOREIGN KEY (service_id) REFERENCES spa_service(id)
      );
    ''');

    // Thêm dữ liệu mẫu cho bảng spa_category
    await db.insert('spa_category', {
      'name': 'Grooming',
      'description': 'Dịch vụ tắm và cắt tỉa lông'
    });
    await db.insert('spa_category', {
      'name': 'Spa',
      'description': 'Dịch vụ spa thư giãn cho thú cưng'
    });
    // await db.insert('spa_category', {'name': 'Medical', 'description': 'Dịch vụ chăm sóc y tế'});

    // Thêm dữ liệu mẫu cho bảng spa_service
    await db.insert('spa_service', {
      'category_id': 1,
      'name': 'Tắm và sấy khô',
      'description': 'Dịch vụ tắm và sấy khô cho thú cưng',
      'price': 150000,
    });
    await db.insert('spa_service', {
      'category_id': 1,
      'name': 'Cắt tỉa lông',
      'description': 'Dịch vụ cắt tỉa lông cho thú cưng',
      'price': 200000,
    });
    await db.insert('spa_service', {
      'category_id': 2,
      'name': 'Spa thư giãn',
      'description': 'Dịch vụ spa thư giãn cho thú cưng với các liệu trình đặc biệt',
      'price': 300000,
    });
    // await db.insert('spa_service', {
    //   'category_id': 3,
    //   'name': 'Khám sức khỏe tổng quát',
    //   'description': 'Dịch vụ kiểm tra sức khỏe tổng quát cho thú cưng',
    //   'price': 500000,
    // });
  }

  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return await db.insert('user', {
      'username': username,
      'password': password
    });
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query('user', where: 'username = ? AND password = ?', whereArgs: [
      username,
      password
    ]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('user', where: 'id = ?', whereArgs: [
      id
    ]);
  }

  Future<List<Map<String, dynamic>>> getSpaCategories() async {
    Database db = await instance.database;
    return await db.query('spa_category');
  }

  Future<List<Map<String, dynamic>>> getSpaServices(int categoryId) async {
    Database db = await instance.database;
    return await db.query('spa_service', where: 'category_id = ?', whereArgs: [
      categoryId
    ]);
  }

  Future<int> insertBooking(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('spa_calendar', row);
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String username) async {
    Database db = await instance.database;
    return await db.query('spa_calendar', where: 'username = ?', whereArgs: [
      username
    ]);
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    Database db = await instance.database;
    return await db.query('spa_calendar');
  }
}
