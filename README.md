# JaRiksa Mobile App 📱✨

**JaRiksa** adalah platform manajemen kualitas jasa berbasis Cloud dan Integrated Vision AI yang mengotomatisasi inspeksi barang dan menghasilkan dokumentasi digital yang objektif sebelum pengerjaan dimulai. Dengan bukti kondisi barang yang aman dan dapat dipertanggungjawabkan, JaRiksa membantu UMKM jasa mengurangi sengketa, melindungi pendapatan, dan meningkatkan kepercayaan pelanggan.

---

## 🚀 Fitur Utama

1. **Autentikasi Pengguna**: Sistem masuk (Login) aman untuk operator atau pemilik toko.
2. **Dashboard Operasional**: 
   * Ringkasan pendapatan hari ini lengkap dengan tren kenaikan/penurunan dibanding hari kemarin.
   * Status operasional real-time (Pesanan Masuk, Sedang Diproses, Siap Diambil).
   * Daftar aktivitas terkini/pesanan terbaru.
3. **Pencatatan Pesanan Baru**:
   * Pengecekan pelanggan terdaftar secara otomatis via nomor HP (dengan fitur *debounce* otomatis).
   * Pendaftaran pelanggan baru secara langsung dari aplikasi jika nomor HP belum terdaftar.
4. **Analisis Kerusakan AI**:
   * Fitur pemotretan kondisi fisik barang sebelum dicuci menggunakan kamera bawaan.
   * Analisis AI untuk mendeteksi area dan tingkat kerusakan (sobek, luntur, noda, dll.) yang menghasilkan daftar tag kerusakan (*damage tags*) otomatis untuk transparansi ke pelanggan.
5. **Pembayaran & Kasir Terintegrasi**:
   * Metode pembayaran fleksibel: **Bayar Sekarang (NOW)** menggunakan gerbang pembayaran (Midtrans) atau **Bayar Nanti (LATER)** saat pengambilan barang.
6. **Pelacakan & Update Status**:
   * Pelacakan kemajuan pengerjaan pesanan menggunakan visual *stepper* interaktif (Masuk → Diproses → Siap Diambil → Selesai).
   * Pembaruan status pesanan secara manual oleh operator toko melalui lembar pilihan (*bottom sheet*).

---

## 🛠️ Teknologi yang Digunakan

* **Framework**: [Flutter](https://flutter.dev) (SDK `^3.12.0`)
* **State Management**: [Flutter Bloc](https://pub.dev/packages/flutter_bloc) & [Bloc](https://pub.dev/packages/bloc)
* **HTTP Client / Networking**: [Dio](https://pub.dev/packages/dio)
* **Responsive Layout**: [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil)
* **UI & Animasi**:
  * [Google Fonts](https://pub.dev/packages/google_fonts) untuk tipografi modern.
  * [Animated Bottom Navigation Bar](https://pub.dev/packages/animated_bottom_navigation_bar) untuk menu navigasi yang halus.
  * [Shimmer](https://pub.dev/packages/shimmer) untuk efek loading skeleton premium.
  * [Flutter SVG](https://pub.dev/packages/flutter_svg) untuk rendering ikon berkualitas tinggi.
* **Integrasi Hardware & Web**:
  * [Camera](https://pub.dev/packages/camera) & [Image Picker](https://pub.dev/packages/image_picker) untuk pengambilan foto kondisi barang.
  * [URL Launcher](https://pub.dev/packages/url_launcher) untuk redirect pembayaran gerbang Midtrans.

---

## 📁 Struktur Proyek (Architecture)

Proyek ini menerapkan arsitektur berbasis fitur (*Feature-First*) yang bersih dan mudah dipelihara:

```text
lib/
├── core/
│   ├── pages/         # Halaman utama aplikasi (MainPage, dll)
│   ├── storage/       # Manajemen penyimpanan lokal (TokenStorage)
│   ├── theme/         # Desain sistem (Warna, Tipografi, Font Weight)
│   └── widgets/       # Global reusable widgets (AppButton, AppNavbar, TextField)
└── features/
    ├── auth/          # Halaman login dan logika autentikasi
    ├── home/          # Halaman dashboard utama, model, dan cubit operasional
    ├── order/         # Alur pencatatan pesanan, scan kamera, AI report, & pembayaran
    ├── order_list/    # Halaman daftar pesanan dan detail rincian pesanan
    └── splash/        # Halaman splash screen pembuka aplikasi
```

---

## 🏁 Cara Menjalankan Projek Secara Lokal

### 1. Prasyarat (Prerequisites)
Pastikan Anda telah memasang perangkat lunak berikut di komputer Anda:
* **Flutter SDK** versi terbaru (Minimal versi `3.12.0`).
* **Dart SDK** yang cocok dengan versi Flutter Anda.
* **Android Studio** (untuk emulator Android) atau **Xcode** (untuk emulator iOS di macOS).
* Koneksi internet aktif untuk mendownload pustaka pubspec dan berkomunikasi dengan API backend (`https://vincent.bccdev.id/api`).

### 2. Langkah Instalasi

1. **Clone repositori ini**:
   ```bash
   git clone https://github.com/Niebll/Jariksa-Mobile-Apps.git
   cd jariksa
   ```

2. **Dapatkan dependencies proyek**:
   Jalankan perintah berikut di terminal root proyek untuk mengunduh semua pustaka yang tertulis di `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

3. **Pastikan perangkat/emulator terhubung**:
   Untuk melihat daftar perangkat yang terdeteksi, jalankan:
   ```bash
   flutter devices
   ```

4. **Jalankan Aplikasi**:
   Mulai aplikasi dalam mode debug menggunakan perintah:
   ```bash
   flutter run
   ```

### 3. Membangun Aplikasi (Build Production Bundle)

* **Membangun APK Android**:
  ```bash
  flutter build apk --release
  ```
* **Membangun iOS App Bundle (memerlukan macOS)**:
  ```bash
  flutter build ipa --release
  ```

---

## 🔒 Konfigurasi API & Environment

Konfigurasi API backend default saat ini diarahkan ke:
`https://vincent.bccdev.id/api`

Informasi autentikasi disimpan secara lokal menggunakan `SharedPreferences` via class `TokenStorage` yang terletak di [token_storage.dart](file:///d:/Flutter/%20Project/jariksa/lib/core/storage/token_storage.dart).

---
