import 'package:flutter/material.dart';

SnackBar createSnackbar({
  required String dismissText,
  required Color backgroundColor,
  required Icon icon,
}) {
  return SnackBar(
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
  );
}
