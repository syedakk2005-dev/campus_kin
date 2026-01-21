import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static const Uuid _uuid = Uuid();
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndSaveImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (image == null) return null;

      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = '${appDir.path}/images';
      await Directory(imagesDir).create(recursive: true);

      // Generate unique filename
      final String fileName = '${_uuid.v4()}.jpg';
      final String filePath = '$imagesDir/$fileName';

      // Copy image to app directory
      await File(image.path).copy(filePath);
      
      return filePath;
    } catch (e) {
      print('Error picking/saving image: $e');
      return null;
    }
  }

  static Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  static bool isValidImagePath(String path) {
    final File file = File(path);
    return file.existsSync();
  }
}