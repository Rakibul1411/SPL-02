import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Center of Dhaka district
  static final LatLng _dhakaCenterLocation = LatLng(23.8103, 90.4125);

  LatLng _selectedLocation = LatLng(23.7250151, 90.4028433);

  // Bounding box for Dhaka district to limit map movement
  static final LatLngBounds _dhakaBounds = LatLngBounds(
    LatLng(23.6500, 90.2500), // Southwest corner
    LatLng(24.0000, 90.5500), // Northeast corner
  );

  final MapController _mapController = MapController(); // Add MapController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Location in Dhaka",
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // Use the MapController
            options: MapOptions(
              center: _dhakaCenterLocation,
              zoom: 12.0,
              minZoom: 10.0, // Tighter min zoom for Dhaka
              maxZoom: 18.0,
              // Restrict map movement to Dhaka bounds
              bounds: _dhakaBounds,
              boundsOptions: const FitBoundsOptions(
                padding: EdgeInsets.all(50.0), // Padding for bounds
              ),
              onTap: (tapPosition, point) {
                // Ensure selected point is within Dhaka bounds
                if (_dhakaBounds.contains(point)) {
                  setState(() {
                    _selectedLocation = point;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    builder: (ctx) => const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 50.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  color: Colors.blue,
                  onPressed: () {
                    // Use MapController for zooming
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom + 1.0,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  color: Colors.blue,
                  onPressed: () {
                    // Use MapController for zooming
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom - 1.0,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedLocation);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}