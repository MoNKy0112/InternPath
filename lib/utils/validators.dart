/// Validador que filtra los campos permitidos para actualizar una colección
/// y agrega un campo `updatedAt` con la fecha actual en milisegundos.
/// Lanza una excepción si no hay campos válidos para actualizar.
/// Ejemplo de uso:
/// ```dart
/// final data = {'fullName': 'Nuevo Nombre', 'invalidField': 'valor'};
/// final allowedFields = {'fullName', 'age', 'bio', 'profilePicture'};
/// final filteredData = filterAllowedFields(data, allowedFields);
/// ```
/// // Luego usar filteredData para actualizar la colección.
Map<String, dynamic> filterAllowedFields(
  Map<String, dynamic> data,
  Set<String> allowedFields,
) {
  final filtered = <String, dynamic>{};

  for (final entry in data.entries) {
    if (allowedFields.contains(entry.key)) {
      filtered[entry.key] = entry.value;
    }
  }

  if (filtered.isEmpty) {
    throw Exception('No valid fields to update');
  }

  // Siempre agregamos updatedAt
  filtered['updatedAt'] = DateTime.now();

  return filtered;
}
