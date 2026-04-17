import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../marketplace/marketplace_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Immersive Background Layer
          _buildImmersiveBackground(size),

          // 2. Atmospheric Orbs (Glow)
          _buildAtmosphericOrbs(size),

          // 3. Main Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Top Branding Header
                          _buildTopBranding(context),

                          const Spacer(),

                          // Login Card (Glassmorphism)
                          _buildLoginPanel(context, authViewModel, size),
                          
                          // Bottom Spacing for Mobile
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Global Error Overlay
          if (authViewModel.error != null) _buildErrorSnackbar(context, authViewModel),
        ],
      ),
    );
  }

  Widget _buildImmersiveBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBW7hki1GRaYQ7OThPW9LDkVoTGTJ4tlug1_FHk2mgsQyRaq7DSHNd_40l_XWPIwr7eq0QDXq7AYkxroQuWh0bh3amfx-9X8Hrk4qu71TaUIDICDQuIgz78HS72kywmePjjvgsubTzftmGLX_TBtsKqgunwixZC7ecJ7xvKEqZRSdQjt9NfiZjhXzx2DYYOaNxN1vrA8kUAu03Mi9HNTxpOryzKiQs43LFvUPnuM4G7FSO4JEQ-njvQTiH-ZAxIhRlq0GPtdp1OSVw',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.surfaceContainerLowest,
              AppColors.surfaceContainerLowest.withValues(alpha: 0.4),
              AppColors.surfaceContainerLowest.withValues(alpha: 0.2),
            ],
            stops: const [0.1, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildAtmosphericOrbs(Size size) {
    return Stack(
      children: [
        Positioned(
          top: size.height * 0.25,
          right: -80,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer.withValues(alpha: 0.05),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 384,
            height: 384,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 150, sigmaY: 150),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBranding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CAMPUS EATS',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.primaryContainer,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'THE OBSIDIAN LOOM',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 4.0,
                ),
              ),
            ],
          ),
          // System Status (Admin View Simulation)
          const HiddenOnMobile(
            child: Row(
              children: [
                Text(
                  'SYSTEM ONLINE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Color(0x99DCE3E8),
                  ),
                ),
                SizedBox(width: 16),
                StatusOrb(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPanel(BuildContext context, AuthViewModel vm, Size size) {
    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Layout for Desktop/Tablet would be Row, for Mobile Column
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 700) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _buildWelcomeText(context)),
                          const SizedBox(width: 48),
                          Expanded(child: _buildLoginForm(context, vm)),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildWelcomeText(context),
                          const SizedBox(height: 48),
                          _buildLoginForm(context, vm),
                        ],
                      );
                    }
                  },
                ),
                
                const SizedBox(height: 48),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCESS PORTAL',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.primaryContainer,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'The Kitchen Awaits',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 24),
        Text(
          'Experience the rhythm of Afro-modernist dining. Fresh ingredients, digital precision.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Container(width: 48, height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(width: 12),
            Text(
              'SECURE COMMAND LINK',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.outline,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthViewModel vm) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          style: GoogleFonts.manrope(color: AppColors.onSurface),
          decoration: const InputDecoration(
            labelText: 'STUDENT IDENTIFIER',
            hintText: 'campus.id@university.edu',
            prefixIcon: Icon(Icons.alternate_email, size: 20, color: Color(0x80FFE16D)),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: GoogleFonts.manrope(color: AppColors.onSurface),
          decoration: InputDecoration(
            labelText: 'SECURE KEYPHRASE',
            hintText: '••••••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0x80FFE16D)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'KEEP SESSION',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'LOST ACCESS?',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryFixedDim,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: vm.isLoading 
              ? null 
              : () async {
                  final success = await vm.login(_emailController.text, _passwordController.text);
                  if (success && context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                    );
                  } else if (context.mounted && vm.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(vm.error!),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
            child: vm.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimaryContainer),
                )
              : const Text('ENTER THE KITCHEN'),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NEW PARTICIPANT?',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            OutlinedButton(
              onPressed: () => _showRegistrationSheet(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              ),
              child: Text(
                'CREATE ACCOUNT',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryContainer,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showRegistrationSheet(BuildContext context) {
    final regNameController = TextEditingController();
    final regIdController = TextEditingController();
    final regEmailController = TextEditingController();
    final regPhoneController = TextEditingController();
    final regPasswordController = TextEditingController();
    final regConfirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Consumer<AuthViewModel>(
          builder: (ctx, vm, _) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'JOIN THE LOOM',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContainer,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your Campus Eats account to join the Obsidian Loom ecosystem.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name Field
                    TextField(
                      controller: regNameController,
                      style: GoogleFonts.manrope(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'FULL NAME',
                        hintText: 'John Doe',
                        prefixIcon: Icon(Icons.person_outline, size: 20, color: Color(0x80FFE16D)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Student ID Field
                    TextField(
                      controller: regIdController,
                      style: GoogleFonts.manrope(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'STUDENT ID',
                        hintText: '20210001',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20, color: Color(0x80FFE16D)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 32),

                    // Email Field
                    TextField(
                      controller: regEmailController,
                      style: GoogleFonts.manrope(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'CAMPUS EMAIL',
                        hintText: 'student@vvu.edu.gh',
                        prefixIcon: Icon(Icons.alternate_email, size: 20, color: Color(0x80FFE16D)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextField(
                      controller: regPasswordController,
                      obscureText: true,
                      style: GoogleFonts.manrope(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'CREATE KEYPHRASE',
                        hintText: '••••••••••••',
                        prefixIcon: Icon(Icons.lock_outline, size: 20, color: Color(0x80FFE16D)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Phone Number Field
                    TextField(
                      controller: regPhoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.manrope(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'COMMAND PHONE',
                        hintText: '+233 ...',
                        prefixIcon: Icon(Icons.phone_android, size: 20, color: Color(0x80FFE16D)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    TextField(
                      controller: regConfirmController,
                      obscureText: true,
                      style: GoogleFonts.manrope(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'CONFIRM KEYPHRASE',
                        hintText: '••••••••••••',
                        prefixIcon: Icon(Icons.lock_reset, size: 20, color: Color(0x80FFE16D)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                                // Validation
                                if (regPasswordController.text != regConfirmController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Keyphrases do not match.'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                if (regPasswordController.text.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Keyphrase must be at least 6 characters.'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                final success = await vm.register(
                                  email: regEmailController.text.trim(),
                                  password: regPasswordController.text,
                                  displayName: regNameController.text.trim(),
                                  studentId: regIdController.text.trim(),
                                  phoneNumber: regPhoneController.text.trim(),
                                );

                                if (success && sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop(); // Close sheet
                                  if (context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                                    );
                                  }
                                } else if (sheetContext.mounted && vm.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(vm.error!),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                        child: vm.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              )
                            : const Text('CREATE ACCOUNT'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorSnackbar(BuildContext context, AuthViewModel vm) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                vm.error!,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () => vm.clearError(), // Assuming clearError exists
            ),
          ],
        ),
      ),
    );
  }
}

class HiddenOnMobile extends StatelessWidget {
  final Widget child;
  const HiddenOnMobile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) return const SizedBox.shrink();
    return child;
  }
}

class StatusOrb extends StatelessWidget {
  const StatusOrb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFD700),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

