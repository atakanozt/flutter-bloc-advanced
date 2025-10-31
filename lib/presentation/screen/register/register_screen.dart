import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_advance/data/models/user.dart';
import 'package:flutter_bloc_advance/configuration/local_storage.dart';
import 'package:flutter_bloc_advance/routes/app_router.dart';
import 'package:flutter_bloc_advance/data/repository/login_repository.dart';
import 'package:flutter_bloc_advance/data/repository/account_repository.dart';
import 'package:flutter_bloc_advance/data/models/user_jwt.dart';
import 'package:flutter_bloc_advance/presentation/screen/components/confirmation_dialog_widget.dart';
import 'package:flutter_bloc_advance/presentation/screen/components/responsive_form_widget.dart';
import 'package:flutter_bloc_advance/presentation/screen/components/submit_button_widget.dart';
import 'package:flutter_bloc_advance/presentation/screen/components/user_form_fields.dart';
import 'package:flutter_bloc_advance/routes/app_routes_constants.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

import '../../../generated/l10n.dart';
import 'bloc/register_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.returnToSettings = false});

  final bool returnToSettings;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _lastUsername;
  String? _lastPassword;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) => _handleStateChanges(context, state),
      child: Scaffold(appBar: _buildAppBar(context), body: _buildBody(context)),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).register),
      leading: IconButton(
        key: const Key('registerScreenAppBarBackButtonKey'),
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _handlePopScope(false, null, context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return ResponsiveFormBuilder(
          formKey: _formKey,
          children: [
            // Alt başlık eklendi (AppBar'da zaten başlık var)
            Text(
              'Create your account',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 8),
            ..._buildFormFields(context, state),
            _submitButton(context, state),
          ],
        );
      },
    );
  }

  List<Widget> _buildFormFields(BuildContext context, RegisterState state) {
    return [
      _usernameField(context),
      UserFormFields.firstNameField(context, state.data?.firstName),
      UserFormFields.lastNameField(context, state.data?.lastName),
      UserFormFields.emailField(context, state.data?.email),
      _passwordField(context),
    ];
  }

  Widget _usernameField(BuildContext context) {
    return FormBuilderTextField(
      name: 'username',
      decoration: InputDecoration(
        labelText: S.of(context).login_user_name,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return S.of(context).required_field;
        if (value.length < 3) return S.of(context).min_length_4;
        return null;
      },
    );
  }

  Widget _passwordField(BuildContext context) {
    return FormBuilderTextField(
      name: 'password',
      obscureText: true,
      decoration: InputDecoration(
        labelText: S.of(context).login_password,
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return S.of(context).required_field;
        if (value.length < 4) return S.of(context).password_min_length;
        return null;
      },
    );
  }

  Widget _submitButton(BuildContext context, RegisterState state) {
    return ResponsiveSubmitButton(
      key: const Key('registerSubmitButtonKey'),
      onPressed: () => state.status == RegisterStatus.loading ? null : _onSubmit(context, state),
      isLoading: state.status == RegisterStatus.loading,
    );
  }

  void _onSubmit(BuildContext context, RegisterState state) {
    debugPrint("onSubmit");
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint("validate");
      _showSnackBar(context, S.of(context).failed, const Duration(milliseconds: 1000));
      return;
    }

    if (!(_formKey.currentState?.isDirty ?? false)) {
      debugPrint("no changes made");
      _showSnackBar(context, S.of(context).no_changes_made, const Duration(milliseconds: 1000));
      return;
    }

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      debugPrint("saveAndValidate");
      User data = User(
        login: _formKey.currentState!.value['username'],
        firstName: _formKey.currentState!.value['firstName'],
        lastName: _formKey.currentState!.value['lastName'],
        email: _formKey.currentState!.value['email'],
      );
      _lastUsername = _formKey.currentState!.value['username'];
      _lastPassword = _formKey.currentState!.value['password'];
      context.read<RegisterBloc>().add(RegisterFormSubmitted(data: data));
    }
  }

  void _handleStateChanges(BuildContext context, RegisterState state) {
    const duration = Duration(milliseconds: 1000);
    switch (state.status) {
      case RegisterStatus.initial:
        //
        break;
      case RegisterStatus.loading:
        _showSnackBar(context, S.of(context).loading, duration);
        break;
      case RegisterStatus.success:
        _formKey.currentState?.reset();
        _playSuccessAndLogin(
          context,
          _lastUsername,
          _lastPassword,
          firstName: _formKey.currentState?.value['firstName'],
          lastName: _formKey.currentState?.value['lastName'],
        );
        break;
      case RegisterStatus.error:
        _showSnackBar(context, S.of(context).failed, duration);
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message, Duration duration) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }

  Future<void> _handlePopScope(bool didPop, Object? data, [BuildContext? contextParam]) async {
    final context = contextParam ?? data as BuildContext;

    if (!context.mounted) return;

    if (didPop || !(_formKey.currentState?.isDirty ?? false) || _formKey.currentState == null) {
      // Eğer settings'den geldiyse settings'e, değilse home'a dön
      if (widget.returnToSettings) {
        context.go(ApplicationRoutesConstants.settings);
      } else {
        context.go(ApplicationRoutesConstants.home);
      }
      return;
    }

    final shouldPop = await ConfirmationDialog.show(context: context, type: DialogType.unsavedChanges) ?? false;
    if (shouldPop && context.mounted) {
      // Eğer settings'den geldiyse settings'e, değilse home'a dön
      if (widget.returnToSettings) {
        context.go(ApplicationRoutesConstants.settings);
      } else {
        context.go(ApplicationRoutesConstants.home);
      }
    }
  }
}

Future<void> _playSuccessAndLogin(
  BuildContext context,
  String? username,
  String? password, {
  String? firstName,
  String? lastName,
}) async {
  // Show a simple Apple-like success animation (scaling checkmark in a circle)
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return const _SuccessDialog();
    },
  );

  // After success, authenticate with provided credentials and persist session
  if (username == null || username.isEmpty || password == null || password.isEmpty) {
    if (context.mounted) AppRouter().push(context, ApplicationRoutesConstants.login);
    return;
  }

  try {
    final loginRepo = LoginRepository();
    final accountRepo = AccountRepository();
    // Save user-provided display info for dev mode
    if (firstName != null && firstName.isNotEmpty) {
      await AppLocalStorage().save(StorageKeys.firstName.name, firstName);
    }
    if (lastName != null && lastName.isNotEmpty) {
      await AppLocalStorage().save(StorageKeys.lastName.name, lastName);
    }
    final token = await loginRepo.authenticate(UserJWT(username, password));
    if (token != null && token.idToken != null) {
      await AppLocalStorage().save(StorageKeys.jwtToken.name, token.idToken);
      await AppLocalStorage().save(StorageKeys.username.name, username);
      final user = await accountRepo.getAccount();
      await AppLocalStorage().save(StorageKeys.roles.name, user.authorities);
      // Update firstName/lastName from account if available (backend might have different values)
      if (user.firstName != null && user.firstName!.isNotEmpty) {
        await AppLocalStorage().save(StorageKeys.firstName.name, user.firstName!);
      }
      if (user.lastName != null && user.lastName!.isNotEmpty) {
        await AppLocalStorage().save(StorageKeys.lastName.name, user.lastName!);
      }
      if (context.mounted) {
        AppRouter().push(context, ApplicationRoutesConstants.home);
      }
      return;
    }
  } catch (e) {
    // fallthrough to login if auto-auth fails
  }
  if (context.mounted) AppRouter().push(context, ApplicationRoutesConstants.login);
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Icon(Icons.check_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
