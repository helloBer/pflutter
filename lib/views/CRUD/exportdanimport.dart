import 'dart:io';

import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saverp_app/bloc/pemasukanKategori/pemasukanKategori_bloc.dart';
import 'package:saverp_app/bloc/pengeluaranKategori/pengeluaranKategori_bloc.dart';
import 'package:saverp_app/bloc/transaksi/transaksi_bloc.dart';
import 'package:saverp_app/database/koneksi.dart';
import 'package:saverp_app/database/pemasukanKategori_DAO.dart';
import 'package:saverp_app/database/pengeluaranKategori_DAO.dart';
import 'package:saverp_app/models/konfigurasiApps.dart';
import 'package:saverp_app/models/pemasukanKategori.dart';
import 'package:saverp_app/models/pengeluaranKategori.dart';
import 'package:saverp_app/models/transaksi.dart';
import 'package:saverp_app/models/widget.dart';

class ExportImport extends StatefulWidget {
  const ExportImport({super.key});

  @override
  State<ExportImport> createState() => _ExportImportState();
}

class _ExportImportState extends State<ExportImport> {
  void _addTransactionDB(
      Object category, DateTime date, double amount, String note) {
    if (category is ExpenseCategory) {
      context.read<TransactionBloc>().add(AddTransaction(
              transaction: Transaction(
            id: 0,
            expenseCategory: category,
            date: date,
            amount: amount,
            note: note,
          )));
    } else if (category is IncomeCategory) {
      context.read<TransactionBloc>().add(AddTransaction(
              transaction: Transaction(
            id: 0,
            incomeCategory: category,
            date: date,
            amount: amount,
            note: note,
          )));
    }
  }

  Future<void> _insertExpenseCategory(ExpenseCategory expenseCategory,
      void Function(ExpenseCategory) callback) async {
    final categoryState = context.read<ExpenseCategoryBloc>().state;
    if (categoryState is ExpenseCategoryLoaded) {
      final List<ExpenseCategory> categories = categoryState.category;
      final existingCategory = categories.firstWhereOrNull(
          (category) => category.name == expenseCategory.name);
      if (existingCategory == null) {
        final insertedId =
            await ExpenseCategoryDAO.insertExpenseCategory(expenseCategory);
        final updatedCategory = expenseCategory.copyWith(id: insertedId);
        if (context.mounted) {
          context
              .read<ExpenseCategoryBloc>()
              .add(AddExpenseCategory(category: updatedCategory));
        }
        callback(updatedCategory);
      } else {
        callback(existingCategory);
      }
    }
  }

  Future<void> _insertIncomeCategory(IncomeCategory incomeCategory,
      void Function(IncomeCategory) callback) async {
    final categoryState = context.read<IncomeCategoryBloc>().state;
    if (categoryState is IncomeCategoryLoaded) {
      final List<IncomeCategory> categories = categoryState.category;
      final existingCategory = categories
          .firstWhereOrNull((category) => category.name == incomeCategory.name);
      if (existingCategory == null) {
        final insertedId =
            await IncomeCategoryDAO.insertIncomeCategory(incomeCategory);
        final updatedCategory = incomeCategory.copyWith(id: insertedId);
        if (context.mounted) {
          context
              .read<IncomeCategoryBloc>()
              .add(AddIncomeCategory(category: updatedCategory));
        }
        callback(updatedCategory);
      } else {
        callback(existingCategory);
      }
    }
  }

  void _exportTransToCSV(BuildContext context) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    late final Map<Permission, PermissionStatus> statusess;

    if (androidInfo.version.sdkInt <= 32) {
      statusess = await [
        Permission.storage,
      ].request();
    } else {
      statusess = await [Permission.notification].request();
    }

    var allAccepted = true;
    statusess.forEach((permission, status) {
      if (status != PermissionStatus.granted) {
        allAccepted = false;
      }
    });

    if (allAccepted) {
      String? saveDirectory = await FilePicker.platform.getDirectoryPath();
      if (saveDirectory != null) {
        DatabaseHelper db = DatabaseHelper();
        var queryResult = await db.accessDatabase('''
              SELECT 
                A.jumlahTransaksi, strftime("%Y-%m-%d %H:%M:%S", A.tanggal) AS tanggal, A.deskripsi, 
                COALESCE(B.nama, C.nama) AS kategori,
                CASE
                  WHEN B.nama IS NOT NULL THEN 'Pengeluaran'
                  ELSE 'Pemasukan'
                END AS tipe
              FROM 
                Transaksi AS A 
                LEFT JOIN pengeluaranKategori AS B 
                  ON A.pengeluaranKategoriId = B.id
                LEFT JOIN pemasukanKategori AS C 
                  ON A.pemasukanKategoriId = C.id
            ''');

        List<String> csvData = [];
        // Add headers to the CSV data
        csvData.add(queryResult[0].keys.join(','));
        // Add rows to the CSV data
        for (var row in queryResult) {
          csvData.add(row.values.map((value) => value.toString()).join(','));
        }
        String csvString = csvData.join('\n');

        // final downloadPath = await getDownloadPath();
        String currentDate = DateFormat('yyyyMMdd').format(DateTime.now());
        String fileName = 'TransactionData_$currentDate.csv';

        final filepath = '$saveDirectory${Platform.pathSeparator}$fileName';

        try {
          // Save the CSV data to a file
          File file = File(filepath);
          await file.writeAsString(csvString, mode: FileMode.write);

          if (context.mounted) {
            _showPopup(context, 'Export Sukses', 'Data telah diexport!');
          }
          // NotificationService.showNotification(title: 'Success', body: 'CSV file exported', fln: flutterLocalNotificationsPlugin);
        } catch (e) {
          if (context.mounted) {
            _showPopup(context, 'Export Gagal', 'Data gagal diexport!');
          }
        }
      } else {
        if (context.mounted) {
          _showPopup(context, 'Export Gagal', 'Data gagal diexport!');
        }
      }
    }
  }

  void _importTransFromCSV(BuildContext context) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    late final Map<Permission, PermissionStatus> statusess;

    if (androidInfo.version.sdkInt <= 32) {
      statusess = await [
        Permission.storage,
      ].request();
    } else {
      statusess = await [Permission.notification].request();
    }

    var allAccepted = true;
    statusess.forEach((permission, status) {
      if (status != PermissionStatus.granted) {
        allAccepted = false;
      }
    });

    if (allAccepted) {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final lines = await file.readAsLines();

        final header = lines[0].replaceAll(';', ',').split(',');

        List<Map> listOfMap = [];

        for (var i = 1; i < lines.length; i++) {
          final values = lines[i].replaceAll(';', ',').split(',');
          var map = {};
          for (var j = 0; j < header.length; j++) {
            map[header[j]] = values[j];
          }

          if (map['kategori'] != null &&
              map['tanggal'] != null &&
              map['jumlahTransaksi'] != null &&
              map['deskripsi'] != null) {
            listOfMap.add(map);
          }
        }

        try {
          // Expense
          final List<ExpenseCategory> expenseCategories =
              await ExpenseCategoryDAO.getExpenseCategories();
          for (var i = 0; i < listOfMap.length; i++) {
            var map = listOfMap[i];

            ExpenseCategory? expenseCategory;
            for (ExpenseCategory temp in expenseCategories) {
              if (temp.name == map['kategori'] &&
                  map['tipe'] == 'Pengeluaran') {
                expenseCategory = temp;
                break;
              }
            }

            // If category exists
            if (expenseCategory != null) {
              _addTransactionDB(expenseCategory, DateTime.parse(map['tanggal']),
                  double.parse(map['jumlahTransaksi']), map['deskripsi']);
            } else {
              ExpenseCategory newCategory =
                  ExpenseCategory(id: 0, name: map['nama']);
              _insertExpenseCategory(newCategory, (newCategory) {
                _addTransactionDB(newCategory, DateTime.parse(map['tanggal']),
                    double.parse(map['jumlahTransaksi']), map['deskripsi']);
              });
            }
          }

          // Income
          final List<IncomeCategory> incomeCategories =
              await IncomeCategoryDAO.getIncomeCategories();
          for (var i = 0; i < listOfMap.length; i++) {
            var map = listOfMap[i];

            IncomeCategory? incomeCategory;
            for (IncomeCategory temp in incomeCategories) {
              if (temp.name == map['kategori'] && map['tipe'] == 'Pemasukan') {
                incomeCategory = temp;
                break;
              }
            }

            // If category exists
            if (incomeCategory != null) {
              _addTransactionDB(incomeCategory, DateTime.parse(map['tanggal']),
                  double.parse(map['jumlahTransaksi']), map['deskripsi']);
            } else {
              IncomeCategory newCategory =
                  IncomeCategory(id: 0, name: map['nama']);

              _insertIncomeCategory(newCategory, (newCategory) {
                _addTransactionDB(newCategory, DateTime.parse(map['tanggal']),
                    double.parse(map['jumlahTransaksi']), map['deskripsi']);
              });
            }
          }

          // Show notification
          if (context.mounted) {
            _showPopup(context, 'Import Success', 'Transaction data imported');
          }
        } catch (e) {
          if (context.mounted) {
            _showPopup(
                context, 'Import Failed', 'Transaction data import failed');
          }
        }
      }
    }
  }

  void _showPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Export dan Impor data'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _exportTransToCSV(context);
                },
                child: const CardContainer(
                  paddingBottom: 16,
                  paddingTop: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Export transactions to CSV'),
                      Icon(Icons.upload_rounded)
                    ],
                  ),
                ),
              ),
              GestureDetector(
                  onTap: () {
                    _importTransFromCSV(context);
                  },
                  child: const CardContainer(
                    paddingBottom: 16,
                    paddingTop: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Import transactions from CSV'),
                        Icon(Icons.download_rounded)
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
