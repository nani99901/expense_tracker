import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/success_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/onboarding/onboarding_bloc.dart';
import '../blocs/onboarding/onboarding_event.dart';
import '../../domain/entities/user.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// const Color _primaryPurple = Color(0xFF7F3DFF);

const List<String> accountTypes = ['Savings', 'Current', 'Salary'];

class AddWallet extends StatefulWidget {
  const AddWallet({super.key});

  @override
  State<AddWallet> createState() => _AddWalletState();
}

class _AddWalletState extends State<AddWallet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedAccountType;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final wallet = Wallet(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      balance: 0.0,
      type: selectedAccountType ?? 'Wallet',
    );

    context.read<OnboardingBloc>().add(AddWalletEvent(wallet));
    context.read<OnboardingBloc>().add(CompleteOnboarding());

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wallets')
            .doc(wallet.id)
            .set({
          'name': wallet.name,
          'type': wallet.type,
          'balance': wallet.balance,
        });
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SuccessPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Add new wallet',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Align(
                alignment: Alignment.center,
                child: const Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '₹00.0',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 16.0,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          if (value.trim().length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      DropdownButtonFormField<String>(
                        value: selectedAccountType,
                        decoration: InputDecoration(
                          hintText: 'Account Type',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 16.0,
                          ),
                        ),
                        isExpanded: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please choose an account type';
                          }
                          return null;
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                        items: accountTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedAccountType = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
