import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/screens/search_page.dart';
import 'package:chat_app/screens/notification_page.dart';
import 'package:chat_app/screens/private_chat.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:chat_app/screens/login-page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static String id = 'HomePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String myEmail = FirebaseAuth.instance.currentUser!.email!;
  String myName = "Me";

  @override
  void initState() {
    super.initState();
    _fetchMyName();
  }

  void _fetchMyName() async {
    var snapshot = await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .where('email', isEqualTo: myEmail)
        .get();
    if (snapshot.docs.isNotEmpty && mounted) {
      setState(() => myName = snapshot.docs.first['name'] ?? "Me");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Chats", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.public, color: Colors.white), onPressed: () => Navigator.pushNamed(context, ChatPage.id)),
          SizedBox(
            width: 50,
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage())),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection(kFriendsCollection).where('to', isEqualTo: myEmail).where('isRead', isEqualTo: false).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                    return Positioned(
                      right: 8, top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text("${snapshot.data!.docs.length}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(kFriendsCollection).where('status', isEqualTo: 'accepted').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                var myFriends = snapshot.data?.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['from'] == myEmail || data['to'] == myEmail;
                }).toList() ?? [];

                if (myFriends.isEmpty) return const Center(child: Text("No active chats yet."));
                return ListView.builder(
                  itemCount: myFriends.length,
                  itemBuilder: (context, index) => _buildFriendTile(myFriends[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(hintText: "Search...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
        onSubmitted: (val) {
          if (val.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (context) => SearchResultPage(query: val)));
        },
      ),
    );
  }

  Widget _buildFriendTile(QueryDocumentSnapshot friendDoc) {
    var friendData = friendDoc.data() as Map<String, dynamic>;
    String friendEmail = friendData['from'] == myEmail ? friendData['to'] : friendData['from'];
    String chatId = ([myEmail, friendEmail]..sort()).join("_");

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection(kUsersCollection).where('email', isEqualTo: friendEmail).get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData || userSnap.data!.docs.isEmpty) return const SizedBox();
        var userData = userSnap.data!.docs.first.data() as Map<String, dynamic>;

        return ListTile(
          leading: CircleAvatar(backgroundImage: (userData['profilePic'] != null && userData['profilePic'].isNotEmpty) ? NetworkImage(userData['profilePic']) : null),
          title: Text(userData['name'] ?? 'User'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Remove Friend"),
                  content: Text("Are you sure you want to remove ${userData['name']}?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () async {
                        await friendDoc.reference.delete();
                        Navigator.pop(context);
                      },
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PrivateChat(chatId: chatId, friendName: userData['name'], friendPic: userData['profilePic'] ?? '', myName: myName))),
        );
      },
    );
  }
}