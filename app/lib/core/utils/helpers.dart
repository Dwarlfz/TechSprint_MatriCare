String displayNameFromEmail(String? email) {
  if (email == null) return "Mother";
  return email.split('@').first;
}
