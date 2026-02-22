/// Validates that [email] matches a standard email format.
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
