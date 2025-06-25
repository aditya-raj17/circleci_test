import 'package:flutter_dotenv/flutter_dotenv.dart';

class Envhelper {
  static Future init() async {
    await dotenv.load(fileName: ".env");
  }

  static String getEnv(String key) {
    return dotenv.env[key] ?? "";
  }

  get realm => getEnv('REALM');
}