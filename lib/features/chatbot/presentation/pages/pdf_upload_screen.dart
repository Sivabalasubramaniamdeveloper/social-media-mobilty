import 'package:flutter/material.dart';
import '../../../../core/base/abstract/base_screen.dart';
import '../../data/service/flowise_service.dart';

class PDFUploadScreen extends BaseScreen {
  const PDFUploadScreen({super.key});

  @override
  String get title => "PDF UPLOAD SCREEN";

  @override
  bool get showAppBar => true;

  @override
  Widget buildBody(BuildContext context) {
    return PDF();
  }
}

class PDF extends StatefulWidget {
  const PDF({super.key});

  @override
  State<PDF> createState() => _PDFState();
}

class _PDFState extends State<PDF> {
  final FlowiseService service = FlowiseService();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () => service.uploadPDF(context),
              child: Text("Upload PDF"),
            ),
          ),
        ],
      ),
    );
  }
}
