
import 'dart:async';

import 'package:expense_tracker/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<String> code = List.filled(6, '');
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  int secondsRemaining = 299; 
  Timer? timer;
  bool showKeyboard = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    this.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _timeString {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onNumberTap(String number) {
    setState(() {
      for (int i = 0; i < code.length; i++) {
        if (code[i].isEmpty) {
          code[i] = number;
          break;
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      for (int i = code.length - 1; i >= 0; i--) {
        if (code[i].isNotEmpty) {
          code[i] = '';
          break;
        }
      }
    });
  }

  void _verify() {
    String code = this.code.join();
    if (code.length == 6) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _resendCode() {
    setState(() {
      secondsRemaining = 299;
      code.fillRange(0, code.length, '');
    });
    _startTimer();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification code sent!')));
  }

  @override
  Widget build(BuildContext context) {
    String maskedEmail = widget.email.replaceRange(
      2,
      widget.email.indexOf('@'),
      '*' * (widget.email.indexOf('@') - 2),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Verification',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  const Text(
                    'Enter your\nVerification Code',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212325),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 40),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: code[index].isNotEmpty
                                ? AppColors.primary
                                : const Color(0xFFF1F1FA),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          code[index],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212325),
                          ),
                        ),
                      );
                    }),
                  ),

//                   Row(
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: List.generate(6, (index) {
//     // Determine if the current index has a number entered
//     bool isEntered = _code.length > index && _code[index].isNotEmpty;

//     return Container(
//       width: 16, // Smaller width for a small dot/circle
//       height: 16, // Smaller height for a small dot/circle
//       decoration: BoxDecoration(
//         color: isEntered
//             ? const Color(0xFF212325) // Semi-black color when a number is entered (filled circle)
//             : const Color(0xFFF1F1FA), // Lighter color for empty circles (semi-black border is gone)
//         shape: BoxShape.circle, // Make it a circle
//       ),
//       alignment: Alignment.center,
//       child: isEntered
//           ? Text(
//               _code[index],
//               style: const TextStyle(
//                 fontSize: 12, // Smaller font size to fit in the small circle
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white, // White color for the number inside the black circle
//               ),
//             )
//           : null, // Display nothing if the circle is empty
//     );
//   }),
// ),


                  const SizedBox(height: 24),

                  Text(
                    _timeString,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF91919F),
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                          text: 'We send verification code to your email ',
                        ),
                        TextSpan(
                          text: maskedEmail,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212325),
                          ),
                        ),
                        const TextSpan(text: '. You can check your inbox.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _resendCode,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF212325),
                        ),
                        children: [
                          const TextSpan(text: "I didn't received the code? "),
                          TextSpan(
                            text: "Send again",
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Verify",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom number keyboard
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Column(
              children: [
                _buildKeyboardRow(['1', '2', '3']),
                _buildKeyboardRow(['4', '5', '6']),
                _buildKeyboardRow(['7', '8', '9']),
                _buildKeyboardRow(['', '0', 'backspace']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        if (key.isEmpty) {
          return const Expanded(child: SizedBox(height: 60));
        }

        return Expanded(
          child: InkWell(
            onTap: () {
              if (key == 'backspace') {
                _onBackspace();
              } else {
                _onNumberTap(key);
              }
            },
            child: Container(
              height: 60,
              alignment: Alignment.center,
              child: key == 'backspace'
                  ? const Icon(Icons.backspace_outlined, size: 24)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          key,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212325),
                          ),
                        ),
                        if (key != '0')
                          Text(
                            _getLetters(key),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF91919F),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getLetters(String number) {
    const letters = {
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
