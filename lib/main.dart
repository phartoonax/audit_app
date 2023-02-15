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
const String APPLICATION_ID = "B4767E6C-1CFB-2E7D-FF6D-8E06E61C3900";
const String ANDROID_API_KEY = "37EE5605-1A6E-45FE-B475-90CAFBB5D2A1";
const String IOS_API_KEY = "868DBCE3-EAE9-436E-AD67-557A5ADF44C7";
const String JS_API_KEY = "11EFD95E-1E59-4853-8E0F-D3A0ADEED12D";

//BACKUP SERVER
// const String APPLICATION_ID = "458084E0-EA3D-0CAB-FFB9-7944218CCA00";
// const String ANDROID_API_KEY = "9A1322D9-F4FC-4900-B9EB-4A786E039307";
// const String IOS_API_KEY = "A831EF88-FAC2-47EA-B170-E8EBC086B034";
// const String JS_API_KEY = "3701441A-4180-47CD-BF96-237A9001A778";

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
     await Backendless.setUrl(SERVER_URL); //TODO: REENABLE THIS WHEN SERVER IS UP
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
