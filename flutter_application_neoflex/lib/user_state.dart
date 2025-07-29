import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_neoflex/database/database_helper.dart';
import 'package:flutter_application_neoflex/models/shop_item.dart';
import 'package:flutter_application_neoflex/models/accelerator_application.dart';

class UserState extends ChangeNotifier {
  int _points = 0;
  final Map<String, bool> _rewardedTests = {};
  final DatabaseHelper _dbHelper = DatabaseHelper();


  int get points => _points;
  bool wasRewarded(String testId) => _rewardedTests[testId] ?? false;

  
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _points = prefs.getInt('user_points') ?? 0;

    final rewardedRaw = prefs.getString('rewarded_tests') ?? '{}';
    _rewardedTests.addAll(Map<String, bool>.from(jsonDecode(rewardedRaw)));

    debugPrint(
      '[UserState] Загружено: $_points баллов, '
      '${_rewardedTests.length} вознаграждённых тестов',
    );
  }

  
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_points', _points);
    await prefs.setString('rewarded_tests', jsonEncode(_rewardedTests));
  }


  Future<void> addPoints(int amount, String testId) async {
    if (!wasRewarded(testId)) {
      _points += amount;
      _rewardedTests[testId] = true;
      await _saveToPrefs();
      notifyListeners();

      debugPrint('[UserState] +$amount баллов за тест "$testId"');
    }
  }

  
  Future<void> spendPoints(int amount, String itemId) async {
    if (_points >= amount) {
      _points -= amount;

      final qrData = 'item_${itemId}_${DateTime.now().millisecondsSinceEpoch}';
      await _dbHelper.purchaseItem(itemId, qrData);

      await _saveToPrefs();
      notifyListeners();

      debugPrint('[UserState] -$amount баллов за "$itemId" | QR: $qrData');
    } else {
      debugPrint('[UserState] Недостаточно баллов для покупки "$itemId"');
    }
  }

  // // --- Отметка товара как выданного ---
  // Future<void> markItemAsIssued(String qrData) async {
  //   await _dbHelper.markItemAsIssued(qrData);
  //   notifyListeners();

  //   debugPrint('[UserState] Товар по QR "$qrData" выдан');
  // }

  // --- Получение списка купленных товаров ---
  Future<List<ShopItem>> getPurchasedItems() async {
    try {
      final items = await _dbHelper.getUserPurchasedItems();
      debugPrint('[UserState] Загружено ${items.length} покупок');
      return items;
    } catch (e) {
      debugPrint('[UserState] Ошибка загрузки покупок: $e');
      return [];
    }
  }


  Future<String> getUserQrData() async {
    final items = await getPurchasedItems();
    if (items.isEmpty) return '';

    final purchaseData = items.map((e) => e.id).join(',');
    return 'user_${DateTime.now().millisecondsSinceEpoch}_$purchaseData';
  }

  
  Future<void> applyForAccelerator(String acceleratorId) async {
    try {
      await _dbHelper.applyForAccelerator(acceleratorId);
      notifyListeners();
      debugPrint(
        '[UserState] Заявка на акселератор "$acceleratorId" отправлена',
      );
    } catch (e) {
      debugPrint('[UserState] Ошибка подачи заявки: $e');
      rethrow;
    }
  }

 
  Future<List<AcceleratorApplication>> getApplications() async {
    return await _dbHelper.getUserApplications();
  }

  
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _points = 0;
    _rewardedTests.clear();
    notifyListeners();

    debugPrint('[UserState] Прогресс пользователя сброшен');
  }

 
  void printDebugInfo() {
    debugPrint('[UserState] Текущие баллы: $_points');
    debugPrint(
      '[UserState] Пройденные тесты: ${_rewardedTests.keys.join(', ')}',
    );
  }
}
