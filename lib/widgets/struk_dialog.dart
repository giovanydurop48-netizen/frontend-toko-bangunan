import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:frontend_toko_bangunan/services/printer_service.dart';

class StrukDialog extends StatefulWidget {
  final Map<String, dynamic> dataTransaksi;
  final VoidCallback onSuccess;

  const StrukDialog({
    super.key,
    required this.dataTransaksi,
    required this.onSuccess,
  });

  @override
  State<StrukDialog> createState() => _StrukDialogState();
}

class _StrukDialogState extends State<StrukDialog> {
  final PrinterService _printerService = PrinterService();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  void _initBluetooth() async {
    final devices = await _printerService.getPairedDevices();
    setState(() {
      _devices = devices;
      if (_devices.isNotEmpty) {
        _selectedDevice = _devices.first;
      }
    });
  }

  void _prosesCetak() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih perangkat printer bluetooth terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isPrinting = true);
    final sukses = await _printerService.cetakStruk(
      device: _selectedDevice!,
      dataTransaksi: widget.dataTransaksi,
    );
    setState(() => _isPrinting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sukses ? 'Struk berhasil dicetak!' : 'Gagal mencetak struk'),
          backgroundColor: sukses ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Transaksi Berhasil'),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih Printer Bluetooth:'),
            const SizedBox(height: 6),
            DropdownButton<BluetoothDevice>(
              isExpanded: true,
              value: _selectedDevice,
              hint: const Text('Pilih Printer'),
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.name ?? 'Unknown Device'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedDevice = val);
              },
            ),
            const Divider(height: 24),
            Text(
              'Kembalian: Rp ${widget.dataTransaksi['kembalian'].toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: _isPrinting ? null : _prosesCetak,
          icon: const Icon(Icons.print),
          label: Text(_isPrinting ? 'Mencetak...' : 'Cetak Struk'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          onPressed: () {
            widget.onSuccess();
            Navigator.pop(context);
          },
          child: const Text('Selesai'),
        ),
      ],
    );
  }
}