
import 'package:boxicons/boxicons.dart';
import 'package:desktop_time_tracker/view/common%20widgets/text_widget.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class CommonTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool isSearch; // <-- SEARCH MODE
  final TextInputType keyboardType;
  final Color? fillColor;
  final Color? borderColor;
  final Icon prefixIcon;

  CommonTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.isSearch = false,
    this.keyboardType = TextInputType.text,
    this.fillColor,
    this.borderColor, required this.prefixIcon,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// ----------------- LABEL (HIDDEN FOR SEARCH) -----------------
        if (!widget.isSearch) ...[
          CommonTextWidget(
            text: widget.label,
            textColor: AppColors.textColor,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 6),
        ],

        Container(
          constraints: BoxConstraints(maxWidth: 750),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? obscure : false,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.fillColor ?? AppColors.primaryColor,

              /// HINT only for search
              hintText: widget.isSearch ? widget.label : null,

              contentPadding: EdgeInsets.symmetric(
                horizontal: 15 * Sizes.scaleFactor,
                vertical: 15 * Sizes.scaleFactor,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: widget.borderColor ?? AppColors.primaryColor,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: widget.borderColor ?? AppColors.textColor,
                  width: 1.5,
                ),
              ),

              suffixIcon: _buildSuffixIcon(),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 10 * Sizes.scaleFactor),
                child: widget.prefixIcon,
              ),
            ),

            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  /// ---------- PASSWORD + SEARCH + NORMAL SUFFIX ICON ----------
  Widget? _buildSuffixIcon() {
    // PASSWORD FIELD
    if (widget.isPassword) {
      return Padding(
        padding: EdgeInsets.only(right: 10 * Sizes.scaleFactor),
        child: IconButton(
          icon: Icon(
            obscure ? Boxicons.bxs_hide : Boxicons.bxs_show,
          ),
          onPressed: () => setState(() => obscure = !obscure),
        ),
      );
    }

    // SEARCH FIELD
    if (widget.isSearch) {
      // empty -> mic icon
      if (widget.controller.text.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(right: 10 * Sizes.scaleFactor),
          child: IconButton(
            icon: const Icon(Boxicons.bx_microphone),
            onPressed: () {
              // TODO: implement voice search
            },
          ),
        );
      }

      // not empty -> clear button
      return Padding(
        padding: EdgeInsets.only(right: 10 * Sizes.scaleFactor),
        child: IconButton(
          icon: const Icon(Boxicons.bxs_x_circle),
          onPressed: () {
            widget.controller.clear();
            setState(() {});
          },
        ),
      );
    }

    // NORMAL FIELD → show clear when text present
    if (widget.controller.text.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: 10 * Sizes.scaleFactor),
        child: IconButton(
          icon: const Icon(Boxicons.bxs_x_circle),
          onPressed: () {
            widget.controller.clear();
            setState(() {});
          },
        ),
      );
    }

    return null;
  }
}
