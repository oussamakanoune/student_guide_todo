import 'package:flutter/material.dart';
import '../services/storage_service.dart';


class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  bool _isDarkMode = false;


  ThemeProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService() {
    _loadTheme();
  }


  bool get isDarkMode => _isDarkMode;


  Future<void> _loadTheme() async {
    _isDarkMode = await _storageService.isDarkTheme();
    notifyListeners();
  }


  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.setDarkTheme(_isDarkMode);
  }


  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _storageService.setDarkTheme(value);
  }
}