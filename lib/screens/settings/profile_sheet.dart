import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../providers/user_provider.dart';

class ProfileSheet extends ConsumerStatefulWidget {
  const ProfileSheet({super.key});

  @override
  ConsumerState<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<ProfileSheet> {
  final _usernameCtrl = TextEditingController();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loadingUsername = false;
  bool _loadingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _usernameCtrl.text = ref.read(userProvider).valueOrNull?.username ?? '';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveUsername(AppStrings s) async {
    if (_usernameCtrl.text.trim().isEmpty) return;
    setState(() => _loadingUsername = true);
    final ok = await ref
        .read(userProvider.notifier)
        .updateUsername(_usernameCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loadingUsername = false);
    _showSnack(ok ? s.usernameUpdated : s.usernameUpdateFailed, ok);
  }

  Future<void> _changePassword(AppStrings s) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loadingPassword = true);
    final ok = await ref
        .read(userProvider.notifier)
        .changePassword(_currentPwCtrl.text, _newPwCtrl.text);
    if (!mounted) return;
    setState(() => _loadingPassword = false);
    if (ok) {
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
    }
    _showSnack(ok ? s.passwordChanged : s.wrongPassword, ok);
  }

  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(stringsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
              child: Row(
                children: [
                  Text(s.editProfile, style: theme.textTheme.headlineMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                children: [
                  Text(s.username, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _usernameCtrl,
                          decoration: InputDecoration(
                            labelText: s.username,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _loadingUsername
                            ? null
                            : () => _saveUsername(s),
                        child: _loadingUsername
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(s.save),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(s.changePassword, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _PwField(
                          ctrl: _currentPwCtrl,
                          label: s.currentPassword,
                          obscure: _obscureCurrent,
                          onToggle: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                          validator: (v) => v!.isEmpty ? s.required : null,
                        ),
                        const SizedBox(height: 12),
                        _PwField(
                          ctrl: _newPwCtrl,
                          label: s.newPassword,
                          obscure: _obscureNew,
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          validator: (v) {
                            if (v!.isEmpty) return s.required;
                            if (v.length < 6) return s.minSixChars;
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _PwField(
                          ctrl: _confirmPwCtrl,
                          label: s.confirmPassword,
                          obscure: _obscureConfirm,
                          onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return s.required;
                            if (v != _newPwCtrl.text) return s.passwordMismatch;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadingPassword
                              ? null
                              : () => _changePassword(s),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: _loadingPassword
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(s.changePassword),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PwField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PwField({
    required this.ctrl,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
