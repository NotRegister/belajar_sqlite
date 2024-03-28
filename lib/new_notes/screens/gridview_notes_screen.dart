// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:belajar_sqlite/new_notes/screens/add_note_screen.dart';
import 'package:belajar_sqlite/new_notes/screens/edit_note_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';

import '../widgets/note_widgets.dart';
import '../screens/add_edit_note_screen.dart';
import '../models/note_model.dart';
import '../services/database_helper.dart';
import 'package:flutter/material.dart';

class GridViewNoteScreen extends StatefulWidget {
  const GridViewNoteScreen({Key? key}) : super(key: key);

  @override
  State<GridViewNoteScreen> createState() => _GridViewNoteScreenState();
}

class _GridViewNoteScreenState extends State<GridViewNoteScreen> {
  // !get location
  /* void getLoc() async {
      // ignore: unused_local_variable
      await Geolocator.checkPermission();
      await Geolocator.requestPermission();

      final loc =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      print(loc);
    } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        floatingActionButton: FloatingActionButton.large(
          backgroundColor: Colors.blue[100],
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddNoteScreen()));
            setState(() {});
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<List<NoteModel>?>(
          future: DatabaseHelper.getAllNotes(),
          builder: (context, AsyncSnapshot<List<NoteModel>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.data == null) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/illustration1.png',
                        width: 400,
                      ),
                      const Text('Tambahkan note anda dengan menekan tombol +'),
                    ],
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else if (snapshot.hasData) {
              if (snapshot.data != null) {
                return Column(
                  children: [
                    SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.blue[400],
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15))),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('All Notes',
                                      style: TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      )),
                                  RichText(
                                    text: TextSpan(
                                      text: '',
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                      children: <TextSpan>[
                                        const TextSpan(
                                          text: 'Anda mempunyai ',
                                        ),
                                        TextSpan(
                                          text: '${snapshot.data!.length} notes',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  // getLoc();
                                  DatabaseHelper().printDatabaseContentss();
                                },
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GridView.builder(
                          itemCount: snapshot.data!.length,
                          padding: const EdgeInsets.all(5),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemBuilder: (context, index) => GridNoteWidget(
                            note: snapshot.data![index],
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditNoteScreen(
                                            note: snapshot.data![index],
                                          )));
                              setState(() {});
                            },
                            onLongPress: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Are you sure you want to delete this note?'),
                                    actions: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(Colors.red)),
                                              onPressed: () async {
                                                await DatabaseHelper.deleteNote(
                                                    snapshot.data![index]);
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'No',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Center(
                child: Text('No notes yet'),
              );
            }
            return const SizedBox.shrink();
          },
        ));
  }
}
