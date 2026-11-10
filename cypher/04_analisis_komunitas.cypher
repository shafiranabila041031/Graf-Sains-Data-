// ============================================================
// 04 - ANALISIS KOMUNITAS LEIDEN
// Tujuan  : melihat berapa komunitas yang tersimpan, seberapa besar
//           tiap komunitas, dan film apa saja di dalamnya.
// Syarat  : 03_leiden.cypher (mode WRITE) sudah dijalankan, sehingga
//           node punya properti leidenCommunity.
//
// PENTING: query di file ini DITULIS ULANG untuk menghasilkan tabel
// yang sama dengan laporan Bagian 6. Query asli untuk tabel itu tidak
// tercatat (tabel di laporan berasal dari file ekspor CSV). Jalankan
// dulu, lalu cocokkan hasilnya dengan laporan sebelum dikumpulkan.
// Nomor komunitas bisa berbeda dari tabel di laporan, karena tabel itu
// berasal dari run Leiden mode stream, bukan dari run write.
// ============================================================


// ------------------------------------------------------------
// 4.1 Jumlah komunitas yang tersimpan
// Hasil di laporan (mode write): 25 komunitas, 10.352 node bernilai.
// ------------------------------------------------------------
MATCH (n)
WHERE n.leidenCommunity IS NOT NULL
RETURN count(DISTINCT n.leidenCommunity) AS jumlah_komunitas,
       count(n) AS jumlah_node_bernomor;


// ------------------------------------------------------------
// 4.2 Sepuluh komunitas terbesar berdasarkan jumlah film
// Meniru tabel laporan Bagian 6: ID komunitas, jumlah film, dan
// empat contoh judul film.
// Urutan contoh film tidak dijamin sama dengan laporan.
// ------------------------------------------------------------
MATCH (m:Movie)
WHERE m.leidenCommunity IS NOT NULL
RETURN m.leidenCommunity AS komunitas,
       count(m) AS jumlah_film,
       collect(m.title)[0..4] AS contoh_film
ORDER BY jumlah_film DESC
LIMIT 10;


// ------------------------------------------------------------
// 4.3 Jumlah pengguna dan film di tiap komunitas
// Satu komunitas bisa berisi pengguna dan film sekaligus karena
// graf yang dianalisis berisi keduanya.
// ------------------------------------------------------------
MATCH (n)
WHERE n.leidenCommunity IS NOT NULL
RETURN n.leidenCommunity AS komunitas,
       count(CASE WHEN n:User THEN 1 END) AS jumlah_pengguna,
       count(CASE WHEN n:Movie THEN 1 END) AS jumlah_film
ORDER BY jumlah_pengguna + jumlah_film DESC;


// ------------------------------------------------------------
// 4.4 Film yang belum pernah dinilai
// Median ukuran komunitas di laporan adalah 1, artinya banyak
// komunitas hanya berisi satu node. Dugaan kami, itu film yang
// belum pernah dinilai (tidak terhubung ke siapa pun). Query ini
// untuk mengeceknya.
// ------------------------------------------------------------
MATCH (m:Movie)
WHERE NOT (m)<-[:RATED]-()
RETURN count(m) AS film_tanpa_rating;
