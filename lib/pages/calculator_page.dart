import 'package:flutter/material.dart';
import '../services/exchange_service.dart';
import '../pages/sarankesan_page.dart';
import '../pages/profile_page.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  int _selectedIndex = 0;

  // Controllers
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();

  // Dropdown variables
  String _selectedDevice = 'Kipas';
  String _selectedTimeZone = 'WIB';
  String _selectedCurrency = 'IDR';

  // Exchange rate
  double? _conversionRate;
  final ExchangeRateService _exchangeRateService = ExchangeRateService();

  // Function to fetch exchange rate
  Future<void> _fetchExchangeRate() async {
    try {
      final data = await _exchangeRateService.getExchangeRates('IDR');
      setState(() {
        _conversionRate = data['conversion_rates'][_selectedCurrency];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil nilai tukar mata uang.')),
      );
    }
  }

  // Calculation logic
  void _calculateEmission() {
    if (_jumlahController.text.isEmpty || _waktuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data!')),
      );
      return;
    }

    if (int.tryParse(_jumlahController.text) == null ||
        double.tryParse(_waktuController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Input harus berupa angka valid!')),
      );
      return;
    }

    if (_conversionRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil nilai tukar mata uang.')),
      );
      return;
    }

    final int jumlah = int.parse(_jumlahController.text);
    final double waktu = double.parse(_waktuController.text);

    // Constants for electricity consumption (kWh per hour per device)
    final Map<String, double> deviceConsumption = {
      'AC': 1.5,
      'Kipas': 0.05,
      'Kulkas': 0.1,
      'Lampu': 0.015,
    };

    // Electricity rates based on time zones
    final Map<String, double> timeZoneRates = {
      'WIB': 1500, // IDR/kWh
      'WITA': 1600,
      'WIT': 1700,
      'London': 0.2, // GBP/kWh
      'Jepang': 25, // JPY/kWh
    };

    // Calculate electricity usage in kWh
    final double kWhUsage = jumlah * waktu * deviceConsumption[_selectedDevice]!;

    // Emission factor
    const double emissionFactor = 0.7;
    final double totalEmission = kWhUsage * emissionFactor; // in kg CO₂

    // Calculate cost based on selected time zone and currency
    final double totalCost =
        kWhUsage * timeZoneRates[_selectedTimeZone]! * _conversionRate!;

    // Show result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Perhitungan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penggunaan listrik: ${kWhUsage.toStringAsFixed(2)} kWh',
                style: const TextStyle(color: Colors.white)),
            Text('Emisi karbon: ${totalEmission.toStringAsFixed(2)} kg CO₂',
                style: const TextStyle(color: Colors.white)),
            Text('Zona Waktu: $_selectedTimeZone',
                style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Biaya listrik: ${totalCost.toStringAsFixed(2)} $_selectedCurrency',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CalculatorPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SaranKesanPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage(email: '',)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 66, 97),
      appBar: AppBar(
        title: const Text('Hitung Emisi Karbon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih jenis alat elektronik:', style: TextStyle(color: Colors.white)),
              DropdownButton<String>(
                dropdownColor: Colors.grey,
                value: _selectedDevice,
                items: ['AC', 'Kipas', 'Kulkas', 'Lampu']
                    .map((device) => DropdownMenuItem(
                          value: device,
                          child: Text(device, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDevice = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextField(
                style: const TextStyle(color: Colors.white),
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah alat elektronik',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                style: const TextStyle(color: Colors.white),
                controller: _waktuController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Lama waktu penggunaan (jam)',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Pilih zona waktu:', style: TextStyle(color: Colors.white)),
              DropdownButton<String>(
                dropdownColor: Colors.grey,
                value: _selectedTimeZone,
                items: ['WIB', 'WITA', 'WIT', 'London', 'Jepang']
                    .map((zone) => DropdownMenuItem(
                          value: zone,
                          child: Text(zone, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTimeZone = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text('Pilih mata uang:', style: TextStyle(color: Colors.white)),
              DropdownButton<String>(
                dropdownColor: Colors.grey,
                value: _selectedCurrency,
                items: ['USD', 'IDR', 'EUR', 'GBP', 'JPY']
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                  await _fetchExchangeRate();
                },
              ),
              const SizedBox(height: 32),

              // Custom Outlined Button
              Center(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.white),
                  ),
                  onPressed: _calculateEmission,
                  child: const Text(
                    'Hitung Emisi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
