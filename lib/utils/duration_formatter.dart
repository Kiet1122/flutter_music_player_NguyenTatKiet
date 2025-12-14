import 'dart:math';

class DurationFormatter {
  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final hoursString = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    final minutesString = minutes.toString().padLeft(2, '0');
    final secondsString = seconds.toString().padLeft(2, '0');

    return '$hoursString$minutesString:$secondsString';
  }

  static String formatCompact(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes.remainder(60)).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
    }
  }

  static String formatHumanReadable(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds > 1 ? 's' : ''}';
    }
  }

  static Duration parse(String timeString) {
    try {
      final parts = timeString.split(':');
      
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return Duration(hours: hours, minutes: minutes, seconds: seconds);
      } else if (parts.length == 2) {
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return Duration(minutes: minutes, seconds: seconds);
      } else if (parts.length == 1) {
        final seconds = int.parse(parts[0]);
        return Duration(seconds: seconds);
      } else {
        throw FormatException('Invalid time format: $timeString');
      }
    } catch (e) {
      throw FormatException('Failed to parse duration: $timeString', e);
    }
  }

  static Duration fromMilliseconds(int milliseconds) {
    return Duration(milliseconds: milliseconds);
  }

  static Duration fromSeconds(int seconds) {
    return Duration(seconds: seconds);
  }

  static Duration fromMinutes(int minutes) {
    return Duration(minutes: minutes);
  }

  static Duration remaining(Duration total, Duration current) {
    return total - current;
  }

  static double percentage(Duration total, Duration current) {
    if (total.inMilliseconds == 0) return 0.0;
    return (current.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  static String formatForProgressBar(Duration position, Duration duration) {
    return '${format(position)} / ${format(duration)}';
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024)).floor();
    
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  static String getLengthCategory(Duration duration) {
    if (duration.inMinutes < 3) {
      return 'Short';
    } else if (duration.inMinutes < 6) {
      return 'Medium';
    } else if (duration.inMinutes < 10) {
      return 'Long';
    } else {
      return 'Very Long';
    }
  }
}