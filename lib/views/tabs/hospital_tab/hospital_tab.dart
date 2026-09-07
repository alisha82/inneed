import 'package:flutter/material.dart';
import 'package:inneed/providers/hospital_provider/hospital_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inneed/views/tabs/hospital_tab/hospital_card/hospital_card.dart';

class HospitalTab extends StatefulWidget {
  const HospitalTab({super.key});

  @override
  State<HospitalTab> createState() => _Hospitaltabstate();
}

class _Hospitaltabstate extends State<HospitalTab> {

  // init for fetching location right after the screen opens
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<HospitalProvider>(context, listen: false).fetchUserLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    //wrapping the whole column with consumer so map and cards can listen to the provider
    return Consumer<HospitalProvider>(
      builder: (context, hospitalProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Live Google Map Container
              Container(
                height: 220,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  // Check loading state & show GoogleMap
                  child: hospitalProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        hospitalProvider.currentPosition?.latitude ?? 31.5204,
                        hospitalProvider.currentPosition?.longitude ?? 74.3587,
                      ),
                      zoom: 13,
                    ),
                    markers: hospitalProvider.markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info Header Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nearby Emergency Hospitals",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Showing hospitals within 5km radius of your current location.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.black87, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Nearby Hospitals",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 42, bottom: 12),
                child: Text(
                  "Within 5km radius from your location",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),

              //  ListView using Custom HospitalCard Widget
              hospitalProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: hospitalProvider.hospitals.length,
                itemBuilder: (context, index) {
                  return HospitalCard(
                    hospital: hospitalProvider.hospitals[index],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}