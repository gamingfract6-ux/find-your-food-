import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal_log.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('find_your_food.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE meal_logs (
        id $idType,
        userId $textType,
        mealType $textType,
        timestamp $textType,
        foodName $textType,
        calories $realType,
        protein $realType,
        carbs $realType,
        fats $realType,
        fiber $realType,
        sugar $realType,
        sodium $realType,
        portion $textType,
        weightGrams $intType,
        imageUrl TEXT,
        notes TEXT
      )
    ''');

    // Create index on timestamp for faster queries
    await db.execute('''
      CREATE INDEX idx_meal_logs_timestamp ON meal_logs(timestamp DESC)
    ''');
  }

  // Insert meal log
  Future<MealLog> insertMealLog(MealLog mealLog) async {
    final db = await instance.database;
    final id = await db.insert('meal_logs', mealLog.toMap());
    return mealLog.copyWith(id: id);
  }

  // Get all meal logs
  Future<List<MealLog>> getAllMealLogs({String? userId}) async {
    final db = await instance.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'meal_logs',
      where: userId != null ? 'userId = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => MealLog.fromMap(maps[i]));
  }

  // Get meal logs for specific date
  Future<List<MealLog>> getMealLogsByDate(DateTime date, {String? userId}) async {
    final db = await instance.database;
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'meal_logs',
      where: userId != null 
        ? 'timestamp >= ? AND timestamp < ? AND userId = ?'
        : 'timestamp >= ? AND timestamp < ?',
      whereArgs: userId != null
        ? [startOfDay.toIso8601String(), endOfDay.toIso8601String(), userId]
        : [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) => MealLog.fromMap(maps[i]));
  }

  // Get meal logs for date range
  Future<List<MealLog>> getMealLogsInRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'meal_logs',
      where: userId != null
        ? 'timestamp >= ? AND timestamp < ? AND userId = ?'
        : 'timestamp >= ? AND timestamp < ?',
      whereArgs: userId != null
        ? [startDate.toIso8601String(), endDate.toIso8601String(), userId]
        : [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => MealLog.fromMap(maps[i]));
  }

  // Get meal logs by meal type for today
  Future<List<MealLog>> getTodayMealsByType(String mealType, {String? userId}) async {
    final today = DateTime.now();
    final todayLogs = await getMealLogsByDate(today, userId: userId);
    
    return todayLogs.where((log) => log.mealType == mealType).toList();
  }

  // Get total calories for date
  Future<double> getTotalCaloriesForDate(DateTime date, {String? userId}) async {
    final logs = await getMealLogsByDate(date, userId: userId);
    return logs.fold(0.0, (sum, log) => sum + log.calories);
  }

  // Get total macros for date
  Future<Map<String, double>> getTotalMacrosForDate(DateTime date, {String? userId}) async {
    final logs = await getMealLogsByDate(date, userId: userId);
    
    return {
      'calories': logs.fold(0.0, (sum, log) => sum + log.calories),
      'protein': logs.fold(0.0, (sum, log) => sum + log.protein),
      'carbs': logs.fold(0.0, (sum, log) => sum + log.carbs),
      'fats': logs.fold(0.0, (sum, log) => sum + log.fats),
    };
  }

  // Update meal log
  Future<int> updateMealLog(MealLog mealLog) async {
    final db = await instance.database;

    return db.update(
      'meal_logs',
      mealLog.toMap(),
      where: 'id = ?',
      whereArgs: [mealLog.id],
    );
  }

  // Delete meal log
  Future<int> deleteMealLog(int id) async {
    final db = await instance.database;

    return await db.delete(
      'meal_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all meal logs (for testing)
  Future<void> clearAllLogs() async {
    final db = await instance.database;
    await db.delete('meal_logs');
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}

// Extension to add copyWith to MealLog
extension MealLogExtension on MealLog {
  MealLog copyWith({
    int? id,
    String? userId,
    String? mealType,
    DateTime? timestamp,
    String? foodName,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    double? fiber,
    double? sugar,
    double? sodium,
    String? portion,
    int? weightGrams,
    String? imageUrl,
    String? notes,
  }) {
    return MealLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealType: mealType ?? this.mealType,
      timestamp: timestamp ?? this.timestamp,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      portion: portion ?? this.portion,
      weightGrams: weightGrams ?? this.weightGrams,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }
}
