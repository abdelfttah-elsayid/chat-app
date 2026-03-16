import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/widgets/custom_chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PrivateChat extends StatefulWidget {
  final String chatId, friendName, friendPic, myName;
  const PrivateChat({super.key, required this.chatId,
    required this.friendName ,
    required this.friendPic, required this.myName});

  @override
  State<PrivateChat> createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {
  final TextEditingController _controller = TextEditingController();
  final String myEmail = FirebaseAuth.instance.currentUser!.email!;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    final collection = FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages');
    final unreadDocs = await collection.where('isRead', isEqualTo: false).where('senderEmail', isNotEqualTo: myEmail).get();
    for (var doc in unreadDocs.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> _sendMessage (String val) async {
    final text = val.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
      'message': text,
      'createdAt': FieldValue.serverTimestamp(),
      'senderEmail': myEmail,
      'senderName': widget.myName,
      'isRead': false,
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 2,
        title: Row(children: [
          CircleAvatar(backgroundImage: widget.friendPic.isNotEmpty ? NetworkImage(widget.friendPic) : null),
          const SizedBox(width: 10),
          Text(widget.friendName, style: const TextStyle(color: Colors.white)),
        ]),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages')
                  .orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final bool isMe = data['senderEmail'] == myEmail;
                    if (!isMe && data['isRead'] == false) docs[index].reference.update({'isRead': true});

                    return ChatBubble(
                      message: data['message'] ?? '',
                      isMe: isMe,
                      userName: isMe ? "You" : widget.friendName,
                      profilePicUrl: data['profilePic'],
                      isRead: data['isRead'] ?? false,
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildIntegratedInput(),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegratedInput() => Padding(
    padding: const EdgeInsets.all(12.0),
    child: TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: "Send message...",
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: kPrimaryColor, width: 2)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send, color: kPrimaryColor),
          onPressed: () => _sendMessage(_controller.text),
        ),
      ),
    ),
  );
}