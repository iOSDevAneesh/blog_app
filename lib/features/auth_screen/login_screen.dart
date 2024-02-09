import 'package:blog_app/features/auth_screen/signup_screen.dart';
import 'package:blog_app/features/blog_screen.dart';
import 'package:blog_app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    if (userId != null) {
      // User is already logged in, navigate to home screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ));
    }
  }

  Future<void> _saveUserData(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<UserCredential?> _handleGoogleSignIn() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      // Obtain the GoogleSignInAuthentication object
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await _saveUserData(userCredential.user!.uid);
      // Return the UserCredential
      return userCredential;
    } catch (e) {
      // Handle Google Sign-In errors
      print('Google Sign-In Error: $e');
      return null;
    }
  }

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 50),
              child: Row(
                children: [
                  Text("Welcome to ",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 26)),
                  Text("blog ",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 30)),
                  Text("app!",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 26)),
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
                  final UserCredential userCredential =
                  await _auth.signInWithEmailAndPassword(email: email, password: password);
                  await _saveUserData(userCredential.user!.uid);
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomeScreen()));
                } catch (e) {
                  CustomErrorDialog.show(context, "Alert", e.toString());
                }
              },
              child: const Text(
                'Sign in with email/password',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  UserCredential? userCredential = await _handleGoogleSignIn();
                  if (userCredential != null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ));
                  } else {
                    CustomErrorDialog.show(context, "Alert", "Google Sign-In failed");
                  }
                },
                child: const Text("Sign in with-google")),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SignupScreen()));
              },
              child: const Text("don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
