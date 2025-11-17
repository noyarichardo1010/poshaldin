import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:protopos/controller/webview/viewcontrol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

import 'package:permission_handler/permission_handler.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  final MainController mainController = Get.find();
  // List<String> printBridgeLogs = [];

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
      Get.dialog(
        PrintDialog(receiptData: receiptData),
        barrierDismissible: false,
      );
    } catch (e) {
      debugPrint("Error parsing print JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to process receipt data from the pos'),
        ),
      );
      // Get.snackbar(
      //   "Error Print",
      //   "Failed to process receipt data from the web",
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    }
  }

  // void _showPrintBridgeLogs() {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: Text("Log PrintBridge (${printBridgeLogs.length})"),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         height: 300,
  //         child: printBridgeLogs.isEmpty
  //             ? Center(child: Text("Belum ada pesan dari Web."))
  //             : ListView.builder(
  //                 itemCount: printBridgeLogs.length,
  //                 itemBuilder: (context, index) {
  //                   final log = printBridgeLogs[index];
  //                   return Card(
  //                     margin: EdgeInsets.only(bottom: 8),
  //                     child: Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text(log, style: TextStyle(fontSize: 13)),
  //                     ),
  //                   );
  //                 },
  //               ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             setState(() {
  //               printBridgeLogs.clear();
  //             });
  //             Navigator.pop(context);
  //           },
  //           child: Text("Clear"),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text("Tutup"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.reload();
        },
        child: SafeArea(child: WebViewWidget(controller: controller)),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   heroTag: "btnLog",
          //   // onPressed: () => _showPrintBridgeLogs(),
          //   onPressed: () {
          //     controller.runJavaScript("""
          //   PrintBridge.postMessage(JSON.stringify({
          //     test: "coba PrintBridge",
          //     time: "${DateTime.now()}"
          //   }));
          // """);
          //     _showPrintBridgeLogs();
          //   },

          //   tooltip: 'Lihat Log PrintBridge',
          //   child: const Icon(Icons.list),
          // ),
          // SizedBox(height: 16),
          // FloatingActionButton(
          //   heroTag: "btnTestBridge",
          //   onPressed: () {
          //     controller.runJavaScript("""
          //   PrintBridge.postMessage(JSON.stringify({
          //     test: "coba PrintBridge",
          //     time: "${DateTime.now()}"
          //   }));
          // """);
          //   },
          //   tooltip: 'Test PrintBridge',
          //   child: const Icon(Icons.bug_report),
          // ),
          // SizedBox(height: 16),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// PRINT DIALOG
// -------------------------------------------------------------
class PrintDialog extends StatefulWidget {
  final Map<String, dynamic> receiptData;
  const PrintDialog({super.key, required this.receiptData});

  @override
  State<PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  final FlutterThermalPrinter _printer = FlutterThermalPrinter.instance;
  List<Printer> _printers = [];
  Printer? _selectedPrinter;
  bool _isLoading = true;
  bool _isPrinting = false;
  bool _isAutoPrinting = false;
  String _status = "Initializing...";
  StreamSubscription<List<Printer>>? _devicesSubscription;

  @override
  void initState() {
    super.initState();
    _loadSavedPrinterAndPrint();
  }

  Future<void> _loadSavedPrinterAndPrint() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPrinterJson = prefs.getString('selected_printer');

    if (savedPrinterJson != null) {
      final printerMap = json.decode(savedPrinterJson);
      final savedPrinter = Printer(
        name: printerMap['name'],
        address: printerMap['address'],
        connectionType: ConnectionType.values.firstWhere(
          (e) => e.toString() == printerMap['connectionType'],
        ),
      );
      setState(() {
        _selectedPrinter = savedPrinter;
        _isAutoPrinting = true;
        _status = "Printing to saved printer: ${savedPrinter.name}";
      });
      await _performPrint();
    } else {
      // No saved printer, proceed with scanning
      _startScan();
    }
  }

  Future<void> _checkBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      Get.snackbar(
        "Permission Required",
        "Please grant Bluetooth and Location permissions to scan printers.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      return;
    }
  }

  void _startScan() async {
    setState(() {
      _isLoading = true;
      _status = "Checking permissions...";
    });

    await _checkBluetoothPermissions();

    setState(() {
      _isLoading = true;
      _status = "Scanning printers...";
      _printers = [];
    });

    _devicesSubscription?.cancel();

    try {
      await _printer.getPrinters(
        connectionTypes: [
          ConnectionType.USB,
          ConnectionType.BLE,
          ConnectionType.NETWORK,
        ],
      );

      _devicesSubscription = _printer.devicesStream.listen(
        (List<Printer> event) {
          setState(() {
            _printers = event;
            _isLoading = false;
            if (_printers.isEmpty) {
              _status =
                  "No printer found.\nEnsure printer is paired in Bluetooth Settings.";
            } else {
              _status = "Select printer to print";
              _selectedPrinter ??= _printers.first;
            }
          });
        },
        onError: (e) {
          setState(() {
            _isLoading = false;
            _status = "Error scanning: $e";
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = "Scan failed: $e";
      });
    }
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    super.dispose();
  }

  String get(dynamic key, [String defaultValue = '']) {
    if (key == null) return defaultValue;
    return key.toString();
  }

  Future<void> _performPrint() async {
    if (_selectedPrinter == null) {
      Get.snackbar("Error", "Please select a printer first.");
      return;
    }

    setState(() {
      _isPrinting = true; //loading
      _status = "Printing in progress...";
    });

    try {
      await _printer.connect(_selectedPrinter!);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      final data = widget.receiptData;

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
          // PosColumn(
          //   text: get(item['subtotal_formatted']),
          //   width: 12,
          //   styles: const PosStyles(align: PosAlign.right),
          // ),
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

      await _printer.printData(_selectedPrinter!, bytes);
      await _printer.disconnect(_selectedPrinter!);

      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Success, Receipt printed successfully! '),
        ),
      );
    } catch (e) {
      debugPrint("Print error: $e");
      if (mounted) {
        setState(() {
          _status = "Error: $e";
        });
      }
      // If auto-printing fails, close the dialog and show an error.
      if (_isAutoPrinting) {
        Get.back(); // Close the printing dialog
        Get.snackbar(
          "Print Failed",
          "Could not connect to saved printer. Please check printer status or change printer in settings.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
      try {
        await _printer.disconnect(_selectedPrinter!);
      } catch (_) {}
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isPrinting)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Printing, please wait...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
