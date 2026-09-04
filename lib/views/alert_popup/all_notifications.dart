import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inneed/Constant/color.dart';
import 'package:inneed/views/widgets/custom_snackbar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Clear Notifications Confirmation Dialog
  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Clear Notifications',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            'Are you sure you want to clear the notification history?',
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Clear Button with Firestore Deletion Logic
            ElevatedButton(
              onPressed: () async {
                try {
                  var snapshots = await FirebaseFirestore.instance.collection('sos_alerts').get();
                  for (var doc in snapshots.docs) {
                    await doc.reference.delete();
                  }

                  if (!context.mounted) return;
                  Navigator.of(context).pop();

                  AppSnackbar.show(
                    context,
                    message: 'Notification history cleared successfully',
                    isSuccess: true,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();

                  AppSnackbar.show(
                    context,
                    message: 'Failed to clear notifications: $e',
                    isSuccess: false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Emergency Alerts History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Basket / Delete Icon in AppBar
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              _showClearConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sos_alerts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var alerts = snapshot.data!.docs;

          if (alerts.isEmpty) {
            return const Center(child: Text("No alerts found."));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              var alert = alerts[index].data() as Map<String, dynamic>;
              return ListTile(
                leading:
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                title: Text(alert['emergencyType'] ?? 'Unknown Emergency'),
                subtitle: Text("By: ${alert['senderName'] ?? 'Anonymous'}"),
                trailing: Text(
                  (alert['createdAt'] as Timestamp?)
                      ?.toDate()
                      .toString()
                      .substring(11, 16) ??
                      '',
                ),
              );
            },
          );
        },
      ),
    );
  }
}