import 'dart:async';
import 'dart:convert';
import 'package:app_farma_scan_v2/models/departmentData_model.dart';
import 'package:app_farma_scan_v2/models/documentData_model.dart';
import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:app_farma_scan_v2/models/userData_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final timeoutDuration = Duration(seconds: 20);
  String ipDigitalizacion = '192.168.240.6/ITEDigitalizacionAPI3';

  Future<UserData> loginUser(
      String ipPharma, String username, String password) async {
    username = username + "_9"; //Control de version _9
    try {
      final response = await http
          .get(Uri.parse(
            'http://$ipPharma/ws_plataformamovil/Service1.svc/AutentificarUsuarioFarmaScan?usuario=$username&contrasenia=$password&ipMovil=$ipPharma&ipMovil2=$ipPharma',
          ))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final decodedBody = jsonDecode(utf8DecodedBody);

        if (decodedBody['respuesta'] == 'ok') {
          return UserData.fromJson(decodedBody);
        } else {
          throw Exception(decodedBody['mensaje']);
        }
      } else {
        throw Exception('Error de conexión con el servidor');
      }
    } on TimeoutException {
      final timeoutSeconds = timeoutDuration.inSeconds;
      throw Exception(
          'Tiempo de espera agotado. No se pudo conectar al servidor en $timeoutSeconds segundos.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> getTokenITEDigitalizacion() async {
    try {
      final credenciales = {
        'grant_type': 'password',
        'client_id': '6864fc4f-9298-4633-80c0-4d4ea23ae9d6',
        'client_secret': 'Dd5/f2\$E'
      };

      final cabecera = {'Content-Type': 'application/x-www-form-urlencoded'};

      final response = await http
          .post(
              Uri.parse(
                'http://$ipDigitalizacion/oauth/token',
              ),
              headers: cabecera,
              body: credenciales)
          .timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final accessToken = jsonResponse['access_token'];
        return accessToken;
      } else {
        throw Exception('Error de conexión con el servidor');
      }
    } on TimeoutException {
      final timeoutSeconds = timeoutDuration.inSeconds;
      throw Exception(
          'Tiempo de espera agotado. No se pudo conectar al servidor en $timeoutSeconds segundos.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<DepartmentData>> getDepartamentos() async {
    try {
      final token = await getTokenITEDigitalizacion();
      final cabecera = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(
            Uri.parse(
                'http://$ipDigitalizacion/api/Departamentos/4/?aprobacion=S'),
            headers: cabecera,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final decodedBody = json.decode(utf8DecodedBody) as List<dynamic>;
        final departmentsDataList = decodedBody
            .map((jsonObject) => DepartmentData.fromJson(jsonObject))
            .toList();
        return departmentsDataList;
      } else {
        throw Exception('Error de conexión con el servidor');
      }
    } on TimeoutException {
      final timeoutSeconds = timeoutDuration.inSeconds;
      throw Exception(
          'Tiempo de espera agotado. No se pudo conectar al servidor en $timeoutSeconds segundos.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<DocumentData>> getDocumentsByDepartment(
      String departmentCode) async {
    try {
      final token = await getTokenITEDigitalizacion();
      final cabecera = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(
            Uri.parse(
                'http://$ipDigitalizacion/api/Catalogo/?id=4&id2=$departmentCode'),
            headers: cabecera,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final decodedBody = json.decode(utf8DecodedBody) as List<dynamic>;
        final documentsDataList = decodedBody
            .map((jsonObject) => DocumentData.fromJson(jsonObject))
            .toList();
        return documentsDataList;
      } else {
        throw Exception('Error de conexión con el servidor');
      }
    } on TimeoutException {
      final timeoutSeconds = timeoutDuration.inSeconds;
      throw Exception(
          'Tiempo de espera agotado. No se pudo conectar al servidor en $timeoutSeconds segundos.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<DocumentFieldsData> getDocument(String catCodigo) async {
    try {
      final token = await getTokenITEDigitalizacion();
      final cabecera = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(
            Uri.parse('http://$ipDigitalizacion/api/Documento/$catCodigo'),
            headers: cabecera,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final decodedBody = json.decode(utf8DecodedBody);
        final documentFields = DocumentFieldsData.fromJson(decodedBody);
        return documentFields;
      } else {
        throw Exception('Error de conexión con el servidor');
      }
    } on TimeoutException {
      final timeoutSeconds = timeoutDuration.inSeconds;
      throw Exception(
          'Tiempo de espera agotado. No se pudo conectar al servidor en $timeoutSeconds segundos.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
