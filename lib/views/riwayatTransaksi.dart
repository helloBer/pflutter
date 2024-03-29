import 'dart:async';
import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import 'package:intl/intl.dart';
import 'package:saverp_app/bloc/transaksi/transaksi_bloc.dart';
import 'package:saverp_app/models/functions.dart';
import 'package:saverp_app/models/konfigurasiApps.dart';
import 'package:saverp_app/models/pengeluaranKategori.dart';
import 'package:saverp_app/models/transaksi.dart';
import 'package:saverp_app/models/widget.dart';
import 'package:saverp_app/views/CRUD/inputTransaksi.dart';

// import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:animated_search_bar/animated_search_bar.dart';

class TransaksiPage extends StatelessWidget {
  const TransaksiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 100),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [TransactionsContainer()],
      ),
    );
  }
}

class TransactionsContainer extends StatefulWidget {
  const TransactionsContainer({Key? key}) : super(key: key);

  @override
  TransactionsContainerState createState() => TransactionsContainerState();
}

class TransactionsContainerState extends State<TransactionsContainer> {
  bool datePicked = true;
  List<ExpenseCategory> categories = [];

  List<DateTime?> filterDateRange = [
    DateTime(DateTime.now().year, DateTime.now().month, 1),
    DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
  ];
  String filterDateRangeText = 'This Month';
  String customDateRangeText = 'Custom';

  List<DropdownMenuItem<String>> get dropdownDateRangeItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "All", child: Text("All")),
      const DropdownMenuItem(value: "This Month", child: Text("This Month")),
      const DropdownMenuItem(value: "Last Month", child: Text("Last Month")),
      DropdownMenuItem(value: "Custom", child: Text(customDateRangeText)),
    ];
    return menuItems;
  }

  void setDateRange(String dateRange) {
    DateTime now = DateTime.now();

    if (dateRange == 'This Month') {
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
      setState(() {
        filterDateRange = [startOfMonth, endOfMonth];
        datePicked = true;
      });
    } else if (dateRange == 'Last Month') {
      DateTime startOfMonth = DateTime(now.year, now.month - 1, 1);
      DateTime endOfMonth = DateTime(now.year, now.month, 0);
      setState(() {
        filterDateRange = [startOfMonth, endOfMonth];
        datePicked = true;
      });
    } else {
      setState(() {
        datePicked = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        selectedDayTextStyle:
            TextStyle(color: AppColors.base100, fontWeight: FontWeight.w700),
        selectedDayHighlightColor: AppColors.accent,
      ),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
      value: filterDateRange,
    );

    if (results != null && results.length == 2) {
      setState(() {
        filterDateRange = results;
        datePicked = true;
      });
    } else if (results != null && results.length == 1) {
      setState(() {
        filterDateRange = List.from(results)..addAll(results);
        datePicked = true;
      });
    } else {
      setState(() {
        datePicked = false;
        filterDateRangeText = 'All';
        customDateRangeText = 'Custom';
      });
    }
  }

  List<Transaction> _sortTransactions(List<Transaction> transactionList) {
    List<Transaction> sortedTransactions = [];

    sortedTransactions = List.from(transactionList)
      ..sort((a, b) {
        final dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) {
          return dateComparison;
        }
        return b.id.compareTo(a.id);
      });

    return sortedTransactions;
  }

  List<Transaction> _filterTransactions(List<Transaction> transactionList) {
    List<Transaction> results = [];

    if (datePicked) {
      results = transactionList.where((t) {
        final tDate = DateTime(t.date.year, t.date.month, t.date.day);
        final startDate = DateTime(filterDateRange[0]!.year,
            filterDateRange[0]!.month, filterDateRange[0]!.day);
        final endDate = DateTime(filterDateRange[1]!.year,
            filterDateRange[1]!.month, filterDateRange[1]!.day);
        return (tDate.isAfter(startDate) ||
                tDate.isAtSameMomentAs(startDate)) &&
            ((tDate.isBefore(endDate) || tDate.isAtSameMomentAs(endDate)));
      }).toList();
      // if (filterTagName != 'All Tag') {
      //   results = results.where((t) {
      //     return t.tags?.any((tag) => tag.name == filterTagName) ?? false;
      //   }).toList();
      // }
      // } else {
      //   // if (filterTagName != 'All Tag') {
      //   //   results = results.where((t) {
      //   //     return t.tags?.any((tag) => tag.name == filterTagName) ?? false;
      //   //   }).toList();
    } else {
      results = transactionList;
    }

    return results;
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(
      List<Transaction> transactions) {
    final Map<String, List<Transaction>> groupedTransactions = {};

    for (var transaction in transactions) {
      final String date = DateFormat('dd MMM yyyy').format(transaction
          .date); // Replace 'formatDate' with your date formatting logic

      if (groupedTransactions.containsKey(date)) {
        groupedTransactions[date]!.add(transaction);
      } else {
        groupedTransactions[date] = [transaction];
      }
    }

    return groupedTransactions;
  }

  double _calculateTotalAmount(List<Transaction> transactions) {
    double total = 0.0;
    for (final transaction in transactions) {
      if (transaction.expenseCategory != null) {
        total -= transaction.amount;
      } else {
        total += transaction.amount;
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const GetTransactions());
    // context.read<SubscriptionBloc>().add(const GetSubscriptions());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
          if (state is TransactionLoaded) {
            if (state is TransactionInitial || state is TransactionUpdated) {
              context.read<TransactionBloc>().add(const GetTransactions());
            }
            if (state.transaction.isEmpty) {
              return Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).viewPadding.top + 16,
                      bottom: 16),
                  color: AppColors.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Total',
                                style: TextStyle(
                                    color: AppColors.base100,
                                    fontWeight: FontWeight.bold),
                              )),
                          Text('Rp 0',
                              style: TextStyle(color: AppColors.base100)),
                        ],
                      ),
                    ],
                  ));
            }
            final List<Transaction> transactions =
                _sortTransactions(_filterTransactions(state.transaction));
            double totalAmount = _calculateTotalAmount(transactions);
            return Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewPadding.top + 16, bottom: 16),
              color: AppColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Total',
                            style: TextStyle(
                                color: AppColors.base100,
                                fontWeight: FontWeight.bold),
                          )),
                      Text('Rp ${amountDoubleToString(totalAmount)}',
                          style: TextStyle(color: AppColors.base100)),
                    ],
                  ),
                ],
              ),
            );
          }
          return Text('Rp -', style: TextStyle(color: AppColors.base100));
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8, top: 12),
                child: AnimatedSearchBar(
                  label: 'Search transactions',
                  onChanged: (value) {
                    print(value);
                    context.read<TransactionBloc>().add(SearchTransactions(query: value));
                  },
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(bottom: 8, top: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.only(left: 12, top: 3, bottom: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.base200),
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.base100,
                        ),
                        child: DropdownButton(
                          onChanged: (String? newValue) {
                            if (newValue == 'Custom') {
                              _selectDateRange(context);
                              setState(() {
                                customDateRangeText =
                                    '${DateFormat('dd MMM yyyy').format(filterDateRange[0]!)} - ${DateFormat('dd MMM yyyy').format(filterDateRange[1]!)}';
                              });
                            } else {
                              setDateRange(newValue!);
                            }
                            setState(() {
                              filterDateRangeText = newValue!;
                            });
                          },
                          value: filterDateRangeText,
                          items: dropdownDateRangeItems,
                          style:
                              TextStyle(color: AppColors.primary, fontSize: 12),
                          underline: const SizedBox(),
                          isDense: true,
                        ),
                      ),
                      //   BlocBuilder<TagBloc, TagState>(builder: (context, state) {
                      //     if (state is TagInitial) {
                      //       context.read<TagBloc>().add(const GetTags());
                      //     }
                      //     if (state is TagLoaded) {
                      //       final tags = state.tag
                      //           .map((tag) => tag.name)
                      //           .toList(); // Get list of categories
                      //       tags.insert(0, "All Tag"); // Add "All" to the list
                      //       final dropdownItems =
                      //           tags // Create DropdownMenuItem from the list
                      //               .map((tag) => DropdownMenuItem(
                      //                     value: tag,
                      //                     child: Text(tag),
                      //                   ))
                      //               .toList();
                      //       return Container(
                      //         padding: const EdgeInsets.only(
                      //             left: 12, top: 3, bottom: 3),
                      //         decoration: BoxDecoration(
                      //           border: Border.all(color: AppColors.base200),
                      //           borderRadius: BorderRadius.circular(4),
                      //           color: AppColors.base100,
                      //         ),
                      //         child: DropdownButton(
                      //           onChanged: (String? newValue) {
                      //             setState(() {
                      //               filterTagName = newValue!;
                      //             });
                      //           },
                      //           value: filterTagName,
                      //           items: dropdownItems,
                      //           style: TextStyle(
                      //               color: AppColors.primary, fontSize: 12),
                      //           underline: const SizedBox(),
                      //           isDense: true,
                      //         ),
                      //       );
                      //     }
                      //     return const NoDataWidget();
                      //   }),
                    ],
                  )),
              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionInitial ||
                      state is TransactionUpdated) {
                    context
                        .read<TransactionBloc>()
                        .add(const GetTransactions());
                  }
                  if (state is TransactionLoaded) {
                    if (state.transaction.isEmpty) {
                      return const NoDataWidget();
                    }

                    final List<Transaction> transactions = _sortTransactions(
                        _filterTransactions(state.transaction));
                    final Map<String, List<Transaction>> groupedTransactions =
                        _groupTransactionsByDate(transactions);

                    if (transactions.isEmpty) {
                      return const NoDataWidget();
                    } else {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final entry in groupedTransactions.entries)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: AppColors.neutral
                                                  .withOpacity(0.6)),
                                        ),
                                        Text(
                                          'Rp ${amountDoubleToString(_calculateTotalAmount(entry.value))}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: AppColors.neutral
                                                  .withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      for (final transaction in entry.value)
                                        TransactionCard(
                                          transaction: transaction,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }
                  }

                  return const NoDataWidget();
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}

class TransactionCard extends StatefulWidget {
  final Transaction transaction;

  const TransactionCard({required this.transaction, Key? key})
      : super(key: key);

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  String _title = '';
  String? _icon = '';
  String _objectType = '';

  @override
  void initState() {
    super.initState();
    if (widget.transaction.expenseCategory != null) {
      _title = widget.transaction.expenseCategory!.name;
      _icon = widget.transaction.expenseCategory?.icon;
      _objectType = 'pengeluaranKategori';
    } else {
      _title = widget.transaction.incomeCategory!.name;
      _icon = widget.transaction.incomeCategory?.icon;
      _objectType = 'pemasukanKategori';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TransactionForm(
                    header1: 'Edit transaction',
                    header2: 'Edit existing transaction',
                    initialValues: widget.transaction,
                  )),
        );
      },
      child: CardContainer(
        marginBottom: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: _icon != null
                        ? Icon(
                            deserializeIcon(jsonDecode(_icon!)),
                            color: AppColors.primary,
                          )
                        : Text(
                            _title.isNotEmpty
                                ? _title
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
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: _title,
                            style: const TextStyle(color: Colors.black)),
                      ),
                      (widget.transaction.note != null &&
                              widget.transaction.note!.isNotEmpty)
                          ? Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: RichText(
                                text: TextSpan(
                                  text: widget.transaction.note != null &&
                                          widget.transaction.note!.length > 22
                                      ? '${widget.transaction.note?.substring(0, 22)}...'
                                      : widget.transaction.note,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 11),
                                ),
                              ),
                            )
                          : Container(),
                      // Container(
                      //   margin: const EdgeInsets.only(top: 8),
                      //   child: Row(
                      //     children: [
                      //       for (var tag in widget.transaction.tags ??
                      //           [Tag(id: 0, name: 'nope', color: "#FFFFFF")])
                      //         Container(
                      //           margin: const EdgeInsets.only(right: 4),
                      //           padding: const EdgeInsets.symmetric(
                      //             vertical: 2,
                      //             horizontal: 4,
                      //           ),
                      //           decoration: BoxDecoration(
                      //             color: hexToColor(tag.color),
                      //             borderRadius: const BorderRadius.all(
                      //               Radius.circular(4),
                      //             ),
                      //           ),
                      //           child: Text(
                      //             tag.name,
                      //             style: TextStyle(
                      //                 fontSize: 11,
                      //                 color: getTextColorForBackground(
                      //                     hexToColor(tag.color))),
                      //           ),
                      //         ),
                      //     ],
                      //   ),
                      // )
                    ]),
              ],
            ),
            RichText(
              text: TextSpan(
                  text: 'Rp ${amountDoubleToString(widget.transaction.amount)}',
                  style: TextStyle(
                      color: _objectType == 'pengeluaranKategori'
                          ? AppColors.error
                          : AppColors.success,
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
