import 'package:flutter/material.dart';

void showSnackbar({
  required BuildContext context,
  required String dismissText,
  required Color backgroundColor,
  required Icon icon
}) {
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          icon,
          const SizedBox(width: 8), // Add some spacing
          Expanded(
            child: Text(dismissText),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 2), // Duration for the Snackbar
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () { /*Optionally, handle dismiss action*/ },
      ),
    )
  );
}

String formatTimeAgo(DateTime date) {

  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';

  return '${date.year}-${date.month}-${date.day}';
}


class NavigationDestinationWithPath extends NavigationDestination {

  final String path;

  const NavigationDestinationWithPath({
    required Icon selectedIcon,
    required Icon icon,
    required String label,
    required this.path,
  }) : super(selectedIcon: selectedIcon, icon: icon, label: label);
}
