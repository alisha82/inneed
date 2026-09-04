import 'package:flutter/material.dart';
import 'package:inneed/Constant/color.dart';
import 'package:inneed/Providers/Emergency_Contact_Provider/emergency_provider.dart';
import 'package:provider/provider.dart';

class EmergencyContactCard extends StatelessWidget {
  final String title, description;
  final int number;
  final VoidCallback onCallPressed;
  final IconData icon;
  final Color iconColor;

  const EmergencyContactCard({
    super.key,
    required this.title,
    required this.number,
    required this.description,
    required this.onCallPressed,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final String numberStr = number.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    number.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Consumer<EmergencyProvider>(
            builder: (context, provider, child) {
              final isCallingThis = provider.callingNumber == numberStr;
              return ElevatedButton.icon(
                onPressed: isCallingThis
                    ? null
                    : () {
                  onCallPressed();
                },
                icon: const Icon(
                  Icons.phone,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Call',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}