import 'package:flutter/material.dart';
import '../models/plaza.dart';

class PlazaViewModel extends ChangeNotifier {
  List<Plaza> _userPlazas = [];
  bool _isLoading = false;
  String? _error;

  List<Plaza> get userPlazas => _userPlazas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PlazaViewModel({String? userId}) {
    if (userId != null) {
      fetchUserPlazas(userId);
    }
  }

  Future<void> fetchUserPlazas(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 5)); // TODO: Remove Future
      _userPlazas = [
        Plaza(
          id: '1',
          imageUrl: '',
          name: 'MG Plaza',
          location: 'Infosys circle, Hinjewadi',
        ),
        Plaza(
          id: '2',
          imageUrl: '',
          name: 'Tech Plaza',
          location: 'Phase 2, Hinjewadi',
        ),
        Plaza(
          id: '3',
          imageUrl: '',
          name: 'MG Plaza',
          location: 'Infosys circle, Hinjewadi',
        ),
        Plaza(
          id: '4',
          imageUrl: '',
          name: 'MG Plaza',
          location: 'Infosys circle, Hinjewadi',
        ),
        Plaza(
          id: '5',
          imageUrl: '',
          name: 'MG Plaza',
          location: 'Infosys circle, Hinjewadi',
        ),
      ];
    } catch (e) {
      _error = 'Failed to fetch plazas: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPlaza(Plaza plaza) async {
    try {
      _isLoading = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
      _userPlazas.add(plaza);
    } catch (e) {
      _error = 'Failed to add plaza: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePlaza(Plaza updatedPlaza) async {
    try {
      _isLoading = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
      final index = _userPlazas.indexWhere((p) => p.id == updatedPlaza.id);
      if (index != -1) {
        _userPlazas[index] = updatedPlaza;
      }
    } catch (e) {
      _error = 'Failed to update plaza: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePlaza(String plazaId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
      _userPlazas.removeWhere((plaza) => plaza.id == plazaId);
    } catch (e) {
      _error = 'Failed to delete plaza: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
