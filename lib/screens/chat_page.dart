import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/widgets/custom_chat_bubble.dart';
import 'package:chat_app/widgets/custom_chat_message.dart'; // تأكد من استيراد الكود الخاص بالـ Input
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  static String id = 'ChatPage';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final CollectionReference messages = FirebaseFirestore.instance.collection(kMessagesCollections);
  final TextEditingController _controller = TextEditingController();

  Future<void> sendMessage(String text) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (text.trim().isEmpty || user == null) return;

    try {
      var userDoc = await FirebaseFirestore.instance.collection(kUsersCollection).doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.exists ? (userDoc.data() as Map<String, dynamic>) : {};

      await messages.add({
        'message': text,
        'createdAt': FieldValue.serverTimestamp(),
        'senderEmail': user.email,
        'userName': userData['name'] ?? "User",
        'profilePic': userData['profilePic'] ?? "",
      });
      _controller.clear();
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: kPrimaryColor, title: const Text("Global Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messages.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No messages yet."));

                var messagesList = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    var data = messagesList[index].data() as Map<String, dynamic>;
                    return ChatBubble(
                      message: data['message'] ?? "",
                      isMe: data['senderEmail'] == FirebaseAuth.instance.currentUser?.email,
                      userName: data['userName'] ?? "User",
                      profilePicUrl: data['profilePic'],
                      isRead: true,
                    );
                  },
                );
              },
            ),
          ),
          CustomChatTextField(controller: _controller, hintText: "Send a message", onSubmitted: sendMessage),
        ],
      ),
    );
  }
}