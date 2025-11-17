import 'package:desktop_time_tracker/constants/colors.dart';
import 'package:desktop_time_tracker/view/common%20widgets/text_widget.dart';
import 'package:flutter/material.dart';

class SessionInfo extends StatelessWidget {
  final String label;
  final String value;
  const SessionInfo({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextWidget(text: label, textSize: 24, textColor: AppColors.subtextColor,),
        const SizedBox(height: 2),
        CommonTextWidget(text: value, textSize: 26, textColor: AppColors.secondaryColor,),
      ],
    );
  }
}
