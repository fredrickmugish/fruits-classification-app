import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';


final Map<String, List<String>> fruitAdvantages = {
  'apple': [
    'Rich in antioxidants and fiber. Helps in reducing the risk of heart disease.',
    'Contains vitamins A, C, and K.',
  ],
  'Banana': [
    'Good source of potassium. Helps in maintaining healthy blood pressure.',
    'Provides energy and supports digestion.',
  ],
  'Orange': [
    'High in vitamin C. Boosts immune system and supports healthy skin.',
    'Contains antioxidants and fiber.',
  ],
  // Add more fruits and their advantages as needed
};


class FruitClassifierApp extends StatefulWidget {
  @override
  _FruitClassifierAppState createState() => _FruitClassifierAppState();
}

class _FruitClassifierAppState extends State<FruitClassifierApp> {
  List<dynamic>? _output;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NUTRITION DETECTION APP',
        style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: Text('Choose Image from Gallery'),
                  ),
                  ElevatedButton(
                    onPressed: _takePhoto,
                    child: Text('Take a Photo'),
                  ),
               _output != null
  ? Column(
      children: [
        Text('Detected Fruit: ${_output![0]['label'].split(' ').last}'),
        SizedBox(height: 10),
        Text('Advantages:'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: fruitAdvantages[_output![0]['label'].split(' ').last]!.map((advantage) {
            return Text('- $advantage\n'); // Add a line break (\n) between each advantage
          }).toList(),
        ),
      ],
    )
  : Container(),



                ],
              ),
            ),
    );
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  void _pickImageFromGallery() async {
    var imagePicker = ImagePicker();
    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    _classifyImage(image.path);
  }

  void _takePhoto() async {
    var imagePicker = ImagePicker();
    var image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    _classifyImage(image.path);
  }

  void _classifyImage(String imagePath) async {
    var output = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _output = output;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: FruitClassifierApp(),
  ));
}
