import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:life_events/ui/list.dart';
import 'package:life_events/model/strings.dart';
import 'package:life_events/model/colours.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        backgroundColor: AppColours.appBackgroundColour,
        dialogTheme: DialogTheme(backgroundColor: AppColours.appBackgroundColour),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'AU'),
      ],
      locale: Locale('en', 'AU'),
      home: LifeEvents(),
    );
  }
}