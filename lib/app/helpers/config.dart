class ApiConfig {
  // For Android Emulator: use 10.0.2.2 to access localhost
  // For Chrome/Web: use localhost or 127.0.0.1
  // For Physical Device: use your computer's IP address
  // For Remote Server: use the remote host address

  // === LOCAL DEVELOPMENT ===
  static const baseUrlAddress = "10.0.2.2";
  static const port = "8000";
  static const useHttps = false;

  // === REMOTE SERVER ===
  // static const baseUrlAddress = "api-epesantren.asmuldev.web.id";
  // static const port = "";
  // static const useHttps = true;

  static const api = "v1/api/";
}

enum RequestType { local, remote }
