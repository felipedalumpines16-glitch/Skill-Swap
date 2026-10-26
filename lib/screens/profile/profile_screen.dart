import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../utils/error_messages.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.user, super.key});

  final AppUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profiles = ProfileService();
  final _auth = AuthService.instance;
  String? _error;

  Future<void> _editProfile(StudentProfile? profile) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(
      text: profile?.name ?? widget.user.displayName,
    );
    final course = TextEditingController(text: profile?.course ?? '');
    final bio = TextEditingController(text: profile?.bio ?? '');
    var saving = false;
    String? error;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit profile'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Name is required.'
                        : null,
                  ),
                  TextFormField(
                    controller: course,
                    maxLength: 100,
                    decoration:
                        const InputDecoration(labelText: 'Course / program'),
                  ),
                  TextFormField(
                    controller: bio,
                    maxLength: 500,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Biography'),
                  ),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        await _profiles.update(
                          uid: widget.user.uid,
                          email: widget.user.email,
                          name: name.text,
                          course: course.text,
                          bio: bio.text,
                        );
                        widget.user.displayName = name.text.trim();
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text('Profile saved.')),
                          );
                        }
                      } catch (exception) {
                        setDialogState(() {
                          saving = false;
                          error = userFacingError(exception);
                        });
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    course.dispose();
    bio.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _auth.signOut();
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<StudentProfile?>(
        stream: _profiles.watch(widget.user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(userFacingError(snapshot.error!)),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData &&
              snapshot.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          final name = profile?.name.isNotEmpty == true
              ? profile!.name
              : widget.user.displayName;
          final initials = name
              .trim()
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: const Color(0xFF087E8B),
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                widget.user.email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              if (profile == null)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Your profile details are not available.',
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: const Text('Course / program'),
                      subtitle: Text(
                        profile?.course.isNotEmpty == true
                            ? profile!.course
                            : 'Not added',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notes_outlined),
                      title: const Text('About me'),
                      subtitle: Text(
                        profile?.bio.isNotEmpty == true
                            ? profile!.bio
                            : 'Not added',
                      ),
                    ),
                    if (profile != null &&
                        profile.createdAt.millisecondsSinceEpoch > 0) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text('Member since'),
                        subtitle: Text(
                          '${profile.createdAt.year}-${profile.createdAt.month.toString().padLeft(2, '0')}-${profile.createdAt.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => _editProfile(profile),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit profile'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          );
        },
      ),
    );
  }
}
