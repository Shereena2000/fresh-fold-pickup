import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/cloudinary_config.dart';

class CloudinaryService {
  /// Upload image to Cloudinary
  Future<Map<String, dynamic>?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse(CloudinaryConfig.uploadUrl);

      final request = http.MultipartRequest('POST', url);
      
      // Add upload preset
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      
      // Add folder for organization
      request.fields['folder'] = CloudinaryConfig.promoFolder;
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        
        return {
          'url': jsonData['secure_url'],
          'public_id': jsonData['public_id'],
        };
      } else {
        final responseData = await response.stream.bytesToString();
        throw Exception('Failed to upload image: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      throw Exception('Error uploading to Cloudinary: $e');
    }
  }

  /// Delete image from Cloudinary (requires API key and signature)
  /// For production, implement this on backend/Cloud Functions
  Future<bool> deleteImage(String publicId) async {
    // Note: Deletion requires authentication via API key and signature
    // For now, we'll just return true and handle deletion manually or via backend
    // In production, implement this using Cloud Functions with Cloudinary Admin API
    return true;
  }
}

