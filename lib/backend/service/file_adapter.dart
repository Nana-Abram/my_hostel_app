import 'package:image_picker/image_picker.dart';

abstract class PlatformFileAdapter {
  Future<List<dynamic>> convertXFiles(List<XFile> files);
}
