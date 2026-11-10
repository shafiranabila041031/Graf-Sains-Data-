# Community Detection Leiden dan Rekomendasi Film (Collaborative Filtering) pada Dataset MovieLens dengan Neo4j

Tugas mata kuliah Graf Sains Data. Kami membentuk komunitas pengguna dan film dengan algoritma **Leiden** di Neo4j (Graph Data Science), lalu membuat rekomendasi film dengan **collaborative filtering**.

## Anggota Kelompok 10:
- Shafira Nabila Noer Poerwanto (23031554011)
- Muhammad Rif'at Syarief (23031554053)
- Novia Djoend Lestari (23031554220)


## Tools
- Neo4j 5.x dengan plugin Graph Data Science (GDS). Query `CALL (row) {...}` di file 01 butuh Neo4j 5.23 ke atas.
- Neo4j Browser (instance `gsd`, database `movielens`)
- Dataset: MovieLens small (610 pengguna, 9.742 film, 100.836 rating)

## Alur
1. Impor data film, genre, pengguna, dan rating ke Neo4j.
2. Proyeksikan graf (User, Movie, RATED) ke memori GDS.
3. Jalankan Leiden (mode stats, lalu mode write).
4. Analisis komunitas yang terbentuk.
5. Buat visualisasi graf untuk laporan.
6. Buat rekomendasi film untuk pengguna 1 dengan collaborative filtering.

## Cara menjalankan
Jalankan file di folder `cypher/` berurutan. Salin isi file ke Neo4j Browser, lalu jalankan query satu per satu.

| File | Isi |
|---|---|
| `cypher/01_import_data.cypher` | Constraint, impor film, genre, pengguna, rating, dan cek jumlah data |
| `cypher/02_proyeksi_graf.cypher` | Proyeksi graf `movielensGraph` ke memori GDS |
| `cypher/03_leiden.cypher` | Leiden mode stats dan write (menyimpan `leidenCommunity`) |
| `cypher/04_analisis_komunitas.cypher` | Jumlah dan ukuran komunitas, film di tiap komunitas |
| `cypher/05_visualisasi.cypher` | Enam query untuk gambar di laporan |
| `cypher/06_rekomendasi.cypher` | Rekomendasi 10 film untuk pengguna 1 |


## Hasil
Data yang masuk: 610 User, 9.742 Movie, 100.836 relasi RATED, 22.084 relasi IN_GENRE. Proyeksi graf: 10.352 node, 201.672 relasi (relasi dibaca dua arah), 1.955 ms.

**Leiden**

| Mode | Jumlah komunitas | Modularitas (Q) | Waktu |
|---|---|---|---|
| stats | 24 | 0,2776 | 907 ms |
| write | 25 | 0,2769 | 3.593 ms |

Pada mode write, Leiden berhenti di level 2 dan konvergen. Ukuran komunitas: median 1, rata-rata 414,08, terbesar 3.266 node.

**Komunitas terbesar berdasarkan jumlah film** (dari run stream)

| ID | Jumlah film |
|---|---|
| 4 | 3.094 |
| 2 | 2.789 |
| 25 | 1.923 |
| 0 | 1.036 |
| 65 | 481 |
| 48 | 294 |
| 10 | 107 |

**Rekomendasi untuk pengguna 1 (5 teratas)**

| No | Film | Pengguna serupa | Rata-rata rating |
|---|---|---|---|
| 1 | The Shawshank Redemption (1994) | 266 | 4,65 |
| 2 | The Godfather (1972) | 153 | 4,64 |
| 3 | Terminator 2: Judgment Day (1991) | 149 | 4,49 |
| 4 | The Lord of the Rings: The Fellowship of the Ring (2001) | 140 | 4,57 |
| 5 | The Lord of the Rings: The Return of the King (2003) | 134 | 4,51 |

Daftar lengkap 10 film ada di `cypher/06_rekomendasi.cypher` dan Bagian 8 laporan.

## Keterbatasan
- Dataset kecil (MovieLens small), jadi hasil belum tentu berlaku untuk data yang lebih besar.
- Leiden mengandung unsur acak. Jumlah komunitas berbeda antara stats (24) dan write (25), dan nomor komunitas bisa berubah di setiap run. Penyebabnya belum kami uji.
- Banyak komunitas hanya berisi satu node (median ukuran = 1). Dugaan kami itu film yang belum pernah dinilai; query 4.4 di file 04 bisa dipakai untuk mengeceknya.
- Rekomendasi condong ke film populer (popularity bias). Kolom Prediksi_Rating hanya rata-rata rating dari pengguna serupa (rating 4,0 ke atas), bukan prediksi nilai dari pengguna 1.
- Rekomendasi memakai relasi RATED langsung, bukan komunitas Leiden.
- Query di `04_analisis_komunitas.cypher` ditulis ulang karena query asli tabel laporan tidak tercatat. Jalankan dan cocokkan hasilnya sebelum dikumpulkan.
- Jumlah genre (20) dihitung dari log impor, bukan dari query langsung.


PPT :
https://docs.google.com/presentation/d/15IabCS7lwY_nHEKW_jFhRj7WNf_OGXoy/edit?usp=sharing&ouid=107836384034892031330&rtpof=true&sd=true 