import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class EmergencyProvider with ChangeNotifier {
  String? _callingNumber; // which number is getting dial

  String? get callingNumber => _callingNumber;

  // Phone Dialer Call Karne Ka Method
  Future<void> makePhoneCall(String phoneNumber) async {
    _callingNumber = phoneNumber;
    notifyListeners();
    // Sirf state listen karne wale button ko update karega

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint("Dialer could not be launched for $phoneNumber");
      }
    } catch (e) {
      debugPrint("Error launching dialer: $e");
    } finally {
      _callingNumber = null;
      notifyListeners(); // Reset calling state after launching
    }
  }
}