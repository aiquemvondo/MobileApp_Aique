import 'package:flutter/foundation.dart' hide Category;
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class ExpenseProvider with ChangeNotifier {
  final LocalStorage storage;
  // List of expenses
  List<Expense> _expenses = [];
  List<Subcategory> _subcategorys = [];
  List<Category> _categorys = [];

  // List of categories
  

  // Getters
  List<Expense> get expenses => _expenses;
  List<Category> get categorys => _categorys;
  List<Subcategory> get subcategorys => _subcategorys;

  ExpenseProvider(this.storage) {
    _loadCategorysFromStorage();
    _loadSubcategorysFromStorage();
    _loadExpensesFromStorage();
  }

  void _loadExpensesFromStorage() {
  var storedExpenses = storage.getItem('expenses');
  if (storedExpenses != null) {
    final List<dynamic> decoded = jsonDecode(storedExpenses);
    _expenses = decoded
        .map((item) => Expense.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
  }
  else
  {
    _saveExpensesToStorage();
  }

}

void _loadCategorysFromStorage() {
  var storedCategorys = storage.getItem('categorys');
  if (storedCategorys != null) {
    final List<dynamic> decoded = jsonDecode(storedCategorys);
    _categorys = decoded
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
  }
  else
  {
      storage.setItem(
        'categorys',
        jsonEncode(_categorys.map((p) => p.toJson()).toList()),
      );
  }
}

void _loadSubcategorysFromStorage() {
  var storedSubcategorys = storage.getItem('subcategorys');
  if (storedSubcategorys != null) {
    final List<dynamic> decoded = jsonDecode(storedSubcategorys);
    _subcategorys = decoded
        .map((item) => Subcategory.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
  }
  else
  {
      storage.setItem(
        'subcategorys',
        jsonEncode(_subcategorys.map((t) => t.toJson()).toList()),
      );
  }
}

  // Add an expense
  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveExpensesToStorage();
    notifyListeners();
  }

 void _saveExpensesToStorage() {
  storage.setItem(
    'expenses',
    jsonEncode(_expenses.map((e) => e.toJson()).toList()),
  );
}

  void addOrUpdateExpenses(Expense expense) {
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      // Update existing expense
      _expenses[index] = expense;
    } else {
      // Add new time entry
      _expenses.add(expense);
    }
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Delete an expense
  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Add a category
  void addCategory(Category category) {
    if (!_categorys.any((p) => p.name == category.name)) {
      _categorys.add(category);
      storage.setItem(
        'categorys',
        jsonEncode(_categorys.map((p) => p.toJson()).toList()),
      );
      notifyListeners();
    }
  }

  //add subcategorys
  void addSubcategory(Subcategory subcategory) {
    if (!_subcategorys.any((t) => t.name == subcategory.name)) {
      _subcategorys.add(subcategory);
      storage.setItem(
        'subcategorys',
        jsonEncode(_subcategorys.map((t) => t.toJson()).toList()),
      );
      notifyListeners();
    }
  }

  // Delete a category
  void deleteCategory(String id) {
    _categorys.removeWhere((category) => category.id == id);
    notifyListeners();
  }

  // Delete a tag
  void deleteSubcategory(String id) {
    _subcategorys.removeWhere((subcategory) => subcategory.id == id);
    notifyListeners();
  }

  int _nextId(Iterable<String> ids) {
    var maxId = -1;
    for (final id in ids) {
      final parsed = int.tryParse(id);
      if (parsed != null && parsed > maxId) maxId = parsed;
    }
    return maxId + 1;
  }

  int generateCategoryId() {
    return categorys.length;
  }

  int generateSubcategoryId() {
    return subcategorys.length;
  }

  int generateExpenseId() {
    return _nextId(expenses.map((e) => e.id));
  }

}
