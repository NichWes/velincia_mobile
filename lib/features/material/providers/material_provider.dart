import 'package:flutter/material.dart';
import '../data/material_service.dart';
import '../models/material_model.dart';

class MaterialProvider extends ChangeNotifier {
  final MaterialService _materialService = MaterialService();

  bool isLoading = false;
  List<MaterialModel> materials = [];
  String? errorMessage;

  Future<void> fetchMaterials() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      materials = await _materialService.getMaterials();
    } catch (e) {
      errorMessage = 'Gagal memuat material: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
