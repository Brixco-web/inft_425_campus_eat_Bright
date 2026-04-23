import 'package:intl/intl.dart';

class TimeUtils {
  /// Returns a contextual greeting based on the current hour.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  /// Returns a subtle emoji matching the time of day.
  static String getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '🌅';
    if (hour >= 12 && hour < 17) return '☀️';
    if (hour >= 17 && hour < 21) return '🌆';
    return '🌙';
  }

  /// Returns total greeting block like "Good Evening 👋"
  static String getFullGreeting() {
    return '${getGreeting()} ${getGreetingEmoji()}';
  }

  /// Returns formatted date for headers, e.g., "Monday, Oct 24"
  static String getFormattedDate() {
    return DateFormat('EEEE, MMM d').format(DateTime.now());
  }
}
