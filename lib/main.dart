import 'dart:math' as math;

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


  pixelToLatLng(double x, double y, double zoom){
    var crsSimple = CrsSimple();
    var (lng, lat) = crsSimple.untransform(-y, -x, crsSimple.scale(zoom));

    return LatLng(lng, lat);
  }

  String getMapUrl(){
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
                    bounds: LatLngBounds(pixelToLatLng(0, 0, 3),
                        pixelToLatLng(1280, 1280, 3))),
                onTap: (tapPosition, point,) {
                  const crsSimple =  CrsSimple();



                  // this is the way!
                  // ceiling( log(imagesize / tilesize) / log(2) )
                  var (transformedX, transformedY) = crsSimple.transform(point.longitude, point.latitude, crsSimple.scale(3));
                  debugPrint('TransformedX: ${transformedX.ceil()}, TransformedY: ${transformedY.ceil()}');


                  debugPrint('${rc.latLngToPixel(point.latitude, point.longitude)}');
                },

                crs: rc.crsSimple,

                // initialCenter: pixelToLatLng(1280/2,1280/2, 3),
                initialCenter: rc.pixelToLatLng(1280/2,1280/2),
                initialZoom: 1,

              ),
              children: [
                TileLayer(
                  urlTemplate: getMapUrl(),

                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: rc.pixelToLatLng(1280/2,1280/2),
                      width: 30,
                      height: 30,
                      child: FlutterLogo(),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

