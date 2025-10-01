import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:internpath/domain/entities/user.dart';
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
  String? _photoUrl;

  late User _userData;
  late String uid;
  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    authUseCase = context.read<AuthUseCases>();
    final user = authProvider.currentUser;

    if (user != null) {
      uid = user.uid;
      authUseCase.getUserById(uid).then((userData) {
        if (userData != null) {
          _fullNameController.text = userData.fullName;
          _photoUrl = userData.photoUrl;
          _userData = userData;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> loadPhoto() {
      return CachedNetworkImageProvider(
        _photoUrl ??
            'https://ui-avatars.com/api/?name=${_fullNameController.text}',
      );
    }

    Future<void> updateProfile() async {
      if (_formKey.currentState!.validate()) {
        final fullName = _fullNameController.text.trim();
        // You can add more fields as needed

        try {
          await authUseCase.updateProfile(uid, {
            'fullName': fullName,
            // Add other fields here
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
        }
      }
    }

    return Form(
      key: _formKey,
      child: Card(
        margin: const EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(radius: 50, backgroundImage: loadPhoto()),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: updateProfile,
                    child: const Text('Actualizar Perfil'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
