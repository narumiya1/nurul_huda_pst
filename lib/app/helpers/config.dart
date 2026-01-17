class ApiConfig {
  // auth/kbs/sign-in
  // For local backend use host (without port) and set port below.
  // For remote use the plain host (no path)
  // static const baseUrl = "192.168.14.44";
  // static const port = "8000";
  // Remote host (do NOT include path like '/proxy' here)

  // https://api-epesantren.asmuldev.web.id/v1/api/citizen/province

  static const baseUrlAddress = "api-epesantren.asmuldev.web.id";

  // static const port = "8000";

  // If your remote API sits behind a proxy path, include it here.
  // e.g. for qctps proxy the full API base becomes: https://qctps.devtbn.tech/proxy/api/
  static const api = "v1/api/";
  // static const localApi = "proxy/api/tpsmobile/";
}

enum RequestType { local, remote }
