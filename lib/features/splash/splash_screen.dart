import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _dropController;

  late Animation<double> _ripple1;
  late Animation<double> _ripple2;
  late Animation<double> _ripple3;
  late Animation<double> _dropScale;
  late Animation<double> _dropOpacity;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _ripple1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _ripple2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOut),
      ),
    );
    _ripple3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _dropScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _dropController, curve: Curves.easeOut));

    _dropOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dropController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.3), weight: 50),
    ]).animate(_dropController);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _rippleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _dropController.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, a, b) => widget.nextScreen,
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, a, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070E1B),
      body: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _rippleController,
                builder: (context, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    _RippleRing(
                      progress: _ripple1.value,
                      maxRadius: 110,
                      color: AppColors.primary,
                    ),
                    _RippleRing(
                      progress: _ripple2.value,
                      maxRadius: 95,
                      color: AppColors.primary,
                    ),
                    _RippleRing(
                      progress: _ripple3.value,
                      maxRadius: 80,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _dropController,
                builder: (context, child) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary
                            .withAlpha((_glowOpacity.value * 180).toInt()),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _dropController,
                builder: (context, child) => Opacity(
                  opacity: _dropOpacity.value,
                  child: Transform.scale(
                    scale: _dropScale.value,
                    child: const _DropletIcon(size: 100),
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

class _DropletIcon extends StatelessWidget {
  final double size;
  const _DropletIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DropletPainter(),
    );
  }
}

class _DropletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final dropPath = Path();
    final cx = w / 2;
    dropPath.moveTo(cx, h * 0.10);
    dropPath.cubicTo(
      cx - w * 0.38, h * 0.30,
      cx - w * 0.42, h * 0.55,
      cx - w * 0.30, h * 0.72,
    );
    dropPath.arcToPoint(
      Offset(cx + w * 0.30, h * 0.72),
      radius: Radius.circular(w * 0.30),
      clockwise: false,
    );
    dropPath.cubicTo(
      cx + w * 0.42, h * 0.55,
      cx + w * 0.38, h * 0.30,
      cx, h * 0.10,
    );
    dropPath.close();

    final gradient = const LinearGradient(
      colors: [Color(0xFF00E5FF), Color(0xFF00C2CB), Color(0xFF0077A8)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dropPath, paint);

    final glossPath = Path();
    glossPath.moveTo(cx - w * 0.18, h * 0.20);
    glossPath.cubicTo(
      cx - w * 0.28, h * 0.32,
      cx - w * 0.30, h * 0.46,
      cx - w * 0.22, h * 0.54,
    );
    glossPath.cubicTo(
      cx - w * 0.18, h * 0.44,
      cx - w * 0.14, h * 0.30,
      cx - w * 0.10, h * 0.20,
    );
    glossPath.close();

    canvas.drawPath(
      glossPath,
      Paint()
        ..color = Colors.white.withAlpha(90)
        ..style = PaintingStyle.fill,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - w * 0.12, h * 0.18),
        width: w * 0.08,
        height: h * 0.06,
      ),
      Paint()
        ..color = Colors.white.withAlpha(160)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RippleRing extends StatelessWidget {
  final double progress;
  final double maxRadius;
  final Color color;

  const _RippleRing({
    required this.progress,
    required this.maxRadius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();
    final radius = progress * maxRadius;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withAlpha((opacity * 80).toInt()),
          width: 1.5,
        ),
      ),
    );
  }
}
