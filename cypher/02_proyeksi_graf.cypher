// ============================================================
// 02 - PROYEKSI GRAF GDS
// Tujuan  : membuat salinan graf di memori (RAM) supaya algoritma
//           Graph Data Science (GDS) bisa berjalan cepat.
// Syarat  : plugin Graph Data Science sudah terpasang, dan
//           file 01_import_data.cypher sudah dijalankan.
// Catatan : proyeksi bukan database baru. Isinya hanya salinan
//           graf untuk analisis.
// ============================================================


// ------------------------------------------------------------
// 2.1 (Opsional) Hapus proyeksi lama
// Jalankan hanya jika proyeksi 'movielensGraph' sudah pernah
// dibuat. Parameter false membuat query tidak error bila proyeksi
// belum ada.
// ------------------------------------------------------------
CALL gds.graph.drop('movielensGraph', false)
YIELD graphName;


// ------------------------------------------------------------
// 2.2 Buat proyeksi 'movielensGraph'
// - ['User', 'Movie']   : node yang disalin.
// - RATED               : relasi yang disalin.
// - UNDIRECTED          : relasi dibaca dua arah (pengguna -> film
//                         dan film -> pengguna).
// - properties: rating  : nilai rating ikut disalin.
// Hasil di laporan:
//   nodeCount         = 10.352 (610 User + 9.742 Movie)
//   relationshipCount = 201.672 (100.836 rating x 2 arah)
//   projectMillis     = 1.955 ms
// ------------------------------------------------------------
CALL gds.graph.project(
  'movielensGraph',
  ['User', 'Movie'],
  {
    RATED: {
      orientation: 'UNDIRECTED',
      properties: ['rating']
    }
  }
);
