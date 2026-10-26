import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/skill_request.dart';
import '../../services/request_service.dart';
import '../../utils/error_messages.dart';
import '../../widgets/skill_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({required this.user, super.key});

  final AppUser user;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _service = RequestService();
  int _selected = 0;
  String? _error;

  Future<void> _changeStatus(SkillRequest request, String status) async {
    try {
      await _service.transition(request, status, userId: widget.user.uid);
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncoming = _selected == 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Incoming')),
                ButtonSegment(value: 1, label: Text('Sent')),
              ],
              selected: {_selected},
              onSelectionChanged: (selection) =>
                  setState(() => _selected = selection.first),
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
            child: StreamBuilder<List<SkillRequest>>(
              stream: isIncoming
                  ? _service.watchIncoming(widget.user.uid)
                  : _service.watchSent(widget.user.uid),
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
                  return EmptyState(
                    message: isIncoming
                        ? 'Requests from other students will appear here.'
                        : 'The skill requests you send will appear here.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final request = snapshot.data![index];
                    final otherStudent =
                        isIncoming ? request.requesterName : request.ownerName;
                    final actions = <Widget>[];
                    if (isIncoming && request.status == 'pending') {
                      actions.addAll([
                        TextButton(
                          onPressed: () => _changeStatus(request, 'declined'),
                          child: const Text('Decline'),
                        ),
                        FilledButton(
                          onPressed: () => _changeStatus(request, 'accepted'),
                          child: const Text('Accept'),
                        ),
                      ]);
                    } else if (!isIncoming && request.status == 'pending') {
                      actions.add(
                        TextButton(
                          onPressed: () => _changeStatus(request, 'cancelled'),
                          child: const Text('Cancel request'),
                        ),
                      );
                    } else if (!isIncoming && request.status == 'accepted') {
                      actions.add(
                        FilledButton(
                          onPressed: () => _changeStatus(request, 'completed'),
                          child: const Text('Mark completed'),
                        ),
                      );
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.skillTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                '${isIncoming ? 'From' : 'With'} $otherStudent'),
                            if (request.message.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(request.message),
                            ],
                            const SizedBox(height: 8),
                            Chip(label: Text(_statusLabel(request.status))),
                            if (actions.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children: actions,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String status) =>
    status[0].toUpperCase() + status.substring(1);
