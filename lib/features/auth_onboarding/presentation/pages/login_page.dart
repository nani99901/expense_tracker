import 'dart:async';
import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/pin_setup_page.dart';
import 'package:expense_tracker/features/home/presentation/pages/app_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/signup_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/onboarding/onboarding_bloc.dart';
import '../blocs/onboarding/onboarding_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

String _mapAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No user found for that email';
    case 'wrong-password':
      return 'Incorrect password';
    case 'invalid-email':
      return 'Invalid email';
    case 'user-disabled':
      return 'User disabled';
    default:
      return 'Login failed (${e.code})';
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  // final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  // bool agreed = false;
  bool obscure = true;

  @override
  void dispose() {
    // nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(),
    );

    
    final uid = cred.user?.uid;
    if (uid != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      final snap = await userDoc.get();
      if (!snap.exists) {
        await userDoc.set({
          'uid': uid,
          'email': emailCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final snap = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .limit(1)
              .get();
          if (!mounted) return;
          if (snap.docs.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AppShell()),
            );
            return;
          }
        } catch (_) {}
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PinSetupPage()),
      );
    });
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    final msg = _mapAuthError(e);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  } catch (e) {
    // catch *unknown* errors (important)
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Something went wrong. Try again.")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF212325),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212325)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Name
              // _inputField("Name", nameCtrl, false),
              const SizedBox(height: 24),

              // Email
              _inputField("Email", emailCtrl, false),
              const SizedBox(height: 24),

              // Password
              TextFormField(
                controller: passCtrl,
                obscureText: obscure,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(
                    color: Color(0xFF91919F),
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFF1F1FA),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFF1F1FA),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF7F3DFF),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF91919F),
                    ),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),


              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Forgot password not implemented')),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

               RichText(
                 text: TextSpan(
                   style: const TextStyle(
                     color: Color(0xFF000000),
                     fontSize: 14,
                     height: 1.4,
                   ),
                   children: [
                     const TextSpan(
                       text: "Don't have an account yet? ",
                     ),
                     TextSpan(
                       text: "Sign Up",
                       style: const TextStyle(color: AppColors.primary),
                       recognizer: TapGestureRecognizer()
                         ..onTap = () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => const SignUpPage(),
                             ),
                           );
                         },
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

  Widget _inputField(String hint, TextEditingController ctrl, bool isPassword) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF91919F), fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF1F1FA), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF1F1FA), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $hint';
        }
        if (hint == "Email" && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}
