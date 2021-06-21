import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class DBService {
  late SharedPreferences prefs;
  late Logger log;

  DBService() {
    log = new Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 1,
        colors: true,
        printEmojis: false,
      ),
    );
  }

  Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();
    return true;
  }

  void setMaxHBToDB(int heartBeat) {
    prefs.setInt("max_heart_beat", heartBeat);
    log.v({
      "type": "set",
      "key": "max",
      "value": heartBeat,
    });
  }

  int getMaxHBFromDB() {
    int? heartBeat = prefs.getInt("max_heart_beat");
    log.v({
      "type": "get",
      "key": "max",
      "value": heartBeat,
    });
    return heartBeat ?? 0;
  }

  void setMinHBToDB(int heartBeat) {
    prefs.setInt("min_heart_beat", heartBeat);
    log.v({
      "type": "set",
      "key": "min",
      "value": heartBeat,
    });
  }

  int getMinHBFromDB() {
    int? heartBeat = prefs.getInt("min_heart_beat");
    log.v({
      "type": "get",
      "key": "min",
      "value": heartBeat,
    });
    return heartBeat ?? 0;
  }

  void setAvgHBToDB(int heartBeat) {
    prefs.setInt("avg_heart_beat", heartBeat);
    log.v({
      "type": "set",
      "key": "avg",
      "value": heartBeat,
    });
  }

  int getAvgHBFromDB() {
    int? heartBeat = prefs.getInt("avg_heart_beat");
    log.v({
      "type": "get",
      "key": "avg",
      "value": heartBeat,
    });
    return heartBeat ?? 0;
  }
}
