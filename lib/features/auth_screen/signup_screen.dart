import 'package:blog_app/features/blog_screen.dart';
import 'package:blog_app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 50),
              child: Row(
                children: [
                  Text("Sign ",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 26)),
                  Text("up!",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 26)),
                ],
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: "email"),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: "password"),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    final String email = _emailController.text.trim();
                    final String password = _passwordController.text.trim();

                    // Sign up user with email and password
                    final UserCredential userCredential =
                        await _auth.createUserWithEmailAndPassword(
                            email: email, password: password);

                    // Navigate to home screen if signup is successful
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomeScreen()));
                  } catch (e) {
                    // Handle signup errors
                    print('Signup Error: $e');
                    CustomErrorDialog.show(context, "Alert", e.toString());
                    // You can show an error message to the user
                  }
                },
                child: const Text(
                  "Signup",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
