import 'package:flutter/material.dart';
import 'package:project/constants/theme.dart';

class DropdownInput extends StatelessWidget {
  final String? placeholder;
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator; // Hàm kiểm tra giá trị
  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final bool outlineBorder;
  final bool filled;
  final Color? fillColor;

  const DropdownInput({
    super.key,
    this.placeholder,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.enabledBorderColor = MaterialColors.muted,
    this.focusedBorderColor = MaterialColors.primary,
    this.outlineBorder = false,
    this.filled = false,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      borderRadius: BorderRadius.circular(8),
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 16, bottom: outlineBorder ? 20 : 16),
        filled: filled,
        fillColor: fillColor,
        hintText: placeholder,
        // hintStyle: TextStyle(color: MaterialColors.caption),
        enabledBorder: outlineBorder
            ? OutlineInputBorder(
                borderSide: BorderSide(color: enabledBorderColor),
                gapPadding: 10.0, // Cách viền 1 bên 10px
              )
            : UnderlineInputBorder(borderSide: BorderSide(color: enabledBorderColor)),
        focusedBorder: outlineBorder
            ? OutlineInputBorder(
                borderSide: BorderSide(color: focusedBorderColor),
                gapPadding: 10.0, // Cách viền 1 bên 10px
              )
            : UnderlineInputBorder(borderSide: BorderSide(color: focusedBorderColor)),
      ),
      validator: validator, // Thêm kiểm tra giá trị
      items: items,
      // dropdownColor: fillColor ?? Colors.white, // Set the dropdown menu color
      // style: TextStyle(color: MaterialColors.caption), // Set the text style for the dropdown items
      iconEnabledColor: focusedBorderColor, // Set the color of the dropdown icon
      iconSize: 24, // Set the size of the dropdown icon
    );
  }
}
