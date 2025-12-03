import 'package:flutter/material.dart';
import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/usecases/company_usecases.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:provider/provider.dart';
import 'package:internpath/domain/entities/request.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:internpath/domain/usecases/request_usecases.dart';
import 'package:go_router/go_router.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  Request? _request;
  bool _loading = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() => _loading = true);
    try {
      final usecases = context.read<RequestUseCases>();
      final r = await usecases.getRequestById(widget.requestId);
      if (!mounted) return;
      setState(() {
        _request = r;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando solicitud: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _accept() async {
    if (_request == null) return;
    setState(() => _processing = true);
    try {
      final usecases = context.read<RequestUseCases>();
      // Intentamos actualizar el estado en backend / repo.
      try {
        if (_request!.type == RequestType.companySuggestion) {
          await _acceptCompanySuggestion(
            data: _request!.data,
            userId: _request!.userId,
          );
        }
      } catch (e) {
        // manejar error específico si es necesario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar sugerencia: $e')),
        );
        return;
      }
      // Ajusta el método a la firma concreta de RequestUseCases (p. ej. updateRequestStatus o approveRequest).
      await usecases.updateRequestStatus(
        widget.requestId,
        RequestStatus.approved,
      );
      if (!mounted) return;
      setState(() {
        _request = Request(
          id: _request!.id,
          userId: _request!.userId,
          userName: _request!.userName,
          modderId: _request!.modderId,
          type: _request!.type,
          status: RequestStatus.approved,
          data: _request!.data,
          createdAt: _request!.createdAt,
          updatedAt: DateTime.now(),
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud aprobada')));
      // aquí iría el flujo según tipo de solicitud (se trabajará luego)
      GoRouter.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al aprobar: $e')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _acceptCompanySuggestion({
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    // lógica específica para aceptar sugerencia de empresa
    final experienceId = data['experienceId'];
    final companyName = data['companyName'];

    final companyUseCases = context.read<CompanyUseCases>();
    final experienceUseCases = context.read<ExperienceUseCases>();
    try {
      Company company = Company(
        id: '', // se asignará en el backend
        name: companyName,
      );
      // Suponiendo que hay un método para agregar empresa
      final newCompanyId = await companyUseCases.addCompany(company);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Empresa "$companyName" agregada exitosamente')),
      );

      Experience? experience = await experienceUseCases.getExperienceById(
        experienceId,
      );
      if (experience == null) {
        throw Exception('Experiencia no encontrada');
      }
      final newExperience = Experience(
        id: experience.id,
        userId: experience.userId,
        companyId: newCompanyId, // vincular nueva empresa
        salary: experience.salary,
        startDate: experience.startDate,
        endDate: experience.endDate,
        flexSchedule: experience.flexSchedule,
        continueOption: experience.continueOption,
        description: experience.description,
        positionTitle: experience.positionTitle,
      );

      //actualizar experiencia para vincularla a la nueva empresa
      await experienceUseCases.updateExperience(
        userId,
        experienceId,
        newExperience,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al agregar empresa: $e')));
      rethrow;
    }
  }

  Future<void> _reject() async {
    if (_request == null) return;
    setState(() => _processing = true);
    try {
      // Por ahora solo actualizamos visualmente y notificamos.
      final usecases = context.read<RequestUseCases>();
      await usecases.updateRequestStatus(
        widget.requestId,
        RequestStatus.rejected,
      );
      if (!mounted) return;
      setState(() {
        _request = Request(
          id: _request!.id,
          userId: _request!.userId,
          userName: _request!.userName,
          modderId: _request!.modderId,
          type: _request!.type,
          status: RequestStatus.rejected,
          data: _request!.data,
          createdAt: _request!.createdAt,
          updatedAt: DateTime.now(),
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud rechazada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al rechazar: $e')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isModder = auth.isModder;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // preferir Navigator.pop
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              GoRouter.of(context).go('/');
            }
          },
        ),
        title: const Text('Detalle de solicitud'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _request == null
          ? Center(child: Text('Solicitud no encontrada'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _request!.type
                                .toString()
                                .split('.')
                                .last
                                .replaceAllMapped(
                                  RegExp(r'([A-Z])'),
                                  (m) => ' ${m[0]}',
                                )
                                .trim(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(child: const Icon(Icons.person)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _request!.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'User ID: ${_request!.userId}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Chip(
                                label: Text(
                                  _request!.status
                                      .toString()
                                      .split('.')
                                      .last
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                backgroundColor:
                                    _request!.status == RequestStatus.pending
                                    ? Colors.grey.shade100
                                    : _request!.status == RequestStatus.approved
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          if (_request!.data.isNotEmpty)
                            ..._request!.data.entries.map(
                              (e) => _buildDataRow(
                                e.key,
                                e.value?.toString() ?? '',
                              ),
                            ),
                          const SizedBox(height: 8),
                          _buildDataRow(
                            'Creado',
                            _request!.createdAt.toLocal().toString(),
                          ),
                          _buildDataRow(
                            'Actualizado',
                            _request!.updatedAt.toLocal().toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isModder) // botones solo para modder
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                (_processing ||
                                    _request!.status == RequestStatus.approved)
                                ? null
                                : _accept,
                            icon: _processing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: const Text('Aceptar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                (_processing ||
                                    _request!.status == RequestStatus.rejected)
                                ? null
                                : _reject,
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text(
                              'Rechazar',
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (!isModder)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Solo los modders pueden aceptar o rechazar solicitudes.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
