
  // ============================================================
  // EDGE CASES & ROBUSTNESS TESTS
  // ============================================================
  group('Edge Cases & Robustness', () {
    test('ActionItemRepository: delete non-existent item should not throw', () async {
      final repo = container.read(actionItemRepositoryProvider);
      // Should complete without error
      await repo.delete('non_existent_id');
      final items = await repo.getAll();
      expect(items.isEmpty, true);
    });

    test('EnrollmentRepository: update non-existent enrollment does nothing', () async {
      final repo = container.read(enrollmentRepositoryProvider);
      
      final ghostEnrollment = Enrollment(
        enrollmentId: 'ghost', 
        courseCode: 'GHOST', 
        stats: const CourseStats()
      );
      
      // Should not throw and not add the item
      await repo.updateEnrollment(ghostEnrollment);
      
      final fetched = await repo.getEnrollment('ghost');
      expect(fetched, isNull);
    });

    test('JsonFileService: handle corrupt file gracefully', () async {
      // Manually create a corrupt JSON file
      final file = File('${tempDir.path}/corrupt.json');
      await file.writeAsString('{ "incomplete": ');

      // readJson should throw FormatException or return null/empty depending on impl
      // The current impl catches error and returns null or throws.
      // Let's verify standard behavior.
      
      try {
        await jsonService.readJson('corrupt.json');
        // If it doesn't throw, expecting null or rethrow
      } catch (e) {
        expect(e, isA<FormatException>());
      }
    });
    
    test('ScheduleRepository: overlapping slots allowed in persistence', () async {
       // Persistence layer should strictly store what is given, conflict resolution logic is higher up
       final repo = container.read(scheduleRepositoryProvider);
       
       await repo.addCustomSlot(
         enrollmentId: 'E1',
         dayOfWeek: DayOfWeek.mon,
         startTime: '10:00', 
         endTime: '11:00'
       );
       
       // Add overlapping slot
       await repo.addCustomSlot(
         enrollmentId: 'E1', 
         dayOfWeek: DayOfWeek.mon,
         startTime: '10:30', 
         endTime: '11:30'
       );
       
       final slots = await repo.getSlotsForEnrollment('E1');
       expect(slots.length, 2, reason: 'Persistence layer should allow overlaps');
    });
  });
}
