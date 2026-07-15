/// Tipe-tipe error spesifik yang terjadi dalam aplikasi FoodVision AI.
/// Setiap tipe memiliki pesan default yang informatif dalam Bahasa Indonesia.
enum AppErrorType {
  noInternet,
  timeout,
  modelNotLoaded,
  imageBroken,
  inferenceFailed,
  cameraFailed,
  galleryFailed,
  mealDbFailed,
  geminiFailed,
  unknown,
}

class AppException implements Exception {
  final AppErrorType type;
  final String message;
  final String? technicalDetail;

  const AppException({
    required this.type,
    required this.message,
    this.technicalDetail,
  });

  /// Pesan singkat untuk ditampilkan di SnackBar.
  String get userMessage => message;

  @override
  String toString() => 'AppException(${type.name}): $message'
      '${technicalDetail != null ? ' [$technicalDetail]' : ''}';

  // --- Factory constructors untuk setiap skenario error ---

  factory AppException.noInternet() => const AppException(
        type: AppErrorType.noInternet,
        message: 'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.',
      );

  factory AppException.timeout(String service) => AppException(
        type: AppErrorType.timeout,
        message: 'Permintaan ke $service habis waktu. Coba lagi dalam beberapa saat.',
      );

  factory AppException.modelNotLoaded() => const AppException(
        type: AppErrorType.modelNotLoaded,
        message: 'Model AI belum selesai dimuat. Tunggu sebentar lalu coba lagi.',
      );

  factory AppException.imageBroken() => const AppException(
        type: AppErrorType.imageBroken,
        message: 'Gambar tidak dapat dibaca atau rusak. Pilih gambar lain.',
      );

  factory AppException.inferenceFailed(String detail) => AppException(
        type: AppErrorType.inferenceFailed,
        message: 'Analisis gambar gagal. Pastikan gambar berformat JPG/PNG yang valid.',
        technicalDetail: detail,
      );

  factory AppException.cameraFailed(String detail) => AppException(
        type: AppErrorType.cameraFailed,
        message: 'Kamera tidak dapat dibuka. Pastikan izin kamera telah diberikan.',
        technicalDetail: detail,
      );

  factory AppException.galleryFailed(String detail) => AppException(
        type: AppErrorType.galleryFailed,
        message: 'Tidak dapat mengakses galeri. Pastikan izin penyimpanan telah diberikan.',
        technicalDetail: detail,
      );

  factory AppException.mealDbFailed(String detail) => AppException(
        type: AppErrorType.mealDbFailed,
        message: 'Gagal mengambil data resep dari MealDB.',
        technicalDetail: detail,
      );

  factory AppException.geminiFailed(String detail) => AppException(
        type: AppErrorType.geminiFailed,
        message: 'Estimasi nutrisi dari Gemini AI tidak tersedia saat ini.',
        technicalDetail: detail,
      );

  factory AppException.unknown(String detail) => AppException(
        type: AppErrorType.unknown,
        message: 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.',
        technicalDetail: detail,
      );
}
