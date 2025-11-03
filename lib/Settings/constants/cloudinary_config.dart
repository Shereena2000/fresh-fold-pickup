class CloudinaryConfig {
  // Cloudinary credentials
  static const String cloudName = 'dvcodgbkd';
  static const String apiKey = '692484724374318';
  static const String apiSecret = 'hIZ6N5OjvIFXks9wWAAcveYA8v8';
  
  // Upload configuration
  static const String uploadPreset = 'driver_profiles'; // Create this in Cloudinary dashboard
  static const String promoFolder = 'driver_profiles';
  
  // Upload URL
  static String get uploadUrl => 
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  
  // Get image URL with transformations
  static String getImageUrl(String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    String transformations = '';
    
    if (width != null || height != null) {
      List<String> params = [];
      if (width != null) params.add('w_$width');
      if (height != null) params.add('h_$height');
      params.add('c_fill');
      transformations = params.join(',');
    }
    
    if (quality != 'auto') {
      transformations += transformations.isNotEmpty ? ',q_$quality' : 'q_$quality';
    }
    
    if (format != 'auto') {
      transformations += transformations.isNotEmpty ? ',f_$format' : 'f_$format';
    }
    
    final baseUrl = 'https://res.cloudinary.com/$cloudName/image/upload';
    
    if (transformations.isNotEmpty) {
      return '$baseUrl/$transformations/$publicId';
    }
    
    return '$baseUrl/$publicId';
  }
}

