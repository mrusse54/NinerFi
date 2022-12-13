// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Buildings _$BuildingsFromJson(Map<String, dynamic> json) => Buildings(
      building: json['building'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      count: json['count'] as int,
    );

Map<String, dynamic> _$BuildingsToJson(Buildings instance) => <String, dynamic>{
      'building': instance.building,
      'lat': instance.lat,
      'lng': instance.lng,
      'count': instance.count,
    };

Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
      buildings: (json['buildings'] as List<dynamic>)
          .map((e) => Buildings.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
      'buildings': instance.buildings,
    };
