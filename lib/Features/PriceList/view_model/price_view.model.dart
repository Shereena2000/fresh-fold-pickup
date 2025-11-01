import 'package:flutter/material.dart';

import '../repository/price_reposiotory.dart';
import '../model/price_item_model.dart';

class PriceViewModel extends ChangeNotifier {
  final PriceRepository _repository = PriceRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Map<String, List<PriceItemModel>> _categoryItems = {
    'regular': [],
    'express': [],
    'premium': [],
  };

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  
  List<PriceItemModel> getItemsForCategory(String category) {
    return _categoryItems[category] ?? [];
  }

  // ==================== LOAD ITEMS ====================

  Future<void> loadCategoryItems(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categoryItems[category] = await _repository.getCategoryItems(category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load items: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        loadCategoryItems('regular'),
        loadCategoryItems('express'),
        loadCategoryItems('premium'),
      ]);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== STREAM ITEMS ====================

  Stream<List<PriceItemModel>> streamCategoryItems(String category) {
    return _repository.streamCategoryItems(category);
  }

  // ==================== SAVE ITEM ====================

  Future<bool> savePriceItem(String category, PriceItemModel item) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.savePriceItem(category, item);
      _successMessage = item.itemId.isEmpty 
          ? 'Item added successfully' 
          : 'Item updated successfully';
      
      // Reload items
      await loadCategoryItems(category);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save item: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== DELETE ITEM ====================

  Future<bool> deletePriceItem(String category, String itemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deletePriceItem(category, itemId);
      
      // Remove from local list
      _categoryItems[category]?.removeWhere((item) => item.itemId == itemId);
      
      _successMessage = 'Item deleted successfully';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete item: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== REORDER ITEMS ====================

  Future<bool> reorderItems(String category, List<PriceItemModel> newOrder) async {
    try {
      await _repository.batchUpdateOrders(category, newOrder);
      _categoryItems[category] = newOrder;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reorder items: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ==================== INITIALIZE DEFAULT DATA ====================

  Future<void> initializeDefaults() async {
    try {
      await Future.wait([
        _repository.initializeDefaultItems('regular'),
        _repository.initializeDefaultItems('express'),
        _repository.initializeDefaultItems('premium'),
      ]);
      await loadAllCategories();
    } catch (e) {
      _errorMessage = 'Failed to initialize: ${e.toString()}';
      notifyListeners();
    }
  }

  // ==================== UTILITY METHODS ====================

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'regular':
        return 'Regular (2-3 Days)';
      case 'express':
        return 'Express (24 Hours)';
      case 'premium':
        return 'Premium (Same Day)';
      default:
        return category;
    }
  }
}