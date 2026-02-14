import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mineai/core/network/alice.dart';
import 'package:go_router/go_router.dart';

class FlowiseService {
  final Dio dio = dioProvider.dio;

  Future<void> uploadPDF(BuildContext context) async {
    await dotenv.load();
    String baseURLEndpoint = dotenv.get('CHAT_BOT_PDF_UPLOAD_URL');

    String cohereApiKey = dotenv.get('COHERE_API_KEY');
    String modelName = dotenv.get('MODEL_NAME');
    String baseUrl = baseURLEndpoint;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      FormData formData = FormData.fromMap({
        "files": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        "cohereApiKey": cohereApiKey, // replace if needed
        "modelName": modelName, // replace if needed
      });

      try {
        final response = await dio.post(baseUrl, data: formData);
        print("✅ Upload Response: ${response.data}");
        context.pushNamed("/screen3");
      } catch (e) {
        print("❌ Upload Error: $e");
      }
    } else {
      print("⚠️ No file selected");
    }
  }
}
