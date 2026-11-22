import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/produk.dart';
import '../models/karyawan.dart';
import '../models/pelanggan.dart';

// Pengelola database SQLite SmartKasir (pola Singleton)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartkasir.db');
    return _database!;
  }

  // Inisialisasi database (Chrome Web & Android), versi 3 = ada tabel pelanggan
  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        filePath,
        version: 3,
        onCreate: _createDB,
        onUpgrade: _onUpgradeDB,
      );
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  // Dipakai saat database dibuat pertama kali (pengguna baru)
  Future _createDB(Database db, int version) async {
    // 1. Tabel produk (M11)
    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode_produk TEXT UNIQUE,
        nama_produk TEXT NOT NULL,
        kategori TEXT NOT NULL,
        harga_beli REAL NOT NULL,
        harga_jual REAL NOT NULL,
        stok INTEGER NOT NULL,
        gambar_path TEXT,
        diskon_persen INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');
    for (final produk in produkAwalSQLite) {
      await db.insert('produk', produk.toMap());
    }

    // 2. Tabel karyawan (M12)
    await _buatTabelKaryawan(db);

    // 3. Tabel pelanggan (M13)
    await _buatTabelPelanggan(db);
  }

  // Dipakai saat database lama dinaikkan versinya
  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _buatTabelKaryawan(db);
    }
    if (oldVersion < 3) {
      await _buatTabelPelanggan(db);
    }
  }

  // Tabel karyawan + 2 staf awal
  Future _buatTabelKaryawan(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS karyawan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_karyawan TEXT NOT NULL,
        pin TEXT NOT NULL,
        peran TEXT NOT NULL
      )
    ''');
    await db.rawInsert('''
      INSERT INTO karyawan (nama_karyawan, pin, peran)
      VALUES ('Ahmad Kasir', '1234', 'Kasir')
    ''');
    await db.rawInsert('''
      INSERT INTO karyawan (nama_karyawan, pin, peran)
      VALUES ('Siti Supervisor', '8888', 'Manajer')
    ''');
  }

  // Tabel pelanggan + 2 pelanggan awal (lengkap dengan koordinat Banjarmasin)
  Future _buatTabelPelanggan(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pelanggan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode_pelanggan TEXT UNIQUE NOT NULL,
        nama_pelanggan TEXT NOT NULL,
        nomor_wa TEXT NOT NULL,
        alamat TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.rawInsert('''
      INSERT INTO pelanggan (kode_pelanggan, nama_pelanggan, nomor_wa, alamat, latitude, longitude, created_at)
      VALUES ('CUST-001', 'Warung Bu Siti', '081234567890', 'Jl. Hasan Basri No. 12, Banjarmasin', -3.298280, 114.588820, '2026-11-01 09:00:00')
    ''');
    await db.rawInsert('''
      INSERT INTO pelanggan (kode_pelanggan, nama_pelanggan, nomor_wa, alamat, latitude, longitude, created_at)
      VALUES ('CUST-002', 'Budi Santoso', '085712345678', 'Jl. Kayu Tangi II No. 45, Banjarmasin', -3.295410, 114.582150, '2026-11-02 10:30:00')
    ''');
  }

  // ==========================================
  // CRUD TABEL PELANGGAN (M13)
  // ==========================================

  Future<int> insertPelanggan(Pelanggan pelanggan) async {
    final db = await instance.database;
    return await db.insert('pelanggan', pelanggan.toMap());
  }

  Future<List<Pelanggan>> getAllPelanggan() async {
    final db = await instance.database;
    final result = await db.query('pelanggan', orderBy: 'id DESC');
    return result.map((json) => Pelanggan.fromMap(json)).toList();
  }

  // Cari berdasarkan nama, nomor WA, atau kode member
  Future<List<Pelanggan>> searchPelanggan(String keyword) async {
    final db = await instance.database;
    final result = await db.query(
      'pelanggan',
      where: 'nama_pelanggan LIKE ? OR nomor_wa LIKE ? OR kode_pelanggan LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'id DESC',
    );
    return result.map((json) => Pelanggan.fromMap(json)).toList();
  }

  Future<int> updatePelanggan(Pelanggan pelanggan) async {
    final db = await instance.database;
    return await db.update(
      'pelanggan',
      pelanggan.toMap(),
      where: 'id = ?',
      whereArgs: [pelanggan.id],
    );
  }

  Future<int> deletePelanggan(int id) async {
    final db = await instance.database;
    return await db.delete('pelanggan', where: 'id = ?', whereArgs: [id]);
  }

  // Hitung total pelanggan (untuk ringkasan di Dashboard / Tab Toko)
  Future<int> countPelanggan() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM pelanggan');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==========================================
  // CRUD TABEL KARYAWAN (M12)
  // ==========================================

  Future<int> insertKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return await db.insert('karyawan', karyawan.toMap());
  }

  Future<List<Karyawan>> getAllKaryawan() async {
    final db = await instance.database;
    final result = await db.query('karyawan', orderBy: 'id ASC');
    return result.map((json) => Karyawan.fromMap(json)).toList();
  }

  Future<int> updateKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return await db.update(
      'karyawan',
      karyawan.toMap(),
      where: 'id = ?',
      whereArgs: [karyawan.id],
    );
  }

  Future<int> deleteKaryawan(int id) async {
    final db = await instance.database;
    return await db.delete('karyawan', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // CRUD TABEL PRODUK (M11)
  // ==========================================

  Future<int> insertProduk(Produk produk) async {
    final db = await instance.database;
    return await db.insert(
      'produk',
      produk.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Produk>> getAllProduk() async {
    final db = await instance.database;
    final result = await db.query('produk', orderBy: 'id DESC');
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  Future<List<Produk>> getProdukByKategori(String kategori) async {
    final db = await instance.database;
    if (kategori == 'Semua') return await getAllProduk();
    final result = await db.query(
      'produk',
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'id DESC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  Future<List<Produk>> searchProduk(String keyword) async {
    final db = await instance.database;
    final result = await db.query(
      'produk',
      where: 'nama_produk LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  Future<int> updateProduk(Produk produk) async {
    final db = await instance.database;
    return await db.update(
      'produk',
      produk.toMap(),
      where: 'id = ?',
      whereArgs: [produk.id],
    );
  }

  Future<int> deleteProduk(int id) async {
    final db = await instance.database;
    return await db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countProduk() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM produk');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}