import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';
import 'routes.dart';

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
      duration: const Duration(seconds: 1),
      /*
      action: SnackBarAction(
        label: context.loc.dismiss,
        textColor: Colors.white,
        onPressed: () {},
      )
      */
    )
  );
}

/*
 * Function used to get a text from how many time the date was
 */
String formatTimeAgo(DateTime date) {

  // Force compare dates as they are UTCs (even if we force it before i want to be sure)
  final nowUtc = DateTime.now().toUtc();
  final dateUtc = date.toUtc();

  // Compute diff
  final diff = nowUtc.difference(dateUtc);

  // Show message depending of time diff
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';

  // ensure that we show value as local
  final localDate = date.toLocal();

  // Return date in string if diff is too big
  return '${localDate.year}-${localDate.month}-${localDate.day}';
}

/*
 * Widget used to display errors messages !
 */
class ErrorText extends StatelessWidget {

  final String header;
  final String message;
  final Color color;
  final bool haveButton;

  ErrorText ({
    super.key,
    this.header = 'Oops!',
    this.message = 'The page you requested could not be found.',
    this.color = Colors.redAccent,
    this.haveButton = false
  });

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            header,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          // Only if button is active
          if (haveButton)
            const SizedBox(height: 32),
          if (haveButton)
            ElevatedButton.icon(
              onPressed: () => context.go(HOME_PATH),
              icon: const Icon(Icons.home),
              label: const Text('Home'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/*
 * Make the use of locationsation text easier !
 * - This add a `.loc` properties in all BuildContext objects
 */
extension LocalizationExt on BuildContext {

  AppLocalizations get loc => AppLocalizations.of(this)!;
}
