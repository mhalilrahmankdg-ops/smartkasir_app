import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kelola_karyawan_page.dart';

// Halaman Profil Toko & Footer Struk Kasir (SharedPreferences)
class ProfilTokoPage extends StatefulWidget {
  const ProfilTokoPage({super.key});

  @override
  State<ProfilTokoPage> createState() => _ProfilTokoPageState();
}

class _ProfilTokoPageState extends State<ProfilTokoPage> {
  final _namaTokoController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noWaController = TextEditingController();
  final _footerController = TextEditingController();

  bool _sedangMenyimpan = false;

  // Nama kasir yang sedang bertugas
  String _activeCashierName = 'Belum Ditentukan';

  @override
  void initState() {
    super.initState();
    _muatProfilToko();
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _alamatController.dispose();
    _noWaController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  // Baca pengaturan toko dari SharedPreferences
  Future<void> _muatProfilToko() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _namaTokoController.text =
          prefs.getString('nama_toko') ?? 'SmartKasir Poliban';
      _alamatController.text = prefs.getString('alamat_toko') ??
          'Jl. Brigjend H. Hasan Basry, Banjarmasin';
      _noWaController.text = prefs.getString('no_wa') ?? '081234567890';
      _footerController.text = prefs.getString('footer_struk') ??
          'Terima Kasih Atas Kunjungan Anda! Barang yang sudah dibeli tidak dapat ditukar.';
      _activeCashierName =
          prefs.getString('active_cashier_name') ?? 'Belum Ditentukan';
    });
  }

  // Simpan pengaturan toko ke SharedPreferences
  Future<void> _simpanProfilToko() async {
    setState(() => _sedangMenyimpan = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_toko', _namaTokoController.text.trim());
    await prefs.setString('alamat_toko', _alamatController.text.trim());
    await prefs.setString('no_wa', _noWaController.text.trim());
    await prefs.setString('footer_struk', _footerController.text.trim());

    if (!mounted) return;
    setState(() => _sedangMenyimpan = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Identitas toko berhasil diperbarui!'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profil & Pengaturan Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu ringkasan kasir bertugas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Icon(Icons.storefront, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KASIR AKTIF SHIFT INI',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _activeCashierName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KelolaKaryawanPage(),
                        ),
                      );
                      // Muat ulang nama kasir aktif setelah kembali
                      _muatProfilToko();
                    },
                    icon: const Icon(Icons.people_outline, size: 16),
                    label: const Text('Kelola'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'IDENTITAS USAHA & STRUK KASIR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 12),

            // 1. Nama toko
            TextFormField(
              controller: _namaTokoController,
              decoration: InputDecoration(
                labelText: 'Nama Toko / Usaha',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // 2. Alamat toko
            TextFormField(
              controller: _alamatController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Alamat Toko',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // 3. Kontak WhatsApp
            TextFormField(
              controller: _noWaController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor WhatsApp / Kontak Toko',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // 4. Catatan kaki struk
            TextFormField(
              controller: _footerController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Catatan Kaki Struk (Footer Nota)',
                hintText: 'Contoh: Terima kasih atas kunjungan Anda!',
                prefixIcon: const Icon(Icons.receipt_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Tombol simpan
            ElevatedButton.icon(
              onPressed: _sedangMenyimpan ? null : _simpanProfilToko,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _sedangMenyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _sedangMenyimpan ? 'Menyimpan Pengaturan...' : 'Simpan Profil Toko',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}