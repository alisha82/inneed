import 'package:flutter/material.dart';
import 'package:inneed/views/alert_Popup/all_notifications.dart';
import 'package:inneed/views/alert_Popup/sos_alert.dart';
import 'package:inneed/views/tabs/emergency/emergency_tab.dart';
import 'package:inneed/views/tabs/firstaid_tab/firstaid_tab.dart';
import 'package:inneed/views/tabs/hospital_tab/hospital_tab.dart';
import 'package:inneed/views/tabs/inneed_tab/inneed_tab.dart';
import 'package:inneed/views/widgets/custom_drawer.dart';
import 'package:marquee/marquee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // tabs index

  @override
  void initState() {
    super.initState();
    setupFCMNotifications();
    listenForSosAlerts();
  }

  void setupFCMNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    //foregroud notifications
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Ask user notification permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else {
      print('User declined or accepted provisional permission');
    }
    //get device fcm token( for targeted notifications)
    String? token = await messaging.getToken();
    print("FCM Registration Token: $token");

    //if user is logged in, update his token in firestore
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null && token != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).set({
        'fcmToken': token,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    //handling foreground msg
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');
      // Agar notification aati hai toh popup Firestore listener khud handle kar lega agar app open hai.
      //if notification is received, firestore listener will handle popup itself if app is open
    });

    // Handle notification click in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background via notification: ${message.messageId}');
    });
  }

  void listenForSosAlerts() {
    final DateTime appOpenTime = DateTime.now();

    FirebaseFirestore.instance
        .collection('sos_alerts')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var data = change.doc.data() as Map<String, dynamic>;
          String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

          Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;
          if (createdAtTimestamp != null) {
            DateTime alertTime = createdAtTimestamp.toDate();

            if (alertTime.isBefore(appOpenTime.subtract(const Duration(seconds: 5)))) {
              continue;
            }
          }

          if (data['senderId'] != currentUserId) {
            double alertLat = (data['latitude'] as num?)?.toDouble() ?? 0.0;
            double alertLng = (data['longitude'] as num?)?.toDouble() ?? 0.0;

            double distanceInKm = 0.0;

            try {
              Position userPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.medium,
              );

              double distanceInMeters = Geolocator.distanceBetween(
                userPosition.latitude,
                userPosition.longitude,
                alertLat,
                alertLng,
              );

              distanceInKm = distanceInMeters / 1000;
            } catch (e) {
              distanceInKm = 0.0;
            }

            // Setting 5km radius check for foreground popup
            if (distanceInKm <= 5.0 && mounted) {
              showSosAlertPopup(
                context: context,
                emergencyType: data['emergencyType'] ?? 'Emergency',
                senderName: data['senderName'] ?? 'Unknown',
                senderPhone: data['senderPhone'] ?? 'N/A',
                distance: distanceInKm,
                latitude: alertLat,
                longitude: alertLng,
              );
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                      builder: (innerContext) {
                        return IconButton(
                          onPressed: () {
                            Scaffold.of(innerContext).openDrawer();
                          },
                          icon: const Icon(Icons.menu),
                        );
                      }),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/app_logo.png',
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'IN NEED',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0XFFE50914),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      size: 28,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Emergency Healthcare Services - Quick access\nto help when you need it',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2962FF),
                      Color(0xFF8E24AA),
                      Color(0xFFD32F2F),
                    ],
                  ),
                ),
                child: Marquee(
                  text:
                  '🫀 CPR Tip: Push hard and fast - 100-120 compressions per minute  •  🔥 Burns: Run cool water for 10-20 minutes, never use ice  •  🫁 Choking: 5 back blows, 5 abdominal thrusts - repeat until clear  •  🩸 Bleeding: Apply direct pressure, dont remove first cloth  •  🧠 Stroke (FAST): Face drooping, Arm weakness, Speech difficulty - Time to call 1122  •  💉 Allergic Reaction: Use EpiPen immediately if breathing difficulty occurs  •  🐍 Snake Bite: Keep calm, immobilize limb, seek immediate medical help  •  ❤️ Heart Attack: Chew 325mg aspirin, call 1122 immediately  •  🦴 Fracture: Immobilize injured area, don\'t try to realign bone  •  🥶 Hypothermia: Remove wet clothing, warm gradually with blankets  •  ',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  blankSpace: 0.0,
                  velocity: 48.0,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 16.0,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TabBar(
                              overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                              splashFactory: NoSplash.splashFactory,
                              enableFeedback: false,
                              tabAlignment: TabAlignment.start,
                              isScrollable: true,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey.shade600,
                              indicatorColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              padding: const EdgeInsets.all(4),
                              tabs: const [
                                Tab(
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 18),
                                      SizedBox(width: 6),
                                      Text('Emergency'),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    children: [
                                      Icon(Icons.wifi_tethering, size: 18),
                                      SizedBox(width: 6),
                                      Text('In Need'),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    children: [
                                      Icon(Icons.chat_bubble, size: 18),
                                      SizedBox(width: 6),
                                      Text('First Aid'),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    children: [
                                      Icon(Icons.local_hospital, size: 18),
                                      SizedBox(width: 6),
                                      Text('Hospital'),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            EmergencyTab(),
                            inNeedTab(),
                            FirstAidTab(),
                            HospitalTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}