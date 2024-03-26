// import 'package:belajar_sqlite/old_notes/screen/notes_screen.dart';
import 'package:belajar_sqlite/new_notes/screens/gridview_notes_screen.dart';
import 'package:belajar_sqlite/new_notes/screens/notes_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GridViewNoteScreen(),
    );
  }
}
