import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/helper/show_snack_bar.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static String id = 'RegisterPage';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey();
  String? email, password, confirmPassword, name, phone;
  bool isLoading = false;
  File? imageFile;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => imageFile = File(pickedFile.path));
    }
  }
  Future<String?> uploadImageToCloudinary(File image) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/dv8innh0c/image/upload");
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = 'fcntun0s';
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      return jsonDecode(responseString)['secure_url'];
    }
    return null;
  }

  // الـ Validators
  String? validateField(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone is required';
    if (!RegExp(r'^[0-9]{11}$').hasMatch(value)) return 'Must be exactly 11 digits';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
                    child: imageFile == null ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey) : null,
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      CustomFormTextField(validator: validateField, onChanged: (data) => name = data, label: "User Name", icon: Icons.person),
                      const SizedBox(height: 10),
                      CustomFormTextField(
                        validator: validatePhone,
                        onChanged: (data) => phone = data,
                        label: "Phone Number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      CustomFormTextField(validator: validateField, onChanged: (data) => email = data, label: 'Email', icon: Icons.email),
                      const SizedBox(height: 10),
                      CustomFormTextField(validator: validateField, isPassword: true, onChanged: (data) => password = data, label: 'Password', icon: Icons.password),
                      const SizedBox(height: 10),
                      CustomFormTextField(
                        isPassword: true,
                        validator: (data) => data != password ? 'Passwords do not match' : null,
                        onChanged: (data) => confirmPassword = data,
                        label: 'Confirm Password',
                        icon: Icons.password,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        onTap: () async {
                          if (formKey.currentState!.validate() && imageFile != null) {
                            setState(() => isLoading = true);
                            try {
                              UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: email!, password: password!,
                              );

                              String? imageUrl = await uploadImageToCloudinary(imageFile!);

                              if (imageUrl != null) {
                                await FirebaseFirestore.instance.collection('users').doc(user.user!.uid).set({
                                  'name': name,
                                  'phone': phone,
                                  'email': email,
                                  'profilePic': imageUrl,
                                  'createdAt': DateTime.now(),
                                });
                                showSnackBar(context, 'Success!');
                                Navigator.pop(context);
                              } else {
                                showSnackBar(context, 'Image upload failed');
                              }
                            } on FirebaseAuthException catch (e) {
                              showSnackBar(context, 'Error: ${e.code}'); // هنا هيطلعلك السبب الحقيقي
                            } catch (e) {
                              showSnackBar(context, 'Error: ${e.toString()}');
                            }
                            setState(() => isLoading = false);
                          } else if (imageFile == null) {
                            showSnackBar(context, 'Please select a profile image');
                          }
                        },
                        text: 'REGISTER',
                        icon: Icons.app_registration,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}