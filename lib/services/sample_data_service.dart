import 'package:campus_kin/models/item_model.dart';
import 'package:campus_kin/services/database_service.dart';
import 'package:uuid/uuid.dart';

class SampleDataService {
  static const Uuid _uuid = Uuid();

  static final List<Map<String, dynamic>> _sampleItems = [
    {
      'title': 'Black Leather Wallet',
      'description': 'Lost my black leather wallet near the library. Contains student ID and some cash.',
      'category': 'Personal Items',
      'location': 'Main Library',
      'type': ItemType.lost,
      'userEmail': 'john.student@university.edu',
      'userPhone': '(555) 123-4567',
      'imagePath': 'https://pixabay.com/get/g71e6270164335e7900571265f84cde4863812fd16d843833c1a30ec1f4743dabab9e605f4158a3a499d4378a5e6bb08be16b8f99771679fb5274f50487b89a25_1280.jpg',
    },
    {
      'title': 'iPhone 13 Pro',
      'description': 'Found a space gray iPhone 13 Pro in the student center. Has a clear case with stickers.',
      'category': 'Electronics',
      'location': 'Student Center',
      'type': ItemType.found,
      'userEmail': 'sarah.finder@university.edu',
      'userPhone': '(555) 987-6543',
      'imagePath': 'https://pixabay.com/get/g61f9b2aefb84d131e8ed040e87671e483a341d663e3e2a9f3e51f49f7599b7f5afd4ed072240c9043aec49cba9b99249d86fe3706f2cca84e51eb76c1055f376_1280.jpg',
    },
    {
      'title': 'Set of Dorm Keys',
      'description': 'Lost my dorm keys somewhere between the cafeteria and dormitory building B.',
      'category': 'Keys',
      'location': 'Campus Cafeteria',
      'type': ItemType.lost,
      'userEmail': 'mike.resident@university.edu',
      'userPhone': '(555) 456-7890',
      'imagePath': 'https://pixabay.com/get/gcfd0765b3e76a8b0152969846cb8d14fd9559e09cc525658057beb70dae6c22169b4e820fee577a2df7aee6dc35652d0c07aedb412c67715f7763c0e51f799c6_1280.jpg',
    },
    {
      'title': 'Wireless Headphones',
      'description': 'Found Sony wireless headphones in the computer lab. They were left on desk 15.',
      'category': 'Electronics',
      'location': 'Computer Lab A',
      'type': ItemType.found,
      'userEmail': 'tech.helper@university.edu',
      'userPhone': '(555) 234-5678',
      'imagePath': 'https://pixabay.com/get/gb737c5efd8f1f136d04239697849d0adf251a3b974c02fea3ae1423cd4fff12513a4c5ddf85fd7932adf0cfc7908193bcc88516023a2cc0e5d638d862b6f4749_1280.jpg',
    },
    {
      'title': 'Blue Backpack',
      'description': 'Lost my navy blue Jansport backpack with textbooks and laptop inside.',
      'category': 'Bags',
      'location': 'Engineering Building',
      'type': ItemType.lost,
      'userEmail': 'eng.student@university.edu',
      'userPhone': '(555) 345-6789',
      'imagePath': 'https://pixabay.com/get/g80f41c46e31954e7b97ee1c46917796919b9c3ff6f2ea0d9c841a5225f1334b6763ea0f261a65973a15d90c4e39904f6240e901cae4709aac7feecc383e571b3_1280.jpg',
    },
    {
      'title': 'Red Water Bottle',
      'description': 'Found a red Hydro Flask water bottle in the gym locker room.',
      'category': 'Personal Items',
      'location': 'Campus Gym',
      'type': ItemType.found,
      'userEmail': 'gym.staff@university.edu',
      'userPhone': '(555) 567-8901',
      'imagePath': 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400',
    },
    {
      'title': 'Calculus Textbook',
      'description': 'Lost my Calculus III textbook with my name written inside the cover.',
      'category': 'Books',
      'location': 'Mathematics Building',
      'type': ItemType.lost,
      'userEmail': 'math.student@university.edu',
      'userPhone': '(555) 678-9012',
      'imagePath': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
    },
    {
      'title': 'Silver Watch',
      'description': 'Found a silver watch in the parking lot near the business school.',
      'category': 'Jewelry',
      'location': 'Business School Parking',
      'type': ItemType.found,
      'userEmail': 'security@university.edu',
      'userPhone': '(555) 789-0123',
      'imagePath': 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400',
    },
  ];

  static Future<void> loadSampleData() async {
    try {
      // Check if we already have data
      final existingItems = await DatabaseService.getAllItems();
      if (existingItems.isNotEmpty) return;

      final now = DateTime.now();
      
      for (int i = 0; i < _sampleItems.length; i++) {
        final sampleData = _sampleItems[i];
        final item = ItemModel(
          id: _uuid.v4(),
          title: sampleData['title'],
          description: sampleData['description'],
          category: sampleData['category'],
          location: sampleData['location'],
          datePosted: now.subtract(Duration(days: i)),
          dateLostFound: now.subtract(Duration(days: i + 1)),
          type: sampleData['type'],
          imagePath: sampleData['imagePath'],
          userEmail: sampleData['userEmail'],
          userPhone: sampleData['userPhone'],
        );
        
        await DatabaseService.addItem(item);
      }
      
      print('Sample data loaded successfully');
    } catch (e) {
      print('Error loading sample data: $e');
    }
  }
}