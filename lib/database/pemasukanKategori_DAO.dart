import 'package:saverp_app/database/koneksi.dart';
import 'package:saverp_app/models/pemasukanKategori.dart';
import 'package:sqflite/sqflite.dart' as sql;

// Data Access Object
class IncomeCategoryDAO {
  // Insert
  static Future<int> insertIncomeCategory(IncomeCategory category) async {
    final db = await DatabaseHelper.initializeDB();
    final data = category.toMap();
    data.remove('id');
    final id = await db.insert('pemasukanKategori', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  // Select
  static Future<List<IncomeCategory>> getIncomeCategories() async {
    final db = await DatabaseHelper.initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('pemasukanKategori');
    return queryResult.map((e) => IncomeCategory.fromMap(e)).toList();
  }

  static Future<List<IncomeCategory>> getIncomeCategoryIDbyName(
      String name) async {
    final db = await DatabaseHelper.initializeDB();
    final List<Map<String, Object?>> queryResult = await db
        .query('pemasukanKategori', where: "nama = ?", whereArgs: [name]);
    return queryResult.map((e) => IncomeCategory.fromMap(e)).toList();
  }

  static Future<List<IncomeCategory>> getIncomeCategorybyID(int id) async {
    final db = await DatabaseHelper.initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('pemasukanKategori', where: "id = ?", whereArgs: [id]);
    return queryResult.map((e) => IncomeCategory.fromMap(e)).toList();
  }

  // Update
  static Future<int> updateIncomeCategory(IncomeCategory category) async {
    final db = await DatabaseHelper.initializeDB();

    final data = {
      'nama': category.name,
      'icon': category.icon,
      'createdAt': DateTime.now().toString()
    };

    final result = await db.update('pemasukanKategori', data,
        where: "id = ?", whereArgs: [category.id]);
    return result;
  }

  // Delete
  static Future<void> deleteIncomeCategory(IncomeCategory category) async {
    final db = await DatabaseHelper.initializeDB();
    await db
        .delete("pemasukanKategori", where: "id = ?", whereArgs: [category.id]);
  }
}
