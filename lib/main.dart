import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MaterialApp(
  home: HomeScreen(),
));

class HomeScreen extends StatefulWidget {
  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  File? pickedImage; // Make pickedImage nullable
  bool isImageLoaded = false;
  List<dynamic>? _result; // Make _result nullable

  String _confidence = ""; // Define _confidence with setter and getter
  String _class = ""; // Define _name with setter and getter

  getImageFromGallery() async {
    var tempStore =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = tempStore != null ? File(tempStore.path) : null; // Check if tempStore is null
      isImageLoaded = pickedImage != null; // Update isImageLoaded based on pickedImage
    });
  }

  loadMyModel() async {
    var resultant = await Tflite.loadModel(
        labels: "assets/labels.txt",
        model: "assets/model.tflite"
    );
    print("Result after loading model: $resultant");
  }

  @override
  void initState() {
    super.initState();
    loadMyModel();
  }

  applyModelOnImage(File file) async {
    // Verify pickedImage is not null
    if (pickedImage == null) {
      print("Error: No image selected!");
      return;
    }

    var res = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    print("_result: $_result"); // Print the actual output

    setState(() {
      _result = res;

      if (_result != null && _result!.isNotEmpty) {
        // Extract information based on your model's output format (refer to documentation)
        String str = _result![0]["labels"];
        _class = str.substring(2);
        _confidence = (_result![0]['confidence'] * 100.0).toStringAsFixed(2) + "%";
      } else {
        print("No results found from the model!"); // Inform user if no results
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NUTRITION DETECTION APP'),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 30),
            isImageLoaded
                ? Center(
                    child: Container(
                      height: 350,
                      width: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(pickedImage!), // Use ! to assert non-null
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                : Container(),
            if (_class.isNotEmpty && _confidence.isNotEmpty)
              Text("Name : $_class \n Confidence: $_confidence"), // Render text only if _name and _confidence are not empty
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImageFromGallery();
        },
        child: Icon(Icons.photo_album),
      ),
    );
  }
}
