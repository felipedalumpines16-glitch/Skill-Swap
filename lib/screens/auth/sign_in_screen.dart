import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/auth_validators.dart';
import '../../utils/error_messages.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService.instance;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_registering) {
        await _auth.register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
      } else {
        await _auth.signIn(email: _email.text, password: _password.text);
      }
    } catch (error) {
      _showError(userFacingError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (mounted) setState(() => _error = message);
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (AuthValidators.email(email) != null) {
      _showError('Enter a valid email address first.');
      return;
    }
    try {
      await _auth.sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      }
    } catch (error) {
      _showError(userFacingError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.swap_horiz_rounded,
                        size: 52, color: Color(0xFF087E8B)),
                    const SizedBox(height: 12),
                    Text(
                      _registering
                          ? 'Create your account'
                          : 'Welcome to SkillSwap',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _registering
                          ? 'Learn something. Share something.'
                          : 'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Offline demo: accounts and app data are temporary and '
                      'stay only in memory until the app closes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 28),
                    if (_registering) ...[
                      TextFormField(
                        controller: _name,
                        maxLength: 100,
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            const InputDecoration(labelText: 'Full name'),
                        validator: AuthValidators.name,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(labelText: 'Email address'),
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      validator: AuthValidators.password,
                    ),
                    if (_registering) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Confirm password'),
                        validator: (value) => AuthValidators.confirmPassword(
                          value,
                          _password.text,
                        ),
                      ),
                    ],
                    if (!_registering)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _loading ? null : _forgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_registering ? 'Create account' : 'Sign in'),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() {
                                _registering = !_registering;
                                _error = null;
                              }),
                      child: Text(_registering
                          ? 'Already have an account? Sign in'
                          : 'New to SkillSwap? Create an account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
