import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/item_service.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login.')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                const Icon(Icons.school_outlined, color: AppTheme.navy, size: 20),
                const SizedBox(width: 6),
                const Text(
                  'Campus Found',
                  style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.lightBlue,
                  child: Icon(Icons.person, color: AppTheme.navy, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: AppTheme.lightBlue,
                    child: Icon(Icons.person, size: 45, color: AppTheme.navy),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    (user.displayName?.trim().isNotEmpty ?? false)
                        ? user.displayName!
                        : (user.email?.split('@').first ?? 'Campus User'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.navy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'STUDENT ID: ${user.uid.substring(0, user.uid.length.clamp(0, 8)).toUpperCase()}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textGrey, letterSpacing: 0.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live stats from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: ItemService().getMyItems(user.uid),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final reported = docs.length;
                final recovered = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return data['status'] == 'claimed';
                }).length;

                return Row(
                  children: [
                    Expanded(child: _StatCard(value: '$reported', label: 'Items Reported')),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(value: '$recovered', label: 'Items Recovered', accent: true)),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            const _SectionHeader('ACCOUNT SETTINGS'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsRow(
                  icon: Icons.badge_outlined,
                  title: 'Personal Information',
                  subtitle: 'Name, email, and ID',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.verified_user_outlined,
                  title: 'University Verification',
                  subtitle: 'Official campus status',
                  trailing: const _VerifiedChip(),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),

            const _SectionHeader('NOTIFICATION PREFERENCES'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _ToggleRow(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Instant alerts for matches',
                  value: true,
                  onChanged: (_) {
                    // TODO: persist push-notification preference
                  },
                ),
                const Divider(height: 1),
                _ToggleRow(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark theme',
                  value: isDark,
                  onChanged: (value) {
                    context.read<ThemeProvider>().toggleTheme(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            const _SectionHeader('PRIVACY & SECURITY'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsRow(icon: Icons.location_on_outlined, title: 'Location Privacy', onTap: () {}),
                const Divider(height: 1),
                _SettingsRow(icon: Icons.shield_outlined, title: 'Two-Factor Authentication', onTap: () {}),
              ],
            ),
            const SizedBox(height: 20),

            const _SectionHeader('HELP & SUPPORT'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsRow(icon: Icons.help_outline, title: 'FAQ & Knowledge Base', onTap: () {}),
                const Divider(height: 1),
                _SettingsRow(icon: Icons.local_police_outlined, title: 'Contact Campus Security', onTap: () {}),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async => AuthService().logout(),
                icon: const Icon(Icons.logout, color: AppTheme.dangerRed),
                label: const Text('Log Out', style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.dangerRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool accent;
  const _StatCard({required this.value, required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: accent ? AppTheme.orange.withOpacity(0.15) : AppTheme.paleBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.navy)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppTheme.textGrey),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.navy),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textGrey),
      onTap: onTap,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.navy),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
      value: value,
      activeColor: AppTheme.orange,
      onChanged: onChanged,
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.claimedBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: AppTheme.claimedText),
          const SizedBox(width: 4),
          Text('Verified', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.claimedText)),
        ],
      ),
    );
  }
}
