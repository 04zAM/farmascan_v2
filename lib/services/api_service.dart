import 'dart:async';
import 'dart:convert';
import 'package:app_farma_scan_v2/models/departmentData_model.dart';
import 'package:app_farma_scan_v2/models/documentData_model.dart';
import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:app_farma_scan_v2/models/userData_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  final timeoutDuration = Duration(seconds: 60);
  final timeoutDurationPostDocument = Duration(seconds: 120);
  String ipDigitalizacion = '192.168.240.6/ITEDigitalizacionAPI3';
  String servicePlataformaMovil = 'ws_plataformamovil/Service1.svc';
  String ipOCR = '192.168.240.6:8081';

  Future<String> getLocalIp() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      List<NetworkInterface> interfaces = await NetworkInterface.list(
          includeLoopback: false, type: InternetAddressType.IPv4);

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.isLoopback) {
            continue;
          }
          prefs.setString('ipPhone', addr.address);
          return addr.address;
        }
      }

      throw Exception("No se encontró una dirección IP local");
    } catch (e) {
      throw Exception("Error al obtener la dirección IP local: $e");
    }
  }

  Future<UserData> loginUser(
      String ipPharma, String username, String password) async {
    username = username + "_10"; //Control de version _9
    String ipPhone = await getLocalIp();

    try {
      final encodedUsername = Uri.encodeComponent(username);
      final encodedPassword = Uri.encodeComponent(password);
      final encodedIpPhone = Uri.encodeComponent(ipPhone);

      final url = Uri.parse(
        'http://$ipPharma/$servicePlataformaMovil/AutentificarUsuarioFarmaScan?usuario=$encodedUsername&contrasenia=$encodedPassword&ipMovil=$encodedIpPhone&ipMovil2=$encodedIpPhone',
      );

      final response = await http.get(url).timeout(timeoutDuration);

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
      if (e.toString().contains('Failed host')) {
        throw Exception('No se pudo conectar al servidor, verifique la IP.');
      } else {
        throw Exception('$e \n Verifique y vuelva a intentar.');
      }
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
        List<DepartmentData> filteredList = departmentsDataList
            .where((data) =>
                !data.ambAmbiente.contains("CONVENIOS") &&
                !data.ambAmbiente.contains("CUPONES"))
            .toList();

        return filteredList;
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

  Future<Map<String, dynamic>> getDocumentType(String nroComprobante) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ipPharma = prefs.getString('ipPharma');

      final response = await http
          .get(Uri.parse(
              'http://$ipPharma/$servicePlataformaMovil//TipoDocumento?serie=$nroComprobante'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final decodedBody = json.decode(utf8DecodedBody);
        return decodedBody;
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

  Future<Map<String, dynamic>> getBarcodeDocument(
      String documento, String origenDatos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ipPharma = prefs.getString('ipPharma');

      final response = await http
          .get(Uri.parse(
              'http://$ipPharma/$servicePlataformaMovil/VerificarFactura?serie=$documento|$origenDatos'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final decodedBody = json.decode(utf8DecodedBody);
        final documentFields = decodedBody['mensaje'];
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

  Future<Map<String, dynamic>> postDocuments(
      DocumentFieldsData documento) async {
    try {
      final token = await getTokenITEDigitalizacion();
      final cabecera = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      //Testear el api
      //print(jsonEncode(documento.toJson()));
      //final jsonTemp = jsonEncode(documento.toJson());
      final response = await http
          .post(
            Uri.parse('http://$ipDigitalizacion/api/Documento'),
            headers: cabecera,
            body: jsonEncode(documento.toJson()),
          )
          .timeout(timeoutDurationPostDocument);

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final decodedBody = json.decode(utf8DecodedBody);
        return decodedBody;
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

  Future<String> postOCR(String base64Image, int codigoDocumento) async {
    try {
      final apiUrl = "http://192.168.240.6:8081/predecir";
      final headers = {"Content-Type": "application/json"};

      final data = {
        "CodigoDocumento": codigoDocumento,
        "Base64": base64Image,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final mensaje = responseBody["mensaje"];
        return mensaje;
      } else {
        throw Exception("Error de conexión con el servidor");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
