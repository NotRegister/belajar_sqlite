import 'dart:io';
import 'dart:typed_data';

import 'package:belajar_sqlite/new_notes/models/note_model.dart';
import 'package:belajar_sqlite/new_notes/screens/gridview_notes_screen.dart';
import 'package:belajar_sqlite/new_notes/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;
  const AddEditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  File? selectedImage;
  Uint8List? imageBytes;

  Future<String> saveImageToLocalDevice(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await imageFile.copy(imagePath);
    return imagePath;
  }

  Future<void> pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 500,
      maxHeight: 800,
    );
    if (pickedImage == null) return;

    final imageFile = File(pickedImage.path);
    final savedImagePath = await saveImageToLocalDevice(imageFile);

    setState(() {
      selectedImage = imageFile;
      print('lokasi path gambar : $savedImagePath');
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }

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
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              width: 300,
              height: 300,
              child: selectedImage == null ? null : Image.file(selectedImage!),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
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
                              address: DatabaseHelper.address, //DatabaseHelper.address,
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
                              shape:
                                  MaterialStateProperty.all(const RoundedRectangleBorder(
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
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.green[700],
                    ),
                    child: IconButton(
                      onPressed: () {
                        pickImageFromCamera();
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        size: 26.0,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
