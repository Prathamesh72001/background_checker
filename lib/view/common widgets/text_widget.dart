import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/sizes.dart';

class CommonTextWidget extends StatelessWidget {
  final String text;
  final double? textSize;
  final FontWeight? fontWeight;
  final int maxLines;
  final TextOverflow overflow;
  final Color? textColor;
  final TextAlign textAlign;

  const CommonTextWidget({
    super.key,
    required this.text,
    this.textSize,
    this.fontWeight,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
    this.textColor,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: GoogleFonts.baloo2(
        fontSize: (textSize ?? 25) * Sizes.scaleFactor,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
