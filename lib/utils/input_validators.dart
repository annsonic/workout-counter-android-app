class InputValidators {
  /// 檢查輸入是否在 [min, max] 範圍內的整數，回傳是否有效
  static bool isValid(String text, int min, int max) {
    final int? val = int.tryParse(text);
    if (val == null) return false;
    return val >= min && val <= max;
  }

  /// 將字串轉為整數並限制在 [min, max] 範圍內
  static int clamp(String text, int min, int max) {
    int? val = int.tryParse(text);
    val ??= min;
    if (val < min) val = min;
    if (val > max) val = max;
    return val;
  }
}
