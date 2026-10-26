import 'package:flutter/material.dart';

import '../models/skill.dart';

class SkillCard extends StatelessWidget {
  const SkillCard({
    required this.skill,
    this.action,
    super.key,
  });

  final Skill skill;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    skill.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Chip(label: Text(skill.category)),
              ],
            ),
            Text(skill.description),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    skill.ownerName.isEmpty
                        ? 'SkillSwap student'
                        : skill.ownerName,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
}
