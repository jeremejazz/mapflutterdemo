import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io' show Platform;

import 'package:mapflutterdemo/rastercoords.dart';

void main() {
  runApp(const MapFlutter());
}

class MapFlutter extends StatelessWidget {
  const MapFlutter({super.key});

  pixelToLatLng(double x, double y, double zoom) {
    var crsSimple = CrsSimple();
    var (lng, lat) = crsSimple.untransform(-y, -x, crsSimple.scale(zoom));

    return LatLng(lng, lat);
  }

  String getMapUrl() {
    if (kIsWeb) {
      return "http://localhost:8000/map_tiles/{z}/{x}/{y}.png";
    }

    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/map_tiles/{z}/{x}/{y}.png";
    }
    return "http://localhost:8000/map_tiles/{z}/{x}/{y}.png";
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final rc = RasterCoords(width: 1280, height: 1280);
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                cameraConstraint: CameraConstraint.containCenter(
                  bounds: rc.getMaxBounds(),
                ),
                onTap: (tapPosition, latLng) {
                 final pixelCoords = rc.latLngToPixel(latLng);
                 debugPrint('Lat/Lng Coords: $latLng');
                  debugPrint(
                    'Pixel Coords: $pixelCoords ',
                  );

                },

                crs: CrsSimple(),

                // initialCenter: pixelToLatLng(1280/2,1280/2, 3),
                initialCenter: rc.pixelToLatLng(x: 1280 / 2,y: 1280 / 2),
                maxZoom: 3,
                minZoom: 1,
                initialZoom: 1,
              ),
              children: [
                TileLayer(urlTemplate: getMapUrl()),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: rc.pixelToLatLng(x: 1280 / 2, y: 1280 / 2),
                      width: 30,
                      height: 30,
                      child: FlutterLogo(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
