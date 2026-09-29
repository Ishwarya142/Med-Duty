class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = 'medduty-cloud';
  static const String uploadPreset = 'medduty_unsigned_preset';
  static const String apiKey = '999999999999999';
  static const String baseUrl = 'https://api.cloudinary.com/v1_1/$cloudName';
  static const String uploadUrl = '$baseUrl/image/upload';
  static const String unsignedUploadUrl = '$baseUrl/image/upload';
  static const String autoUploadUrl = '$baseUrl/auto/upload';
  static const List<String> allowedImageExtensions = ['.jpg', '.jpeg', '.png'];
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
}
