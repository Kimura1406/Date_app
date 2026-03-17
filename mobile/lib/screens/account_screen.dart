import 'package:flutter/material.dart';

import '../data/models.dart';
import '../widgets/profile_field.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.currentUser,
    required this.statusMessage,
    required this.busy,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.ageController,
    required this.jobController,
    required this.bioController,
    required this.distanceController,
    required this.interestsController,
    required this.onRefreshSession,
    required this.onUpdate,
    required this.onDelete,
    required this.onLogout,
  });

  final AppUser currentUser;
  final String statusMessage;
  final bool busy;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController jobController;
  final TextEditingController bioController;
  final TextEditingController distanceController;
  final TextEditingController interestsController;
  final Future<void> Function() onRefreshSession;
  final Future<void> Function() onUpdate;
  final Future<void> Function() onDelete;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Center',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Logged in as ${currentUser.name} (${currentUser.email}) with role ${currentUser.role}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6E5960),
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileField(label: 'Email', controller: emailController),
                  ProfileField(
                    label: 'Password (leave blank to keep current password)',
                    controller: passwordController,
                    obscureText: true,
                  ),
                  ProfileField(
                    label: 'Display name',
                    controller: nameController,
                  ),
                  ProfileField(
                    label: 'Age',
                    controller: ageController,
                    keyboardType: TextInputType.number,
                  ),
                  ProfileField(label: 'Job', controller: jobController),
                  ProfileField(
                    label: 'Distance',
                    controller: distanceController,
                  ),
                  ProfileField(
                    label: 'Bio',
                    controller: bioController,
                    maxLines: 3,
                  ),
                  ProfileField(
                    label: 'Interests',
                    controller: interestsController,
                    hintText: 'Travel, Music, Coffee',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.tonal(
                        onPressed: busy ? null : () async => onRefreshSession(),
                        child: const Text('Refresh token'),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : () async => onUpdate(),
                        child: const Text('Edit user'),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : () async => onDelete(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9B1C31),
                        ),
                        child: const Text('Delete user'),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : () async => onLogout(),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (statusMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusMessage),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
