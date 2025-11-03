# Cloudinary Setup Guide

## ✅ Current Configuration (Already Configured)

**Cloud Name**: `dvcodgbkd`  
**API Key**: `692484724374318`  
**API Secret**: `hIZ6N5OjvIFXks9wWAAcveYA8v8`  
**Upload Preset**: `driver_profiles`  
**Folder**: `driver_profiles/`

**Implementation**: Custom HTTP multipart upload ✅

---

## 📋 Files Created

### Configuration:
- ✅ `lib/Settings/constants/cloudinary_config.dart` - Cloudinary credentials
- ✅ `lib/Settings/services/cloudinary_service.dart` - Upload service

### Implementation:
- Uses `http` package for multipart upload
- No external Cloudinary package needed
- Full control over upload process

---

## 📋 Setup Steps (One-Time)

### 1. Create Upload Preset in Cloudinary Dashboard

You need to create an **unsigned upload preset** in Cloudinary:

1. Go to [Cloudinary Console](https://console.cloudinary.com/)
2. Navigate to **Settings** → **Upload**
3. Scroll down to **Upload presets**
4. Click **Add upload preset**
5. Configure the preset:
   - **Preset name**: `driver_profiles`
   - **Signing Mode**: **Unsigned** ⚠️ Important!
   - **Folder**: `driver_profiles` (optional but recommended)
   - **Upload Mapping**: Leave empty
   - **Allowed formats**: jpg, png, jpeg
   - **Max file size**: 10 MB (recommended)
   - **Image transformations**: Optional (can add auto quality/format)
6. Click **Save**

---

---

## 📸 Upload Flow

```
1. Driver clicks camera icon
2. Selects image from camera/gallery
3. Image compressed locally (1024x1024, 85% quality)
4. Upload to Cloudinary
   └── Folder: driver_profiles/
   └── Public ID: driver_{uid}_{timestamp}
5. Cloudinary returns secure URL
6. URL saved to Firestore (drivers collection)
7. Image displayed in Profile screen
```

---

## 🌐 Image URLs

Cloudinary URLs will look like:
```
https://res.cloudinary.com/dvcodgbkd/image/upload/v1234567890/driver_profiles/driver_abc123_1699123456789.jpg
```

---

## ✅ Benefits of Cloudinary

- ✅ **Free tier**: 25 GB storage, 25 GB bandwidth
- ✅ **Automatic optimization**: WebP, AVIF support
- ✅ **Image transformations**: Resize, crop, format on-the-fly
- ✅ **Fast CDN**: Global content delivery
- ✅ **Thumbnails**: Automatic generation

---

## 🔐 Security Best Practices

1. ✅ Use **unsigned uploads** for mobile apps (already configured)
2. ✅ Set **folder restrictions** in upload preset
3. ✅ Set **max file size** limits
4. ✅ Set **allowed formats** (jpg, png only)
5. ⚠️ **Never expose API Secret** in client code

---

## 🎯 Image Optimization (Optional)

You can transform images on-the-fly by modifying URLs:

**Original**:
```
https://res.cloudinary.com/dvcodgbkd/image/upload/v1234567890/driver_profiles/image.jpg
```

**Optimized (300x300, auto quality)**:
```
https://res.cloudinary.com/dvcodgbkd/image/upload/w_300,h_300,c_fill,q_auto/v1234567890/driver_profiles/image.jpg
```

---

## 📊 Storage Structure

```
Cloudinary Storage
└── driver_profiles/
    ├── driver_abc123_1699123456789.jpg
    ├── driver_xyz789_1699234567890.jpg
    └── ...
```

Firestore Storage:
```
drivers/
└── {driverId}/
    └── profileImageUrl: "https://res.cloudinary.com/..."
```

---

## 🐛 Troubleshooting

### Error: "Upload preset not found"
- ✅ Create the `driver_profiles` upload preset in Cloudinary
- ✅ Make sure it's set to **Unsigned**

### Error: "Invalid signature"
- ✅ Check that upload preset is **Unsigned**
- ✅ Remove API Secret from CloudinaryPublic constructor

### Error: "Upload failed"
- ✅ Check internet connection
- ✅ Verify cloud name is correct: `dvcodgbkd`
- ✅ Check file size is under limit

---

## ✅ Testing Checklist

- [ ] Create upload preset in Cloudinary
- [ ] Set preset to **Unsigned**
- [ ] Test image upload from app
- [ ] Verify image appears in Cloudinary dashboard
- [ ] Verify image displays in Profile screen
- [ ] Test with different image sizes
- [ ] Test with camera and gallery

---

## 📝 Current Implementation

### **CloudinaryConfig** (`lib/Settings/constants/cloudinary_config.dart`):
```dart
class CloudinaryConfig {
  static const String cloudName = 'dvcodgbkd';
  static const String uploadPreset = 'driver_profiles';
  static const String promoFolder = 'driver_profiles';
  static String get uploadUrl => 
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
}
```

### **CloudinaryService** (`lib/Settings/services/cloudinary_service.dart`):
```dart
class CloudinaryService {
  Future<Map<String, dynamic>?> uploadImage(File imageFile) async {
    // HTTP multipart upload
    // Returns: { 'url': '...', 'public_id': '...' }
  }
}
```

### **AuthViewModel** (`lib/Features/auth/view_model.dart/auth_view_model.dart`):
```dart
final CloudinaryService _cloudinaryService = CloudinaryService();

Future<bool> uploadProfileImage() async {
  // Upload using CloudinaryService
  final result = await _cloudinaryService.uploadImage(imageFile);
  final downloadUrl = result['url'];
  // Save to Firestore
  // Update UI
}
```

**Benefits**:
- ✅ No external Cloudinary package needed
- ✅ Uses standard `http` package
- ✅ Full control over upload process
- ✅ Better error handling
- ✅ Cleaner code

---

## 🎉 Done!

Once you create the upload preset, image upload will work automatically!

