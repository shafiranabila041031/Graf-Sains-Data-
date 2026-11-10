// ============================================================
// 03 - COMMUNITY DETECTION DENGAN LEIDEN
// Tujuan  : mencari kelompok (komunitas) di dalam graf. Satu
//           komunitas berisi node yang banyak saling terhubung.
// Syarat  : proyeksi 'movielensGraph' sudah dibuat
//           (02_proyeksi_graf.cypher).
// Catatan : Leiden memakai unsur acak, jadi angka dan ID komunitas
//           bisa sedikit berbeda setiap kali dijalankan.
// ============================================================


// ------------------------------------------------------------
// 3.1 Leiden mode STATS (hanya menghitung, tidak menyimpan hasil)
// communityCount = jumlah komunitas.
// modularity (Q) = seberapa jelas graf terbagi menjadi kelompok.
//                  Makin tinggi makin jelas.
// Hasil di laporan: 24 komunitas, Q = 0.2776, waktu 907 ms.
// ------------------------------------------------------------
CALL gds.leiden.stats('movielensGraph')
YIELD communityCount, modularity
RETURN communityCount AS Total_Komunitas_Leiden,
       round(modularity, 4) AS Skor_Modularitas_Q;


// ------------------------------------------------------------
// 3.2 Leiden mode WRITE (menyimpan nomor komunitas ke setiap node)
// Nomor komunitas disimpan di properti leidenCommunity, sehingga
// bisa dipakai di query biasa (file 04 dan 05).
// Hasil di laporan:
//   waktu total (Neo4j Browser) = 3.593 ms
//   preProcessing 17 ms | compute 929 ms | postProcessing 120 ms |
//   write 1.847 ms
//   pengaturan: theta 0.01, gamma 1.0, tolerance 0.0001,
//               maxLevels 10, concurrency 4
//   didConverge = TRUE, ranLevels = 2
//   10.352 node diberi nomor komunitas
//   communityCount = 25, modularity = 0.2769
//   (level 1 = 0.2524, level 2 = 0.2769)
//   ukuran komunitas: min 1, median 1, persentil 75 = 38,
//   persentil 90 = 1.995, maks 3.266, rata-rata 414,08
// ------------------------------------------------------------
CALL gds.leiden.write('movielensGraph', { writeProperty: 'leidenCommunity' });


// ------------------------------------------------------------
// Catatan perbedaan hasil
// Mode stats memberi 24 komunitas (Q = 0.2776), mode write memberi
// 25 komunitas (Q = 0.2769). Penyebabnya belum diuji. Dugaan kami:
// unsur acak pada perhitungan paralel (concurrency 4).
//
// Agar hasil bisa diulang, GDS menyediakan randomSeed yang dipakai
// bersama concurrency 1. Contoh (BELUM kami jalankan):
//
//   CALL gds.leiden.stats('movielensGraph',
//        { randomSeed: 42, concurrency: 1 })
//   YIELD communityCount, modularity
//   RETURN communityCount, round(modularity, 4) AS Q;
// ------------------------------------------------------------
