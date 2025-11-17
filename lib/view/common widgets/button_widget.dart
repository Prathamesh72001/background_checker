
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class CommonButtonWidget extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;
  final double hoverScale;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final String tooltip;

  const CommonButtonWidget({
    super.key,
    required this.child,
    required this.onPressed,
    this.tooltip = "",
    required this.height,
    required this.width, this.backgroundColor, this.hoverScale = 1.15,
  });

  @override
  State<CommonButtonWidget> createState() => _CommonButtonWidgetState();
}

class _CommonButtonWidgetState extends State<CommonButtonWidget>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      verticalOffset: (widget.height/1.5) * Sizes.scaleFactor,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _scale = widget.hoverScale),
        onExit: (_) => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Container(height: widget.height * Sizes.scaleFactor,width: widget.width *Sizes.scaleFactor,constraints: BoxConstraints(maxWidth: 750),
            decoration: BoxDecoration(color: widget.backgroundColor ?? AppColors.secondaryColor,borderRadius: BorderRadius.circular(100),boxShadow: [BoxShadow(color: Colors.transparent)]),
            alignment: Alignment.center,
            child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
