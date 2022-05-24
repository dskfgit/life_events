import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:life_events/model/lifeevent.dart';

class DatabaseHelper {
  static final _databaseName = "LifeEvents.db";
  static final _databaseVersion = 1;
  static final table = 'life_events';
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnTheDay = 'theDay';
  static final columnDetails = 'details';
  static final columnType = 'type';
  static final columnRelated = 'related';
  static const int sortAsc = 0;
  static const int sortDesc = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    //Directory documentsDirectory = await getApplicationDocumentsDirectory();
    WidgetsFlutterBinding.ensureInitialized();
    String path = Path.join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    //Create the table and insert the first Life Event!
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnTheDay TEXT NOT NULL,
            $columnDetails TEXT NOT NULL,
            $columnType INTEGER NOT NULL,
            $columnRelated INTEGER
          )
          ''');
  }

  // Helper methods
  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    int id = 0;
    Database db = await instance.database;
    try {
      id = await db.insert(table, row);
    }
    catch(err) {
      print(err.toString());
    }
    return id;
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }


  Future<List<LifeEvent>> getAlllifeEvents(int sortKey, int filter) async {
    Database db = await instance.database;
    String sortBy = '';
    switch (sortKey) {
      case sortAsc:
        {
          sortBy = "ASC";
        }
        break;
      case sortDesc:
        {
          sortBy = "DESC";
        }
        break;
      default:
        {
          sortBy = "DESC";
        }
        break;
    }
    String prefix = "SELECT * FROM " + table;
    String whereClause = "";
    if (filter != LifeEvent.typeAll) {
      whereClause = " WHERE " + columnType + " IS " + filter.toString();
    }
    String suffix = " ORDER BY " + columnTheDay + " " + sortBy;
    String selectString = prefix + whereClause + suffix;
    // Query the table for all of the LifeEvents.
    //final List<Map<String, dynamic>> maps = await db.query(table);
    final List<Map<String, dynamic>> maps = await db.rawQuery(selectString);
    // Convert the List<Map<String, dynamic> into a List<LifeEvent>.
    //maps.sort((a, b) => a[columnTheDay].compareTo(b[columnTheDay]));
    return List.generate(maps.length, (i) {
      return LifeEvent(
          id: maps[i][columnId],
          name: maps[i][columnName],
          theDay: maps[i][columnTheDay],
          details: maps[i][columnDetails],
          type: maps[i][columnType],
          related: maps[i][columnRelated]
      );
    });
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}