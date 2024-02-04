// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

// class ExpenseCategory {
//   final int id;
//   final String name;
//   final String icon;

//   ExpenseCategory(this.id, this.name, this.icon);

//   factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
//     return ExpenseCategory(
//       map['id'],
//       map['nama'],
//       map['icon'],
//     );
//   }
// }

// class Transaction {
//   final int id;
//   final double amount;
//   final DateTime date;
//   final String note;
//   final int expenseCategoryId;

//   Transaction(
//       this.id, this.amount, this.date, this.note, this.expenseCategoryId);

//   factory Transaction.fromMap(Map<String, dynamic> map) {
//     return Transaction(
//       map['id'],
//       map['jumlahTransaksi'],
//       DateTime.parse(map['tanggal']),
//       map['deskripsi'],
//       map['pengeluaranKategoriId'],
//     );
//   }
// }

// class Grafik2 extends StatefulWidget {
//   @override
//   _Grafik2State createState() => _Grafik2State();
// }

// class _Grafik2State extends State<Grafik2> {
//   late Database _database;
//   final StreamController<List<PieChartSectionData>> _streamController =
//       StreamController<List<PieChartSectionData>>.broadcast();

//   @override
//   void initState() {
//     super.initState();
//     _initDatabase();
//     _updateChartData(); // Mulai pembaruan data secara realtime saat widget diinisialisasi
//   }

//   Future<void> _initDatabase() async {
//     _database = await openDatabase(
//       join(await getDatabasesPath(), 'database.db'),
//       version: 1,
//       //     onCreate: (db, version) async {
//       //       await db.execute('''
//       //         CREATE TABLE ExpenseCategories (
//       //           id INTEGER PRIMARY KEY,
//       //           name TEXT,
//       //           icon TEXT
//       //         )
//       //       ''');

//       //       await db.execute('''
//       //         CREATE TABLE Transactions (
//       //           id INTEGER PRIMARY KEY,
//       //           amount REAL,
//       //           date TEXT,
//       //           note TEXT,
//       //           expenseCategoryId INTEGER,
//       //           FOREIGN KEY (expenseCategoryId) REFERENCES ExpenseCategories (id)
//       //         )
//       //       ''');
//       // },
//     );
//   }

//   void _updateChartData() {
//     // Simulasi data pengeluaran yang berubah secara real-time
//     Timer.periodic(Duration(seconds: 2), (timer) async {
//       List<PieChartSectionData> sections = await _getExpenseData();

//       _streamController.add(sections);
//     });
//   }

//   Future<List<PieChartSectionData>> _getExpenseData() async {
//     final List<Map<String, dynamic>> expenseCategoriesData =
//         await _database.query('pengeluaranKategori');
//     final List<Map<String, dynamic>> transactionsData =
//         await _getTransactionsWithin30Days();

//     Map<int, double> expensePerCategory = {};

//     for (final transaction in transactionsData) {
//       final expenseCategoryId = transaction['pengeluaranKategoriId'];
//       final amount = transaction['jumlahTransaksi'] as double;

//       if (expenseCategoryId != null) {
//         expensePerCategory.update(expenseCategoryId, (value) => value + amount,
//             ifAbsent: () => amount);
//       }
//     }

//     double totalExpense =
//         expensePerCategory.values.reduce((value, element) => value + element);

//     List<PieChartSectionData> sections = expenseCategoriesData.map((category) {
//       final id = category['id'];
//       final name = category['nama'];
//       final icon = category['icon'];
//       final totalCategoryExpense = expensePerCategory[id] ?? 0.0;
//       final percentage = (totalCategoryExpense / totalExpense) * 100;

//       return PieChartSectionData(
//         color: Colors.primaries[id % Colors.primaries.length],
//         value: totalCategoryExpense,
//         title: '$name\n${percentage.toStringAsFixed(1)}%',
//       );
//     }).toList();

//     return sections;
//   }

//   Future<List<Map<String, dynamic>>> _getTransactionsWithin30Days() async {
//     final currentDate = DateTime.now();
//     final thirtyDaysAgo = currentDate.subtract(Duration(days: 90));

//     final String formattedCurrentDate =
//         DateFormat('yyyy-MM-dd').format(currentDate);
//     final String formattedThirtyDaysAgo =
//         DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);

//     return await _database.rawQuery(
//       '''
//     SELECT * FROM Transaksi
//     WHERE tanggal BETWEEN ? AND ?
//     ''',
//       [formattedThirtyDaysAgo, formattedCurrentDate],
//     );
//   }

//   @override
//   void dispose() {
//     _streamController.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: StreamBuilder<List<PieChartSectionData>>(
//         stream: _streamController.stream,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//             double totalExpense =
//                 snapshot.data!.fold(0, (total, item) => total + item.value);
//             return Column(
//               children: [
//                 Text(
//                   'Total Pengeluaran: \Rp${totalExpense.toStringAsFixed(totalExpense.truncateToDouble() == totalExpense ? 0 : 2)}',
//                   style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
//                 ),
//                 Center(
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           height: 200, // Ukuran widget pie chart disesuaikan
//                           child: PieChart(
//                             PieChartData(
//                               sections: snapshot.data ?? [],
//                               borderData: FlBorderData(show: false),
//                               sectionsSpace: 0,
//                               centerSpaceRadius: 40,
//                               startDegreeOffset: 90,
//                               pieTouchData: PieTouchData(
//                                 touchCallback:
//                                     (FlTouchEvent event, touchResponse) {},
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Column(
//                           children: snapshot.data!
//                               .where((item) =>
//                                   (item as PieChartSectionData).value > 0)
//                               .map((item) {
//                             final categoryData = item as PieChartSectionData;
//                             return ListTile(
//                               title: RichText(
//                                 text: TextSpan(
//                                   text: '☐ ',
//                                   style: TextStyle(
//                                     color: categoryData.color,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text:
//                                           '${categoryData.title!R.split('\n')[0]}: ${categoryData.title!.split('\n')[1]}',
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         color: categoryData.color,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return CircularProgressIndicator();
//           }
//         },
//       ),
//     );
//   }
// }
