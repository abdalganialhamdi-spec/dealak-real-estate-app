import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final int conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محادثة')),
      body: Column(
        children: [
          const Expanded(child: Center(child: Text('الرسائل'))),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 4)]),
            child: Row(
              children: [
                const Expanded(child: TextField(decoration: InputDecoration(hintText: 'اكتب رسالة...', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.send), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
