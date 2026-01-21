import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:campus_kin/models/item_model.dart';

class AIService {
  // Using Hugging Face's free inference API
  static const String _apiUrl = 'https://api-inference.huggingface.co/models/sentence-transformers/clip-ViT-B-32';
  static const String _apiKey = 'hf_demo'; // Public demo key, replace with your own for production

  static Future<List<double>?> getImageEmbedding(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) return null;

      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // For demo purposes, we'll use a simple fallback similarity calculation
      // In production, you would use a proper image embedding service
      return _generateSimpleEmbedding(imageBytes);
    } catch (e) {
      print('Error getting image embedding: $e');
      return null;
    }
  }

  static Future<double> calculateSimilarity(String imagePath1, String imagePath2) async {
    try {
      final embedding1 = await getImageEmbedding(imagePath1);
      final embedding2 = await getImageEmbedding(imagePath2);
      
      if (embedding1 == null || embedding2 == null) {
        return _calculateBasicSimilarity(imagePath1, imagePath2);
      }
      
      return _cosineSimilarity(embedding1, embedding2);
    } catch (e) {
      print('Error calculating similarity: $e');
      return 0.0;
    }
  }

  // Simple embedding generation based on image properties
  static List<double> _generateSimpleEmbedding(Uint8List imageBytes) {
    final List<double> embedding = [];
    
    // Generate a simple feature vector based on image data
    for (int i = 0; i < 128; i++) {
      final int index = (i * imageBytes.length / 128).floor();
      embedding.add((imageBytes[index] / 255.0) * 2 - 1);
    }
    
    return embedding;
  }

  // Cosine similarity calculation
  static double _cosineSimilarity(List<double> vec1, List<double> vec2) {
    if (vec1.length != vec2.length) return 0.0;
    
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;
    
    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      norm1 += vec1[i] * vec1[i];
      norm2 += vec2[i] * vec2[i];
    }
    
    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;
    
    return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
  }

  // Basic similarity fallback based on file properties
  static double _calculateBasicSimilarity(String imagePath1, String imagePath2) {
    try {
      final File file1 = File(imagePath1);
      final File file2 = File(imagePath2);
      
      final int size1 = file1.lengthSync();
      final int size2 = file2.lengthSync();
      
      // Simple size-based similarity (for demo)
      final double sizeDiff = (size1 - size2).abs() / Math.max(size1.toDouble(), size2.toDouble());
      return Math.max(0.0, 1.0 - sizeDiff);
    } catch (e) {
      return 0.0;
    }
  }

  static Future<List<ItemModel>> findSimilarItems(ItemModel targetItem, List<ItemModel> candidateItems, {double threshold = 0.7}) async {
    final List<ItemModel> similarItems = [];
    
    for (final candidate in candidateItems) {
      // Don't compare with same type (lost with lost, found with found)
      if (candidate.type == targetItem.type) continue;
      
      // Don't compare with same user
      if (candidate.userEmail == targetItem.userEmail) continue;
      
      final similarity = await calculateSimilarity(targetItem.imagePath, candidate.imagePath);
      
      if (similarity >= threshold) {
        similarItems.add(candidate);
      }
    }
    
    // Sort by similarity (higher first)
    similarItems.sort((a, b) {
      // This is a simplified sort, in production you'd store similarity scores
      return b.datePosted.compareTo(a.datePosted);
    });
    
    return similarItems;
  }
}

// Simple math utilities
class Math {
  static double max(double a, double b) => a > b ? a : b;
  static double sqrt(double x) => x < 0 ? 0 : x == 0 ? 0 : _approximateSqrt(x);
  
  static double _approximateSqrt(double x) {
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
}