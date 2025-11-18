import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:expense_tracker/features/home/presentation/pages/edit_wallet_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 32),
              child: Column(
                children: [
                  
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Stack(
                      children: [
                       
                        Positioned(
                          left: -30,
                          top: 40,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.4),
                                  AppColors.primary.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        Positioned(
                          left: 100,
                          top: 20,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.5),
                                  AppColors.primary.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Center circle
                        Positioned(
                          left: 150,
                          top: 90,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.4),
                                  AppColors.primary.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        Positioned(
                          right: 50,
                          top: 80,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.45),
                                  AppColors.primary.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        Positioned(
                          right: -40,
                          top: 0,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.5),
                                  AppColors.primary.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Center content
                        Center(
                          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Account Balance',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${total.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditWalletPage(),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/wallet_2.svg'),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Wallet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: user == null
                          ? Stream.empty()
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
                        return Text(
                          '₹${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Divider(thickness: 0.2,),

             Spacer(),

            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    
                  },
                  child: const Text(
                    '+ Add new wallet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}