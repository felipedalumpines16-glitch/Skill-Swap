import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/skill.dart';
import '../../services/skill_service.dart';
import '../../utils/error_messages.dart';
import '../../widgets/skill_card.dart';

class MySkillsScreen extends StatefulWidget {
  const MySkillsScreen({required this.user, super.key});

  final AppUser user;

  @override
  State<MySkillsScreen> createState() => _MySkillsScreenState();
}

class _MySkillsScreenState extends State<MySkillsScreen> {
  final _service = SkillService();

  Future<void> _editSkill([Skill? skill]) async {
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController(text: skill?.title ?? '');
    final description = TextEditingController(text: skill?.description ?? '');
    var category = skill?.category ?? Skill.categories.first;
    var loading = false;
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(skill == null ? 'Share a skill' : 'Edit skill'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: title,
                    maxLength: 60,
                    decoration: const InputDecoration(labelText: 'Skill title'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a title.'
                        : null,
                  ),
                  TextFormField(
                    controller: description,
                    maxLength: 400,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Describe what you can teach.'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: Skill.categories
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => category = value);
                    },
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() {
                        loading = true;
                        error = null;
                      });
                      try {
                        await _service.save(
                          id: skill?.id,
                          title: title.text,
                          description: description.text,
                          category: category,
                          ownerId: widget.user.uid,
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (exception) {
                        setDialogState(() {
                          loading = false;
                          error = userFacingError(exception);
                        });
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(skill == null ? 'Share' : 'Save'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    description.dispose();
  }

  Future<void> _deleteSkill(Skill skill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this skill?'),
        content: Text(
          'Pending requests for “${skill.title}” will be declined. '
          'Accepted exchanges will remain in your request history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.delete(skill.id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(error))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My skills')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _editSkill,
        icon: const Icon(Icons.add),
        label: const Text('Share a skill'),
      ),
      body: StreamBuilder<List<Skill>>(
        stream: _service.watchMine(widget.user.uid),
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const EmptyState(
              message:
                  'You have not shared any skills yet. Add one to get started.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final skill = snapshot.data![index];
              return SkillCard(
                skill: skill,
                action: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') _editSkill(skill);
                    if (value == 'delete') _deleteSkill(skill);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
