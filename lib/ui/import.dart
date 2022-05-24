import 'package:flutter/material.dart';
import 'package:life_events/model/strings.dart';
import 'package:life_events/model/colours.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:life_events/model/database_helper.dart';
import 'package:csv/csv.dart';
import 'package:life_events/model/csvstorage.dart';
import 'package:life_events/ui/dialogs.dart';
import 'package:life_events/ui/list.dart';

class ImportPage extends StatefulWidget {
  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  //Get the database lazily.
  final dbHelper = DatabaseHelper.instance;
  final CsvStorage storage = new CsvStorage();

  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.9;
    Future<bool> fileExists = storage.importCsvExists();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.importPageTitle),
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
                                "This action will import a single Comma Separated Values (CSV) file from your Downloads directory, named \"life_events.csv\"."))),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                FutureBuilder<bool>(
                  future: fileExists,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    List<Widget> children;
                    if (snapshot.hasData) {
                      children = <Column>[
                        Column(
                          children: [
                            csvFileExistsRow(snapshot.data),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        )
                      ];
                    } else if (snapshot.hasError) {
                      children = <Widget>[
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text('Error: ${snapshot.error}'),
                        )
                      ];
                    } else {
                      children = const <Widget>[
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Checking for import file...'),
                        )
                      ];
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: children,
                      ),
                    );
                  },
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            SizedBox(height: 20),
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
                                "Tip: You can generate this file by using the \"export\" function. It will drop a csv file in your downloads directory. You could then use it as a template and edit it."))),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black45,
                              fontWeight: FontWeight.normal,
                            ),
                            text:
                                "NB: We ignore IDs. If you export a file and then re-import it, you'll end up with duplicates. There is no logic to see if Life Events should be updated. They are always added as new Life Events."))),
              ],
            ),
            SizedBox(height: 40),
            Row(
              children: [
                IconButton(
                  icon: Icon(FlutterIcons.md_cloud_upload_ion),
                  onPressed: _pushImport,
                ),
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      text: "if you're ready, tap the icon to import now."),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pushImport() async {
    //Get ell of the Life Events and smash them into a CSV on the file system.
    int beforeCount = await dbHelper.queryRowCount();
    String csvData = await storage.readCsv();
    int id; //blank because we don't use it.
    List<List<dynamic>> lifeEvents =
        const CsvToListConverter().convert(csvData);
    lifeEvents.forEach((row) async {
      final Map<String, dynamic> lifeEvent = {
        DatabaseHelper.columnId: id,
        DatabaseHelper.columnName: row[1],
        DatabaseHelper.columnDetails: row[2],
        DatabaseHelper.columnType: row[3],
        DatabaseHelper.columnTheDay: row[4],
        //Related needs to be zero.
        DatabaseHelper.columnRelated: 0,
      };
      await dbHelper.insert(lifeEvent);
    });
    int afterCount = await dbHelper.queryRowCount();
    int count = afterCount - beforeCount;

    await showOkDialog(context, "Import Results", "You managed to import $count Life Events.");

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LifeEvents()));
  }

  Row csvFileExistsRow(bool exists) {
    Icon existsIcon;
    String msgText;

    if (exists) {
      msgText = "The import file is there";
      existsIcon = Icon(
        Icons.check_circle_outline,
        color: Colors.green,
        size: 30,
      );
    } else {
      msgText = "The import file is not there!";
      existsIcon = Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 30,
      );
    }

    Row row = Row(children: [
      existsIcon,
      RichText(
        text: TextSpan(
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            text: msgText),
      ),
    ],
    );

    return row;
  }
}
