import 'package:belajar_sqlite/new_notes/models/note_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _databaseName = 'notes.db';
  static String? lat, long, address = null;

  static Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: ((db, version) async => await db.execute(
            '''CREATE TABLE notes(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              title TEXT NOT NULL, 
              content TEXT NOT NULL,
              lat TEXT,
              long TEXT
              )''',
          )),
      version: _version,
    );
  }

  Future<void> printDatabaseContentss() async {
    try {
      Database database = await _getDatabase();
      List<Map<String, dynamic>> rows = await database.query('notes');
      rows.forEach((row) {
        print(row); // Print each row of the table
      });
    } catch (e) {
      print('Error printing database contents: $e');
    }
  }

  static Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    /* serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    } */

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  }

  static Future<void> updatePosition() async {
    Position pos = await _determinePosition();

    // *pm untuk menerjemahkan dari geolocator menjadi nama jalan dll
    List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude); // !: masih belum save ke database jadi semua data akan menggunakan addres sekarang tidak sesuai dengan latlong

    lat = pos.latitude.toString();
    long = pos.longitude.toString();
    address = pm[0].street.toString();
    // ?print('berhasil get lat: $lat');
  }

  static Future<int> addNote(NoteModel note) async {
    final db = await _getDatabase();
    // await updatePosition();
    return await db.insert('notes', note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateNote(NoteModel note) async {
    final db = await _getDatabase();
    return await db.update('notes', note.toJson(),
        where: 'id = ?',
        whereArgs: [note.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteNote(NoteModel note) async {
    final db = await _getDatabase();
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  static Future<List<NoteModel>?> getAllNotes() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('notes');

    if (maps.isEmpty) {
      return null;
    }

    return List.generate(maps.length, (index) => NoteModel.fromJson(maps[index]));
  }

  // ! Danger
  Future<void> deleteDatabase() async {
    String pathLocation = await getDatabasesPath();
    return databaseFactory.deleteDatabase(pathLocation.toString());
  }
}
