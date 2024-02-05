import 'package:saverp_app/database/koneksi.dart';
import 'package:saverp_app/models/pemasukanKategori.dart';
import 'package:saverp_app/models/pengeluaranKategori.dart';
import 'package:saverp_app/models/transaksi.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:intl/intl.dart';

// Data Access Object
class TransactionDAO {
  static Future<int> insertTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.initializeDB();
    final transactionData = transaction.toMap();
    transactionData.remove('id');

    // final List<Map<String, dynamic>> tagsData = transaction.tags!.map((tag) {
    //   return {
    //     'transactionId': 0,
    //     'tagId': tag.id,
    //     'createdAt': transactionData['createdAt'],
    //   };
    // }).toList();

    // transactionData.remove('tags');

    // Insert into Transactions table
    final int transactionId = await db.insert('Transaksi', transactionData,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    // Update the 'transactionId' field in the tagsData list with the actual transaction ID
    // for (var tagData in tagsData) {
    //   tagData['transactionId'] = transactionId;
    // }

    // Insert into TransactionTags table
    // for (var tag in tagsData) {
    //   await db.insert('TransactionTags', tag,
    //       conflictAlgorithm: sql.ConflictAlgorithm.replace);
    // }

    return transactionId;
  }

  static Future<List<Transaction>> getTransactions() async {
    final db = await DatabaseHelper.initializeDB();

    final List<Map<String, Object?>> queryResult = await db.rawQuery("""
            SELECT 
        A.*, 
        B.id as PengeluaranKategoriId, B.nama as NamapengeluaranKategori, B.icon as IconpengeluaranKategori,
        C.id as PemasukanKategoriId, C.nama as NamapemasukanKategori, C.icon as IconpemasukanKategori
      FROM Transaksi AS A 
        LEFT JOIN pengeluaranKategori AS B ON A.pengeluaranKategoriId = B.id 
        LEFT JOIN pemasukanKategori AS C ON A.pemasukanKategoriId = C.id 
      ORDER BY A.tanggal DESC
    """);

    final Map<int, Transaction> transactionsMap = {};

    for (var e in queryResult) {
      ExpenseCategory? expenseCategory;
      if (e['PengeluaranKategoriId'] != null) {
        var expenseCategoryMap = {
          'id': e['PengeluaranKategoriId'],
          'nama': e['NamapengeluaranKategori'],
          'icon': e['IconpengeluaranKategori']
        };
        expenseCategory = ExpenseCategory.fromMap(expenseCategoryMap);
      }

      IncomeCategory? incomeCategory;
      if (e['PemasukanKategoriId'] != null) {
        var incomeCategoryMap = {
          'id': e['PemasukanKategoriId'],
          'nama': e['NamapemasukanKategori'],
          'icon': e['IconpemasukanKategori']
        };
        incomeCategory = IncomeCategory.fromMap(incomeCategoryMap);
      }

      final transactionId = e['id'] as int;

      final formattedDate = DateFormat('dd MM yyyy')
          .format(DateTime.parse(e['tanggal'] as String));
      final dateWithoutTime = DateFormat('dd MM yyyy').parse(formattedDate);

      // Check if the transaction is already in the map
      if (!transactionsMap.containsKey(transactionId)) {
        // If not, create a new Transaction object
        final transaction = Transaction.fromMap(
          e,
          expenseCategory: expenseCategory,
          incomeCategory: incomeCategory,
        );

        transaction.date = dateWithoutTime;
        transactionsMap[transactionId] = transaction;
      }
    }

    // print(transactionsMap.values.toList());
    // call getby note
    final debuggetbynote = await getTransactionsByNote('');
    // print(debuggetbynote);
    // return transactionsMap.values.toList();
    return debuggetbynote;
  }

  static Future<int> updateTransaction(Transaction transaction,
      ExpenseCategory? expenseCategory, IncomeCategory? incomeCategory) async {
    final db = await DatabaseHelper.initializeDB();

    // Prepare the data for the update
    final data = {
      'pengeluaranKategoriId': expenseCategory?.id,
      'pemasukanKategoriId': incomeCategory?.id,
      'tanggal': transaction.date.toIso8601String(),
      'jumlahTransaksi': transaction.amount,
      'deskripsi': transaction.note,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Update the main transaction data
    final result = await db.update('Transaksi', data,
        where: "id = ?", whereArgs: [transaction.id]);

    // Update tags separately
    // await _updateTransactionTags(db, transaction);

    return result;
  }

  // static Future<void>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               (db, transaction) async {
  //   // Delete existing tags for the transaction
  //   await db.delete('TransactionTags',
  //       where: 'transactionId = ?', whereArgs: [transaction.id]);

  //   // Insert new tags for the transaction
  //   for (var tag in transaction.tags) {
  //     await db.insert('TransactionTags', {
  //       'transactionId': transaction.id,
  //       'tagId': tag.id,
  //       'createdAt': DateTime.now().toIso8601String(),
  //     });
  //   }
  // }

  static Future<void> deleteTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.initializeDB();

    // Delete the main transaction
    await db.delete("Transaksi", where: "id = ?", whereArgs: [transaction.id]);

    // // Delete the associated tags
    // await db.delete("TransactionTags",
    //     where: "transactionId = ?", whereArgs: [transaction.id]);
  }

  static Future<List<Transaction>> getTransactionsByNote(String note) async {
    final db = await DatabaseHelper.initializeDB();
    final transactionsMap = <int, Transaction>{};

    final queryResult = await db.rawQuery('''
          SELECT 
            A.*, 
            B.id as PengeluaranKategoriId, B.nama as NamapengeluaranKategori, B.icon as IconpengeluaranKategori,
            C.id as PemasukanKategoriId, C.nama as NamapemasukanKategori, C.icon as IconpemasukanKategori
          FROM Transaksi AS A 
            LEFT JOIN pengeluaranKategori AS B ON A.pengeluaranKategoriId = B.id 
            LEFT JOIN pemasukanKategori AS C ON A.pemasukanKategoriId = C.id 
          WHERE A.deskripsi LIKE ?
        ''', ['%$note%']);
    // print(queryResult);
    for (var e in queryResult) {
      ExpenseCategory? expenseCategory;
      if (e['PengeluaranKategoriId'] != null) {
        var expenseCategoryMap = {
          'id': e['PengeluaranKategoriId'],
          'nama': e['NamapengeluaranKategori'],
          'icon': e['IconpengeluaranKategori']
        };
        expenseCategory = ExpenseCategory.fromMap(expenseCategoryMap);
      }

      IncomeCategory? incomeCategory;
      if (e['PemasukanKategoriId'] != null) {
        var incomeCategoryMap = {
          'id': e['PemasukanKategoriId'],
          'nama': e['NamapemasukanKategori'],
          'icon': e['IconpemasukanKategori']
        };
        incomeCategory = IncomeCategory.fromMap(incomeCategoryMap);
      }

      final transactionId = e['id'] as int;

      final formattedDate = DateFormat('dd MM yyyy')
          .format(DateTime.parse(e['tanggal'] as String));
      final dateWithoutTime = DateFormat('dd MM yyyy').parse(formattedDate);

      // Check if the transaction is already in the map
      if (!transactionsMap.containsKey(transactionId)) {
        // If not, create a new Transaction object
        final transaction = Transaction.fromMap(
          e,
          expenseCategory: expenseCategory,
          incomeCategory: incomeCategory,
        );

        transaction.date = dateWithoutTime;
        transactionsMap[transactionId] = transaction;
      }
    }
    // print(transactionsMap.values.toList());
    // print(transactionsMap.values);
    return transactionsMap.values.toList();
  }
}
