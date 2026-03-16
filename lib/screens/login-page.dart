import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/helper/show_snack_bar.dart' show showSnackBar;
import 'package:chat_app/screens/home_page.dart';
import 'package:chat_app/screens/register_page.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = 'LoginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey();
  String? email, password;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              const SizedBox(height: 150),
              Center(child: Image.asset('assets/images/2323232323.png')),
              const Center(
                child: Text('Chat App', style: TextStyle(fontSize: 32, color: Colors.white, fontFamily: 'Pacifico')),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('LOGIN', style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'Pacifico')),
              ),
              CustomFormTextField(
                validator: (data) {
                  if (data!.isEmpty) return 'Email is required';
                  if (!data.contains('@')) return 'Invalid email format';
                  return null;
                },
                onChanged: (data) => email = data,
                label: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 10),
              CustomFormTextField(
                validator: (data) {
                  if (data!.isEmpty) return 'Password is required';
                  return null;
                },
                onChanged: (data) => password = data,
                label: 'Password',
                icon: Icons.password,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'LOGIN',
                icon: Icons.login,
                onTap: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() => isLoading = true);
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email!,
                        password: password!,
                      );
                      setState(() => isLoading = false);
                      Navigator.pushNamedAndRemoveUntil(context, HomePage.id, (route) => false);
                    } on FirebaseAuthException catch (e) {
                      setState(() => isLoading = false);
                      if (e.code == 'invalid-credential') {
                        showSnackBar(context, 'Invalid email or password');
                      } else if (e.code == 'user-not-found') {
                        showSnackBar(context, 'User not found');
                      } else if (e.code == 'wrong-password') {
                        showSnackBar(context, 'Wrong password');
                      } else {
                        showSnackBar(context, 'Error: ${e.code}');
                      }
                    } catch (e) {
                      setState(() => isLoading = false);
                      showSnackBar(context, 'Something went wrong');
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, RegisterPage.id),
                      child: const Text("Sign Up", style: TextStyle(color: Color(0xffC7EDE6), fontWeight: FontWeight.bold, fontFamily: 'Pacifico' )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}