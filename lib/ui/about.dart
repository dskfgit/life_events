import 'package:flutter/material.dart';
import 'package:life_events/model/strings.dart';

class AboutPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    double cWidth = MediaQuery.of(context).size.width*0.9;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.helpPageTitle)),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        width: cWidth,
        child: Column(
          children: [
            Row(
              children: [
                RichText(
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        text: "About Life Events")
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.sticky_note_2_outlined),
                Text("Version 1.0"),
              ],
            ),
            Row(
              children: [
                Icon(Icons.auto_awesome),
                Flexible(child: Text("Thank you to albin.post@gmail.com for Wikipedia, On this Day (https://byabbe.se/)")),
              ],
            ),
            Row(
              children: [
                Icon(Icons.filter_vintage),
                Flexible( child: Text("Built with Flutter and Android Studio.")),
              ],
            ),
            Row(
              children: [
                Icon(Icons.perm_identity_outlined),
                Flexible( child: Text("Authored by Des Fisher (fisher.des@gmail.com)")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
