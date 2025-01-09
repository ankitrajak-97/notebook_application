import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // singleton class has only 1 static object

  DBHelper._();

  static final DBHelper getInstance =
      DBHelper._(); // Function to call class once
  static final String TABLENAME = 'note';
  static final String COLUMN_SNO = 's_no';
  static final String COLUMN_TITLE = 'title';
  static final String COLUMN_DESC = 'desc';

// defining and creating database object:
  Database? mYDB; // making it nullable for initially initialise
  var dbName = 'noteDb';
// database open (if path is exist then open else create db )

  Future<Database> getDB() async {
    mYDB ??= await openDB();
    return mYDB!;
    // if (mYDB != null) {
    //   return mYDB!;
    // } else {
    //   mYDB = await openDB();
    //   return mYDB!;
    // }
  }

// 2 things need to check whether db is opened and give the path
  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "$dbName.db");
    // Print the database path for debugging
    return await openDatabase(dbPath, onCreate: (db, version) {
      //create all tables here
      db.execute(
          'create table $TABLENAME ($COLUMN_SNO integer primary key autoincrement ,$COLUMN_TITLE text ,$COLUMN_DESC text)');
      //
      //
      //
      //
      //
    }, version: 1);
  }

// all queries
  // insertion
  Future<bool> addNote({required String title, required String desc}) async {
    var db = await getDB();
    int rowsEffected =
        await db.insert(TABLENAME, {COLUMN_TITLE: title, COLUMN_DESC: desc});
    return rowsEffected > 0;
  }

// reading all data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLENAME);
    // print("Fetched Notes: $mData"); // Debugging
    return mData;
  }

  /// update data
  Future<bool> updateNote(
      {required String title, required String desc, required int sno}) async {
    var db = await getDB();
    int rowsEffected = await db.update(
      TABLENAME,
      {COLUMN_TITLE: title, COLUMN_DESC: desc},
      where: "$COLUMN_SNO = $sno",
    );
    return rowsEffected > 0;
  }

  // Future<bool> updateNote({
  //   required String title,
  //   required String desc,
  //   required int sno,
  // }) async {
  //   var db = await getDB();
  //
  //   // Debugging prints
  //   print("Attempting to update note...");
  //   print("Title: $title, Desc: $desc, SNO: $sno");
  //
  //   int rowsEffected = await db.update(
  //     TABLENAME,
  //     {COLUMN_TITLE: title, COLUMN_DESC: desc},
  //     where: "$COLUMN_SNO = ?",
  //     whereArgs: [sno], // Ensure this matches the primary key of a row
  //   );
  //
  //   // Print rows affected
  //   print("Rows affected by update: $rowsEffected");
  //
  //   return rowsEffected > 0;
  // }

  // delete a note :
  Future<bool> deleteNote({required int sno}) async {
    var db = await getDB();
    int rowsEffected = await db
        .delete(TABLENAME, where: '$COLUMN_SNO = ?', whereArgs: ['$sno']);
    return rowsEffected > 0;
  }
}
