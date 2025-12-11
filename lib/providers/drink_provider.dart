// 📁 lib/providers/drink_provider.dart
// Custom drinks ve drink logs için provider

import 'package:flutter/material.dart';
import 'package:health_care/models/custom_drink_model.dart';
import 'package:health_care/services/custom_drink_service.dart';

class DrinkProvider extends ChangeNotifier {
  final CustomDrinkService _service = CustomDrinkService();
  
  List<CustomDrink> _customDrinks = [];
  List<DrinkLog> _todayLogs = [];
  List<DrinkLog> _selectedDateLogs = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  List<CustomDrink> get customDrinks => _customDrinks;
  List<DrinkLog> get todayLogs => _todayLogs;
  List<DrinkLog> get selectedDateLogs => _selectedDateLogs;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  // Initialize ve Firebase listener'ları başlat
  void initialize() {
    _isLoading = true;
    notifyListeners();

    // Custom drinks listener
    _service.getCustomDrinks().listen((drinks) {
      _customDrinks = drinks;
      notifyListeners();
    }, onError: (error) {
      debugPrint('DrinkProvider custom drinks error: $error');
      _isLoading = false;
      notifyListeners();
    });

    // Today's logs listener
    _service.getTodayDrinkLogs().listen((logs) {
      _todayLogs = logs;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('DrinkProvider today logs error: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  // Custom drink ekle
  Future<void> addCustomDrink(CustomDrink drink) async {
    try {
      await _service.addCustomDrink(drink);
    } catch (e) {
      debugPrint('Error adding custom drink: $e');
      rethrow;
    }
  }

  // Custom drink güncelle
  Future<void> updateCustomDrink(String drinkId, CustomDrink drink) async {
    try {
      await _service.updateCustomDrink(drinkId, drink);
    } catch (e) {
      debugPrint('Error updating custom drink: $e');
      rethrow;
    }
  }

  // Custom drink sil
  Future<void> deleteCustomDrink(String drinkId) async {
    try {
      await _service.deleteCustomDrink(drinkId);
    } catch (e) {
      debugPrint('Error deleting custom drink: $e');
      rethrow;
    }
  }

  // Drink log ekle
  Future<void> addDrinkLog(DrinkLog log) async {
    try {
      await _service.addDrinkLog(log);
    } catch (e) {
      debugPrint('Error adding drink log: $e');
      rethrow;
    }
  }

  // Drink log sil
  Future<void> deleteDrinkLog(String logId) async {
    try {
      await _service.deleteDrinkLog(logId);
    } catch (e) {
      debugPrint('Error deleting drink log: $e');
      rethrow;
    }
  }

  // Bugünün toplam bardak sayısını al
  Future<int> getTodayTotalCups() async {
    try {
      return await _service.getTodayTotalCups();
    } catch (e) {
      debugPrint('Error getting today total cups: $e');
      return 0;
    }
  }

  // Seçili tarihi değiştir ve o tarihin loglarını yükle
  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
    
    // O tarihin loglarını dinle
    _service.getDrinkLogsForDate(_selectedDate).listen((logs) {
      _selectedDateLogs = logs;
      notifyListeners();
    }, onError: (error) {
      debugPrint('DrinkProvider selected date logs error: $error');
    });
  }
}
