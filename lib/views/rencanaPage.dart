import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saverp_app/bloc/rencanaAnggaran/rencanaAnggaran_bloc.dart';
import 'package:saverp_app/models/functions.dart';
import 'package:saverp_app/models/konfigurasiApps.dart';
import 'package:saverp_app/models/rencanaAnggaran.dart';
import 'package:saverp_app/models/widget.dart';
import 'package:saverp_app/views/CRUD/inputRencana.dart';

// import 'package:searchbar_animation/searchbar_animation.dart';

class rencanaPage extends StatefulWidget {
  const rencanaPage({Key? key}) : super(key: key);

  @override
  State<rencanaPage> createState() => _rencanaPageState();
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

class _rencanaPageState extends State<rencanaPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 32,
          right: 32,
          top: MediaQuery.of(context).viewPadding.top + 24,
          bottom: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            text: 'Rencana Keuangan',
            firstChild: true,
            button: AddButton(
              text: 'Buat Rencana',
              onPressed: (context) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GoalsForm(
                            header1: 'Buat Rencana Baru',
                            header2: 'Catat Rencana Menabung anda!',
                          )),
                );
              },
            ),
          ),
          Divider(
            color: Colors.black,
            thickness: 1,
          ),
          BlocBuilder<GoalBloc, GoalState>(
            builder: (context, state) {
              if (state is GoalInitial || state is GoalUpdated) {
                context.read<GoalBloc>().add(const GetGoals());
              }
              if (state is GoalLoaded) {
                if (state.goal.isNotEmpty) {
                  return Column(
                    children: state.goal
                        .map((goalItem) => GoalsCard(goal: goalItem))
                        .toList(),
                  );
                }
              }
              return const NoDataWidget();
            },
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
                      const SectionTitle(text: 'Progress Rencana'),
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
    );
  }
}

class GoalsCard extends StatelessWidget {
  final Goal goal;

  const GoalsCard({required this.goal, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GoalsForm(
                    header1: 'Edit Rencana',
                    header2: 'Edit Rencana Keuangan',
                    initialValues: goal.copyWith(),
                  )),
        );
      },
      child: CardContainer(
        color: AppColors.primary,
        paddingBottom: 16,
        paddingTop: 16,
        marginBottom: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 8,
                ),
                Text(
                  'Rp ${amountDoubleToString(goal.totalAmount)}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
