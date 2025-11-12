import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:protopos/controller/main_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

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
          _handlePrintRequest(message.message);
          print("====Payload===: ${message.message}");
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    mainController.webViewController = controller;
  }

  void _logout() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
    await prefsAuth.remove('tokenlogin');
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
      print("Error parsing print JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to process receipt data from the web'),
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

  void _showTestPrintDialog() {
    const String dummyJsonPayload = '''
    {
        "header": "Talasi",
        "sub_header": "Original Receipt",
        "details": {
            "date": "11-11-2025",
            "time": "19:59:00",
            "location": "Test Location",
            "bill_no": "TEST-001"
        },
        "items": [
            {
                "name": "Test Product A",
                "quantity_str": "1",
                "price_formatted": "10.000",
                "subtotal_formatted": "10.000"
            },
            {
                "name": "Test Product B",
                "quantity_str": "2",
                "price_formatted": "5.000",
                "subtotal_formatted": "10.000"
            }
        ],
        "totals": {
            "subtotal": "Rp 20.000",
            "discount": "Rp 0",
            "tax": "Rp 2.000",
            "grand_total": "Rp 22.000"
        },
        "footer": {
            "payment_method": "Test",
            "thank_you_note": "Thank you for testing!"
        }
    }
    ''';
    _handlePrintRequest(dummyJsonPayload);
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 60.0),
        child: FloatingActionButton(
          onPressed: _showTestPrintDialog,
          tooltip: 'Test Print Dialog',
          child: const Icon(Icons.print, size: 22),
        ),
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
  String _status = "Scanning printers...";
  StreamSubscription<List<Printer>>? _devicesSubscription;

  @override
  void initState() {
    super.initState();
    _startScan();
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
            width: 6,
          ),
          PosColumn(
            text: get(item['subtotal_formatted']),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      bytes += generator.hr();
      final totals = data['totals'] ?? {};
      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 6),
        PosColumn(text: get(totals['subtotal']), width: 6),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Discount', width: 6),
        PosColumn(text: get(totals['discount']), width: 6),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Tax', width: 6),
        PosColumn(text: get(totals['tax']), width: 6),
      ]);
      bytes += generator.hr(ch: ' ');
      bytes += generator.row([
        PosColumn(
          text: 'GRAND TOTAL',
          width: 6,
          styles: const PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text: get(totals['grand_total']),
          width: 6,
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
      bytes += generator.feed(3);
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
      print("Print error: $e");
      setState(() {
        _status = "Error: $e";
      });
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
        AlertDialog(
          title: Text("Print Receipt"),
          content: SizedBox(
            width: 300,
            child: _isLoading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(_status),
                    ],
                  )
                : _printers.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_status, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _startScan,
                        child: Text("Scan Again"),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<Printer>(
                        value: _selectedPrinter != null
                            ? _printers.firstWhere(
                                (p) => p.address == _selectedPrinter!.address,
                                orElse: () => _printers.first,
                              )
                            : null,
                        items: _printers.map((printer) {
                          return DropdownMenuItem<Printer>(
                            value: printer,
                            child: Text(
                              printer.name ?? "Unknown (${printer.address})",
                            ),
                          );
                        }).toList(),
                        onChanged: (Printer? newPrinter) {
                          setState(() {
                            _selectedPrinter = newPrinter;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(_status),
                    ],
                  ),
          ),
          actions: [
            ElevatedButton(
              onPressed: _isLoading || _selectedPrinter == null
                  ? null
                  : _performPrint,
              child: const Text("Print"),
            ),
            SizedBox(height: 5),
            Align(
              child: Column(
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ),
          ],
        ),

        // overlay loading print
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
