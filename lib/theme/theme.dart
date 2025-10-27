import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff415f91),
      surfaceTint: Color(0xff415f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd6e3ff),
      onPrimaryContainer: Color(0xff274777),
      secondary: Color(0xff7f570f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffddb1),
      onSecondaryContainer: Color(0xff624000),
      tertiary: Color(0xff28638a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffcae6ff),
      onTertiaryContainer: Color(0xff004b70),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff1a1c20),
      onSurfaceVariant: Color(0xff44474e),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff274777),
      secondaryFixed: Color(0xffffddb1),
      onSecondaryFixed: Color(0xff291800),
      secondaryFixedDim: Color(0xfff3bd6e),
      onSecondaryFixedVariant: Color(0xff624000),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff001e30),
      tertiaryFixedDim: Color(0xff96ccf8),
      onTertiaryFixedVariant: Color(0xff004b70),
      surfaceDim: Color(0xffd9d9e0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe8e7ee),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff133665),
      surfaceTint: Color(0xff415f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff506da0),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff4c3100),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff8f651e),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003a58),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3a7299),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff0f1116),
      onSurfaceVariant: Color(0xff33363e),
      outline: Color(0xff4f525a),
      outlineVariant: Color(0xff6a6d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff506da0),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff375586),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff8f651e),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff734d04),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff3a7299),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff1b5980),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc6c6cd),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffe8e7ee),
      surfaceContainerHigh: Color(0xffdcdce3),
      surfaceContainerHighest: Color(0xffd1d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff032b5b),
      surfaceTint: Color(0xff415f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff2a497a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3e2700),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff654200),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff002f49),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff044e73),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292c33),
      outlineVariant: Color(0xff464951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff2a497a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0e3262),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff654200),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff472d00),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff044e73),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003652),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb8b8bf),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f0f7),
      surfaceContainer: Color(0xffe2e2e9),
      surfaceContainerHigh: Color(0xffd4d4db),
      surfaceContainerHighest: Color(0xffc6c6cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffaac7ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff0a305f),
      primaryContainer: Color(0xff274777),
      onPrimaryContainer: Color(0xffd6e3ff),
      secondary: Color(0xfff3bd6e),
      onSecondary: Color(0xff442b00),
      secondaryContainer: Color(0xff624000),
      onSecondaryContainer: Color(0xffffddb1),
      tertiary: Color(0xff96ccf8),
      onTertiary: Color(0xff00344f),
      tertiaryContainer: Color(0xff004b70),
      onTertiaryContainer: Color(0xffcae6ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff111318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc4c6d0),
      outline: Color(0xff8e9099),
      outlineVariant: Color(0xff44474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff415f91),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff274777),
      secondaryFixed: Color(0xffffddb1),
      onSecondaryFixed: Color(0xff291800),
      secondaryFixedDim: Color(0xfff3bd6e),
      onSecondaryFixedVariant: Color(0xff624000),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff001e30),
      tertiaryFixedDim: Color(0xff96ccf8),
      onTertiaryFixedVariant: Color(0xff004b70),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff1a1c20),
      surfaceContainer: Color(0xff1e2025),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcdddff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff002551),
      primaryContainer: Color(0xff7491c7),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd69d),
      onSecondary: Color(0xff362100),
      secondaryContainer: Color(0xffb7883f),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffbee0ff),
      onTertiary: Color(0xff00283f),
      tertiaryContainer: Color(0xff6096bf),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadce6),
      outline: Color(0xffafb2bb),
      outlineVariant: Color(0xff8e9099),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff294878),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff00112b),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff133665),
      secondaryFixed: Color(0xffffddb1),
      onSecondaryFixed: Color(0xff1b0f00),
      secondaryFixedDim: Color(0xfff3bd6e),
      onSecondaryFixedVariant: Color(0xff4c3100),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff001320),
      tertiaryFixedDim: Color(0xff96ccf8),
      onTertiaryFixedVariant: Color(0xff003a58),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff43444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1c1e22),
      surfaceContainer: Color(0xff26282d),
      surfaceContainerHigh: Color(0xff313238),
      surfaceContainerHighest: Color(0xff3c3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffebf0ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa6c3fc),
      onPrimaryContainer: Color(0xff000b20),
      secondary: Color(0xffffedd9),
      onSecondary: Color.fromARGB(255, 10, 3, 71),
      secondaryContainer: Color(0xffefb96b),
      onSecondaryContainer: Color.fromARGB(255, 10, 3, 71),
      tertiary: Color(0xffe5f1ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff93c8f4),
      onTertiaryContainer: Color(0xff000d18),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeeeff9),
      outlineVariant: Color(0xffc0c2cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff294878),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff00112b),
      secondaryFixed: Color(0xffffddb1),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xfff3bd6e),
      onSecondaryFixedVariant: Color(0xff1b0f00),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff96ccf8),
      onTertiaryFixedVariant: Color(0xff001320),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff4e5056),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1e2025),
      surfaceContainer: Color(0xff2e3036),
      surfaceContainerHigh: Color(0xff393b41),
      surfaceContainerHighest: Color(0xff45474c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


ThemeData theme(ColorScheme colorScheme) => ThemeData(
  useMaterial3: true,
  brightness: colorScheme.brightness,
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.surface,
  canvasColor: colorScheme.surface,
  textTheme: textTheme.apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.onPrimary,
    iconTheme: IconThemeData(color: colorScheme.onPrimary),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: colorScheme.surface,
    selectedItemColor: colorScheme.primary,
    unselectedItemColor: Color(0xff415f91).withValues(alpha: 128) // equivalente a 0.5 de opacidad,
  ),
);


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}