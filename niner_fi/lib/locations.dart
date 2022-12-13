import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'locations.g.dart';



//This code is from an example

@JsonSerializable()
class Buildings {
  Buildings({
    required this.building,
    required this.lat,
    required this.lng,
    required this.count,
  });

  factory Buildings.fromJson(Map<String, dynamic> json) => _$BuildingsFromJson(json);
  Map<String, dynamic> toJson() => _$BuildingsToJson(this);

  final String building;
  final double lat;
  final double lng;
  final int count;

}


@JsonSerializable()
class Locations {
  Locations({
    required this.buildings,
  });

  factory Locations.fromJson(Map<String, dynamic> json) =>
      _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final List<Buildings> buildings;

}

Future<Locations> getGoogleOffices() async {
  const googleLocationsURL = 'https://ninerfi.azurewebsites.net/api/connecteddevices';

  // Retrieve the locations of Google offices
  try {
    final response = await http.get(Uri.parse(googleLocationsURL));
    if (response.statusCode == 200) {
      return Locations.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }

  // Fallback for when the above HTTP request fails.
  return Locations.fromJson(
    json.decode(
      await rootBundle.loadString('assets/locations.json'),
    ) as Map<String, dynamic>,
  );
}