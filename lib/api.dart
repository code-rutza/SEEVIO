import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' show pi, sin, cos, atan2, sqrt;
import 'package:geolocator/geolocator.dart';
import 'package:seevio/result.dart';

const API_KEY = "AIzaSyCGnsjLXhRfb86sDaOH6X7E3sgAtcaiKd8";
const BASE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch";

int getDistance(Position userPos, double lat, double long) {
  /// https://www.movable-type.co.uk/scripts/latlong.html
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

  double distance = R * c;

  return distance.toInt().abs();
}

String getDirection(Position userPos, double lat, double long) {
  /// Probabil gresit, vezi chiar codu!
  /// if (abs(userLat - lat) < threshold) atunci fata sau spate
  ///
  /// lat < userLat -> stanga else dreapta
  ///
  /// long < userLong  -> spate else fata
  assert(userPos != null);
  assert(lat != null);
  assert(long != null);

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

Future<List> fetchNearbyPlaces(
    {Position position, int radious, String keyword}) async {
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
