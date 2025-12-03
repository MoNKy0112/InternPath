import 'package:flutter/material.dart';
import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/domain/usecases/company_usecases.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CompanyEditScreen extends StatefulWidget {
  final String? companyId;
  const CompanyEditScreen({super.key, this.companyId});

  @override
  State<CompanyEditScreen> createState() => _CompanyEditScreenState();
}

class _CompanyEditScreenState extends State<CompanyEditScreen> {
  final _form = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _websiteCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _logoCtl = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.companyId != null) _load();
  }

  Future<void> _load() async {
    final usecases = context.read<CompanyUseCases>();
    final c = await usecases.getCompanyById(widget.companyId!);
    if (!mounted) return;
    if (c != null) {
      _nameCtl.text = c.name;
      _websiteCtl.text = c.website ?? '';
      _descCtl.text = c.description ?? '';
      _logoCtl.text = c.logoUrl ?? '';
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => loading = true);
    final usecases = context.read<CompanyUseCases>();
    final company = Company(
      id: widget.companyId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtl.text.trim(),
      website: _websiteCtl.text.trim().isEmpty ? null : _websiteCtl.text.trim(),
      description: _descCtl.text.trim().isEmpty ? null : _descCtl.text.trim(),
      logoUrl: _logoCtl.text.trim().isEmpty ? null : _logoCtl.text.trim(),
    );
    if (widget.companyId == null) {
      await usecases.addCompany(company);
    } else {
      await usecases.updateCompany(company.id, company);
    }
    if (!mounted) return;
    setState(() => loading = false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.companyId == null ? 'Crear empresa' : 'Editar empresa';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.go('/');
            }
          },
        ),
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _websiteCtl,
                decoration: const InputDecoration(
                  labelText: 'Sitio web (opcional)',
                ),
              ),
              TextFormField(
                controller: _descCtl,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                ),
                maxLines: 3,
              ),
              TextFormField(
                controller: _logoCtl,
                decoration: const InputDecoration(
                  labelText: 'Logo URL (opcional)',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loading ? null : _save,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
