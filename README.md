
# 📊 Pemodelan Profil Mahasiswa ITERA
### Evaluasi Berbasis Data dengan Bootstrap, Cross Validation, dan Kriteria Informasi
 
<div align="center">
</div>

---


## 📋 Deskripsi Proyek
 
Proyek ini merupakan **Tugas Besar Mata Kuliah Analisis Data Sains (ADS) 2025** di Institut Teknologi Sumatera (ITERA). Tujuannya adalah mengidentifikasi pola dan kelompok **profil mahasiswa ITERA** menggunakan pendekatan berbasis data (*data-driven*).
 
Keandalan model dievaluasi menggunakan tiga metode utama:
 
- 🔁 **Bootstrap Resampling** — estimasi parameter dengan 1000 iterasi ulang
- ✂️ **Cross Validation** — evaluasi performa model dengan k-fold CV
- 📐 **Kriteria Informasi** — seleksi model terbaik via AIC, BIC, dan RMSE

---

## 🗂️ Struktur Proyek
 
```
📦 profil-mahasiswa-itera/
├── 📄 tugas_besar_profil_mahasiswa_ITERA.qmd   # Dokumen Quarto utama
├── 📄 cleaning_profil_mahasiswa_ITERA.R         # Skrip pembersihan data
├── 📄 install_packages.R                        # Skrip instalasi paket
├── 📄 .Rprofile                                 # Konfigurasi mirror CRAN
├── 📊 Dataset_Tugas_Besar_ADS_2025_-_Karakteristik_Mahasiswa_.csv
├── 📊 dataset_profil_mahasiswa_ITERA_clean.csv  # Data hasil cleaning
└── 📖 README.md


## 📦 Variabel Dataset
 
Data dikumpulkan melalui survei daring mahasiswa ITERA 2025. Berikut variabel yang digunakan dalam analisis:
 
| Variabel | Tipe | Deskripsi |
|---|---|---|
| `prodi` | Kategorik | Program studi mahasiswa |
| `ipk` | Numerik | Indeks Prestasi Kumulatif (0–4) |
| `jenis_kelamin` | Kategorik | Laki-laki / Perempuan |
| `tinggi_badan` | Numerik | Tinggi badan (cm) |
| `berat_badan` | Numerik | Berat badan (kg) |
| `bmi` | Numerik | Body Mass Index *(turunan)* |
| `pendidikan_terakhir` | Kategorik | Pendidikan sebelum kuliah |
| `jam_belajar_perminggu` | Numerik | Rata-rata jam belajar per minggu |
| `penerima_beasiswa` | Kategorik | Ya / Tidak |
| `status_pekerjaan` | Kategorik | Bekerja / Tidak bekerja |
| `akses_internet` | Kategorik | Jenis akses internet utama |
| `keterlibatan_organisasi` | Kategorik | Tingkat aktif berorganisasi |
| `uang_saku` | Kategorik (ordinal) | Rentang uang saku per bulan |
| `jenis_tempat_tinggal` | Kategorik | Kos / Asrama / Rumah / dll |
| `jarak_dari_kampus` | Kategorik (ordinal) | Jarak tempat tinggal ke kampus |
| `pekerjaan_ayah` | Kategorik | Jenis pekerjaan ayah |
| `pekerjaan_ibu` | Kategorik | Jenis pekerjaan ibu |
| `pendapatan_orangtua` | Kategorik (ordinal) | Rentang pendapatan orang tua |
| `jumlah_anggota_keluarga` | Numerik | Jumlah anggota dalam keluarga |
 
> **Catatan:** Variabel `nim` dan `asal_daerah` dibuang dari analisis — `nim` hanya identifier, `asal_daerah` berisi teks bebas yang tidak informatif untuk pemodelan.
 
---
 
## 🔧 Cara Penggunaan
 
### 1. Clone repositori
 
```bash
git clone https://github.com/username/profil-mahasiswa-itera.git
cd profil-mahasiswa-itera
```
 
### 2. Setup mirror CRAN
 
Buat file `.Rprofile` di folder proyek agar tidak muncul error mirror:
 
```bash
echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"))' > .Rprofile
```
 
### 3. Install paket R
 
```bash
Rscript install_packages.R
```
 
Atau langsung di terminal:
 
```bash
R -e "options(repos=c(CRAN='https://cran.rstudio.com/')); install.packages(c('tidyverse','boot','caret','cluster','factoextra','knitr','kableExtra','corrplot','scales','gridExtra'))"
```
 
> **Jika muncul error dependency sistem** (Linux/Ubuntu):
> ```bash
> sudo apt install libcurl4-openssl-dev libxml2-dev libssl-dev libfontconfig1-dev
> ```
> Untuk Arch Linux:
> ```bash
> sudo pacman -S curl libxml2 openssl fontconfig
> ```
 
### 4. Render dokumen Quarto
 
```bash
quarto render tugas_besar_profil_mahasiswa_ITERA.qmd
```
 
Output berupa file `tugas_besar_profil_mahasiswa_ITERA.html` yang bisa dibuka di browser.
 
---
 
## 📦 Paket R yang Digunakan
 
| Paket | Versi | Fungsi |
|---|---|---|
| `tidyverse` | ≥ 2.0 | Manipulasi dan visualisasi data |
| `stringr` | ≥ 1.5 | Pembersihan teks |
| `boot` | ≥ 1.3 | Bootstrap resampling |
| `caret` | ≥ 6.0 | Cross validation & training model |
| `cluster` | ≥ 2.1 | Algoritma clustering |
| `factoextra` | ≥ 1.0 | Visualisasi hasil clustering & PCA |
| `ggplot2` | ≥ 3.4 | Visualisasi data |
| `knitr` | ≥ 1.4 | Rendering tabel di Quarto |
| `kableExtra` | ≥ 1.3 | Styling tabel |
| `corrplot` | ≥ 0.9 | Heatmap korelasi |
| `scales` | ≥ 1.3 | Format label plot |
| `gridExtra` | ≥ 2.3 | Susun plot berdampingan |
 
---
 
## 🔄 Alur Analisis
 
```
┌─────────────────────────────────────────────────┐
│              PENGUMPULAN DATA                   │
│         (Survei mahasiswa ITERA 2025)           │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│            PEMBERSIHAN DATA (R)                 │
│  • Rename & seleksi variabel                    │
│  • Validasi rentang numerik (IPK, TB, BB)       │
│  • Normalisasi 100+ varian nama prodi           │
│  • Standarisasi teks kategorik                  │
│  • Imputasi median / modus                      │
│  • Tambah fitur BMI                             │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│         EKSPLORASI DATA (EDA)                   │
│  • Distribusi IPK, jenis kelamin, pendapatan    │
│  • Heatmap korelasi variabel numerik            │
│  • Pola jam belajar vs IPK                      │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│           PEMODELAN (K-Means Clustering)        │
│  • Elbow Method → k optimal                     │
│  • Silhouette Analysis                          │
│  • Bangun model klaster profil mahasiswa        │
└──────┬────────────────┬────────────────┬────────┘
       │                │                │
       ▼                ▼                ▼
  Bootstrap        Cross Val.      Kriteria Info.
  (B=1000)         (10-fold)       AIC / BIC
  CI 95%           RMSE, R²        Seleksi model
       │                │                │
       └────────────────┴────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────┐
│        INTERPRETASI PROFIL MAHASISWA            │
│  • Karakteristik tiap klaster                   │
│  • Kesimpulan & rekomendasi kebijakan           │
└─────────────────────────────────────────────────┘
```
 
---
 
## 📈 Contoh Output
 
Dokumen Quarto yang dirender mencakup:
 
- **6 visualisasi EDA** — distribusi IPK, gender, pendapatan orang tua, boxplot beasiswa, scatter plot jam belajar vs IPK, heatmap korelasi
- **Plot Elbow & Silhouette** — untuk menentukan jumlah klaster optimal
- **Cluster plot PCA** — visualisasi 2D kelompok profil mahasiswa
- **Tabel Bootstrap CI** — interval kepercayaan 95% per klaster
- **Plot RMSE per fold** — hasil 10-fold cross validation
- **Tabel AIC/BIC** — perbandingan model kandidat
---
 
## 👥 Tim
 
| Nama | NIM | Prodi |
|---|---|---|
| *(Nama Anggota 1)* | *(NIM)* | *(Prodi)* |
| *(Nama Anggota 2)* | *(NIM)* | *(Prodi)* |
| *(Nama Anggota 3)* | *(NIM)* | *(Prodi)* |
 
**Dosen Pengampu:** *(Nama Dosen)*
**Mata Kuliah:** Analisis Data Sains — ITERA 2025
 
---
 
## 📚 Referensi
 
- Efron, B., & Tibshirani, R. J. (1993). *An Introduction to the Bootstrap*. Chapman & Hall.
- James, G., Witten, D., Hastie, T., & Tibshirani, R. (2021). *An Introduction to Statistical Learning*. Springer.
- Akaike, H. (1974). A new look at the statistical model identification. *IEEE Transactions on Automatic Control*, 19(6), 716–723.
- Wickham, H., & Grolemund, G. (2016). *R for Data Science*. O'Reilly Media.
---
 
## 📄 Lisensi
 
Proyek ini dibuat untuk keperluan akademik. Distribusi bebas dengan mencantumkan sumber.
 
---
 
<div align="center">
  <sub>Dibuat dengan ❤️ menggunakan R & Quarto — Institut Teknologi Sumatera 2025</sub>
</div>
```



