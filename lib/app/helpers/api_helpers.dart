import 'dart:convert';
import 'dart:io';
import 'package:epesantren_mob/app/helpers/config.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  final http.Client client = http.Client();

  Future<T> getData<T>({
    required Uri uri,
    required T Function(dynamic data) builder,
    Map<String, String>? header,
  }) async {
    try {
      final response = await client.get(
        uri,
        headers: header,
      );
      // Debug basic info
      print('API GET: $uri -> status=${response.statusCode}');
      switch (response.statusCode) {
        case HttpStatus.ok:
          try {
            final data = jsonDecode(response.body);
            return builder(data);
          } catch (e) {
            final bodyPreview = response.body.length > 300
                ? response.body.substring(0, 300)
                : response.body;
            throw Exception(
                'Invalid JSON response from $uri (status ${response.statusCode}). Body preview: $bodyPreview');
          }
        case HttpStatus.notFound:
          throw Exception("endpoint not found");
        case HttpStatus.unauthorized:
          // LocalPrefsRepository().deleteToken();
          // LocalPrefsRepository().deleteUser();
          // LocalPrefsRepository().deleteCurrentProfile();
          // AppRoutes().clearAndNavigate(AppRoutes.auth);
          throw Exception("token no longer valid");
        default:
          final data = jsonDecode(response.body);
          throw Exception(data.toString());
      }
    } on SocketException catch (_) {
      throw Exception("No Internet Connection");
    }
  }

  Future<T> getDataNoHeader<T>({
    required Uri uri,
    required T Function(dynamic data) builder,
  }) async {
    try {
      final response = await client.get(
        uri,
      );
      // Debug basic info
      print('API GET: $uri -> status=${response.statusCode}');
      switch (response.statusCode) {
        case HttpStatus.ok:
          try {
            final data = jsonDecode(response.body);
            return builder(data);
          } catch (e) {
            final bodyPreview = response.body.length > 300
                ? response.body.substring(0, 300)
                : response.body;
            throw Exception(
                'Invalid JSON response from $uri (status ${response.statusCode}). Body preview: $bodyPreview');
          }
        case HttpStatus.notFound:
          throw Exception("endpoint not found");
        case HttpStatus.unauthorized:
          // LocalPrefsRepository().deleteToken();
          // LocalPrefsRepository().deleteUser();
          // LocalPrefsRepository().deleteCurrentProfile();
          // AppRoutes().clearAndNavigate(AppRoutes.auth);
          throw Exception("token no longer valid");
        default:
          final data = jsonDecode(response.body);
          throw Exception(data.toString());
      }
    } on SocketException catch (_) {
      throw Exception("No Internet Connection");
    }
  }

  Future<T> deleteData<T>({
    required Uri uri,
    required T Function(dynamic data) builder,
    Map<String, String>? header,
  }) async {
    try {
      final response = await client.delete(
        uri,
        headers: header,
      );
      print('API DELETE: $uri -> status=${response.statusCode}');
      switch (response.statusCode) {
        case HttpStatus.ok:
          try {
            final data = jsonDecode(response.body);
            return builder(data);
          } catch (e) {
            final bodyPreview = response.body.length > 300
                ? response.body.substring(0, 300)
                : response.body;
            throw Exception(
                'Invalid JSON response from $uri (status ${response.statusCode}). Body preview: $bodyPreview');
          }
        case HttpStatus.notFound:
          throw Exception("endpoint not found");
        case HttpStatus.unauthorized:
          // LocalPrefsRepository().deleteToken();
          // LocalPrefsRepository().deleteUser();
          // LocalPrefsRepository().deleteCurrentProfile();
          // AppRoutes().clearAndNavigate(AppRoutes.auth);
          throw Exception("token no longer valid");
        default:
          final data = jsonDecode(response.body);
          throw Exception(data.toString());
      }
    } on SocketException catch (_) {
      throw Exception("No Internet Connection");
    }
  }

  Future<T> postData<T>({
    required Uri uri,
    required T Function(dynamic data) builder,
    Map<String, String>? header,
    Map<String, dynamic>? jsonBody,
  }) async {
    try {
      final response = await client.post(
        uri,
        headers: header,
        body: jsonEncode(jsonBody),
      );
      print('API POST: $uri -> status=${response.statusCode}');
      switch (response.statusCode) {
        case HttpStatus.ok:
        case HttpStatus.created:
          try {
            final data = jsonDecode(response.body);
            return builder(data);
          } catch (e) {
            final bodyPreview = response.body.length > 300
                ? response.body.substring(0, 300)
                : response.body;
            throw Exception(
                'Invalid JSON response from $uri (status ${response.statusCode}). Body preview: $bodyPreview');
          }
        case HttpStatus.unauthorized:
          // LocalPrefsRepository().deleteToken();
          // LocalPrefsRepository().deleteUser();
          // LocalPrefsRepository().deleteCurrentProfile();
          // AppRoutes().clearAndNavigate(AppRoutes.auth);
          throw Exception("token no longer valid");
        case HttpStatus.unprocessableEntity:
          final data = jsonDecode(response.body);
          throw Exception(data["message"]);
        case HttpStatus.notFound:
          throw Exception("endpoint not found");
        default:
          final data = jsonDecode(response.body);
          throw Exception(data.toString());
      }
    } on SocketException catch (_) {
      throw Exception("No Internet Connection");
    }
  }

  Future<T> patchData<T>({
    required Uri uri,
    required T Function(dynamic data) builder,
    Map<String, String>? header,
    Map<String, dynamic>? jsonBody,
  }) async {
    try {
      final response = await client.patch(
        uri,
        headers: header,
        body: jsonEncode(jsonBody),
      );
      print('API PATCH: $uri -> status=${response.statusCode}');
      switch (response.statusCode) {
        case HttpStatus.ok:
          try {
            final data = jsonDecode(response.body);
            return builder(data);
          } catch (e) {
            final bodyPreview = response.body.length > 300
                ? response.body.substring(0, 300)
                : response.body;
            throw Exception(
                'Invalid JSON response from $uri (status ${response.statusCode}). Body preview: $bodyPreview');
          }
        case HttpStatus.unauthorized:
          // LocalPrefsRepository().deleteToken();
          // LocalPrefsRepository().deleteUser();
          // LocalPrefsRepository().deleteCurrentProfile();
          // AppRoutes().clearAndNavigate(AppRoutes.auth);
          throw Exception("token no longer valid");
        case HttpStatus.unprocessableEntity:
          final data = jsonDecode(response.body);
          throw Exception(data["message"]);
        case HttpStatus.notFound:
          throw Exception("endpoint not found");
        default:
          final data = jsonDecode(response.body);
          throw Exception(data.toString());
      }
    } on SocketException catch (_) {
      throw Exception("No Internet Connection");
    }
  }

  Future<T> postImageData<T>({
    required Uri uri,
    required Map<String, File?> files,
    required T Function(dynamic data) builder,
    Map<String, String>? fields,
    Map<String, String>? header,
  }) async {
    try {
      final x = http.MultipartRequest("POST", uri);

      files.forEach((key, value) async {
        if (value != null) {
          final multipartFile = await http.MultipartFile.fromPath(
            key,
            value.path,
          );
          x.files.add(multipartFile);
        }
      });

      if (fields != null) {
        x.fields.addAll(fields);
      }

      if (header != null) {
        x.headers.addAll(header);
      }

      final streamedRespoonse = await x.send();
      final response = await http.Response.fromStream(streamedRespoonse);
      print('API MULTIPART POST: $uri -> status=${response.statusCode}');
      switch (response.statusCode) {
        case HttpStatus.ok:
          try {
            final data = jsonDecode(response.body);
            return builder(data);
          } catch (e) {
            final bodyPreview = response.body.length > 300
                ? response.body.substring(0, 300)
                : response.body;
            throw Exception(
                'Invalid JSON response from $uri (status ${response.statusCode}). Body preview: $bodyPreview');
          }
        case HttpStatus.unauthorized:
          // LocalPrefsRepository().deleteToken();
          // LocalPrefsRepository().deleteUser();
          // LocalPrefsRepository().deleteCurrentProfile();
          // AppRoutes().clearAndNavigate(AppRoutes.auth);
          throw Exception("token no longer valid");
        case HttpStatus.notFound:
          throw Exception("endpoint not found");
        default:
          final data = jsonDecode(response.body);
          throw Exception(data.toString());
      }
    } on SocketException catch (_) {
      throw Exception("No Internet Connection");
    }
  }

  static Uri buildUri({
    required String endpoint,
    Map<String, String>? params,
  }) {
    var uri = Uri(
      // Use http for local, https for remote
      scheme: ApiConfig.useHttps ? "https" : "http",
      host: ApiConfig.baseUrlAddress,

      // Include port for local backend
      port: ApiConfig.port.isNotEmpty ? int.parse(ApiConfig.port) : null,

      path: "${ApiConfig.api}$endpoint",
      queryParameters: params,
    );

    return uri;
  }

  // static Uri buildLocalUri({
  //   required String endpoint,
  //   Map<String, String>? params,
  // }) {
  //   var uri = Uri(
  //     // *change to http for local backend
  //     scheme: "https",
  //     host: ApiConfig.baseUrlAddress,

  //     // *uncomment this for local backend
  //     // port: int.parse(ApiConfig.port),

  //     path: "${ApiConfig.api}$endpoint",
  //     queryParameters: params,
  //   );

  //   return uri;
  // }

  // static Uri buildTpaLocalUri({
  //   required String endpoint,
  //   Map<String, String>? params,
  // }) {
  //   var uri = Uri(
  //     // *change to http for local backend
  //     scheme: "https",
  //     host: ApiConfig.baseUrlAddress,

  //     // *uncomment this for local backend
  //     // port: int.parse(ApiConfig.port),

  //     path: "${ApiConfig.api}$endpoint",
  //     queryParameters: params,
  //   );

  //   return uri;
  // }

  // static Uri buildUriAddress({
  //   required String endpoint,
  //   Map<String, String>? params,
  // }) {
  //   var uri = Uri(
  //     // *change to http for local backend
  //     scheme: "https",
  //     host: ApiConfig.baseUrlAddress,

  //     // *uncomment this for local backend
  //     // port: int.parse(ApiConfig.port),

  //     path: "${ApiConfig.api}$endpoint",
  //     queryParameters: params,
  //   );
  //   print("$uri");
  //   print(uri.toString());
  //   return uri;
  // }

  static Map<String, String> header() {
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  static Map<String, String> tokenHeader(String token) {
    return {
      "accept": "application/json",
      "content-type": "application/json",
      "authorization": "Bearer $token",
    };
  }

  static Map<String, String> tokenHeaderMultipart(String token) {
    return {
      "accept": "application/json",
      "authorization": "Bearer $token",
    };
  }
}
