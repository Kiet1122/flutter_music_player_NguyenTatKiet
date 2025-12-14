import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:io';

class ColorExtractor {
  static Future<Color> extractDominantColor(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return const Color(0xFF1DB954);
      }

      final Uint8List bytes = await imageFile.readAsBytes();
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        MemoryImage(bytes),
        size: const Size(100, 100),
      );

      return paletteGenerator.dominantColor?.color ?? const Color(0xFF1DB954);
    } catch (e) {
      print('Error extracting color: $e');
      return const Color(0xFF1DB954);
    }
  }

  static Future<List<Color>> extractColorPalette(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return [
          const Color(0xFF1DB954),
          const Color(0xFF191414),
          const Color(0xFF282828),
        ];
      }

      final Uint8List bytes = await imageFile.readAsBytes();
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        MemoryImage(bytes),
        size: const Size(100, 100),
      );

      final List<Color> colors = [];
      
      if (paletteGenerator.dominantColor != null) {
        colors.add(paletteGenerator.dominantColor!.color);
      }
      
      if (paletteGenerator.vibrantColor != null) {
        colors.add(paletteGenerator.vibrantColor!.color);
      }
      
      if (paletteGenerator.mutedColor != null) {
        colors.add(paletteGenerator.mutedColor!.color);
      }
      
      if (paletteGenerator.darkMutedColor != null) {
        colors.add(paletteGenerator.darkMutedColor!.color);
      }

      while (colors.length < 3) {
        colors.add(const Color(0xFF1DB954));
      }

      return colors;
    } catch (e) {
      print('Error extracting color palette: $e');
      return [
        const Color(0xFF1DB954),
        const Color(0xFF191414),
        const Color(0xFF282828),
      ];
    }
  }

  static Color getContrastingTextColor(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  static List<Color> generateGradient(Color baseColor, {int steps = 5}) {
    final List<Color> gradient = [];
    
    for (int i = 0; i < steps; i++) {
      final double amount = i / (steps - 1);
      final Color color = Color.lerp(
        darken(baseColor, 0.4),
        lighten(baseColor, 0.4),
        amount,
      )!;
      gradient.add(color);
    }
    
    return gradient;
  }

  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  static ThemeData getThemeForBackground(Color backgroundColor) {
    final bool isDark = backgroundColor.computeLuminance() < 0.5;
    
    return isDark
        ? ThemeData.dark()
        : ThemeData.light();
  }
}