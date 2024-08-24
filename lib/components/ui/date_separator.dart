
import 'package:flutter/material.dart';

/// A widget that displays a date separator between messages.
class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = _getDateText(date);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildSeparatorLine(context)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: _buildSeparatorLine(context)),
        ],
      ),
    );
  }

  /// Builds a separator line for the date separator.
  Widget _buildSeparatorLine(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      height: 2,
    );
  }

  /// Gets the appropriate text to display for the date separator.
  String _getDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Today";
    } else if (messageDate == yesterday) {
      return "Yesterday";
    } else if (now.difference(messageDate).inDays < 7) {
      return _getWeekdayName(date.weekday);
    } else {
      return date.toLocal().toIso8601String().substring(0, 10);
    }
  }

  /// Gets the name of the weekday for a given weekday number.
  String _getWeekdayName(int weekday) {
    const weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    return weekdays[weekday - 1];
  }
}