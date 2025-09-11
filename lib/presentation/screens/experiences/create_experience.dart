import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/data/models/experience_model.dart';
import 'package:internpath/data/models/user_model.dart';
import 'package:internpath/utils/thousands_formatter.dart';

class CreateExperience extends StatefulWidget {
  final ExperienceModel? experience; // Null if creating a new experience

  const CreateExperience({super.key, this.experience});

  @override
  State<CreateExperience> createState() => _CreateExperienceState();
}

class _CreateExperienceState extends State<CreateExperience> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  bool _flexSchedule = false;
  bool _continueOption = false;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.experience != null) {
      _companyController.text = widget.experience!.company;
      _jobTitleController.text = widget.experience!.jobTitle;
      _descriptionController.text = widget.experience!.description ?? '';
      _salaryController.text = widget.experience!.salary.toString();
      _flexSchedule = widget.experience!.flexSchedule;
      _continueOption = widget.experience!.continueOption;
      _startDateController.text = widget.experience!.startDate
          .toIso8601String();
      _endDateController.text = widget.experience!.endDate.toIso8601String();
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _flexSchedule = false;
    _continueOption = false;
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
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
              widget.experience == null
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
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'Empresa'),
                ),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(labelText: 'Cargo'),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
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

                  ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
