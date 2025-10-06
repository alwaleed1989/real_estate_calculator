// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter/material.dart';
//
// class AdScreen extends StatefulWidget {
//   @override
//   _AdScreenState createState() => _AdScreenState();
// }
//
// class _AdScreenState extends State<AdScreen> {
//   BannerAd? _bannerAd;
//   bool _isAdLoaded = false;
//
//   // استخدم معرّف الوحدة الإعلانية الخاص بك هنا
//   final String _adUnitId = "ca-app-pub-1785027446942479~1082845202";
//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }
//
//   void _loadAd() {
//     _bannerAd = BannerAd(
//       adUnitId: _adUnitId,
//       request: const AdRequest(),
//       size: AdSize.banner,
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() {
//             _isAdLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (ad, err) {
//           ad.dispose();
//         },
//       ),
//     )..load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('AdMob Banner')),
//       body: Center(child: const Text("محتوى التطبيق هنا")),
//       bottomNavigationBar: _isAdLoaded
//           ? SizedBox(
//         height: _bannerAd!.size.height.toDouble(),
//         width: _bannerAd!.size.width.toDouble(),
//         child: AdWidget(ad: _bannerAd!),
//       )
//           : const SizedBox(),
//     );
//   }
// }