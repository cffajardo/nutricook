bool isValidEmail(String email) {
  if (email.trim().isEmpty) return false;
  final pattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return pattern.hasMatch(email.trim());
}

bool looksLikeEmail(String input) {
  return input.trim().contains('@');
}

bool isValidPassword(String password) {
  final passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[^\s]{6,}$',
  );

  return passwordRegex.hasMatch(password);
}

bool isValidUsername(String username) {
  final trimmed = username.trim();
  final usernameRegex = RegExp(r'^[A-Za-z0-9_]{3,}$');

  return trimmed.isNotEmpty && usernameRegex.hasMatch(trimmed);
}

