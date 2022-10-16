import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:invidual_project/profileNsetting/Profile.dart';
import 'package:invidual_project/authentication/Signup.dart';
import 'package:invidual_project/authentication/forgotpassword/ForgotPassword.dart';
import 'package:invidual_project/authentication/Login.dart';
import 'package:invidual_project/authentication/forgotpassword/ForgotPassword_sent.dart';
import 'package:invidual_project/profileNsetting/Setting.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init(cacheProvider: SharePreferenceCache());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ValueChangeObserver<bool>(
        cacheKey: Setting.keyDarkMode,
        defaultValue: true,
        builder: (_, isDarkMode, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: isDarkMode?
              ThemeData.dark().copyWith(
                primaryColor: Colors.white,
                //scaffoldBackgroundColor: Color(0xff170635),
                //backgroundColor: Color(0xff170635),
                backgroundColor: Color(0xff170635),
                canvasColor: Color(0xff170635),
              )
              : ThemeData.light().copyWith(
                primaryColor: Color(0xff170635),
                //scaffoldBackgroundColor: Colors.white,
                //backgroundColor: Colors.white,
                backgroundColor: Colors.white,
                canvasColor: Colors.white,
              ),
          home: const Profile(),
        )
        );
  }
}