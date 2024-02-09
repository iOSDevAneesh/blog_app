import 'dart:io';

import 'package:blog_app/services/cruds_method.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({super.key});

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title, authorName, description;
  CrudMethods crudMethods = CrudMethods();

  final picker = ImagePicker();
  File? selectedImage;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Future<void> getImage() async {
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          selectedImage = File(pickedImage.path);
        });
      }
    }

    uploadBlog() async {
      if (selectedImage != null) {
        setState(() {
          isLoading = true;
        });

        try {
          Reference firebaseStorageRef = FirebaseStorage.instance
              .ref()
              .child("blogImages")
              .child("${randomAlphaNumeric(9)}.jpg");

          final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

          await task.whenComplete(() {});

          var downloadUrl = await firebaseStorageRef.getDownloadURL();
          print("this is url $downloadUrl");

          Map<String, String> blogMap = {
            "imageUrl": downloadUrl,
            "authorName": authorName,
            "title": title,
            "desc": description
          };

          await crudMethods.addData(blogMap);
          setState(() {
            isLoading = false; // Set isLoading back to false after upload
          });

          Navigator.pop(context, true);
        } catch (error) {
          setState(() {
            isLoading = false; // Set isLoading back to false in case of error
          });
          print("Error uploading blog: $error");
        }
      } else {
        // Handle case where no image is selected
        print("No image selected");
      }
    }


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Create",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 20),
            ),
            Text(
              "blog",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 20),
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select an image!',style: TextStyle(color: Colors.white),),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (title.isEmpty ||
                      authorName.isEmpty ||
                      description.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All fields are required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    uploadBlog();
                  }
                }
              },
              icon: const Icon(
                Icons.upload,
                color: Colors.white,
              ))
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "uploading...",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(selectedImage!
                                    .path), // Use File constructor
                                height: 170,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(top: 50),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              height: 170,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white),
                              child: Center(
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ))),
                            ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Title",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        title = val;
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Author name",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a authorName';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        authorName = val;
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Description",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        description = val;
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
