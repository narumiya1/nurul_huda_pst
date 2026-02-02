class ApiConfig {
  // For Android Emulator: use 10.0.2.2 to access localhost
  // For Chrome/Web: use localhost or 127.0.0.1

  // static String get baseUrlAddress {
  //   if (kIsWeb) {
  //     return "127.0.0.1";
  //   }
  //   return "10.0.2.2";
  // }

  // static const port = "8000";
  // static const useHttps = false;

  // === REMOTE SERVER ===
  static const baseUrlAddress = "api-epesantren.asmuldev.web.id";
  static const port = "";
  static const useHttps = true;

  static const api = "v1/api/";
}

enum RequestType { local, remote }
