class OnBoarding {
  final String title;
  final String image;
  final String deskripsi;

  OnBoarding({
    required this.title,
    required this.image,
    required this.deskripsi,
  });
}

List<OnBoarding> onboardingContents = [
  OnBoarding(
    image: 'assets/images/gambarongoing1.png',
    title: 'Catat',
    deskripsi: 'Catat semua pemasukan dan pengeluaran anda',
  ),
  OnBoarding(
    image: 'assets/images/gambarongoing2.png',
    title: 'Lihat',
    deskripsi: 'Lihat history pemasukan dan pengeluaran anda',
  ),
  OnBoarding(
    image: 'assets/images/gambarongoing3.png',
    title: 'Rencanakan',
    deskripsi: 'Rencanakan keuangan anda untuk masa depan!',
  ),
  OnBoarding(
    image: 'assets/images/LogoOG.png',
    title: '',
    deskripsi: '',
  ),
];
