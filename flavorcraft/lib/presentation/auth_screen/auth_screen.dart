import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final app = AppController.instance;

    try {
      if (_isRegisterMode) {
        await app.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await app.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }

      final data = error.response?.data;
      String message = app.text('auth.error.generic');
      if (data is Map<String, dynamic>) {
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          }
        } else if (data['message'] != null) {
          message = data['message'].toString();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppController.instance;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: app,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen,
                                  Color(0xFF2DB87A),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.lock_open_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 2.5.h),
                          Text(
                            _isRegisterMode
                                ? app.text('auth.createAccount')
                                : app.text('auth.welcomeBack'),
                            style: GoogleFonts.dmSans(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 0.8.h),
                          Text(
                            _isRegisterMode
                                ? app.text('auth.subtitleRegister')
                                : app.text('auth.subtitleLogin'),
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          if (_isRegisterMode) ...[
                            _buildTextField(
                              controller: _nameController,
                              label: app.text('auth.name'),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return app.text('auth.validation.name');
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 1.8.h),
                          ],
                          _buildTextField(
                            controller: _emailController,
                            label: app.text('auth.email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return app.text('auth.validation.email');
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 1.8.h),
                          _buildTextField(
                            controller: _passwordController,
                            label: app.text('auth.password'),
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').isEmpty) {
                                return app.text('auth.validation.password');
                              }
                              if ((value ?? '').length < 8) {
                                return app.text(
                                  'auth.validation.passwordLength',
                                );
                              }
                              return null;
                            },
                          ),
                          if (_isRegisterMode) ...[
                            SizedBox(height: 1.8.h),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: app.text('auth.confirmPassword'),
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return app.text(
                                    'auth.validation.passwordMatch',
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                          SizedBox(height: 3.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: app.isAuthenticating ? null : _submit,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: app.isAuthenticating
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _isRegisterMode
                                            ? app.text('auth.register')
                                            : app.text('auth.login'),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 1.8.h),
                          Center(
                            child: TextButton(
                              onPressed: app.isAuthenticating
                                  ? null
                                  : () {
                                      setState(() {
                                        _isRegisterMode = !_isRegisterMode;
                                      });
                                    },
                              child: Text(
                                _isRegisterMode
                                    ? app.text('auth.switchToLogin')
                                    : app.text('auth.switchToRegister'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
