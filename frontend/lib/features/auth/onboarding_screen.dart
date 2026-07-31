import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/providers/profile_provider.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_backdrop.dart';
import '../../shared/widgets/prereq_mark.dart';

const _termsText = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum
dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem
accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab
illo inventore veritatis et quasi architecto beatae vitae dicta sunt
explicabo.
''';

const _contentTypeByExt = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
};

/// First-login guided setup: terms acceptance, choosing a display name, and
/// an optional profile picture. Shown whenever the router's onboarding gate
/// trips (see router.dart) — a brand-new account (`lastSeenAt == null`) or
/// one that hasn't accepted the current terms (`termsAccepted == false`).
///
/// All three steps are collected locally and only submitted together at the
/// very end (`_finish`), with `acceptTerms` called last: `termsAccepted` is
/// what the router's redirect actually watches, so flipping it early would
/// bounce the user straight to `/scanner` mid-flow instead of letting them
/// finish choosing a name/photo.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepCount = 3;

  int _step = 0;
  bool _submitting = false;
  String? _error;

  final _nameController = TextEditingController();
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();

  Uint8List? _avatarBytes;
  String? _avatarFilename;
  String? _avatarContentType;

  @override
  void initState() {
    super.initState();
    final suggested = ref.read(profileProvider).value?.displayName;
    if (suggested != null && suggested.isNotEmpty) {
      _nameController.text = suggested;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _goTo(int step) => setState(() => _step = step);

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.name.contains('.')
        ? picked.name.split('.').last.toLowerCase()
        : 'jpg';
    setState(() {
      _avatarBytes = bytes;
      _avatarFilename = picked.name;
      _avatarContentType = _contentTypeByExt[ext] ?? 'image/jpeg';
    });
  }

  Future<void> _finish() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final notifier = ref.read(profileProvider.notifier);
      await notifier.updateDisplayName(_nameController.text.trim());
      if (_avatarBytes != null) {
        await notifier.uploadAvatar(
          bytes: _avatarBytes!,
          filename: _avatarFilename!,
          contentType: _avatarContentType!,
        );
      }
      // Accept last: this is what releases the router's onboarding gate.
      await notifier.acceptTerms();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not save: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480, minWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PrereqMark(size: 40),
                  AppSpace.gap6,
                  _StepDots(step: _step, count: _stepCount),
                  AppSpace.gap6,
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: switch (_step) {
                          0 => _TermsStep(
                              key: const ValueKey('terms'),
                              onContinue: () => _goTo(1),
                            ),
                          1 => _NameStep(
                              key: const ValueKey('name'),
                              controller: _nameController,
                              fieldKey: _nameFieldKey,
                              onBack: () => _goTo(0),
                              onContinue: () {
                                if (_nameFieldKey.currentState!.validate()) {
                                  _goTo(2);
                                }
                              },
                            ),
                          _ => _AvatarStep(
                              key: const ValueKey('avatar'),
                              avatarBytes: _avatarBytes,
                              existingAvatarUrl:
                                  ref.watch(profileProvider).value?.avatarUrl,
                              submitting: _submitting,
                              error: _error,
                              onBack: () => _goTo(1),
                              onPickPhoto: _pickAvatar,
                              onFinish: _finish,
                            ),
                        },
                      ),
                    ),
                  ),
                  AppSpace.gap4,
                  Text(
                    "Don't go in alone",
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.count});

  final int step;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i <= step;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppSpace.s1),
          width: i == step ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.neutral800,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        );
      }),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: AppColors.accent),
        AppSpace.gap2,
        Text(title, style: theme.textTheme.titleLarge),
      ],
    );
  }
}

class _TermsStep extends StatelessWidget {
  const _TermsStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StepHeader(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
        ),
        AppSpace.gap6,
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: SingleChildScrollView(
            child: Text(_termsText, style: theme.textTheme.bodyMedium),
          ),
        ),
        AppSpace.gap6,
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: onContinue,
            child: const Text('Accept & Continue'),
          ),
        ),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({
    super.key,
    required this.controller,
    required this.fieldKey,
    required this.onBack,
    required this.onContinue,
  });

  final TextEditingController controller;
  final GlobalKey<FormFieldState<String>> fieldKey;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StepHeader(icon: Icons.badge_outlined, title: 'Choose a name'),
        AppSpace.gap2,
        Text(
          'This is what other Prereq users will see on your activity.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        AppSpace.gap6,
        TextFormField(
          key: fieldKey,
          controller: controller,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'Display name',
            counterText: '',
          ),
          onFieldSubmitted: (_) => onContinue(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter a display name';
            }
            return null;
          },
        ),
        AppSpace.gap6,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: onBack, child: const Text('Back')),
            FilledButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AvatarStep extends StatelessWidget {
  const _AvatarStep({
    super.key,
    required this.avatarBytes,
    required this.existingAvatarUrl,
    required this.submitting,
    required this.error,
    required this.onBack,
    required this.onPickPhoto,
    required this.onFinish,
  });

  final Uint8List? avatarBytes;
  final String? existingAvatarUrl;
  final bool submitting;
  final String? error;
  final VoidCallback onBack;
  final VoidCallback onPickPhoto;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ImageProvider? preview;
    if (avatarBytes != null) {
      preview = MemoryImage(avatarBytes!);
    } else if (existingAvatarUrl != null && existingAvatarUrl!.isNotEmpty) {
      preview = NetworkImage(existingAvatarUrl!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StepHeader(
          icon: Icons.photo_camera_outlined,
          title: 'Add a profile picture',
        ),
        AppSpace.gap2,
        Text(
          'Optional — you can always add or change this later.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        AppSpace.gap8,
        Center(
          child: GestureDetector(
            onTap: submitting ? null : onPickPhoto,
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.surfaceHigh,
              backgroundImage: preview,
              child: preview == null
                  ? const Icon(Icons.person_outline,
                      size: 40, color: AppColors.textSecondary)
                  : null,
            ),
          ),
        ),
        AppSpace.gap4,
        Center(
          child: TextButton.icon(
            onPressed: submitting ? null : onPickPhoto,
            icon: const Icon(Icons.upload_outlined, size: 18),
            label: Text(avatarBytes == null ? 'Choose photo' : 'Choose different photo'),
          ),
        ),
        if (error != null) ...[
          AppSpace.gap4,
          Text(error!, style: theme.textTheme.bodySmall
              ?.copyWith(color: AppColors.red)),
        ],
        AppSpace.gap6,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: submitting ? null : onBack,
              child: const Text('Back'),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: submitting ? null : onFinish,
                  child: const Text('Skip'),
                ),
                AppSpace.gap3,
                FilledButton(
                  onPressed: submitting ? null : onFinish,
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Finish'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
