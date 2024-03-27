import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class FruitModel {
  List<dynamic>? _output;
  String? _selectedImagePath;

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  Future<void> classifyImageFromGallery() async {
    var imagePicker = ImagePicker();
    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    _selectedImagePath = image.path;
    await _classifyImage(_selectedImagePath!);
  }

  Future<void> classifyImageFromCamera() async {
    var imagePicker = ImagePicker();
    var image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    _selectedImagePath = image.path;
    await _classifyImage(_selectedImagePath!);
  }

  Future<void> _classifyImage(String imagePath) async {
    var output = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    _output = output;
  }

  String? get selectedImagePath => _selectedImagePath;

  List<dynamic>? get output => _output;

  void disposeModel() {
    Tflite.close();
  }
}
