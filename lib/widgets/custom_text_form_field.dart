import 'package:flutter/material.dart';

class CustomFormTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  const CustomFormTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.onChanged,
    this.validator,
    this.keyboardType,

  });

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  bool obscureText = true;
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextFormField(

        validator: widget.validator,
        onChanged: (data) {
          if (widget.onChanged != null) widget.onChanged!(data);
          // تحديث حالة الخطأ لحظياً
          if (widget.validator != null) {
            setState(() => errorText = widget.validator!(data));
          }
        },
        obscureText: widget.isPassword ? obscureText : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: Colors.white),
          // منطق ظهور أيقونة العين أو أيقونة الخطأ
          suffixIcon: widget.isPassword
              ? IconButton(
            onPressed: () => setState(() => obscureText = !obscureText),
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white),
          )
              : (errorText != null ? const Icon(Icons.error, color: Colors.red) : null),
          labelText: widget.label,
          labelStyle: const TextStyle(color: Colors.white),
          // تثبيت شكل البوردر
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.blue, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.blue, width: 2)),
        ),
      ),
    );
  }
}