import 'dart:math' show log, Point, max;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// flutter_map utility for image map projection
class RasterCoords {
  CrsSimple crsSimple = CrsSimple();
  late double scale;
  late double zoomLevel;
  double width;
  double height;
  double tileSize;

  RasterCoords({
    required this.width,
    required this.height,
    this.tileSize = 256,
  }) {
    initialize();
  }

  /// initialize the zoom level and scale
  void initialize(){
    zoomLevel = computeZoomLevel();
    scale = crsSimple.scale(zoomLevel);
  }

  /// compute the zoomLevel based on the image [width] and [height]
  double computeZoomLevel() {
    return (log(max(width, height) / tileSize) / log(2)).ceil().toDouble();
  }

  /// Converts pixel to latlng based on the [x] and [y] coordinates
  /// of the raster image
  ///
  /// returns latitude and longitude
  LatLng pixelToLatLng(double x, double y) {
    final (double lat, double lng) = crsSimple.untransform(
      -y,
      -x,
      crsSimple.scale(zoomLevel),
    );

    return LatLng(lat, lng);
  }

  /// Converts [LatLng] to pixel based on
  /// the [latitude] and [longitude]
  /// coordinates from the map
  ///
  /// returns a [Point] object with x and y coordinates
  /// of the pixel
  Point latLngToPixel(LatLng latLng) {
    final lng = latLng.longitude;
    final lat = latLng.latitude;
    final (double x, double y) = crsSimple.transform(
      lng,
      lat,
      crsSimple.scale(zoomLevel),
    );

    return Point(x, y);
  }

  /// Get the max bounds of the image
  LatLngBounds getMaxBounds() {
    final southWest = pixelToLatLng(0, height);
    final northEast = pixelToLatLng(width, 0);

    return LatLngBounds(southWest, northEast);
  }
}
