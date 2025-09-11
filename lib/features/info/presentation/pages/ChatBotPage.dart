import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FlowiseChat extends StatefulWidget {
  const FlowiseChat({super.key});

  @override
  State<FlowiseChat> createState() => _FlowiseChatState();
}

class _FlowiseChatState extends State<FlowiseChat> {
  final TextEditingController _controller = TextEditingController();
  String responseText = "";

  Future<void> sendMessage(String message) async {
    final url = Uri.parse(
      "https://192.168.0.221:3000/api/v1/prediction/5c5cbc19-0f69-407d-802e-ba17af24ab7a",
    );
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer vfB_krSpV0Nh2D_QnSQ90hti0W8oLFJgMPWJlL_0Rr0",
      },
      body: jsonEncode({"question": message}),
    );

    if (response.statusCode == 200) {
      print("sssssssssssssssssssss");
      final data = jsonDecode(response.body);
      setState(() {
        responseText = data["text"] ?? "No response";
      });
      print("sssssssssssssssssssss");
    } else {
      print("sssssssssssssssssssss");
      setState(() {
        responseText = "Error: ${response.statusCode}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flowise Chatbot")),
      body: Column(
        children: [
          Expanded(child: SingleChildScrollView(child: Text(responseText))),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Ask something...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  sendMessage(_controller.text);
                  _controller.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
