import 'package:chat_app/constants/constants.dart';
import 'package:flutter/material.dart';

class CustomChatTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSubmitted;

  const CustomChatTextField({
    super.key,
    this.controller,
    this.onSubmitted,
    required String hintText ,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted, // هيتنفذ لما المستخدم يدوس زرار "Done" في الكيبورد
        style: const TextStyle(color: Colors.black), // اللون الأسود اللي طلبته
        decoration: InputDecoration(
          hintText: "Send a message",
          hintStyle: const TextStyle(color: Colors.grey),

          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: kPrimaryColor),
            onPressed: () {
              if (onSubmitted != null && controller != null) {
                onSubmitted!(controller!.text);
                controller!.clear(); // مسح النص بعد الإرسال
              }
            },
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kPrimaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}