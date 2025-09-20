import 'package:url_launcher/url_launcher.dart';

class Tool {
  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);

    if(!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      throw Exception("Could not launch $url");
    }
  }

  String formatDuration(int minutes) {
    final hours = minutes ~/ 60;   // integer division
    final mins = minutes % 60;     // remainder
    if (hours > 0 && mins > 0) {
      return "$hours hours $mins min";
    } else if (hours > 0) {
      return "$hours hours";
    } else {
      return "$mins minutes";
    }
  }
}