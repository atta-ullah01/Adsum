import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExtractedEvent {

  ExtractedEvent({
    required this.title,
    required this.date,
    required this.type,
    this.isLowConfidence = false,
    this.description = '',
  });
  final String title;
  final DateTime date;
  final String type;
  final bool isLowConfidence;
  final String description;
}

class HolidayInjectionState {

  HolidayInjectionState({
    this.isProcessing = false,
    this.extractedEvents = const [],
  });
  final bool isProcessing;
  final List<ExtractedEvent> extractedEvents;

  HolidayInjectionState copyWith({
    bool? isProcessing,
    List<ExtractedEvent>? extractedEvents,
  }) {
    return HolidayInjectionState(
      isProcessing: isProcessing ?? this.isProcessing,
      extractedEvents: extractedEvents ?? this.extractedEvents,
    );
  }
}

class HolidayInjectionViewModel extends AutoDisposeNotifier<HolidayInjectionState> {
  @override
  HolidayInjectionState build() {
    // Mock extracted data
    return HolidayInjectionState(
      extractedEvents: [
        ExtractedEvent(
          title: 'Mahavir Jayanti',
          date: DateTime(2026, 4, 4),
          type: 'Holiday',
          description: 'Imported from PDF',
        ),
        ExtractedEvent(
          title: 'Good Friday',
          date: DateTime(2026, 4, 7),
          type: 'Holiday',
          description: 'Imported from PDF',
        ),
        ExtractedEvent(
          title: 'Dr. Ambedkar Jayanti',
          date: DateTime(2026, 4, 14),
          type: 'Holiday',
          description: 'Imported from PDF',
        ),
        ExtractedEvent(
          title: 'Mid-Sem Pattern',
          date: DateTime(2026, 5, 18),
          type: 'Exam Info',
          isLowConfidence: true,
          description: 'Imported from PDF',
        ),
      ],
    );
  }

  Future<void> importHolidays() async {
    state = state.copyWith(isProcessing: true);
    
    final service = ref.read(calendarServiceProvider);
    
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    for (final event in state.extractedEvents) {
      // Only import holidays for now, or all? Logic was specific in original file.
      // Original file imported all as 'Holiday' type for the first 3.
      // Let's blindly import high confidence ones or just all as appropriate.
      // The original code hardcoded the addEvent calls. Here we iterate.
      
      if (event.isLowConfidence) continue; // Skip low confidence for now? Or import?
      // Original code did not import the last one (Mid-Sem).
      
      await service.addEvent(
        title: event.title,
        date: event.date,
        type: CalendarEventType.holiday,
        description: event.description,
      );
    }
    
    ref.invalidate(calendarEventsProvider);
    state = state.copyWith(isProcessing: false);
  }
}

final holidayInjectionViewModelProvider = NotifierProvider.autoDispose<HolidayInjectionViewModel, HolidayInjectionState>(HolidayInjectionViewModel.new);
