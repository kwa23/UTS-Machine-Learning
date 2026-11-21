#!/usr/bin/env bash
# Satu perintah untuk mereproduksi SEMUA angka dan ketiga berkas prediksi.
# Pemakaian (dari akar repo):  bash kode/jalankan_semua.sh
set -euo pipefail
cd "$(dirname "$0")"
DATA=../data
for f in clustering.csv.gz regresi_train_1.csv.gz regresi_train_2.csv.gz regresi_train_3.csv.gz regresi_test.csv.gz \
         klasifikasi_train_1.csv.gz klasifikasi_train_2.csv.gz klasifikasi_train_3.csv.gz klasifikasi_test.csv.gz; do
  [ -f "$DATA/$f" ] || { echo "Berkas data tidak ditemukan: data/$f (lihat kode/README.md)"; exit 1; }
done
export CLUSTERING_CSV="$DATA/clustering.csv.gz"
for nb in clustering regresi klasifikasi; do
  echo "== menjalankan $nb.ipynb =="
  jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=-1 "$nb.ipynb"
done
cp cluster.csv prediksi_regresi.csv prediksi_klasifikasi.csv ..
echo "Selesai. Berkas prediksi ada di akar repo."
