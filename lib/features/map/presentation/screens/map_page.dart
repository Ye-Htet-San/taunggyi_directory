// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
// import 'package:tgi_directory/features/places/data/models/sample_places.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //Fallback center (Taunggyi-ish)
  static const LatLng _fallbackLatLng = LatLng(20.79905, 97.0339);

  //Turn this on if device is low-end/crashes with GL
  //Lite mode disables gesture but is MUCH lighter.

  static final bool _useLiteModeOnAndroid =
      defaultTargetPlatform == TargetPlatform.android;

  final Set<Marker> _markers = <Marker>{};
  final Completer<GoogleMapController> _controller = Completer();

  Position? _currentPosition;
  bool _loading = true;
  String? _errorMessage;

  //Cache the 5 nearest places so we don't recompute every build.
  // List<_PlaceWithDistance> _nearest = const [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      //1) Check service
      final serviceEnable = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnable) {
        _error("Location services are disabled.");
        return;
      }

      //2) Check/request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _error("Location permission denied.");
      }

      //3) Use last know first(fast)
      final last = await Geolocator.getLastKnownPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition =
            last ??
            Position(
              //fallback to city center if no last known
              longitude: _fallbackLatLng.latitude,
              latitude: _fallbackLatLng.longitude,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              altitudeAccuracy: 1,
              heading: 0,
              headingAccuracy: 1,
              speed: 0,
              speedAccuracy: 0,
            );
      });

      //4) Compute nearest 5 & draw markers immediately
      _computeNearestAndMarkers();

      //5) Trying to refine with current GPS( but don't hang forever)
      Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            timeLimit: const Duration(seconds: 5),
          )
          .then((pos) async {
            if (!mounted) return;
            setState(() {
              _currentPosition = pos;
            });
            _computeNearestAndMarkers();

            //Animate camera gently to exact position
            if (_controller.isCompleted) {
              final c = await _controller.future;
              c.animateCamera(
                CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
              );
            }
          })
          .catchError((_) {
            //
          });
    } catch (e) {
      _error("Error getting location:$e");
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _error(String msg) {
    if (!mounted) return;
    setState(() {
      _errorMessage = msg;
      _loading = false;
    });
  }

  void _computeNearestAndMarkers() {
    if (_currentPosition == null) return;

    final meLat = _currentPosition!.latitude;
    final meLng = _currentPosition!.longitude;
    final samplePlaces = [];
    //Build typed list with distances
    final List<_PlaceWithDistance> all =
        samplePlaces.map((p) {
          final dMeters = Geolocator.distanceBetween(
            meLat,
            meLng,
            p.latitude,
            p.longitude,
          );
          return _PlaceWithDistance(place: p, distanceMeters: dMeters);
        }).toList();

    //Sort by distance & take nearest 5

    all.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    final nearest = all.take(min(5, all.length)).toList();

    //Build markers : current + 5 places

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('me'),
        position: LatLng(meLat, meLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'You are here'),
      ),

      //Places
      ...nearest.map((pw) {
        final p = pw.place;
        final dist = _prettyDistance(pw.distanceMeters);
        return Marker(
          markerId: MarkerId(p.id as String),
          position: LatLng(p.latitude, p.longitude),
          infoWindow: InfoWindow(
            title: p.title,
            snippet: dist,
            onTap: () {
              //Navigate to detail page
              context.push('/place-detail', extra: p);
            },
          ),
        );
      }),
    };

    if (!mounted) return;
    setState(() {
      // _nearest = nearest;
      _markers
        ..clear()
        ..addAll(markers);
    });
  }

  String _prettyDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    }
    return '${(meters / 1000).toStringAsFixed(2)}km';
    //
  }

  Future<void> _recenter() async {
    if (_currentPosition == null) return;
    if (!_controller.isCompleted) return;
    final c = await _controller.future;
    await c.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15,
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });
    _errorMessage = null;
    await _init();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Nearby Places')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nearby Places')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                  },
                  child: const Text('Open Location Settings'),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _refresh,
          child: const Icon(Icons.refresh),
        ),
      );
    }

    final LatLng center =
        _currentPosition == null
            ? _fallbackLatLng
            : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Places')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: center, zoom: 14.5),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,

        // Performance knobs for older devices:
        buildingsEnabled: false,
        indoorViewEnabled: false,
        trafficEnabled: false,

        // Lite mode is much lighter on Android devices prone to Adreno/GL crashes.
        liteModeEnabled: false,

        // Reduce zoom span to avoid huge tile loads
        minMaxZoomPreference: const MinMaxZoomPreference(10, 18),

        onMapCreated: (controller) {
          if (!_controller.isCompleted) {
            _controller.complete(controller);
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'refresh',
            onPressed: _refresh,
            child: const Icon(Icons.refresh),
          ),
          // const SizedBox(height: 10),
          // FloatingActionButton(
          //   heroTag: 'center',
          //   onPressed: _recenter,
          //   child: const Icon(Icons.my_location),
          // ),
        ],
      ),
    );
  }
}

class _PlaceWithDistance {
  final Place place;
  final double distanceMeters;
  const _PlaceWithDistance({required this.place, required this.distanceMeters});
}
