// ============================================================
// 01 - IMPORT DATA
// Tujuan  : membuat aturan ID unik, lalu memasukkan data MovieLens
//           ke Neo4j sebagai graf User - Movie - Genre.
// Syarat  : movies.csv dan ratings.csv sudah ada di folder "import"
//           milik database.
// Cara    : jalankan SATU query per eksekusi, urut dari atas ke bawah.
// Instance: gsd | Database: movielens
// Catatan : angka "Hasil di laporan" disalin dari log eksekusi kelompok.
// ============================================================


// ------------------------------------------------------------
// 1.1 Aturan ID unik (constraint)
// Supaya satu film, satu pengguna, dan satu genre hanya tercatat
// satu kali (tidak ada data ganda). Neo4j juga otomatis membuat
// indeks sehingga pencarian lebih cepat.
// Hasil di laporan: 644 ms (Movie), 146 ms (User), 130 ms (Genre).
// ------------------------------------------------------------
CREATE CONSTRAINT FOR (m:Movie) REQUIRE m.movieId IS UNIQUE;

CREATE CONSTRAINT FOR (u:User) REQUIRE u.userId IS UNIQUE;

CREATE CONSTRAINT FOR (g:Genre) REQUIRE g.name IS UNIQUE;


// ------------------------------------------------------------
// 1.2 Impor film dan genre (movies.csv)
// - Satu film bisa punya beberapa genre, ditulis "Action|Comedy".
// - split(row.genres, '|') memecahnya menjadi daftar genre.
// - Tiap genre dibuat menjadi node Genre, lalu dihubungkan ke
//   filmnya dengan relasi IN_GENRE.
// Hasil di laporan: 7.872 ms; 9.762 node baru (9.742 Movie + 20 Genre),
// 22.084 relasi IN_GENRE, 19.504 properti.
// ------------------------------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET m.title = row.title
WITH m, split(row.genres, '|') AS genres
FOREACH (genreName IN genres |
  MERGE (g:Genre {name: genreName})
  MERGE (m)-[:IN_GENRE]->(g)
);


// ------------------------------------------------------------
// 1.3 Impor pengguna (ratings.csv)
// Membuat satu node User untuk setiap userId yang berbeda.
// Dibuat lebih dulu supaya semua pengguna sudah ada sebelum
// relasi rating ditulis.
// Hasil di laporan: 610 node User, 1.097 ms.
// ------------------------------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row
WITH DISTINCT row.userId AS userId
MERGE (:User {userId: toInteger(userId)});


// ------------------------------------------------------------
// 1.4 Impor rating menjadi relasi RATED (ratings.csv)
// - Setiap baris = satu rating: pengguna -> film.
// - Disimpan per 10.000 baris supaya memori tidak penuh.
// - Sintaks CALL (row) { ... } butuh Neo4j 5.23 ke atas.
// Catatan: jika Neo4j Browser menolak query ini, tulis :auto di depan
// LOAD CSV (jadi ":auto LOAD CSV WITH HEADERS ...").
// Hasil di laporan: 10.713 ms; 100.836 relasi RATED
// (201.672 properti: rating dan timestamp).
// ------------------------------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row
CALL (row) {
  MATCH (u:User {userId: toInteger(row.userId)})
  MATCH (m:Movie {movieId: toInteger(row.movieId)})
  CREATE (u)-[r:RATED {rating: toFloat(row.rating), timestamp: toInteger(row.timestamp)}]->(m)
} IN TRANSACTIONS OF 10000 ROWS;


// ------------------------------------------------------------
// 1.5 Pemeriksaan jumlah data (query tambahan untuk verifikasi)
// Cocokkan dengan panel "Database information" di laporan:
//   total 10.372 node  dan 122.920 relasi
//   Relasi : IN_GENRE 22.084 + RATED 100.836
//   Node   : User 610; Movie 9.742 dan Genre 20 (dihitung dari log:
//            9.762 - 9.742 = 20, lalu dicek 2 x 9.742 + 20 = 19.504
//            properti, sama dengan log). Cocokkan dengan hasil query.
// ------------------------------------------------------------
MATCH (n)
RETURN labels(n) AS jenis_node,
       count(n) AS jumlah;

MATCH ()-[r]->()
RETURN type(r) AS jenis_relasi,
       count(r) AS jumlah;
