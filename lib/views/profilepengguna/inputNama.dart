import 'package:flutter/material.dart';
import 'package:saverp_app/models/konfigurasiApps.dart';
import 'package:saverp_app/models/functions.dart';
import 'package:saverp_app/navbar.dart';

class inputNama extends StatelessWidget {
  const inputNama({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double sizeV = SizeConfig.blockSizeV!;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        height: MediaQuery.of(context).size.height,
        color: kPrimaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset("assets/images/Logo.png"),
            ),
            SizedBox(
              height: sizeV * 2,
            ),
            const _InputNamaForm(),
          ],
        ),
      ),
    );
  }
}

class _InputNamaForm extends StatefulWidget {
  const _InputNamaForm();
  @override
  State<_InputNamaForm> createState() => _InputNamaFormState();
}

class _InputNamaFormState extends State<_InputNamaForm> {
  final TextEditingController _namaUserController = TextEditingController();

  String namaPengguna = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeValues();
  }

  void initializeValues() async {
    String? getNamaPengguna = await getConfigurationString('user_name');

    setState(() {
      namaPengguna = getNamaPengguna ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: (namaPengguna == null || namaPengguna.isEmpty)
                ? 'Masukkan nama anda'
                : 'Silahkan ubah nama',
            style: TextStyle(
                color: AppColors.base100,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 36),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: AppColors.base100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(2, 2),
                ),
              ]),
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Isi Disini';
                  }
                  return null;
                },
                maxLength: 20,
                controller: _namaUserController,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: AppColors.base300, fontSize: 14),
                  hintText: "Nama ",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.base300),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kSecondaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            final String name = _namaUserController.text;
            saveConfiguration('user_name', name);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NavbarsaveRP()),
            );
          },
          child: Container(
              margin: const EdgeInsets.only(top: 1),
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 100),
              decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Masuk',
                style: TextStyle(color: AppColors.base100),
              )),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _namaUserController.dispose();
    super.dispose();
  }
}
