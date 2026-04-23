import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user_model.dart';
import '../dashboard/student_shell.dart';
import '../admin/admin_shell.dart';

/// Two-phase login: Landing showcase → Glassmorphic auth card overlay.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _AuthMode { none, signIn, signUp, unlock }

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  // State
  _AuthMode _authMode = _AuthMode.none;
  bool _stayLoggedIn = true;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _cardController;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<double> _backdropOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _cardScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _backdropOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );

    // Initial check for returning user
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAutoLogin());
  }

  Future<void> _checkAutoLogin() async {
    final authVm = context.read<AuthViewModel>();
    final needsUnlock = await authVm.checkInitialAuth();
    if (!needsUnlock && authVm.uid != null) {
      // User is already logged in (stay logged in without biometrics)
      if (mounted) _navigateAfterAuth(authVm);
    } else if (authVm.useBiometrics && authVm.isBiometricAvailable) {
      // Show unlock card
      if (mounted) _openAuthCard(_AuthMode.unlock);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _cardController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _openAuthCard(_AuthMode mode) {
    setState(() => _authMode = mode);
    _cardController.forward(from: 0);
  }

  void _closeAuthCard() {
    _cardController.reverse().then((_) {
      setState(() {
        _authMode = _AuthMode.none;
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
        _studentIdController.clear();
        _phoneController.clear();
        _confirmController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Layer 1: Full-bleed food hero image ──
          _buildHeroBackground(size),

          // ── Layer 2: Floating food bubbles ──
          _buildFloatingFoodBubbles(size),

          // ── Layer 3: Landing content (brand, features, CTAs) ──
          _buildLandingContent(context, size),

          // ── Layer 4: Glassmorphic auth card overlay ──
          if (_authMode != _AuthMode.none)
            _buildAuthOverlay(context, authVm, size),

          // ── Layer 5: Error toast ──
          if (authVm.error != null) _buildErrorToast(context, authVm),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LAYER 1: Hero food background
  // ─────────────────────────────────────────────
  Widget _buildHeroBackground(Size size) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/cuisine_hero.png',
            fit: BoxFit.cover,
          ),
          // Dark cinematic overlay so text is readable
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.35),
                  AppColors.background.withValues(alpha: 0.15),
                  AppColors.background.withValues(alpha: 0.5),
                  AppColors.background.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LAYER 2: Floating food bubbles
  // ─────────────────────────────────────────────
  Widget _buildFloatingFoodBubbles(Size size) {
    final dishes = [
      _Bubble('🍛', 0.05, 0.22, 52),
      _Bubble('🥘', 0.78, 0.15, 46),
      _Bubble('🍗', 0.65, 0.38, 42),
      _Bubble('🥤', 0.10, 0.45, 40),
      _Bubble('🍰', 0.85, 0.42, 38),
      _Bubble('🥗', 0.40, 0.12, 44),
    ];

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        final t = _floatController.value;
        return Stack(
          children: dishes.map((d) {
            final drift = sin(t * pi * 2 + d.size) * 5;
            return Positioned(
              left: size.width * d.x,
              top: size.height * d.y + drift,
              child: Container(
                width: d.size,
                height: d.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.65),
                  border: Border.all(
                    color: AppColors.primaryContainer.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(d.emoji, style: TextStyle(fontSize: d.size * 0.4)),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  LAYER 3: Landing content
  // ─────────────────────────────────────────────
  Widget _buildLandingContent(BuildContext context, Size size) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar: logo + status
          _buildTopBar(context),

          const Spacer(),

          // Center branding
          _buildBranding(context),

          const SizedBox(height: 32),

          // Feature showcase row
          _buildFeatureChips(),

          const Spacer(),

          // CTA buttons
          _buildCtaButtons(context),

          const SizedBox(height: 16),

          // Legal footer
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Valley View University · Powered by Obsidian Loom',
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppColors.background.withValues(alpha: 0.55),
              border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restaurant_rounded, color: AppColors.primaryContainer, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Campus Eats',
                  style: GoogleFonts.epilogue(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Status pill
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.background.withValues(alpha: 0.55),
                  border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFF4ADE80).withValues(alpha: 0.3),
                          const Color(0xFF4ADE80),
                          _pulseController.value,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kitchen Open',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4ADE80).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Column(
      children: [
        // App name
        Text(
          'CAMPUS\nEATS',
          style: GoogleFonts.epilogue(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurface,
            height: 1.0,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Order Fresh · Track Live · Pick Up Fast',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureChips() {
    final features = [
      _Feature(Icons.restaurant_menu_rounded, 'Fresh Menu'),
      _Feature(Icons.delivery_dining_rounded, 'Quick Pickup'),
      _Feature(Icons.qr_code_scanner_rounded, 'QR Orders'),
      _Feature(Icons.account_balance_wallet_rounded, 'Wallet'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: features.map((f) {
          return Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.background.withValues(alpha: 0.5),
                  border: Border.all(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(f.icon, color: AppColors.primaryContainer, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                f.label,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCtaButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Primary: Sign In
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _openAuthCard(_AuthMode.signIn),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimaryContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Secondary: Create Account
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () => _openAuthCard(_AuthMode.signUp),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Create Account',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.primaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LAYER 4: Glassmorphic auth card overlay
  // ─────────────────────────────────────────────
  Widget _buildAuthOverlay(BuildContext context, AuthViewModel vm, Size size) {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, _) {
        return Stack(
          children: [
            // Dark backdrop (tap to dismiss)
            GestureDetector(
              onTap: vm.isLoading ? null : _closeAuthCard,
              child: Container(
                color: Colors.black.withValues(alpha: 0.6 * _backdropOpacity.value),
              ),
            ),

            // Centered glassmorphic card (Scrolls fully if keyboard pushes it out of bounds)
            Positioned.fill(
              child: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                          top: 20,
                          left: 20,
                          right: 20,
                        ),
                        child: Center(
                          child: Opacity(
                            opacity: _cardOpacity.value,
                            child: Transform.scale(
                              scale: _cardScale.value,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: Material(
                                  color: Colors.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                                      child: Container(
                                        padding: const EdgeInsets.all(28),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.85),
                                          borderRadius: BorderRadius.circular(28),
                                          border: Border.all(
                                            color: AppColors.primaryContainer.withValues(alpha: 0.15),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.35),
                                              blurRadius: 40,
                                              offset: const Offset(0, 16),
                                            ),
                                          ],
                                        ),
                                        // The form contents (no inner scroll view needed anymore)
                                        child: _authMode == _AuthMode.signIn
                                            ? _buildSignInForm(context, vm)
                                            : _authMode == _AuthMode.signUp
                                                ? _buildSignUpForm(context, vm)
                                                : _buildUnlockForm(context, vm),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Sign In Form ──
  Widget _buildSignInForm(BuildContext context, AuthViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Close button row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Welcome Back',
              style: GoogleFonts.epilogue(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            _buildCloseButton(),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Sign in to your account',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 28),

        _buildField(_emailController, 'Email', 'student@vvu.edu.gh',
            Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next),
        const SizedBox(height: 16),
        _buildField(_passwordController, 'Password', '••••••••',
            Icons.lock_outline_rounded,
            isPassword: true),
        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.primaryFixedDim,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Stay Logged In Toggle
        Theme(
          data: ThemeData(unselectedWidgetColor: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
          child: CheckboxListTile(
            value: _stayLoggedIn,
            onChanged: (val) => setState(() => _stayLoggedIn = val ?? true),
            title: Text(
              'Stay Logged In (Enables Biometrics)',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primaryContainer,
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(height: 12),

        _buildSubmitButton(
          label: 'Sign In',
          isLoading: vm.isLoading,
          onPressed: () => _handleSignIn(vm),
        ),
        const SizedBox(height: 16),

        // Switch mode text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No account? ',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => _authMode = _AuthMode.signUp);
              },
              child: Text(
                'Sign Up',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Sign Up Form ──
  Widget _buildSignUpForm(BuildContext context, AuthViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Join Us',
              style: GoogleFonts.epilogue(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            _buildCloseButton(),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Create your Campus Eats account',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 24),

        _buildField(
            _nameController, 'Full Name', 'John Doe', Icons.person_outline_rounded),
        const SizedBox(height: 14),
        _buildField(
            _studentIdController, 'Student ID', '20210001', Icons.badge_outlined),
        const SizedBox(height: 14),
        _buildField(_emailController, 'Campus Email', 'student@vvu.edu.gh',
            Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next),
        const SizedBox(height: 14),
        _buildField(_phoneController, 'Phone', '+233 ...', Icons.phone_android_rounded,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        _buildField(_passwordController, 'Password', '••••••••',
            Icons.lock_outline_rounded,
            isPassword: true),
        const SizedBox(height: 14),
        _buildField(_confirmController, 'Confirm Password', '••••••••',
            Icons.lock_reset_rounded,
            isPassword: true),
        const SizedBox(height: 24),

        _buildSubmitButton(
          label: 'Create Account',
          isLoading: vm.isLoading,
          onPressed: () => _handleSignUp(vm),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already a member? ',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => _authMode = _AuthMode.signIn);
              },
              child: Text(
                'Sign In',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Unlock Form ──
  Widget _buildUnlockForm(BuildContext context, AuthViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Security Check',
          style: GoogleFonts.epilogue(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ).copyWith(letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back, authenticate to continue.',
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        
        // Large Biometric Icon Button
        Center(
          child: GestureDetector(
            onTap: () async {
              final ok = await vm.authenticateWithBiometrics();
              if (ok && mounted) _navigateAfterAuth(vm);
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.25), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 56,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 48),
        
        _buildSubmitButton(
          label: 'Unlock with Biometrics',
          isLoading: vm.isLoading,
          onPressed: () async {
            final ok = await vm.authenticateWithBiometrics();
            if (ok && mounted) _navigateAfterAuth(vm);
          },
        ),
        
        const SizedBox(height: 20),
        
        TextButton(
          onPressed: () async {
            await vm.logout();
            _closeAuthCard();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error.withValues(alpha: 0.8),
          ),
          child: Text(
            'Switch Account / Log Out',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Shared widgets
  // ─────────────────────────────────────────────
  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: _closeAuthCard,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
        ),
        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: GoogleFonts.manrope(color: AppColors.onSurface, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primaryFixed),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1E2125), // Solid dark grey so fields contrast against glassmorphism
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none, // Removed border for cleaner look
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
        ),
        labelStyle: GoogleFonts.manrope(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.8), // Better visibility
          fontSize: 13,
        ),
        floatingLabelStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.primaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        hintStyle: GoogleFonts.manrope(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), // Better visibility
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64, // Increased height to ensure premium feel and zero descender clipping
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24), // Added horizontal breathing room
        ),
        child: isLoading
            ? const SizedBox(
                height: 24, width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.onPrimaryContainer,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w900, // Thicker weight for better stand-out
                  fontSize: 16,
                  letterSpacing: 1.2,
                  height: 1.1, // Controlled line height
                ),
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Auth handlers
  // ─────────────────────────────────────────────
  Future<void> _handleSignIn(AuthViewModel vm) async {
    final success = await vm.login(
      _emailController.text.trim(),
      _passwordController.text,
      stayLoggedIn: _stayLoggedIn,
    );
    if (success && mounted) {
      _navigateAfterAuth(vm);
    } else if (mounted && vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error!), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _handleSignUp(AuthViewModel vm) async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = await vm.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      studentId: _studentIdController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    if (success && mounted) {
      _navigateAfterAuth(vm);
    } else if (mounted && vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error!), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _navigateAfterAuth(AuthViewModel vm) {
    final role = vm.user?.role ?? UserRole.student;
    if (role == UserRole.admin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AdminShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => StudentShell()),
      );
    }
  }

  // ─────────────────────────────────────────────
  //  Error toast
  // ─────────────────────────────────────────────
  Widget _buildErrorToast(BuildContext context, AuthViewModel vm) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  vm.error!,
                  style: GoogleFonts.manrope(
                    color: AppColors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                onPressed: () => vm.clearError(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data models
// ─────────────────────────────────────────────
class _Bubble {
  final String emoji;
  final double x, y, size;
  const _Bubble(this.emoji, this.x, this.y, this.size);
}

class _Feature {
  final IconData icon;
  final String label;
  const _Feature(this.icon, this.label);
}
