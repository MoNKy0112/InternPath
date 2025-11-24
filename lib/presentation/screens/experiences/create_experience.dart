import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/entities/request.dart';
import 'package:internpath/domain/usecases/company_usecases.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/domain/usecases/request_usecases.dart';
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

  @override
  void initState() {
    super.initState();
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
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );
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
    super.dispose();
  }

  Future<void> _loadExperience(String experienceId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
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
      final userId = FirebaseAuth.instance.currentUser?.uid;
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
        await _experienceUseCases.addExperience(userId, experience);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/');
              },
            ),
            Text(
              widget.experienceId == null
                  ? 'Crear Experiencia'
                  : 'Editar Experiencia',
            ),
          ],
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
                  initialValue: _selectedCompanyId,
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
                      _openNewCompanyDialog(); // 👇 lo implemento abajo
                      return;
                    }
                    _selectedCompanyId = value;
                  },
                ),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(labelText: 'Cargo'),
                ),
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
                      child: Text(
                        widget.experienceId == null ? 'Crear' : 'Actualizar',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
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

  Future<void> _openNewCompanyDialog() async {
    final TextEditingController controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sugerir nueva empresa"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nombre de la empresa"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              _selectedCompanyId = null;
              _suggestedCompanyName = controller.text.trim();
              Navigator.pop(context, controller.text.trim());
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      if (!mounted) return;
      final requestUseCases = context.read<RequestUseCases>();

      await requestUseCases.createRequest(
        Request(
          id: '',
          userId: userId,
          type: RequestType.companySuggestion,
          status: RequestStatus.pending,
          data: {'companyName': result},
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Solicitud enviada. Un modder revisará la empresa."),
        ),
      );
    }
  }
}
