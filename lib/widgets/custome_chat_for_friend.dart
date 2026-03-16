import 'package:chat_app/constants/constants.dart';
import 'package:flutter/material.dart';

class ChatBubbleForFriend extends StatelessWidget {
  final String message;
  final bool isMe;
  final String? userName;
  final String? profilePicUrl;

  const ChatBubbleForFriend({
    super.key,
    required this.message,
    required this.isMe,
    this.userName,
    this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // عرض اسم المستخدم
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 45, bottom: 2),
                child: Text(userName ?? "User", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),

            Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: profilePicUrl != null && profilePicUrl!.isNotEmpty
                        ? NetworkImage(profilePicUrl!)
                        : null,
                    child: (profilePicUrl == null || profilePicUrl!.isEmpty)
                        ? const Icon(Icons.person) : null,
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : kPrimaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}