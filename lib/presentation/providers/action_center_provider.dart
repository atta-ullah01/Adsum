import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/action_item.dart';

class ActionCenterNotifier extends AsyncNotifier<List<ActionItem>> {
  @override
  Future<List<ActionItem>> build() async {
    return _loadActionItems();
  }

  Future<List<ActionItem>> _loadActionItems() async {
    try {
      final repo = ref.watch(actionItemRepositoryProvider);
      return repo.getAll();
    } catch (e) {
      debugPrint("Error loading action items: $e");
      return [];
    }
  }

  Future<void> resolveItem(String itemId, String action) async {
    final repo = ref.read(actionItemRepositoryProvider);
    final resolution = Resolution.fromString(action.replaceAll(' ', '_').toUpperCase()); 
    
    if (resolution != null) {
      // Optimistic update
      final previousState = state.asData?.value ?? [];
      state = AsyncValue.data(previousState.where((item) => item.itemId != itemId).toList());
      
      try {
        await repo.resolve(itemId, resolution);
      } catch (e) {
        // Revert on failure
        state = AsyncValue.data(previousState);
        debugPrint("Failed to resolve item: $e");
      }
    }
  }
}

final actionCenterProvider = AsyncNotifierProvider<ActionCenterNotifier, List<ActionItem>>(ActionCenterNotifier.new);
