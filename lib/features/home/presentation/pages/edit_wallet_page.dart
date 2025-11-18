import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditWalletPage extends StatefulWidget {
  const EditWalletPage({super.key});

  @override
  State<EditWalletPage> createState() => _EditWalletPageState();
}

class _EditWalletPageState extends State<EditWalletPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedAccountType;
  String? _walletDocId;
  bool _loadingWallet = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loadingWallet = false;
      });
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wallets')
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        final data = doc.data();
        _walletDocId = doc.id;
        _nameController.text = (data['name'] as String?) ?? '';
        _selectedAccountType = data['type'] as String?;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _loadingWallet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Edit account',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions:  [
          // Padding(
          //   padding: EdgeInsets.only(right: 16),
          //   child: Icon(Icons.delete_outline, color: Colors.white),
          // ),
          GestureDetector(
            onTap: () {
              
            },
            child: Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: SvgPicture.asset('assets/trash.svg'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                 Align(
                  alignment: AlignmentGeometry.topLeft,
                   child: Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                                   ),
                 ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: user == null
                      ? const Stream.empty()
                      : FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('transactions')
                          .snapshots(),
                  builder: (context, snapshot) {
                    double total = 0;
                    if (snapshot.hasData) {
                      for (final doc in snapshot.data!.docs) {
                        final data = doc.data();
                        final amount = (data['amount'] as num).toDouble();
                        final isIncome = (data['isIncome'] as bool?) ?? false;
                        total += isIncome ? amount : -amount;
                      }
                    }
                    return Align(
                  alignment: AlignmentGeometry.topLeft,
                      child: Text(
                        '₹${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
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
                        value: _selectedAccountType,
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
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Bank',
                            child: Text(
                              'Bank',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Wallet',
                            child: Text(
                              'Wallet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Savings',
                            child: Text(
                              'Savings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Current',
                            child: Text(
                              'Current',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Salary',
                            child: Text(
                              'Salary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null && _walletDocId != null) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('wallets')
                                    .doc(_walletDocId)
                                    .update({
                                  'name': _nameController.text.trim(),
                                  'type': _selectedAccountType ?? 'Wallet',
                                });
                              } catch (_) {}
                            }

                            if (!mounted) return;
                            Navigator.of(context).pop();
                          },
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
