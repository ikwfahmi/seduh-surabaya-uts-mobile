import 'package:flutter/material.dart';

import '../theme.dart';

class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.actionLabel = 'Coba lagi',
  });
  final IconData icon;
  final String title, message, actionLabel;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: SeduhColors.pale,
          child: Icon(icon, size: 30, color: SeduhColors.coffee),
        ),
        const SizedBox(height: 20),
        Text(title, style: editorial(28), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: SeduhColors.muted, height: 1.6),
          ),
        ),
        if (action != null) ...[
          const SizedBox(height: 22),
          FilledButton(onPressed: action, child: Text(actionLabel)),
        ],
      ],
    ),
  );
}

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(48),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(strokeWidth: 2),
        SizedBox(height: 20),
        Text(
          'Sedang menyeduh daftar kafe…',
          style: TextStyle(color: SeduhColors.muted),
        ),
      ],
    ),
  );
}
