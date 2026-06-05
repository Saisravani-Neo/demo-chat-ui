import 'package:agorachat/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../../../core/utils/phone_number_utils.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/common_text_field.dart';
import '../../../widgets/common_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final number = _mobileController.text.trim();
    context.read<RegisterBloc>().add(RegisterSubmitted(mobileNumber: number));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            context.go('/contacts');
          } else if (state is RegisterFailure) {
            CommonSnackbar.showError(context, state.message);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                  'Enter your mobile number to get started.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),

                  const SizedBox(height: 48),

                  // Mobile number field
                  CommonTextField(
                    controller: _mobileController,
                    hint: 'Enter your mobile number',
                    label: 'Mobile Number',
                    prefixText: '+91 ',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    autofocus: true,
                    validator: PhoneNumberUtils.validateInput,
                  ),

                  const SizedBox(height: 32),

                  // Register button
                  BlocBuilder<RegisterBloc, RegisterState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        label: 'Register',
                        isLoading: state is RegisterLoading,
                        onPressed: _submit,
                      );
                    },
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
