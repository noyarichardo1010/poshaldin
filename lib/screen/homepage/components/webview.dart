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
    final prefs = await SharedPreferences.getInstance();
    final savedPrinterJson = prefs.getString('selected_printer');

    if (savedPrinterJson == null) {
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
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        get(data['sub_header']),
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

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
      bytes += generator.hr();

      final items = data['items'] ?? [];
      for (var item in items) {
        bytes += generator.text(get(item['name']));
        bytes += generator.row([
          PosColumn(
            text:
                "  ${get(item['quantity_str'])} x ${get(item['price_formatted'])}",
            width: 12,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      bytes += generator.hr();
      final totals = data['totals'] ?? {};
      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 4),
        PosColumn(
          text: get(totals['subtotal']),
          width: 8,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Discount', width: 4),
        PosColumn(
          text: get(totals['discount']),
          width: 8,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Gratuity', width: 4),
        PosColumn(
          text: get(totals['gratuity']),
          width: 8,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Tax', width: 4),
        PosColumn(
          text: get(totals['tax']),
          width: 8,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.hr(ch: ' ');
      bytes += generator.row([
        PosColumn(
          text: 'GRAND TOTAL',
          width: 4,
          styles: const PosStyles(
            bold: true,
            height: PosTextSize.size2,
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: get(totals['grand_total']),
          width: 8,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      ]);
      bytes += generator.hr();

      final footer = data['footer'] ?? {};
      bytes += generator.text(
        "Payment Method: ${get(footer['payment_method'])}",
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(1);
      bytes += generator.text(
        get(footer['thank_you_note'], "Thank you for your purchase!"),
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(0);
      bytes += generator.cut();

      await printer.printData(selectedPrinter, bytes);
      await printer.disconnect(selectedPrinter);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: successColor,
          content: Text('Success, Receipt printed successfully! '),
        ),
      );
    } catch (e) {
      debugPrint("Print error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: errorColor,
          content: Text(
            'Could not connect to saved printer. Please check printer status or change printer in settings.',
          ),
        ),
      );
      try {
        await printer.disconnect(selectedPrinter);
      } catch (_) {}
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
