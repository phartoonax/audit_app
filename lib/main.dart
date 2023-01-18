// ignore_for_file: constant_identifier_names

import 'package:audit_app/color_schemes.g.dart';
import 'package:audit_app/screeens/loginpage.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

const String SERVER_URL = "https://eu-api.backendless.com";
const String APPLICATION_ID = "7CA5C0C0-D75E-06E3-FF2B-21190A25AD00";
const String ANDROID_API_KEY = "373D04CC-DD8F-4211-887C-CFE61EA1D58C";
const String IOS_API_KEY = "C849FF3F-8B17-4103-A512-6BC7AA9C765F";
const String JS_API_KEY = "86C6B81F-64A8-407F-93FA-BA5E4648E025";

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    init();
  }

  void init() async {
    await Backendless.initApp(
      applicationId: APPLICATION_ID,
      androidApiKey: ANDROID_API_KEY,
      iosApiKey: IOS_API_KEY,
      jsApiKey: JS_API_KEY,
    );
    await Backendless.setUrl(SERVER_URL);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        useInheritedMediaQuery: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Audit App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
            darkTheme:
                ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
            themeMode: ThemeMode.light,
            home: child,
          );
        },
        child: const LoginPage());
  }
}
