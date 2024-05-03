import "package:flutter/material.dart";
import "package:talk/ui/scheme.ext.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4287580748),
      surfaceTint: Color(4287580748),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4294957785),
      onPrimaryContainer: Color(4282058766),
      secondary: Color(4286010966),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4294957785),
      onSecondaryContainer: Color(4281079061),
      tertiary: Color(4287384159),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294957538),
      onTertiaryContainer: Color(4281992989),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      background: Color(4294965495),
      onBackground: Color(4280424729),
      surface: Color(4294965495),
      onSurface: Color(4280424729),
      surfaceVariant: Color(4294237661),
      onSurfaceVariant: Color(4283581251),
      outline: Color(4286935922),
      outlineVariant: Color(4292329921),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281871918),
      inverseOnSurface: Color(4294962668),
      inversePrimary: Color(4294947763),
      primaryFixed: Color(4294957785),
      onPrimaryFixed: Color(4282058766),
      primaryFixedDim: Color(4294947763),
      onPrimaryFixedVariant: Color(4285739830),
      secondaryFixed: Color(4294957785),
      onSecondaryFixed: Color(4281079061),
      secondaryFixedDim: Color(4293311932),
      onSecondaryFixedVariant: Color(4284301119),
      tertiaryFixed: Color(4294957538),
      onTertiaryFixed: Color(4281992989),
      tertiaryFixedDim: Color(4294947271),
      onTertiaryFixedVariant: Color(4285543240),
      surfaceDim: Color(4293449429),
      surfaceBright: Color(4294965495),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963440),
      surfaceContainer: Color(4294765289),
      surfaceContainerHigh: Color(4294370531),
      surfaceContainerHighest: Color(4293975774),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4285411122),
      surfaceTint: Color(4287580748),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4289355617),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4283972411),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4287589484),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4285214532),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4289093494),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294965495),
      onBackground: Color(4280424729),
      surface: Color(4294965495),
      onSurface: Color(4280424729),
      surfaceVariant: Color(4294237661),
      onSurfaceVariant: Color(4283318079),
      outline: Color(4285291355),
      outlineVariant: Color(4287198838),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281871918),
      inverseOnSurface: Color(4294962668),
      inversePrimary: Color(4294947763),
      primaryFixed: Color(4289355617),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4287448906),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4287589484),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4285813844),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4289093494),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4287186781),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4293449429),
      surfaceBright: Color(4294965495),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963440),
      surfaceContainer: Color(4294765289),
      surfaceContainerHigh: Color(4294370531),
      surfaceContainerHighest: Color(4293975774),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4282650388),
      surfaceTint: Color(4287580748),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4285411122),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281604892),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4283972411),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4282519075),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4285214532),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294965495),
      onBackground: Color(4280424729),
      surface: Color(4294965495),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4294237661),
      onSurfaceVariant: Color(4281213217),
      outline: Color(4283318079),
      outlineVariant: Color(4283318079),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281871918),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4294960870),
      primaryFixed: Color(4285411122),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4283570461),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4283972411),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4282394150),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4285214532),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4283439406),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4293449429),
      surfaceBright: Color(4294965495),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963440),
      surfaceContainer: Color(4294765289),
      surfaceContainerHigh: Color(4294370531),
      surfaceContainerHighest: Color(4293975774),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294947763),
      surfaceTint: Color(4294947763),
      onPrimary: Color(4283833633),
      primaryContainer: Color(4285739830),
      onPrimaryContainer: Color(4294957785),
      secondary: Color(4293311932),
      onSecondary: Color(4282657066),
      secondaryContainer: Color(4284301119),
      onSecondaryContainer: Color(4294957785),
      tertiary: Color(4294947271),
      onTertiary: Color(4283702577),
      tertiaryContainer: Color(4285543240),
      onTertiaryContainer: Color(4294957538),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279898385),
      onBackground: Color(4293975774),
      surface: Color(4279898385),
      onSurface: Color(4293975774),
      surfaceVariant: Color(4283581251),
      onSurfaceVariant: Color(4292329921),
      outline: Color(4288711820),
      outlineVariant: Color(4283581251),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293975774),
      inverseOnSurface: Color(4281871918),
      inversePrimary: Color(4287580748),
      primaryFixed: Color(4294957785),
      onPrimaryFixed: Color(4282058766),
      primaryFixedDim: Color(4294947763),
      onPrimaryFixedVariant: Color(4285739830),
      secondaryFixed: Color(4294957785),
      onSecondaryFixed: Color(4281079061),
      secondaryFixedDim: Color(4293311932),
      onSecondaryFixedVariant: Color(4284301119),
      tertiaryFixed: Color(4294957538),
      onTertiaryFixed: Color(4281992989),
      tertiaryFixedDim: Color(4294947271),
      onTertiaryFixedVariant: Color(4285543240),
      surfaceDim: Color(4279898385),
      surfaceBright: Color(4282529590),
      surfaceContainerLowest: Color(4279503884),
      surfaceContainerLow: Color(4280424729),
      surfaceContainer: Color(4280753437),
      surfaceContainerHigh: Color(4281477159),
      surfaceContainerHighest: Color(4282200626),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294949305),
      surfaceTint: Color(4294947763),
      onPrimary: Color(4281598729),
      primaryContainer: Color(4291525244),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4293640640),
      onSecondary: Color(4280684560),
      secondaryContainer: Color(4289562759),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294948811),
      onTertiary: Color(4281532951),
      tertiaryContainer: Color(4291197842),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279898385),
      onBackground: Color(4293975774),
      surface: Color(4279898385),
      onSurface: Color(4294965753),
      surfaceVariant: Color(4283581251),
      onSurfaceVariant: Color(4292658885),
      outline: Color(4289896094),
      outlineVariant: Color(4287725438),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293975774),
      inverseOnSurface: Color(4281477159),
      inversePrimary: Color(4285805623),
      primaryFixed: Color(4294957785),
      onPrimaryFixed: Color(4281073925),
      primaryFixedDim: Color(4294947763),
      onPrimaryFixedVariant: Color(4284359462),
      secondaryFixed: Color(4294957785),
      onSecondaryFixed: Color(4280290059),
      secondaryFixedDim: Color(4293311932),
      onSecondaryFixedVariant: Color(4283051823),
      tertiaryFixed: Color(4294957538),
      onTertiaryFixed: Color(4281008146),
      tertiaryFixedDim: Color(4294947271),
      onTertiaryFixedVariant: Color(4284228151),
      surfaceDim: Color(4279898385),
      surfaceBright: Color(4282529590),
      surfaceContainerLowest: Color(4279503884),
      surfaceContainerLow: Color(4280424729),
      surfaceContainer: Color(4280753437),
      surfaceContainerHigh: Color(4281477159),
      surfaceContainerHighest: Color(4282200626),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294965753),
      surfaceTint: Color(4294947763),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4294949305),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294965753),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4293640640),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965753),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4294948811),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279898385),
      onBackground: Color(4293975774),
      surface: Color(4279898385),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4283581251),
      onSurfaceVariant: Color(4294965753),
      outline: Color(4292658885),
      outlineVariant: Color(4292658885),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293975774),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4283307803),
      primaryFixed: Color(4294959327),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4294949305),
      onPrimaryFixedVariant: Color(4281598729),
      secondaryFixed: Color(4294959327),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4293640640),
      onSecondaryFixedVariant: Color(4280684560),
      tertiaryFixed: Color(4294959078),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4294948811),
      onTertiaryFixedVariant: Color(4281532951),
      surfaceDim: Color(4279898385),
      surfaceBright: Color(4282529590),
      surfaceContainerLowest: Color(4279503884),
      surfaceContainerLow: Color(4280424729),
      surfaceContainer: Color(4280753437),
      surfaceContainerHigh: Color(4281477159),
      surfaceContainerHighest: Color(4282200626),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
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
