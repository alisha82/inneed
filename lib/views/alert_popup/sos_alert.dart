import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SosAlert extends StatelessWidget {
  final String emergencyType;
  final String senderName;
  final String senderPhone;
  final double distance;
  final double latitude;
  final double longitude;

  const SosAlert({
    super.key,
    required this.emergencyType,
    required this.senderName,
    required this.senderPhone,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: const Color(0xFFFDF3F1), // Soft Peach/Pink tint
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Dialog fit-content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFE64A19),
                  size: 26,
                ),
                SizedBox(width: 8),
                Text(
                  "NEARBY SOS ALERT!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Emergency Type
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_outlined,
                  color: Color(0xFFD84315),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  "Emergency: $emergencyType",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD84315),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sender Details
            Text(
              "From: $senderName",
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
            ),
            Text(
              "Phone: $senderPhone",
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
            ),
            Text(
              "Distance: ${distance.toStringAsFixed(1)} km away",
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
            ),

            const SizedBox(height: 14),

            // Warning Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7), // Soft Yellow Tint
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFB74D), // Light Orange Border
                  width: 1.2,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFFE65100),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "SAFETY WARNING",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    "To avoid scams, always inform the officials (15/1122) before going.",
                    style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.3),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Note for female users: It is highly recommended to send official help instead of visiting alone.",
                    style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Dismiss Link
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 6, bottom: 8),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        color: Color(0xFFC62828),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Call Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final Uri telUrl = Uri.parse('tel:$senderPhone');
                      if (await canLaunchUrl(telUrl)) {
                        await launchUrl(telUrl);
                      }
                    },
                    icon: const Icon(Icons.call, size: 16, color: Colors.white),
                    label: const Text(
                      "Call",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Green Accent
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Directions Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final Uri mapUrl = Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
                      );
                      if (await canLaunchUrl(mapUrl)) {
                        await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.directions, size: 16, color: Colors.white),
                    label: const Text(
                      "Directions",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3), // Blue Accent
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Global Helper Function
void showSosAlertPopup({
  required BuildContext context,
  required String emergencyType,
  required String senderName,
  required String senderPhone,
  required double distance,
  required double latitude,
  required double longitude,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SosAlert( // Fix: Class name SosAlert matched
        emergencyType: emergencyType,
        senderName: senderName,
        senderPhone: senderPhone,
        distance: distance,
        latitude: latitude,
        longitude: longitude,
      );
    },
  );
}