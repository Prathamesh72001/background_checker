import 'package:desktop_time_tracker/constants/colors.dart';
import 'package:desktop_time_tracker/constants/sizes.dart';
import 'package:desktop_time_tracker/constants/strings.dart';
import 'package:desktop_time_tracker/view/common%20widgets/text_widget.dart';
import 'package:desktop_time_tracker/view/screens/dashboard/widget/session_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionTile extends StatelessWidget {
  final String softwareName;
  final String windowTitle;
  final DateTime startTime;
  final DateTime endTime;

  const SessionTile({
    super.key,
    required this.softwareName,
    required this.windowTitle,
    required this.startTime,
    required this.endTime,
  });

  // -----------------------------
  // FORMATTERS
  // -----------------------------

  String _formatTime(DateTime time) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(time);
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // -----------------------------
  // WINDOW TITLE TREE BUILDER
  // -----------------------------
  List<Widget> buildTitleTree(String title) {
    final parts = title.split(RegExp(r'\s*[-–—−]\s*'));

    return List.generate(parts.length, (index) {
      return Padding(
        padding: EdgeInsets.only(left: (index * 20).toDouble()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (index > 0)
              Container(
                margin: EdgeInsets.only(right: 10 * Sizes.scaleFactor),
                height: 12 * Sizes.scaleFactor,
                width: 12 * Sizes.scaleFactor,
                decoration: BoxDecoration(
                    color: AppColors.subtextColor,
                    borderRadius: BorderRadius.circular(100)),
              ),
            Expanded(
              child: CommonTextWidget(
                text: parts[index],
                fontWeight: index == 0 ? FontWeight.w700 : FontWeight.w500,
                textSize: index == 0 ? 28 : 24,
                textColor: AppColors.subtextColor,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = endTime.difference(startTime);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOFTWARE NAME
          CommonTextWidget(
            text: softwareName.replaceAll(".exe", "").toUpperCase(),
            fontWeight: FontWeight.w700,
            textSize: 32,
            textColor: AppColors.secondaryColor,
            textAlign: TextAlign.start,
          ),

          const SizedBox(height: 6),

          // WINDOW TITLE TREE
          ...buildTitleTree(windowTitle),
          const SizedBox(height: 14),

          // TIME ROW
          MediaQuery.of(context).size.width < 750
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      SessionInfo(
                          label: Strings.start, value: _formatTime(startTime)),
                      Divider(
                        color: AppColors.subtextColor,
                      ),
                      SessionInfo(
                          label: Strings.end, value: _formatTime(endTime)),
                      Divider(
                        color: AppColors.subtextColor,
                      ),
                      SessionInfo(
                        label: Strings.duration,
                        value: _formatDuration(duration),
                      )
                    ])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SessionInfo(
                        label: Strings.start, value: _formatTime(startTime)),
                    SessionInfo(
                        label: Strings.end, value: _formatTime(endTime)),
                    SessionInfo(
                      label: Strings.duration,
                      value: _formatDuration(duration),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
