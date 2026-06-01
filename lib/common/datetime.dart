import 'package:fl_croc/l10n/l10n.dart';

extension DateTimeExt on DateTime {
  bool get isBeforeNow => isBefore(DateTime.now());

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }

  String timeAgoL10n(AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return l10n.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}${l10n.minAgo}';
    if (diff.inHours < 24) return '${diff.inHours}${l10n.hoursAgo}';
    if (diff.inDays < 30) return '${diff.inDays}${l10n.daysAgo}';
    return '${(diff.inDays / 30).floor()}${l10n.monthsAgo}';
  }
}
