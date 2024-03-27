import 'package:belajar_sqlite/new_notes/models/note_model.dart';
import 'package:belajar_sqlite/new_notes/screens/gridview_notes_screen.dart';
import 'package:belajar_sqlite/new_notes/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;
  const AddEditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    var _lat = '';
    var _long = '';
    var _address = '';

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }

/*     Future<Position> _determinePosition() async {
      bool serviceEnabled;
      LocationPermission permission;
      await Geolocator.checkPermission();
      await Geolocator.requestPermission();

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
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
      } 

      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);

    }

    Future<void> _updatePosition() async {
      Position pos = await _determinePosition();

      // *pm untuk menerjemahkan dari geolocator menjadi nama jalan dll
      List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      setState(() {
        _lat = pos.latitude.toString();
        _long = pos.longitude.toString();
        _address = pm[0].street.toString();
        print('berhasil get loc');
      });
    } */

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        centerTitle: true,
        title: Text(
          widget.note == null ? "Add Note" : "Edit Note",
          style: const TextStyle(color: Colors.white),
        ),
        actions: const [],
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 24.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Tuliskan notes anda disini',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: TextFormField(
                controller: titleController,
                maxLines: 1,
                decoration: const InputDecoration(
                    hintText: 'Title',
                    labelText: 'Note title',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 0.75,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ))),
              ),
            ),
            TextFormField(
              controller: contentController,
              decoration: const InputDecoration(
                  hintText: 'Type here the note',
                  labelText: 'Note description',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 0.75,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ))),
              keyboardType: TextInputType.multiline,
              onChanged: (str) {},
              maxLines: 5,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    onPressed: () async {
                      final title = titleController.value.text;
                      final description = contentController.value.text;

                      if (title.isEmpty || description.isEmpty) {
                        return;
                      }
                      await DatabaseHelper.updatePosition();
                      final NoteModel model = NoteModel(
                        title: title,
                        content: description,
                        id: widget.note?.id,
                        lat: DatabaseHelper.lat,
                        long: DatabaseHelper.long,
                      );
                      if (widget.note == null) {
                        // await  DatabaseHelper.updatePosition();
                        // print(_lat);
                        await DatabaseHelper.addNote(model);
                      } else {
                        // await DatabaseHelper.updatePosition();
                        await DatabaseHelper.updateNote(model);
                      }

                      // Navigator.pop(context);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GridViewNoteScreen()));
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.white,
                              width: 0.75,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            )))),
                    child: Text(
                      widget.note == null ? 'Save' : 'Edit',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
