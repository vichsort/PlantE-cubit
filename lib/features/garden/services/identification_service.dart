import 'dart:io';
import '../../../core/network/api_service.dart';
import '../../../core/utils/image_utils.dart';

class IdentificationService {
  final ApiService _apiService;

  IdentificationService(this._apiService);

  Future<dynamic> identifyPlant(File imageFile) async {
    try {
      print("IdentificationService: Identifying plant...");
      final imageBase64 = await imageFileToBase64(imageFile); 
      final responseData = await _apiService.post('/garden/identify', {
        'image': imageBase64,
      });
      print("IdentificationService: Plant identified successfully.");
      return responseData;
    } catch (e) {
      print("IdentificationService: Error identifying plant - $e");
      rethrow;
    }
  }
}