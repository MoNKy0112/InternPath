import 'package:flutter/material.dart';
import 'package:internpath/presentation/screens/user/profile/components/edit_profile_form.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Editar Perfil",
      currentPageIndex: 2,
      child: EditProfileForm(),
    );
  }
}
