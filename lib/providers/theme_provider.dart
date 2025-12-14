import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.dark;
  Color _primaryColor = const Color(0xFF1DB954);
  Color _backgroundColor = const Color(0xFF191414);
  Color _cardColor = const Color(0xFF282828);
  Color _textColor = Colors.white;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Color get backgroundColor => _backgroundColor;
  Color get cardColor => _cardColor;
  Color get textColor => _textColor;

  ThemeData get darkTheme => ThemeData.dark().copyWith(
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _backgroundColor,
    cardColor: _cardColor,
    appBarTheme: AppBarTheme(
      backgroundColor: _backgroundColor,
      foregroundColor: _textColor,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.grey),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: Colors.grey[800],
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _backgroundColor,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  ThemeData get lightTheme => ThemeData.light().copyWith(
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: Colors.grey[100],
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      titleLarge: TextStyle(color: Colors.black),
      titleMedium: TextStyle(color: Colors.black),
      titleSmall: TextStyle(color: Colors.grey),
    ),
    iconTheme: const IconThemeData(color: Colors.black54),
    dividerColor: Colors.grey[300],
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      print('Error saving theme: $e');
    }
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      print('Error saving theme: $e');
    }
    
    notifyListeners();
  }

  void updatePrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void updateBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  Future<void> resetTheme() async {
    _primaryColor = const Color(0xFF1DB954);
    _backgroundColor = const Color(0xFF191414);
    _cardColor = const Color(0xFF282828);
    _textColor = Colors.white;
    _themeMode = ThemeMode.dark;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      print('Error saving theme: $e');
    }
    
    notifyListeners();
  }
}