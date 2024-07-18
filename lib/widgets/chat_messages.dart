import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }
        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, i) {
              final chatData = loadedMessages[i].data();
              final nextChatData = i + 1 < loadedMessages.length
                  ? loadedMessages[i + 1].data()
                  : null;
              final currentUserId = chatData['userId'];
              final nextUserId =
                  nextChatData != null ? nextChatData['userId'] : null;
              if (currentUserId == nextUserId) {
                return MessageBubble.next(
                  message: chatData['message'],
                  isMe: authenticatedUser.uid == currentUserId,
                );
              } else {
                return MessageBubble.first(
                  userImage: chatData['userImage'],
                  username: chatData['username'],
                  message: chatData['message'],
                  isMe: authenticatedUser.uid == currentUserId,
                );
              }
            });
      },
    );
  }
}
