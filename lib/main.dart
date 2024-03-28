import 'dart:io';
import 'package:flutter/material.dart';
import 'model.dart';
import 'advantages.dart';

void main() {
  runApp(MaterialApp(
    home: MainScreen(),
  ));
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FruitModel _fruitModel = FruitModel();

  @override
  void initState() {
    super.initState();
    _fruitModel.loadModel();
  }

  @override
  void dispose() {
    _fruitModel.disposeModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NUTRITION DETECTION APP',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.jpeg'), // Replace 'assets/background_image.jpg' with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _fruitModel.classifyImageFromGallery();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PredictionScreen(
                        imagePath: _fruitModel.selectedImagePath!,
                        predictedLabel: _fruitModel.output![0]['label'].split(' ').last,
                      ),
                    ),
                  );
                },
                child: Text('Choose Image from Gallery'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _fruitModel.classifyImageFromCamera();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PredictionScreen(
                        imagePath: _fruitModel.selectedImagePath!,
                        predictedLabel: _fruitModel.output![0]['label'].split(' ').last,
                      ),
                    ),
                  );
                },
                child: Text('Take a Photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class PredictionScreen extends StatelessWidget {
  final String predictedLabel;
  final String imagePath;

  const PredictionScreen({Key? key, required this.predictedLabel, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String>? advantages = fruitAdvantages[predictedLabel];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detection',
        style: TextStyle(color: Colors.white),),
        centerTitle: false,
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              File(imagePath),
              height: 250, // Adjust the height as needed
              width: 250, // Adjust the width as needed
            ),
            SizedBox(height: 10),
            Text('Classified as: $predictedLabel'), // Predicted label below the image
            SizedBox(height: 10),
            Text(
              'Advantages:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            if (advantages != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: advantages
                    .map((advantage) => Text(' - $advantage'))
                    .toList(),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
