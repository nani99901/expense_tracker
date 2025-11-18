import 'package:expense_tracker/features/home/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/landing_screen.dart';
import 'package:expense_tracker/features/home/presentation/pages/account_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : 'Sai Priya';
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: user == null
                              ? const Stream.empty()
                              : FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .snapshots(),
                          builder: (context, snap) {
                            String display = name;
                            if (snap.hasData && snap.data!.data() != null) {
                              final data = snap.data!.data()!;
                              final fromFs = data['name'];
                              if (fromFs is String &&
                                  fromFs.trim().isNotEmpty) {
                                display = fromFs.trim();
                              }
                            }
                            return Text(
                              display,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset('assets/edit.svg'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _menuTile(
                      context,
                      assetName: 'wallet',
                      title: 'Account',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F3F3)),
                    _menuTile(
                      context,
                      assetName: 'settings',
                      title: 'Settings',
                      onTap: () {
                              Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(),
                          ),
                        );
                        
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F3F3)),
                    _menuTile(
                      context,
                      assetName: 'logout',
                      title: 'Logout',
                      onTap: () async {
                        final confirmed = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: false,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (ctx) {
                            return SizedBox(
                              height: 260,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  18,
                                  20,
                                  28,
                                ),
                                child: Column(
                                  children: [
                                    
                                    Container(
                                      width: 44,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD8CFF7),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    
                                    const Text(
                                      'Logout?',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 30),

                                    
                                    const Text(
                                      'Are you sure do you wanna logout?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF8E8E93),
                                        height: 1.4,
                                      ),
                                    ),

                                    // const Spacer(),
                                    SizedBox(height: 30,),
                                    
                                    Row(
                                      children: [
                                        
                                        Expanded(
                                          child: Container(
                                            height: 54,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3EFFF),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text(
                                                'No',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        /// YES Button
                                        Expanded(
                                          child: Container(
                                            height: 54,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        if (confirmed == true) {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => LandingScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
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

  Widget _menuTile(
    BuildContext context, {
    required String assetName,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      minVerticalPadding: 30,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 60,
        height: 60,
        // decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: SvgPicture.asset('assets/$assetName.svg'),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black45),
    );
  }
}
