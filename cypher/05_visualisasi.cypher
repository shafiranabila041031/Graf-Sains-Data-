// ============================================================
// 05 - VISUALISASI GRAF (untuk screenshot)
// Tujuan  : menampilkan bentuk graf di Neo4j Browser dan
//           memastikan datanya sudah masuk dengan benar.
// Syarat  : 01 sampai 03 sudah dijalankan. Query 5.4 butuh
//           leidenCommunity dari 03_leiden.cypher (mode WRITE).
// Tips    : angka di dalam lingkaran User pada screenshot kami adalah
//           nomor komunitas Leiden (leidenCommunity). Caption bisa
//           diubah di panel style Neo4j Browser (klik label User,
//           lalu pilih Caption).
// Setiap query dibatasi LIMIT supaya gambar tidak terlalu padat,
// jadi gambar hanya contoh sebagian data.
// ============================================================


// ------------------------------------------------------------
// 5.1 Gambar 1 - Film dan genre
// Hasil di laporan: 20 node (10 Movie + 10 Genre), 25 relasi IN_GENRE.
// ------------------------------------------------------------
MATCH p=()-[:IN_GENRE]->() RETURN p LIMIT 25;


// ------------------------------------------------------------
// 5.2 Gambar 2 - Pengguna dan film yang dinilai
// Hasil di laporan: 26 node (25 Movie + 1 User), 25 relasi RATED.
// Bentuknya seperti bintang: satu pengguna di tengah.
// ------------------------------------------------------------
MATCH p=()-[:RATED]->() RETURN p LIMIT 25;


// ------------------------------------------------------------
// 5.3 Gambar 3 - Jalur rekomendasi untuk pengguna 1
// Jalur: pengguna 1 -> film yang sama-sama dinilai -> pengguna lain
// yang mirip -> film yang mungkin disukai pengguna 1.
// Hasil di laporan: 34 node (31 Movie + 3 User), 33 relasi RATED,
// 4.990 ms.
// ------------------------------------------------------------
MATCH path = (target:User {userId: 1})-[r1:RATED]->(common:Movie)<-[r2:RATED]-(peer:User)-[r3:RATED]->(rec:Movie)
WHERE target <> peer
  AND abs(r1.rating - r2.rating) <= 1.0
  AND r3.rating >= 4.0
  AND NOT (target)-[:RATED]->(rec)
RETURN path
LIMIT 30;


// ------------------------------------------------------------
// 5.4 Gambar 4 - Film dari komunitas Leiden 0, 2, dan 6
// beserta pengguna yang memberi rating 4.5 ke atas.
// Hasil di laporan: 63 node (3 Movie + 60 User), 60 relasi RATED.
// Nomor 0, 2, 6 adalah contoh. Cek nomor komunitas yang ada di
// databasemu dengan query 4.2 (file 04).
// ------------------------------------------------------------
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE m.leidenCommunity IN [0, 2, 6]
  AND r.rating >= 4.5
RETURN u, r, m
LIMIT 60;


// ------------------------------------------------------------
// 5.5 Gambar 5 - Film lain yang disukai penonton Toy Story
// Dua film dianggap berhubungan jika pengguna yang sama memberi
// keduanya rating 4.5 ke atas.
// Hasil di laporan: 37 node (36 Movie + 1 User), 36 relasi RATED.
// ------------------------------------------------------------
MATCH (m1:Movie {title: 'Toy Story (1995)'})<-[r1:RATED]-(u:User)-[r2:RATED]->(m2:Movie)
WHERE m1 <> m2
  AND r1.rating >= 4.5
  AND r2.rating >= 4.5
RETURN m1, r1, u, r2, m2
LIMIT 35;


// ------------------------------------------------------------
// 5.6 Gambar 6 - Toy Story, genrenya, dan pengguna yang memberi
// rating 5.0
// Hasil di laporan: 32 node dan 30 relasi.
// Pada gambar kami hanya tampak genre Adventure karena LIMIT 30
// memotong baris hasil. Naikkan LIMIT jika ingin melihat semua genre.
// ------------------------------------------------------------
MATCH (m:Movie {title: 'Toy Story (1995)'})-[g:IN_GENRE]->(genre:Genre)
OPTIONAL MATCH (u:User)-[r:RATED]->(m)
WHERE r.rating = 5.0
RETURN m, g, genre, u, r
LIMIT 30;
