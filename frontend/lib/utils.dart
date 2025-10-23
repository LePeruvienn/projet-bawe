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
