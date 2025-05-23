import 'dart:math' show log, Point, max;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    zoomLevel = computeZoomLevel();
    scale = crsSimple.scale(zoomLevel);
  }

  double computeZoomLevel() {

    return (log(max(width, height) / tileSize) /
        log(2))
        .ceil()
        .toDouble();
  }

  /// Converts pixel to latlng based on the [x] and [y] coordinates
  /// of the raster image
  ///
  /// returns latitude and longitude
  (double lat, double lng) pixelToLatLng(double x, double y) {

   final (double lng, double lat) = crsSimple.untransform(-y, -x, crsSimple.scale(zoomLevel));

   return (lat, lng);
  }

  /// Converts [latlng] to pixel based on
  /// the [latitude] and [longitude] coordinates
  ///
  /// returns [x] and [y] coordinates
  (double x, double y) latLngToPixel(double lat, double lng) {

    final (double y, double x) = crsSimple.transform(lng, lat, crsSimple.scale(zoomLevel));

    return (x, y);

  }

  /// based on leaflet's [Map#project] method
  Point project(LatLng latLng) {
    final (double x, double y) = latLngToPixel(latLng.latitude, latLng.longitude);
    return Point(x,y);
  }
  /// based on leaflet's [Map#unproject] method
  LatLng unproject(Point point) {
    final (double lat, double lng) = pixelToLatLng(point.x.toDouble(), point.y.toDouble());
    return LatLng(lat, lng);
  }

  LatLngBounds getMaxBounds() {
  /**
   *  var southWest = this.unproject([0, this.height])
      var northEast = this.unproject([this.width, 0])
      return new L.LatLngBounds(southWest, northEast)
   */

  return LatLngBounds(
  LatLng(90, -180),
  LatLng(-90, 180),
  );

  }


}
