import 'package:flutter/material.dart';
import 'package:saverp_app/database/koneksi.dart';
import 'package:saverp_app/models/functions.dart';
import 'package:saverp_app/models/konfigurasiApps.dart';
import 'package:saverp_app/models/widget.dart';
import 'package:saverp_app/views/CRUD/exportdanimport.dart';
import 'package:saverp_app/views/InfoApps/onboarding.dart';
import 'package:saverp_app/views/profilepengguna/inputNama.dart';

class pageLainnya extends StatefulWidget {
  const pageLainnya({super.key});

  @override
  State<pageLainnya> createState() => _pageLainnyaState();
}

class _pageLainnyaState extends State<pageLainnya> {
  DatabaseHelper db = DatabaseHelper();
  String NamaPengguna = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeValues();
  }

  void initializeValues() async {
    String? getNamaPengguna = await getConfigurationString('user_name');

    setState(() {
      // budgetMode = budgetModeValue ?? true;
      // budgetAmount = budgetAmountValue ?? 0;
      NamaPengguna = getNamaPengguna ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.primary,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 40, 20, 0),
            child: Row(
                // mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: Color(0xFF30B2A3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/pprofile.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            NamaPengguna,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(1.0),
                            child: IconButton(
                              icon: Icon(Icons.settings,
                                  size: 25.0, color: Color(0xff3E454C)),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => inputNama(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ),
        Divider(
          color: Colors.black,
          thickness: 1,
          height: 0.5,
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                // Navigasi ke halaman ImportdanExport() saat di-tap
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ExportImport()));
              },
              child: const CardContainer(
                paddingBottom: 16,
                paddingTop: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Export/Import data'), Icon(Icons.info)],
                ),
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.black,
          thickness: 1,
          height: 0.5,
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OnBoardingPage()));
              },
              child: const CardContainer(
                paddingBottom: 16,
                paddingTop: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Informasi Aplikasi'), Icon(Icons.info)],
                ),
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.black,
          thickness: 1,
          height: 0.5,
        ),
      ],
    );
  }
}
