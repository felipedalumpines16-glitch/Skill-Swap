import 'package:flutter/material.dart';

import '../models/skill.dart';
import '../models/skill_request.dart';
import '../services/request_service.dart';
import '../services/skill_service.dart';

class DashboardSummary extends StatefulWidget {
  const DashboardSummary({required this.uid, super.key});

  final String uid;

  @override
  State<DashboardSummary> createState() => _DashboardSummaryState();
}

class _DashboardSummaryState extends State<DashboardSummary> {
  late final Stream<List<Skill>> _skills;
  late final Stream<List<SkillRequest>> _incoming;
  late final Stream<List<SkillRequest>> _sent;

  @override
  void initState() {
    super.initState();
    _skills = SkillService().watchMine(widget.uid);
    _incoming = RequestService().watchIncoming(widget.uid);
    _sent = RequestService().watchSent(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Skill>>(
      stream: _skills,
      builder: (context, skillSnapshot) => StreamBuilder<List<SkillRequest>>(
        stream: _incoming,
        builder: (context, incomingSnapshot) =>
            StreamBuilder<List<SkillRequest>>(
          stream: _sent,
          builder: (context, sentSnapshot) {
            if (skillSnapshot.hasError ||
                incomingSnapshot.hasError ||
                sentSnapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Summary unavailable. Check your connection and Firestore permissions.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              );
            }
            if (!skillSnapshot.hasData ||
                !incomingSnapshot.hasData ||
                !sentSnapshot.hasData) {
              return const SizedBox.shrink();
            }
            final activeSkills =
                skillSnapshot.data!.where((skill) => skill.active).length;
            final incoming = incomingSnapshot.data!
                .where((request) => request.status == 'pending')
                .length;
            final outgoing = sentSnapshot.data!
                .where((request) => request.status == 'pending')
                .length;
            final completed = sentSnapshot.data!
                .where((request) => request.status == 'completed')
                .length;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    alignment: WrapAlignment.spaceAround,
                    runSpacing: 12,
                    children: [
                      _Statistic(label: 'Active skills', value: activeSkills),
                      _Statistic(label: 'Incoming', value: incoming),
                      _Statistic(label: 'Sent pending', value: outgoing),
                      _Statistic(label: 'Completed', value: completed),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Statistic extends StatelessWidget {
  const _Statistic({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      child: Column(
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF087E8B),
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
