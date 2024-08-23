import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'bluetoothManager.dart';

class PrintOptionsScreen extends StatefulWidget {
  @override
  _PrintOptionsScreenState createState() => _PrintOptionsScreenState();
}

class _PrintOptionsScreenState extends State<PrintOptionsScreen> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() async {
    devices = await bluetoothManager.getAvailableDevices();
    setState(() {});
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print Options'),
        backgroundColor: const Color.fromARGB(255, 218, 255, 68),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            final isConnected = bluetoothManager.isConnected() &&
                bluetoothManager.connectedDevice?.address == device.address;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  device.name ?? 'Unknown Device',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  device.address ?? 'No Address',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: isConnected
                    ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                    : Icon(Icons.bluetooth, color: Colors.grey, size: 24),
                onTap: () async {
                  if (isConnected) {
                    await bluetoothManager.disconnectPrinter();
                   
                  } else {
                    await bluetoothManager.connectToPrinter(device);
                    
                  }
                  _loadDevices();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
