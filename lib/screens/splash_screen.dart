import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.blueDark,
              AppColors.blueMid,
              Color(0xFF12396C),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 80,
                right: -30,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blueLight.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.blueDark.withValues(alpha: 0.28),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: _LogoPainter(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Digital Car Passport',
                          style: AppTextStyles.h1White.copyWith(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Know before you buy.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white60,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white10,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.white15),
                          ),
                          child: const Text(
                            'One app. Every data source. Instant trust.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shield = Paint()..color = AppColors.blueAccent;
    final accent = Paint()..color = AppColors.teal;
    final outline = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height * 0.2)
      ..lineTo(size.width * 0.88, size.height * 0.78)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.12, size.height * 0.78)
      ..lineTo(0, size.height * 0.2)
      ..close();
    canvas.drawPath(outline, shield);

    final road = Path()
      ..moveTo(size.width * 0.32, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.46,
        size.width * 0.42,
        size.height * 0.82,
      )
      ..lineTo(size.width * 0.58, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.46,
        size.width * 0.68,
        size.height * 0.2,
      )
      ..close();
    canvas.drawPath(road, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.54),
      4,
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
