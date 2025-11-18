import 'package:expense_tracker/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/routing/app_router.dart';

const Color _successGreen = Color(0xFF00A86B);

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _successGreen,
                  shape: BoxShape.circle,
                ),
                child: AnimatedBuilder(
                  animation: _checkAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CheckMarkPainter(
                        progress: _checkAnimation.value,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _checkAnimation,
              child: const Text(
                'You are set!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 8,
        ),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
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
              'Go to Home Screen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class CheckMarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckMarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Check mark coordinates (scaled to container size)
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    // Start point of check mark
    final Offset start = Offset(centerX - 12, centerY);
    // Middle point of check mark
    final Offset middle = Offset(centerX - 2, centerY + 10);
    // End point of check mark
    final Offset end = Offset(centerX + 15, centerY - 12);

    if (progress < 0.5) {
      // Draw first part of check mark (from start to middle)
      final double segmentProgress = progress * 2;
      path.moveTo(start.dx, start.dy);
      path.lineTo(
        start.dx + (middle.dx - start.dx) * segmentProgress,
        start.dy + (middle.dy - start.dy) * segmentProgress,
      );
    } else {
      // Draw complete first part
      path.moveTo(start.dx, start.dy);
      path.lineTo(middle.dx, middle.dy);
      
      // Draw second part of check mark (from middle to end)
      final double segmentProgress = (progress - 0.5) * 2;
      path.lineTo(
        middle.dx + (end.dx - middle.dx) * segmentProgress,
        middle.dy + (end.dy - middle.dy) * segmentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}