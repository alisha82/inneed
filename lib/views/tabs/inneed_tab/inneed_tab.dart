import 'package:flutter/material.dart';
import 'package:inneed/models/emergency_type_model.dart';
import 'package:inneed/views/auth/signup_screen.dart';
import 'package:inneed/views/widgets/custom_snackbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class inNeedTab extends StatefulWidget {
  const inNeedTab({super.key});

  @override
  State<inNeedTab> createState() => _inNeedtabstate();
}

// AutomaticKeepAliveClientMixin to preserve state across tab switches
class _inNeedtabstate extends State<inNeedTab> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true; // it wont reset state when we switch tab

  late EmergencyItem selectedEmergency;
  final List<EmergencyItem> emergencyTypes = [
    EmergencyItem(
      title: "Road Accident",
      icon: Icons.car_crash_rounded,
      color: Colors.orange.shade700,
    ),
    EmergencyItem(
      title: "Heart Attack / Cardiac",
      icon: Icons.favorite_rounded,
      color: Colors.red.shade600,
    ),
    EmergencyItem(
      title: "Severe Bleeding",
      icon: Icons.water_drop_rounded,
      color: Colors.red.shade800,
    ),
    EmergencyItem(
      title: "Fire Emergency",
      icon: Icons.local_fire_department_rounded,
      color: Colors.deepOrange,
    ),
    EmergencyItem(
      title: "Other Medical Need",
      icon: Icons.medical_services_rounded,
      color: Colors.blue.shade600,
    ),
  ];

  // Location & Map states
  bool isLocationEnabled = false;
  LatLng? currentLatLng;
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    selectedEmergency = emergencyTypes[0];
  }

  // fetching location permission with Custom Snackbar
  Future<void> _fetchAndEnableLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Location services are disabled. Please turn on GPS.',
          isSuccess: false,
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          AppSnackbar.show(
            context,
            message: 'Location permissions are denied',
            isSuccess: false,
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Location permissions are permanently denied.',
          isSuccess: false,
        );
      }
      return;
    }

    // Show loading while fetching position
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        currentLatLng = LatLng(position.latitude, position.longitude);
        isLocationEnabled = true;
        markers = {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLatLng!,
            infoWindow: const InfoWindow(title: 'Your Current Location'),
          ),
        };
      });

      if (mapController != null && currentLatLng != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentLatLng!, zoom: 15.0),
          ),
        );
      }

      if (mounted) Navigator.pop(context); // Close loading
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        AppSnackbar.show(
          context,
          message: "Failed to get location: $e",
          isSuccess: false,
        );
      }
    }
  }

  Future<void> sendSosAlert() async {
    // Check if location is available
    if (currentLatLng == null) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: "Please enable location access first!",
          isSuccess: false,
        );
      }
      return;
    }

    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Default fallback values
      String senderName = user?.displayName ?? 'Anonymous User';
      String senderPhone = user?.phoneNumber ?? '';

      // fetching real users from firebase with flexible field checks
      if (user != null) {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists && userDoc.data() != null) {
            Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
            senderName = data['name'] ?? data['fullName'] ?? data['userName'] ?? senderName;
            senderPhone = data['phone'] ?? data['phoneNumber'] ?? data['mobile'] ?? data['userPhone'] ?? senderPhone;
          } else {
            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection('users')
                .where('uid', isEqualTo: user.uid)
                .limit(1)
                .get();

            if (querySnapshot.docs.isNotEmpty) {
              var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
              senderName = data['name'] ?? data['fullName'] ?? data['userName'] ?? senderName;
              senderPhone = data['phone'] ?? data['phoneNumber'] ?? data['mobile'] ?? data['userPhone'] ?? senderPhone;
            }
          }
        } catch (err) {
          print("Error fetching user profile data: $err");
        }
      }
      //fallback if phone number is not available in firestore
      if (senderPhone.isEmpty) {
        senderPhone = 'Not Provided';
      }

      // send data to firestore within 8 sec then time out
      await FirebaseFirestore.instance.collection('sos_alerts').add({
        'senderId': user?.uid ?? '',
        'senderName': senderName,
        'senderPhone': senderPhone,
        'emergencyType': selectedEmergency.title,
        'latitude': currentLatLng!.latitude,
        'longitude': currentLatLng!.longitude,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      }).timeout(const Duration(seconds: 8));

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Success Message
      if (mounted) {
        AppSnackbar.show(
          context,
          message: "Alert sent successfully!",
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (mounted) {
        AppSnackbar.show(
          context,
          message: "Failed to send alert: $e",
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return _buildMainContent();
  }

  // Extracted helper method for Main UI to keep build clean
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Location & Map Card Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Color(0xFF1976D2), size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Your Current Location",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isLocationEnabled
                      ? "Your exact location is ready to be shared with nearby app users."
                      : "Your location will be shared with nearby app users when you send an SOS alert.",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                ),
                const SizedBox(height: 14),

                // map show if location is enable
                if (isLocationEnabled && currentLatLng != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: currentLatLng!,
                          zoom: 15.0,
                        ),
                        markers: markers,
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // enable location btn
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      User? currentUser = FirebaseAuth.instance.currentUser;

                      if (currentUser == null) {
                        AppSnackbar.show(
                          context,
                          message: "Please sign up first to use emergency features!",
                          isSuccess: false,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                        return;
                      }
                      //if user is already login
                      await _fetchAndEnableLocation();
                    },
                    icon: Icon(
                      isLocationEnabled ? Icons.refresh : Icons.location_pin,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      isLocationEnabled ? "Update Location" : "Enable Location Access",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B2A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Emergency Alert section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Emergency In Need Alert",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Send instant alert to nearby IN NEED app users for immediate assistance.",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Emergency Type",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<EmergencyItem>(
                      value: selectedEmergency,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                      items: emergencyTypes.map((EmergencyItem item) {
                        return DropdownMenuItem<EmergencyItem>(
                          value: item,
                          child: Row(
                            children: [
                              Icon(item.icon, color: item.color, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                item.title,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (EmergencyItem? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedEmergency = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDE7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFF59D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_outlined, size: 18, color: Color(0xFFF57F17)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "This will broadcast your exact location and emergency type to all nearby users with the IN NEED app.",
                          style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.3),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      sendSosAlert();
                    },
                    icon: const Icon(Icons.wifi_tethering, color: Colors.white, size: 18),
                    label: const Text(
                      "SEND IN NEED ALERT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "How Emergency Alerts Work",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStepItem(stepNumber: "1", title: "Enable location access to share your exact position"),
                _buildStepItem(stepNumber: "2", title: "Select the type of emergency you're experiencing"),
                _buildStepItem(stepNumber: "3", title: "Press \"Send SOS Alert\" to broadcast to all nearby app users"),
                _buildStepItem(stepNumber: "4", title: "Nearby users receive instant notification with your location"),
                _buildStepItem(stepNumber: "5", title: "Track who acknowledged and who's coming to help"),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

Widget _buildStepItem({required String stepNumber, required String title}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFFBBDEFB),
          child: Text(
            stepNumber,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
          ),
        ),
      ],
    ),
  );
}