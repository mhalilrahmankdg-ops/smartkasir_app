class Produk {
  final int id;
  final String nama;
  final String kategori;
  final double harga;
  final int stok;
  final String gambarUrl;
  final int diskonPersen;

  const Produk({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.gambarUrl,
    this.diskonPersen = 0,
  });
}

final List<Produk> daftarProdukDummy = [
  const Produk(
    id: 1,
    nama: 'Kopi Susu Gula Aren 250ml',
    kategori: 'Minuman',
    harga: 18000,
    stok: 24,
    gambarUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=300',
    diskonPersen: 20,
  ),
  const Produk(
    id: 2,
    nama: 'Roti Bakar Cokelat Keju',
    kategori: 'Makanan',
    harga: 15000,
    stok: 5,
    gambarUrl: 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?w=300',
  ),
  const Produk(
    id: 3,
    nama: 'Matcha Latte Ice',
    kategori: 'Minuman',
    harga: 22000,
    stok: 0,
    gambarUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=300',
  ),
  const Produk(
    id: 4,
    nama: 'Nasi Goreng Banjar Spesial',
    kategori: 'Makanan',
    harga: 25000,
    stok: 12,
    gambarUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=300',
    diskonPersen: 10,
  ),
  const Produk(
    id: 5,
    nama: 'Kentang Goreng Crispy',
    kategori: 'Snack',
    harga: 12000,
    stok: 18,
    gambarUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=300',
  ),
  const Produk(
    id: 6,
    nama: 'Air Mineral Botol 600ml',
    kategori: 'Minuman',
    harga: 5000,
    stok: 40,
    gambarUrl: 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=300',
  ),
];