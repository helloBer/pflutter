import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import 'package:intl/intl.dart';
import 'package:saverp_app/bloc/rencanaAnggaran/rencanaAnggaran_bloc.dart';
import 'package:saverp_app/database/koneksi.dart';
import 'package:saverp_app/models/functions.dart';
import 'package:saverp_app/models/konfigurasiApps.dart';
import 'package:saverp_app/models/widget.dart';
import 'package:saverp_app/navbar.dart';
import 'package:saverp_app/views/grafik/grafik1.dart';
import 'package:saverp_app/views/profilepengguna/inputNama.dart';
import 'package:saverp_app/views/rencanaPage.dart';
import 'package:saverp_app/views/riwayatTransaksi.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  DatabaseHelper db = DatabaseHelper();

  bool budgetMode = true;
  double budgetAmount = 0;
  String namaPengguna = '';
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    initializeValues();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<List<Map<String, Object?>>> getTransactionsFiltered() async {
    List<Map<String, Object?>> transactions = [];

    // if (dropdownText == 'Bulan Ini') {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('yyyy-MM').format(now);

    transactions = await db.accessDatabase('''
        SELECT 
          A.*, 
          B.id as pengeluaranKategoriId, B.nama as NamapengeluaranKategori, B.icon as pengeluaranKategoriIcon, 
          C.id as pemasukanKategoriId, C.nama as NamapemasukanKategori, C.icon as pemasukanKategoriIcon
        FROM 
          Transaksi AS A 
          LEFT JOIN pengeluaranKategori AS B ON A.pengeluaranKategoriId = B.id 
          LEFT JOIN pemasukanKategori AS C ON A.pemasukanKategoriId = C.id
        WHERE 
          strftime('%Y-%m', tanggal) = '$currentMonth'
      ''');

    return transactions;
  }

  void _redirectToLogin(namaPengguna) {
    if (namaPengguna == null || namaPengguna.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const inputNama()),
      );
    }
  }

  void initializeValues() async {
    String? getNamaPengguna = await getConfigurationString('user_name');

    _redirectToLogin(getNamaPengguna);

    setState(() {
      namaPengguna = getNamaPengguna ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: Stack(children: [
        CustomPaint(
          size: MediaQuery.of(context).size,
        ),
        Container(
          padding: EdgeInsets.only(
              left: 32,
              right: 32,
              top: MediaQuery.of(context).viewPadding.top + 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Hallo, ',
                      style: const TextStyle(color: Colors.black, fontSize: 30),
                      children: <TextSpan>[
                        TextSpan(
                            text: namaPengguna,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
              ),
              FutureBuilder<List<Map<String, Object?>>>(
                future: getTransactionsFiltered(),
                builder: (context, snapshot) {
                  List<Map<String, Object?>> transactions = snapshot.data ?? [];

                  double totalSaldo = 0;
                  double income = 0;
                  double expense = 0;

                  for (var transaction in transactions) {
                    double amount = transaction['jumlahTransaksi'] as double;

                    if (transaction['pengeluaranKategoriId'] != null) {
                      expense += amount;
                    } else {
                      income += amount;
                    }
                  }

                  totalSaldo = income - expense;
                  // }

                  return KartuLaporan(
                      totalSaldo: totalSaldo, income: income, expense: expense);
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 300,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(2),
                              child: TabBar(
                                unselectedLabelColor: kSecondaryColor,
                                labelColor: kPrimaryColor,
                                indicatorColor: Colors.white,
                                indicatorWeight: 2,
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                controller: tabController,
                                tabs: [
                                  Tab(
                                    text: 'Semua',
                                  ),
                                  Tab(
                                    text: 'Kategori',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            Grafik1(),
                            Grafik1(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SectionTitle(
                text: 'Literasi Keuangan',
                firstChild: true,
                button: AddButton(
                  text: 'Lihat Semua',
                  onPressed: (context) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavbarsaveRP(),
                      ),
                    );
                  },
                ),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
                height: 0.5,
              ),
              // LITERASI KEUANGAN DISINI //
              // LITERASI KEUANGAN DISINI //
              SectionTitle(
                text: 'Transaksi Terakhir',
                firstChild: true,
                button: AddButton(
                  text: 'Lihat Semua',
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => NavbarsaveRP(),
                      ),
                    );
                  },
                ),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
                height: 0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FutureBuilder<List<Map<String, Object?>>>(
                  future: getTransactionsFiltered(),
                  builder: (context,
                      AsyncSnapshot<List<Map<String, Object?>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Menampilkan widget loading atau indikator loading
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Menampilkan pesan error jika terjadi kesalahan
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // Lanjutkan dengan pengolahan data setelah mendapat snapshot yang sukses
                      List<Map<String, Object?>> transactions =
                          snapshot.data ?? [];

                      // Calculate the total amount for each category
                      final categoryTotalMap = <String, Map<String, dynamic>>{};
                      double totalAmount = 0;

                      for (var transaction in transactions) {
                        if (transaction['pengeluaranKategoriId'] != null) {
                          final category =
                              transaction['NamapengeluaranKategori'].toString();
                          final amount = double.parse(
                              transaction['jumlahTransaksi'].toString());
                          final icon =
                              transaction['pengeluaranKategoriIcon'].toString();

                          totalAmount += amount;

                          if (!categoryTotalMap.containsKey(category)) {
                            categoryTotalMap[category] = {
                              'jumlahTransaksi': amount,
                              'icon': icon,
                            };
                          } else {
                            categoryTotalMap[category]!['jumlahTransaksi'] +=
                                amount;
                          }
                        }
                      }

                      // Generate a list of Expenses widgets based on the category totals
                      final expenseWidgets =
                          categoryTotalMap.entries.map((entry) {
                        final category = entry.key;
                        final amount = entry.value['jumlahTransaksi'] as double;
                        final icon = entry.value['icon'] as String;

                        return Expenses(
                          text: category,
                          amount: amount,
                          icon: icon,
                          totalAmount: totalAmount,
                        );
                      }).toList();

                      // Sort the expenseWidgets list by amount in descending order
                      expenseWidgets
                          .sort((a, b) => b.amount.compareTo(a.amount));

                      // Batasi jumlah elemen yang ditampilkan menjadi maksimal tiga
                      final batasjumlahTransaksi =
                          expenseWidgets.take(3).toList();

                      if (batasjumlahTransaksi.isNotEmpty) {
                        return Column(
                          children: batasjumlahTransaksi,
                        );
                      } else {
                        return const NoDataWidget(text: 'Belum ada transaksi');
                      }
                    }
                  },
                ),
              ),
              BlocBuilder<GoalBloc, GoalState>(
                builder: (context, state) {
                  if (state is GoalInitial || state is GoalUpdated) {
                    context.read<GoalBloc>().add(const GetGoals());
                  }
                  if (state is GoalLoaded) {
                    if (state.goal.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                            text: 'Rencana Keuangan',
                            firstChild: true,
                            button: AddButton(
                              text: 'Lihat Semua',
                              onPressed: (context) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => rencanaPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 1,
                            height: 0.5,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ...state.goal.map((goalItem) => ListRencanaKeuangan(
                                title: goalItem.name,
                                progressAmount: goalItem.progressAmount,
                                totalAmount: goalItem.totalAmount,
                                progress: goalItem.totalAmount != 0
                                    ? (goalItem.progressAmount != null
                                        ? (goalItem.progressAmount! /
                                                goalItem.totalAmount) *
                                            100
                                        : 0)
                                    : 0,
                              )),
                        ],
                      );
                    }
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: IntrinsicWidth(
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                backgroundColor: AppColors.base300,
              ),
            ),
            RichText(
              text: const TextSpan(
                text: 'Warning\n',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Lorem ipsum dolor sit amet',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseChart extends StatelessWidget {
  ExpenseChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<FlSpot> data;

  late final double maxY =
      data.reduce((value, element) => value.y > element.y ? value : element).y;
  late final double minY =
      data.reduce((value, element) => value.y < element.y ? value : element).y;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      height: 240,
      paddingTop: 24,
      paddingRight: 24,
      paddingLeft: 8,
      paddingBottom: 8,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.base100,
              tooltipBorder: BorderSide(color: AppColors.primary, width: 1),
              tooltipPadding: const EdgeInsets.all(8),
              tooltipRoundedRadius: 2,
              tooltipMargin: 2,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                TextStyle textStyle = TextStyle(color: AppColors.neutral);
                return BarTooltipItem(
                  '${valueToTitle(group.x.toDouble())}\nRp ${addThousandSeperatorToString((rod.toY).toInt().toString())}',
                  textStyle,
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: 0.1,
                getTitlesWidget: bottomTitleWidgets,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: ((maxY + minY) / 2) * 0.5,
                getTitlesWidget: leftTitleWidgets,
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minY: max(minY - (maxY * 0.25), 0),
          maxY: maxY + (maxY * 0.25),
          barGroups: data.map((item) {
            return BarChartGroupData(
              x: item.x.toInt(),
              barRods: [
                BarChartRodData(
                  toY: item.y,
                  color: AppColors.primary,
                  width: 18,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ((maxY + minY) / 2) * 0.5,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.base200,
                strokeWidth: 1,
              );
            },
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 150),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }
}

class ListRencanaKeuangan extends StatelessWidget {
  final double progress;
  final double? progressAmount;
  final double totalAmount;
  final String title;

  const ListRencanaKeuangan(
      {required this.title,
      required this.progress,
      this.progressAmount,
      required this.totalAmount,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: CardContainer(
        paddingTop: 16,
        paddingBottom: 16,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child:
                      Text(title, style: TextStyle(color: AppColors.neutral)),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  progressAmount != null
                      ? Text(
                          '${amountDoubleToString(progressAmount!)} / ${amountDoubleToString(totalAmount)} ( ${progress.toStringAsFixed(1)}% )',
                          style:
                              TextStyle(color: AppColors.base300, fontSize: 12),
                        )
                      : Text(
                          '0 / ${amountDoubleToString(totalAmount)} ( 0% )',
                          style:
                              TextStyle(color: AppColors.base300, fontSize: 12),
                        ),
                ]),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progress / 100,
                      color: progress >= 100
                          ? AppColors.success
                          : AppColors.primary,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Expenses extends StatelessWidget {
  final String text;
  final String? icon;
  final double amount, totalAmount;

  const Expenses(
      {required this.text,
      required this.amount,
      required this.totalAmount,
      this.icon,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: icon != null
                          ? Icon(
                              deserializeIcon(jsonDecode(icon!)),
                              color: AppColors.primary,
                            )
                          : Text(
                              text.isNotEmpty
                                  ? text
                                      .split(" ")
                                      .map((e) => e[0])
                                      .take(2)
                                      .join()
                                      .toUpperCase()
                                  : "",
                              style: TextStyle(color: AppColors.primary),
                            ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                        text: text,
                        style: const TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                    text: 'Rp ${amountDoubleToString(amount)}',
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],
          ),
          const Divider(),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: amount / totalAmount,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class KartuLaporan extends StatelessWidget {
  final double income;
  final double expense;
  final double totalSaldo;

  const KartuLaporan({
    Key? key,
    required this.income,
    required this.expense,
    required this.totalSaldo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(2, 2), // changes position of shadow
            ),
          ]),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                  text: TextSpan(
                      text: 'Saldo',
                      style:
                          TextStyle(color: AppColors.base300, fontSize: 12))),
              RichText(
                  text: TextSpan(
                      text: 'Rp ${amountDoubleToString(totalSaldo)}',
                      style: TextStyle(
                          color: AppColors.base100,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
            ],
          ),
          Container(
            height: 24,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                          text: TextSpan(
                              text: 'Pengeluaran',
                              style: TextStyle(
                                  color: AppColors.base300, fontSize: 12))),
                      RichText(
                          text: TextSpan(
                              text: 'Rp ${amountDoubleToString(expense)}',
                              style: TextStyle(
                                  color: AppColors.base100, fontSize: 14))),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                          text: TextSpan(
                              text: 'Pemasukan',
                              style: TextStyle(
                                  color: AppColors.base300, fontSize: 12))),
                      RichText(
                          text: TextSpan(
                              text: 'Rp ${amountDoubleToString(income)}',
                              style: TextStyle(
                                  color: AppColors.base100, fontSize: 14))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String valueToTitle(double value) {
  String yearText = value.toInt().toString();
  String year = yearText.substring(yearText.length - 4);

  int month = value ~/ 10000;
  String monthText = monthIntToString(month);

  String finalString = '$monthText\n$year';

  return finalString;
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  String title = valueToTitle(value);

  Widget text = Text(
    title,
    style: const TextStyle(
      fontSize: 12,
    ),
    textAlign: TextAlign.center,
  );

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}

Widget leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(fontSize: 12);

  if (value >= 1000000) {
    return Text('${(value / 1000000).toStringAsFixed(1)}M',
        style: style, textAlign: TextAlign.left);
  } else if (value >= 1000) {
    return Text('${(value / 1000).toStringAsFixed(0)}K',
        style: style, textAlign: TextAlign.left);
  } else {
    String text = value.toInt().toString();
    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
