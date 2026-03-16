import 'package:chat_app/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchResultPage extends StatelessWidget {
  final String query;
  final String myEmail = FirebaseAuth.instance.currentUser!.email!;

  SearchResultPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Results")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(kUsersCollection)
            .where('name', isEqualTo: query)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No user found"));
          }

          var userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          String targetEmail = userData['email'];

          if (targetEmail == myEmail) {
            return const Center(child: Text("You cannot add yourself"));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(kFriendsCollection)
                .where('from', isEqualTo: myEmail)
                .where('to', isEqualTo: targetEmail)
                .snapshots(),
            builder: (context, fSnapshot) {
              bool isRequested = fSnapshot.hasData && fSnapshot.data!.docs.isNotEmpty;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: userData['profilePic'] != null && userData['profilePic'].isNotEmpty
                      ? NetworkImage(userData['profilePic'])
                      : null,
                  child: (userData['profilePic'] == null || userData['profilePic'].isEmpty)
                      ? const Icon(Icons.person) : null,
                ),
                title: Text(userData['name']),
                trailing: IconButton(
                  icon: Icon(
                    isRequested ? Icons.cancel : Icons.person_add,
                    color: isRequested ? Colors.red : Colors.blue,
                  ),
                  onPressed: () {
                    if (isRequested) {
                      fSnapshot.data!.docs.first.reference.delete();
                    } else {
                      FirebaseFirestore.instance.collection(kFriendsCollection).add({
                        'from': myEmail,
                        'to': targetEmail,
                        'status': 'pending',
                        'isRead': false,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}