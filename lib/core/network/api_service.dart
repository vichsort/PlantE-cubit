import 'dart:convert';
import 'dart:io'; // Para SocketException
import 'package:http/http.dart' as http;
import '../error/api_exception.dart'; // Importa a exceção customizada

class ApiService {
  // --- CONFIGURAÇÃO ---
  // Use '10.0.2.2' para o emulador Android acessar o localhost do PC.
  // Use o IP local da sua máquina (ex: '192.168.1.100') para iOS/Dispositivo Físico.
  final String _baseUrl = 'http://10.0.2.2:5000/api/v1';

  String? _token; // Armazena o token JWT

  // --- Gerenciamento do Token ---
  void setToken(String? token) {
    _token = token;
    print("ApiService: Token set.");
  }

  void clearToken() {
    _token = null;
    print("ApiService: Token cleared.");
  }

  // --- Cabeçalhos Padrão ---
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // --- Métodos HTTP ---

  Future<dynamic> get(String endpoint) async { // Retorna dynamic pois 'data' pode ser Map ou List
    final url = Uri.parse('$_baseUrl$endpoint');
    print('ApiService GET: $url');
    try {
      final response = await http.get(url, headers: _getHeaders());
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Erro de conexão. Verifique sua rede.', 503, errorCode: 'NETWORK_ERROR');
    } catch (e) {
       throw ApiException('Erro desconhecido no GET: ${e.toString()}', 500, errorCode: 'UNKNOWN_GET_ERROR');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    print('ApiService POST: $url');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Erro de conexão. Verifique sua rede.', 503, errorCode: 'NETWORK_ERROR');
    } catch (e) {
       throw ApiException('Erro desconhecido no POST: ${e.toString()}', 500, errorCode: 'UNKNOWN_POST_ERROR');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    print('ApiService PUT: $url');
    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Erro de conexão. Verifique sua rede.', 503, errorCode: 'NETWORK_ERROR');
    } catch (e) {
       throw ApiException('Erro desconhecido no PUT: ${e.toString()}', 500, errorCode: 'UNKNOWN_PUT_ERROR');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    print('ApiService DELETE: $url');
    try {
      final response = await http.delete(url, headers: _getHeaders());
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Erro de conexão. Verifique sua rede.', 503, errorCode: 'NETWORK_ERROR');
    } catch (e) {
       throw ApiException('Erro desconhecido no DELETE: ${e.toString()}', 500, errorCode: 'UNKNOWN_DELETE_ERROR');
    }
  }

  // --- Tratamento da Resposta ---
  dynamic _handleResponse(http.Response response) { // Retorna dynamic
    final statusCode = response.statusCode;
    print('ApiService Response: $statusCode');

    Map<String, dynamic> decodedBody;
    try {
       decodedBody = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Resposta inválida do servidor (não JSON).', statusCode, errorCode: 'INVALID_RESPONSE_FORMAT');
    }

    final String status = decodedBody['status'] ?? 'error';
    final String message = decodedBody['message'] ?? 'Erro desconhecido na resposta da API.';
    final String? errorCode = decodedBody['error_code'];
    final dynamic data = decodedBody['data']; // 'data' PODE SER null, Map, ou List

    if (status == 'success') {
      // Retorna o conteúdo de 'data' diretamente
      // Se 'data' for null (ex: DELETE sucesso), retorna null.
      // Os Serviços que chamam o ApiService tratarão o null/Map/List conforme esperado.
      return data;
    } else {
      // Lança a exceção com detalhes do erro da API
      throw ApiException(message, statusCode, errorCode: errorCode);
    }
  }
}
