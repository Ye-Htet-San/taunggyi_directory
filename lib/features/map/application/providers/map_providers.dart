// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLastLat = 'last_lat';
const _kLastLng = 'last_lng';
const _kUseGoogleMap = 'use_google_map';

// Position state class for geolocation
class PositionState {
  final Position? position;
  final bool loading;
  final String? error;

  const PositionState({this.position, this.loading = true, this.error});

  PositionState copyWith({Position? position, bool? loading, String? error}) {
    return PositionState(
      position: position ?? this.position,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final positionProvider =
    StateNotifierProvider<PositionNotifier, PositionState>((ref) {
  final n = PositionNotifier();
  ref.onDispose(n.dispose);
  return n;
});

class PositionNotifier extends StateNotifier<PositionState> {
  StreamSubscription<Position>? _sub;

  PositionNotifier() : super(const PositionState(loading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        final last = await _getLastLocation();
        if (last != null) {
          state = state.copyWith(position: last, loading: false, error: null);
        } else {
          state = state.copyWith(
              position: null,
              loading: false,
              error: 'Location services disabled and no last known location.');
        }
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          final last = await _getLastLocation();
          if (last != null) {
            state = state.copyWith(position: last, loading: false, error: null);
          } else {
            state = state.copyWith(
                loading: false,
                error: 'Location permission denied. Allow location access to get current position.');
          }
        } else {
          try {
            final pos = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.best)
                .timeout(const Duration(seconds: 10));
            state = state.copyWith(position: pos, loading: false, error: null);
            await _saveLastLocation(pos);
          } catch (_) {
            final last = await _getLastLocation();
            if (last != null) {
              state = state.copyWith(position: last, loading: false, error: null);
            } else {
              state = state.copyWith(
                  loading: false,
                  error:
                      'Could not obtain a fresh GPS fix. Try moving outdoors and open the app again.');
            }
          }
        }
      }

      _startStreamIfPossible();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> _startStreamIfPossible() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 20,
      ),
    ).listen((pos) async {
      state = state.copyWith(position: pos, loading: false, error: null);
      await _saveLastLocation(pos);
    });
  }

  Future<void> forceRefresh() => _init();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _saveLastLocation(Position p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLastLat, p.latitude);
    await prefs.setDouble(_kLastLng, p.longitude);
  }

  Future<Position?> _getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_kLastLat);
    final lng = prefs.getDouble(_kLastLng);
    if (lat != null && lng != null) {
      return Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    return null;
  }
}

// MapPreference to toggle between Google Maps and OSM
class MapPreference {
  final bool useGoogleMap;
  const MapPreference({required this.useGoogleMap});

  MapPreference copyWith({bool? useGoogleMap}) =>
      MapPreference(useGoogleMap: useGoogleMap ?? this.useGoogleMap);
}

final mapPreferenceProvider =
    StateNotifierProvider<MapPreferenceNotifier, MapPreference>((ref) {
  return MapPreferenceNotifier();
});

class MapPreferenceNotifier extends StateNotifier<MapPreference> {
  MapPreferenceNotifier() : super(const MapPreference(useGoogleMap: true)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_kUseGoogleMap);
    if (v != null) {
      state = state.copyWith(useGoogleMap: v);
    }
  }

  Future<void> setUseGoogleMap(bool v) async {
    state = state.copyWith(useGoogleMap: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUseGoogleMap, v);
  }

  Future<void> toggle() async => setUseGoogleMap(!state.useGoogleMap);
}
