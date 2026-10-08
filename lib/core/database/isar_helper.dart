import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/attendance/data/models/attendance_record_isar.dart';

class IsarHelper {
  static Future<Isar> init() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [AttendanceRecordIsarSchema],
      directory: dir.path,
    );
  }
}
