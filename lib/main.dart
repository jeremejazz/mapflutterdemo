import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io' show Platform;


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



                },

                crs: CrsSimple(),
                initialCenter: pixelToLatLng(1280/2,1280/2, 3),

                initialZoom: 1,

              ),
              children: [
                TileLayer(
                  urlTemplate: getMapUrl(),

                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pixelToLatLng(1280/2,1280/2, 3),
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



/// The most common CRS used for rendering maps.
class Epsg3857NoWrap extends Epsg3857 {
  @override
  bool get infinite => false;

  @override
  final (double, double)? wrapLng = null;

  @override
  final (double, double)? wrapLat = null;


  @override
  final String code = 'EPSG:3857';

  @override
  final Projection projection;

  @override
  final Transformation transformation;

  static const double _scale = 0.5 / (math.pi * SphericalMercator.r);

  const Epsg3857NoWrap()
      : projection = const SphericalMercator(),
        transformation = const Transformation(_scale, 0.5, -_scale, 0.5),
        super();

}

class Transformation {
  final double a;
  final double b;
  final double c;
  final double d;

  const Transformation(this.a, this.b, this.c, this.d);

  @nonVirtual
  (double, double) transform(double x, double y, double scale) => (
  scale * (a * x + b),
  scale * (c * y + d),
  );

  @nonVirtual
  (double, double) untransform(double x, double y, double scale) => (
  (x / scale - b) / a,
  (y / scale - d) / c,
  );
}

(int?, int?)? projectLatLonToRaster(
    double latitude,
    double longitude,
    int imageHeight,
    int imageWidth,
    double minLatitude,
    double maxLatitude,
    double minLongitude,
    double maxLongitude,
    ) {
  if (latitude < minLatitude ||
      latitude > maxLatitude ||
      longitude < minLongitude ||
      longitude > maxLongitude) {
    return null;
  }

  // Calculate the normalized position within the latitude range (0 to 1)
  final normalizedLat = (latitude - minLatitude) / (maxLatitude - minLatitude);

  // Calculate the normalized position within the longitude range (0 to 1)
  final normalizedLon = (longitude - minLongitude) / (maxLongitude - minLongitude);

  // Project to raster coordinates
  final row = ((1 - normalizedLat) * imageHeight).toInt(); // Invert latitude for image row
  final col = (normalizedLon * imageWidth).toInt();

  return (row, col);
}