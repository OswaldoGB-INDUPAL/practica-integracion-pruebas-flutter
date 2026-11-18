String? validateTitle(String? value) {
  final title = (value ?? '').trim();
  if (title.length < 3 || title.length > 80) {
    return 'El título debe tener entre 3 y 80 caracteres.';
  }
  return null;
}

String? validateDescription(String? value) {
  if ((value ?? '').length > 500) {
    return 'La descripción no puede superar 500 caracteres.';
  }
  return null;
}
