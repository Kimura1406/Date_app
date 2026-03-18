import 'package:flutter/material.dart';

import '../data/models.dart';
import '../localization/app_language.dart';
import '../localization/app_localizations.dart';
import '../widgets/language_selector_field.dart';
import '../widgets/profile_field.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.currentUser,
    required this.selectedLanguage,
    required this.onLanguageChanged,
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
  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
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
    final strings = context.strings;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.myPageTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F2323),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${strings.myPageSubtitle}: ${currentUser.name} (${currentUser.email})',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6D5A5A),
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LanguageSelectorField(
                    label: strings.changeLanguage,
                    language: selectedLanguage,
                    onChanged: onLanguageChanged,
                  ),
                  ProfileField(
                    label: strings.emailLabel,
                    controller: emailController,
                  ),
                  ProfileField(
                    label: strings.passwordKeepCurrent,
                    controller: passwordController,
                    obscureText: true,
                  ),
                  ProfileField(
                    label: strings.displayName,
                    controller: nameController,
                  ),
                  ProfileField(
                    label: strings.age,
                    controller: ageController,
                    keyboardType: TextInputType.number,
                  ),
                  ProfileField(label: strings.job, controller: jobController),
                  ProfileField(
                    label: strings.distance,
                    controller: distanceController,
                  ),
                  ProfileField(
                    label: strings.bio,
                    controller: bioController,
                    maxLines: 3,
                  ),
                  ProfileField(
                    label: strings.interests,
                    controller: interestsController,
                    hintText: strings.interestsHint,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.tonal(
                        onPressed: busy ? null : () async => onRefreshSession(),
                        child: Text(strings.refreshToken),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : () async => onUpdate(),
                        child: Text(strings.editUser),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : () async => onDelete(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9B1C31),
                        ),
                        child: Text(strings.deleteUser),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : () async => onLogout(),
                        child: Text(strings.logout),
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
