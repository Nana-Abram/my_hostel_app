import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/dashboard/edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final authState = ref.read(authProvider);
  final currentUser = authState.value;
    return Scaffold(
    
      body:EditProfilePage(currentUser: currentUser!, isOwner: false,),
    );
  }
}