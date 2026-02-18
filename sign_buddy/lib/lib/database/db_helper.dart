import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  late Database db;

  // CREATE DATABASE
  Future<void> createDatabase() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'sign_buddy.db'),
      version: 1,
      onCreate: (db, version) async {

        await db.execute(
            'CREATE TABLE history ('
                'id INTEGER PRIMARY KEY AUTOINCREMENT, '
                'userId TEXT, '
                'predictedSign TEXT, '
                'confidence REAL, '
                'dateTime TEXT)'
        );

      },
    );
  }

  // INSERT
  Future<void> insertHistory(
      String userId,
      String predictedSign,
      double confidence,
      String dateTime
      ) async {

    await db.insert(
      'history',
      {
        'userId': userId,
        'predictedSign': predictedSign,
        'confidence': confidence,
        'dateTime': dateTime,
      },
    );
  }

  // READ
  Future<List<Map<String, dynamic>>> getHistory(String userId) async {

    return await db.query(
      'history',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  // UPDATE
  Future<void> updateHistory(
      int id,
      String predictedSign,
      double confidence
      ) async {

    await db.update(
      'history',
      {
        'predictedSign': predictedSign,
        'confidence': confidence,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<void> deleteHistory(int id) async {

    await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
