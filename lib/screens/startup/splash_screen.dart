import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../services/token_storage_service.dart';
import '../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bookController;
  late AnimationController _contentController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _bookOpenAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _glowAnimation;

  int _currentTipIndex = 0;
  List<Map<String, dynamic>> get _educationalTips {
    return [
      {
        'icon': Icons.medical_services_rounded,
        'text': 'منتجات طب أسنان متميزة'
      },
      {'icon': Icons.trending_up, 'text': 'شريكك في التميز المهني'},
      {
        'icon': Icons.emoji_events_outlined,
        'text': 'رواد طب الأسنان في الشرق الأوسط'
      },
    ];
  }

  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _bookController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _bookOpenAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeOutBack),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    _logoRotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _bookController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    _loadingController.forward();

    _tipTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _educationalTips.length;
        });
      }
    });

    Timer(const Duration(milliseconds: 4000), () {
      _checkFirstLaunch();
    });
  }

  Future<void> _checkFirstLaunch() async {
    const timeoutDuration = Duration(seconds: 6);
    try {
      await _checkFirstLaunchImpl().timeout(
        timeoutDuration,
        onTimeout: () {
          if (kDebugMode) print('⚠️ Splash: timeout — navigating to login');
          _navigateToLogin();
        },
      );
    } catch (e) {
      if (kDebugMode) print('⚠️ Splash: error $e — navigating to login');
      if (mounted) _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  Future<void> _checkFirstLaunchImpl() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('hasLaunched') ?? false;

    if (!mounted) return;

    if (!hasLaunched) {
      context.go(RouteNames.onboarding1);
      return;
    }

    final isLoggedIn = await TokenStorageService.instance.isLoggedIn();
    if (!isLoggedIn) {
      context.go(RouteNames.login);
      return;
    }

    final role = await TokenStorageService.instance.getUserRole();
    final roleLower = role?.toLowerCase() ?? 'student';
    if (roleLower == 'instructor' || roleLower == 'teacher') {
      context.go(RouteNames.instructorHome);
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  void dispose() {
    _bookController.dispose();
    _contentController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD42535),
              Color(0xFFB01E2D),
              Color(0xFF8C1722),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundPattern(size),
            ...List.generate(15, (i) => _buildFloatingParticle(i, size)),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildLogoSection(),
                  const SizedBox(height: 40),
                  _buildAppName(),
                  const Spacer(flex: 1),
                  _buildEducationalTip(),
                  const SizedBox(height: 40),
                  _buildLoadingSection(),
                  const Spacer(flex: 1),
                  _buildBottomBranding(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.3,
          right: -size.width * 0.3,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1 * _glowAnimation.value),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -size.width * 0.2,
          left: -size.width * 0.2,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingParticle(int index, Size size) {
    final random = math.Random(index);
    final particleSize = random.nextDouble() * 6 + 3;
    final startX = random.nextDouble() * size.width;
    final startY = random.nextDouble() * size.height;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final offset =
            math.sin(_glowController.value * math.pi * 2 + index) * 20;
        return Positioned(
          left: startX + offset,
          top: startY + offset * 0.5,
          child: Container(
            width: particleSize,
            height: particleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3 + _glowAnimation.value * 0.3),
              boxShadow: [
                BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 10)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_bookController, _contentController, _glowController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200 * _logoScaleAnimation.value,
              height: 200 * _logoScaleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.2 * _glowAnimation.value),
                    width: 2),
              ),
            ),
            Container(
              width: 170 * _logoScaleAnimation.value,
              height: 170 * _logoScaleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color:
                        Colors.white.withOpacity(0.15 * _glowAnimation.value),
                    width: 1),
              ),
            ),
            Container(
              width: 160 * _glowAnimation.value,
              height: 160 * _glowAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color:
                          Colors.white.withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 50,
                      spreadRadius: 10)
                ],
              ),
            ),
            Transform.scale(
              scale: _logoScaleAnimation.value,
              child: Transform.rotate(
                angle: _logoRotateAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 15))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/medex_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.medical_services_rounded,
                            size: 60, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 60,
              child: Transform.scale(
                scale: _logoScaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFD42535), Color(0xFFB01E2D)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 15)
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome,
                      size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeAnimation.value.clamp(0.0, 1.0),
          child: Transform.translate(
              offset: Offset(0, _textSlideAnimation.value), child: child),
        );
      },
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFFFCDD2)],
            ).createShader(bounds),
            child: Text(
              'MEDEX',
              style: GoogleFonts.cairo(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1)
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medical_services_rounded,
                    size: 18, color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 8),
                Text(
                  'رواد طب الأسنان في مصر والشرق الأوسط',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalTip() {
    final tip = _educationalTips[_currentTipIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, slideChild) {
            return Opacity(
              opacity: animation.value.clamp(0.0, 1.0),
              child: slideChild,
            );
          },
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                    .animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_currentTipIndex),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child:
                  Icon(tip['icon'] as IconData, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                tip['text'] as String,
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              width: 180,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: _loadingController.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.white70, Colors.white]),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.5), blurRadius: 6)
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final delay = index * 0.3;
                    final value = ((_glowController.value + delay) % 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.4 + value * 0.6),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBranding() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: (_textFadeAnimation.value * 0.7).clamp(0.0, 1.0),
          child: child,
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_rounded,
                  size: 16, color: Colors.white.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text(
                'Medex Medical - Premium Dental Solutions',
                style: GoogleFonts.cairo(
                    fontSize: 11, color: Colors.white.withOpacity(0.6)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'v1.0.0',
            style: GoogleFonts.cairo(
                fontSize: 10, color: Colors.white.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}
