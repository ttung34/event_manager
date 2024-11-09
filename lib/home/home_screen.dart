import 'package:event_manager2/home/messgaer/message.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomeScreenChat extends StatefulWidget {
  const HomeScreenChat({super.key});

  @override
  State<HomeScreenChat> createState() => _HomeScreenChatState();
}

class _HomeScreenChatState extends State<HomeScreenChat> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final FocusNode _textFieldFocusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
        model: 'genimi-pro', apiKey: const String.fromEnvironment('api_key'));
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Genimi Chat"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatSession.history.length,
                itemBuilder: (context, index) {
                  final Content content = _chatSession.history.toList()[index];
                  final text = content.parts
                      .whereType<TextPart>()
                      .map<String>((e) => e.text)
                      .join();
                  return MessageChat(
                    text: text,
                    isFromUser: content.role == 'user',
                  );
                }),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    focusNode: _textFieldFocusNode,
                    decoration: textFieldDecoration(),
                    controller: _textEditingController,
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(height: 15)
              ],
            ),
          )
        ],
      ),
    );
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
        contentPadding: const EdgeInsets.all(15),
        hintText: "Enter a prompt..",
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ));
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      final text = response.text;
      if (text == null) {
        _showError("No response from API");
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textEditingController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocusNode.requestFocus();
    }
  }

  void _showError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Something went wrong"),
            content: SingleChildScrollView(
              child: SelectableText(message),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context);
                },
                child: const Text('OK'),
              )
            ],
          );
        });
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(
              milliseconds: 750,
            ),
            curve: Curves.easeOutCirc));
  }
}
