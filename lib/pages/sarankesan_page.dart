import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/saran_kesan_model.dart';
import '../pages/calculator_page.dart';
import '../pages/profile_page.dart';

class SaranKesanPage extends StatefulWidget {
  const SaranKesanPage({super.key});

  @override
  _SaranKesanPageState createState() => _SaranKesanPageState();
}

class _SaranKesanPageState extends State<SaranKesanPage> {
  int _selectedIndex = 0;
  final TextEditingController _saranController = TextEditingController();
  final TextEditingController _kesanController = TextEditingController();
  late Box<SaranKesan> _box;
  bool _isAdding = false; // Mode input atau tidak
  int? _editingIndex; // Menyimpan index yang sedang diedit

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SaranKesanAdapter());
    }
    _box = await Hive.openBox<SaranKesan>('saranKesan');
    setState(() {});
  }

  void _saveData() {
    final saran = _saranController.text.trim();
    final kesan = _kesanController.text.trim();

    if (saran.isEmpty || kesan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data')),
      );
      return;
    }

    if (_editingIndex == null) {
      final newSaranKesan = SaranKesan(saran: saran, kesanPesan: kesan);
      _box.add(newSaranKesan);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan')),
      );
    } else {
      // Edit item yang ada
      _box.putAt(_editingIndex!, SaranKesan(saran: saran, kesanPesan: kesan));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diperbarui')),
      );
    }

    // Bersihkan input dan kembali ke mode list
    _saranController.clear();
    _kesanController.clear();
    setState(() {
      _isAdding = false;
      _editingIndex = null;
    });
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

  void _editItem(int index) {
    final saranKesan = _box.getAt(index);
    _saranController.text = saranKesan?.saran ?? '';
    _kesanController.text = saranKesan?.kesanPesan ?? '';

    setState(() {
      _isAdding = true;
      _editingIndex = index;
    });
  }

  void _deleteItem(int index) {
    _box.deleteAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 66, 97),
      appBar: AppBar(
        title: const Text('Saran & Kesan'),
        leading: _isAdding
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isAdding = false;
                    _editingIndex = null;
                  });
                },
              )
            : null,
      ),
      body: _isAdding
          ? _buildInputForm() // Mode input
          : _buildGroupedList(), // Mode list
      floatingActionButton: _isAdding
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isAdding = true;
                });
              },
              backgroundColor: Colors.white, // Ganti latar belakang tombol menjadi putih
              foregroundColor: Colors.black, // Ganti warna ikon menjadi hitam
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.grey,
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

  Widget _buildInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _saranController,
            decoration: const InputDecoration(
              labelText: 'Saran',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.white)
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _kesanController,
            decoration: const InputDecoration(
              labelText: 'Kesan dan Pesan',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.white)
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.white),
                  ),
            onPressed: _saveData,
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList() {
    return ValueListenableBuilder<Box<SaranKesan>>(
      valueListenable: _box.listenable(),
      builder: (context, box, _) {
        final saranKesanList = box.values.toList().cast<SaranKesan>();

        if (saranKesanList.isEmpty) {
          return const Center(child: Text('Belum ada data', style: TextStyle(color: Colors.white)));
        }

        // Memisahkan berdasarkan kategori "Saran" dan "Kesan Pesan"
        final saranList = saranKesanList
            .where((saranKesan) => saranKesan.saran.isNotEmpty)
            .toList();
        final kesanList = saranKesanList
            .where((saranKesan) => saranKesan.kesanPesan.isNotEmpty)
            .toList();

        return ListView(
          children: [
            // Menampilkan Saran
            if (saranList.isNotEmpty)
              ExpansionTile(
                title: const Text('Saran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                children: saranList.map((saranKesan) {
                  final index = saranList.indexOf(saranKesan);
                  return ListTile(
                    title: Text(saranKesan.saran, style: const TextStyle(color: Colors.white)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _deleteItem(index),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            // Menampilkan Kesan dan Pesan
            if (kesanList.isNotEmpty)
              ExpansionTile(
                title: const Text('Kesan dan Pesan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                children: kesanList.map((saranKesan) {
                  final index = kesanList.indexOf(saranKesan);
                  return ListTile(
                    title: Text(saranKesan.kesanPesan, style: const TextStyle(color: Colors.white)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _deleteItem(index),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}
