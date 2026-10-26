import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/skill.dart';
import '../../services/request_service.dart';
import '../../services/skill_service.dart';
import '../../utils/error_messages.dart';
import '../../widgets/dashboard_summary.dart';
import '../../widgets/skill_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({required this.user, super.key});

  final AppUser user;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _service = SkillService();
  final _requests = RequestService();
  final _search = TextEditingController();
  String _category = 'All';
  String? _error;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _requestSkill(Skill skill) async {
    final messageController = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request ${skill.title}'),
        content: TextField(
          controller: messageController,
          maxLength: 400,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Message (optional)',
            hintText: 'Introduce yourself or share what you hope to learn.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, messageController.text),
            child: const Text('Send request'),
          ),
        ],
      ),
    );
    messageController.dispose();
    if (message == null || !mounted) return;
    if (message.length > 400) {
      setState(() => _error = 'Message must be 400 characters or fewer.');
      return;
    }
    try {
      await _requests.create(
        skill: skill,
        requesterId: widget.user.uid,
        message: message,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent.')),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover skills')),
      body: Column(
        children: [
          DashboardSummary(uid: widget.user.uid),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search skills or students',
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () => setState(() => _search.clear()),
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    'All',
                    ...Skill.categories,
                  ]
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _category = value ?? 'All'),
                ),
              ],
            ),
          ),
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _error = null),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: StreamBuilder<List<Skill>>(
              stream: _service.watchDiscover(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _LoadError(
                    message: userFacingError(snapshot.error!),
                    onRetry: () => setState(() {}),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final query = _search.text.trim().toLowerCase();
                final skills = snapshot.data!
                    .where((skill) => skill.ownerId != widget.user.uid)
                    .where((skill) =>
                        _category == 'All' || skill.category == _category)
                    .where((skill) =>
                        query.isEmpty ||
                        skill.title.toLowerCase().contains(query) ||
                        skill.description.toLowerCase().contains(query) ||
                        skill.ownerName.toLowerCase().contains(query))
                    .toList();
                if (skills.isEmpty) {
                  return EmptyState(
                    message: snapshot.data!.isEmpty
                        ? 'No skills have been shared yet.'
                        : 'No skills match your search. Clear filters to see all skills.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: skills.length,
                  itemBuilder: (context, index) => SkillCard(
                    skill: skills[index],
                    action: TextButton(
                      onPressed: () => _requestSkill(skills[index]),
                      child: const Text('Request'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}
