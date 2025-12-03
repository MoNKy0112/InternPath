import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/entities/request.dart';
import 'package:internpath/domain/usecases/company_usecases.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/domain/usecases/request_usecases.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:internpath/utils/thousands_formatter.dart';
import 'package:provider/provider.dart';

class CreateExperience extends StatefulWidget {
  final String? experienceId;

  const CreateExperience({super.key, this.experienceId});

  @override
  State<CreateExperience> createState() => _CreateExperienceState();
}

class _CreateExperienceState extends State<CreateExperience> {
  // final TextEditingController _companyController = TextEditingController();
  List<Company> _companies = [];
  String? _selectedCompanyId;
  String? _suggestedCompanyName;
  bool requestInProcess = false;
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  bool _flexSchedule = false;
  bool _continueOption = false;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late ExperienceUseCases _experienceUseCases;

  late final Experience? experience;

  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    _experienceUseCases = context.read<ExperienceUseCases>();
    _loadCompanies();
    if (widget.experienceId != null) {
      _loadExperience(widget.experienceId!);
    } else {
      experience = Experience(
        id: '',
        companyId: '',
        positionTitle: '',
        description: '',
        salary: 0,
        flexSchedule: false,
        continueOption: false,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        userId: authProvider.domainUser?.id ?? '',
      );
      requestInProcess = false;
      _suggestedCompanyName = '';
    }
  }

  @override
  void dispose() {
    _selectedCompanyId = null;
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _flexSchedule = false;
    _continueOption = false;
    _startDateController.dispose();
    _endDateController.dispose();
    requestInProcess = false;
    _suggestedCompanyName = '';
    super.dispose();
  }

  Future<void> _loadExperience(String experienceId) async {
    final userId = authProvider.domainUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario no autenticado')));
      return;
    }
    final experience = await _experienceUseCases.getExperienceById(
      experienceId,
    );

    if (experience != null) {
      setState(() {
        _selectedCompanyId = experience.companyId;
        _jobTitleController.text = experience.positionTitle;
        _descriptionController.text = experience.description ?? '';
        _salaryController.text = experience.salary.toString();
        _flexSchedule = experience.flexSchedule;
        _continueOption = experience.continueOption;
        _startDateController.text = experience.startDate.toIso8601String();
        _endDateController.text = experience.endDate.toIso8601String();
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experiencia no encontrada')),
      );
      context.go('/');
    }
  }

  Future<void> _loadCompanies() async {
    _companies = await context.read<CompanyUseCases>().getCompanies();
    setState(() {});
  }

  Future<void> _saveExperience() async {
    if (_formKey.currentState!.validate()) {
      final userId = authProvider.domainUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuario no autenticado')));
        return;
      }
      final experience = Experience(
        id: widget.experienceId ?? '',
        companyId: _selectedCompanyId ?? '',
        positionTitle: _jobTitleController.text,
        description: _descriptionController.text,
        salary:
            double.tryParse(_salaryController.text.replaceAll('.', '')) ?? 0,
        flexSchedule: _flexSchedule,
        continueOption: _continueOption,
        startDate:
            DateTime.tryParse(_startDateController.text) ?? DateTime.now(),
        endDate: DateTime.tryParse(_endDateController.text) ?? DateTime.now(),
        userId: userId,
      );

      if (widget.experienceId == null) {
        final newExperienceId = await _experienceUseCases.addExperience(
          userId,
          experience,
        );
        if (requestInProcess &&
            _suggestedCompanyName != null &&
            _suggestedCompanyName!.isNotEmpty) {
          createCompanyRequest(newExperienceId);
        }
      } else {
        await _experienceUseCases.updateExperience(
          userId,
          widget.experienceId!,
          experience,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.experienceId == null
                ? 'Experiencia creada exitosamente'
                : 'Experiencia actualizada exitosamente',
          ),
        ),
      );
      context.go('/');
    }
  }

  void createCompanyRequest(String experienceId) async {
    final userId = authProvider.domainUser?.id;
    if (userId == null) return;
    if (!mounted) return;
    final requestUseCases = context.read<RequestUseCases>();

    await requestUseCases.createRequest(
      Request(
        id: '',
        userId: userId,
        userName: authProvider.domainUser?.fullName ?? 'Desconocido',
        type: RequestType.companySuggestion,
        status: RequestStatus.pending,
        data: {
          'companyName': _suggestedCompanyName,
          'experienceId': experienceId,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Solicitud enviada. Un modder revisará la empresa."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // único botón de retroceso: intenta pop, si no puede hace fallback a la lista
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.go('/'); // fallback si no hay historial
            }
          },
        ),
        title: Text(
          widget.experienceId == null
              ? 'Crear Experiencia'
              : 'Editar Experiencia',
        ),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: requestInProcess ? 'new-company' : _selectedCompanyId,
                  decoration: const InputDecoration(labelText: 'Empresa'),
                  items: [
                    ..._companies.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                    const DropdownMenuItem(
                      value: 'new-company',
                      child: Text('➕ Mi empresa no aparece'),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == 'new-company') {
                      // abrir diálogo para sugerir o editar empresa sugerida
                      final edited = await _openNewCompanyDialog(
                        initial: _suggestedCompanyName ?? '',
                      );
                      if (edited ?? false) {
                        setState(() {
                          requestInProcess = true;
                          _selectedCompanyId = null;
                        });
                      }
                      return;
                    } else {
                      // selección de una empresa existente
                      setState(() {
                        requestInProcess = false;
                        _suggestedCompanyName = '';
                        _selectedCompanyId = value;
                      });
                    }
                  },
                ),

                // Mostrar la sugerencia (editable) si está activa
                if (requestInProcess &&
                    (_suggestedCompanyName != null &&
                        _suggestedCompanyName!.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Empresa sugerida',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _suggestedCompanyName!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Editar sugerencia',
                                  onPressed: () async {
                                    final edited = await _openNewCompanyDialog(
                                      initial: _suggestedCompanyName ?? '',
                                    );
                                    if (edited ?? false) {
                                      setState(() {});
                                    }
                                  },
                                  icon: const Icon(Icons.edit, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                TextFormField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(labelText: 'Cargo'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    counterText:
                        "${_descriptionController.text.length}/300", // contador manual
                  ),
                  maxLines: 5, // varias líneas
                  maxLength: 300, // límite de caracteres
                  keyboardType: TextInputType.multiline,
                  onChanged: (_) {
                    setState(() {}); // actualiza el contador visual
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    if (value.length > 300) {
                      return 'Máximo 300 caracteres';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salario',
                    hintText: 'Ingrese un número entero',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsFormatter(),
                  ],
                ),
                CheckboxListTile(
                  title: const Text('Horario Flexible'),
                  value: _flexSchedule,
                  onChanged: (value) {
                    setState(() {
                      _flexSchedule = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Opción de Continuar'),
                  value: _continueOption,
                  onChanged: (value) {
                    setState(() {
                      _continueOption = value ?? false;
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _startDateController.text = pickedDate
                                  .toIso8601String();
                            });
                          }
                        },
                        child: Text(
                          _startDateController.text.isEmpty
                              ? 'Seleccionar Fecha de Inicio'
                              : _startDateController.text.split('T').first,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('a'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _endDateController.text = pickedDate
                                  .toIso8601String();
                            });
                          }
                        },
                        child: Text(
                          _endDateController.text.isEmpty
                              ? 'Seleccionar Fecha de Fin'
                              : _endDateController.text.split('T').first,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _saveExperience,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          100,
                          181,
                          246,
                        ),
                      ),
                      child: Text(
                        widget.experienceId == null ? 'Crear' : 'Actualizar',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final router = GoRouter.of(context);
                        if (router.canPop()) {
                          router.pop();
                        } else {
                          router.go('/');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          245,
                          131,
                          123,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _openNewCompanyDialog({String initial = ''}) async {
    final TextEditingController controller = TextEditingController(
      text: initial,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          initial.isEmpty ? "Sugerir nueva empresa" : "Editar empresa sugerida",
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nombre de la empresa"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              setState(() {
                _suggestedCompanyName = value;
                requestInProcess = true;
                _selectedCompanyId = null;
              });
              Navigator.pop(context, true);
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );

    return result;
  }
}
