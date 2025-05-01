// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safeships_flutter/theme.dart';

enum CustomTextFieldType { underline, outline }

class CustomTextField extends StatelessWidget {
  final String? labelText;
  final String hintText;
  final Widget? prefix;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final VoidCallback? onCompleted;
  final void Function(String)? onChanged;
  final void Function(PointerDownEvent)? onTapOutside;
  final bool? isPicker;
  final void Function()? pickerFunction;
  final bool? isPassword;
  final bool? isObscure;
  final Widget? rightIcon;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final bool? enableTooltip;
  final bool? enableError;
  final String? errorText;
  final TextStyle? lableStyle;
  final double? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final CustomTextFieldType? textFieldType;
  final bool isTextArea; // Tambahkan parameter ini
  final List<TextInputFormatter>? inputFormatters; // Tambahkan parameter ini

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.prefix,
    required this.keyboardType,
    required this.controller,
    this.onCompleted,
    this.onChanged,
    this.onTapOutside,
    this.isPicker = false,
    this.pickerFunction,
    this.isPassword = false,
    this.isObscure,
    this.rightIcon,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.style,
    this.hintStyle,
    this.enableTooltip = false,
    this.enableError = false,
    this.errorText = "Can not be empty",
    this.lableStyle,
    this.borderRadius,
    this.textFieldType = CustomTextFieldType.underline,
    this.borderColor = const Color(0xFFC4C4C4),
    this.fillColor = const Color(0xFFE8F6FA),
    this.isTextArea = false,
    this.inputFormatters, // Nilai default false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText!.isNotEmpty
            ? Row(
                children: [
                  Text(
                    labelText!,
                    style: lableStyle ??
                        primaryTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: medium,
                        ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  // enableTooltip!
                  //     ? ElTooltip(
                  //         position: ElTooltipPosition.rightCenter,
                  //         color: primaryColor700,
                  //         showModal: false,
                  //         content: Text(
                  //           'Min. 8 karakter, 1 huruf kecil,\n1 huruf besar, dan 1 angka',
                  //           textAlign: TextAlign.center,
                  //           style: primaryTextStyle.copyWith(
                  //             color: whiteColor,
                  //             fontSize: 10,
                  //           ),
                  //         ),
                  //         distance: 5,
                  //         disappearAnimationDuration:
                  //             const Duration(milliseconds: 200),
                  //         appearAnimationDuration:
                  //             const Duration(milliseconds: 200),
                  //         child: Icon(
                  //           Icons.info_outline,
                  //           size: 14,
                  //           color: subtitleTextColor,
                  //         ),
                  //       )
                  //     : const SizedBox(),
                ],
              )
            : const SizedBox(
                height: 0,
              ),
        textFieldType == CustomTextFieldType.outline
            ? const SizedBox(
                height: 5,
              )
            : const SizedBox(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: textFieldType == CustomTextFieldType.underline
                ? Colors.transparent
                : Colors.transparent,
          ),
          child: TextField(
            focusNode: focusNode,
            onTapOutside: onTapOutside,
            onTap: isPicker! ? pickerFunction : null,
            inputFormatters: inputFormatters,

            onEditingComplete: onCompleted,
            onChanged: onChanged,
            obscureText: isPassword! ? isObscure! : false,
            readOnly: isPicker!,
            keyboardType: keyboardType,
            controller: controller,
            maxLines:
                isTextArea ? 5 : 1, // Tambahkan ini untuk menyesuaikan tinggi
            style: style ??
                primaryTextStyle.copyWith(
                  fontSize: 12,
                ),

            textInputAction: textInputAction,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              error: enableError! ? Text(errorText!) : null,
              errorBorder: enableError!
                  ? textFieldType == CustomTextFieldType.underline
                      ? const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        )
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(borderRadius ?? 8),
                          ),
                          borderSide: const BorderSide(
                            color: Colors.red,
                          ),
                        )
                  : null,
              hoverColor: Colors.red,
              contentPadding: textFieldType == CustomTextFieldType.underline
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
              hintText: hintText,
              hintStyle: hintStyle ??
                  primaryTextStyle.copyWith(
                    color: blackColor.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: medium,
                  ),
              enabledBorder: textFieldType == CustomTextFieldType.underline
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: disabledColor,
                      ),
                    )
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(borderRadius ?? 8),
                      ),
                      borderSide: BorderSide(
                        color: borderColor ?? disabledColor,
                      ),
                    ),
              focusedBorder: textFieldType == CustomTextFieldType.underline
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isPicker! ? disabledColor : primaryColor500,
                      ),
                    )
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(borderRadius ?? 8),
                      ),
                      borderSide: BorderSide(
                        color: isPicker!
                            ? borderColor ?? disabledColor
                            : primaryColor500,
                        width: isPicker! ? 1 : 2,
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(
                maxHeight: 20,
                maxWidth: 85,
              ),
              prefixIcon: prefix,
              suffixIconConstraints: const BoxConstraints(
                maxHeight: 20,
              ),
              suffix: rightIcon,
            ),
          ),
        ),
      ],
    );
  }
}
