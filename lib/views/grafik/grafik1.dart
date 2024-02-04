import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:saverp_app/database/koneksi.dart';
import 'package:saverp_app/models/widget.dart';
import 'package:saverp_app/views/dashboard.dart';

class Grafik1 extends StatefulWidget {
  const Grafik1({Key? key}) : super(key: key);
  @override
  State<Grafik1> createState() => _Grafik1State();
}

class _Grafik1State extends State<Grafik1> {
  DatabaseHelper db = DatabaseHelper();
  List<FlSpot> chartData = [];

  Future<List<FlSpot>> getChartData() async {
    List<Map<String, Object?>> monthlyAmounts = await db.accessDatabase('''
  SELECT strftime('%Y-%m', tanggal) AS yearMonth, SUM(jumlahTransaksi) AS TotalTransaksi
  FROM Transaksi
  WHERE pengeluaranKategoriId IS NOT NULL
      GROUP BY yearMonth
      ORDER BY yearMonth ASC
''');

    chartData = monthlyAmounts.map((row) {
      String yearMonth = row['yearMonth'] as String;
      double y = row['TotalTransaksi'] as double;
      return FlSpot(_parseYearMonth(yearMonth), y);
    }).toList();

    return chartData;
  }

  double _parseYearMonth(String yearMonth) {
    List<String> parts = yearMonth.split('-');
    int year = int.tryParse(parts[0]) ?? 0;
    int month = int.tryParse(parts[1]) ?? 0;

    return (((month) * 10000) + year).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: FutureBuilder<List<FlSpot>>(
            future: getChartData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                chartData = snapshot.data!;
                if (chartData.isEmpty) {
                  return const NoDataWidget(text: 'Belum ada postingan');
                }
                return ExpenseChart(
                    data: chartData.length > 6
                        ? chartData.sublist(
                            chartData.length - 6,
                            chartData.length,
                          )
                        : chartData);
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
