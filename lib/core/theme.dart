import 'package:flutter/material.dart';

@immutable
class MyTheme extends ThemeExtension<MyTheme> {
  const MyTheme({
    required this.sidebarSurface,
  });

  final Color? sidebarSurface;

  @override
  MyTheme copyWith({Color? sidebarSurface}) {
    return MyTheme(
      sidebarSurface: sidebarSurface ?? this.sidebarSurface,
    );
  }

  @override
  MyTheme lerp(MyTheme? other, double t) {
    return MyTheme(
      sidebarSurface: Color.lerp(sidebarSurface, other?.sidebarSurface, t)!,
    );
  }
}