import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:weconnect/splash.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

import 'shared/api_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Intl.defaultLocale = 'th';
  initializeDateFormatting();

  LineSDK.instance.setup('1656748478').then((_) {
    print('LineSDK Prepared');
  });

  // await Firebase.initializeApp();
  HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // set bacground color notificationbar.
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    // portrait only.
    _portraitModeOnly();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF7847AB),
        primaryColorDark: const Color(0xFF9C0000),
        fontFamily: 'Sarabun',
      ),
      title: appName,
      home: const SplashPage(),
      builder: (context, child) {
        return MediaQuery(
          // ignore: sort_child_properties_last
          child: child ?? const SizedBox(),
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
        );
      },
    );
  }
}

void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
