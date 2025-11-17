import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_helpers;
import 'package:win32/win32.dart' as win32;

import '../platforms/active_window.dart';

Future<ActiveWindow?> getActiveWindowWindows() async {
  // get the active window handle
  final hwnd = win32.GetForegroundWindow();
  if (hwnd == 0) return null;

  // get process id
  final pidPtr = ffi_helpers.calloc<ffi.Uint32>();
  win32.GetWindowThreadProcessId(hwnd, pidPtr);
  final pid = pidPtr.value;

  try {
    // get window title length
    final len = win32.GetWindowTextLength(hwnd) + 1;

    // allocate UTF16 buffer properly:
    // calloc<Uint16>() is required, then cast to Utf16*
    final titlePtr = ffi_helpers.calloc<ffi.Uint16>(len).cast<ffi_helpers.Utf16>();

    try {
      win32.GetWindowText(hwnd, titlePtr, len);

      // Explicit extension to avoid ambiguity:
      final title =
      ffi_helpers.Utf16Pointer(titlePtr).toDartString();

      // get process name
      String processName = "unknown";

      final hProcess = win32.OpenProcess(
        win32.PROCESS_QUERY_LIMITED_INFORMATION,
        win32.FALSE,
        pid,
      );

      if (hProcess != 0) {
        final namePtr = ffi_helpers.calloc<ffi.Uint16>(260).cast<ffi_helpers.Utf16>();
        final sizePtr = ffi_helpers.calloc<ffi.Uint32>()..value = 260;

        try {
          final result = win32.QueryFullProcessImageName(
            hProcess,
            0,
            namePtr,
            sizePtr,
          );

          if (result != 0) {
            processName =
                ffi_helpers.Utf16Pointer(namePtr).toDartString();

            // Extract only last part (Chrome.exe, Spotify.exe)
            final parts = processName.split("\\");
            processName = parts.last;
          }
        } finally {
          ffi_helpers.calloc.free(namePtr);
          ffi_helpers.calloc.free(sizePtr);
        }

        win32.CloseHandle(hProcess);
      }

      return ActiveWindow(
        appName: processName,
        title: title,
      );
    } finally {
      ffi_helpers.calloc.free(titlePtr);
    }
  } finally {
    ffi_helpers.calloc.free(pidPtr);
  }
}
