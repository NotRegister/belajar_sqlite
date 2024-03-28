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

class EditNoteScreen extends StatefulWidget {
  final NoteModel? note;
  const EditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  File? selectedImage;
  String? selectedImagePath;

  /* Future<String> saveImageToLocalDevice(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await imageFile.copy(imagePath);
    return imagePath;
  } */

  Future<void> pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 500,
      maxHeight: 800,
    );

    if (pickedImage == null) return;
    final imageFile = File(pickedImage.path);
    selectedImagePath = imageFile.path;
    print('pathnya adalah : ${imageFile.path}');
    // final savedImagePath = await saveImageToLocalDevice(imageFile);

    setState(() {
      selectedImage = imageFile;
      // *debug : walaupun tanpa fungsi saveImageToLocalDevice() tetap mengambil gambar dengan cara imageFile.path
      // selectedImageDebug = File('/data/user/0/com.example.belajar_sqlite/cache/scaled_b7732ee0-4107-42d5-a0d3-4ef2b5d77ca35747745360280450578.jpg');
      // print('lokasi path gambar : $savedImagePath');
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

    final _imagePath = File(widget.note!.imgPath ?? 'Gambar Tidak ditemukan');

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
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Padding(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 400,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: selectedImage == null
                        ? Image.file(
                            _imagePath,
                            fit: BoxFit.cover,
                          ) //Text('path gambar : $_imagePath',)
                        : Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
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
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
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
                                address: DatabaseHelper.address,
                                imgPath: selectedImagePath,
                              );
                              if (widget.note == null) {
                                await DatabaseHelper.addNote(model);
                              } else {
                                await DatabaseHelper.updateNote(model);
                              }

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const GridViewNoteScreen()));
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.blue),
                                shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.white,
                                          width: 0.75,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        )))),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            )),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
