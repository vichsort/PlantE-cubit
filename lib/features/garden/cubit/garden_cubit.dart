// lib/features/garden/cubit/garden_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../services/garden_service.dart';
import '../services/identification_service.dart'; // Importa o serviço de identificação
import 'garden_state.dart';
import '../../../core/error/api_exception.dart';
import '../models/plant_summary.dart';

class GardenCubit extends Cubit<GardenState> {
  final GardenService _gardenService;
  final IdentificationService _identificationService;
  final ImagePicker _imagePicker = ImagePicker();

  // Guarda a lista completa internamente para filtrar rapidamente
  List<PlantSummary> _internalAllPlants = [];

  GardenCubit(this._gardenService, this._identificationService) : super(GardenInitial());

  /// Carrega a lista inicial de plantas do jardim.
  Future<void> loadGarden() async {
    // Evita recargas múltiplas se já estiver carregando
    if (state is GardenLoading) return;

    emit(GardenLoading());
    try {
      final plants = await _gardenService.fetchPlants();
      _internalAllPlants = plants; // Armazena a lista completa

      if (plants.isEmpty) {
        emit(GardenEmpty());
      } else {
        // Inicialmente, a lista filtrada é igual à lista completa
        emit(GardenLoaded(allPlants: plants, filteredPlants: plants));
      }
    } on ApiException catch (e) {
      emit(GardenError(e.message));
    } catch (e) {
      emit(GardenError("Erro inesperado ao carregar o jardim: ${e.toString()}"));
    }
  }

  /// Filtra a lista de plantas exibida com base no termo de busca.
  void searchPlants(String searchTerm) {
    // Só filtra se já tivermos dados carregados
    if (state is GardenLoaded) {
      final currentState = state as GardenLoaded;
      final normalizedSearch = searchTerm.toLowerCase().trim();

      if (normalizedSearch.isEmpty) {
        // Se a busca está vazia, mostra todas as plantas
        emit(currentState.copyWith(
          filteredPlants: _internalAllPlants, // Usa a lista interna completa
          searchTerm: '',
        ));
      } else {
        // Filtra a lista interna completa
        final filtered = _internalAllPlants.where((plant) {
          final nameMatch = plant.scientificName.toLowerCase().contains(normalizedSearch);
          final nicknameMatch = plant.nickname?.toLowerCase().contains(normalizedSearch) ?? false;
          return nameMatch || nicknameMatch;
        }).toList();

        // Emite um novo estado Loaded com a lista filtrada e o termo de busca
        emit(currentState.copyWith(
          filteredPlants: filtered,
          searchTerm: searchTerm,
        ));
      }
    } else {
      print("GardenCubit: Tentativa de busca em estado inválido ($state)");
    }
  }

  /// Inicia o processo de identificação de uma nova planta.
  Future<void> identifyNewPlant(ImageSource source) async {
    // Poderia emitir um estado específico 'GardenIdentifying' aqui.
    // Para simplificar, a UI pode mostrar um loading externo.
    print("GardenCubit: Starting identification from $source");

    // Para evitar múltiplas identificações simultâneas, podemos checar o estado
    // if (state is GardenLoading || state is GardenIdentifying) return;
    // emit(GardenIdentifying()); // Exemplo de estado específico

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (pickedFile != null) {
        print("GardenCubit: Image picked, sending to service...");
        // Idealmente, emitir um estado de loading aqui para feedback na UI
        // emit(GardenLoading()); // Reutiliza o estado de loading geral

        await _identificationService.identifyPlant(File(pickedFile.path));
        print("GardenCubit: Identification successful, reloading garden.");

        // Recarrega a lista do jardim para incluir a nova planta.
        // O loadGarden emitirá Loading -> Loaded/Empty.
        await loadGarden();
        // (Opcional: emitir estado GardenIdentifySuccess aqui para SnackBar,
        // mas garantir que a UI volte para Loaded/Empty depois)

      } else {
        print("GardenCubit: Image picking cancelled by user.");
        // Se estava em estado de loading/identifying, voltar ao estado anterior
        // if (state is GardenIdentifying) emit(GardenLoaded(...)) // Precisa do estado anterior
      }
    } on ApiException catch (e) {
       print("GardenCubit: API Error during identification - ${e.message}");
       emit(GardenError("Falha ao identificar planta: ${e.message}"));
    } catch (e) {
      print("GardenCubit: Unexpected error during identification - $e");
      emit(GardenError("Erro inesperado ao identificar planta: ${e.toString()}"));
    }
  }

  /// Deleta uma planta do jardim do usuário.
  Future<void> deletePlant(String plantId) async {
    print("GardenCubit: Attempting to delete plant $plantId");

    // Mostra loading e recarrega a lista após a operação
    emit(GardenLoading());

    try {
      await _gardenService.deletePlant(plantId);
      print("GardenCubit: Plant $plantId deleted successfully, reloading garden.");

      // Recarrega o jardim para refletir a remoção
      await loadGarden();
      // (Opcional: emitir estado GardenDeleteSuccess aqui para SnackBar)

    } on ApiException catch (e) {
      print("GardenCubit: API Error during deletion - ${e.message}");
      emit(GardenError("Falha ao remover planta: ${e.message}"));
      // Poderia tentar voltar ao estado anterior aqui se guardado
    } catch (e) {
       print("GardenCubit: Unexpected error during deletion - $e");
       emit(GardenError("Erro inesperado ao remover planta: ${e.toString()}"));
       // Poderia tentar voltar ao estado anterior aqui se guardado
    }
  }
}