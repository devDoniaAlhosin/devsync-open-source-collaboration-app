String formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }

  return value < 0 ? '-$buffer' : buffer.toString();
}

String compactNumber(int value) {
  if (value >= 1000000) {
    final number = value / 1000000;
    return '${_trimZero(number)}m';
  }
  if (value >= 1000) {
    final number = value / 1000;
    return '${_trimZero(number)}k';
  }
  return '$value';
}

String pluralize(int count, String singular, [String? plural]) {
  return count == 1 ? singular : (plural ?? '${singular}s');
}

String _trimZero(double value) {
  final fixed = value.toStringAsFixed(value >= 10 ? 0 : 1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}
