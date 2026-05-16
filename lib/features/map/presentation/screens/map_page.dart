import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

// Google Maps
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

// Flutter Map (OSM)
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlng;

// Providers & Models
import 'package:tgi_directory/features/map/application/providers/map_providers.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
import 'package:tgi_directory/features/places/application/providers/places_provider.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  static const latlng.LatLng _fallbackLatLng = latlng.LatLng(20.79905, 97.0339);

  final Completer<gmap.GoogleMapController> _gController = Completer();
  final fm.MapController _fmController = fm.MapController();

  Set<gmap.Marker> _gMarkers = {};
  List<fm.Marker> _fmMarkers = [];
  final double _zoom = 14.0;

  List<_PlaceWithDistance> _nearestPlaces = [];

  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(positionProvider);
    final mapPref = ref.watch(mapPreferenceProvider);
    final placesAsync = ref.watch(placesProvider);

    // ✅ Listen only once
    if (!_listening) {
      _listening = true;

      // Listen to position updates
      ref.listen<PositionState>(positionProvider, (prev, next) {
        final nextPos = next.position;
        if (nextPos != null &&
            (prev?.position == null || _distanceMoved(prev!.position!, nextPos) > 20)) {
          _centerMapsTo(nextPos);

          final places = ref.read(placesProvider).maybeWhen(
                data: (p) => p,
                orElse: () => <Place>[],
              );
          _computeNearestAndMarkers(nextPos, places);
        }
      });

      // Listen to places updates
      ref.listen<AsyncValue<List<Place>>>(placesProvider, (prev, next) {
        next.whenData((places) {
          final pos = ref.read(positionProvider).position;
          if (pos != null) _computeNearestAndMarkers(pos, places);
        });
      });
    }

    // Loading UI
    if (posState.loading || placesAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nearby Places')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error handling
    if (posState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.clearSnackBars();
        scaffold.showSnackBar(SnackBar(content: Text(posState.error!)));
      });
    }

    final places = placesAsync.maybeWhen(data: (p) => p, orElse: () => <Place>[]);

    // Initial marker computation if empty
    if (_gMarkers.isEmpty && posState.position != null && places.isNotEmpty) {
      _computeNearestAndMarkers(posState.position, places);
    }

    final centerLatLng = posState.position != null
        ? latlng.LatLng(posState.position!.latitude, posState.position!.longitude)
        : _fallbackLatLng;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Places'),
        actions: [
          IconButton(
            tooltip:
                mapPref.useGoogleMap ? 'Switch to OpenStreetMap' : 'Switch to Google Maps',
            icon: Icon(mapPref.useGoogleMap ? Icons.map : Icons.public),
            onPressed: () async {
              await ref.read(mapPreferenceProvider.notifier).toggle();
              final pos = ref.read(positionProvider).position;
              if (pos != null) _centerMapsTo(pos);
            },
          ),
        ],
      ),
      body: mapPref.useGoogleMap
          ? _buildGoogleMap(centerLatLng)
          : _buildFlutterMap(centerLatLng),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () {
          final pos = ref.read(positionProvider).position;
          if (pos != null) _centerMapsTo(pos);
        },
      ),
    );
  }

  double _distanceMoved(Position a, Position b) {
    return Geolocator.distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);
  }

  Future<void> _centerMapsTo(Position pos) async {
    // Google Map
    if (_gController.isCompleted) {
      try {
        final ctrl = await _gController.future;
        await ctrl.animateCamera(
          gmap.CameraUpdate.newLatLng(gmap.LatLng(pos.latitude, pos.longitude)),
        );
      } catch (_) {}
    }

    // Flutter Map
    try {
      _fmController.move(latlng.LatLng(pos.latitude, pos.longitude), _zoom);
    } catch (_) {}
  }

  void _computeNearestAndMarkers(Position? pos, List<Place> allPlaces) {
    if (pos == null) return;

    final lat = pos.latitude;
    final lng = pos.longitude;

    _nearestPlaces = allPlaces
        .map((p) {
          final distance = Geolocator.distanceBetween(lat, lng, p.latitude, p.longitude);
          return _PlaceWithDistance(place: p, distanceMeters: distance);
        })
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    final nearest = _nearestPlaces.take(min(5, _nearestPlaces.length)).toList();

    // Google Maps markers
    final gmarkers = <gmap.Marker>{
      gmap.Marker(
        markerId: const gmap.MarkerId('me'),
        position: gmap.LatLng(lat, lng),
        icon: gmap.BitmapDescriptor.defaultMarkerWithHue(gmap.BitmapDescriptor.hueBlue),
        infoWindow: const gmap.InfoWindow(title: 'You are here'),
      ),
      ...nearest.map(
        (pw) => gmap.Marker(
          markerId: gmap.MarkerId(pw.place.id.toString()),
          position: gmap.LatLng(pw.place.latitude, pw.place.longitude),
          infoWindow: gmap.InfoWindow(
            title: pw.place.title,
            snippet: _prettyDistance(pw.distanceMeters),
            onTap: () => context.push('/place-detail', extra: pw.place),
          ),
        ),
      ),
    };

    // Flutter Map markers
    final fmMarkers = <fm.Marker>[
      fm.Marker(
        point: latlng.LatLng(lat, lng),
        width: 48,
        height: 48,
        child: const Icon(Icons.my_location, size: 32, color: Colors.blue),
      ),
      ...nearest.map(
        (pw) => fm.Marker(
          point: latlng.LatLng(pw.place.latitude, pw.place.longitude),
          width: 120,
          height: 60,
          child: GestureDetector(
            onTap: () => context.push('/place-detail', extra: pw.place),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_pin, size: 36, color: Colors.red),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    pw.place.title,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    setState(() {
      _gMarkers = gmarkers;
      _fmMarkers = fmMarkers;
    });
  }

  String _prettyDistance(double meters) {
    return meters < 1000
        ? '${meters.toStringAsFixed(0)} m'
        : '${(meters / 1000).toStringAsFixed(2)} km';
  }

  Widget _buildGoogleMap(latlng.LatLng center) {
    final initialCamera = gmap.CameraPosition(
      target: gmap.LatLng(center.latitude, center.longitude),
      zoom: _zoom,
    );

    return gmap.GoogleMap(
      initialCameraPosition: initialCamera,
      markers: _gMarkers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: gmap.MapType.normal,
      buildingsEnabled: true,
      liteModeEnabled: true,
      minMaxZoomPreference: const gmap.MinMaxZoomPreference(5, 18),
      onMapCreated: (ctrl) {
        if (!_gController.isCompleted) _gController.complete(ctrl);
      },
    );
  }

  Widget _buildFlutterMap(latlng.LatLng center) {
    return fm.FlutterMap(
      mapController: _fmController,
      options: fm.MapOptions(
        initialCenter: center,
        initialZoom: _zoom,
        interactionOptions: fm.InteractionOptions(flags: fm.InteractiveFlag.all),
      ),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.tgi_directory',
        ),
        fm.MarkerLayer(markers: _fmMarkers),
      ],
    );
  }
}

class _PlaceWithDistance {
  final Place place;
  final double distanceMeters;
  const _PlaceWithDistance({required this.place, required this.distanceMeters});
}
