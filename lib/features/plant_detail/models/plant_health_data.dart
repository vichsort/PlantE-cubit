import 'package:equatable/equatable.dart';

class PlantHealthData extends Equatable {
  final String diseaseName;
  final List<String> symptoms;
  final List<String> treatmentPlan;
  final String recoveryTime;

  const PlantHealthData({
    required this.diseaseName,
    required this.symptoms,
    required this.treatmentPlan,
    required this.recoveryTime,
  });

  factory PlantHealthData.fromJson(Map<String, dynamic> json) {
    return PlantHealthData(
      diseaseName: json['disease_name'] as String,
      symptoms: List<String>.from(json['symptoms'] as List),
      treatmentPlan: List<String>.from(json['treatment_plan'] as List),
      recoveryTime: json['recovery_time'] as String,
    );
  }

  @override
  List<Object?> get props => [
    diseaseName,
    symptoms,
    treatmentPlan,
    recoveryTime,
  ];
}
