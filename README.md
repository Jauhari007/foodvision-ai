# FoodVision AI

FoodVision AI adalah aplikasi mobile cerdas berbasis Flutter yang menggunakan Machine Learning (TensorFlow Lite) untuk mengenali jenis makanan secara instan dari kamera atau galeri foto. Aplikasi ini dilengkapi dengan integrasi **Gemini AI** untuk mengestimasi nilai gizi makanan, serta **MealDB API** untuk menyajikan resep makanan yang relevan.

Aplikasi ini dirancang dengan antarmuka yang modern, responsif untuk berbagai ukuran layar (smartphone hingga tablet), dan menerapkan arsitektur kode yang bersih serta aman.

---

## 🚀 Fitur Utama

-   📷 **Camera Integration**: Ambil foto makanan langsung menggunakan kamera perangkat Anda.
-   🖼️ **Gallery Picker**: Pilih foto makanan yang ada di galeri penyimpanan Anda.
-   ✂️ **Crop Image**: Potong dan sesuaikan area gambar makanan secara presisi sebelum dianalisis oleh model ML.
-   🤖 **TensorFlow Lite**: Klasifikasi makanan secara offline menggunakan model Deep Learning lokal (`food_classifier.tflite`) yang berjalan cepat di background isolate.
-   📊 **Confidence Score Validation**: Validasi tingkat kepercayaan hasil prediksi. Jika di bawah 60%, aplikasi akan memberikan peringatan bahwa gambar bukan makanan.
-   📈 **Top 5 Prediction**: Menampilkan hingga 5 alternatif prediksi makanan dengan persentase kecocokannya.
-   🍽️ **MealDB API**: Mencari resep makanan, kategori, daerah asal, dan instruksi pembuatan secara real-time berdasarkan hasil deteksi makanan.
-   🧠 **Gemini AI Nutrition**: Mengestimasi informasi kandungan gizi (Kalori, Protein, Karbohidrat, Lemak, dan Serat) per porsi menggunakan Google Gemini API (`gemini-flash-latest`).
-   🛡️ **Professional Error Handling**: Penanganan error yang kuat untuk berbagai situasi seperti tidak ada koneksi internet, timeout API, kamera/galeri tidak diizinkan, model belum siap, atau gambar rusak.

---

## 📁 Struktur Folder Project

Aplikasi ini menerapkan struktur **Simple Clean Architecture** untuk memastikan kode modular, mudah dipelihara, dan siap diproduksi (*production-ready*).

```text
lib/
├── core/
│   ├── constants/     # Warna, ukuran standar, gaya teks, dan string lokalisasi
│   ├── errors/        # Kelas AppException bertingkat & utilitas ErrorHandler
│   └── theme/         # Konfigurasi AppTheme dasar (Font Poppins)
├── models/            # Model data/entitas (Meal, Nutrition, Prediction)
├── pages/             # Halaman utama aplikasi (HomePage, PreviewPage)
├── providers/         # State Management menggunakan Provider (PredictionProvider)
├── repository/        # Mediator antara data service dan UI (MealRepository)
├── services/          # Layanan eksternal (GeminiService, MealService, TfliteService, ImageService)
├── widgets/           # Reusable widgets (Cards, Dialogs, Loading Indicators)
└── main.dart          # Entry point aplikasi
```

---

## 🛠️ Arsitektur Project

-   **Presentation Layer (`pages/` & `widgets/`)**:
    Menangani pembuatan UI. Halaman besar didekomposisi menjadi widget-widget kecil yang modular (seperti `PrimaryPredictionCard`, `RecipeCard`, `NutritionCard`) untuk menghindari nested widget yang terlalu dalam.
-   **State Management (`providers/`)**:
    Mengatur state secara reaktif menggunakan `Provider` dan `ChangeNotifier` untuk memisahkan logika bisnis dari UI.
-   **Repository Layer (`repository/`)**:
    Mengabstraksikan sumber data. `MealRepository` bertanggung jawab mencocokkan hasil klasifikasi ML dengan basis data resep eksternal, lengkap dengan logika pencarian bertahap (*progressive fallback*).
-   **Service Layer (`services/`)**:
    Interaksi langsung dengan sistem operasi, SDK, dan API pihak ketiga. Contohnya, `TfliteService` menjalankan proses inferensi model berat di dalam thread isolate terpisah agar UI tetap mulus (60 FPS).
-   **Core Layer (`core/`)**:
    Kumpulan aset global seperti tema, parameter layout adaptif, penanganan error tersentralisasi (`AppException`), dan string lokalisasi Bahasa Indonesia.

---

## 📦 Dependencies

Beberapa package Flutter utama yang digunakan dalam project ini:

*   [`flutter_litert`](https://pub.dev/packages/flutter_litert) - Menjalankan inferensi model TensorFlow Lite / LiteRT.
*   [`google_generative_ai`](https://pub.dev/packages/google_generative_ai) - Akses ke API Google Gemini.
*   [`image_picker`](https://pub.dev/packages/image_picker) - Mengambil gambar dari galeri atau kamera.
*   [`image_cropper`](https://pub.dev/packages/image_cropper) - Memotong gambar sebelum diumpankan ke model ML.
*   [`provider`](https://pub.dev/packages/provider) - State management.
*   [`http`](https://pub.dev/packages/http) - Melakukan HTTP Request ke REST API MealDB.
*   [`flutter_spinkit`](https://pub.dev/packages/flutter_spinkit) - Animasi loading indicator yang estetik.

---

## ⚙️ Cara Instalasi & Menjalankan

### Prasyarat
- Flutter SDK terinstal di perangkat Anda (versi terbaru direkomendasikan).
- Akun Google AI Studio untuk mendapatkan Gemini API Key.

### Langkah-langkah

1.  **Clone repositori ini:**
    ```bash
    git clone https://github.com/Jauhari007/foodvision-ai.git
    cd foodvision-ai
    ```

2.  **Ambil dependensi project:**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Keamanan API Key lokal:**
    Buat file `.env` di root project untuk menyimpan API Key Anda (file ini secara otomatis diabaikan oleh Git demi keamanan):
    ```env
    GEMINI_API_KEY=KUNCI_API_GEMINI_ANDA
    ```

4.  **Jalankan aplikasi dengan API Key:**
    Jalankan perintah berikut di terminal Anda untuk mengompilasi dan menguji aplikasi:
    ```bash
    flutter run --dart-define=GEMINI_API_KEY=KUNCI_API_GEMINI_ANDA
    ```

    *Tips untuk Pengguna VS Code:*
    Anda cukup membuka menu **Run and Debug (F5)** dan memilih konfigurasi **"FoodVision AI (Debug)"** karena API Key lokal sudah dikonfigurasi secara aman di file `.vscode/launch.json` lokal Anda.

---

## 📸 Screenshots

| Halaman Utama | Deteksi Makanan Sukses | Makanan Tidak Dikenali (< 60%) |
| :---: | :---: | :---: |
| *[Screenshot Utama]* | *[Screenshot Hasil Deteksi]* | *[Screenshot Peringatan]* |

*(Catatan: Anda dapat menaruh gambar screenshot aplikasi di folder assets/screenshots dan memperbarui tautan di atas.)*
