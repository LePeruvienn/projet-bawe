import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'l10n/app_localizations.dart';

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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dismissText,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {},
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
 * Used to store destination data
 */
class DestinationData {

  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const DestinationData({
    required this.icon,
    required this.selectedIcon,
    required this.path
  });
}


/*
 * Make the use of locationsation text easier !
 * - This add a `.loc` properties in all BuildContext objects
 */
extension LocalizationExt on BuildContext {

  AppLocalizations get loc => AppLocalizations.of(this)!;
}
