import 'package:flutter/material.dart';

/*
 * Function used to display message on a SnackBar easly
 */
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

/*
 * Function used to get a text from how many time the date was
 */
String formatTimeAgo(DateTime date) {

  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';

  return '${date.year}-${date.month}-${date.day}';
}

/*
 * Functions used to know in wich type of screen we are
 */
bool isMobile(BuildContext context) {

  return MediaQuery.of(context).size.width < 600;
}
bool isTablet(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
}
bool isDesktop(BuildContext context) {

  return MediaQuery.of(context).size.width >= 1024;
}

/*
 * Used to store destination data
 */
class DestinationData {

  final IconData icon;
  final IconData selectedIcon;
  final String text;
  final String path;

  const DestinationData({
    required this.icon,
    required this.selectedIcon,
    required this.text,
    required this.path
  });
}
