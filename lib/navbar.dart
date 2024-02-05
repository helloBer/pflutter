import 'package:flutter/material.dart';
import 'package:saverp_app/models/functions.dart';
import 'package:saverp_app/models/konfigurasiApps.dart';
import 'package:saverp_app/views/dashboard.dart';
import 'package:saverp_app/views/lainnyaPage.dart';
import 'package:saverp_app/views/rencanaPage.dart';
import 'package:saverp_app/views/riwayatTransaksi.dart';

class NavbarsaveRP extends StatefulWidget {
  const NavbarsaveRP({Key? key}) : super(key: key);

  @override
  NavbarsaveRPState createState() => NavbarsaveRPState();
}

class NavbarsaveRPState extends State<NavbarsaveRP> {
  int _currentIndex = 0;

  List<Widget> _children = [];

  @override
  void initState() {
    _children = [
      const DashboardPage(),
      const TransaksiPage(),
      const TransaksiPage(),
      const rencanaPage(),
      const pageLainnya()
    ];
    super.initState();
  }

  void changeScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_currentIndex);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(child: _children[_currentIndex]),
      ),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      floatingActionButtonAnimator: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: SizedBox(
          height: 64,
          width: 64,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                openBottomModalCategory(context, changeScreen);
              },
              backgroundColor: kPrimaryColor,
              child: Icon(Icons.add, color: AppColors.base100),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 12),
        height: 72,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: kSecondaryColor)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100000),
            child: Container(
              child: Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  iconSize: 18,
                  elevation: 1,
                  showSelectedLabels: true,
                  showUnselectedLabels: false,
                  selectedItemColor: kPrimaryColor,
                  unselectedItemColor: kSecondaryColor,
                  backgroundColor: kNetralColor,
                  currentIndex: _currentIndex,
                  onTap: changeScreen,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bar_chart),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.receipt),
                      label: 'Transaksi',
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox.shrink(),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.tune),
                      label: 'Buat Rencana',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.more_horiz),
                      label: 'Lainnya',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
