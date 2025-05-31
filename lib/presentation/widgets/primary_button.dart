// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:safeships_flutter/theme.dart';

class PrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool? isLoading;
  final bool? isEnabled;
  final Color? color;
  final double? width;
  final double? height;
  final double? elevation;
  final Color? borderColor;
  final Color? foregroundColor;
  final bool? reverseLoading;
  final double? radius;
  const PrimaryButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.isLoading = false,
    this.reverseLoading = false,
    this.isEnabled = true,
    this.color,
    this.width,
    this.height,
    this.elevation,
    this.borderColor,
    this.radius,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled!
          ? !isLoading!
              ? onPressed
              : () {}
          : () {},
      style: ElevatedButton.styleFrom(
        elevation: elevation ?? 1,
        // padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(radius ?? 6),
          ),
          side: borderColor != null
              ? BorderSide(
                  color: borderColor!,
                )
              : BorderSide.none,
        ),
        backgroundColor: isEnabled!
            ? !isLoading!
                ? color ?? primaryColor500
                : reverseLoading!
                    ? whiteColor
                    : disabledColor
            : disabledColor,
        foregroundColor: foregroundColor ?? primaryColor200,
        shadowColor: elevation != 0 ? null : transparentColor,
        minimumSize: Size(
          width ?? double.infinity,
          height ?? 40,
        ),
      ),
      child: !isLoading!
          ? child
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: reverseLoading! ? primaryColor500 : whiteColor,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Loading",
                  style: primaryTextStyle.copyWith(
                    fontWeight: semibold,
                    fontSize: 16,
                    color: reverseLoading! ? primaryColor500 : whiteColor,
                  ),
                )
              ],
            ),
    );
  }
}
