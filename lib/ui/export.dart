import 'package:flutter/material.dart';
import 'package:life_events/model/strings.dart';
import 'package:life_events/model/colours.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:life_events/model/database_helper.dart';
import 'package:csv/csv.dart';
import 'package:life_events/model/lifeevent.dart';
import 'package:life_events/model/csvstorage.dart';
import 'package:life_events/ui/dialogs.dart';

import 'list.dart';

class ExportPage extends StatefulWidget {
  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  //Get the database lazily.
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.exportPageTitle),
        backgroundColor: AppColours.appBackgroundColour,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        width: cWidth,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                            text:
                                "This action will export all of your life events into a single Comma Separated Values (CSV) file in your Downloads directory, named \"life_events.csv\". If there is already a file there by that name, it will be overwritten."))),
              ],
            ),
            SizedBox(height: 40),
            Row(
              children: [
                IconButton(
                  icon: Icon(FlutterIcons.md_save_ion),
                  onPressed: _pushExport,
                ),
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      text: "if you're ready, tap the icon to export now."),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pushExport() async {
    //Get ell of the Life Events and smash them into a CSV on the file system.

    final int count = await dbHelper.queryRowCount();

    final int numFields = 6;

    final List<LifeEvent> lifeEvents = await dbHelper.getAlllifeEvents(
        DatabaseHelper.sortDesc, LifeEvent.typeAll);

    //Get each one out and stuff it into a list, then put that in the parent list.
    List<List<dynamic>> allRows = List.generate(lifeEvents.length, (i) {
      return List<dynamic>.generate(numFields, (j) {
        switch (j) {
          case 0:
            return lifeEvents[i].id.toString();
            break;
          case 1:
            return lifeEvents[i].name.toString();
            break;
          case 2:
            return lifeEvents[i].details.toString();
            break;
          case 3:
            return lifeEvents[i].type.toString();
            break;
          case 4:
            return lifeEvents[i].theDay.toString();
            break;
          case 5:
            return lifeEvents[i].related.toString();
            break;
        }
      });
    });

    String csv = const ListToCsvConverter().convert(allRows);
    /*
    EXPORT: Open a file on the filesystem and write each as a CSV...
    */
    final CsvStorage storage = new CsvStorage();
    storage.writeCsv(csv);

    await showOkDialog(context, "Export Results", "You managed to export $count Life Events.");

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LifeEvents()));
  }
}
