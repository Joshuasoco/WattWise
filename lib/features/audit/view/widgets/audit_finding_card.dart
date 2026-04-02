import 'package:flutter/material.dart';

import '../../models/audit_finding.dart';

class AuditFindingCard extends StatelessWidget {
  const AuditFindingCard({super.key, required this.findings});

  final List<AuditFinding> findings;

  @override
  Widget build(BuildContext context) {
    if (findings.isEmpty) {
      return const Text('No findings for the current profile.');
    }

    return Column(
      children: [
        for (final finding in findings)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(finding.title),
            subtitle: Text(finding.description),
            trailing: Chip(
              label: Text('${finding.severity}/${finding.confidence}'),
            ),
          ),
      ],
    );
  }
}
