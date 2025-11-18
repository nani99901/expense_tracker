import 'package:expense_tracker/core/utils/secure_pin_manager.dart';
import 'package:expense_tracker/features/home/presentation/pages/app_shell.dart';
import 'package:flutter/material.dart';

class PinUnlockPage extends StatefulWidget {
  const PinUnlockPage({Key? key}) : super(key: key);

  @override
  State<PinUnlockPage> createState() => _PinUnlockPageState();
}

class _PinUnlockPageState extends State<PinUnlockPage> {
  String pin = '';
  final mgr = SecurePinManager();

  void _onNumberTap(String number) async {
    if (pin.length >= 4) return;
    setState(() => pin += number);
    if (pin.length == 4) {
      final ok = await mgr.verifyPin(pin);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
        );
      } else {
        setState(() => pin = '');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
      }
    }
  }

  void _onBackspace() {
    if (pin.isEmpty) return;
    setState(() => pin = pin.substring(0, pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Text(
              "Enter your PIN",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: filled ? const Color(0xFF212325) : const Color(0xFFF1F1FA),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const Spacer(),
            _keypad(),
          ],
        ),
      ),
    );
  }

  Widget _keypad() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F7),
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Column(
        children: [
          _row(['1', '2', '3']),
          _row(['4', '5', '6']),
          _row(['7', '8', '9']),
          _row(['', '0', 'back'])
        ],
      ),
    );
  }

  Widget _row(List<String> keys) {
    return Row(
      children: keys.map((k) {
        if (k.isEmpty) return const Expanded(child: SizedBox(height: 60));
        return Expanded(
          child: InkWell(
            onTap: () => k == 'back' ? _onBackspace() : _onNumberTap(k),
            child: SizedBox(
              height: 60,
              child: Center(
                child: k == 'back'
                    ? const Icon(Icons.backspace_outlined, size: 24)
                    : Text(
                        k,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF212325)),
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
