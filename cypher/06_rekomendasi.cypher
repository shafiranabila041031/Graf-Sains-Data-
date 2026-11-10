// ============================================================
// 06 - REKOMENDASI FILM (COLLABORATIVE FILTERING)
// Tujuan  : menyarankan film untuk pengguna target (userId = 1)
//           berdasarkan selera pengguna lain yang mirip.
// Syarat  : 01_import_data.cypher sudah dijalankan.
// Catatan : rekomendasi ini memakai relasi RATED secara langsung,
//           bukan komunitas Leiden. Ganti angka 1 pada userId untuk
//           mencoba pengguna lain.
// ============================================================


// ------------------------------------------------------------
// 6.1 Rekomendasi 10 film untuk pengguna 1
//
// Cara kerjanya:
// 1) Cari pengguna lain (peer) yang menilai film yang sama dengan
//    pengguna 1, dengan selisih rating paling banyak 1.0.
// 2) Pengguna lain dianggap mirip jika punya minimal 3 film yang
//    sama (film_bersama >= 3), supaya kemiripan bukan kebetulan.
// 3) Ambil film yang diberi rating 4.0 ke atas oleh pengguna mirip.
// 4) Buang film yang sudah pernah dinilai pengguna 1.
// 5) Urutkan dari film yang disukai paling banyak pengguna mirip.
//
// Kolom hasil:
//   Jumlah_User_Serupa = berapa pengguna mirip yang menyukai film itu.
//   Prediksi_Rating    = rata-rata rating dari pengguna mirip itu.
//     (Karena hanya rating 4.0 ke atas yang dihitung, nilainya pasti
//      di atas 4.0. Ini bukan prediksi nilai dari pengguna 1.)
//
// Hasil di laporan (waktu 4.605 ms, satu kali percobaan):
//   1  The Shawshank Redemption (1994)                          266  4.65
//   2  The Godfather (1972)                                     153  4.64
//   3  Terminator 2: Judgment Day (1991)                        149  4.49
//   4  The Lord of the Rings: The Fellowship of the Ring (2001) 140  4.57
//   5  The Lord of the Rings: The Return of the King (2003)     134  4.51
//   6  Apollo 13 (1995)                                         126  4.40
//   7  The Lord of the Rings: The Two Towers (2002)             125  4.51
//   8  The Sixth Sense (1999)                                   124  4.40
//   9  Memento (2000)                                           121  4.51
//   10 The Lion King (1994)                                     114  4.42
// ------------------------------------------------------------
MATCH (target:User {userId: 1})-[r1:RATED]->(common:Movie)<-[r2:RATED]-(peer:User)
WHERE target <> peer
  AND abs(r1.rating - r2.rating) <= 1.0
WITH target, peer, count(DISTINCT common) AS film_bersama
WHERE film_bersama >= 3

MATCH (peer)-[r3:RATED]->(rec:Movie)
WHERE NOT (target)-[:RATED]->(rec)
  AND r3.rating >= 4.0
RETURN rec.title AS Rekomendasi_Film,
       count(DISTINCT peer) AS Jumlah_User_Serupa,
       round(avg(r3.rating), 2) AS Prediksi_Rating
ORDER BY Jumlah_User_Serupa DESC, Prediksi_Rating DESC
LIMIT 10;


// ------------------------------------------------------------
// Catatan
// - Hasil cenderung berisi film populer (popularity bias), karena
//   film yang banyak ditonton lebih sering muncul.
// - Jalur penelusuran rekomendasi dalam bentuk gambar ada di
//   file 05_visualisasi.cypher (query 5.3).
// ------------------------------------------------------------
