import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/modals/app_modals/categories_data.dart';

class CategoriesProvider with ChangeNotifier {
  List<CategoryData> _categories = [];

  // Getter for categories
  List<CategoryData> get categories => _categories;

  // Setter for categories
  void setCategories(List<CategoryData> categoriesList) {
    _categories = categoriesList;
    notifyListeners(); // Notify listeners about the update
  }

  // Add a category
  void addCategory(CategoryData category) {
    _categories.add(category);
    notifyListeners();
  }

  // Remove a category
  void removeCategory(String categoryId) {
    _categories.removeWhere((category) => category.categoryId == categoryId);
    notifyListeners();
  }

  // Clear all categories
  void clearCategories() {
    _categories = [];
    notifyListeners();
  }
}
