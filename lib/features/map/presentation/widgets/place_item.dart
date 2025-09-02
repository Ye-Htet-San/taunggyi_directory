// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
// import 'package:tgi_directory/features/places/data/models/sample_places.dart';

// // Just implement ClusterItem interface instead of extending
// class PlaceItem implements ClusterItem {
//   @override
//   final LatLng location;
//   final String id;
//   final String title;

//   PlaceItem({
//     required this.id,
//     required this.title,
//     required double latitude,
//     required double longitude,
//   }) : location = LatLng(latitude, longitude);
  
//   @override
//   // TODO: implement geohash
//   String get geohash => throw UnimplementedError(); // assign to ClusterItem.location
// }

// // Convert your nearest places to ClusterItems
// List<PlaceItem> clusterItems = samplePlaces.map((place) {
//   return PlaceItem(
//     id: place.id,
//     title: place.title,
//     latitude: place.latitude,
//     longitude: place.longitude,
//   );
// }).toList();
