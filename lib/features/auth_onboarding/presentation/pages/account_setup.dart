import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/add_wallet_page.dart';
import 'package:flutter/material.dart';

class AccountSetup extends StatefulWidget {
  const AccountSetup({super.key});

  @override
  State<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 150, left: 24, right: 24, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
        
                const Text(
                  "Let's setup your\naccount!",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212325),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 20),
                Text('Account can be your bank, credit card or\nyour wallet.'),
              ],
            ),
        
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWallet()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Let's Go",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
