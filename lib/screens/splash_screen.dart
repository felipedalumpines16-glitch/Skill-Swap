import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const _primaryTeal = Color(0xFF087E8B);
  static const _secondaryAqua = Color(0xFF12A3A5);
  static const _mainText = Color(0xFF172B3A);
  static const _secondaryText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: _primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          size: 54,
                          color: _primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'SkillSwap',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _mainText,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Learn Something. Share Something.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: constraints.maxHeight < 500 ? 16 : 32,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _secondaryAqua,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Getting things ready…',
                          style: TextStyle(color: _secondaryText, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
