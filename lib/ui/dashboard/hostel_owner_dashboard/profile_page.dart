import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/dashboard/edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch so the page rebuilds when the user's profile is updated
    final currentUser = ref.watch(authProvider).value;

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Return EditProfilePage directly — no wrapping Scaffold.
    // DashboardScreen already supplies the outer AppBar, so isOwner: false
    // suppresses the redundant inner AppBar while still showing all fields.
    return EditProfilePage(currentUser: currentUser, isOwner: false);
  }
}
