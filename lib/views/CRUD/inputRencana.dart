import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saverp_app/bloc/rencanaAnggaran/rencanaAnggaran_bloc.dart';
import 'package:saverp_app/models/functions.dart';
import 'package:saverp_app/models/rencanaAnggaran.dart';
import 'package:saverp_app/models/widget.dart';
import 'package:saverp_app/views/template.dart';

class GoalsForm extends StatefulWidget {
  final Goal? initialValues;
  final String header1, header2;

  const GoalsForm(
      {required this.header1, this.header2 = '', this.initialValues, Key? key})
      : super(key: key);

  @override
  State<GoalsForm> createState() => _GoalsFormState();
}

class _GoalsFormState extends State<GoalsForm> {
  final _formKey = GlobalKey<FormState>();

  final GoalBloc categoryBloc = GoalBloc();
  Goal goal = Goal(id: 0, name: '', totalAmount: 0, progressAmount: 0);

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      goal = widget.initialValues!;
    }
  }

  Future<void> insertGoal() async {
    if (goal.name.isNotEmpty) {
      context.read<GoalBloc>().add(AddGoal(goal: goal));
    }
  }

  Future<void> updateGoal() async {
    context.read<GoalBloc>().add(UpdateGoal(goal: goal));
  }

  Future<void> deleteGoal() async {
    context.read<GoalBloc>().add(DeleteGoal(goal: goal));
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplate(
      formKey: _formKey,
      header1: widget.header1,
      header2: widget.header2,
      buttonText: widget.initialValues == null ? null : '',
      onSave: () {
        widget.initialValues == null ? insertGoal() : updateGoal();
      },
      onDelete: () {
        deleteGoal();
      },
      formInputs: Form(
        key: _formKey,
        child: Column(
          children: [
            FormTextInput(
              title: 'Nama Rencana',
              labelText: '....',
              isRequired: true,
              initalText: goal.name,
              onSave: (value) {
                goal.name = value!;
              },
              validateText: (value) {
                if (value == null || value.isEmpty) {
                  return 'Isi kolom ini';
                }
                return null;
              },
            ),
            FormTextInput(
              title: 'Progres Yang Terkumpul',
              labelText: 'Uang yang sudah terkumpul',
              isKeypad: true,
              useThousandSeparator: true,
              initalText: goal.progressAmount != null
                  ? amountDoubleToString(goal.progressAmount!)
                  : '',
              onSave: (value) {
                goal.progressAmount = amountStringToDouble(value!);
              },
            ),
            FormTextInput(
              title: 'Target',
              labelText: 'Jumlah target uang',
              isRequired: true,
              isKeypad: true,
              useThousandSeparator: true,
              initalText: goal.totalAmount != 0
                  ? amountDoubleToString(goal.totalAmount)
                  : '',
              onSave: (value) {
                goal.totalAmount = amountStringToDouble(value!);
              },
              validateText: (value) {
                if (value == null || value.isEmpty) {
                  return 'Isi kolom ini';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
