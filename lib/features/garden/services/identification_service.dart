import 'dart:io';

// -- Core --
import 'package:plante/core/network/api_service.dart';
import 'package:plante/core/utils/image_utils.dart';
import 'package:plante/core/utils/location_utils.dart';

class IdentificationService {
  final ApiService _apiService;
  final LocationService _locationService;

  IdentificationService(this._apiService, this._locationService);

  Future<dynamic> identifyPlant(File imageFile) async {
    try {
      // Localização
      final locationData = await _locationService.getCurrentLocation();
      print("IdentificationService: Usando localização: $locationData");

      final imageBase64 = await imageFileToBase64(imageFile);
      final responseData = await _apiService.post('/garden/identify', {
        'image': imageBase64,
        'latitude': locationData['latitude'],
        'longitude': locationData['longitude'],
      });

      return responseData;
    } catch (e) {
      rethrow;
    }
  }
}
