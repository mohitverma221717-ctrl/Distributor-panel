import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final int maxLines;
  final bool showCountryCode;
  final String countryCode;
  final VoidCallback? onCountryCodeTap;

  const GlassInput({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.showCountryCode = false,
    this.countryCode = '+91',
    this.onCountryCodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.38),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.65),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                Padding(
                  padding: EdgeInsets.only(
                    left: 14,
                    right: showCountryCode ? 6 : 8,
                    top: maxLines > 1 ? 12 : 0,
                  ),
                  child: prefixIcon,
                ),
              ],
              if (showCountryCode) ...[
                InkWell(
                  onTap: onCountryCodeTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          countryCode,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 22,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  validator: validator,
                  onChanged: onChanged,
                  readOnly: readOnly,
                  maxLines: maxLines,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF475569).withOpacity(0.65),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: (prefixIcon == null && !showCountryCode) ? 16 : 8,
                      vertical: maxLines > 1 ? 12 : 14,
                    ),
                  ),
                ),
              ),
              if (suffixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: suffixIcon,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
