import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Localização padrão: Brasília
  final Map<String, double> _brasiliaLocation = {
    'latitude': -15.7797,
    'longitude': -47.9297,
  };

  Future<Map<String, double>> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Testa se o serviço de localização está habilitado
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("LocationService: GPS desabilitado. Usando fallback.");
        return _brasiliaLocation;
      }

      // checa a permissão
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("LocationService: Permissão negada. Usando fallback.");
          return _brasiliaLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          "LocationService: Permissão negada permanentemente. Usando fallback.",
        );
        return _brasiliaLocation;
      }

      // então pegamos a posição
      debugPrint("LocationService: Permissão OK. Buscando localização...");
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (e) {
      // Se der timeout ou qualquer outro erro, usa o fallback
      debugPrint(
        "LocationService: Erro ao buscar localização ($e). Usando fallback.",
      );
      return _brasiliaLocation;
    }
  }
}
