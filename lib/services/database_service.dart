import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_kin/models/item_model.dart';
import 'package:campus_kin/models/match_model.dart';

class DatabaseService {
  static const String _itemsKey = 'campus_kin_items';
  static const String _matchesKey = 'campus_kin_matches';
  
  static late SharedPreferences _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Items CRUD
  static Future<List<ItemModel>> getAllItems() async {
    final String? itemsJson = _prefs.getString(_itemsKey);
    if (itemsJson == null) return [];
    
    final List<dynamic> itemsList = json.decode(itemsJson);
    return itemsList.map((json) => ItemModel.fromJson(json)).toList();
  }

  static Future<List<ItemModel>> getItemsByType(ItemType type) async {
    final items = await getAllItems();
    return items.where((item) => item.type == type).toList();
  }

  static Future<bool> addItem(ItemModel item) async {
    try {
      final items = await getAllItems();
      items.add(item);
      
      final String itemsJson = json.encode(items.map((item) => item.toJson()).toList());
      return await _prefs.setString(_itemsKey, itemsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateItem(ItemModel updatedItem) async {
    try {
      final items = await getAllItems();
      final index = items.indexWhere((item) => item.id == updatedItem.id);
      
      if (index != -1) {
        items[index] = updatedItem;
        final String itemsJson = json.encode(items.map((item) => item.toJson()).toList());
        return await _prefs.setString(_itemsKey, itemsJson);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteItem(String itemId) async {
    try {
      final items = await getAllItems();
      items.removeWhere((item) => item.id == itemId);
      
      final String itemsJson = json.encode(items.map((item) => item.toJson()).toList());
      return await _prefs.setString(_itemsKey, itemsJson);
    } catch (e) {
      return false;
    }
  }

  // Matches CRUD
  static Future<List<MatchModel>> getAllMatches() async {
    final String? matchesJson = _prefs.getString(_matchesKey);
    if (matchesJson == null) return [];
    
    final List<dynamic> matchesList = json.decode(matchesJson);
    return matchesList.map((json) => MatchModel.fromJson(json)).toList();
  }

  static Future<bool> addMatch(MatchModel match) async {
    try {
      final matches = await getAllMatches();
      matches.add(match);
      
      final String matchesJson = json.encode(matches.map((match) => match.toJson()).toList());
      return await _prefs.setString(_matchesKey, matchesJson);
    } catch (e) {
      return false;
    }
  }

  static Future<List<ItemModel>> searchItems(String query, {ItemType? type, String? category}) async {
    final items = await getAllItems();
    return items.where((item) {
      final matchesQuery = query.isEmpty || 
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.description.toLowerCase().contains(query.toLowerCase()) ||
          item.location.toLowerCase().contains(query.toLowerCase());
      
      final matchesType = type == null || item.type == type;
      final matchesCategory = category == null || item.category == category;
      
      return matchesQuery && matchesType && matchesCategory && item.status == ItemStatus.active;
    }).toList();
  }
}