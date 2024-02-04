import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:saverp_app/main.dart';
import 'package:saverp_app/views/InfoApps/data_onboarding.dart';
import 'package:saverp_app/models/konfigurasiApps.dart';
import 'package:saverp_app/navbar.dart';
import 'package:saverp_app/views/dashboard.dart';
import 'package:saverp_app/views/profilepengguna/inputNama.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int HalamanApps = 0;
  PageController _pageController = PageController(initialPage: 0);

  AnimatedContainer dotIndicator(index) {
    return AnimatedContainer(
      margin: EdgeInsets.only(right: 5),
      duration: Duration(milliseconds: 400),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: HalamanApps == index ? kPrimaryColor : kSecondaryColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Future setcekOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cekOnboarding = await prefs.setBool('cekOnboarding', true);
  }

  @override
  void initState() {
    super.initState();
    setcekOnboarding();
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double sizeV = SizeConfig.blockSizeV!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BGOngoingScreen.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
            child: Column(
          children: [
            Container(
              child: Image.asset("assets/images/logoongoing.png"),
            ),
            SizedBox(
              height: sizeV * 2,
            ),
            Expanded(
                flex: 7,
                child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) {
                      setState(() {
                        HalamanApps = value;
                      });
                    },
                    itemCount: onboardingContents.length,
                    itemBuilder: (context, index) => Column(
                          children: [
                            Container(
                              child:
                                  Image.asset(onboardingContents[index].image),
                            ),
                            SizedBox(
                              height: sizeV * 2,
                            ),
                            Text(
                              onboardingContents[index].title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                            SizedBox(
                              height: sizeV * 2,
                            ),
                            Text(
                              onboardingContents[index].deskripsi,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ))),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  HalamanApps == onboardingContents.length - 1
                      ? ButtonMulai(
                          buttonName: 'Mulai',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NavbarsaveRP()));
                          },
                          bgColor: kPrimaryColor,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            NavButtonOB(
                              name: 'Lewati',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NavbarsaveRP()));
                              },
                            ),
                            Row(
                              children: List.generate(onboardingContents.length,
                                  (index) => dotIndicator(index)),
                            ),
                            NavButtonOB(
                                name: 'Lanjut',
                                onPressed: () {
                                  _pageController.nextPage(
                                      duration: Duration(milliseconds: 400),
                                      curve: Curves.easeInOut);
                                }),
                          ],
                        ),
                ],
              ),
            )
          ],
        )),
      ),
    );
  }
}

class ButtonMulai extends StatelessWidget {
  const ButtonMulai({
    super.key,
    required this.buttonName,
    required this.onPressed,
    required this.bgColor,
  });
  final String buttonName;
  final VoidCallback onPressed;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
          height: SizeConfig.blockSizeH! * 12,
          width: SizeConfig.blockSizeH! * 100,
          child: TextButton(
            onPressed: onPressed,
            child: Text(
              buttonName,
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(backgroundColor: bgColor),
          )),
    );
  }
}

//
class NavButtonOB extends StatelessWidget {
  const NavButtonOB({
    super.key,
    required this.name,
    required this.onPressed,
  });
  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        splashColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            name,
          ),
        ));
  }
}
