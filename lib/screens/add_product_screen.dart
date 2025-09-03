import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../models/product_model.dart';
import '../widgets/barcode_scanner_widget.dart';

class AddProductScreen extends StatefulWidget {
  final Function(Product) onProductAdded;

  const AddProductScreen({super.key, required this.onProductAdded});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _brandController = TextEditingController();
  final _storeController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedUnit = 'un';
  DateTime _purchaseDate = DateTime.now();
  DateTime? _expirationDate;
  bool _showScanner = false;

  final List<String> _units = ['g', 'kg', 'ml', 'L', 'un'];
  final List<String> _productTypes = [
    'Alimento',
    'Bebida',
    'Limpeza',
    'Higiene',
    'Outros',
  ];

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPurchaseDate
          ? _purchaseDate
          : _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _expirationDate = picked;
        }
      });
    }
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _showScanner = true;
    });
  }

  void _onBarcodeScanned(String barcode) {
    setState(() {
      _showScanner = false;
      // Aqui você pode adicionar lógica para buscar informações do produto
      // com base no código de barras (barcode)
      // Por enquanto, vamos apenas preencher o campo de nome com o código
      _nameController.text = 'Produto $barcode';
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Código de barras lido: $barcode')));
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return Scaffold(
        body: BarcodeScannerWidget(
          onBarcodeScanned: _onBarcodeScanned,
          onClose: () => setState(() => _showScanner = false),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Produto'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Nome do Produto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                    tooltip: 'Escanear código de barras',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _typeController.text.isEmpty
                    ? _productTypes[0]
                    : _typeController.text,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Produto',
                  border: OutlineInputBorder(),
                ),
                items: _productTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _typeController.text = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      items: _units.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marca (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _storeController,
                decoration: const InputDecoration(
                  labelText: 'Mercado (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Preço (R\$)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data da Compra'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_purchaseDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: const Text('Data de Validade (opcional)'),
                subtitle: Text(
                  _expirationDate != null
                      ? DateFormat('dd/MM/yyyy').format(_expirationDate!)
                      : 'Não definido',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final product = Product(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      type: _typeController.text.isNotEmpty
                          ? _typeController.text
                          : _productTypes[0],
                      quantity: double.parse(_quantityController.text),
                      unit: _selectedUnit,
                      purchaseDate: _purchaseDate,
                      expirationDate: _expirationDate,
                      brand: _brandController.text.isNotEmpty
                          ? _brandController.text
                          : null,
                      store: _storeController.text.isNotEmpty
                          ? _storeController.text
                          : null,
                      price: double.parse(_priceController.text),
                    );

                    // Retorna o produto para a tela anterior
                    Navigator.pop(context, product);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Salvar Produto',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _quantityController.dispose();
    _brandController.dispose();
    _storeController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
