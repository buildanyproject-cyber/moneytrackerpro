import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_buttons.dart';

// ============================================================
// Splash Screen — Animated loading with app logo + biometric/PIN
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _authFailed = false;
  bool _showPinInput = false;
  final _pinController = TextEditingController();
  String _pinError = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final settings = context.read<SettingsProvider>();

    if (!kIsWeb && settings.biometricEnabled) {
      bool authenticated = false;
      final auth = LocalAuthentication();
      try {
        final canCheck =
            await auth.canCheckBiometrics || await auth.isDeviceSupported();
        if (canCheck) {
          authenticated = await auth.authenticate(
            localizedReason: 'Unlock MoneyTracker Pro',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: false,
            ),
          );
        } else {
          // Device doesn't support biometrics, try PIN
          if (settings.hasPin) {
            if (mounted) setState(() => _showPinInput = true);
            return;
          }
          authenticated = true; // No biometrics, no PIN — skip
        }
      } catch (e) {
        // On biometric error, fallback to PIN if available
        if (settings.hasPin) {
          if (mounted) setState(() => _showPinInput = true);
          return;
        }
        authenticated = true; // No PIN fallback, allow entry
      }

      if (!authenticated) {
        // Biometric failed — offer PIN fallback if available
        if (settings.hasPin) {
          if (mounted) setState(() => _showPinInput = true);
          return;
        }
        if (mounted) setState(() => _authFailed = true);
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _verifyPin() {
    final settings = context.read<SettingsProvider>();
    if (settings.verifyPin(_pinController.text)) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _pinError = 'Incorrect PIN. Try again.';
        _pinController.clear();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF4834D4), Color(0xFF2C2154)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // App name
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppConstants.appTagline,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // PIN Input or Loading/Retry
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _showPinInput
                      ? _buildPinInput()
                      : _authFailed
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 48),
                              child: Column(
                                children: [
                                  PrimaryButton(
                                    label: 'Retry Authentication',
                                    icon: Icons.fingerprint,
                                    onPressed: () {
                                      setState(() {
                                        _authFailed = false;
                                        _showPinInput = false;
                                      });
                                      _navigateToNext();
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  if (context
                                      .read<SettingsProvider>()
                                      .hasPin) ...[
                                    TextButton(
                                      onPressed: () => setState(
                                          () => _showPinInput = true),
                                      child: const Text(
                                        'Use PIN Instead',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPinInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          const Text(
            'Enter PIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '• • • •',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
            ),
            onSubmitted: (_) => _verifyPin(),
          ),
          if (_pinError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _pinError,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Unlock',
            icon: Icons.lock_open,
            onPressed: _verifyPin,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _showPinInput = false;
                _authFailed = false;
              });
              _navigateToNext();
            },
            child: const Text(
              'Try Biometric Again',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
