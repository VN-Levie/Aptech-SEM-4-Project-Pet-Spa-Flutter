import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';

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
      join(await getDatabasesPath(), 'pet_spa_002.db'),
      onCreate: _onCreate,
      version: 12,
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

    // Bảng giỏ hàng
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price DECIMAL NOT NULL,
        category TEXT NOT NULL
      );
    ''');

    // Bảng đơn hàng
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        total_amount DECIMAL NOT NULL,
        payment_method TEXT NOT NULL,
        delivery_option TEXT NOT NULL,
        order_date DATE NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        imageUrl TEXT,
        category TEXT
      );
    ''');

    // Thêm dữ liệu mẫu cho bảng spa_category và spa_service
    await db.insert('spa_category', {'name': 'Grooming', 'description': 'Dịch vụ tắm và cắt tỉa lông'});
    await db.insert('spa_category', {'name': 'Spa', 'description': 'Dịch vụ spa thư giãn cho thú cưng'});

    await db.insert('spa_service', {'category_id': 1, 'name': 'Tắm và sấy khô', 'description': 'Dịch vụ tắm và sấy khô cho thú cưng', 'price': 150000});
    await db.insert('spa_service', {'category_id': 1, 'name': 'Cắt tỉa lông', 'description': 'Dịch vụ cắt tỉa lông cho thú cưng', 'price': 200000});
    await db.insert('spa_service', {'category_id': 2, 'name': 'Spa thư giãn', 'description': 'Dịch vụ spa thư giãn cho thú cưng với các liệu trình đặc biệt', 'price': 300000});

    // Gọi hàm để tạo sản phẩm mẫu nếu cần
    await generateProductsIfNeeded(db);
  }

  // Hàm tạo sản phẩm mẫu nếu chưa có sản phẩm nào trong database
  Future<void> generateProductsIfNeeded(Database db) async {
    final List<Map<String, dynamic>> existingProducts = await db.query('products');

    // Nếu chưa có sản phẩm nào trong database, tạo mới
    if (existingProducts.isEmpty) {
      List<Map<String, dynamic>> productList = [];

      // Danh sách các danh mục
      List<Map<String, dynamic>> categories = [
        {'name': 'Thức ăn', 'names': foodNames},
        {'name': 'Đồ chơi', 'names': toyNames},
        {'name': 'Phụ kiện', 'names': accessoryNames},
        {'name': 'Quần áo', 'names': clothesNames},
        {'name': 'Vòng cổ', 'names': collarNames},
        {'name': 'Dây dẫn', 'names': leashNames},
      ];

      // Tạo sản phẩm cho mỗi danh mục
      for (int i = 0; i < categories.length; i++) {
        String category = categories[i]['name'];
        List<String> productNames = categories[i]['names'];

        // Tạo số sản phẩm ngẫu nhiên cho mỗi danh mục (từ 3 đến 10)
        int productCount = Random().nextInt(8) + 3;

        for (int j = 0; j < productCount; j++) {
          // Tạo số ngẫu nhiên từ 1 đến 9 cho hình ảnh
          int randomImageNumber = Random().nextInt(9) + 1;

          // Chọn tên sản phẩm ngẫu nhiên từ danh sách
          String productName = '${productNames[Random().nextInt(productNames.length)]} $randomImageNumber';

          // Tạo một sản phẩm mới
          Map<String, dynamic> product = {
            'name': productName,
            'price': 100.0 + j * 10 + (i * 5), // Giá tăng dần theo số lượng và danh mục
            'imageUrl': 'https://via.placeholder.com/500?text=$productName',
            'category': category
          };

          productList.add(product);
        }
      }

      // Thêm tất cả sản phẩm vào database
      for (var product in productList) {
        await db.insert('products', product);
      }

      print('Đã thêm sản phẩm mẫu vào SQLite theo danh mục.');
    } else {
      print('Đã có sản phẩm trong cơ sở dữ liệu, không cần tạo mới.');
    }
  }

  // Danh sách các tên sản phẩm hợp lý dựa trên từng danh mục
  List<String> foodNames = ['Thức ăn cho chó', 'Thức ăn cho mèo', 'Snack cho chó', 'Snack cho mèo', 'Hạt dinh dưỡng', 'Thức ăn khô'];
  List<String> toyNames = ['Bóng đồ chơi', 'Xương gặm cao su', 'Đồ chơi nhai', 'Đồ chơi phát âm', 'Dây thừng kéo co', 'Chuột đồ chơi'];
  List<String> accessoryNames = ['Vòng cổ chống ve', 'Vòng cổ thời trang', 'Vòng cổ phát sáng', 'Chuồng nuôi', 'Lồng vận chuyển', 'Giường cho thú cưng'];
  List<String> clothesNames = ['Áo khoác cho chó', 'Áo mưa cho mèo', 'Quần áo thời trang', 'Áo giữ ấm', 'Bộ đồ hóa trang', 'Áo phông'];
  List<String> collarNames = ['Vòng cổ da', 'Vòng cổ vải', 'Vòng cổ kim loại', 'Vòng cổ thông minh', 'Vòng cổ gắn chuông'];
  List<String> leashNames = ['Dây dẫn da', 'Dây dẫn tự cuộn', 'Dây dẫn phản quang', 'Dây dẫn xích kim loại', 'Dây dẫn co giãn'];

  // Phương thức giỏ hàng
  Future<int> insertCartItem(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('cart', row);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    Database db = await instance.database;
    return await db.query('cart');
  }

  Future<int> clearCart() async {
    Database db = await instance.database;
    return await db.delete('cart');
  }

  // Phương thức đơn hàng
  Future<int> createOrder(Map<String, dynamic> order) async {
    Database db = await instance.database;
    return await db.insert('orders', order);
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String username) async {
    Database db = await instance.database;
    return await db.query('orders', where: 'username = ?', whereArgs: [username]);
  }

    Future<int> insertUser(String username, String password) async {
    final db = await database;
    return await db.insert('user', {'username': username, 'password': password});
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query('user', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getSpaCategories() async {
    Database db = await instance.database;
    return await db.query('spa_category');
  }

  Future<List<Map<String, dynamic>>> getSpaServices(int categoryId) async {
    Database db = await instance.database;
    return await db.query('spa_service', where: 'category_id = ?', whereArgs: [categoryId]);
  }

  Future<int> insertBooking(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('spa_calendar', row);
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String username) async {
    Database db = await instance.database;
    return await db.query('spa_calendar', where: 'username = ?', whereArgs: [username]);
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    Database db = await instance.database;
    return await db.query('spa_calendar');
  }


}
