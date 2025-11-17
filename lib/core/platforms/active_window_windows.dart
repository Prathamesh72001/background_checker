import 'dart:developer';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_helpers;
import 'package:win32/win32.dart' as win32;
import '../platforms/active_window.dart';

// UI Automation GUIDs
const CLSID_CUIAutomation = '{FF48DBA4-60EF-4201-AA87-54103EEF594E}';
const IID_IUIAutomation = '{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}';

Future<ActiveWindow?> getActiveWindowWindows() async {
  final hwnd = win32.GetForegroundWindow();
  if (hwnd == 0) return null;

  // ──────────────────────────────────────────────
  // FETCH WINDOW PROCESS + TITLE
  // ──────────────────────────────────────────────
  final pidPtr = ffi_helpers.calloc<ffi.Uint32>();
  win32.GetWindowThreadProcessId(hwnd, pidPtr);
  final pid = pidPtr.value;

  try {
    final len = win32.GetWindowTextLength(hwnd) + 1;
    final titlePtr =
        ffi_helpers.calloc<ffi.Uint16>(len).cast<ffi_helpers.Utf16>();

    try {
      win32.GetWindowText(hwnd, titlePtr, len);
      final title = ffi_helpers.Utf16Pointer(titlePtr).toDartString();

      // Extract process name
      String processName = "unknown";

      final hProcess = win32.OpenProcess(
        win32.PROCESS_QUERY_LIMITED_INFORMATION,
        win32.FALSE,
        pid,
      );

      if (hProcess != 0) {
        final namePtr =
            ffi_helpers.calloc<ffi.Uint16>(260).cast<ffi_helpers.Utf16>();
        final sizePtr = ffi_helpers.calloc<ffi.Uint32>()..value = 260;

        try {
          final result = win32.QueryFullProcessImageName(
            hProcess,
            0,
            namePtr,
            sizePtr,
          );

          if (result != 0) {
            processName = ffi_helpers.Utf16Pointer(namePtr).toDartString();
            final parts = processName.split("\\");
            processName = parts.last;
          }
        } finally {
          ffi_helpers.calloc.free(namePtr);
          ffi_helpers.calloc.free(sizePtr);
        }

        win32.CloseHandle(hProcess);
      }

      // ──────────────────────────────────────────────
      // IF BROWSER → TRY READING URL USING UI AUTOMATION
      // ──────────────────────────────────────────────
      log(processName.toLowerCase(), name: "browserUrl");

      final isBrowser = processName.toLowerCase() == "msedge.exe" ||
          processName.toLowerCase() == "chrome.exe" ||
          processName.toLowerCase() == "brave.exe" ||
          processName.toLowerCase() == "opera.exe" ||
          processName.toLowerCase().contains("browser");

      String? browserUrl;

      // if (isBrowser) {
      //   browserUrl = _readBrowserUrl(hwnd);
      //   log(browserUrl.toString(), name: "browserUrl");
      // }

      return ActiveWindow(
        appName: processName,
        title: title,
        url: browserUrl, // NEW FIELD (you must add this in your model)
      );
    } finally {
      ffi_helpers.calloc.free(titlePtr);
    }
  } finally {
    ffi_helpers.calloc.free(pidPtr);
  }
}

// ──────────────────────────────────────────────
// UI AUTOMATION — READ BROWSER URL
// ──────────────────────────────────────────────
String? _readBrowserUrl(int hwnd) {
  try {
    final clsidAutomation = win32.GUIDFromString(CLSID_CUIAutomation);
    final iidAutomation = win32.GUIDFromString(IID_IUIAutomation);

    final automationPtr = ffi_helpers.calloc<ffi.Pointer<win32.COMObject>>();

    final hr = win32.CoCreateInstance(
      clsidAutomation,
      ffi.nullptr,
      win32.CLSCTX_INPROC_SERVER,
      iidAutomation,
      automationPtr.cast(),
    );

    if (win32.FAILED(hr) || automationPtr.value == ffi.nullptr) {
      ffi_helpers.calloc.free(automationPtr);
      return null;
    }

    final automation = win32.IUIAutomation(automationPtr.value);

    // Get root element for this HWND
    final rootPtr = ffi_helpers.calloc<ffi.Pointer<win32.COMObject>>();
    automation.elementFromHandle(hwnd, rootPtr);
    if (rootPtr.value == ffi.nullptr) {
      automation.release();
      ffi_helpers.calloc.free(automationPtr);
      ffi_helpers.calloc.free(clsidAutomation);
      ffi_helpers.calloc.free(iidAutomation);
      ffi_helpers.calloc.free(rootPtr);
      return null;
    }
    final rootElement = win32.IUIAutomationElement(rootPtr.value);

    String? tryValuePatternOnElement(win32.IUIAutomationElement element) {
      final patternPtr = ffi_helpers.calloc<ffi.Pointer<win32.COMObject>>();
      element.getCurrentPattern(win32.UIA_ValuePatternId, patternPtr);
      if (patternPtr.value == ffi.nullptr) {
        ffi_helpers.calloc.free(patternPtr);
        return null;
      }

      final vp = win32.IUIAutomationValuePattern(patternPtr.value);
      final valuePtr = vp.currentValue; // Pointer<Utf16> for your win32 version
      String? v;
      if (valuePtr != ffi.nullptr) {
        v = ffi_helpers.Utf16Pointer(valuePtr).toDartString();
        win32.SysFreeString(valuePtr.cast());
      }
      vp.release();
      ffi_helpers.calloc.free(patternPtr);
      if (v == null) return null;
      v = v.trim();
      return v.isEmpty ? null : v;
    }

    // strategy A: simple ControlType == Edit (fast)
    final conditionPtr = ffi_helpers.calloc<ffi.Pointer<win32.COMObject>>();
    final variantPtr = ffi_helpers.calloc<win32.VARIANT>();
    final variant = variantPtr.ref;
    variant.vt = win32.VT_I4;
    variant.lVal = win32.UIA_EditControlTypeId;

    automation.createPropertyCondition(
        win32.UIA_ControlTypePropertyId, variantPtr.ref, conditionPtr);
    String? url;
    if (conditionPtr.value != ffi.nullptr) {
      final condition = win32.IUIAutomationCondition(conditionPtr.value);
      final foundPtr = ffi_helpers.calloc<ffi.Pointer<win32.COMObject>>();
      rootElement.findFirst(win32.TreeScope_Subtree, condition.ptr, foundPtr);

      if (foundPtr.value != ffi.nullptr) {
        final addressBar = win32.IUIAutomationElement(foundPtr.value);
        url = tryValuePatternOnElement(addressBar);
        addressBar.release();
      }

      // cleanup for this strategy
      ffi_helpers.calloc.free(foundPtr);
      condition.release();
    }

    // free variant/condition memory used by strategy A
    ffi_helpers.calloc.free(variantPtr);
    ffi_helpers.calloc.free(conditionPtr);

    // strategy B (fallback): find elements which expose ValuePattern
    if (url == null || url.isEmpty) {
      // Create condition: IsValuePatternAvailable == true
      final cond2Ptr = ffi_helpers.calloc<ffi.Pointer<win32.COMObject>>();
      final v2Ptr = ffi_helpers.calloc<win32.VARIANT>();
      final v2 = v2Ptr.ref;
      v2.vt = win32.VT_BOOL;
      // VARIANT_TRUE is -1 in COM (some bindings provide VARIANT_TRUE constant)
      v2.boolVal = true; // variant true

      // UIA_IsValuePatternAvailablePropertyId constant used to detect elements
      automation.createPropertyCondition(
          win32.UIA_IsValuePatternAvailablePropertyId, v2Ptr.ref, cond2Ptr);

      if (cond2Ptr.value != ffi.nullptr) {
        final cond2 = win32.IUIAutomationCondition(cond2Ptr.value);

        // find ALL matching elements
        final resultsPtr = ffi_helpers.calloc<ffi.Pointer<win32.COMObject>>();
        rootElement.findAll(win32.TreeScope_Subtree, cond2.ptr, resultsPtr);

        if (resultsPtr.value != ffi.nullptr) {
          final array = win32.IUIAutomationElementArray(resultsPtr.value);
          final len = array.length;

          for (var i = 0; i < len && (url == null || url.isEmpty); i++) {
            final elemPtr = ffi_helpers.calloc<ffi.Pointer<win32.COMObject>>();
            array.getElement(i, elemPtr);
            if (elemPtr.value != ffi.nullptr) {
              final elem = win32.IUIAutomationElement(elemPtr.value);
              final candidate = tryValuePatternOnElement(elem);
              elem.release();
              if (candidate != null && _looksLikeUrl(candidate)) {
                url = candidate;
              }
            }
            ffi_helpers.calloc.free(elemPtr);
          }

          array.release();
        }

        // free results pointer
        ffi_helpers.calloc.free(resultsPtr);
        cond2.release();
      }

      // free fallback variant and condition pointers
      ffi_helpers.calloc.free(v2Ptr);
      ffi_helpers.calloc.free(cond2Ptr);
    }

    // clean up remaining COM objects + pointers
    rootElement.release();
    automation.release();

    ffi_helpers.calloc.free(rootPtr);
    ffi_helpers.calloc.free(automationPtr);
    ffi_helpers.calloc.free(clsidAutomation);
    ffi_helpers.calloc.free(iidAutomation);

    if (url == null) return null;
    url = url.trim();
    return url.isEmpty ? null : url;
  } catch (e) {
    log(e.toString(), name: "browserUrl");
    return null;
  }
}

// small helper to heuristically check URL-like string
bool _looksLikeUrl(String s) {
  final lower = s.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) return true;
  if (lower.contains('.') && !lower.contains(' ')) return true;
  return false;
}
