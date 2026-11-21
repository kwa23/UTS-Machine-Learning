# Kode UTS Machine Learning: Regresi, Klasifikasi, Clustering

Tiga notebook mandiri (semua fungsi ada di dalam notebook, tidak saling mengimpor) dan satu skrip yang menjalankan semuanya.

## Isi folder

| Berkas | Isi |
|---|---|
| `regresi.ipynb` | Tugas 1: estimasi durasi pengiriman (P50 dan P90) -> `prediksi_regresi.csv` |
| `klasifikasi.ipynb` | Tugas 2: deteksi fraud (probabilitas dan keputusan tandai) -> `prediksi_klasifikasi.csv` |
| `clustering.ipynb` | Tugas 3: segmentasi pelanggan -> `cluster.csv` |
| `jalankan_semua.sh` | Satu perintah yang menjalankan ketiga notebook dan menaruh tiga berkas prediksi di akar repo |
| `requirements.txt` | Versi paket yang dipakai |

## Data

Data tidak ikut di repo (ukuran besar). Buat folder `data/` di akar repo (bila belum ada), lalu taruh berkas berikut di dalamnya:

```
data/clustering.csv.gz
data/regresi_train_1.csv.gz   data/regresi_train_2.csv.gz   data/regresi_train_3.csv.gz   data/regresi_test.csv.gz
data/klasifikasi_train_1.csv.gz   data/klasifikasi_train_2.csv.gz   data/klasifikasi_train_3.csv.gz   data/klasifikasi_test.csv.gz
```

`regresi_train_{1,2,3}` dan `klasifikasi_train_{1,2,3}` adalah `regresi_train.csv` / `klasifikasi_train.csv` asli yang dipecah menjadi tiga bagian berurutan waktu (karena batas ukuran unggah) dan dikompres; notebook menggabungkannya kembali. Isi data tidak diubah.

## Cara menjalankan (satu perintah)

```bash
pip install -r kode/requirements.txt
bash kode/jalankan_semua.sh
```

Perintah kedua menjalankan ketiga notebook berurutan, lalu menyalin `cluster.csv`, `prediksi_regresi.csv`, dan `prediksi_klasifikasi.csv` ke akar repo. Notebook yang sudah dieksekusi (lengkap dengan tabel dan grafik) tersimpan kembali di `kode/`, dan tabel pendukung Tugas 3 di `kode/output/`. Semua angka di laporan berasal dari keluaran notebook-notebook ini.

Waktu jalan total sekitar **±70 menit** (clustering ±15, regresi ±25, klasifikasi ±30) pada 2 inti CPU (lihat rincian di bawah). Semua seed bernilai 42; berkas prediksi yang dihasilkan identik dengan yang ada di repo bila versi paket sama dengan `requirements.txt` (diuji dengan Python 3.13).

Menjalankan satu tugas saja:

```bash
cd kode
CLUSTERING_CSV=../data/clustering.csv.gz jupyter nbconvert --to notebook --execute --inplace clustering.ipynb
jupyter nbconvert --to notebook --execute --inplace regresi.ipynb
jupyter nbconvert --to notebook --execute --inplace klasifikasi.ipynb
```

Notebook juga bisa dibuka di Google Colab: unggah notebook dan berkas data tugas terkait ke folder kerja Colab, lalu *Run all*. Notebook mencari data di folder kerja, `data/`, atau `../data/`.

## Ringkasan per tugas

**Tugas 1, Regresi (`regresi.ipynb`).** Audit menemukan `jumlah_scan` (bocor, hanya terisi akibat pengiriman), `f30` (proksi waktu), kode sentinel pada `jarak_km`, `berat_kg` yang hilang tidak acak, dan outlier. Fitur-fitur bermasalah dibuang dan dampaknya diukur lewat ablasi, termasuk perbandingan dengan CV acak. Validasi memakai *expanding window* tiga lipatan. Model akhir adalah rata-rata geometrik LightGBM kuantil dan LightGBM L2 pada $\log y$ dengan kuantil residual per layanan; Ridge dan baseline kuantil grup sebagai pembanding. P90 dikalibrasi konformal dan diuji *leave-one-fold-out*. Analisis galat per `layanan`, `pulau_tujuan`, `mitra_kurir`, serta SHAP.

**Tugas 2, Klasifikasi (`klasifikasi.ipynb`).** Label belum lengkap pada sekitar tiga minggu terakhir, sehingga validasi memakai jeda 21 hari dan hanya label matang. `flag_review_manual` bocor dan dikeluarkan (ablasi mengukur dampaknya). Fitur riwayat pengguna dan merchant dibangun hanya dari masa lalu. Empat pendekatan imbalance dibandingkan; pergeseran pola (jaringan merchant baru sejak Agustus) dianalisis dan diadaptasi lewat pembobotan data Agustus. Probabilitas dikalibrasi (Platt), keputusan memakai aturan biaya $\hat p\,a>25000$ dan dibandingkan dengan menandai semua atau tidak sama sekali.

**Tugas 3, Clustering (`clustering.ipynb`).** Preprocessing (log, logit, *centered log-ratio* untuk data komposisional), seleksi fitur dengan bukti (prediktabilitas, $\eta^2$, ablasi), perbandingan K-Means, GMM, dan Ward, pemilihan jumlah cluster dengan beberapa kriteria, stabilitas bootstrap (ARI), aturan anomali (label $-1$), serta profil dan aksi pemasaran per segmen.

## Catatan reproduktibilitas

- Seed global 42; LightGBM memakai seed dan jumlah *thread* tetap. Perbedaan versi paket atau jumlah inti CPU dapat menggeser angka pada digit belakang; nomor cluster bersifat sembarang.
- Skema validasi tidak pernah memakai data setelah titik potong (tidak ada kebocoran waktu). Hiperparameter LightGBM regresi dipilih lewat pencarian acak (10 konfigurasi) pada lipatan temporal yang sama; skrip pencarian tidak disertakan, dan nilai terpilih tertulis di sel parameter `regresi.ipynb`. Klasifikasi memakai parameter tetap tanpa penyetelan.
- Notebook menulis berkas prediksi ke folder kerjanya (`kode/`) lalu `jalankan_semua.sh` menyalinnya ke akar repo.
