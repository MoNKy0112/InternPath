import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late final AuthProvider authProvider;
  late final AuthUseCases authUseCase;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();

  bool _editingName = false;
  bool _saving = false;

  late String uid;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    authUseCase = context.read<AuthUseCases>();
    final user = authProvider.currentUser;
    uid = user?.uid ?? '';

    // inicializar desde domainUser si ya está cargado
    final domainUser = authProvider.domainUser;
    if (domainUser != null) {
      _fullNameController.text = domainUser.fullName;
    }

    // escuchar cambios en provider para actualizar UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // si domainUser cambia más adelante, actualizar nombre en controller si no está en edición
      authProvider.addListener(_onAuthProviderChanged);
    });
  }

  void _onAuthProviderChanged() {
    final domainUser = authProvider.domainUser;
    if (domainUser != null && !_editingName) {
      _fullNameController.text = domainUser.fullName;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    authProvider.removeListener(_onAuthProviderChanged);
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _fullNameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await authUseCase.updateProfile(uid, {'fullName': newName});
      // refrescar dominio
      await authProvider.refreshDomainUser();
      if (!mounted) return;
      setState(() {
        _editingName = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar nombre: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancelEdit() {
    final domainUser = authProvider.domainUser;
    _fullNameController.text = domainUser?.fullName ?? '';
    setState(() {
      _editingName = false;
    });
  }

  ImageProvider<Object> _avatarProvider() {
    final domainUser = authProvider.domainUser;
    final fullName = domainUser?.fullName ?? 'User';
    final photoUrl = domainUser?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CachedNetworkImageProvider(photoUrl);
    }
    final url =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=0D8ABC&color=fff&size=256';
    return CachedNetworkImageProvider(url);
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final domainUser = context.watch<AuthProvider>().domainUser;

    if (domainUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: avatar + basic info
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: CachedNetworkImage(
                      imageUrl:
                          (_avatarProvider() as CachedNetworkImageProvider).url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre editable inline (reemplazado para mejor visualización)
                      _editingName
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _fullNameController,
                                  style: const TextStyle(fontSize: 18),
                                  minLines: 1,
                                  maxLines:
                                      2, // permite nombres largos en 2 líneas
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      tooltip: 'Guardar',
                                      onPressed: _saving ? null : _saveName,
                                      icon: _saving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      tooltip: 'Cancelar',
                                      onPressed: _saving ? null : _cancelEdit,
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    domainUser.fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Editar nombre',
                                  onPressed: () {
                                    setState(() {
                                      _editingName = true;
                                      _fullNameController.text =
                                          domainUser.fullName;
                                    });
                                  },
                                  icon: const Icon(Icons.edit, size: 20),
                                ),
                              ],
                            ),
                      const SizedBox(height: 6),
                      Text(
                        domainUser.email,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 6),
                      Chip(
                        label: Text(
                          domainUser.role
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Detalle completo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(
                        width: 8,
                        child: Icon(Icons.calendar_today, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Creado:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_formatDate(domainUser.createdAt))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(
                        width: 8,
                        child: Icon(Icons.update, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Actualizado:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_formatDate(domainUser.updatedAt))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Acciones adicionales
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Forzar refresh de user domain
                      await authProvider.refreshDomainUser();
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Datos actualizados')),
                        );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refrescar datos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // permitir al usuario salir de edición si está en pantalla (fallback)
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar'),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
