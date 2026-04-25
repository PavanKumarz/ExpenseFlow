import 'package:expenseflow/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_flow.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            type TEXT,
            category TEXT,
            date TEXT,
            notes TEXT
          )
          ''');
      },
    );
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    Database db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'id DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<Map<String, double>> getSummary() async {
    Database db = await database;

    final incomeResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'",
    );
    final expenseResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'",
    );

    double totalIncome =
        (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    double totalExpense =
        (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;
    double balance = totalIncome - totalExpense;

    return {'income': totalIncome, 'expense': totalExpense, 'balance': balance};
  }

  Future<int> deleteTransaction(int id) async {
    Database db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getDailySummary(int days) async {
    Database db = await database;
    List<Map<String, dynamic>> summary = [];

    DateTime now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String dateStr =
          "${day.month.toString().padLeft(2, '0')}/"
          "${day.day.toString().padLeft(2, '0')}/"
          "${day.year}";

      final incomeResult = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'income' AND date = ?",
        [dateStr],
      );
      final expenseResult = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense' AND date = ?",
        [dateStr],
      );

      summary.add({
        'date': dateStr,
        'day': _getDayName(day.weekday),
        'income': (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0,
        'expense': (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0,
      });
    }

    return summary;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }

  String formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<Map<String, double>> getSummaryForRange(
    DateTime start,
    DateTime end,
  ) async {
    Database db = await database;
    double totalIncome = 0;
    double totalExpense = 0;

    // We iterate through days because dates are stored as strings MM/DD/YYYY
    DateTime current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String dateStr = formatDate(current);
      final incomeResult = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'income' AND date = ?",
        [dateStr],
      );
      final expenseResult = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense' AND date = ?",
        [dateStr],
      );

      totalIncome += (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
      totalExpense += (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;
      current = current.add(const Duration(days: 1));
    }

    return {'income': totalIncome, 'expense': totalExpense};
  }

  Future<List<Map<String, dynamic>>> getCategorySummary(
    DateTime start,
    DateTime end,
    String type,
  ) async {
    Database db = await database;
    Map<String, double> categoryTotals = {};

    DateTime current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String dateStr = formatDate(current);
      final results = await db.query(
        'transactions',
        where: 'date = ? AND type = ?',
        whereArgs: [dateStr, type],
      );

      for (var row in results) {
        String category = row['category'] as String;
        double amount = (row['amount'] as num).toDouble();
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
      }
      current = current.add(const Duration(days: 1));
    }

    List<Map<String, dynamic>> summary = [];
    categoryTotals.forEach((category, total) {
      summary.add({'category': category, 'amount': total});
    });

    // Sort by amount descending
    summary.sort((a, b) => (b['amount'] as double).compareTo(a['amount']));

    return summary;
  }

  Future<List<Map<String, dynamic>>> getDailySummaryForRange(
    DateTime start,
    DateTime end,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> summary = [];

    DateTime current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String dateStr = formatDate(current);

      final incomeResult = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'income' AND date = ?",
        [dateStr],
      );
      final expenseResult = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense' AND date = ?",
        [dateStr],
      );

      summary.add({
        'date': dateStr,
        'day': _getDayName(current.weekday),
        'income': (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0,
        'expense': (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0,
      });

      current = current.add(const Duration(days: 1));
    }

    return summary;
  }
}
