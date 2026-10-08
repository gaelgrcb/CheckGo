import 'package:ntp/ntp.dart';

abstract class TimeService {
  Future<DateTime> getOfficialTime();
}

class TimeServiceImpl implements TimeService {
  @override
  Future<DateTime> getOfficialTime() async {
    try {
      // Intentamos obtener la hora del servidor NTP de Google
      DateTime ntpTime = await NTP.now(lookUpAddress: 'time.google.com');
      return ntpTime;
    } catch (e) {
      // Fallback: Si no hay red, usar hora local.
      // En un sistema real se debería considerar el último offset calculado o el uptime.
      return DateTime.now();
    }
  }
}
