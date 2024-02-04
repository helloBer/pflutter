import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saverp_app/bloc/pemasukanKategori/pemasukanKategori_bloc.dart';
import 'package:saverp_app/bloc/pengeluaranKategori/pengeluaranKategori_bloc.dart';
import 'package:saverp_app/bloc/rencanaAnggaran/rencanaAnggaran_bloc.dart';
import 'package:saverp_app/bloc/transaksi/transaksi_bloc.dart';
import 'package:saverp_app/navbar.dart';
import 'package:saverp_app/views/InfoApps/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool? cekOnboarding;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  SharedPreferences pref = await SharedPreferences.getInstance();
  cekOnboarding = pref.getBool('cekOnboarding') ?? false;
  // runApp(const MyApp());
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<ExpenseCategoryBloc>(
        create: (BuildContext context) => ExpenseCategoryBloc(),
      ),
      BlocProvider<IncomeCategoryBloc>(
        create: (BuildContext context) => IncomeCategoryBloc(),
      ),
      BlocProvider<TransactionBloc>(
        create: (BuildContext context) => TransactionBloc(),
      ),
      BlocProvider<GoalBloc>(
        create: (BuildContext context) => GoalBloc(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'saveRP',
      theme: ThemeData(
          textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme)),
      debugShowCheckedModeBanner: false,
      home: cekOnboarding == true ? NavbarsaveRP() : OnBoardingPage(),
    );
  }
}
