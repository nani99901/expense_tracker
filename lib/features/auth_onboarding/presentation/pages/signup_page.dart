import 'dart:async';
import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/verfication_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/onboarding/onboarding_bloc.dart';
import '../blocs/onboarding/onboarding_event.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

String _mapSignupError(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Email already in use';
    case 'invalid-email':
      return 'Invalid email';
    case 'weak-password':
      return 'Weak password';
    default:
      return 'Signup failed (${e.code})';
  }
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool agreed = false;
  bool obscure = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms & Privacy Policy')),
      );
      return;
    }

    context.read<OnboardingBloc>().add(
      StartSignup(name: nameCtrl.text.trim(), email: emailCtrl.text.trim()),
    );

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'uid': uid,
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationPage(email: emailCtrl.text.trim()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = _mapSignupError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Sign Up',
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
              _inputField("Name", nameCtrl, false),
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

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      side: const BorderSide(
                        color: AppColors.primary,
                        // width: 1.5,
                      ),
                      value: agreed,
                      onChanged: (v) => setState(() => agreed = v!),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: "By signing up, you agree to the ",
                          ),
                          TextSpan(
                            text: "Terms of Service and Privacy Policy",
                            style: const TextStyle(color: AppColors.primary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Handle terms tap
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                    "Sign Up",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(
                      color: Color(0xFF91919F),
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: const TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                      ),
                    ],
                  ),
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
