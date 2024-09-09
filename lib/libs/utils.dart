import 'package:intl/intl.dart';

class Utils {
  Future<String> getTimeDiff(String time) async {
    DateTime currentTime = DateTime.now();
    DateTime startTime = DateTime.parse(time);
    Duration difference = currentTime.difference(startTime);

    if (difference.inDays > 0) {
      if (difference.inDays <= 7) {
        return '${difference.inDays}d ago';
      } else {
        if (startTime.year < currentTime.year) {
          DateFormat formatter = DateFormat('dd MMM yyyy');
          return formatter.format(startTime);
        } else {
          DateFormat formatter = DateFormat('dd MMM');
          return formatter.format(startTime);
        }
      }
    } else {
      if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        if (difference.inMinutes > 2) {
          return '${difference.inHours}min ago';
        } else {
          return 'just now';
        }
      }
    }
  }


  Future<String> getCommentTimeDiff(String time) async {
    DateTime currentTime = DateTime.now();
    DateTime startTime = DateTime.parse(time);
    Duration difference = currentTime.difference(startTime);

    if (difference.inDays > 0) {
      if (difference.inDays <= 7) {
        return '${difference.inDays}d';
      } else {
        if (startTime.year < currentTime.year) {
          DateFormat formatter = DateFormat('dd MMM yyyy');
          return formatter.format(startTime);
        } else {
          DateFormat formatter = DateFormat('dd MMM');
          return formatter.format(startTime);
        }
      }
    } else {
      if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else {
        if (difference.inMinutes > 2) {
          return '${difference.inHours}min';
        } else {
          return 'just now';
        }
      }
    }
  }
}