import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../main_shell.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _auth.authChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Unable to load the local demo session.')),
          );
        }
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.active) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        return user == null ? const SignInScreen() : MainShell(user: user);
      },
    );
  }
}
