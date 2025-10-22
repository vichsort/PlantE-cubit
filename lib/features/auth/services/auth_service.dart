
import 'package:plante/core/network/api_service.dart';
import 'package:plante/core/storage/secure_storage_service.dart';
import '../../../core/error/api_exception.dart';

class AuthService {
  final ApiService _apiService;
  final SecureStorageService _secureStorageService;

  // Recebe as dependências (ApiService e SecureStorageService) via construtor.
  // Isso facilita a injeção de dependência e os testes.
  AuthService(this._apiService, this._secureStorageService);

  /// Tenta autenticar o usuário com email e senha.
  /// Em caso de sucesso, salva o token JWT e o configura no ApiService.
  /// Retorna `void` em caso de sucesso.
  /// Lança [ApiException] ou outra exceção em caso de falha.
  Future<void> login(String email, String password) async {
    try {
      final responseData = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final token = responseData?['token'] as String?;

      if (token != null && token.isNotEmpty) {
        await _secureStorageService.saveToken(token);
        _apiService.setToken(token);

      } else {
        throw Exception("Token não recebido do servidor após login.");
      }
    }
    // Não precisamos capturar ApiException aqui, pois queremos que o Cubit a receba
    // para poder mostrar a mensagem de erro específica da API (ex: "Credenciais inválidas").
    // O 'catch (e)' no Cubit cuidará disso.
    catch (e) {
      rethrow;
    }
  }

  /// Tenta registrar um novo usuário com email e senha.
  /// Retorna `void` em caso de sucesso.
  /// Lança [ApiException] ou outra exceção em caso de falha.
  Future<void> register(String email, String password) async {
    try {
      await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
      });

    } catch (e) {
      rethrow; // Re-lança a exceção para o Cubit tratar (ex: "Email já em uso")
    }
  }

  /// Realiza o logout do usuário.
  /// Limpa o token do armazenamento seguro e do ApiService.
  Future<void> logout() async {
    try {
      await _secureStorageService.deleteToken();
      _apiService.clearToken();

    } catch (e) {
      try {
        await _secureStorageService.deleteToken();
        _apiService.clearToken();
      } catch (finalError) {
         throw Exception("AuthService: Critical error clearing token during logout failure - $finalError");
      }
      rethrow;
    }
  }

  /// Verifica se existe um token JWT válido armazenado localmente.
  /// Usado na inicialização do app para determinar o estado inicial de autenticação.
  /// Retorna o token se existir e for válido (a validação real é feita pela API),
  /// caso contrário, retorna null.
  Future<String?> checkAuthenticationStatus() async {
    final token = await _secureStorageService.getToken();
    if (token != null) {
      _apiService.setToken(token);
    } else {
      _apiService.clearToken();
    }
    return token;
  }
}