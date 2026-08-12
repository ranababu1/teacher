import 'models/review_schedule.dart';

abstract class ReviewScheduleRepository {
  Future<ReviewSchedule> getSchedule(String conceptId);

  Future<List<ReviewSchedule>> getDueSchedules();

  Future<void> saveSchedule(ReviewSchedule schedule);
}
