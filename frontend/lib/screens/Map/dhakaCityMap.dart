import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class DhakaMapScreen extends StatefulWidget {
  const DhakaMapScreen({Key? key}) : super(key: key);

  @override
  State<DhakaMapScreen> createState() => _DhakaMapScreenState();
}

class _DhakaMapScreenState extends State<DhakaMapScreen> {
  // Initial camera position centered on Dhaka
  static const CameraPosition _dhakaPosition = CameraPosition(
    target: LatLng(23.8103, 90.4125), // Dhaka city coordinates
    zoom: 12.0,
  );

  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng _selectedPosition = LatLng(23.8103, 90.4125); // Default selected position
  bool _locationSelected = false;

  @override
  void initState() {
    super.initState();
    // Add some important Dhaka landmarks as markers
    _markers.add(
      const Marker(
        markerId: MarkerId('national_parliament'),
        position: LatLng(23.7626, 90.3776),
        infoWindow: InfoWindow(title: 'National Parliament House'),
      ),
    );

    _markers.add(
      const Marker(
        markerId: MarkerId('lalbagh_fort'),
        position: LatLng(23.7194, 90.3877),
        infoWindow: InfoWindow(title: 'Lalbagh Fort'),
      ),
    );

    _markers.add(
      const Marker(
        markerId: MarkerId('ahsan_manzil'),
        position: LatLng(23.7083, 90.4060),
        infoWindow: InfoWindow(title: 'Ahsan Manzil'),
      ),
    );
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _locationSelected = true;

      // Add or update the user's selected position marker
      _markers.removeWhere((marker) => marker.markerId == const MarkerId('selected_location'));
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Your Selected Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhaka City Map'),
        backgroundColor: Colors.green[700],
        actions: [
          if (_locationSelected)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // Convert to latlong2.LatLng before returning to match the type in registration screen
                final latlong2Position = latlong2.LatLng(
                    _selectedPosition.latitude,
                    _selectedPosition.longitude
                );
                Navigator.pop(context, latlong2Position);
              },
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _dhakaPosition,
        markers: _markers,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        onTap: _selectLocation,
      ),
      bottomNavigationBar: _locationSelected
          ? Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          onPressed: () {
            final latlong2Position = latlong2.LatLng(
                _selectedPosition.latitude,
                _selectedPosition.longitude
            );
            Navigator.pop(context, latlong2Position);
          },
          child: const Text(
            'Confirm Location',
            style: TextStyle(fontSize: 16),
          ),
        ),
      )
          : Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          'Tap on the map to select your location',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}