import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:protopos/assets.dart';
// import 'package:protopos/controller/print/receipt_data.dart';
import 'package:protopos/controller/webview/viewcontrol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

// import 'package:permission_handler/permission_handler.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  final MainController mainController = Get.find();
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'ExitBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _logout();
        },
      )
      ..addJavaScriptChannel(
        'PrintBridge',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint("====Payload===: ${message.message}");
          // setState(() {
          //   printBridgeLogs.add(message.message);
          // });
          _handlePrintRequest(message.message);
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    mainController.webViewController = controller;
  }

  void _logout() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
    await prefsAuth.remove('keylogin');
    Get.offAllNamed('/login');
  }

  void _handlePrintRequest(String jsonPayload) {
    try {
      final Map<String, dynamic> receiptData = json.decode(jsonPayload);
      _printReceipt(receiptData);
    } catch (e) {
      debugPrint("Error parsing print JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: errorColor,
          content: Text('Failed to process receipt data from the pos'),
        ),
      );
    }
  }

  String get(dynamic key, [String defaultValue = '']) {
    if (key == null) return defaultValue;
    return key.toString();
  }

  Future<void> _printReceipt(Map<String, dynamic> data) async {
    setState(() {
      _isPrinting = true;
    });

    // Show loading dialog
    Get.dialog(
      const PopScope(
        canPop: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: whiteColor),
              SizedBox(height: 16),
              Text(
                "Printing, please wait...",
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    final prefs = await SharedPreferences.getInstance();
    final savedPrinterJson = prefs.getString('selected_printer');

    if (savedPrinterJson == null) {
      if (Get.isDialogOpen!) {
        Get.back(); // Close the loading dialog
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: errorColor,
          content: Text(
            'Please setup your printer in settings, then reprint from Reports Menu',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final printerMap = json.decode(savedPrinterJson);
    final selectedPrinter = Printer(
      name: printerMap['name'],
      address: printerMap['address'],
      connectionType: ConnectionType.values.firstWhere(
        (e) => e.toString() == printerMap['connectionType'],
      ),
    );

    final FlutterThermalPrinter printer = FlutterThermalPrinter.instance;

    try {
      await printer.connect(selectedPrinter);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.text(
        get(data['header']),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          fontType: PosFontType.fontA,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      bytes += generator.text(
        get(data['sub_header']),
        styles: const PosStyles(
          align: PosAlign.center,
          fontType: PosFontType.fontB,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );

      // bytes += generator.hr(len: 40);

      final details = data['details'] ?? {};
      bytes += generator.row([
        PosColumn(text: 'Date', width: 4),
        PosColumn(text: ': ${get(details['date'])}', width: 8),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Time', width: 4),
        PosColumn(text: ': ${get(details['time'])}', width: 8),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Location', width: 4),
        PosColumn(text: ': ${get(details['location'])}', width: 8),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Bill No', width: 4),
        PosColumn(text: ': ${get(details['bill_no'])}', width: 8),
      ]);

      bytes += generator.hr(len: 40);

      final items = data['items'] ?? [];
      for (var item in items) {
        bytes += generator.text(
          get(item['name']),
          styles: const PosStyles(
            fontType: PosFontType.fontB,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        );

        bytes += generator.row([
          PosColumn(
            text:
                "  ${get(item['quantity_str'])} x ${get(item['price_formatted'])}",
            width: 12,
            styles: const PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontB,
              height: PosTextSize.size1,
            ),
          ),
        ]);
      }

      bytes += generator.hr(len: 40);

      final totals = data['totals'] ?? {};
      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 6),
        PosColumn(
          text: get(totals['subtotal']),
          width: 6,
          styles: const PosStyles(
            fontType: PosFontType.fontB,
            height: PosTextSize.size1,
          ),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: 'Discount', width: 6),
        PosColumn(
          text: get(totals['discount']),
          width: 6,
          styles: const PosStyles(
            fontType: PosFontType.fontB,
            height: PosTextSize.size1,
          ),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: 'Gratuity', width: 6),
        PosColumn(
          text: get(totals['gratuity']),
          width: 6,
          styles: const PosStyles(
            fontType: PosFontType.fontB,
            height: PosTextSize.size1,
          ),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: 'Tax', width: 6),
        PosColumn(
          text: get(totals['tax']),
          width: 6,
          styles: const PosStyles(
            fontType: PosFontType.fontB,
            height: PosTextSize.size1,
          ),
        ),
      ]);

      bytes += generator.hr(len: 40);

      bytes += generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: const PosStyles(
            bold: true,
            fontType: PosFontType.fontB,
            height: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: get(totals['grand_total']),
          width: 6,
          styles: const PosStyles(
            bold: true,
            fontType: PosFontType.fontB,
            height: PosTextSize.size2,
          ),
        ),
      ]);

      bytes += generator.hr(len: 40);

      final footer = data['footer'] ?? {};
      bytes += generator.text(
        "Payment Method: ${get(footer['payment_method'])}",
        styles: const PosStyles(
          align: PosAlign.center,
          fontType: PosFontType.fontB,
          height: PosTextSize.size1,
        ),
      );

      bytes += generator.text(
        get(footer['thank_you_note'], "Thank you for your purchase!"),
        styles: const PosStyles(
          align: PosAlign.center,
          fontType: PosFontType.fontB,
          height: PosTextSize.size1,
        ),
      );

      bytes += generator.feed(0);
      bytes += generator.cut();

      await printer.printData(selectedPrinter, bytes);
      await printer.disconnect(selectedPrinter);

      if (Get.isDialogOpen!) Get.back();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: successColor,
          content: const Text('Success, Receipt printed successfully!'),
        ),
      );
    } catch (e) {
      debugPrint("Print error: $e");

      if (Get.isDialogOpen!) Get.back();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: errorColor,
          content: const Text(
            'Could not connect to saved printer. Please check printer status or change printer in settings.',
          ),
        ),
      );

      try {
        await printer.disconnect(selectedPrinter);
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.reload();
        },
        child: SafeArea(child: WebViewWidget(controller: controller)),
      ),

      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     // FloatingActionButton(
      //     //   heroTag: "btnLog",
      //     //   // onPressed: () => _showPrintBridgeLogs(),
      //     //   onPressed: () {
      //     //     controller.runJavaScript("""
      //     //   PrintBridge.postMessage(JSON.stringify({
      //     //     test: "coba PrintBridge",
      //     //     time: "${DateTime.now()}"
      //     //   }));
      //     // """);
      //     //     _showPrintBridgeLogs();
      //     //   },

      //     //   tooltip: 'Lihat Log PrintBridge',
      //     //   child: const Icon(Icons.list),
      //     // ),
      //     // SizedBox(height: 16),
      //     // FloatingActionButton(
      //     //   heroTag: "btnTestBridge",
      //     //   onPressed: () {
      //     //     controller.runJavaScript("""
      //     //   PrintBridge.postMessage(JSON.stringify({
      //     //     test: "coba PrintBridge",
      //     //     time: "${DateTime.now()}"
      //     //   }));
      //     // """);
      //     //   },
      //     //   tooltip: 'Test PrintBridge',
      //     //   child: const Icon(Icons.bug_report),
      //     // ),
      //     // SizedBox(height: 16),
      //   ],
      // ),
    );
  }
}
