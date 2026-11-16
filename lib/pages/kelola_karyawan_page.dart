import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/karyawan.dart';
import '../helpers/database_helper.dart';
import 'form_karyawan_page.dart';

// Halaman daftar staf kasir + penetapan Kasir Aktif
class KelolaKaryawanPage extends StatefulWidget {
  const KelolaKaryawanPage({super.key});

  @override
  State<KelolaKaryawanPage> createState() => _KelolaKaryawanPageState();
}

class _KelolaKaryawanPageState extends State<KelolaKaryawanPage> {
  // Menampung hasil query daftar karyawan dari SQLite
  late Future<List<Karyawan>> _karyawanFuture;

  // Kasir aktif yang tersimpan di SharedPreferences
  int? _activeCashierId;
  String _activeCashierName = 'Belum Ditentukan';

  @override
  void initState() {
    super.initState();
    // Isi dulu supaya FutureBuilder tidak error saat build pertama
    _karyawanFuture = DatabaseHelper.instance.getAllKaryawan();
    _muatData();
  }

  // Muat daftar karyawan (SQLite) dan kasir aktif (SharedPreferences)
  Future<void> _muatData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _activeCashierId = prefs.getInt('active_cashier_id');
      _activeCashierName =
          prefs.getString('active_cashier_name') ?? 'Belum Ditentukan';
      _karyawanFuture = DatabaseHelper.instance.getAllKaryawan();
    });
  }

  // Tetapkan kasir yang sedang bertugas
  Future<void> _setKasirAktif(Karyawan staf) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_cashier_id', staf.id!);
    await prefs.setString('active_cashier_name', staf.namaKaryawan);

    if (!mounted) return;
    setState(() {
      _activeCashierId = staf.id;
      _activeCashierName = staf.namaKaryawan;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kasir aktif giliran saat ini: "${staf.namaKaryawan}"'),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dialog konfirmasi hapus staf
  void _konfirmasiHapusKaryawan(Karyawan staf) {
    // Proteksi: kasir yang sedang aktif tidak boleh dihapus
    if (staf.id == _activeCashierId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Karyawan "${staf.namaKaryawan}" sedang aktif bertugas! '
            'Ganti kasir aktif terlebih dahulu sebelum menghapus.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Karyawan?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus staf "${staf.namaKaryawan}" '
          '(${staf.peran})? Data tidak dapat dipulihkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.deleteKaryawan(staf.id!);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data staf "${staf.namaKaryawan}" telah dihapus!'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _muatData();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Badge peran dengan warna berbeda
  Widget _buildRoleBadge(String peran) {
    Color bg;
    Color fg;
    if (peran == 'Manajer') {
      bg = Colors.amber.shade100;
      fg = Colors.amber.shade900;
    } else if (peran == 'Admin') {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade900;
    } else {
      bg = Colors.green.shade100;
      fg = Colors.green.shade900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        peran,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Kelola Karyawan & Kasir',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. Banner kasir aktif
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.verified_user, color: Colors.amber, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KASIR AKTIF BERJAGA SAAT INI',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _activeCashierName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Daftar karyawan dari SQLite
          Expanded(
            child: FutureBuilder<List<Karyawan>>(
              future: _karyawanFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan database: ${snapshot.error}'),
                  );
                }

                final daftarStaf = snapshot.data ?? [];
                if (daftarStaf.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data karyawan terdaftar.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: daftarStaf.length,
                  itemBuilder: (context, index) {
                    final staf = daftarStaf[index];
                    final isActive = staf.id == _activeCashierId;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? const Color(0xFF1E3A8A)
                              : Colors.grey.shade200,
                          foregroundColor:
                              isActive ? Colors.white : Colors.grey.shade700,
                          child: Text(
                            staf.namaKaryawan.isNotEmpty
                                ? staf.namaKaryawan[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                staf.namaKaryawan,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildRoleBadge(staf.peran),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'PIN: •••• | ID: #${staf.id}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Set kasir aktif
                            IconButton(
                              icon: Icon(
                                isActive ? Icons.star : Icons.star_border,
                                color:
                                    isActive ? Colors.amber.shade700 : Colors.grey,
                              ),
                              tooltip:
                                  isActive ? 'Kasir Aktif' : 'Set sebagai Kasir Aktif',
                              onPressed: () => _setKasirAktif(staf),
                            ),
                            // Edit
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF1E3A8A),
                              ),
                              tooltip: 'Edit Data',
                              onPressed: () async {
                                final refresh = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FormKaryawanPage(karyawan: staf),
                                  ),
                                );
                                if (refresh == true) _muatData();
                              },
                            ),
                            // Hapus
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              tooltip: 'Hapus Staf',
                              onPressed: () => _konfirmasiHapusKaryawan(staf),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormKaryawanPage()),
          );
          if (refresh == true) _muatData();
        },
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Karyawan'),
      ),
    );
  }
}