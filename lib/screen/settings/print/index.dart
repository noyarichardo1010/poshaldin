import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
// import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  final FlutterThermalPrinter _printer = FlutterThermalPrinter.instance;
  List<Printer> _printers = [];
  Printer? _selectedPrinter;
  bool _isLoading = true;
  bool _isPrinterSaved = false;
  String _status = "Scanning printers..";
  StreamSubscription<List<Printer>>? _devicesSubscription;

  @override
  void initState() {
    super.initState();
    _loadSavedPrinterAndScan();
  }

  Future<void> _loadSavedPrinterAndScan() async {
    await _loadSavedPrinter();
    _startScan();
  }

  Future<void> _loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPrinterJson = prefs.getString('selected_printer');
    if (savedPrinterJson != null) {
      final printerMap = json.decode(savedPrinterJson);
      setState(() {
        _selectedPrinter = Printer(
          name: printerMap['name'],
          address: printerMap['address'],
          connectionType: ConnectionType.values.firstWhere(
            (e) => e.toString() == printerMap['connectionType'],
          ),
        );
        _isPrinterSaved = true;
      });
    }
  }

  Future<void> _savePrinter(Printer printer) async {
    final prefs = await SharedPreferences.getInstance();
    final printerMap = {
      'name': printer.name,
      'address': printer.address,
      'connectionType': printer.connectionType.toString(),
    };
    await prefs.setString('selected_printer', json.encode(printerMap));
    setState(() {
      _isPrinterSaved = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Printer ${printer.name} saved successfully.'),
      ),
    );
  }

  Future<void> _clearSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_printer');
    setState(() {
      _isPrinterSaved = false;
      _selectedPrinter = _printers.isNotEmpty ? _printers.first : null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue,
        content: Text(
          'Printer setting cleared. You can now select a new printer.',
        ),
      ),
    );
  }

  Future<void> _checkBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            'Permission Required! Please grant Bluetooth and Location permissions to scan printers.',
          ),
        ),
      );
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
              _status = "Select a printer and save.";
              // If a printer was saved, try to keep it selected
              if (_selectedPrinter != null) {
                final savedAddress = _selectedPrinter!.address;
                _selectedPrinter = _printers.firstWhere(
                  (p) => p.address == savedAddress,
                  orElse: () => _printers.first,
                );
              } else {
                _selectedPrinter = _printers.first;
              }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Printer",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_printers.isEmpty)
              Center(
                child: Column(
                  children: [
                    Text(_status, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _startScan,
                      child: const Text("Scan Again"),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey),
                            color: _isPrinterSaved
                                ? Colors.grey[200]
                                : Colors.transparent,
                          ),
                          child: DropdownButton<Printer>(
                            value: _selectedPrinter,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _printers.map((printer) {
                              return DropdownMenuItem<Printer>(
                                value: printer,
                                child: Text(
                                  printer.name ??
                                      "Unknown (${printer.address})",
                                ),
                              );
                            }).toList(),
                            onChanged: _isPrinterSaved
                                ? null
                                : (Printer? newPrinter) {
                                    setState(() {
                                      _selectedPrinter = newPrinter;
                                    });
                                  },
                          ),
                        ),
                      ),
                      if (_isPrinterSaved)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSavedPrinter,
                          tooltip: "Change Printer",
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (!_isPrinterSaved)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedPrinter == null
                            ? null
                            : () => _savePrinter(_selectedPrinter!),
                        child: const Text("Save Settings"),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _startScan,
                      child: const Text("Rescan"),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Text(_status, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
