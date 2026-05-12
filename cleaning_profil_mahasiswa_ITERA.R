# ============================================================
#  Pembersihan Data Profil Mahasiswa ITERA
#  Tugas Besar - Analisis Data Sains 2025
#  Output : dataset_profil_mahasiswa_ITERA_clean.csv
# ============================================================

# ── 0. Install & load paket ──────────────────────────────────
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("stringr"))   install.packages("stringr")

library(tidyverse)
library(stringr)


# ── 1. Baca data ─────────────────────────────────────────────
df_raw <- read_csv(
  "Dataset_Tugas_Besar_ADS_2025_-_Karakteristik_Mahasiswa_.csv",
  show_col_types = FALSE
)

cat("Dimensi awal :", nrow(df_raw), "baris x", ncol(df_raw), "kolom\n")


# ── 2. Rename kolom ──────────────────────────────────────────
df <- df_raw |>
  rename(
    nim                     = 1,
    prodi                   = 2,
    ipk                     = 3,
    jenis_kelamin           = 4,
    tinggi_badan            = 5,
    berat_badan             = 6,
    pendidikan_terakhir     = 7,
    jam_belajar_perminggu   = 8,
    penerima_beasiswa       = 9,
    asal_daerah             = 10,
    status_pekerjaan        = 11,
    akses_internet          = 12,
    keterlibatan_organisasi = 13,
    uang_saku               = 14,
    jenis_tempat_tinggal    = 15,
    jarak_dari_kampus       = 16,
    pekerjaan_ayah          = 17,
    pekerjaan_ibu           = 18,
    pendapatan_orangtua     = 19,
    jumlah_anggota_keluarga = 20
  )


# ── 3. Pilih variabel relevan ────────────────────────────────
# Buang: nim (hanya identifier), asal_daerah (teks bebas / noise)
df <- df |>
  select(
    prodi, ipk, jenis_kelamin, tinggi_badan, berat_badan,
    pendidikan_terakhir, jam_belajar_perminggu, penerima_beasiswa,
    status_pekerjaan, akses_internet, keterlibatan_organisasi,
    uang_saku, jenis_tempat_tinggal, jarak_dari_kampus,
    pekerjaan_ayah, pekerjaan_ibu, pendapatan_orangtua,
    jumlah_anggota_keluarga
  )


# ── 4. Bersihkan IPK ─────────────────────────────────────────
# Ganti koma → titik, buang entri "-" atau di luar 0–4
df <- df |>
  mutate(
    ipk = str_replace_all(ipk, ",", "."),
    ipk = suppressWarnings(as.numeric(ipk)),
    ipk = if_else(ipk >= 0 & ipk <= 4, ipk, NA_real_)
  )


# ── 5. Bersihkan jam belajar per minggu ──────────────────────
# Hapus semua karakter non-angka (misal "3 jam" → "3")
df <- df |>
  mutate(
    jam_belajar_perminggu = str_extract(
      as.character(jam_belajar_perminggu), "[0-9]+\\.?[0-9]*"
    ),
    jam_belajar_perminggu = suppressWarnings(as.numeric(jam_belajar_perminggu)),
    # Hapus nilai tidak masuk akal (> 168 jam/minggu)
    jam_belajar_perminggu = if_else(
      jam_belajar_perminggu >= 0 & jam_belajar_perminggu <= 168,
      jam_belajar_perminggu, NA_real_
    )
  )


# ── 6. Bersihkan tinggi & berat badan ────────────────────────
df <- df |>
  mutate(
    tinggi_badan = suppressWarnings(as.numeric(tinggi_badan)),
    tinggi_badan = if_else(tinggi_badan >= 100 & tinggi_badan <= 250,
                           tinggi_badan, NA_real_),
    berat_badan  = suppressWarnings(as.numeric(berat_badan)),
    berat_badan  = if_else(berat_badan >= 20 & berat_badan <= 200,
                           berat_badan, NA_real_)
  )


# ── 7. Bersihkan jumlah anggota keluarga ─────────────────────
# Ekstrak angka pertama dari teks bebas (misal "5 orang termasuk saya" → 5)
df <- df |>
  mutate(
    jumlah_anggota_keluarga = str_extract(
      as.character(jumlah_anggota_keluarga), "\\d+"
    ),
    jumlah_anggota_keluarga = suppressWarnings(as.integer(jumlah_anggota_keluarga)),
    jumlah_anggota_keluarga = if_else(
      jumlah_anggota_keluarga >= 1 & jumlah_anggota_keluarga <= 20,
      jumlah_anggota_keluarga, NA_integer_
    )
  )


# ── 8. Normalisasi Program Studi ─────────────────────────────
# Lookup table: semua variasi → nama kanonik
prodi_lookup <- tribble(
  ~variasi,                                  ~kanonik,
  "Sains Data",                              "Sains Data",
  "Sains data",                              "Sains Data",
  "sains data",                              "Sains Data",
  "SAINS DATA",                              "Sains Data",
  "Sainsdata",                               "Sains Data",
  "Matematika",                              "Matematika",
  "matematika",                              "Matematika",
  "Sains Aktuaria",                          "Sains Aktuaria",
  "Sains aktuaria",                          "Sains Aktuaria",
  "SAINS AKTUARIA",                          "Sains Aktuaria",
  "SAP",                                     "Sains Aktuaria",
  "sains aktuaria",                          "Sains Aktuaria",
  "Teknik Informatika",                      "Teknik Informatika",
  "Teknik informatika",                      "Teknik Informatika",
  "TKA",                                     "Teknik Informatika",
  "Teknik Biomedis",                         "Teknik Biomedis",
  "Teknik biomedis",                         "Teknik Biomedis",
  "teknik biomedis",                         "Teknik Biomedis",
  "Teknik biomed",                           "Teknik Biomedis",
  "Teknik Geofisika",                        "Teknik Geofisika",
  "teknik Geofisika",                        "Teknik Geofisika",
  "teknik geofisika",                        "Teknik Geofisika",
  "TEKNIK GEOFISIKA",                        "Teknik Geofisika",
  "teknij geofisika",                        "Teknik Geofisika",
  "Farmasi",                                 "Farmasi",
  "Kimia",                                   "Kimia",
  "kimia",                                   "Kimia",
  "KIMIA",                                   "Kimia",
  "Fisika",                                  "Fisika",
  "FISIKA",                                  "Fisika",
  "Arsitektur",                              "Arsitektur",
  "ARSITEKTUR",                              "Arsitektur",
  "arsitektur",                              "Arsitektur",
  "Arsitektur Lanskap",                      "Arsitektur Lanskap",
  "Arsitektur lanskap",                      "Arsitektur Lanskap",
  "Arl",                                     "Arsitektur Lanskap",
  "Teknik Sipil",                            "Teknik Sipil",
  "Teknik Mesin",                            "Teknik Mesin",
  "teknik mesin",                            "Teknik Mesin",
  "Teknologi Pangan",                        "Teknologi Pangan",
  "Tekpang",                                 "Teknologi Pangan",
  "Pariwisata",                              "Pariwisata",
  "pariwisata",                              "Pariwisata",
  "Perencanaan wilayah dan kota",            "Perencanaan Wilayah dan Kota",
  "Perencanaan Wilayah dan Kota",            "Perencanaan Wilayah dan Kota",
  "PWK",                                     "Perencanaan Wilayah dan Kota",
  "Pwk",                                     "Perencanaan Wilayah dan Kota",
  "pwk",                                     "Perencanaan Wilayah dan Kota",
  "Rekayasa Instrumentasi dan Automasi",     "Rekayasa Instrumentasi dan Automasi",
  "REKAYASA INSTRUMENTASI DAN AUTOMASI",    "Rekayasa Instrumentasi dan Automasi",
  "Rekayasa instrumentasi & automasi",       "Rekayasa Instrumentasi dan Automasi",
  "Rekayasa Instrumentasi Dan Automasi",     "Rekayasa Instrumentasi dan Automasi",
  "Teknik Pertambangan",                     "Teknik Pertambangan",
  "TEKNIK PERTAMBANGAN",                     "Teknik Pertambangan",
  "teknik Pertambangan",                     "Teknik Pertambangan",
  "Teknik pertambangan",                     "Teknik Pertambangan",
  "Teknik Geologi",                          "Teknik Geologi",
  "teknik geologi",                          "Teknik Geologi",
  "Biologi",                                 "Biologi",
  "biologi",                                 "Biologi",
  "Teknik Kimia",                            "Teknik Kimia",
  "Sains Atmosfer dan Keplanetan",           "Sains Atmosfer dan Keplanetan",
  "Sains Atmosfir dan Keplanetan",           "Sains Atmosfer dan Keplanetan",
  "Sains atmosfer dan keplanetan",           "Sains Atmosfer dan Keplanetan",
  "Teknik Sistem Energi",                    "Teknik Sistem Energi",
  "TEKNIK SISTEM ENERGI",                    "Teknik Sistem Energi",
  "Teknik Lingkungan",                       "Teknik Lingkungan",
  "Teknik Elektro",                          "Teknik Elektro",
  "teknik elektro",                          "Teknik Elektro",
  "Teknik Telekomunikasi",                   "Teknik Telekomunikasi",
  "teknik telekomunikasi",                   "Teknik Telekomunikasi",
  "Telekomunikasi",                          "Teknik Telekomunikasi",
  "Rekayasa Kosmetik",                       "Rekayasa Kosmetik",
  "Rekayasa kosmetik",                       "Rekayasa Kosmetik",
  "Rekayasa Kehutanan",                      "Rekayasa Kehutanan",
  "Rekayasa kehutanan",                      "Rekayasa Kehutanan",
  "Rekayasa kehutanan 3.1",                  "Rekayasa Kehutanan",
  "Teknik Biosistem",                        "Teknik Biosistem",
  "Teknik Industri",                         "Teknik Industri",
  "Teknik industri",                         "Teknik Industri",
  "teknik industri",                         "Teknik Industri",
  "Teknik Geomatika",                        "Teknik Geomatika",
  "Teknik geomatika",                        "Teknik Geomatika",
  "Teknik Kelautan",                         "Teknik Kelautan",
  "Teknik kelautan",                         "Teknik Kelautan",
  "Desain Komunikasi Visual",                "Desain Komunikasi Visual",
  "Desain komunikasi visual",                "Desain Komunikasi Visual",
  "Teknik Fisika",                           "Teknik Fisika",
  "Teknologi Industri Pertanian",            "Teknologi Industri Pertanian",
  "Sains lingkungan kelautan",               "Sains Lingkungan Kelautan",
  "SAINS LINGKUNGAN KELAUTAN",              "Sains Lingkungan Kelautan",
  "Rekayasa keolahragaan",                   "Rekayasa Keolahragaan",
  "Rekayasa Minyak & Gas",                   "Rekayasa Minyak dan Gas",
  "Rekayasa Tata Kelola Air Terpadu",        "Rekayasa Tata Kelola Air Terpadu",
  "Teknik Material",                         "Teknik Material",
  "Teknik Perkeretaapian",                   "Teknik Perkeretaapian"
)

df <- df |>
  left_join(prodi_lookup, by = c("prodi" = "variasi")) |>
  mutate(prodi = if_else(!is.na(kanonik), kanonik, str_to_title(prodi))) |>
  select(-kanonik)


# ── 9. Standarisasi teks kategorik ──────────────────────────
df <- df |>
  mutate(
    jenis_kelamin           = str_trim(jenis_kelamin),
    pendidikan_terakhir     = str_trim(str_to_upper(pendidikan_terakhir)),
    penerima_beasiswa       = str_trim(penerima_beasiswa),
    status_pekerjaan        = str_trim(status_pekerjaan),
    akses_internet          = str_trim(akses_internet),
    keterlibatan_organisasi = str_trim(keterlibatan_organisasi),
    jenis_tempat_tinggal    = str_trim(jenis_tempat_tinggal),
    jarak_dari_kampus       = str_trim(jarak_dari_kampus),
    pekerjaan_ayah          = str_trim(pekerjaan_ayah),
    pekerjaan_ibu           = str_trim(pekerjaan_ibu)
  )


# ── 10. Standarisasi uang saku ────────────────────────────────
df <- df |>
  mutate(
    uang_saku = case_when(
      str_detect(uang_saku, "500k|500 k") ~ "500k - 1jt",
      str_detect(uang_saku, "1 jt s\\.d 1,5|1jt.*1,5") ~ "1jt - 1,5jt",
      str_detect(uang_saku, "1,5 jt|1,5jt") ~ "1,5jt - 2jt",
      str_detect(uang_saku, "> 2") ~ "> 2jt",
      TRUE ~ str_trim(uang_saku)
    )
  )


# ── 11. Standarisasi pendapatan orang tua ─────────────────────
df <- df |>
  mutate(
    pendapatan_orangtua = case_when(
      str_detect(pendapatan_orangtua, "< 1")       ~ "< 1jt",
      str_detect(pendapatan_orangtua, "1jt.*3|1 jt.*3") ~ "1jt - 3jt",
      str_detect(pendapatan_orangtua, "3.*5")       ~ "3jt - 5jt",
      str_detect(pendapatan_orangtua, "5.*7")       ~ "5jt - 7jt",
      str_detect(pendapatan_orangtua, "7.*9")       ~ "7jt - 9jt",
      str_detect(pendapatan_orangtua, "> 9")         ~ "> 9jt",
      TRUE ~ str_trim(pendapatan_orangtua)
    )
  )


# ── 12. Imputasi missing values ──────────────────────────────
df <- df |>
  mutate(
    # Numerik → median
    ipk = if_else(is.na(ipk),
                  median(ipk, na.rm = TRUE), ipk),
    jam_belajar_perminggu = if_else(
      is.na(jam_belajar_perminggu),
      median(jam_belajar_perminggu, na.rm = TRUE),
      jam_belajar_perminggu
    ),
    tinggi_badan = if_else(is.na(tinggi_badan),
                           median(tinggi_badan, na.rm = TRUE), tinggi_badan),
    berat_badan = if_else(is.na(berat_badan),
                          median(berat_badan, na.rm = TRUE), berat_badan),
    jumlah_anggota_keluarga = if_else(
      is.na(jumlah_anggota_keluarga),
      as.integer(median(jumlah_anggota_keluarga, na.rm = TRUE)),
      jumlah_anggota_keluarga
    ),
    # Kategorik → modus
    pendidikan_terakhir = if_else(
      is.na(pendidikan_terakhir),
      names(sort(table(pendidikan_terakhir), decreasing = TRUE))[1],
      pendidikan_terakhir
    )
  )


# ── 13. Tambah kolom BMI ─────────────────────────────────────
df <- df |>
  mutate(
    bmi = round(berat_badan / ((tinggi_badan / 100)^2), 2)
  )


# ── 14. Validasi hasil ───────────────────────────────────────
cat("\n=== RINGKASAN DATA BERSIH ===\n")
cat("Jumlah baris :", nrow(df), "\n")
cat("Jumlah kolom :", ncol(df), "\n")

cat("\nMissing values per kolom:\n")
mv <- colSums(is.na(df))
if (sum(mv) == 0) {
  cat("  Tidak ada missing values\n")
} else {
  print(mv[mv > 0])
}

cat("\nStatistik variabel numerik:\n")
df |>
  select(ipk, jam_belajar_perminggu, tinggi_badan,
         berat_badan, bmi, jumlah_anggota_keluarga) |>
  summary() |>
  print()

cat("\nDistribusi prodi (top 10):\n")
df |> count(prodi, sort = TRUE) |> slice_head(n = 10) |> print()


# ── 15. Simpan output ────────────────────────────────────────
write_csv(df, "dataset_profil_mahasiswa_ITERA_clean.csv")
cat("\nFile disimpan: dataset_profil_mahasiswa_ITERA_clean.csv\n")
