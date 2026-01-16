import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text field designed for conscious financial input
///
/// Features gentle micro-copy and mindful design
class ConsciousTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const ConsciousTextField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        helperMaxLines: 2,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        filled: true,
      ),
    );
  }
}

/// A number input specifically for currency amounts
class CurrencyInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const CurrencyInputField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ConsciousTextField(
      label: label,
      hint: hint ?? '0',
      helperText: helperText,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      prefixIcon: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('Rp', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

/// A number input for hours
class HoursInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const HoursInputField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ConsciousTextField(
      label: label,
      hint: hint ?? '0',
      helperText: helperText,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
      ],
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      suffixIcon: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('jam', style: TextStyle(fontSize: 14, color: Colors.grey)),
      ),
    );
  }
}
