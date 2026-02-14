import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/network/custom_api_call.dart';
import '../../../../instance/locator.dart';

class Screen3 extends BaseScreen {
  const Screen3({super.key});

  @override
  String get title => "Datayaan Chat Bot";

  @override
  bool get showAppBar => true;

  @override
  Widget buildBody(BuildContext context) {
    return ChatScreen();
  }
}

class Message {
  final String text;
  final bool isUser;

  Message(this.text, this.isUser);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  late String apiEndpoint;
  CustomApiCallService customApiCallService = getIt<CustomApiCallService>();
  CustomAppLogger customAppLogger = getIt<CustomAppLogger>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFunction();
  }

  Future<void> initFunction() async {
    await dotenv.load();

    apiEndpoint = dotenv.get('CHAT_BOT_BASE_URL');
  }

  Future<void> sendMessage(String prompt) async {
    setState(() {
      _messages.add(Message(prompt, true));
      _isLoading = true;
    });
    try {
      final response = await customApiCallService.makeApiRequest(
        method: AppStrings.postAPI,
        token: '',
        url: apiEndpoint,
        data: {"question": prompt},
      );
      if (response.statusCode == 200) {
        final data = await response.data is String
            ? json.decode(response.data)
            : response.data;
        CustomAppLogger.appLogger("sssss", ' load  data: ${data['text']}');
        String reply = data['text']?.toString() ?? "No reply found";
        setState(() {
          _messages.add(Message(reply, false));
        });
      } else {
        customAppLogger.warning(
          'Failed to load driver data: ${response.statusCode}',
        );
        throw Exception('Failed to load driver data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      customAppLogger.warning(e);
      throw Exception('${AppStrings.failedToLoad} ${e.error}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildMessage(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue.shade100 : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: true,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return buildMessage(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade800,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: Colors.tealAccent,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: Colors.white70.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 14,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        sendMessage(value.trim());
                        _controller.clear();
                      }
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent.shade400.withOpacity(0.5),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        sendMessage(text);
                        _controller.clear();
                      }
                    },
                    icon: const Icon(Icons.send, size: 20),
                    color: Colors.blueGrey.shade900,
                    splashRadius: 22,
                    tooltip: 'Send message',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatStreamExample extends StatelessWidget {
  const ChatStreamExample({super.key});

  // Fake chat messages stream
  Stream<String> chatStream() async* {
    List<String> messages = ["Hi 👋", "How are you?", "I am fine ✅", "Bye 👋"];
    for (var msg in messages) {
      await Future.delayed(Duration(seconds: 2));
      yield msg; // emit new message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Stream")),
      body: StreamBuilder<String>(
        stream: chatStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text("Waiting for messages..."));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return Center(child: Text("New Message: ${snapshot.data}"));
          } else {
            return Center(child: Text("No messages yet"));
          }
        },
      ),
    );
  }
}
