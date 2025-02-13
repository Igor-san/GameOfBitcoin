import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

extension EitherX<L, R> on Either<L, R> {
  R asRight() => (this as Right).value;
  L asLeft() => (this as Left).value;
}

extension DoubleExtension on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

@immutable
class MyColors extends ThemeExtension<MyColors> {
  const MyColors({
    required this.brandColor,
    required this.errorColor,
    required this.successColor,
  });

  final Color? brandColor;
  final Color? errorColor;
  final Color? successColor;

  @override
  MyColors copyWith({Color? brandColor, Color? errorColor, Color? successColor}) {
    return MyColors(
      brandColor: brandColor ?? this.brandColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
    );
  }

  @override
  MyColors lerp(MyColors? other, double t) {
    if (other is! MyColors) {
      return this;
    }
    return MyColors(
      brandColor: Color.lerp(brandColor, other.brandColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      successColor: Color.lerp(successColor, other.successColor, t),
    );
  }

  // Optional
  @override
  String toString() => 'MyColors(brandColor: $brandColor, errorColor: $errorColor, successColor: $successColor)';
}
