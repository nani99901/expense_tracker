import 'package:expense_tracker/features/auth_onboarding/presentation/pages/account_setup.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/onboarding/onboarding_bloc.dart';
import '../blocs/onboarding/onboarding_event.dart';


class PinSetupPage extends StatefulWidget {
  const PinSetupPage({Key? key}) : super(key: key);

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String pin = '';
  String confirm = '';
  bool confirming = false;

  void _onNumberTap(String number) {
    setState(() {
      if (!confirming) {
        if (pin.length < 4) pin += number;
        if (pin.length == 4) {
          // Auto-advance to confirmation after a brief delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                confirming = true;
              });
            }
          });
        }
      } else {
        if (confirm.length < 4) confirm += number;
        if (confirm.length == 4) {
          // Auto-submit after completing confirmation
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _submit();
            }
          });
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (confirming && confirm.isNotEmpty) {
        confirm = confirm.substring(0, confirm.length - 1);
      } else if (confirming && confirm.isEmpty) {
        confirming = false;
      } else if (!confirming && pin.isNotEmpty) {
        pin = pin.substring(0, pin.length - 1);
      }
    });
  }

  void _submit() {
    if (pin.length == 4 && confirm.length == 4 && pin == confirm) {
      context.read<OnboardingBloc>().add(SetPinEvent(pin));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AccountSetup()),
        (route) => false,
      );
    } else {
      // Reset confirmation on mismatch
      setState(() {
        confirm = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = confirming ? confirm : pin;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8E4EFF),
              Color(0xFF7F3DFF),
              Color(0xFF6B2FDB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              
              SizedBox(),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       const Text(
              //         '9:41',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 15,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //       Row(
              //         children: [
              //           Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
              //           const SizedBox(width: 4),
              //           Icon(Icons.wifi, color: Colors.white, size: 16),
              //           const SizedBox(width: 4),
              //           Icon(Icons.battery_full, color: Colors.white, size: 20),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              
              const Spacer(),
              
              // Title
              Text(
                confirming ? "Ok. Re type your PIN again." : "Let's setup your PIN",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < active.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: filled ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              
              const Spacer(),
              
              // Keyboard
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    _keypadRow(['1', '2', '3']),
                    _keypadRow(['4', '5', '6']),
                    _keypadRow(['7', '8', '9']),
                    _keypadRow(['', '0', 'back']),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keypadRow(List<String> keys) {
    return Row(
      children: keys.map((k) {
        if (k.isEmpty) return const Expanded(child: SizedBox(height: 80));
        return Expanded(
          child: InkWell(
            onTap: () => k == 'back' ? _onBackspace() : _onNumberTap(k),
            child: SizedBox(
              height: 80,
              child: Center(
                child: k == 'back'
                    ? const Icon(Icons.backspace_outlined, size: 28, color: Color(0xFF212325))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            k,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF212325),
                            ),
                          ),
                          if (k != '0')
                            Text(
                              _getLetters(k),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF91919F),
                                letterSpacing: 2,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getLetters(String number) {
    const letters = {
      '1': '',
      '2': 'ABC',
      '3': 'DEF',
      '4': 'GHI',
      '5': 'JKL',
      '6': 'MNO',
      '7': 'PQRS',
      '8': 'TUV',
      '9': 'WXYZ',
    };
    return letters[number] ?? '';
  }
}