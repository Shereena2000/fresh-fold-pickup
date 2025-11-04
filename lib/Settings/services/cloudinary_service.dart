import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/cloudinary_config.dart';

class CloudinaryService {
  /// Upload image to Cloudinary
  Future<Map<String, dynamic>?> uploadImage(File imageFile) async {
    print('════════════════════════════════════════');
    print('🚀 CLOUDINARY UPLOAD STARTING');
    print('════════════════════════════════════════');
    
    try {
      // Verify file exists
      final fileExists = await imageFile.exists();
      print('📁 File exists: $fileExists');
      
      if (!fileExists) {
        throw Exception('Image file does not exist at path: ${imageFile.path}');
      }
      
      final fileSize = await imageFile.length();
      print('📁 File size: $fileSize bytes');
      print('📁 File path: ${imageFile.path}');
      
      // Configuration
      print('');
      print('⚙️  Configuration:');
      print('   Cloud Name: ${CloudinaryConfig.cloudName}');
      print('   Upload Preset: ${CloudinaryConfig.uploadPreset}');
      print('   Upload URL: ${CloudinaryConfig.uploadUrl}');
      
      final url = Uri.parse(CloudinaryConfig.uploadUrl);

      final request = http.MultipartRequest('POST', url);
      
      // Add ONLY the upload preset (unsigned upload)
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      
      print('');
      print('📤 Request Details:');
      print('   Method: POST');
      print('   URL: $url');
      print('   Fields: ${request.fields}');
      
      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      
      request.files.add(multipartFile);
      print('   File name: ${multipartFile.filename}');
      print('   File length: ${multipartFile.length} bytes');

      print('');
      print('⏳ Sending request to Cloudinary...');
      
      final response = await request.send();
      
      print('📥 Response received!');
      print('   Status code: ${response.statusCode}');
      
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('');
        print('✅ SUCCESS: Upload completed!');
        
        final jsonData = json.decode(responseData);
        final secureUrl = jsonData['secure_url'];
        final publicId = jsonData['public_id'];
        
        print('   Secure URL: $secureUrl');
        print('   Public ID: $publicId');
        print('   Format: ${jsonData['format']}');
        print('   Size: ${jsonData['bytes']} bytes');
        print('════════════════════════════════════════');
        
        return {
          'url': secureUrl,
          'public_id': publicId,
        };
      } else {
        print('');
        print('❌ FAILED: Upload rejected by Cloudinary');
        print('   Status: ${response.statusCode}');
        print('   Response: $responseData');
        print('════════════════════════════════════════');
        
        // Parse error
        try {
          final errorJson = json.decode(responseData);
          final errorMessage = errorJson['error']['message'] ?? 'Unknown error';
          throw Exception('Cloudinary Error: $errorMessage');
        } catch (e) {
          throw Exception('Upload failed with status ${response.statusCode}: $responseData');
        }
      }
    } catch (e) {
      print('');
      print('❌ EXCEPTION OCCURRED');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('════════════════════════════════════════');
      rethrow;
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

