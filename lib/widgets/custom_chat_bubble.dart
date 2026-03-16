import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message, userName;
  final String? profilePicUrl;
  final bool isMe, isRead;

  const ChatBubble({super.key, required this.message, required this.isMe, required this.userName, this.profilePicUrl, required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(userName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15), topRight: const Radius.circular(15),
                  bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(message, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 16))),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Icon(isRead ? Icons.done_all : Icons.done, size: 16, color: isRead ? Colors.cyanAccent : Colors.white70),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}