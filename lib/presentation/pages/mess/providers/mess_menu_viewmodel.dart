import 'package:adsum/data/providers/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessMenuState {

  MessMenuState({
    required this.selectedHostel,
    required this.selectedDate,
  });
  final String selectedHostel; // ID
  final DateTime selectedDate;

  MessMenuState copyWith({
    String? selectedHostel,
    DateTime? selectedDate,
  }) {
    return MessMenuState(
      selectedHostel: selectedHostel ?? this.selectedHostel,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class MessMenuViewModel extends AutoDisposeNotifier<MessMenuState> {
  @override
  MessMenuState build() {
    // Default values. Hostel might need to be fetched async. 
    // For now, default to Kumaon or let UI init it.
    // Ideally we load user pref.
    return MessMenuState(
      selectedHostel: 'h_kumaon',
      selectedDate: DateTime.now(),
    );
  }
  
  // Initialize with preference if available
  Future<void> initHostel() async {
     final savedId = await ref.read(messServiceProvider).getCurrentHostelId();
     if (savedId != null) {
       state = state.copyWith(selectedHostel: savedId);
     }
  }

  void setHostel(String hostelId) {
    state = state.copyWith(selectedHostel: hostelId);
    // Persist
    ref.read(messServiceProvider).setCurrentHostelId(hostelId);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
}

final messMenuViewModelProvider = NotifierProvider.autoDispose<MessMenuViewModel, MessMenuState>(MessMenuViewModel.new);
