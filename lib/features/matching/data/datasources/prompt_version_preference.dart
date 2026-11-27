import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user-selected / auto-optimized matching prompt version.
class PromptVersionPreference {
  PromptVersionPreference(this._prefs);

  final SharedPreferences _prefs;

  static const key = 'matching_preferred_prompt_version';

  String? read() {
    final value = _prefs.getString(key)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> write(String version) async {
    final trimmed = version.trim();
    if (trimmed.isEmpty) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setString(key, trimmed);
  }
}
