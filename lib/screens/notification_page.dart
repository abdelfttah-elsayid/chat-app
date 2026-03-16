import 'package:chat_app/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markAllAsRead());
  }

  void _markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var query = await FirebaseFirestore.instance.collection(kFriendsCollection)
        .where('to', isEqualTo: user.email)
        .where('isRead', isEqualTo: false).get();

    for (var doc in query.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final String myEmail = FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(kFriendsCollection)
            .where(Filter.or(Filter('to', isEqualTo: myEmail), Filter('from', isEqualTo: myEmail)))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications!"));
          }

          var docs = snapshot.data!.docs.where((d) {
            var data = d.data();
            return (data['to'] == myEmail && data['status'] == 'pending') ||
                (data['from'] == myEmail && data['status'] == 'accepted');
          }).toList();

          if (docs.isEmpty) return const Center(child: Text("No notifications!"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data();
              bool isIncoming = data['to'] == myEmail && data['status'] == 'pending';
              bool isUnread = data['isRead'] == false;
              String otherEmail = isIncoming ? data['from'] : data['to'];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection(kUsersCollection).where('email', isEqualTo: otherEmail).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData || userSnap.data!.docs.isEmpty) return const SizedBox();

                  var userData = userSnap.data!.docs.first.data() as Map<String, dynamic>;
                  String userName = userData['name'] ?? 'User';
                  String? profilePic = userData['profilePic'];

                  return ListTile(
                    tileColor: isUnread ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                    leading: CircleAvatar(
                      backgroundImage: (profilePic != null && profilePic.isNotEmpty) ? NetworkImage(profilePic) : null,
                      child: (profilePic == null || profilePic.isEmpty) ? const Icon(Icons.person) : null,
                    ),
                    title: Text(
                      isIncoming ? "Request from $userName" : "$userName accepted!",
                      style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
                    ),
                    trailing: isIncoming ? Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => doc.reference.update({'status': 'accepted', 'isRead': true}),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => doc.reference.delete(),
                      ),
                    ]) : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}