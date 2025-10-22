
import 'package:plante/core/network/api_service.dart';
import 'package:plante/core/storage/secure_storage_service.dart';
// import '../../../core/error/api_exception.dart';

/// Serviço responsável pela lógica de autenticação.
/// Interage com a ApiService para chamadas de rede e
/// com SecureStorageService para persistência segura do token.
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
      print("AuthService: Attempting login for $email"); // Debug
      // Chama o endpoint de login da API Flask via ApiService
      final responseData = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      // Extrai o token da resposta (esperamos um Map com a chave 'token')
      final token = responseData?['token'] as String?; // Safely access token

      if (token != null && token.isNotEmpty) {
        // 1. Salva o token de forma segura no dispositivo
        await _secureStorageService.saveToken(token);
        // 2. Informa ao ApiService para usar este token em futuras requisições
        _apiService.setToken(token);
        print("AuthService: Login successful, token saved."); // Debug
      } else {
        // Se a API retornou sucesso (status 200) mas sem token, algo está errado.
        print("AuthService: Login successful but no token received from API."); // Debug
        throw Exception("Token não recebido do servidor após login."); // Lança erro genérico
      }
    }
    // Não precisamos capturar ApiException aqui, pois queremos que o Cubit a receba
    // para poder mostrar a mensagem de erro específica da API (ex: "Credenciais inválidas").
    // O 'catch (e)' no Cubit cuidará disso.
    catch (e) {
      print("AuthService: Login failed - $e"); // Debug
      // Simplesmente re-lança a exceção para a camada superior (Cubit) tratar.
      rethrow;
    }
  }

  /// Tenta registrar um novo usuário com email e senha.
  /// Retorna `void` em caso de sucesso.
  /// Lança [ApiException] ou outra exceção em caso de falha.
  Future<void> register(String email, String password) async {
    try {
      print("AuthService: Attempting registration for $email"); // Debug
      // Chama o endpoint de registro da API Flask
      await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
      });
      // A API retorna 201 Created com user_id, mas não precisamos dele aqui
      print("AuthService: Registration successful for $email."); // Debug
      // Após o registro, o usuário geralmente precisa fazer login separadamente.
      // Se a API fizesse login automático após registro, pegaríamos o token aqui.
    } catch (e) {
      print("AuthService: Registration failed - $e"); // Debug
      rethrow; // Re-lança a exceção para o Cubit tratar (ex: "Email já em uso")
    }
  }

  /// Realiza o logout do usuário.
  /// Limpa o token do armazenamento seguro e do ApiService.
  Future<void> logout() async {
    try {
      print("AuthService: Performing logout."); // Debug
      // 1. (Opcional) Informa o backend para invalidar o token no lado do servidor, se houver endpoint.
      // try {
      //   await _apiService.delete('/auth/logout'); // Exemplo
      // } catch (e) {
      //   print("AuthService: Failed to notify backend on logout - $e");
      //   // Continua mesmo assim, o importante é limpar localmente.
      // }

      // 2. Remove o token do armazenamento seguro local
      await _secureStorageService.deleteToken();
      // 3. Informa ao ApiService para parar de usar o token
      _apiService.clearToken();
      print("AuthService: Logout successful, token cleared locally."); // Debug
    } catch (e) {
      print("AuthService: Error during logout - $e");
      // Mesmo em caso de erro, tenta garantir a limpeza local por segurança.
      try {
        await _secureStorageService.deleteToken();
        _apiService.clearToken();
      } catch (finalError) {
         print("AuthService: Critical error clearing token during logout failure - $finalError");
      }
      // Re-lança o erro original para que a UI possa ser notificada, se necessário
      rethrow;
    }
  }

  /// Verifica se existe um token JWT válido armazenado localmente.
  /// Usado na inicialização do app para determinar o estado inicial de autenticação.
  /// Retorna o token se existir e for válido (a validação real é feita pela API),
  /// caso contrário, retorna null.
  Future<String?> checkAuthenticationStatus() async {
    print("AuthService: Checking initial authentication status."); // Debug
    final token = await _secureStorageService.getToken();
    if (token != null) {
      // Se encontramos um token, informamos ao ApiService para usá-lo
      _apiService.setToken(token);
      print("AuthService: Found existing token."); // Debug
      // Poderíamos fazer uma chamada a um endpoint '/auth/verify' aqui
      // para garantir que o token ainda é válido no backend, mas para começar,
      // assumir que ele é válido é mais simples. O erro virá na primeira chamada protegida.
    } else {
      print("AuthService: No existing token found."); // Debug
      _apiService.clearToken(); // Garante que ApiService está sem token
    }
    return token; // Retorna o token (ou null) para o AuthCubit decidir o estado
  }
}