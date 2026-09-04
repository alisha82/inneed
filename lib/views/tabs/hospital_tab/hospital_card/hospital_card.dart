import 'package:flutter/material.dart';
import 'package:inneed/Models/hospital_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalCard extends StatelessWidget {
  final HospitalModel hospital;
  const HospitalCard({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Name & availability badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hospital.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hospital.isAvailable ? "Available" : "Busy",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

          ),
          const SizedBox(height: 4),
          Text(
            hospital.address,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          //distance & rating
          Row(
            children: [
              Icon(Icons.location_on,
                size: 14,
                color: Colors.blue,),
              const SizedBox(width: 4),
              Text(
                "${hospital.distance} km away",
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.star,
                  size: 14,
                  color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                "${hospital.rating}",
                style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons: Directions & Call
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: ()async {
                    final Uri googleMapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=${hospital.latitude},${hospital.longitude}');
                    if (await canLaunchUrl(googleMapUrl)) {
                      await launchUrl(googleMapUrl);
                    }
                  },
                  icon: const Icon(Icons.directions_outlined,
                      size: 16,
                      color: Colors.black87),

                  label: Text('Directions',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton.icon(
                    onPressed: ()async{
                      final Uri telUrl = Uri.parse('tel:${hospital.phoneNumber}');
                      if (await canLaunchUrl(telUrl)) {
                        await launchUrl(telUrl);
                      }
                    },
                    icon: const Icon(Icons.call, size: 16, color: Colors.white),
                    label: const Text("Call",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B2A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )
              ),
            ],
          ),
        ],
      ),

    );
  }
}
