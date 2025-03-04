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
  // Set the default location to Amar Ekushey Hall, University of Dhaka
  LatLng _selectedLocation = LatLng(23.7250362, 90.4028087); // Latitude and Longitude for Amar Ekushey Hall
  final ValueNotifier<double> _zoomLevel = ValueNotifier<double>(16.0); // Default zoom level

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Location",
          style: GoogleFonts.roboto(  // Apply custom Google font here
            color: Colors.white, // Set text color to white
            fontSize: 20, // Optional: Customize font size
            fontWeight: FontWeight.w600, // Optional: Customize font weight
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _zoomLevel,
            builder: (context, zoom, child) {
              return FlutterMap(
                options: MapOptions(
                  center: _selectedLocation,
                  zoom: zoom,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedLocation = point;
                    });
                  },
                  maxZoom: 18.0, // Set a maximum zoom level
                  minZoom: 4.0, // Set a minimum zoom level
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
              );
            },
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
                    if (_zoomLevel.value < 18.0) {
                      _zoomLevel.value += 1; // Zoom In
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  color: Colors.blue,
                  onPressed: () {
                    if (_zoomLevel.value > 4.0) {
                      _zoomLevel.value -= 1; // Zoom Out
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedLocation); // Return the selected location
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
