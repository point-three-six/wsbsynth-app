import 'package:flutter/material.dart';
import 'screens/splash/splash.dart';
import 'style.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Splash(),
        theme: ThemeData(
            primaryColor: AppPrimaryColor,
            canvasColor: AppPrimaryColor,
            textTheme: TextTheme(bodyText1: AppTextStyle),
            appBarTheme:
                AppBarTheme(textTheme: TextTheme(headline6: AppBarTextStyle))));
  }
}
