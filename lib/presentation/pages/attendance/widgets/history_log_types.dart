import 'package:adsum/domain/models/models.dart';

enum DayType {
  classDay,
  holiday,
  cancelled,
  rescheduled,
  noClass,
}

class CalendarEntry { 

  const CalendarEntry({
    required this.type,
    this.status,
    this.description,
    this.log,
  });
  final DayType type;
  final AttendanceStatus? status; 
  final String? description; 
  final AttendanceLog? log;
}
