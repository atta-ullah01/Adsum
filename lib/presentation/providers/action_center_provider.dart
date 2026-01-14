import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionCenterNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _loadActionItems();
  }

  Future<List<Map<String, dynamic>>> _loadActionItems() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/action_items.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.map((item) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        
        // Parse colors
        if (map.containsKey('bg_color')) {
          map['bg'] = Color(int.parse(map['bg_color']));
        }
        if (map.containsKey('accent_color')) {
          map['accent'] = Color(int.parse(map['accent_color']));
        }
        
        // Ensure payload is a Map
        if (map['payload'] != null) {
          map['payload'] = Map<String, dynamic>.from(map['payload']);
        }

        // Map 'body' to description/subtitle if needed or keep as is.
        // The UI might use specific keys. 
        // Current UI uses: title, date, bg, accent, payload.
        // JSON has: title, body, created_at, bg_color, accent_color, payload.
        
        // Formatting date (mock logic for now, using created_at)
        map['date'] = _formatDate(map['created_at']);

        return map;
      }).toList();
    } catch (e) {
      debugPrint("Error loading action items: $e");
      return [];
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Unknown Date';
    // For now returning simple string, could use intl
    return "Today"; // simplistic mock
  }

  Future<void> resolveItem(String itemId, String action) async {
    final currentState = state.value ?? [];
    // Remove locally
    state = AsyncValue.data(currentState.where((item) => item['item_id'] != itemId).toList());
    
    // In a real app, we would make an API call here.
  }
}

final actionCenterProvider = AsyncNotifierProvider<ActionCenterNotifier, List<Map<String, dynamic>>>(ActionCenterNotifier.new);
