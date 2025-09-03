import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onBarcodeScanned;
  final VoidCallback onClose;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeScanned,
    required this.onClose,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startBarcodeScan();
  }

  Future<void> _startBarcodeScan() async {
    try {
      // Verifica permissão da câmera
      final status = await Permission.camera.request();
      if (status.isDenied) {
        setState(() {
          _errorMessage =
              'Permissão da câmera é necessária para escanear códigos de barras';
          _isLoading = false;
        });
        return;
      }

      // Executa o scanner
      final result = await BarcodeScanner.scan(
        options: const ScanOptions(
          strings: {
            'cancel': 'Cancelar',
            'flash_on': 'Luz ligada',
            'flash_off': 'Luz desligada',
          },
          restrictFormat: [
            BarcodeFormat.ean8,
            BarcodeFormat.ean13,
            BarcodeFormat.code39,
            BarcodeFormat.code93,
            BarcodeFormat.code128,
          ],
          useCamera: -1, // Câmera padrão
          autoEnableFlash: false,
        ),
      );

      // Se o usuário cancelou o scan
      if (result.type == ResultType.Cancelled) {
        widget.onClose();
        return;
      }

      // Se encontrou um código
      if (result.rawContent.isNotEmpty) {
        widget.onBarcodeScanned(result.rawContent);
      }
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = e.code == 'BarcodeScanner.cameraAccessDenied'
            ? 'Permissão da câmera negada!'
            : 'Erro ao escanear código: $e';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao escanear código: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _startBarcodeScan,
                  child: const Text('Tentar novamente'),
                ),
                TextButton(
                  onPressed: widget.onClose,
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: Text('Escaneando código de barras...')),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
