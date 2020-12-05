import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' show pi, sin, cos, atan2, sqrt;
import 'package:geolocator/geolocator.dart';
import 'package:SEEVIO/result.dart';

// Pls no ciorderino, ii restricted pe Places pls be kind
const API_KEY = "AIzaSyCGnsjLXhRfb86sDaOH6X7E3sgAtcaiKd8";
const BASE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch";

int getDistance(Position userPos, double lat, double long) {
  /// Calculate the distance from the user's current position to the POI's location
  ///
  /// [userPos] - User [Position] object
  /// [lat] - Point Of Interest latitude
  /// [long] - Point Of Interest longitude
  ///
  /// Returns [int] - distance in meters (rounded to x00 / x50)
  ///
  /// Explaination: https://www.movable-type.co.uk/scripts/latlong.html

  double userLat = userPos.latitude;
  double userLong = userPos.longitude;

  const R = 6371000;

  double radianUserLat = userLat * pi / 180;
  double radianLat = lat * pi / 180;

  double delta1 = (lat - userLat) * pi / 180;
  double delta2 = (long - userLong) * pi / 180;

  double a = sin(delta1 / 2) * sin(delta1 / 2) +
      cos(radianUserLat) * cos(radianLat) * sin(delta2 / 2) * sin(delta2 / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double _distance = R * c;
  int distance = _distance.toInt().abs();

  if (distance % 50 > 25) {
    return ((distance ~/ 50 + 1) * 50);
  } else return (distance ~/ 50 * 50);
}

String getDirection(Position userPos, double lat, double long) {
  /// Get the direction relative to the user's current position to the POI
  ///
  /// [userPos] - User [Position] object
  /// [lat] - Point Of Interest latitude
  /// [long] - Point Of Interest longitude
  ///
  /// Returns [String] - left/right/back/front

  double userLat = userPos.latitude;
  double userLong = userPos.longitude;

  double threshold = 0.004;

  double thresholdRes = userLat - lat;
  thresholdRes = thresholdRes.abs();
  if (thresholdRes < threshold) {
    if (long < userLong) {
      return "left";
    } else {
      return "right";
    }
  } else {
    if (lat < userLat) {
      return "back";
    } else {
      return "front";
    }
  }
}

Future<List<Result>> fetchNearbyPlaces(
    {Position position, int radious, String keyword}) async {
  /// Fetch the POIs near the user using the Google Places API
  /// 
  /// Param [position] - the user's current position
  /// Param [radious] - the radious in which we search for places
  /// Param [keyword], optional - Only return results that match that keyword
  /// 
  /// Returns a [List] of [Result]s

  double lat = position.latitude;
  double long = position.longitude;
  String url = "";
  List<Result> resultList = [];

  if (keyword != null) {
    url +=
        "$BASE_URL/json?location=$lat,$long&radius=$radious&keyword=$keyword&key=$API_KEY";
  } else {
    url += "$BASE_URL/json?location=$lat,$long&radius=$radious&key=$API_KEY";
  }

  http.Response res = await http.get(url);
  if (res.statusCode == 200) {
    dynamic _json = json.decode(res.body);
    List results = _json['results'];

    results.forEach((result) {
      var resultPosition = result['geometry'];
      resultPosition = resultPosition['location'];
      String relativeDir = getDirection(
        position,
        resultPosition['lat'],
        resultPosition['lng'],
      );

      int distanceFromUser = getDistance(
        position,
        resultPosition['lat'],
        resultPosition['lng'],
      );

      Result _result = new Result(
        name: result['name'],
        relativeDirection: relativeDir,
        distanceFromUser: distanceFromUser,
      );

      resultList.add(_result);
    });

    return resultList;
  } else {
    return null;
  }
}
