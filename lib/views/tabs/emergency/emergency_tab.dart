import 'package:flutter/material.dart';
import 'package:inneed/Constant/color.dart';
import 'package:inneed/Providers/Emergency_Contact_Provider/emergency_provider.dart';
import 'package:inneed/views/tabs/Emergency/Constructor/contact_card.dart';
import 'package:provider/provider.dart';

class EmergencyTab extends StatefulWidget {
  const EmergencyTab({super.key});

  @override
  State<EmergencyTab> createState() => _Emergencytabstate();
}

class _Emergencytabstate extends State<EmergencyTab> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmergencyProvider(),
      child: Builder(
        builder: (context) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //top card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0), // Soft pink background
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                    border: Border.all(
                      color: AppColors.primaryRed.withOpacity(0.3), // Light red border line
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.fire_truck_outlined,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'In Case of\nEmergency',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'For life-threatening\nemergencies, call 1122\nimmediately',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<EmergencyProvider>(
                        builder: (context, provider, child) {
                          final isCalling1122 = provider.callingNumber == "1122";
                          return ElevatedButton.icon(
                            onPressed: isCalling1122
                                ? null
                                : () {
                              provider.makePhoneCall("1122");
                            },
                            icon: const Icon(
                              Icons.phone,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Call 1122',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                //main card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Emergency Contact Numbers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quick access to emergency services -\nNo registration required',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      //contact list cards
                      EmergencyContactCard(
                        title: 'Edhi Ambulance',
                        number: 115,
                        description: 'Medical emergencies & \nambulance',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("115");
                        },
                        icon: Icons.add_box_outlined,
                        iconColor: AppColors.primaryRed,
                      ),
                      EmergencyContactCard(
                        title: 'Rescue',
                        number: 1122,
                        description: 'Emergency ambulance & rescue',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("1122");
                        },
                        icon: Icons.add_box_outlined,
                        iconColor: const Color(0xFF2E7D32),
                      ),
                      EmergencyContactCard(
                        title: 'Fire Brigade',
                        number: 16,
                        description: 'Fire emergencies',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("16");
                        },
                        icon: Icons.local_fire_department_outlined,
                        iconColor: const Color(0xFFD84315),
                      ),
                      EmergencyContactCard(
                        title: 'Rangers Helpline',
                        number: 1101,
                        description: 'Terror threats & suspicious activity',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("1101");
                        },
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF795548),
                      ),
                      EmergencyContactCard(
                        title: 'Motorway Police',
                        number: 130,
                        description: 'Highway & Motorway accidents',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("130");
                        },
                        icon: Icons.directions_car_outlined,
                        iconColor: const Color(0xFF00897B),
                      ),
                      EmergencyContactCard(
                        title: 'Women Helpline',
                        number: 1043,
                        description: 'Harassment & domestic violence',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("1043");
                        },
                        icon: Icons.people_outline,
                        iconColor: const Color(0xFF8E24AA),
                      ),
                      EmergencyContactCard(
                        title: 'Chhipa Ambulance',
                        number: 1020,
                        description: 'Ambulance services',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("1020");
                        },
                        icon: Icons.medical_services_outlined,
                        iconColor: const Color(0xFFFB8C00),
                      ),
                      EmergencyContactCard(
                        title: 'Aman Ambulance',
                        number: 1021,
                        description: 'Advanced life support ambulance',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("1021");
                        },
                        icon: Icons.add_box_outlined,
                        iconColor: const Color(0xFFD81B60),
                      ),
                      EmergencyContactCard(
                        title: 'COVID-19 Helpline',
                        number: 1166,
                        description: 'Coronavirus assistance',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("1166");
                        },
                        icon: Icons.coronavirus_outlined,
                        iconColor: const Color(0xFF5E35B1),
                      ),
                      EmergencyContactCard(
                        title: 'Child Protection',
                        number: 1121,
                        description: 'Child abuse and protection',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("1121");
                        },
                        icon: Icons.sentiment_satisfied_alt_outlined,
                        iconColor: const Color(0xFF43A047),
                      ),
                      EmergencyContactCard(
                        title: 'Cyber Crime (FIA)',
                        number: 1991,
                        description: 'Report cyber crimes',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("1991");
                        },
                        icon: Icons.laptop_outlined,
                        iconColor: const Color(0xFF3949AB),
                      ),
                      EmergencyContactCard(
                        title: 'Bomb Disposal',
                        number: 133,
                        description: 'Bomb threat emergencies',
                        onCallPressed: () {
                          Provider.of<EmergencyProvider>(context, listen: false).makePhoneCall("133");
                        },
                        icon: Icons.warning_amber_rounded,
                        iconColor: const Color(0xFFE53935),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}